# Performance, Profiling and Physics (Godot 4.7)

Reference for `game-godot-specialist`. Budgets labeled "rule of thumb" are starting points, not
engine limits. Measure on the minimum-spec target, not on the development machine.

## 1. Measure before changing anything

| Tool | Where | Answers |
|---|---|---|
| Profiler | Debugger > Profiler | Which scripts and engine phases eat frame time |
| Visual Profiler | Debugger > Visual Profiler | CPU and GPU time per rendering pass |
| Monitors | Debugger > Monitors | FPS, process and physics time, node and object counts, draw calls, memory |
| ObjectDB snapshots (4.6+) | Debugger | Capture live objects at two moments and diff them to find leaks |
| Network Profiler | Debugger | RPC and synchronizer bandwidth |
| Remote scene tree | Scene dock > Remote while running | What actually exists at runtime (orphaned nodes, runaway spawns) |
| Tracing profilers (4.6+) | Tracy, Perfetto, Instruments | Timelines of GDScript and C# alongside engine internals; see the Profiling docs for setup. Perfetto is the default tracer for Android builds in 4.7 |
| Command line | `--print-fps`, `--gpu-profile` | Quick reads without opening the editor |

In-game counters for playtest builds:

```gdscript
# autoloads/perf_monitors.gd -- registered as Autoload "PerfMonitors"
extends Node

func _ready() -> void:
	Performance.add_custom_monitor(&"game/enemies_alive", _count_enemies)

func _count_enemies() -> int:
	return get_tree().get_node_count_in_group(&"enemies")
```

Custom monitors appear in Debugger > Monitors next to the built-in ones. Read built-ins from code
with `Performance.get_monitor(Performance.TIME_PROCESS)`.

Frame budgets (rule of thumb): 16.6 ms at 60 FPS, 8.3 ms at 120 FPS, 33.3 ms at 30 FPS. Plan to use
about three quarters of the budget on the minimum-spec device so spikes have headroom.

## 2. CPU patterns that matter

- **Do not process what is not moving.** `set_process(false)` / `set_physics_process(false)` when
  idle; `process_mode = Node.PROCESS_MODE_DISABLED` for pooled or parked nodes;
  `VisibleOnScreenEnabler2D/3D` to switch off-screen enemies off.
- **Events, not polling.** Timers and signals instead of checking conditions every frame.
- **No allocations in hot loops.** Reuse arrays, cache node references in `@onready`, use
  `StringName` literals (`&"run"`) for frequently compared names, avoid building strings per frame.
- **Thousands of similar things are data, not nodes.** Render them with `MultiMeshInstance2D/3D`,
  keep their state in packed arrays, and query physics with shape casts instead of one body each.
- **Heavy pure work goes to threads.** `WorkerThreadPool.add_task(callable)` for procedural
  generation or pathfinding batches. Never touch the scene tree from a worker; hand results back
  with `call_deferred()`.
- **Language escalation is the last step.** Move a profiled hot path to C# or GDExtension (C++,
  Rust, etc.) only when the profiler shows the script itself is the cost, not the algorithm.

### Object pool

```gdscript
# pooling/bullet_pool.gd
class_name BulletPool
extends Node
## Recycles bullets instead of instantiating and freeing them on every shot.

@export var bullet_scene: PackedScene
@export_range(1, 4096) var prewarm: int = 256

var _available: Array[Bullet] = []

func _ready() -> void:
	for _i: int in prewarm:
		_available.append(_create())

func acquire(at: Vector2, direction: Vector2) -> Bullet:
	var bullet: Bullet = _available.pop_back() if not _available.is_empty() else _create()
	bullet.activate(at, direction)
	return bullet

func release(bullet: Bullet) -> void:
	bullet.deactivate()
	_available.append(bullet)

func _create() -> Bullet:
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.pool = self
	add_child(bullet)
	bullet.deactivate()
	return bullet
```

```gdscript
# pooling/bullet.gd
class_name Bullet
extends Area2D

@export var speed: float = 900.0
@export var lifetime: float = 1.5

var pool: BulletPool
var _direction: Vector2 = Vector2.RIGHT
var _age: float = 0.0

func activate(at: Vector2, direction: Vector2) -> void:
	global_position = at
	_direction = direction.normalized()
	rotation = _direction.angle()
	_age = 0.0
	reset_physics_interpolation()          # teleported: do not interpolate from the old spot
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func deactivate() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta
	_age += delta
	if _age >= lifetime:
		pool.release(self)
```

Pool when the profiler shows instantiation or freeing spikes, or when you spawn many short-lived
objects per second. A pooled object must fully reset its state in `activate()`; stale state from a
previous life is the classic pooling bug.

## 3. Physics engine choice

- **3D:** Jolt has been the default physics engine for **new** 3D projects since 4.6 (added as an
  option in 4.4). Existing projects keep their setting: Project Settings > Physics > 3D > Physics
  Engine. Switching an existing project is a deliberate migration, not a free upgrade.
- **2D:** Jolt is a 3D engine. 2D games use Godot's built-in 2D physics.

