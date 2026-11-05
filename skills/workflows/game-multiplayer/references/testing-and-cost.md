# Multiplayer Testing, Operations and Hosting Cost

Tooling facts: Unreal network emulation from the UE 5.8 docs; Colyseus debug panel from the 0.18
release post; Unity Multiplayer Play Mode and Multiplayer Tools from Unity's package docs. OS-level
tools (netem, Clumsy, Network Link Conditioner, toxiproxy) are long-standing open tools; confirm
current install steps on their project pages. All thresholds and prices are rules of thumb or
placeholders, never quotes.

## 1. Network condition profiles

Use the same names across engine settings, the test plan and bug reports.

| Profile | Round trip (RTT) | Jitter | Loss | Purpose |
|---|---|---|---|---|
| Good | 40 ms | 10 ms | 0% | Baseline, should feel local |
| Typical | 100 ms | 20 ms | 1% | Everyday home broadband |
| Bad | 200 ms | 50 ms | 3% | Default for regular development play |
| Awful | 400 ms | 100 ms | 8% | Must degrade gracefully, never corrupt state |
| Spike | +1,000 ms for 2 s | | | Buffer recovery, no desync |
| Drop | 10 s outage | | | Reconnect inside the grace window |
| Mobile | 160 ms | 120 ms | 2% + bursts | Phones on cellular, mostly for web/mobile games |

Engine simulators usually take one-way values per direction (Unreal's incoming/outgoing latency,
netem per interface): split the round trip in half.

## 2. Simulating bad networks

| Tool | Platform | Notes |
|---|---|---|
| Unreal network emulation | UE editor and builds | Editor Preferences > Play > Multiplayer Options > Enable Network Emulation (profiles Average, Bad, Custom); `NetEmulation.PktLag`, `NetEmulation.PktLoss` at runtime; `[PacketSimulationSettings]` in `DefaultEngine.ini` |
| Unity Network Simulator | Unity (Multiplayer Tools) | Per-connection latency, jitter and loss presets; combine with Multiplayer Play Mode |
| Colyseus debug | Browser | `import '@colyseus/sdk/debug'` adds telemetry and a latency simulator |
| `tc netem` | Linux | Kernel-level; works for any engine and transport |
| Clumsy | Windows | Lag, drop, throttle, out-of-order on chosen traffic |
| Network Link Conditioner | macOS / iOS | From Apple's additional developer tools; system-wide profiles |
| toxiproxy | Any (TCP proxy) | Latency, jitter, bandwidth, timeouts for TCP/WebSocket servers via an API; scriptable in CI |

`tc netem` on loopback for local multi-client tests (it delays packets in both directions, so
the round trip is twice the configured delay and loss roughly doubles):

```bash
sudo tc qdisc add dev lo root netem delay 100ms 25ms distribution normal loss 1.5%  # ~Bad
sudo tc qdisc change dev lo root netem delay 200ms 50ms loss 4%                     # ~Awful
sudo tc qdisc del dev lo root                                                       # restore
```

Browser DevTools network throttling targets HTTP loading; do not rely on it for WebSocket or
WebRTC gameplay traffic. Simulate on the server, with a proxy, or at the OS level.

## 3. Multi-client testing

| Engine | Local multi-client |
|---|---|
| Godot | Debug menu: run multiple instances; pass `--server`/`--client` style arguments; extra `--headless` instances as bots |
| Unity | Multiplayer Play Mode virtual players; play mode tests that start a host and N clients |
| Unreal | PIE with Number of Players and Net Mode; also test with Run Under One Process off |
| Web | Several browser windows or Playwright browser contexts (one per player); Node clients using the same SDK as bots |

Always test across two real networks (two homes, or a phone hotspot) before a public playtest:
NAT, relays and firewalls only show up there.

## 4. Bots and headless clients

Build bots early; they are cheap with an agent and they find most desync and load bugs.

| Bot type | Behavior | Finds |
|---|---|---|
| Idle | Joins and sits | Leaks, timeouts, keep-alive bugs |
| Random walker | Random valid inputs at the normal rate | Boundary and collision bugs, bandwidth |
| Replay | Replays recorded human input logs | Determinism, regressions |
| Scenario | Scripted join, fight, buy, leave, rejoin | Session-flow and economy bugs |
| Adversarial | Speed hacks, spam, invalid ids, oversized messages | Validation and rate-limit gaps |

Web example: a Node script that opens N `@colyseus/sdk` (or `partysocket`) clients and sends inputs
on a timer; run it against a staging server under toxiproxy.

## 5. Determinism checks (lockstep and rollback)

```text
every tick (or every K ticks):
    h = hash(ordered serialization of simulation state)
    log(tick, h)
compare logs across peers / platforms / browsers:
    first tick where hashes differ -> dump full state at tick-1 and tick on both sides -> diff fields
```

