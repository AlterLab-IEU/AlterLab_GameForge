# Agent-Callable Test Hooks

A game that a coding agent can test is a game with a small, deliberate **test surface**: a way to
read state as text, step time deterministically, fix the random seed, jump to a scenario, and run a
headless smoke check that exits with a status code. This file gives the contract, per-engine
implementations, the web screenshot loop, and the "check commands" block for the project's
`CLAUDE.md`.

The pattern follows two published sources: OpenAI's `develop-web-game` skill (implement, act,
pause, observe, adjust; `window.render_game_to_text()`, `window.advanceTime(ms)`, Playwright after
every meaningful change, screenshots as the source of truth) and Anthropic's Claude Code best
practices (give Claude something it can run that comes back pass or fail; ask for evidence).

## 1. The contract

| Capability | Web | Godot 4.7 | Unity 6.x | Unreal 5.8 |
|---|---|---|---|---|
| State as text | `window.render_game_to_text()` returns JSON | `TestHooks.dump_state()`; smoke prints `STATE {...}` | `TestHooks.RenderGameToText()` | `Game.DumpState` console command |
| Deterministic time | `window.advanceTime(ms)` pauses the loop and steps fixed ticks | `--fixed-fps 60` engine flag | `Time.captureFramerate = 60` | fixed time step command-line flags |
| Seed | `?seed=1337` or `window.setSeed(n)` | `-- --seed=1337` | `-seed 1337` | `Game.Smoke 1337` argument |
| Scenario | `?scenario=boss_phase_2` | `-- --scenario=boss_phase_2` | `-scenario boss_phase_2` | `Game.LoadScenario boss_phase_2` |
| Input | `window.press(action, down)` or real keyboard events | `Input.action_press()` | Input System test fixtures or a facade | `Game.Press <action>` |
| Smoke with exit code | Playwright spec | `-- --smoke` then `get_tree().quit(code)` | `-smoke` then `Application.Quit(code)` | `RequestExitWithStatus` |

Rules for the surface:
- **Off in release builds.** Compile it out or gate it behind a build flag. Never gate it on a URL
  parameter alone in a shipped web build.
- **Text over pixels for logic.** State JSON is cheap for agents to read and for tests to assert.
  Screenshots verify rendering, layout and "is anything on screen at all."
- **Keep the JSON small and stable**: mode, tick, player position and health, enemy count/HP,
  score, current scenario. Round floats. Agents reason better over 30 lines than 3,000.
- **Multiplayer**: the server validates everything regardless. Exposed `window` globals are a cheat
  surface; the test surface must not add trust the server does not already check.

## 2. Web (Vite + Three.js / Phaser / PixiJS)

Prerequisite: the simulation is separated from rendering (`sim.step(dt, input)`, seeded RNG).

```ts
// src/debug/testHooks.ts
import type { Sim } from '../sim/sim';
import type { GameLoop } from '../loop';

// Enabled in dev and in builds made with VITE_TEST_HOOKS=1. Release builds omit it.
export const TEST_HOOKS = import.meta.env.DEV || import.meta.env.VITE_TEST_HOOKS === '1';

export function installTestHooks(sim: Sim, loop: GameLoop): void {
  if (!TEST_HOOKS) return;
  const params = new URLSearchParams(location.search);
  if (params.has('seed')) sim.reset({ seed: Number(params.get('seed')) });
  if (params.has('scenario')) sim.loadScenario(params.get('scenario')!);

  const w = window as unknown as Record<string, unknown>;
  w.render_game_to_text = () => JSON.stringify({
    mode: sim.state.mode,                          // 'title' | 'playing' | 'paused' | 'gameover'
    tick: sim.state.tick,
    scenario: sim.state.scenario,
    player: { x: Math.round(sim.state.player.x), y: Math.round(sim.state.player.y), hp: sim.state.player.hp },
    enemies: sim.state.enemies.map((e) => ({ id: e.id, kind: e.kind, hp: e.hp })),
    score: sim.state.score,
  });
  w.advanceTime = (ms: number) => {
    loop.pause();                                  // stop the rAF-driven loop
    const dt = 1000 / 60;
    for (let t = 0; t < ms; t += dt) sim.step(dt, sim.input);
    loop.renderOnce();                             // draw the resulting state once
  };
  w.setSeed = (n: number) => sim.reset({ seed: n });
  w.loadScenario = (name: string) => sim.loadScenario(name);
  w.press = (action: string, down = true) => sim.setInput(action, down);
}
```

`package.json` scripts the agent and CI call:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:unit": "vitest run",
    "build:test": "VITE_TEST_HOOKS=1 vite build",
    "test:smoke": "playwright test --grep @smoke",
    "test:visual": "playwright test --grep @visual",
    "test:look": "playwright test --grep @look"
  }
}
```

Point Playwright's `webServer.command` at `npm run build:test && npm run preview` so tests run
against a production-like build with hooks enabled.

### Smoke, visual and "look" specs

```ts
// tests/e2e/game.spec.ts
import { test, expect, type Page } from '@playwright/test';

