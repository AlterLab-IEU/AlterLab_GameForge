# Headless CLI, the Agent Verification Loop, and Testing

Reference for `game-godot-specialist`. Command-line options are taken from the Godot 4.7
command-line tutorial (docs.godotengine.org/en/stable, which documents 4.7 as of Nov 2026).

## 1. The binary

- Official downloads are named per version and platform (for example a `Godot_v4.7.2-stable_...`
  file). Symlink or alias it to `godot` so commands match the skill's pre-approved
  `Bash(godot --headless *)` pattern; otherwise each call asks for permission.
- The .NET build is a separate download and also needs the .NET SDK installed (section 7).
- `godot --version` prints the engine version. Compare it with `config/features` in
  `project.godot`, which records the version the project was last saved with.

## 2. Command reference (Godot 4.7)

| Command | What it does | Use it for |
|---|---|---|
| `godot --version` | Prints the version string | Confirm the agent and the project use the same engine |
| `godot --headless --path . --import` | Starts the editor, waits for imports, quits (implies `--editor --quit`) | Fresh clones, new assets, renamed `class_name`; rebuilds `.godot/` |
| `godot --headless --path . --check-only --script res://x.gd` | Parses the script for errors and quits | Parse-check each changed `.gd` |
| `godot --headless --path . --script res://tools/x.gd` | Runs a script that extends `SceneTree` or `MainLoop` | Tools: generate scenes, batch-edit resources, validate data |
| `godot --headless --path . --quit-after 600` | Runs the main scene for 600 iterations, then quits | Smoke run that surfaces runtime script errors |
| `godot --headless --path . --log-file /tmp/godot.log ...` | Writes stdout/stderr logs to a file | Keep a log the agent can search with Grep |
| `godot --headless --path . --export-release "<preset>" <path>` | Exports with the named preset (debug variant: `--export-debug`) | Build checks; preset names come from `export_presets.cfg` |
| `godot --headless --path . --export-pack "<preset>" game.pck` | Exports only the pack (`.pck` or `.zip` by extension) | DLC, mods, patch testing |
| `godot --headless --path . --export-patch "<preset>" patch.pck --patches base.pck` | Exports only changed files | Update size checks (delta encoding since 4.6) |
| `godot --path . -e` | Opens the editor | Human checks; not for unattended agent runs |
| `godot --path . --print-fps` / `--gpu-profile` | Prints FPS / the costliest GPU tasks | Quick performance reads on a machine with a GPU |

Notes from the docs:

- `--headless` is equivalent to `--display-driver headless --audio-driver Dummy`. It is required on
  CI machines without a GPU and stops a window from opening during exports elsewhere.
- Relative export paths resolve against the folder that holds `project.godot`, not the shell's
  working directory.