- Run the same input log on every platform you ship (Windows/macOS/Linux; Chrome/Firefox/Safari
  for web) in CI and compare hashes.
- Keep a replay runner: input log in, state hashes out. It turns "random desync" into a
  reproducible test.

## 6. Soak and load tests

**Soak** (stability over time): one or more full matches, at least as long as the longest real
session, ideally many times longer.

**Load** (capacity): ramp bot CCU until tick time or memory breaks; that number, minus a safety
margin, is players per process.

Watch:

| Metric | Healthy sign |
|---|---|
| Server tick duration p50 / p99 | p99 well under the tick budget (e.g. < 50% of 33 ms at 30 Hz) |
| Memory over time | Flat after warm-up; no upward trend |
| GC pauses (Node, C#) | Short and infrequent; none longer than one tick |
| Bandwidth per player | Matches the ADR estimate within ~20% |
| Reconnects, errors, rejected messages | Stable and explained |
| Desync reports (deterministic games) | Zero |

## 7. Operations basics

- **Version gate**: client and server exchange a protocol version on connect; mismatches get a
  clear "update required" message.
- **Draining deploys**: new matches go to new servers; old servers finish running matches.
- **Kill switches**: config flags to disable matchmaking, a game mode or purchases without a
  client patch.
- **Match IDs everywhere**: logs, error reports and the in-game report button include the match id.
- **Status page or pinned post**: players forgive outages they are told about.
- **End-of-life**: keep a direct-connect or LAN path and a self-hostable server build so the game
  outlives your hosting.

## 8. Hosting cost estimation

### Bandwidth per player

```
snapshot_bytes   = header + sum over relevant entities (bytes per entity after delta/quantization)
down_Bps         = (snapshot_bytes + packet_overhead) x snapshot_rate
up_Bps           = (input_bytes + packet_overhead) x input_rate
packet_overhead  ~ 28 bytes per UDP/IPv4 packet (20 IP + 8 UDP); TCP/IP plus WebSocket framing
                   is larger (40+ bytes before TLS)
```

Overhead matters at small payloads: at 20 packets per second, 28 bytes of headers is 560 B/s per
player before any game data.

### Servers

```
players_per_process  = measured in the load test (never guessed)
processes_at_peak    = ceil(peak_CCU / players_per_process)
machines_at_peak     = ceil(processes_at_peak / processes_per_machine)
server_hours_month   = sum over the month of machines running each hour (autoscaling) 
```

### Monthly cost

```
egress_GB_month = average_CCU x down_Bps x 2,592,000 / 1e9        (30-day month)
cost_month      = server_hours_month x <price per machine-hour>
                + egress_GB_month x <price per GB>
                + relay / realtime service fees (per CCU, MAU, message or room-time)
                + database, logs, monitoring
```

Peak CCU drives machine count; average CCU drives bandwidth. Plan launch week at several times the
expected peak (rule of thumb) and confirm that the provider's free tier will not cut you off.

### Worked example (illustrative numbers only)

A 4-player co-op game, dedicated servers, 20 Hz snapshots:
- Snapshot: 12-byte header + 8 relevant entities x 24 bytes = 204 bytes; + 28 overhead = 232 bytes.
- Down per player: 232 x 20 = 4,640 B/s (about 37 kbit/s). Up: (16 + 28) x 30 = 1,320 B/s.
- Average CCU 1,000: egress = 1,000 x 4,640 x 2,592,000 / 1e9 = about **12,000 GB per month**.
- Load test result (hypothetical): 40 players per 2-vCPU machine. Peak CCU 2,500 means 63 machines
  at peak; with autoscaling, perhaps a third of that on average.
- Price it with the provider's current rates on the day you decide. If those rates were, say,
  $0.05 per GB and $0.04 per machine-hour (hypothetical), egress would be about $600 and compute
  about $600 per month for 21 average machines. The point of the example is the shape, not the
  numbers: bandwidth and peak capacity dominate, and both are set by design choices (snapshot rate,
  entity count, interest management) you control.

Cost levers, biggest first: fewer bytes per entity (quantize, delta), fewer entities per client
(interest management), lower snapshot rate for distant entities, listen servers or relays instead
of dedicated servers for co-op, hibernating rooms for turn-based games.

### Topology cost comparison

| Topology | Your server bill | Hidden costs |
|---|---|---|
| Local / Remote Play Together | None | None |
| P2P or listen server over Steam/EOS relays | None for servers | NAT and host-quality support; cheating by hosts |
| Unity Relay, Photon, Playroom Kit | Usage-based fees (CCU/MAU/bandwidth) | Vendor lock-in; pricing changes |
| Hosted rooms (Colyseus Cloud, Durable Objects) | Room time, messages, egress | Tick loops keep rooms awake |
| Dedicated servers | Machines + egress, 24/7 | Ops, on-call, end-of-life plan |