const hooksReady = (page: Page) =>
  page.waitForFunction(() => typeof (window as any).render_game_to_text === 'function', null, { timeout: 10_000 });
const state = async (page: Page) =>
  JSON.parse(await page.evaluate(() => (window as any).render_game_to_text()));
const step = (page: Page, ms: number) => page.evaluate((m) => (window as any).advanceTime(m), ms);

test('@smoke boots, accepts input, no console errors', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });

  await page.goto('/?seed=1337');
  await hooksReady(page);
  await page.keyboard.press('Enter');               // title -> playing
  await step(page, 500);
  const before = await state(page);
  expect(before.mode).toBe('playing');

  await page.evaluate(() => (window as any).press('jump'));
  await step(page, 200);
  const after = await state(page);
  expect(after.player.y).toBeLessThan(before.player.y);   // screen y grows downward
  expect(errors).toEqual([]);
});

test('@smoke action chain: shoot -> enemy hp -> score', async ({ page }) => {
  await page.goto('/?seed=1337&scenario=single_enemy_in_range');
  await hooksReady(page);
  const s0 = await state(page);
  await page.evaluate(() => (window as any).press('fire'));
  await step(page, 1000);
  const s1 = await state(page);
  expect(s1.enemies.length).toBeLessThan(s0.enemies.length);
  expect(s1.score).toBeGreaterThan(s0.score);
});

for (const scenario of ['title', 'combat_wave_3', 'boss_phase_2', 'game_over']) {
  test(`@visual ${scenario}`, async ({ page }) => {
    await page.goto(`/?seed=1337&scenario=${scenario}`);
    await hooksReady(page);
    await step(page, 1000);
    await expect(page.locator('canvas')).toHaveScreenshot(`${scenario}.png`);
  });
}

// Not a pass/fail test: saves evidence for the agent (or a human) to open and inspect.
test('@look capture current state', async ({ page }) => {
  await page.goto('/?seed=1337');
  await hooksReady(page);
  await page.keyboard.press('Enter');
  for (const ms of [0, 1000, 5000]) {
    await step(page, ms);
    await page.screenshot({ path: `test-results/look/t${ms}.png` });
    console.log(`t=${ms}`, await state(page));
  }
});
```

The agent loop after every meaningful change: run `npm run test:unit` and `npm run test:smoke`;
if anything visual changed, run `npm run test:look` and open the PNGs in `test-results/look/`
before describing the result. Fix the first new console error before anything else, change one
variable at a time, and reset state between scenarios.

## 3. Godot 4.7

```gdscript
# res://debug/test_hooks.gd -- register as Autoload "TestHooks"
extends Node

var args: Dictionary = {}

func _ready() -> void:
	# Enabled in debug runs and in exports with the custom feature tag "test_hooks".
	if not (OS.is_debug_build() or OS.has_feature("test_hooks")):
		return
	for a in OS.get_cmdline_user_args():          # arguments after `--` or `++`
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else true
	if args.has("seed"):
		Game.rng.seed = int(args["seed"])
	if args.has("scenario"):
		Game.load_scenario(String(args["scenario"]))
	if args.has("smoke"):
		_run_smoke.call_deferred()

func dump_state() -> String:
	return JSON.stringify(Game.snapshot())         # small Dictionary: mode, tick, player, enemies, score

func _run_smoke() -> void:
	var frames := int(args.get("smoke_frames", 300))
	var start: Dictionary = Game.snapshot()
	Input.action_press("move_right")
	for i in frames:
		await get_tree().physics_frame
	Input.action_release("move_right")
	var end: Dictionary = Game.snapshot()
	print("STATE ", JSON.stringify(end))
	var ok: bool = end["mode"] == "playing" and end["player"]["x"] > start["player"]["x"]
	get_tree().quit(0 if ok else 1)
```

```bash
godot --headless --path . --fixed-fps 60 -- --smoke --seed=1337 2>&1 | tee reports/smoke.log
grep -E "SCRIPT ERROR|ERROR:" reports/smoke.log && exit 1   # fail on engine-reported errors
```

Script errors do not always change Godot's exit code, so grep the log. For screenshot tests,
`--headless` will not render; use a display (or `xvfb-run`) with Movie Maker mode, for example
`godot --path . --fixed-fps 60 --write-movie reports/frames/boss.png --quit-after 120 -- --scenario=boss_phase_2`,
and compare the last frame against the approved image. Community MCP servers for Godot (for
example Coding-Solo/godot-mcp) can launch the project and read this output for an agent.

## 4. Unity 6.3 LTS / 6.6

```csharp
// Assets/Scripts/Debug/TestHooks.cs
using System;
using System.Collections;
using UnityEngine;

