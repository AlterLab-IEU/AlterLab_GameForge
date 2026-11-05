# GDScript Patterns for Godot 4.7

Reference for `game-godot-specialist`. Every sample is typed GDScript for Godot 4.5+ unless marked.
Indent with tabs (Godot's default). Version-gated features are labeled.

## 1. Typed GDScript baseline

Make the compiler enforce typing instead of relying on review:

- Project Settings > Debug > GDScript (enable *Advanced Settings*): set **Untyped Declaration**
  (`debug/gdscript/warnings/untyped_declaration`) to *Error*. Leave **Inferred Declaration** off so
  `:=` stays legal when the right-hand type is obvious.
- Raise **Unsafe Method Access** and **Unsafe Property Access** to *Warning* in projects with more
  than one programmer. They catch `Variant` calls the type checker cannot see.

```gdscript
class_name Player
extends CharacterBody2D
## Player controller. Tunables are exported; references are injected or scene-unique.

signal health_changed(current: int, maximum: int)
signal died

@export_group("Movement")
@export_range(0.0, 1000.0, 1.0, "suffix:px/s") var move_speed: float = 220.0
@export_range(0.0, 2000.0, 1.0, "suffix:px/s") var jump_velocity: float = 420.0
@export_group("Combat")
@export var stats: PlayerStats            # custom Resource, see section 5
@export var hurtbox: Hurtbox              # injected in the Inspector, not found by path

@onready var _sprite: AnimatedSprite2D = %Sprite   # scene-unique name (%), survives re-parenting

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta
	var axis := Input.get_axis(&"move_left", &"move_right")   # float, inferred
	velocity.x = axis * move_speed
	if not is_zero_approx(axis):
		_sprite.flip_h = axis < 0.0
	move_and_slide()
```

Rules of thumb:

| Write | Not | Why |
|---|---|---|
| `var hp: int = 10` or `var dir := Vector2.ZERO` | `var hp = 10` | Untyped is `Variant`; errors move from parse time to runtime |
| `func f(a: float) -> void:` | `func f(a):` | Return and parameter types are checked at every call site |
| `Array[Enemy]`, `Dictionary[StringName, int]` (4.4+) | `Array`, `Dictionary` | Typed containers are checked on insert and in the Inspector |
| `&"jump"` for action and state names | `"jump"` | `StringName` literals avoid a conversion per call |
| `%HealthBar` (scene-unique node) | `$"../../UI/HUD/HealthBar"` | Unique names survive re-parenting inside the scene |
| `@export var target: Node3D` | `get_node(target_path)` | Node-typed exports are set in the Inspector and type-checked |

Version-gated syntax worth knowing:

- **Typed dictionaries** (4.4+): `var counts: Dictionary[StringName, int] = {}`, exportable.
- **Variadic functions** (4.5+): `func sum(first: float, ...rest: Array) -> float:`.
- **Abstract classes and methods** (4.5+): `@abstract class_name Shape2DTool extends Node` and
  `@abstract func apply() -> void`. Subclasses must implement abstract methods.
- **4.8 beta:** scripts can no longer inherit their own inner classes, and strings used as comments
  are rejected. Fix these before moving a project to 4.8.

## 2. Signals, callables and `await`

"Call down, signal up": a parent calls methods on children it owns; children emit signals that
parents (or an event bus) connect to. Never make a child walk up the tree with `get_parent()` chains.

```gdscript
# Declaring and emitting (typed parameters are checked by the editor)
signal damaged(amount: int, source: Node)
damaged.emit(12, attacker)

# Connecting with callables -- no strings, no Godot 3 three-argument form
health.died.connect(_on_died)
button.pressed.connect(_on_slot_pressed.bind(slot_index))          # bind extra args
door.opened.connect(_on_door_opened, CONNECT_ONE_SHOT)             # fires once
area.body_entered.connect(_on_body_entered, CONNECT_DEFERRED)      # runs at idle time
timer.timeout.connect(func() -> void: _label.visible = false)      # lambda

# Listening to an autoload from a node that can leave the tree and come back
func _enter_tree() -> void:
	Events.score_changed.connect(_on_score_changed)

func _exit_tree() -> void:
	Events.score_changed.disconnect(_on_score_changed)

func _on_score_changed(score: int) -> void:
	_label.text = str(score)
```

A lambda can only be disconnected through the same `Callable`, so store it in a variable before
connecting if you will ever need to disconnect it.

When to disconnect by hand: connections to a freed object are cleaned up for you. Disconnect
explicitly when a node **leaves the tree but stays alive** (pooled enemies, cached menus) and still
listens to an autoload, or it will react while hidden.

`await` replaces Godot 3's `yield`:

```gdscript
func play_hit_feedback() -> void:
	_sprite.modulate = Color.RED
	await get_tree().create_timer(0.08).timeout
	if not is_instance_valid(self):     # the node may have been freed while waiting
		return
	_sprite.modulate = Color.WHITE

func fade_out(node: CanvasItem, seconds: float) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 0.0, seconds)
	await tween.finished

func open_chest() -> void:
	await fade_out(_lid, 0.25)          # a function that awaits is a coroutine; await it too
	_spawn_loot()
```

Pitfalls agents and newcomers hit:

- Awaiting a signal on a node that gets freed never resumes. Guard with `is_instance_valid()` and
  prefer timers or tweens owned by the awaiting node.
- `await` inside `_ready()` delays the rest of `_ready()` but not the parent's `_ready()`.
- A coroutine called without `await` returns immediately; its return value is lost.
- Tweens are bound to the node that created them (`create_tween()`); a freed node kills its tweens.

## 3. Scene composition kit

Each component is its own small scene (`.tscn` with a script root) that a character instances.

```gdscript
# components/health_component.gd
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export_range(1, 10000) var max_health: int = 100
@export var invulnerable: bool = false

var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if invulnerable or amount <= 0 or current_health <= 0:
		return
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
```

```gdscript
# components/hitbox.gd -- monitorable area on the "hitboxes" layer
class_name Hitbox
extends Area3D

@export var damage: int = 10
```

```gdscript
# components/hurtbox.gd -- monitoring area whose mask includes "hitboxes"
class_name Hurtbox
extends Area3D

signal hit_received(damage: int, source: Node)

@export var health: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null:
		return
	hit_received.emit(hitbox.damage, hitbox.owner)
	if health:
		health.take_damage(hitbox.damage)
```

Inside an `area_entered` or `body_entered` callback, change physics state with
`set_deferred("monitoring", false)` or `call_deferred(...)`; adding or freeing nodes mid-step errors.

### State machine (node-based)

```gdscript
# state_machine/state.gd -- 4.5+ (@abstract); drop the annotation on 4.4
@abstract class_name State extends Node

## Ask the machine to switch. The machine owns the transition, not the state.
signal finished(next_state: StringName, data: Dictionary)

func enter(_previous: StringName, _data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
```

```gdscript
# state_machine/state_machine.gd
class_name StateMachine
extends Node

signal state_changed(from: StringName, to: StringName)

@export var initial_state: State

var current: State
var _states: Dictionary[StringName, State] = {}

func _ready() -> void:
	for child: Node in get_children():
		var state := child as State
		if state:
			_states[state.name] = state
			state.finished.connect(_transition)
	await owner.ready                     # let the owner's @onready vars resolve first
	current = initial_state if initial_state else get_child(0) as State
	current.enter(&"")

func _unhandled_input(event: InputEvent) -> void:
	if current:
		current.handle_input(event)

func _process(delta: float) -> void:
	if current:
		current.update(delta)

func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)

func _transition(next_state: StringName, data: Dictionary) -> void:
	var next: State = _states.get(next_state)
	if next == null or next == current:
		push_warning("StateMachine: ignoring transition to '%s'" % next_state)
		return
	var previous: StringName = current.name
	current.exit()
	current = next
	current.enter(previous, data)
	state_changed.emit(previous, current.name)
```

```gdscript
# player/states/idle.gd
extends State

@export var player: Player

func enter(_previous: StringName, _data: Dictionary = {}) -> void:
	player.velocity.x = 0.0

func physics_update(_delta: float) -> void:
	if not is_zero_approx(Input.get_axis(&"move_left", &"move_right")):
		finished.emit(&"Run", {})
	elif Input.is_action_just_pressed(&"jump") and player.is_on_floor():
		finished.emit(&"Jump", {})
```

For a handful of states with no per-state data, a `match` on an `enum` inside the character script
is simpler and fine. Move to nodes when states need their own exports, timers or children.

## 4. Autoloads (event bus and services)

```gdscript
# autoloads/events.gd -- registered as Autoload "Events".
# No class_name: a class_name equal to the autoload name is a parse error ("hides an autoload singleton").
extends Node

signal player_died
signal score_changed(new_score: int)
signal level_completed(level_id: StringName)
signal item_collected(item: ItemData)
```

Usage: `Events.level_completed.emit(&"forest_02")` and `Events.player_died.connect(_on_player_died)`.
Keep the bus to signals only: no state, no logic. Global state goes in a dedicated service autoload
(`SaveService`, `AudioService`) with a narrow, typed API.

## 5. Resources for data-driven tuning

```gdscript
# data/enemy_stats.gd
class_name EnemyStats
extends Resource

@export var display_name: String = ""
@export_range(1, 5000) var max_health: int = 50
@export_range(0.0, 20.0, 0.1, "suffix:m/s") var move_speed: float = 3.5
@export_range(0, 500) var contact_damage: int = 8
@export var drops: Array[LootEntry] = []
```

```gdscript
# data/loot_entry.gd
class_name LootEntry
extends Resource

@export var item: ItemData
@export_range(0.0, 1.0, 0.01) var chance: float = 0.1
```

Create instances in the FileSystem dock (New Resource > EnemyStats) and save them as
`data/enemies/slime.tres`. Designers tune `.tres` files in the Inspector; code never hardcodes numbers.

```gdscript
# enemies/enemy.gd
class_name Enemy
extends CharacterBody3D

@export var stats: EnemyStats
@onready var _health: HealthComponent = %HealthComponent

func _ready() -> void:
	assert(stats != null, "%s has no EnemyStats assigned" % name)
	_health.max_health = stats.max_health
	_health.current_health = stats.max_health
```

Gotchas:

- **Shared instances.** Every scene that loads `slime.tres` gets the same object. Treat loaded
  Resources as read-only templates. To mutate per instance, `stats = stats.duplicate()` (shallow) or
  `duplicate_deep()` with a `DeepDuplicateMode` when nested sub-resources must also be copied, or
  tick *Local to Scene* (`resource_local_to_scene`) on the sub-resource.
- **Registries beat folder scans.** Exported builds remap resource files, so listing `res://` at
  runtime is fragile. Keep an `ItemRegistry` Resource with `@export var items: Array[ItemData]`.
- **Loading:** `preload()` for fixed dependencies (resolved at parse time), `load()` for small
  runtime picks, and `ResourceLoader.load_threaded_request(path)` + `load_threaded_get_status(path)`
  + `load_threaded_get(path)` for loading screens.
- **Save data is not a Resource.** A `.tres`/`.res` can embed or reference scripts, so loading one
  can run code. Save player progress as JSON or `ConfigFile` under `user://`, with a `version` field
  and validation on load; keep `FileAccess.get_var()`'s `allow_objects` at its default `false`.

## 6. Godot 3 to Godot 4 translation table

Models trained on years of Godot 3 tutorials emit these. Every left-hand item is wrong in 4.x.

| Godot 3 (wrong in 4.x) | Godot 4 |
|---|---|
| `yield(get_tree().create_timer(1), "timeout")` | `await get_tree().create_timer(1.0).timeout` |
| `export var speed = 10` / `export(int) var` | `@export var speed: int = 10` |
| `onready var x = $X` | `@onready var x: X = $X` |
| `tool` | `@tool` |
| `var hp setget set_hp, get_hp` | `var hp: int: set = _set_hp, get = _get_hp` (or inline `set(value):`) |
| `connect("pressed", self, "_on_pressed")` | `pressed.connect(_on_pressed)` |
| `emit_signal("died")` | `died.emit()` |
| `KinematicBody` / `KinematicBody2D` | `CharacterBody3D` / `CharacterBody2D` |
| `move_and_slide(velocity, Vector3.UP)` | set `velocity`, `up_direction`; call `move_and_slide()` |
| `Spatial` | `Node3D` |
| `Position2D` / `Position3D` | `Marker2D` / `Marker3D` |
| `Sprite` | `Sprite2D` |
| `TileMap` (single node with layers) | `TileMapLayer` nodes (4.3+) |
| `Tween` node + `interpolate_property()` | `create_tween().tween_property(...)` |
| `scene.instance()` | `scene.instantiate()` |
| `get_tree().change_scene("res://x.tscn")` | `get_tree().change_scene_to_file("res://x.tscn")` |
| `File` / `Directory` | `FileAccess` / `DirAccess` (static `open()`) |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` |
| `rand_range(a, b)` | `randf_range(a, b)` (floats) / `randi_range(a, b)` (ints) |
| `deg2rad`, `rad2deg`, `stepify`, `str2var` | `deg_to_rad`, `rad_to_deg`, `snapped`, `str_to_var` |
| `PoolStringArray`, `PoolVector2Array` | `PackedStringArray`, `PackedVector2Array` |
| `Reference` | `RefCounted` |
| `update()` on a CanvasItem | `queue_redraw()` |
| `BUTTON_LEFT`, `BUTTON_WHEEL_UP` | `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_WHEEL_UP` |
| `remote`, `master`, `puppet`, `rset()` | `@rpc("any_peer" / "authority", ...)`; sync state with `MultiplayerSynchronizer` |
| `VisibilityNotifier2D` | `VisibleOnScreenNotifier2D` |
| `ARVR*` classes | `XR*` classes |

Godot 4-era mistakes that are not Godot 3 holdovers:

- `class_name` on an autoload script with the same name as the autoload.
- `@onready` in a script that does not extend `Node` (Resources have no `_ready`).
- `get_node()` in `_init()`; children do not exist yet. Use `_ready()`.
- Calling `queue_free()` and then using the node in the same frame without `is_instance_valid()`.
- Modifying a shared `.tres` at runtime and wondering why every enemy changed.
- Scripts or scenes moved in the file manager without their `.uid` sidecar (4.4+).
