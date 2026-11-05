# Unity 6 Multiplayer

Facts dated 2026-11-05. Sources: Unity package docs and changelogs for Netcode for GameObjects
(`com.unity.netcode.gameobjects` 3.2) and Unity Netcode (`com.unity.netcode` 7.2), the Unity
Multiplayer Services SDK manual, Photon Fusion 2 introduction, the Mirror and FishNet GitHub pages,
and Unity release information (6.3 LTS, 6.6) from the AI-tooling research. Items marked UNVERIFIED
were not confirmed in primary docs.

## 1. Where Unity's netcode stands (late 2026)

| Package | Status |
|---|---|
| Netcode for GameObjects (NGO) 2.x | 2.13.3 released 2026-09-14. The line to stay on for Unity 6.0-6.6 projects until 3.x support for your editor is confirmed |
| NGO 3.x | 3.0.0 (2026-09-14), 3.1.0 (2026-10-04), 3.2.0 (2026-11-03). **3.0 made Unity Netcode (`com.unity.netcode` 7.0.0) a hard dependency**, which also installs Entities, Burst and Collections. Editor assemblies renamed to `Unity.Netcode.GameObjects.*`; `NetworkTime`, `NetworkTimeSystem`, `NetworkTickSystem` moved to `Unity.Netcode.GameObjects.Timing`; APIs that were obsolete warnings are now compile errors |
| Unity Netcode (`com.unity.netcode`, formerly Netcode for Entities) | Became a core package at 6.5.0 (2026-04-21, parity with standalone 1.12.0). 7.2.0 (2026-10-29) requires editor 6000.7.0b6 or later. Server-authoritative with client prediction; supports GameObject and Entities workflows |
| Multiplayer Services SDK | Unifies Lobby, Matchmaker and Relay under one API with "Sessions"; replaces the separate SDKs (upgrade guide available) |
| Multiplay Game Server Hosting | Unity's hosting docs URL now redirects to Rocket Science Group's hosting page (observed 2026-11-05); Multiplay is listed as part of Rocket Science Group. Confirm contracts and SDK support before committing |

Practical reading: because NGO 3.x depends on Unity Netcode 7.x, and 7.2 requires a 6.7 beta
editor, **NGO 3.x on a 6.3 LTS project is likely unsupported** (minimum editor for NGO 3.0/3.1 not
stated in the changelog read; UNVERIFIED). Ship LTS projects on NGO 2.13.x; plan the 3.x upgrade
with the 6.7 LTS move.

Engine context: Unity 6.3 LTS is supported to 2027-12-04; 6.6 is the current Update release; 6.0
LTS left standard support on 2026-10-16. NGO supports Unity 6.0+ with Mono and IL2CPP; WebGL needs
NGO 1.2.0+ and Unity Transport 2.0.0+.

## 2. Choosing a Unity stack

| Need | Choose | Why |
|---|---|---|
| Co-op or casual, 2-16 players, GameObjects | NGO 2.13 (host or dedicated) + Multiplayer Services (Sessions/Relay) | First-party, documented, Relay solves NAT |
| Fast co-op build where cheating does not matter | NGO distributed authority, or Photon Fusion Shared Authority | Clients own their objects; minimal server logic |
| Competitive action with prediction and lag compensation | Photon Fusion 2 (Dedicated Server or Client Host mode), or Unity Netcode (ECS) | Prediction and lag compensation built in |
| Many entities, ECS project | Unity Netcode (`com.unity.netcode`) | Ghost snapshots, prediction, built on Entities |
| Fighting or RTS determinism | Photon Quantum (deterministic engine; version not reviewed) | Rollback/lockstep handled by the framework |
| Open source, no vendor | Mirror (MIT) or FishNet | Self-hosted, large communities |

## 3. NGO essentials

