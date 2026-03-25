# Godot 4.x Engine Configuration

This section configures Claude Code for a Godot 4.x project. Append to your project's CLAUDE.md or use standalone.

## Engine Details

- **Engine**: Godot 4.6+
- **Primary Language**: GDScript (statically typed)
- **Engine Specialist**: `/game-godot-specialist`

When asking engine-specific questions, use `/game-godot-specialist`. For architecture questions that are engine-agnostic, use `/game-technical-director`.

## Project Structure

```
project.godot
scenes/               -- Scene files (.tscn)
  entities/           -- Player, enemies, NPCs
  levels/             -- Level/world scenes
  ui/                 -- UI scenes (menus, HUD, dialogs)
scripts/              -- GDScript files (.gd)
  autoloads/          -- Singleton autoload scripts
  components/         -- Reusable node components
  resources/          -- Custom Resource class definitions
  state_machines/     -- State machine implementations
  systems/            -- Core game systems (combat, inventory, etc.)
resources/            -- Resource files (.tres)
  data/               -- Gameplay data resources (stats, loot tables)
  themes/             -- UI themes
  materials/          -- Shader materials
assets/
  art/                -- Sprites, textures, models
  audio/              -- Music and SFX
  fonts/              -- Font files
addons/               -- Third-party addons
tests/                -- Test scripts
  run_tests.gd        -- Test runner entry point
export_presets.cfg    -- Export configuration (may contain secrets -- see .gitignore)
```

## GDScript Coding Standards

### Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | snake_case.gd | `player_controller.gd` |
| Classes | PascalCase | `class_name PlayerController` |
| Functions | snake_case | `func take_damage(amount: float) -> void:` |
| Variables | snake_case | `var current_health: float = 100.0` |
| Constants | UPPER_SNAKE_CASE | `const MAX_SPEED: float = 400.0` |
| Signals | snake_case (past tense) | `signal health_changed(new_value: float)` |
| Enums | PascalCase name, UPPER_SNAKE entries | `enum State { IDLE, RUNNING, JUMPING }` |
| Exported vars | snake_case with @export | `@export var move_speed: float = 200.0` |
| Node references | snake_case with @onready | `@onready var sprite: Sprite2D = $Sprite2D` |

### Static Typing Is Mandatory

Every variable, parameter, and return type must be annotated. No exceptions.

```gdscript
# Correct
var speed: float = 200.0
func calculate_damage(base: float, multiplier: float) -> float:
    return base * multiplier

# Wrong -- will be flagged in review
var speed = 200
func calculate_damage(base, multiplier):
    return base * multiplier
```

### Signal Conventions

- Signals are the primary communication mechanism between decoupled scenes.
- Signal names use past tense to describe what happened: `health_changed`, `enemy_defeated`, `level_completed`.
- Never use `get_node()` with paths that cross scene boundaries. Use signals, `@export` references, or an autoload EventBus.
- Connect signals in `_ready()`. Disconnect in `_exit_tree()` for dynamic connections.

```gdscript
# EventBus autoload pattern for cross-scene communication
# autoloads/event_bus.gd
extends Node

signal player_died
signal score_changed(new_score: int)
signal level_transition_requested(target_level: String)
```

### Scene Composition Over Inheritance

- Prefer child nodes and packed scenes as components over deep inheritance trees.
- Godot's scene tree IS a composition framework. A `Player` scene contains a `StateMachine` node, a `HitboxComponent` node, and a `HealthComponent` node -- not a class hierarchy.
- Reusable behaviors are separate scenes that get instanced as children.

### Resource-Driven Data

- Gameplay values live in custom Resource subclasses or `@export` variables, never hardcoded in scripts.
- Create custom Resources for data that designers tune: enemy stats, weapon profiles, loot tables, level configs.

```gdscript
# resources/weapon_data.gd
class_name WeaponData
extends Resource

@export var weapon_name: String = ""
@export var base_damage: float = 10.0
@export var attack_speed: float = 1.0
@export var range: float = 50.0
@export var knockback_force: float = 100.0
```

## Godot-Specific Code Review Criteria

When reviewing Godot code (`/game-code-review`), check for:

- [ ] All variables, parameters, and return types are statically typed
- [ ] No `get_node()` calls with paths crossing scene boundaries
- [ ] Signals used for inter-scene communication, not direct references
- [ ] `@export` or Resources used for tunable values, not hardcoded numbers
- [ ] `call_deferred()` used for scene tree modifications during physics/signal callbacks
- [ ] Collision layers and masks explicitly configured, not left at defaults
- [ ] No `_process()` logic that should be in `_physics_process()` (or vice versa)
- [ ] Object pooling for frequently spawned/despawned entities
- [ ] `@onready` used for node references, cached once, not queried every frame
- [ ] Autoloads used sparingly -- only for true global services (EventBus, AudioManager, SaveManager)

## Build and Test Commands

```bash
# Run the project headless (for CI or testing)
godot --path . --headless --script res://tests/run_tests.gd

# Export for target platform (configure export_presets.cfg first)
godot --path . --headless --export-release "Linux/X11" build/game.x86_64
godot --path . --headless --export-release "Windows Desktop" build/game.exe
godot --path . --headless --export-release "macOS" build/game.dmg

# Run the editor (useful for plugin development)
godot --path . --editor

# Validate GDScript (parse check without running)
godot --path . --headless --check-only --script res://scripts/my_script.gd
```

## Godot Anti-Patterns to Flag

These patterns must be caught during code review or refactored on sight:

1. **Long node paths**: `get_node("../../UI/HUD/HealthBar")` -- use signals or `@export` instead
2. **Untyped GDScript**: `var x = 5` instead of `var x: int = 5`
3. **Overusing `_process`**: Logic that runs every frame but only needs to react to events
4. **Monolithic scenes**: Single scene files with 50+ nodes instead of composed sub-scenes
5. **Hardcoded gameplay values**: `velocity.x = 300` instead of `velocity.x = move_speed`
6. **Polling instead of signals**: Checking a condition every frame when a signal would suffice
7. **Missing `call_deferred`**: Adding/removing nodes during physics step or signal callbacks