- Exporting needs an editor binary plus export templates of **exactly** the same version.
- `-d` / `--debug` enables the local stdout debugger. On a script error it stops at an interactive
  `debug>` prompt and waits for input, so an unattended agent or CI run hangs. Leave `-d` out of
  agent runs, or pass `--remote-debug tcp://127.0.0.1:0` (the trick gdUnit4's own runner uses), and
  always run with a timeout.
- Do not rely on the exit code to catch runtime script errors. Search the output or log file for
  `SCRIPT ERROR`, `Parse Error` and `ERROR:` lines.

## 3. The agent verification loop

Run this after every agent change that touches `.gd`, `.tscn`, `.tres` or project settings. It is
cheap; skipping it is how vibe debt piles up.

```bash
# 0. Same engine as the project?
godot --version

# 1. Re-import when assets, class_name declarations or files on disk changed (fresh clones always)
godot --headless --path . --import --log-file /tmp/godot-import.log

# 2. Parse-check each changed script (list them with: git diff --name-only -- '*.gd')
godot --headless --path . --check-only --script res://player/player.gd

# 3. Unit and data tests (GUT shown; gdUnit4 in section 6)
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit

# 4. Smoke run of the main scene, then search the log for errors
godot --headless --path . --quit-after 600 --log-file /tmp/godot-smoke.log

# 5. Before a milestone or a store upload: one real export per target
godot --headless --path . --export-release "Linux" build/linux/game.x86_64
```

What the loop cannot tell you: whether the game feels right, renders correctly, or reads well. A
headless run draws nothing. End each agent task with a short "please play this" note for the human:
what changed, how to reach it in game, and what to look for.

## 4. GUT (Godot Unit Test)

| GUT | Godot | Source |
|---|---|---|
| 9.7.x (9.7.0 June 2026, 9.7.1 July 2026) | 4.7 | Release notes: "Compatibility changes for Godot 4.7" |
| 9.6.x | 4.6 | Release notes: "Compatibility changes for Godot 4.6" |
| 9.5.0 | 4.5 | Release notes: "Requires Godot 4.5" |

Install from the editor's Asset Store (4.7) or copy `addons/gut/` from the GitHub release, then
enable it in Project Settings > Plugins. Use the GUT version line that matches your engine minor.

```gdscript
# tests/unit/test_health_component.gd
extends GutTest

var _health: HealthComponent

func before_each() -> void:
	_health = HealthComponent.new()
	_health.max_health = 100
	add_child_autofree(_health)        # enters the tree, so _ready() runs; freed after the test

func test_starts_at_max_health() -> void:
	assert_eq(_health.current_health, 100)

func test_damage_reduces_health() -> void:
	_health.take_damage(30)
	assert_eq(_health.current_health, 70)

func test_lethal_damage_emits_died_once() -> void:
	watch_signals(_health)
	_health.take_damage(999)
	_health.take_damage(10)
	assert_signal_emit_count(_health, "died", 1)

func test_health_never_goes_negative() -> void:
	_health.take_damage(999)
	assert_eq(_health.current_health, 0)
```

Command line (documented form, run from the project root; exit code 0 when all tests pass, 1 when
any fail):

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests -ginclude_subdirs -gexit -gjunit_xml_file=res://reports/gut.xml
```

- `-gdir` lists test directories, `-ginclude_subdirs` recurses, `-gexit` quits when done,
  `-gjunit_xml_file` writes JUnit XML for CI.
- Options can live in `res://.gutconfig.json` (the default `-gconfig`). Generate it from the GUT
  panel rather than writing keys from memory; `-gconfig=` with no value skips it.
- Useful waits for scene tests: `await wait_physics_frames(n)`, `await wait_seconds(t)`,
  `await wait_for_signal(obj.some_signal, max_seconds)`.

## 5. Data and scene tests that pay for themselves

```gdscript
# tests/data/test_enemy_data.gd
extends GutTest

const REGISTRY: EnemyRegistry = preload("res://data/enemy_registry.tres")

func test_every_enemy_has_valid_stats() -> void:
	for stats: EnemyStats in REGISTRY.enemies:
		assert_true(stats.max_health > 0, "%s: max_health" % stats.resource_path)
		assert_false(stats.display_name.is_empty(), "%s: display_name" % stats.resource_path)

func test_levels_instantiate_with_spawn_point() -> void:
	for path: String in ["res://levels/forest_01.tscn", "res://levels/forest_02.tscn"]:
		var scene: PackedScene = load(path)
		assert_not_null(scene, path)
		var level: Node = scene.instantiate()
		add_child_autofree(level)
		assert_not_null(level.get_node_or_null("%PlayerSpawn"), "%s needs %%PlayerSpawn" % path)
```

Test priorities for games:

1. Pure rules: damage formulas, cooldowns, inventory and economy math, seeded generation.
2. Save/load round trips, including loading a save written by the previous version.
3. Data validation over every `.tres` in a registry. Catches designer typos before playtests do.
4. Scene smoke tests: every level instantiates, has its required unique nodes, frees cleanly.
5. State machine transitions for player and AI.

Do not unit-test feel, rendering or audio mix. Those belong to playtests (`/gameforge:game-playtest`)
and the QA plan (`/gameforge:game-qa-lead`).

## 6. gdUnit4

Current release line: **v6.2.x** (v6.2.3 published Nov 2026). The v6.0 line was rebuilt on Godot
4.5 and is not backward compatible with older engines; v6.1.0 added Godot 4.6 compatibility.

```gdscript
# tests/unit/test_health_component_gdunit.gd
extends GdUnitTestSuite

func test_damage_reduces_health() -> void:
	var health: HealthComponent = auto_free(HealthComponent.new())
	health.max_health = 100
	add_child(health)
	health.take_damage(30)
	assert_int(health.current_health).is_equal(70)

func test_lethal_damage_emits_died() -> void:
	var health: HealthComponent = monitor_signals(HealthComponent.new())   # also auto-frees
	add_child(health)
	health.take_damage(999)
	await assert_signal(health).is_emitted("died")
```

Command line:

```bash
# Wrapper script shipped with the addon (Linux/macOS; runtest.cmd on Windows).
# Reads the engine path from --godot_binary or the GODOT_BIN environment variable.
GODOT_BIN="$(command -v godot)" addons/gdUnit4/runtest.sh -a res://tests

# Direct, headless. In v6.2.x, headless runs are refused unless you pass --ignoreHeadlessMode
# (the flag is deprecated and has no effect in the upcoming 7.0 line).
godot --headless --path . --remote-debug tcp://127.0.0.1:0 \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode
```

- `-a/--add` adds a directory or suite, `-i/--ignore` skips one, `-rd/--report-directory` changes
  the report folder (default `res://reports/`), `-rc/--report-count` limits kept reports.
- Reports are written as HTML and JUnit XML. Add `reports/` to `.gitignore`.
- Tests that simulate UI input do not work headless, because Godot does not deliver `InputEvent`s in
  headless mode. Run those under a virtual display (for example `xvfb-run`) in CI.
- `scene_runner("res://levels/forest_01.tscn")` drives a real scene with simulated input and frame
  stepping when you need integration tests.

## 7. C# projects

- Engine requirements: the C# docs state Godot 4.5+ needs **.NET 8 or later** (Android exports need
  .NET 9+). The **Godot 4.8 .NET build needs .NET 10 or later** (4.8 beta 1 notes). Pin the SDK in
  `global.json` so CI and every machine agree.
- Build from the command line with `dotnet build` in the project folder, or let Godot do it with
  `godot --headless --path . --build-solutions --quit`.
- Keep rules engine-free where you can (plain C# classes for damage, inventory, economy) and test
  them with an ordinary test project and `dotnet test`. No engine process is needed.
- For tests that need nodes, gdUnit4 has a C# variant, gdUnit4Net (GitHub
  `godot-gdunit-labs/gdUnit4Net`), which runs through `dotnet test`. Follow its README for the
  version that matches your engine.
- C# projects cannot export to the web in Godot 4 (see the export reference).

## 8. Handing off to CI

`/gameforge:game-ci-pipeline` owns pipeline files. The Godot-specific facts it needs:

1. Check out with Git LFS enabled, or textures and audio arrive as pointer files.
2. Cache the editor binary **and** export templates for the exact version (4.7.2 must pair with
   4.7.2 templates). From 4.8, macOS downloads are per architecture, with universal builds still
   available.
3. Run `--import` before anything else; a clean checkout has no `.godot/` and no global class cache.
4. Run tests (section 4 or 6), then exports, then upload build artifacts and JUnit reports.
5. Inject signing secrets as CI secrets. Android keystores can come from
   `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER` and
   `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`, which override the preset values.
