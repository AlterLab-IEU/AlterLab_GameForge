# State Synchronization Models

Engine-agnostic algorithms with pseudocode. Numbers are rules of thumb unless attributed. Further
reading at the end points to well-known public write-ups and talks.

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Tick | One fixed simulation step (e.g. 1/30 s). Network state is stamped with tick numbers |
| RTT | Round-trip time. One-way latency is roughly RTT / 2, but paths are often asymmetric |
| Jitter | Variation in packet arrival time; the reason buffers exist |
| Loss | Packets that never arrive; unreliable channels must tolerate it |
| Authority | The peer whose version of a value is the truth |
| Snapshot | Authoritative state of relevant entities at a tick |
| Ack | Acknowledgement of the last input or snapshot processed |

## 2. Fixed timestep (every model needs it)

```text
const DT = 1 / 30                    # simulation step
accumulator = 0
loop each render frame:
    accumulator += frame_time (clamped to e.g. 0.25 s to avoid spiral of death)
    while accumulator >= DT:
        sample_input(tick)
        simulate(DT)
        tick += 1
        accumulator -= DT
    alpha = accumulator / DT
    render(interpolate(previous_state, current_state, alpha))
```

Separate simulation rate (how often you step), snapshot rate (how often the server sends) and input
rate (how often clients send). They can differ: e.g. simulate 60 Hz, snapshot 20 Hz, input 60 Hz.

## 3. Snapshot interpolation

The server sends snapshots; clients render remote entities slightly in the past, between two
received snapshots, so motion stays smooth despite jitter and loss.

```text
render_time = estimated_server_time - INTERP_DELAY
find snapshots A, B with A.time <= render_time < B.time
t = (render_time - A.time) / (B.time - A.time)
entity.position = lerp(A.position, B.position, t)
entity.rotation = slerp(A.rotation, B.rotation, t)
if no B yet: extrapolate briefly (<= ~100-250 ms), then freeze
```

- **Interpolation delay**: about two to three snapshot intervals, so one lost packet does not
  starve the buffer (rule of thumb). Valve's "Source Multiplayer Networking" article describes a
  100 ms default for Source engine games.
- **Bandwidth**: send only entities relevant to each client (interest management, section 9), only
  fields that changed since the client's last ack (delta compression), and quantize floats
  (positions to centimeters, angles to 8-16 bits).
- **Teleports**: flag discontinuities so clients snap instead of lerping across the map.

## 4. Client-side prediction and server reconciliation

For the character the player controls. The client applies inputs immediately and corrects when the
server disagrees.

```text
client, each tick:
    input = sample_input(); input.seq = next_seq++
    pending.push(input)
    send(input)                         # unreliable, often with the last N inputs for redundancy
    apply(local_state, input)           # predict

client, on server state S with S.last_input_seq:
    local_state = S.player_state        # rewind to authoritative state
    pending.remove_where(seq <= S.last_input_seq)
    for input in pending: apply(local_state, input)   # replay unacknowledged inputs
    correction = rendered_pos - local_state.pos
    visual_offset += correction         # hide small corrections
    visual_offset *= decay_per_frame    # e.g. converge over ~100 ms; snap if large

server, each tick:
    for each client: take queued inputs in seq order (bounded queue), validate, apply
    broadcast snapshot including each client's last processed input seq
```

Rules:
- `apply()` must be the same code on client and server. Share it; do not write it twice.
- The server never trusts predicted state; it only consumes inputs and validates them (speed,
  cooldowns, resources, timestamps not from the future or too old).
- Predict only what the player controls. Predicting other players or physics interactions
  causes visible corrections.
- Projectiles and abilities: spawn a predicted cosmetic copy locally, replace it with the server's
  object when it arrives.

## 5. Server-side lag compensation

The server rewinds other players' hitboxes to where the shooter saw them, then tests the shot.

```text
server keeps history[tick] = hitboxes of all players (ring buffer, e.g. last 500 ms-1 s)

on fire(input) from client C:
    view_time = input.client_view_tick           # client sends which tick it was rendering
    view_time = clamp(view_time, now - MAX_REWIND, now)
    with rewound_hitboxes(view_time):
        hit = raycast(C.weapon_origin, input.aim)
    apply damage at current time if valid (line of sight, ammo, cooldown, range)
```