Concepts: `NetworkManager` (one per scene setup), `NetworkObject` (identity on prefabs),
`NetworkBehaviour` (networked scripts), `NetworkVariable<T>` (replicated state with read/write
permissions), RPCs, `NetworkTransform` and `NetworkAnimator`. Topologies: client-server (host or
dedicated server) and distributed authority (uses Unity's distributed authority service).

RPCs: the universal `[Rpc(SendTo.X)]` attribute replaced the older `[ServerRpc]`/`[ClientRpc]`
pair. Get the caller from `RpcParams`.

```csharp
using Unity.Netcode;
using UnityEngine;

// Server-authoritative movement: owner sends input, server moves, NetworkTransform
// (server authority) replicates the result.
public class PlayerMover : NetworkBehaviour
{
    [SerializeField] float maxSpeed = 6f;
    const float MaxInputsPerSecond = 90f;

    Vector2 serverInput;
    float budget = MaxInputsPerSecond;
    int lastSeq = -1;
    int nextSeq;

    void FixedUpdate()
    {
        if (IsOwner)
        {
            var input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            SubmitInputRpc(input, nextSeq++);   // swap for the Input System in production
        }

        if (!IsServer) return;
        budget = Mathf.Min(budget + MaxInputsPerSecond * Time.fixedDeltaTime, MaxInputsPerSecond);
        var move = new Vector3(serverInput.x, 0f, serverInput.y) * maxSpeed * Time.fixedDeltaTime;
        transform.position += move;              // add collision/nav checks here
    }

    [Rpc(SendTo.Server)]
    void SubmitInputRpc(Vector2 input, int seq, RpcParams rpcParams = default)
    {
        if (rpcParams.Receive.SenderClientId != OwnerClientId) return; // not your object
        if (seq <= lastSeq || budget < 1f) return;                     // replay or flood
        budget -= 1f;
        lastSeq = seq;
        serverInput = Vector2.ClampMagnitude(input, 1f);               // never trust magnitude
    }
}
```

Notes:
- This version has no client prediction, so the owner feels the round trip. For responsive
  movement, use an owner-authoritative transform only where cheating does not matter (co-op), or
  implement prediction (see `sync-models.md`), or use Fusion/Unity Netcode which provide it.
- `NetworkVariable` write permission defaults to the server; keep it that way for gameplay state.
- Spawning: only the server calls `NetworkObject.Spawn()`; register prefabs in the network prefab
  list.
- Scene management: let `NetworkManager.SceneManager` load networked scenes so clients follow.

## 4. Multiplayer Services: Sessions, Lobby, Relay, Matchmaker

- The Multiplayer Services SDK puts Lobby, Matchmaker and Relay behind one API. A **Session** is
  an abstraction over player grouping and connection management for both peer-to-peer (Relay)
  and dedicated-server games.
- Relay lets players connect "without dedicated game servers": the host allocates a relay, others
  join with a code. It also hides IP addresses.
- Existing projects on the standalone Lobby/Relay/Matchmaker SDKs have a documented upgrade path.
- Pricing is usage-based with free tiers; check the current pricing page at decision time.

## 5. Third-party libraries

**Mirror** (MIT; "maintained since 2014"; lists Unity 2019-2022 LTS and 6000.1)
- `NetworkBehaviour` with `[SyncVar]`, `[Command]`, `[ClientRpc]`, `[TargetRpc]`.
- Stable: KCP (UDP) default transport, Telepathy (TCP), WebSockets, interest management, snapshot
  interpolation, latency simulation, batching.
- Beta: lag compensation, encryption, cheat detection (Mirror Guard). Client-side prediction is
  listed as "researching".

**FishNet** ("feature-rich", used for MMO, shooter and turn-based games per its README). Its
documentation advertises client-side prediction and lag compensation (not re-verified here); check
the license file and the current major version before adopting.

**Photon Fusion 2**
- Three topologies with one API: Dedicated Server, Client Host, Shared Authority, plus single-player.
- Client-side prediction and lag compensation "out of the box"; compression; configurable
  area-of-interest for high player counts. Simulation code runs in `FixedUpdateNetwork` with
  `Runner.DeltaTime`, input via `GetInput`.
- "Free for development"; you pay beyond the free tier. Photon also publishes Fusion docs for
  Godot and Unreal (maturity UNVERIFIED).

**Steam and EOS from Unity**: community Steamworks wrappers (Steamworks.NET, Facepunch.Steamworks)
and NGO/Mirror/FishNet transports exist for Steam networking; EOS has a Unity plugin. Versions and
maintenance status were not reviewed for this skill (UNVERIFIED); check activity before adopting.

## 6. Dedicated servers

- Build with the **Dedicated Server** build target (Unity 6 build profiles) to strip rendering and
  audio; run headless with `-batchmode -nographics` in containers.
- Use `#if UNITY_SERVER` or runtime checks to skip UI and audio code paths.
- Keep a single shared simulation assembly used by client prediction and server.

## 7. Testing in Unity

- **Multiplayer Play Mode** (`com.unity.multiplayer.playmode`): run extra virtual players from one
  editor, no project clones.
- **Multiplayer Tools**: Network Simulator component (latency, jitter, loss presets per
  connection), runtime network stats monitor, network profiler views.
- Unity Netcode (ECS) and Unity Transport include their own network simulation settings for
  ECS projects.
- Automated tests: Unity Test Framework play mode tests that start a host and N clients in one
  process; run them in CI (`game-ci-pipeline`).

## 8. Unity checklist

```markdown
- [ ] Netcode package line matches the editor (NGO 2.13.x on 6.3 LTS; 3.x only with a supported editor)
- [ ] NetworkVariables server-write; RPC handlers check sender, sequence, rate, ranges
- [ ] Spawning server-only; prefab list complete; scene loads via the network scene manager
- [ ] Relay/Sessions configured; join codes expire; protocol version checked on connect
- [ ] Dedicated Server build target runs headless in a container (if dedicated)
- [ ] Network Simulator presets used in daily play; Multiplayer Play Mode for multi-client tests
- [ ] No service keys or admin endpoints in the client build
```
