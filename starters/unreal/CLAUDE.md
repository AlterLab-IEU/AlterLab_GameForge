# Unreal Engine 5.8 Project -- Claude Code Configuration

Append this to your project's `CLAUDE.md` (or use it standalone). Replace `MyGame` with your project
and module name, and `UE_ROOT` with your engine install (for example `C:/Program Files/Epic Games/UE_5.8`).

## Engine and GameForge

- **Engine:** Unreal Engine 5.8 (the last planned major UE5 release; UE6 early access is targeted for
  late 2027, so this project ships on 5.8). Check `EngineAssociation` in `MyGame.uproject`.
- **Languages:** C++ for systems, Blueprints for content and one-off reactions.
- **GameForge config:** `.gameforge/project.json` with `"engine": "unreal"`, `"engine_version": "5.8"`,
  `"commit_convention": "conventional"`.
- **Skills:** engine questions `/gameforge:game-unreal-specialist`; architecture and engine-wide budgets
  `/gameforge:game-technical-director`; netcode `/gameforge:game-multiplayer`; reviews
  `/gameforge:game-code-review`; CI `/gameforge:game-ci-pipeline`; agent build loop
  `/gameforge:game-vibe-code`; AI-generated assets `/gameforge:game-ai-assets`; not sure `/gameforge:game-help`.

## Rules for Claude in This Project

