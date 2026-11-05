# Engine Test Frameworks (snapshot: November 2026)

Setup notes, minimal example tests and headless commands for each stack GameForge supports. Use
this when creating or extending a project's test harness. Wiring these commands into CI belongs to
`/gameforge:game-ci-pipeline`.

## Version snapshot

| Framework | Version checked | Engine compatibility | Source (checked 2026-11-05) |
|---|---|---|---|
| GUT (Godot Unit Test) | 9.7.1 (`godot_4_7` branch) | Godot 4.7.x; GUT 9.6.1 for 4.6.x; 7.x for Godot 3 | GUT README version table, github.com/bitwes/Gut |
| gdUnit4 | 6.2.3 (latest 6.2.x tag) | 6.2.x supports Godot 4.5 through 4.7.1; master (v7) targets 4.7+ | gdUnit4 README compatibility table |
| gdUnit4Net (C#) | 5.0.0 tag | Godot .NET projects; run with `dotnet test` | git tags, github.com/MikeSchulze/gdUnit4Net |
| Unity Test Framework | ships with the editor (`com.unity.test-framework`) | Unity 6.3 LTS, 6.6 | Unity manual |
| Unreal Automation | built in | UE 5.8 | Epic documentation |
| Vitest | 5.1.0 (2026-11-02) | peer `vite` ^6.4, ^7 or ^8 | npm registry |
| Playwright | 1.64.1 (2026-10-14) | Chromium, Firefox, WebKit | npm registry |

Godot 4.8 is in beta (its .NET build needs .NET 10). Match the GUT branch or gdUnit4 line to the
project's exact Godot version; both projects publish compatibility tables and mismatches show up
as parse errors in the addon, not as test failures.

## Godot

### GUT

Install: Asset Library (one listing for Godot 4) or copy `addons/gut/` from the matching release,
then enable the plugin and relaunch the editor.

```gdscript
# tests/unit/test_damage.gd
extends GutTest

var calc: DamageCalc

func before_each() -> void:
	calc = DamageCalc.new()

func test_crit_doubles_base_damage() -> void:
	assert_eq(calc.compute(10, true), 20, "crit should double base damage")

func test_armor_never_reduces_below_one() -> void:
	assert_eq(calc.compute(1, false, 999), 1)

func test_player_takes_damage_in_scene() -> void:
	var player: Player = add_child_autofree(preload("res://scenes/player.tscn").instantiate())
	player.apply_damage(5)
	await wait_physics_frames(2)
	assert_eq(player.health, player.max_health - 5)
```

Run headless (exit code 0 when all pass, 1 on any failure; `pending` does not fail the run):

```bash
godot --headless --path . -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests -ginclude_subdirs -gexit -gjunit_xml_file=res://reports/gut.xml
```

Options can live in `res://.gutconfig.json`; command-line flags override it. Generate a sample with
`-gprint_gutconfig_sample`.

### gdUnit4

Install from the Asset Library or the matching release, enable the plugin. Test suites extend
`GdUnitTestSuite`; the scene runner simulates input and frames for integration tests.

```gdscript
# tests/test_player_jump.gd
extends GdUnitTestSuite

func test_jump_leaves_ground() -> void:
	var runner := scene_runner("res://tests/scenes/player_sandbox.tscn")
	var player: CharacterBody2D = runner.find_child("Player")
	var start_y := player.global_position.y
	runner.simulate_action_pressed("jump")
	await runner.simulate_frames(10)
	assert_float(player.global_position.y).is_less(start_y)

func test_coin_pickup_increments_score() -> void:
	var runner := scene_runner("res://tests/scenes/coin_sandbox.tscn")
	runner.invoke("spawn_coin_at_player")
	await runner.simulate_frames(5)
	assert_int(runner.get_property("score")).is_equal(1)
```

Command line: the addon ships `addons/gdUnit4/runtest.sh` (and `.cmd`), which takes the Godot binary
from `GODOT_BIN` or `--godot_binary` and accepts `-a <path>` to add test suites:

```bash
GODOT_BIN=/usr/local/bin/godot ./addons/gdUnit4/runtest.sh -a res://tests
```

Reports land in `res://reports/` by default (`-rd` changes it). For .NET projects the script runs
`dotnet build` first.

### Godot C#
Use gdUnit4Net with the standard .NET test tooling (`dotnet test`). Godot 4.8's .NET build will
require .NET 10; pin the SDK in `global.json` before upgrading.

### Godot-specific pitfalls
- `--headless` uses a dummy renderer: logic and scene tests work, screenshots do not. For visual
  tests run with a real or virtual display (for example `xvfb-run`) and software Vulkan/GL, or use
  Movie Maker mode (`--write-movie`) with `--fixed-fps` to render deterministic frames.
- Autoloads run in tests. Give singletons a `reset()` and call it in `before_each`.
- Avoid `await get_tree().create_timer(...)` in tests; step frames instead.

## Unity (6.3 LTS, 6.6)

Unity Test Framework is NUnit-based with two modes:
- **Edit Mode**: fast, no Play Mode, for pure logic. Put tests in an assembly with an `.asmdef`
  that references the code under test and is marked for tests.
- **Play Mode**: runs the player loop; `[UnityTest]` coroutines can wait frames and load scenes.

```csharp
// Assets/Tests/EditMode/DamageTests.cs
using NUnit.Framework;

public class DamageTests
{
    [Test]
    public void Crit_DoublesBaseDamage() => Assert.AreEqual(20, DamageCalc.Compute(10, crit: true));

    [TestCase(1, 999, ExpectedResult = 1)]
    [TestCase(10, 5, ExpectedResult = 5)]
    public int Armor_NeverBelowOne(int dmg, int armor) => DamageCalc.Compute(dmg, false, armor);
}
```

```csharp
// Assets/Tests/PlayMode/SmokeTests.cs
using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.TestTools;

public class SmokeTests
{
    [SetUp] public void ResetStatics() => GameSession.ResetForTests(); // see pitfall below

    [UnityTest]
    public IEnumerator MainScene_LoadsAndRunsTwoSecondsWithoutErrors()
    {
        yield return SceneManager.LoadSceneAsync("Main");
        float end = Time.realtimeSinceStartup + 2f;
        while (Time.realtimeSinceStartup < end) yield return null;
        LogAssert.NoUnexpectedReceived();
        Assert.IsNotNull(Object.FindFirstObjectByType<PlayerController>());
    }
}
```

Command line (do not combine `-runTests` with `-quit`; the runner exits on its own):

```bash
Unity -batchmode -nographics -projectPath . -runTests -testPlatform EditMode \
  -testResults ./reports/editmode.xml -logFile -
Unity -batchmode -projectPath . -runTests -testPlatform PlayMode \
  -testResults ./reports/playmode.xml -logFile -
```

`-nographics` is fine for Edit Mode; Play Mode tests that render or capture screenshots need a
graphics device. Performance regressions: the Performance Testing package
(`com.unity.test-framework.performance`) records measurements inside tests.

### Unity-specific pitfalls
- **Unity 6.6 turns Fast Enter Play Mode on by default, so static fields no longer reset** between
  Play Mode sessions. Tests that passed in 6.3 can become order-dependent. Reset statics explicitly
  in `[SetUp]` or with `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`.
- Unity 6.0 LTS left standard support on 2026-10-16; target 6.3 LTS for new test infrastructure.
- Unity AI's official MCP server (via the Unity CLI, beta) and the community MCP for Unity
  (CoplayDev) can trigger test runs from an agent; treat their results like any other run and read
  the XML.

## Unreal Engine 5.8

Options, from cheapest to heaviest:
- **Automation Test Framework** (`IMPLEMENT_SIMPLE_AUTOMATION_TEST`, complex tests) for C++ logic.
- **Automation Spec** (BDD-style `Describe`/`It`) for readable grouped tests.
- **Functional Tests**: `AFunctionalTest` actors placed in dedicated test maps, for gameplay in a
  running world; screenshot functional tests compare rendered frames against approved images.
- **Gauntlet**: orchestrates full sessions (client, server, devices) for soak and multiplayer runs.

```cpp
// Source/MyGame/Tests/DamageTests.cpp
#include "Misc/AutomationTest.h"
#include "DamageLibrary.h"

#if WITH_AUTOMATION_TESTS
IMPLEMENT_SIMPLE_AUTOMATION_TEST(FDamageCritDoubles, "MyGame.Combat.Damage.CritDoubles",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)

bool FDamageCritDoubles::RunTest(const FString& Parameters)
{
    TestEqual(TEXT("crit doubles base damage"), UDamageLibrary::Compute(10, true), 20);
    TestTrue(TEXT("armor floor is 1"), UDamageLibrary::Compute(1, false, 999) >= 1);
    return true;
}
#endif
```

Headless run from the command line:

```bash
UnrealEditor-Cmd "/path/MyGame.uproject" -ExecCmds="Automation RunTests MyGame." \
  -TestExit="Automation Test Queue Empty" -unattended -nullrhi -nosplash -nosound \
  -ReportExportPath="Saved/Automation/Reports" -log
```

`-nullrhi` skips rendering; drop it for screenshot functional tests and run on a machine with a GPU.

### Unreal-specific notes
- UE 5.8's experimental **Unreal MCP** plugin can run automation tests from an agent. It is
  editor-only and listens on `127.0.0.1:8000` without authentication: a local developer tool, not a
  CI runner. CI keeps using the command line above.
- UE 5.8 is the last planned UE5 major; UE6 (early access targeted for late 2027) moves toward
  Verse and Scene Graph. Keep gameplay logic testable in plain C++ functions so tests survive the
  migration.

## Web (Three.js, React Three Fiber, Phaser 4, PixiJS 8, Kaplay)

Split the game into a **pure simulation** (state + `step(dt, input)` + seeded RNG, no DOM, no
renderer) and a **view** that draws it. Vitest tests the simulation in Node in milliseconds;
Playwright tests the real build in a browser.

### Vitest (logic)

```ts
// src/sim/damage.test.ts
import { describe, it, expect } from 'vitest';
import { computeDamage } from './damage';
import { createSim } from './sim';

describe('damage', () => {
  it('crit doubles base damage', () => expect(computeDamage(10, { crit: true })).toBe(20));
  it('armor never reduces below 1', () => expect(computeDamage(1, { armor: 999 })).toBe(1));
});

describe('sim determinism', () => {
  it('same seed and inputs give identical state after 600 steps', () => {
    const run = () => {
      const sim = createSim({ seed: 1337 });
      for (let i = 0; i < 600; i++) sim.step(1000 / 60, { right: i % 2 === 0 });
      return JSON.stringify(sim.snapshot());
    };
    expect(run()).toBe(run());
  });
});
```

Run with `npx vitest run` (or `npm test` mapped to it). Vitest 5 needs Vite 6.4 or newer; Vite 8
(Rolldown-based) is the current line. Vitest also has a browser mode backed by Playwright
(`@vitest/browser-playwright`) for testing code that needs real WebGL or Web Audio objects.

### Playwright (end-to-end, screenshots)

```ts
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: 'tests/e2e',
  webServer: { command: 'npm run build && npm run preview', url: 'http://localhost:4173', reuseExistingServer: true },
  use: { baseURL: 'http://localhost:4173', viewport: { width: 1280, height: 720 }, deviceScaleFactor: 1 },
  expect: { toHaveScreenshot: { maxDiffPixelRatio: 0.01, animations: 'disabled' } },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'webkit', use: { browserName: 'webkit' } }, // catches Safari/iOS-only breakage
  ],
});
```

Install browsers once with `npx playwright install --with-deps`. Run with `npx playwright test`;
update baselines only after a human compares old and new images:
`npx playwright test --update-snapshots`. The smoke spec and the screenshot loop that use the
game's test hooks are in `agent-test-hooks.md` in this directory.

### Web pitfalls
- Headless browsers usually render WebGL through a software rasterizer. Generate golden images on
  the same CI image that compares them; expect small differences between Chromium and WebKit and
  keep separate baselines per project (Playwright does this by default).
- Disable or freeze anything time-based (particles, shaders using `performance.now()`, CSS
  animations) through the test hooks before taking screenshots.
- Trig and floating-point results can differ between browser engines; if replays or lockstep
  multiplayer depend on bit-exact math, use your own deterministic functions and test across
  engines (Simon Willison's Battle Drones write-up, October 2026, describes exactly this desync
  between Chrome and Safari).
- Pin the Playwright version in `package.json`; browser builds change with each release.

## Choosing when a project has nothing yet

| Situation | Start with |
|---|---|
| Godot, GDScript, solo dev | GUT (simplest CLI) or gdUnit4 (better scene runner); pick one, not both |
| Godot with C# | gdUnit4Net + `dotnet test` |
| Unity | Edit Mode tests for logic first, one Play Mode smoke test second |
| Unreal | Simple automation tests for C++ logic, one functional test map for the critical path |
| Web game | Vitest on `src/sim/`, one Playwright smoke spec, then screenshot specs |
| Prototype or jam | Only the smoke test. Everything else waits until the design survives a playtest |
