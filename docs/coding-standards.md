# AlterLab GameForge -- Coding Standards

These standards apply to all game code produced or reviewed by GameForge agents, regardless of engine or language. Engine-specific agents may add additional conventions, but these baseline rules are universal.

## Documentation

**Public API Documentation**: Every public method, function, signal, and exported property must have a doc comment explaining what it does, its parameters, return value, and any side effects. Internal helpers do not require doc comments but benefit from them.

**Inline Comments**: Explain the "why" not the "what." The code shows what happens. Comments explain why this approach was chosen, what constraint it satisfies, or what non-obvious behavior to watch for.

## Data-Driven Gameplay Values

**No hardcoded gameplay values.** Every tunable number -- health points, movement speed, damage multipliers, spawn rates, cooldown timers, drop rates, experience curves -- must live in external configuration files (JSON, resource files, data tables, or the engine's equivalent).

**Rationale**: Designers tune gameplay values constantly. If changing a damage number requires a code change, recompile, and redeploy, iteration speed collapses. External config allows runtime tuning, A/B testing, and designer autonomy.

**Exceptions**: Mathematical constants, physics constants, and rendering constants that never change may be hardcoded. If in doubt, externalize.

## Testability

**Dependency injection over singletons.** All public methods must be unit-testable. This means their dependencies are injected, not grabbed from global state. Singletons are acceptable for engine-level services (audio manager, input manager) but gameplay systems must accept their dependencies explicitly.

**Pure logic separation.** Separate game logic from engine integration. The rules of combat, inventory management, or quest progression should be testable without instantiating a scene, spawning nodes, or running a game loop.

**Test structure.** Tests live adjacent to source files in `__tests__/` directories. Test names describe the behavior being verified, not the method name: `"player takes reduced damage when shield is active"` not `"test_calculate_damage"`.

## Frame-Rate Independence

**Delta time for all time-dependent calculations.** Movement, animation, physics, timers, cooldowns, and any value that changes over time must use delta time (the time elapsed since the last frame). Never assume a fixed frame rate.

**Fixed timestep for physics.** Physics simulations use a fixed timestep with accumulator pattern to ensure deterministic behavior regardless of frame rate. Rendering interpolates between physics states.

**Timer implementation.** Never use frame-counting for timers. Use elapsed time tracking. A "2-second cooldown" means 2.0 seconds of accumulated delta time, not 120 frames.

## Performance: Hot Path Discipline

**No allocations in update loops.** The frame update path (every-frame functions like `_process`, `Update`, `Tick`) must not allocate memory. Pre-allocate buffers, pool objects, cache references at initialization. Garbage collection spikes cause visible frame hitches.

**Object pooling.** Frequently spawned and destroyed objects (bullets, particles, enemies, UI notifications) must use object pools. Create a pool at initialization, pull from it during gameplay, return to it on despawn.

**Cache component references.** Do not query for components, nodes, or game objects every frame. Cache references during initialization and null-check defensively.

## State Management

**State machines for entity behavior.** Player states (idle, running, jumping, attacking, stunned), enemy AI states, and UI states must use explicit state machines -- not nested if/else chains. Each state defines its own enter, exit, and update logic.

**Game state architecture.** Top-level game flow (main menu, loading, gameplay, pause, game over) uses a game state machine. States manage their own scene loading, input binding, and cleanup.

**State transitions must be explicit.** No implicit state changes. Every transition has a named trigger, validates preconditions, executes exit logic on the old state, and executes enter logic on the new state.

## Resource Cleanup

**Scene transition cleanup.** When transitioning between scenes or levels, explicitly free all scene-specific resources: despawn pooled objects, unsubscribe from events, release loaded assets, clear caches. Memory leaks across scene transitions are among the most common game bugs.

**Event/signal cleanup.** Every event subscription or signal connection made during a scene's lifetime must be disconnected when the scene exits. Dangling listeners cause null reference errors and logic bugs.

**Asset loading.** Large assets (textures, audio, meshes) that are level-specific should be loaded asynchronously during loading screens and released on level exit. Do not hold the entire game's assets in memory simultaneously.

## Design Document Standards

Every significant gameplay feature must have a design document before implementation begins. The document has 8 required sections:

1. **Overview** -- What is this feature? One paragraph. What player experience does it serve?
2. **Player Fantasy** -- What does the player feel and imagine while engaging with this feature? Written from the player's perspective.
3. **Detailed Rules** -- The complete mechanical specification. Every rule, every interaction, every state transition.
4. **Formulas** -- All mathematical formulas with variable definitions. Damage formula, XP curve, drop rate calculation, scaling functions.
5. **Edge Cases** -- What happens at the boundaries? Zero values, maximum values, interrupted actions, simultaneous events, disconnection during multiplayer.
6. **Dependencies** -- What other systems does this feature depend on? What depends on it? Cross-reference other design documents.
7. **Tuning Knobs** -- Every externalized value that designers can adjust, with its default value, valid range, and the effect of changing it.
8. **Acceptance Criteria** -- Concrete, testable statements that define when this feature is complete. Written as "Given X, when Y, then Z" wherever possible.

## Commit Standards

Every commit must reference its originating design document or task ID. Format: `feat(inventory): add stack splitting [GDD-042]` or `fix(combat): correct damage reduction formula [TASK-187]`.

Commits without a document or task reference are rejected by the `validate-commit` hook unless prefixed with `chore:` or `docs:`.

## AI-Assisted Code Review Guidelines

When AI tools (LLMs, code assistants, copilot-style tools) are used during development, the following review standards apply to all generated or suggested code:

- **Hallucinated API Detection**: AI models frequently generate calls to APIs, methods, or engine functions that do not exist. Every AI-suggested function call must be verified against the engine's official documentation for the target version. Pay particular attention to parameter order, return types, and deprecated methods.
- **Engine-Specific Pattern Validation**: AI-generated code must follow the target engine's idiomatic patterns. GDScript uses signals and `@export`, not C# events. Unity uses `MonoBehaviour` lifecycle methods, not arbitrary `update()` naming. Unreal uses `UFUNCTION`/`UPROPERTY` macros. Code that compiles but violates engine idioms must be refactored.
- **Attribution Requirements**: Any code block generated substantially by AI must include a comment noting AI assistance: `# AI-assisted: reviewed and modified by [developer]`. This is not about blame -- it flags code that may need extra scrutiny during debugging since the original author may not fully understand every line.
- **License Compliance**: AI models trained on open-source code may reproduce copyleft-licensed patterns. When AI suggests a non-trivial algorithm or implementation, verify it does not closely replicate GPL/LGPL/AGPL-licensed code unless the project's license is compatible.
- **Security Pattern Validation**: AI-generated networking code, file I/O, and user input handling must be reviewed for security vulnerabilities. AI models frequently omit input sanitization, generate insecure deserialization patterns, and suggest hardcoded credentials in example code. Never ship AI-generated security-sensitive code without explicit security review.

## Engine Version Requirements

All GameForge engine specialists target these minimum engine versions. Code suggestions, API references, and architecture patterns must be valid for these versions or newer.

| Engine | Minimum Version | Release Date | Key Features |
|---|---|---|---|
| **Godot** | 4.6 | 2025 | GDExtension stability, improved 3D renderer, typed dictionaries |
| **Unity** | 6.3 (6000.3) | 2025 | Entities 1.0 stable, Sentis ML runtime, GPU Resident Drawer |
| **Unreal Engine** | 5.7 | 2025 | Nanite foliage, MegaLights, Enhanced Input system maturity |

Engine specialists must validate that all suggested APIs, classes, and patterns exist in the target version. If a feature was introduced in a later version, note the minimum version requirement explicitly.

## Accessibility Implementation Standards

These standards go beyond design guidelines (see `@docs/game-design-theory.md`, Section 12) to specify concrete implementation requirements for accessible game code.

- **Screen Reader Metadata**: All interactive UI elements must expose accessibility metadata compatible with platform screen reader APIs. Godot: use `AccessibleNode` properties. Unity: implement `IAccessible` interfaces and UGUI accessibility labels. Unreal: use Slate accessibility API and `FAccessibleWidgetData`. Every button, label, and interactive element must have a programmatic name and role.
- **Subtitle Rendering Requirements**: Subtitles must support configurable font size (minimum range: 18px to 36px at 1080p equivalent), background opacity (0% to 100%), speaker identification with color coding (using colorblind-safe palette), and text rendering that maintains readability at all supported resolutions. Subtitles must never be baked into video assets -- they must be rendered dynamically from text data.
- **Input Abstraction**: All input handling must go through an abstraction layer that supports full remapping. No hardcoded key bindings in gameplay code. The input abstraction must support simultaneous gamepad, keyboard/mouse, and touch input. Switch access and single-button play modes must be achievable through the remapping system without code changes.