1. **Never write `.uasset` or `.umap` files as text.** They are binary (GameForge's hook blocks it).
   For Blueprint, level, material or Data Asset changes: write the C++ base class and give numbered
   editor steps, write a Python editor script, or use the Unreal MCP bridge if it is enabled.
2. **Never edit generated folders:** `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`, `.vs/`.
3. **Read before writing:** `.uproject`, `Source/MyGame/MyGame.Build.cs`, the existing classes in the
   area, and `production/session-state/active.md`.
4. **Current APIs only.** No `GENERATED_UCLASS_BODY()`, legacy `BindAxis`/`BindAction` input, PhysX,
   `UProperty`, Matinee or Cascade. If unsure an API exists in 5.8, say so and check the docs.
5. **Finish with the verification loop below** and paste the actual compile and test output.
6. **Update `production/session-state/active.md`** at the end of substantial work.

## Project Structure

```
MyGame.uproject
Source/
  MyGame.Target.cs, MyGameEditor.Target.cs
  MyGame/
    MyGame.Build.cs
    Public/ Private/              -- headers / implementation, mirrored folders
      Characters/ Components/ GameModes/ Abilities/ Input/ UI/ Systems/ Data/
    Private/Tests/                -- automation tests
  MyGameEditor/                   -- editor-only module (tools)
Content/                          -- binary assets (Git LFS): Blueprints, Maps, Materials, UI, VFX, Data
Config/                           -- DefaultEngine.ini, DefaultGame.ini, DefaultInput.ini, ...
Plugins/                          -- project plugins and Game Features
Scripts/                          -- Python editor scripts (editor-only)
design/ docs/ production/         -- GameForge design docs, architecture decisions, session state
```

## C++ Standards

| Element | Convention | Example |
|---|---|---|
| Actor classes | `A` prefix | `AHeroCharacter` |
| UObject/component classes | `U` prefix | `UInventoryComponent` |
| Structs / enums / interfaces | `F` / `E` / `I` | `FWeaponStats`, `EWeaponSlot`, `IInteractable` |
| Booleans | `b` prefix | `bIsAlive` |
| Gameplay Tags | dotted hierarchy | `Ability.Movement.Dash` |
| Delegates | `FOn...` | `FOnHealthChanged` |

- `GENERATED_BODY()` in every `UCLASS`/`USTRUCT`. Every `UObject*` member is
  `UPROPERTY() TObjectPtr<T>`. `IsValid()` before dereferencing objects you do not own.
- Tick off by default (`PrimaryActorTick.bCanEverTick = false`); events, timers and delegates first.
- Gameplay values in Data Assets / Data Tables, never literals. Soft references for on-demand assets.
- Forward-declare in headers; never include `Engine.h` in a header. Add Build.cs modules and `.uproject`
  plugins in the same change as the code that needs them.
- Input through Enhanced Input (Input Actions + Mapping Contexts). GAS only where the design needs it.
- Replicated state changes only behind `HasAuthority()`.

## Build and Test Commands

Put `UE_ROOT/Engine/Build/BatchFiles` and `UE_ROOT/Engine/Binaries/<Platform>` on your `PATH` so the
GameForge Unreal skill's pre-approved `RunUAT` and `UnrealEditor-Cmd` commands match; full-path calls
still work but ask for approval. Use absolute paths to the `.uproject`.

```bash
# Compile the editor target (close the editor first)
UE_ROOT/Engine/Build/BatchFiles/Build.bat MyGameEditor Win64 Development -Project="ABS/MyGame.uproject" -WaitMutex
UE_ROOT/Engine/Build/BatchFiles/Linux/Build.sh MyGameEditor Linux Development -Project="ABS/MyGame.uproject" -WaitMutex

# Headless automation tests; read the JSON report, not just the exit code
UnrealEditor-Cmd "ABS/MyGame.uproject" -ExecCmds="Automation RunTest MyGame;Quit" -unattended -nopause -nosplash -NullRHI -log -ReportExportPath="ABS/Saved/Automation/Reports"

# Recompile all Blueprints after changing C++ they inherit from (does not cover level Blueprints)
UnrealEditor-Cmd "ABS/MyGame.uproject" -run=CompileAllBlueprints -unattended -nopause

# Run an editor Python script headless (it must load any level it needs)
UnrealEditor-Cmd "ABS/MyGame.uproject" -run=pythonscript -script="ABS/Scripts/validate_naming.py"

# Package (copy the exact command the Project Launcher prints if a flag is in doubt)
RunUAT BuildCookRun -project="ABS/MyGame.uproject" -noP4 -platform=Win64 -clientconfig=Shipping -build -cook -stage -pak -archive -archivedirectory="ABS/Packaged"
```

On Linux and macOS use `RunUAT.sh`; on Windows `RunUAT.bat` and `UnrealEditor-Cmd.exe`.

## Agent Verification Loop

Run after every change to C++, Config or Build.cs, stopping at the first failure:

1. `git diff`: no `.uasset`/`.umap` or generated folder touched by hand.
2. Compile the editor target: zero errors, every new warning read (deprecations matter).
3. Run the relevant automation tests headless and check the report.
4. If C++ parents of Blueprints changed: run CompileAllBlueprints.
5. If assets changed through Python or MCP: run the validation script and review changed files.
6. A human plays the feature in PIE and checks feel, visuals and the log.
7. Before a milestone: package a Development build and smoke-test it on min-spec hardware.

## Unreal MCP (optional, UE 5.8, Experimental)

Enable the **Unreal MCP** and **All Toolsets** plugins, then run
`ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to write `.mcp.json`
(server at `http://127.0.0.1:8000/mcp`). Epic documents no authentication layer.

- Keep it on loopback; never forward, tunnel or publish the port. Use it only on a machine you control.
- Treat its toolsets as arbitrary code execution in your editor. Commit before each session and
  review changed files after. Stop it with `ModelContextProtocol.StopServer` when done.
- Editor-only workflow: not for CI and never enabled in shipped builds. One agent at a time; calls
  run serially on the game thread.

## Commit Convention

`<type>(<optional scope>): <summary>`, under 72 characters. With `"commit_convention": "conventional"`
GameForge's hook enforces it.

| Type | Use |
|---|---|
| `feat(scope):` | New gameplay feature or system |
| `fix(scope):` | Bug fix |
| `balance(scope):` | Tuning values (Data Assets, curves, GE magnitudes) |
| `art:` / `audio:` | Art or audio asset changes |
| `design:` | Design documents |
| `level:` | Maps, World Partition, encounters |
| `ui:` | UMG/CommonUI widgets and flows |
| `perf:` | Performance work (include before/after numbers in the body) |
| `refactor(scope):` | Restructuring without behavior change |
| `test:` | Automation tests |
| `chore:` / `docs:` | Build, config, tooling / documentation only |

```
feat(abilities): add dash ability with stamina cost
balance(combat): lower parry window from 12 to 9 frames
perf(rendering): disable Lumen reflections on foliage, GPU -2.1 ms
```

## .gitignore Essentials

```gitignore
# Unreal generated
Binaries/
Intermediate/
Saved/
DerivedDataCache/
Plugins/**/Binaries/
Plugins/**/Intermediate/

# Packaged builds (do not blanket-ignore Build/: it holds per-platform icons and resources)
Packaged/

# IDE and generated project files
.vs/
.idea/
*.sln
*.suo
*.VC.db
*.opensdf
*.sdf
*.xcworkspace

# GameForge session data
production/session-state/
production/session-logs/
```

## Git LFS (.gitattributes)

Run `git lfs install` once, then commit this before the first content commit:

```gitattributes
*.uasset filter=lfs diff=lfs merge=lfs -text lockable
*.umap   filter=lfs diff=lfs merge=lfs -text lockable
*.fbx    filter=lfs diff=lfs merge=lfs -text
*.png    filter=lfs diff=lfs merge=lfs -text
*.wav    filter=lfs diff=lfs merge=lfs -text
*.psd    filter=lfs diff=lfs merge=lfs -text lockable
```

Binary assets cannot be merged: `git lfs lock Content/Maps/Arena.umap` before editing a shared map and
unlock after pushing. World Partition's One File Per Actor reduces map conflicts but not the need to lock.

## Review Checklist (Unreal)

- [ ] Compiles clean; no new deprecation warnings
- [ ] `UPROPERTY()` + `TObjectPtr` on every UObject member; `IsValid()` on non-owned pointers
- [ ] No Blueprint Tick for systems; no per-frame `GetAllActorsOfClass` or synchronous loads
- [ ] Authority checks on replicated state; RPC choices justified
- [ ] Tunables in Data Assets/Tables; Gameplay Tags instead of string or bool soup
- [ ] Enhanced Input only; Build.cs and `.uproject` updated with new dependencies
- [ ] Automation test added or the reason stated; no binary or generated files edited as text
