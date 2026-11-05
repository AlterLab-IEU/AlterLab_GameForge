# Godot 4 Multiplayer

Facts dated 2026-11-05. Sources: Godot 4.7 docs ("High-level multiplayer", `MultiplayerSynchronizer`
class reference, "Exporting for the Web"), Godot release information in the AI-tooling research
(4.7 on 2026-06-18, 4.7.2 on 2026-08-18, 4.8 beta 2 on 2026-10-29), the netfox README, and the
GodotSteam repositories on GitHub (archived) and Codeberg. Code uses static typing, matching
`game-godot-specialist` conventions.

## 1. Stack at a glance

| Layer | Option | Notes |
|---|---|---|
| API | `SceneMultiplayer` (the default `MultiplayerAPI`) | `@rpc`, spawner, synchronizer, built-in auth hook |
| Transport, desktop/mobile | `ENetMultiplayerPeer` | UDP; Godot's ENet is modified for full IPv6. Forward the **UDP** port for direct hosting |
| Transport, web | `WebSocketMultiplayerPeer`, `WebRTCMultiplayerPeer` | The web platform has no raw UDP/TCP. Use `wss://` when the page is HTTPS |
| WebRTC on desktop | `webrtc-native` GDExtension | Built into web exports; desktop needs the extension |
| Steam | GodotSteam (Codeberg) | Lobbies, Steam networking, a MultiplayerPeer implementation |
| Prediction / rollback | netfox (MIT) | Time sync, interpolation, client prediction + server reconciliation, rollback |
| Backend | Nakama (Godot client), Photon Fusion for Godot (maturity UNVERIFIED) | Matchmaking, leaderboards, storage |

Version notes: Godot 4.7 is the current stable line; 4.8 is in beta and its .NET build requires
.NET 10. C# projects cannot be exported to the web in Godot 4, so a browser-playable multiplayer
game must be GDScript (or GDExtension with cross-origin isolation).

## 2. Connecting

```gdscript
# net.gd (autoload)
extends Node

const PORT: int = 24565
const MAX_CLIENTS: int = 7

func host() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	return OK

func join(address: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(address, PORT)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func() -> void: print("connected"))
	multiplayer.connection_failed.connect(func() -> void: print("failed"))
	multiplayer.server_disconnected.connect(_on_server_lost)
	return OK

func leave() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func _on_peer_connected(id: int) -> void: pass
func _on_peer_disconnected(id: int) -> void: pass
func _on_server_lost() -> void: leave()
```

Authentication: `SceneMultiplayer` exposes `auth_callback`; finish with
`multiplayer.complete_auth(peer_id)`. Use it to check the protocol version and a session token
before a peer can send gameplay RPCs.

## 3. RPCs

Default annotation: `@rpc("authority", "call_remote", "reliable", 0)`.

