# System Fingerprints: Detecting Game Systems in Code

Read this before Phase 2. Game systems leave recognizable signals regardless of engine. Start from
the engine's registration points (where global systems are declared), then grep for the system
signals below, then confirm by reading the code.

## 1. Engine registration points

These are where "global" systems live. Read them first; they are the skeleton of the architecture.

| Engine | Where to look | What it tells you |
|---|---|---|
| Godot 4.x | `project.godot` `[autoload]`, `run/main_scene`, `[input]`, `[physics]`, `[internationalization]` | Global singletons, entry scene, input actions, physics engine and tick, translations |
| Godot 4.x | `*.tscn` root nodes and `[connection]` sections; custom `Resource` scripts (`extends Resource`) and `.tres` files | Scene composition, signal wiring, data-driven parameters |
| Unity 6.x | `ProjectSettings/EditorBuildSettings.asset` (scene list), `Packages/manifest.json`, `*.asmdef` | Entry scenes, dependencies, module boundaries |
| Unity 6.x | `ScriptableObject` subclasses and `.asset` instances; `DontDestroyOnLoad`, static `Instance`, `[RuntimeInitializeOnLoadMethod]`; Addressables groups | Data layer, singletons, content loading |
| Unreal 5.x | `Config/DefaultEngine.ini` (`GameDefaultMap`, `GlobalDefaultGameMode`), `DefaultGame.ini`, `DefaultInput.ini` | Entry map, game mode, legacy or Enhanced Input |
| Unreal 5.x | `AGameModeBase`, `AGameStateBase`, `APlayerState`, `UGameInstance`, `U*Subsystem` subclasses; `UDataAsset`, `UDataTable` row structs; GAS (`UAbilitySystemComponent`, `UGameplayAbility`) | Authority and lifecycle layers, data layer, ability framework |
| Web (Vite) | `index.html`, `src/main.*`, `vite.config.*`, `package.json` scripts | Boot sequence, build and test commands |
| Three.js / R3F | `new WebGLRenderer` / `WebGPURenderer`, `<Canvas>`, `useFrame`, `setAnimationLoop`; zustand `create(`; koota `createWorld`, bitECS `createWorld` | Render loop, state stores, ECS worlds |
| Phaser 4 | `new Phaser.Game(config)`, `class X extends Phaser.Scene`, `this.scene.start(` | Scene graph and flow |
| PixiJS 8 | `new Application()` + `await app.init(`, `app.ticker.add(` | Boot and loop |
| Bevy | `App::new()`, `.add_plugins(`, `.add_systems(` | Plugin and system schedule |

Binary limits: Unreal `.uasset`/`.umap` (Blueprints, levels, data assets) cannot be read as text.
List them by path and name, infer purpose from names and C++ references, and mark every Blueprint
behavior UNVERIFIED.

## 2. System signals

| System | Signals in code | Common names |
|---|---|---|
| Movement | velocity/acceleration fields, `move_and_slide`, `CharacterController`, `UCharacterMovementComponent`, ground checks, coyote time, jump buffers | `Player*`, `*Controller`, `Movement*`, `Locomotion*` |
| Combat | damage functions, HP fields, hitboxes/hurtboxes, i-frames, knockback, damage types | `Combat*`, `Weapon*`, `Damage*`, `Health*`, `Hit*` |
| Inventory | item structs or resources, add/remove/stack, capacity, equipment slots | `Inventory*`, `Item*`, `Equipment*`, `Loot*` |
| Economy | currencies, prices, shops, rewards, sinks and faucets, IAP or store SDK calls | `Currency*`, `Shop*`, `Wallet*`, `Reward*`, `Store*` |
| Progression | XP curves, unlocks, skill trees, meta-progression, difficulty scaling | `Progress*`, `Unlock*`, `Level*`, `XP*`, `Meta*` |
| AI | state machines on enemies, behavior trees, navigation/pathfinding calls, perception | `AI*`, `Enemy*`, `Behavior*`, `Brain*`, `NPC*` |
| UI | menus, HUD updates, screen stacks, button callbacks; Godot `Control` scenes, Unity UI Toolkit/uGUI, UMG widgets, DOM overlays | `UI*`, `HUD*`, `Menu*`, `Screen*`, `Panel*` |
| Camera | follow, shake, bounds, zoom, cinematic paths; Cinemachine, Phantom Camera, `SpringArm` | `Camera*` |
| Audio | bus setup, music state machine, SFX triggers, Web Audio unlock | `Audio*`, `Sound*`, `Music*`, `SFX*` |
| Save/Load | serialization, file or `localStorage`/IndexedDB access, save versions and migrations | `Save*`, `Persist*`, `Profile*`, `GameData*` |
| Physics/Collision | collision layers/masks, raycasts, triggers, physics materials, fixed-step accumulators | `Physics*`, `Collision*`, `Trigger*` |
| Networking | RPCs, replication, sockets, Colyseus/Netcode/Steam networking, lobbies, prediction | `Net*`, `Network*`, `Lobby*`, `Room*`, `Sync*` |
| Localization | `tr()`, `LOCTEXT`, string tables, i18n libraries (`i18next`, `react-intl`, Lingui), `.po`/`.csv` translation files | `Locale*`, `I18n*`, `Translation*` |
| Analytics/Telemetry | event calls to GameAnalytics, Unity Analytics, PostHog, Firebase, Sentry; consent flags | `Analytics*`, `Telemetry*`, `Tracking*` |
| Input | action maps, rebinding UI, gamepad/touch handling | `Input*`, `Controls*`, `Bindings*` |
| Procedural generation | seeds, RNG wrappers, room/level generators, noise | `Gen*`, `Procedural*`, `Dungeon*`, `Seed*` |
| Debug and tools | overlays, cheat menus, editor tools (`@tool`, `[MenuItem]`, editor utility widgets), balance simulators | `Debug*`, `Cheat*`, `Dev*`, `Tool*` |

## 3. Mechanics hiding places

| Where | What it reveals |
|---|---|
| State enums and state classes | Each state is a player or enemy behavior |
| Input action handlers | Each action is a verb the player has |
| Collision/overlap callbacks | Each is an interaction rule |
| Timers, cooldowns, tweens | Pacing and feel decisions |
| Data files (`.tres`, ScriptableObject `.asset`, DataTable CSV/JSON, `*.json` configs) | Balance parameters and content volume |
| Tests | The closest thing to a written spec; test names often state intent |
| Commit messages and `progress.md` | Why a rule exists (STATED intent) |

## 4. Inconsistency patterns worth a headline

- Two systems owning the same data (two save systems, two input layers, two event buses).
- Units disagree (pixels vs meters, seconds vs frames, ms vs s across engine and library code).
- Tile-based logic next to continuous physics for the same entities.
- Tuning values duplicated in code and in data files with different numbers.
- Client-computed values that a server or leaderboard trusts.
- Content referenced in code that no longer exists in data (or the reverse).
- Systems named in docs or `CLAUDE.md` that no longer exist in code.