- Cap the rewind (Colyseus 0.18's example uses `maxRewindMs: 500`). Higher caps favor
  high-latency attackers and produce "shot behind cover" complaints.
- Favor the shooter for hitscan; for slow projectiles, simulate the projectile on the server
  instead of rewinding.

## 6. Rollback (GGPO-style)

Peers exchange only inputs. Each peer predicts missing remote inputs (usually "same as last
frame"), simulates immediately, and when the real input arrives and differs, loads the saved state
from that frame and re-simulates to the present, all within one rendered frame.

```text
each frame f:
    local_input[f + INPUT_DELAY] = sample()        # 1-3 frames of delay hides small latency
    send(local_input with recent history)
    for each remote input received for frame r:
        if r < f and input != predicted[r]:
            load_state(saved[r]); 
            for k in r .. f-1: simulate(k, inputs_or_predictions(k)); save_state(k+1)
    remote = received[f] or predict(remote_last)    # predict = repeat last input
    save_state(f); simulate(f, local, remote)
    if f - last_confirmed_frame > MAX_ROLLBACK: stall (wait) rather than diverge
```

Requirements:
- **Determinism**: same inputs produce bit-identical state on every peer.
- **Cheap save/load**: the full game state must snapshot and restore in well under a millisecond
  per frame. Keep state in plain data (arrays, structs), not scattered across scene objects.
- **Fast re-simulation**: up to MAX_ROLLBACK frames (often around 7-8 at 60 Hz, rule of thumb) in
  one frame budget. Separate presentation (particles, audio) from simulation so rollbacks do not
  replay sounds.
- Libraries: GGPO (open source, MIT-licensed since 2019) for C/C++; GGRS for Rust and Bevy;
  netfox for Godot; Photon Quantum for Unity (deterministic engine). Check maintenance status.

## 7. Deterministic lockstep

Every peer simulates the same turns from the same inputs; only inputs cross the network. Bandwidth
stays tiny regardless of unit count, which is why RTS games used it (Bettner and Terrano's 2001
"1500 Archers on a 28.8" article on Age of Empires is the classic account).

```text
turn length T (e.g. 100-200 ms); commands issued in turn n execute in turn n + 2
each turn:
    send my commands for turn n + 2 (or an empty "no-op" so peers can advance)
    wait until commands from all peers for turn n are received
    execute turn n deterministically
    every K turns: exchange checksum(state); mismatch => desync report
```

Determinism hazards:
- Floating point across CPUs, compilers, browsers and math libraries. Use fixed-point math, or one
  controlled float implementation (Battle Drones fixed Chrome vs Safari `Math.sin`/`Math.cos`
  differences with custom functions, per Simon Willison, Oct 2026).
- Iteration order of hash maps and sets; use ordered containers.
- Random numbers: one seeded PRNG per simulation, never `Math.random()` or engine RNG in sim code.
- Physics engines: treat any engine as non-deterministic across platforms until checksums prove it.
- Wall-clock time or frame time in simulation code.
- Uninitialized memory, threads, and anything read from the renderer.

Desync tooling (build it first, not last): per-turn state hashes, a command log, and a replay
runner that re-simulates the log and reports the first divergent turn and field.

## 8. Event and command replication

For turn-based, puzzle and card games: clients send commands ("play card 17 on target 3"); the
server validates against the rules, applies them, appends to a log and broadcasts the resulting
events. Reconnecting clients receive a full state snapshot plus events since. Async play stores
the log in a database and notifies players. Simple, auditable, and naturally cheat-resistant.

## 9. Interest management (relevancy)

Send each client only what it is allowed and needs to know: entities within range, in the same
room or zone, on the same team, or visible. It cuts bandwidth and defeats wallhacks, which can only
show what the client received. Engine support: Godot `MultiplayerSynchronizer` visibility filters,
Mirror interest management, Unreal relevancy and Iris filtering, Colyseus Schema `StateView`
(`view.subscribe()`), Photon area-of-interest.

## 10. Reliability and channels

| Data | Delivery |
|---|---|
| Continuous state (positions, snapshots) | Unreliable or unreliable-ordered; newest wins |
| Inputs | Unreliable, each packet repeating the last few inputs |
| One-off events (spawn, death, chat, purchases) | Reliable |
| Large data (level seeds, initial state) | Reliable, chunked; ideally before gameplay starts |

Over WebSockets (TCP) everything is reliable and ordered, so one lost packet stalls everything
behind it (head-of-line blocking). That is acceptable for party and turn-based games; for fast
action on the web, consider WebRTC DataChannels or WebTransport datagrams.

## 11. Clock synchronization

```text
client sends ping {t0 = client_now}
server replies {t0, server_now}
on reply at t1: rtt = t1 - t0; offset = server_now + rtt/2 - t1
keep the median offset of the last N samples; smooth changes; never jump backward
```

Estimated server time drives interpolation (`render_time`) and input tick stamping.

## Further reading (public sources)

- Gabriel Gambetta, "Fast-Paced Multiplayer" (prediction, reconciliation, entity interpolation).
- Glenn Fiedler, "Gaffer On Games" (fixed timestep, snapshot interpolation, networked physics).
- Valve Developer Community, "Source Multiplayer Networking" and "Lag Compensation".
- Paul Bettner and Mark Terrano, "1500 Archers on a 28.8: Network Programming in Age of Empires
  and Beyond" (2001).
- Timothy Ford, "Overwatch Gameplay Architecture and Netcode", GDC 2017.
- GGPO source and documentation (github.com/pond3r/ggpo).