| Argument | Values |
|---|---|
| mode | `"authority"` (only the node's multiplayer authority may call it remotely) or `"any_peer"` |
| sync | `"call_remote"` or `"call_local"` (also runs on the caller) |
| transfer mode | `"unreliable"`, `"unreliable_ordered"`, `"reliable"` |
| channel | integer; always the last argument |

Inside an RPC, `multiplayer.get_remote_sender_id()` returns the caller. Node authority defaults to
the server (peer 1) and is changed per node with `set_multiplayer_authority(id)`.

Every `"any_peer"` RPC is an open door. Validate it:

```gdscript
# player.gd -- server-authoritative movement (server is peer 1; works for a listen-server host too)
extends CharacterBody2D

const MAX_SPEED: float = 220.0
const MAX_INPUTS_PER_SECOND: int = 90

var owner_peer: int = 1
var _input_dir: Vector2 = Vector2.ZERO
var _last_seq: int = -1
var _budget: float = MAX_INPUTS_PER_SECOND

func _physics_process(delta: float) -> void:
	var me: int = multiplayer.get_unique_id()
	if me == owner_peer:
		var dir: Vector2 = Input.get_vector("left", "right", "up", "down")
		var seq: int = Engine.get_physics_frames()
		if multiplayer.is_server():
			_apply_input(dir, seq)          # host plays locally
		else:
			_send_input.rpc_id(1, dir, seq)
	if multiplayer.is_server():
		_budget = minf(_budget + MAX_INPUTS_PER_SECOND * delta, MAX_INPUTS_PER_SECOND)
		velocity = _input_dir * MAX_SPEED
		move_and_slide()                     # position replicated by a MultiplayerSynchronizer

@rpc("any_peer", "call_remote", "unreliable_ordered")
func _send_input(dir: Vector2, seq: int) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != owner_peer:
		return                               # not your character
	if _budget < 1.0:
		return                               # rate limit
	_budget -= 1.0
	_apply_input(dir, seq)

func _apply_input(dir: Vector2, seq: int) -> void:
	if seq <= _last_seq:
		return                               # stale or replayed
	_last_seq = seq
	_input_dir = dir.limit_length(1.0)       # never trust magnitude
```

The client above does not predict; for responsive local movement, add netfox or the prediction
loop from `sync-models.md`, and keep `_apply_input` shared between client prediction and server.

## 4. Scene replication

- **`MultiplayerSpawner`**: replicates instantiation of listed scenes under its spawn path from the
  authority to peers. Spawn on the server only; clients receive the nodes.
- **`MultiplayerSynchronizer`**: sends properties from the multiplayer authority to peers.
  - `replication_config` (a `SceneReplicationConfig`) lists properties and their mode.
  - `REPLICATION_MODE_ALWAYS` uses `replication_interval`; `REPLICATION_MODE_ON_CHANGE` uses
    `delta_interval`. At `0.0` both sync every network process frame; set real intervals
    (e.g. 0.05 s) to control bandwidth.
  - Visibility: `public_visibility`, `set_visibility_for(peer, visible)`,
    `add_visibility_filter(callable)` and `update_visibility()`. This is your interest management:
    hide enemies a player should not know about. If a spawner created the node, visibility also
    controls whether the node exists on that peer.
  - Object-type properties (Resources) and peer-specific values (instance IDs, RIDs) cannot be
    synchronized.
- A common split (from Godot's scene replication guidance): a client-owned input node with its own
  synchronizer sends inputs to the server; the server-owned character body syncs state to everyone.
  Validate the synced input values on the server exactly as with RPCs.

## 5. Prediction and rollback with netfox

- netfox (MIT) adds time synchronization, interpolation, client-side prediction with server-side
  reconciliation and rollback (including a physics rollback example).
- `netfox.noray` is an optional add-on for connecting players (NAT punch-through and relay via the
  noray server).
- Its examples were written against Godot 4.1; confirm compatibility with your 4.7 project and pin
  the addon version.
- Rollback demands a deterministic, re-simulatable game state. Keep simulation in `_rollback_tick`
  style callbacks (per netfox docs) and presentation elsewhere.

## 6. Steam with GodotSteam

- GodotSteam moved to **Codeberg**; the GitHub repository was archived on 2026-10-20. Current
  release line 4.23.2 for Godot 4.x, paired with Steamworks SDK 1.65; MIT license.
- The repository includes a multiplayer peer implementation, so `@rpc` and the scene replication
  nodes can run over Steam networking and Steam Datagram Relay (hides IPs, no port forwarding).
  Check its docs for the current class name and setup.
- Typical flow: create a Steam lobby, invite friends through the overlay, the lobby owner hosts,
  members connect to the owner's Steam ID through the Steam peer.
- GodotSteam ships as a GDExtension or as a precompiled editor/template module; both are documented
  for the 4.x branch.

## 7. Dedicated and headless servers

- Run a server build with `--headless` (no window or rendering).
- Godot 4 export presets offer a dedicated-server export mode that strips visual resources; branch
  code on `OS.has_feature("dedicated_server")` to skip UI and audio.
- Containerize the headless binary for hosting; expose the UDP port (ENet) or the WebSocket port.

## 8. Web exports and multiplayer

- Transport: WebSocket (through `wss://` behind TLS) or WebRTC (needs a signaling server; WebRTC
  peers still need STUN/TURN for NAT).
- A Godot web client can talk to a Godot headless server over `WebSocketMultiplayerPeer`, or to a
  non-Godot server (Colyseus, Nakama) through that server's protocol.
- Discord Activities allow only WebSockets through their proxy; plan WebSocket transport if
  Discord is a target (see `web.md`).
- Threaded web exports need cross-origin isolation headers; networking does not require threads.

## 9. Testing in Godot

- Run multiple instances from the editor's Debug menu (recent 4.x versions can customize
  per-instance arguments, e.g. `--server` and `--client`).
- The high-level API has no built-in latency/loss simulator documented on the pages read
  (UNVERIFIED absence). Use OS tools: `tc netem` on Linux, Clumsy on Windows, Network Link
  Conditioner on macOS (see `testing-and-cost.md`).
- Add a debug overlay: RTT (ENet peers expose statistics), last processed input sequence,
  correction distance, synchronizer bandwidth.
- Headless bots: run extra `--headless` instances that join and replay recorded inputs.

## 10. Godot checklist

```markdown
- [ ] Transport fits targets: ENet (desktop/mobile), WebSocket/WebRTC (web), Steam peer (Steam)
- [ ] Auth callback checks protocol version and token before gameplay RPCs
- [ ] Every "any_peer" RPC checks sender, rate, ranges, sequence
- [ ] Spawning only on the server; synchronizer intervals set (not 0.0) for bulk state
- [ ] Visibility filters hide information players should not have
- [ ] Prediction/rollback library pinned and tested on the project's Godot version
- [ ] Headless server build runs in a container; UDP or WS port documented
- [ ] Multi-instance test under simulated latency in every milestone
```