Jolt differences that surface when migrating from Godot Physics (from the "Using Jolt Physics" docs):

| Area | Difference |
|---|---|
| Joints | Several soft-limit properties on 3D joints are unsupported (warning if changed). Single-body joints attach the body to `node_b`; a project setting restores the old behavior. |
| Margins | Shapes shrink before the margin shell is applied, so their size does not grow. |
| Penetration | Position-only correction: no overshoot, but deep penetration resolves more slowly. |
| Ray `face_index` | Returns `-1` unless enabled in project settings (costs about 25% more memory for `ConcavePolygonShape3D`). |
| Kinematic contacts | Kinematic `RigidBody3D` does not report contacts with static or kinematic bodies by default. |
| Contact impulses | Estimated; accurate only when the two bodies touch nothing else. |
| `WorldBoundaryShape3D` | Much smaller effective plane; adjustable in project settings. |
| Threading | "Run On Separate Thread" support is experimental. |

## 4. Bodies, layers and controllers

| Node | Use for | Do not |
|---|---|---|
| `CharacterBody2D/3D` | Players, NPCs: code sets `velocity`, then `move_and_slide()` | Move it by setting `position` every frame and expect collisions |
| `RigidBody2D/3D` | Crates, debris, physics props | Set `position` directly; use impulses, forces or `_integrate_forces(state)` |
| `AnimatableBody2D/3D` | Moving platforms and doors driven by animation or code | Use `StaticBody` and move it (other bodies will not be carried) |
| `StaticBody2D/3D` | Level geometry | Animate it |
| `Area2D/3D` | Triggers, hit and hurt boxes, pickups | Toggle `monitoring` directly inside a physics callback (use `set_deferred`) |

Name every layer in Project Settings > Layer Names > 2D/3D Physics before the first enemy exists:

| Layer | Name | Typical mask of things on it |
|---|---|---|
| 1 | world | (nothing; static) |
| 2 | player | world, enemies, pickups |
| 3 | enemies | world, player |
| 4 | player_hitboxes | (monitorable only) |
| 5 | enemy_hurtboxes | player_hitboxes |
| 6 | pickups | (monitorable only) |

Set them in code with `set_collision_layer_value(2, true)` and `set_collision_mask_value(1, true)`
so the intent is readable. A layer table belongs in `docs/` so agents and humans use the same numbers.

`CharacterBody` settings that fix most "slides off slopes" and "sticks to walls" reports:
`up_direction`, `floor_max_angle`, `floor_snap_length`, `floor_stop_on_slope`, and
`motion_mode` (*Grounded* for platformers, *Floating* for top-down and space games).

## 5. Physics interpolation

Turn on Project Settings > Physics > Common > Physics Interpolation when the display refresh rate
differs from the physics tick rate (most players). Then:

- Move objects and run game logic in `_physics_process`, including tweens, animations and
  navigation that move nodes.
- After teleporting or spawning, set the transform and then call `reset_physics_interpolation()`.
- Convert an existing project with the tick rate temporarily set very low (for example 10) so
  anything moved outside the physics tick visibly stutters.
- Some cases, such as a smoothed `Camera3D`, may need custom interpolation.

## 6. Physics queries

```gdscript
# Inside a CharacterBody3D or any CollisionObject3D. Query only from _physics_process.
const WORLD_MASK: int = 1 << 0

func has_line_of_sight(to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position, to, WORLD_MASK)
	query.exclude = [get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty()
```

- `intersect_ray` returns a `Dictionary` (`position`, `normal`, `collider`, ...) and allocates per
  call. Fine for a few queries per frame; batch or cache when you run hundreds.
- **4.8 beta:** `PhysicsDirectSpaceState2D/3D` gain typed, non-allocating results, such as
  `intersect_ray_into()` with a reusable `PhysicsIntersectRayResult3D` and `cast_motion_into()` with
  `PhysicsCastMotionResult3D`. Check the 4.8 class reference before using them, and do not use them
  in a 4.7 project.
- Do not assume Godot physics is deterministic across machines. Rollback or lockstep netcode needs
  its own verified deterministic simulation.

## 7. Navigation

```gdscript
# enemies/chaser.gd
extends CharacterBody3D

@export var speed: float = 4.0
@export var target: Node3D
@onready var _agent: NavigationAgent3D = %NavigationAgent3D

func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame        # the navigation map syncs after the first physics frame
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if target:
		_agent.target_position = target.global_position
	if _agent.is_navigation_finished():
		velocity = Vector3.ZERO
	else:
		velocity = global_position.direction_to(_agent.get_next_path_position()) * speed
	move_and_slide()
```

- Updating `target_position` every tick is fine for a handful of agents; for crowds, update on a
  timer (for example every 0.2 s) and stagger agents.
- Avoidance (`avoidance_enabled`) costs CPU per agent; enable it only where crowds actually form.
- Keep AI decisions in a state machine (see the GDScript patterns reference); `AnimationTree` is for
  animation blending, not AI state.