public static class TestHooks
{
    static string Arg(string name)
    {
        var a = Environment.GetCommandLineArgs();
        int i = Array.IndexOf(a, name);
        return i >= 0 && i + 1 < a.Length ? a[i + 1] : null;
    }

    public static string RenderGameToText() => JsonUtility.ToJson(GameState.Snapshot());

#if DEVELOPMENT_BUILD || UNITY_EDITOR
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Init()
    {
        if (Arg("-seed") is string s) GameRng.Reset(int.Parse(s));
        if (Arg("-scenario") is string sc) ScenarioLoader.Load(sc);
        if (Array.IndexOf(Environment.GetCommandLineArgs(), "-smoke") >= 0)
        {
            Time.captureFramerate = 60;            // fixed 1/60 s per frame regardless of wall clock
            new GameObject("SmokeRunner").AddComponent<SmokeRunner>();
        }
    }
#endif
}

public class SmokeRunner : MonoBehaviour
{
    int errors;
    void OnEnable() => Application.logMessageReceived += (msg, stack, type) =>
    { if (type == LogType.Error || type == LogType.Exception) errors++; };

    IEnumerator Start()
    {
        var start = GameState.Snapshot();
        GameInput.Press("MoveRight");
        for (int i = 0; i < 300; i++) yield return null;
        var end = GameState.Snapshot();
        Debug.Log("STATE " + TestHooks.RenderGameToText());
        bool ok = errors == 0 && end.mode == "playing" && end.playerX > start.playerX;
        Application.Quit(ok ? 0 : 1);
    }
}
```

```bash
./Builds/Linux/MyGame.x86_64 -batchmode -nographics -smoke -seed 1337 -logFile reports/smoke.log
echo "exit: $?"
```

Agents connected through Unity's MCP server or MCP for Unity can trigger the same entry points
from the editor; the command line above is what CI runs.

## 5. Unreal Engine 5.8

```cpp
// Source/MyGame/Debug/SmokeCommands.cpp -- development builds only
#if !UE_BUILD_SHIPPING
#include "HAL/IConsoleManager.h"
#include "SmokeSubsystem.h"

static FAutoConsoleCommandWithWorldAndArgs GSmokeCmd(
    TEXT("Game.Smoke"),
    TEXT("Game.Smoke <seed>: boot smoke test; exits with status 0 (pass) or 1 (fail)"),
    FConsoleCommandWithWorldAndArgsDelegate::CreateLambda([](const TArray<FString>& Args, UWorld* World)
    {
        const int32 Seed = Args.Num() > 0 ? FCString::Atoi(*Args[0]) : 1337;
        World->GetGameInstance()->GetSubsystem<USmokeSubsystem>()->Run(Seed);
        // USmokeSubsystem steps the game, compares DumpState() before/after, then calls
        // FPlatformMisc::RequestExitWithStatus(false, bOk ? 0 : 1);
    }));
#endif
```

```bash
./MyGame -ExecCmds="Game.Smoke 1337" -unattended -nullrhi -nosound -log
```

Unreal can also run with a fixed time step and fixed seeds from the command line (for example the
`-deterministic` switch); confirm the exact flags against your engine version before relying on
them in CI. UE 5.8's experimental Unreal MCP can invoke console commands and automation tests from
an agent inside the editor only.

## 6. The check-commands block for the project's CLAUDE.md

Put this at the top of the game project's `CLAUDE.md` (not GameForge's). Agents read it first.

```markdown
## Checks (run after every change; paste the output before saying "done")
- `npm run test:unit`   Vitest on src/sim, under 10 s
- `npm run test:smoke`  Playwright: boots, input changes state, no console errors, under 60 s
- `npm run test:look`   Saves screenshots to test-results/look/; open and inspect them
Never edit, skip or delete existing tests or snapshot baselines to make a check pass. Ask first.
Seeds: use 1337 for repro. Scenarios: see src/sim/scenarios.ts.
```

Godot, Unity and Unreal projects list their equivalents (`godot --headless ... -- --smoke`,
the player build with `-smoke`, `Game.Smoke`).

## 7. Optional: a Stop hook in the user's project

Teams that want the quick suite enforced can add a Stop hook to the game project's own
`.claude/settings.json` (separate from GameForge's plugin hooks). Exit code 2 from a Stop hook
blocks the stop and shows stderr to Claude, so a failing suite sends the agent back to work.

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "npm run --silent test:unit >&2 || exit 2", "timeout": 90 } ] }
    ]
  }
}
```

Keep it to the fast suite (seconds, not minutes), and make sure a persistently failing test cannot
trap the session in a loop: the hook input includes a `stop_hook_active` flag you can check in a
wrapper script.
