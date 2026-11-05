# [YOUR GAME NAME] -- Godot Project Guide for Coding Agents

## Project

- **Game:** [YOUR GAME NAME] -- [GENRE] -- [ONE SENTENCE: what the player does and why it is fun]
- **Engine:** Godot **4.7.2** stable. Do not upgrade, or open the project in another version,
  without asking; 4.8 is in beta.
- **Language:** typed GDScript [or: C# with the .NET build of Godot and the .NET 8+ SDK pinned in
  `global.json`; Godot 4.8's .NET build needs .NET 10+]
- **Renderer:** [Forward+ | Mobile | Compatibility] (web builds require Compatibility)
- **Targets:** [Windows, Linux, macOS, Steam Deck, Android, iOS, Web]
- **GameForge config:** `.gameforge/project.json` (engine, phase, pillars, commit convention)
- **Current focus and decisions:** `production/session-state/active.md`. Read it at the start of a
  session; update it at the end of long work.

## Skills

This project uses the AlterLab GameForge plugin. Unsure which skill fits? Run `/gameforge:game-help`.

| Task | Skill |
|---|---|
| Godot APIs, scenes, physics, export, tests | `/gameforge:game-godot-specialist` |
| Build a feature with an agent, verified step by step | `/gameforge:game-vibe-code` |
| Mechanics, systems, tuning | `/gameforge:game-designer`, `/gameforge:game-balance-check` |
| Architecture and performance decisions | `/gameforge:game-technical-director` |
| Review a diff (especially agent-written) | `/gameforge:game-code-review` |
| Test plan and release gates | `/gameforge:game-qa-lead` |
| Online play | `/gameforge:game-multiplayer` |
| CI builds and exports | `/gameforge:game-ci-pipeline` |
| AI-generated art, audio or voice (logged) | `/gameforge:game-ai-assets` |
| Playtests | `/gameforge:game-playtest` |
| Launch: Steam, mobile, consoles / itch.io and web portals | `/gameforge:game-launch` / `/gameforge:game-web-publish` |

## Commands

The editor binary is on `PATH` as `godot`. Run everything from the folder with `project.godot`.

```bash
godot --version                                              # must report 4.7.2
godot --headless --path . --import                           # after pulls, new assets, renamed class_name
godot --headless --path . --check-only --script res://player/player.gd     # parse-check one script
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
godot --headless --path . --quit-after 600 --log-file /tmp/godot-smoke.log  # smoke run, then search the log
godot --headless --path . --export-release "[PRESET NAME]" build/[platform]/[file]
godot --path .                                               # play it (human check)
```

[gdUnit4 instead of GUT: `GODOT_BIN="$(command -v godot)" addons/gdUnit4/runtest.sh -a res://tests`. C#: run `dotnet build` first.]

Do not pass `-d` in unattended runs: the local debugger waits at a `debug>` prompt on any script
error. Runtime script errors do not reliably change the exit code, so search the output or log
for `SCRIPT ERROR`, `Parse Error` and `ERROR:`.

## Agent Verification Loop

A task is done only when all of these hold:

1. `godot --version` matches the engine version above.
2. Import ran clean if assets, `class_name` declarations or files on disk changed.
3. `--check-only` passes for every changed `.gd` file.
4. The test suite passes, and new logic has a test.
5. The smoke run log has no `SCRIPT ERROR` or `ERROR:` lines.
6. The Godot 3 API scan finds nothing (search `.gd` files for
   `yield\(|^\s*(export|onready) var|KinematicBody|\.instance\(\)|setget`).
7. The report to the human lists: files changed, commands run with results, what was not verified,
   and exactly what to playtest (how to reach it, what "right" looks like). Headless runs draw
   nothing: feel, visuals and audio always need a human run.

## Project Layout

```
project.godot
export_presets.cfg       -- committed; secrets live in .godot/export_credentials.cfg (never committed)
addons/                  -- third-party plugins (GUT or gdUnit4, others); review before enabling
autoloads/               -- global services only: events.gd, save_service.gd, ...
components/              -- reusable scenes: health, hitbox, hurtbox, state_machine
characters/              -- player/, enemies/ (scene + script + states/ side by side)
levels/
ui/                      -- menus, HUD, themes/
data/                    -- Resource classes (*.gd) and tuning data (*.tres)
assets/                  -- art, audio, fonts (binaries in Git LFS)
tools/                   -- headless tool scripts (extends SceneTree)
tests/                   -- unit/, data/, scenes/
design/  docs/  production/   -- GameForge: design docs, architecture and ADRs, plans and session state
```

## GDScript Rules

- **Typed everything.** Untyped declarations are errors (Project Settings > Debug > GDScript >
  Untyped Declaration). `:=` is fine when the type is obvious.
- **Godot 4 only.** `await`, `@export`, `@onready`, `CharacterBody2D/3D`, `instantiate()`,
  `signal.connect(callable)`, `signal.emit()`. Never `yield`, `export var`, `KinematicBody`,
  `setget` or string-based `connect(..., self, ...)`.
- **Tabs for indentation.** Mixing tabs and spaces in a file is a parse error.
- **Call down, signal up.** No `get_node()` paths that leave the current scene. Use `@export` node
  references, `%UniqueName` and signals; cross-system events go through the `Events` autoload.
- **Composition first.** Behaviors are child scenes; scene inheritance at most two levels deep.
- **Numbers live in data.** Gameplay values go in `data/*.tres` Resources or `@export` variables.
  Loaded Resources are shared: `duplicate()` before changing one per instance.
- **Autoloads need a reason.** Ask before adding one. No `class_name` on an autoload script with
  the same name as the autoload.
- **Physics:** movement in `_physics_process`; named collision layers (table in `docs/`); use
  `call_deferred()` / `set_deferred()` for tree or physics changes inside physics callbacks.
- **Saves** go to `user://` as JSON or `ConfigFile` with a version field, never as `.tres`.
- **Doc comments** (`##`) on exported variables and public functions.

| Element | Convention | Example |
|---|---|---|
| Files, folders | snake_case | `health_component.gd`, `forest_01.tscn` |
| Classes | PascalCase `class_name` | `class_name HealthComponent` |
| Functions, variables | snake_case; leading `_` for private | `func take_damage(amount: int) -> void:` |
| Constants, enum values | UPPER_SNAKE_CASE | `const MAX_SPEED: float = 400.0` |
| Signals | snake_case, past tense | `signal health_changed(current: int, maximum: int)` |
| Nodes in scenes | PascalCase | `HealthComponent`, `%Sprite` |

## Files Agents Must Not Edit by Hand

- `.godot/` -- the editor cache; regenerate it with `--import`. GameForge's hook blocks edits.
- `*.uid` -- Godot owns these (blocked). Commit them, and move a script together with its `.uid`
  (FileSystem dock, or `git mv` both files).
- `*.import` -- change import settings in the Import dock (the hook asks first).
- `.godot/export_credentials.cfg`, keystores, `.env` -- never read, print or commit.
- `.tscn` / `.tres`: small property edits are fine. Never invent `uid://` values (omit `uid=` on
  new `ext_resource` lines), never copy node blocks wholesale, and prefer generating new scenes with
  a tool script in `tools/`. Ask a human to open and re-save edited scenes in the editor.

Ask before changing the renderer, the 3D physics engine, the engine version, export presets or
signing, or before adding addons or autoloads.

## Commit Convention

GameForge's commit hook checks `<type>(<optional scope>): <summary>` once `.gameforge/project.json`
exists. Keep the subject under 72 characters.

| Type | Use |
|---|---|
| `feat(scope)` | New gameplay feature or system |
| `fix(scope)` | Bug fix |
| `balance(scope)` | Tuning values in `data/*.tres` or exports |
| `art`, `audio` | Asset additions or changes |
| `design`, `level` | Design documents; level layout and content |
| `ui` | Menus, HUD, themes |
| `perf`, `refactor`, `test` | Performance, restructuring without behavior change, tests |
| `chore`, `docs` | Tooling, config, addons; documentation |

The hook also accepts `narrative`, `loc`, `build`, `ci`, `style` and `revert`.

```
feat(combat): add dash state with i-frames
fix(save): keep inventory order when loading v2 saves
balance(enemies): lower slime contact damage from 8 to 6
perf(bullets): pool bullets instead of instantiating per shot
```

## .gitignore

```gitignore
# Godot editor cache, import output and export credentials
.godot/
# Android build template (remove this line if you customize the template)
/android/
# Generated from CSV translations on import
*.translation
# C# crash dumps
mono_crash.*.json
# Builds and test reports
build/
reports/
# GameForge session state (the rest of production/ is tracked)
production/session-state/
production/session-logs/
# OS files
.DS_Store
Thumbs.db
```

Commit `*.uid`, `*.import` and `export_presets.cfg`.

## Git LFS (.gitattributes)

Run `git lfs install` once per machine. GameForge blocks commits that add files over the project's
LFS threshold (default 20 MB) unless LFS tracks them.

```gitattributes
# Text (including .gd, .tscn, .tres, .gdshader, .uid) stays in plain git with LF line endings
* text=auto eol=lf

# Binary assets
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text
*.exr filter=lfs diff=lfs merge=lfs -text
*.hdr filter=lfs diff=lfs merge=lfs -text
*.psd filter=lfs diff=lfs merge=lfs -text
*.kra filter=lfs diff=lfs merge=lfs -text
*.aseprite filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.fbx filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text
*.mp3 filter=lfs diff=lfs merge=lfs -text
*.ogv filter=lfs diff=lfs merge=lfs -text
*.ttf filter=lfs diff=lfs merge=lfs -text
*.otf filter=lfs diff=lfs merge=lfs -text
*.res filter=lfs diff=lfs merge=lfs -text
*.scn filter=lfs diff=lfs merge=lfs -text
```

If Godot reports import errors for images or audio after a clone, the files are probably LFS
pointers: run `git lfs pull`. CI must check out with LFS enabled.

## AI-Generated Content

Agent-written code is reviewed by a person before merge. Generated art, audio and voice are logged in
`design/ai-asset-log.md` through `/gameforge:game-ai-assets`, since stores ask about shipped AI
content. Contributing a fix to the Godot engine itself? The Godot project does not accept
substantial AI-authored code or agent-made pull requests; write those yourself.
