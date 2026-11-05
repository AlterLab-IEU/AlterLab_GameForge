# Godot 4.x Review Checklist

Version anchors (November 2026): **Godot 4.7.2 stable** (4.7 released 2026-06-18), **4.8 in beta**
(its .NET build needs .NET 10). The Godot 4.5 C# docs require .NET 8 or later (.NET 9 for Android
export), and C# projects cannot export to the web in 4.x. Judge code against the version in
`project.godot` (`config/features`) or `.gameforge/project.json`.

## 1. Godot 3 patterns agents still write (A1)

Most hits are hard errors in 4.x; a few still parse but misbehave.

| Godot 3 (stop) | Godot 4 (use) | Grep |
|---|---|---|
| `yield(obj, "signal")` | `await obj.signal` | `yield\(` |
| `export var`, `onready var`, `tool` | `@export var`, `@onready var`, `@tool` | `^(export\|onready\|tool)\b` |
| `setget` | `var x: set = _set_x, get = _get_x` or inline `set(value):` | `setget` |
| `KinematicBody2D/3D` | `CharacterBody2D/3D` | `KinematicBody` |
| `move_and_slide(velocity, Vector2.UP)` | set `velocity` (and `up_direction`), then `move_and_slide()` | `move_and_slide\([^)]` |
| `Spatial`, `Position2D`, `Sprite`, `Particles` | `Node3D`, `Marker2D`, `Sprite2D`, `GPUParticles2D/3D` | `\b(Spatial\|Position2D)\b` |
| `scene.instance()` | `scene.instantiate()` | `\.instance\(\)` |
| `change_scene("res://...")` / `change_scene_to(packed)` | `change_scene_to_file()` / `change_scene_to_packed()` | `change_scene\(` |
| `connect("pressed", self, "_on_pressed")` | `pressed.connect(_on_pressed)` | `connect\("[a-z_]+", *self` |
| `emit_signal("died")` | `died.emit()` (old form works; prefer typed) | `emit_signal\(` |
| `File`, `Directory` | `FileAccess`, `DirAccess` | `File.new\(\)\|Directory.new\(\)` |
| `rand_range`, `stepify`, `deg2rad`, `rad2deg` | `randf_range`, `snapped`, `deg_to_rad`, `rad_to_deg` | `rand_range\|stepify\|deg2rad\|rad2deg` |
| `PoolStringArray`, `PoolVector2Array` | `PackedStringArray`, `PackedVector2Array` | `Pool[A-Z]\w*Array` |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | `OS.get_ticks` |
| `.empty()` | `.is_empty()` | `\.empty\(\)` |
| `update()` on CanvasItem | `queue_redraw()` | `^\s*update\(\)` |
| `rect_position`, `rect_size` | `position`, `size` | `rect_(position\|size)` |
| `BUTTON_LEFT`, `event.scancode` | `MOUSE_BUTTON_LEFT`, `event.keycode` / `physical_keycode` | `BUTTON_LEFT\|scancode` |
| `VisualServer`, `Physics2DServer` | `RenderingServer`, `PhysicsServer2D` | `VisualServer\|Physics2DServer` |
| `Engine.editor_hint` | `Engine.is_editor_hint()` | `editor_hint` |
| `Tween.new()` + `interpolate_property` | `create_tween().tween_property(...)` | `interpolate_property` |
| `funcref(obj, "m")` | `Callable(obj, "m")` or `obj.m` | `funcref` |
| GDNative | GDExtension | `gdnative` |

## 2. Agent mistakes that compile (A2 / G-checks)

- **Double-applied delta in `CharacterBody`.** `velocity = dir * speed * delta` followed by
  `move_and_slide()`; `move_and_slide` already integrates over the physics step. Velocity is in
  units per second. Gravity accumulation (`velocity.y += gravity * delta`) is correct.
- **Movement in `_process`.** Body movement and forces belong in `_physics_process`.
- **Invented Input helpers.** `Input.get_action_vector()` does not exist; the real API is
  `Input.get_vector(neg_x, pos_x, neg_y, pos_y)` and `Input.get_axis(neg, pos)`.
- **`get_node()` with long paths per frame.** Cache with `@onready var hp_bar := %HPBar` (scene
  unique names) or exported `NodePath`/node references.
- **Scene tree changes inside physics callbacks.** Adding/removing nodes or changing collision
  shapes in `body_entered` without `call_deferred` / `set_deferred`.
- **Freed-object access after `await`.** The awaiting node may be freed; check
  `is_instance_valid(self)` or bind lifetimes.
- **Thread misuse.** Scene tree nodes are not thread-safe; work from `WorkerThreadPool` must hand
  results back with `call_deferred`.
- **Autoload sprawl.** New autoloads that duplicate an existing one (A4). Check `[autoload]` in
  `project.godot`.
- **Untyped GDScript in hot paths.** Static typing (`var speed: float`, `:=`) is both a correctness
  check and a performance win in 4.x; flag untyped hot-path code as MINOR.

## 3. Project and file hygiene (A8)

| Item | Rule |
|---|---|
| `*.uid` files (Godot 4.4+) | Commit them next to their scripts/resources; move them together on rename; never hand-edit |
| `.godot/` | Never committed (import cache and editor state) |
| `export_presets.cfg` | Committed; contains no passwords. Android keystore credentials come from `GODOT_ANDROID_KEYSTORE_RELEASE_PATH/USER/PASSWORD` env vars in CI |
| `project.godot` | Review every changed key: physics engine, tick rate, renderer, stretch mode, input map. Godot 4.6 made Jolt the default physics engine for **new** 3D projects; switching an existing project changes collision behavior and is a MAJOR finding if unannounced |
| `addons/` | New plugins need a known source, a license, and a version; the 4.7 Asset Store replaced the Asset Library |
| Translations | Player-facing strings through `tr()` / `tr_n()` or auto-translated Control text; see `game-localization-manager` |

## 4. C# in Godot

- Signals: `[Signal] public delegate void DiedEventHandler();` and `EmitSignal(SignalName.Died)`;
  flag string-named signals where generated names exist.
- `GD.Print` in `_Process` / `_PhysicsProcess` per frame (G2).
- Using `System.Threading` timers or `Task.Run` to touch nodes (G9).
- Web target with C#: not exportable in 4.x; flag if `export_presets.cfg` has a Web preset in a C#
  project.
- 4.8 beta .NET builds need the .NET 10 SDK; CI pinned to .NET 8 will fail.

## 5. MCP-edited scenes

Godot's text formats (`.tscn`, `.tres`, `.gd`) diff well, which is why agents and community MCP
servers (for example Coding-Solo/godot-mcp; there is no official Godot MCP server) edit them
directly. In scene diffs check:
- `ext_resource` paths and `uid=` values point at files that exist;
- no duplicated node names under one parent;
- signal `[connection]` entries reference methods that exist in the attached script;
- `unique_name_in_owner` flags were not dropped;
- large unexplained `load_steps` jumps (resources pulled in by accident).

## 6. Quick verification commands for the report

```
godot --headless --check-only --script res://path/to/script.gd
godot --headless --import            # re-import, then quit; surfaces missing resources
godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit   # if GUT is installed
```
