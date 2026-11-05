# Verification Harness Reference

Read this before writing the first check. It gives Claude a check that comes back pass or fail for
a game: the game exposes its state as text and lets a test step time deterministically, and a
Playwright script drives input, saves screenshots and state, and exits non-zero on any console
error or broken expectation.

Code targets the versions pinned in `stack-and-scaffold.md`: Vite 8 vanilla-ts template,
`playwright@1.64.1`. The game-side modules (`testHooks.ts`, the fixed-step loop, seeded rng,
buffered input, debug overlay, tuning panel) and the Godot headless variant are in
`game-test-hooks.md`. This script and both example games in `stack-and-scaffold.md` were built and
run end to end on 5 Nov 2026 (Vite 8.3.6, three 0.187.0, Phaser 4.2.1, Playwright 1.64.1).

## The hook contract

The pattern comes from OpenAI's `develop-web-game` skill (openai/skills, curated set; read via a
mirror on 5 Nov 2026), whose loop is "implement, act, pause, observe, adjust":

| Hook | Contract |
|---|---|
| `window.render_game_to_text(): string` | Compact JSON of what is on screen, enough to play without the visuals: a note on the coordinate system (origin and axis directions), player position and velocity, active enemies and obstacles, pickups, timers and cooldowns, score, mode flags. No long histories. |
| `window.advanceTime(ms): void` | Deterministic stepping. Converts `ms` into fixed 1/60 s updates and renders once. Without it, automated tests are flaky. |

GameForge adds three conventions:

- Hooks exist only in dev and in test builds (`vite build --mode test`, which reads
  `VITE_TEST_HOOKS=1` from `.env.test`), and install only when the URL has `?test=1`. Release
  builds compile them out, so players never get them.
- `?seed=<n>` seeds every random draw; the same seed and inputs give the same state.
- In test mode the real-time loop only renders. Simulation advances only through `advanceTime`.

OpenAI's rules carry over unchanged: run the check after every meaningful change, treat
screenshots as the source of truth, confirm the text state matches the screen, fix the first new
console error before anything else, reset state between scenarios, and test whole action chains.

## The Playwright script: `tests/e2e/verify.mjs`

Plain Node ESM using the `playwright` library (OpenAI's skill also avoids `@playwright/test`
unless asked). It serves the test build with Vite's `preview()` API, runs each scenario in a
fresh browser context, and exits 1 on any failure.

```js
// tests/e2e/verify.mjs: pass/fail check for a web game.
//   npm run verify                    build, then run every scenario in tests/e2e/scenarios/
//   npm run verify -- dash            only scenarios whose filename contains "dash"
//   GAME_URL=http://localhost:5173/ node tests/e2e/verify.mjs    against a running dev server
//   HEADED=1 | BROWSER=webkit | DEVICE="Pixel 5"                 headed, other engine, mobile emulation
// Setup: npm install -D playwright@1.64.1 && npx playwright install chromium
import { chromium, firefox, webkit, devices } from 'playwright';
import { preview } from 'vite';
import { mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises';

const SCENARIOS = 'tests/e2e/scenarios';
const OUT = 'tests/e2e/out';
const STEP_MS = 1000 / 60;
const filter = process.argv[2] ?? '';
const engine = { chromium, firefox, webkit }[process.env.BROWSER ?? 'chromium'];
if (!engine) throw new Error(`BROWSER must be chromium, firefox or webkit`);
if (process.env.DEVICE && !devices[process.env.DEVICE]) throw new Error(`Unknown DEVICE "${process.env.DEVICE}"`);
const contextOptions = process.env.DEVICE ? devices[process.env.DEVICE] : { viewport: { width: 1280, height: 720 } };

let server = null;
let base = process.env.GAME_URL;
if (!base) {
  server = await preview({ preview: { port: 4173, strictPort: true }, logLevel: 'warn' });
  base = server.resolvedUrls?.local[0] ?? 'http://localhost:4173/';
}

const files = (await readdir(SCENARIOS).catch(() => [])).filter((f) => f.endsWith('.json') && f.includes(filter)).sort();
if (files.length === 0) {
  console.error(`No scenarios in ${SCENARIOS} match "${filter}".`);
  process.exit(1);
}

const browser = await engine.launch({ headless: !process.env.HEADED });
let failed = 0;

for (const file of files) {
  const name = file.replace(/\.json$/, '');
  const scenario = JSON.parse(await readFile(`${SCENARIOS}/${file}`, 'utf8'));
  const dir = `${OUT}/${name}`;
  await rm(dir, { recursive: true, force: true });
  await mkdir(dir, { recursive: true });

  const context = await browser.newContext(contextOptions); // fresh profile: no cache, no storage
  const page = await context.newPage();
  const errors = [];
  page.on('console', (msg) => { if (msg.type() === 'error') errors.push(msg.text()); });
  page.on('pageerror', (err) => errors.push(String(err)));
  const problems = [];

  try {
    await page.goto(new URL(`?test=1&seed=${scenario.seed ?? 42}`, base).href);
    await page.waitForFunction(
      () => typeof window.advanceTime === 'function' && typeof window.render_game_to_text === 'function',
      null,
      { timeout: 15_000 },
    );
    const advance = (frames) => page.evaluate((ms) => window.advanceTime(ms), frames * STEP_MS);
    const state = async () => JSON.parse(await page.evaluate(() => window.render_game_to_text()));
    let shots = 0;

    for (const step of scenario.steps) {
      if (step.hold) {
        for (const key of step.hold) await page.keyboard.down(key);
        await advance(step.frames ?? 1);
        for (const key of step.hold) await page.keyboard.up(key);
      } else {
        if (step.tap) {
          await page.keyboard.down(step.tap);
          await advance(2);
          await page.keyboard.up(step.tap);
        }
        if (step.click) {
          await page.locator('canvas').first().click({ position: { x: step.click[0], y: step.click[1] } });
        }
        if (step.frames) await advance(step.frames);
      }
      if (step.expect) {
        const s = await state();
        for (const [path, op, want] of step.expect) {
          const got = path.split('.').reduce((obj, key) => obj?.[key], s);
          if (!compare(got, op, want)) problems.push(`${path} ${op} ${JSON.stringify(want)}: got ${JSON.stringify(got)}`);
        }
      }
      if (step.shot) {
        shots += 1;
        const stem = `${dir}/${String(shots).padStart(2, '0')}-${step.shot}`;
        await page.screenshot({ path: `${stem}.png` });
        await writeFile(`${stem}.json`, JSON.stringify(await state(), null, 2));
      }
    }
  } catch (err) {
    problems.push(`harness: ${err.message}`);
  }
  await context.close();

  const ok = problems.length === 0 && errors.length === 0;
  if (!ok) failed += 1;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}`);
  for (const p of problems) console.log(`  expect  ${p}`);
  for (const e of errors) console.log(`  console ${e}`);
}

await browser.close();
await server?.close();
console.log(`${files.length - failed}/${files.length} scenarios passed. Screenshots and state in ${OUT}/`);
process.exit(failed ? 1 : 0);

function compare(got, op, want) {
  switch (op) {
    case '==': return JSON.stringify(got) === JSON.stringify(want);
    case '!=': return JSON.stringify(got) !== JSON.stringify(want);
    case '>': return got > want;
    case '>=': return got >= want;
    case '<': return got < want;
    case '<=': return got <= want;
    case 'exists': return got !== undefined && got !== null;
    default: throw new Error(`unknown operator "${op}"`);
  }
}
```

Key names are Playwright's: `ArrowLeft`, `Space`, `KeyA`, `Enter`, `Escape`. Click positions are
CSS pixels relative to the canvas element's top-left corner. `DEVICE` emulation needs Chromium or
WebKit (Firefox does not support mobile emulation). WebKit approximates Safari; it does not replace
a real iPhone.

## Scenario files (`tests/e2e/scenarios/*.json`)

Each step can `hold` keys for `frames`, `tap` a key, `click` the canvas, wait `frames`, check
`expect` triples `[path, operator, value]` against the state JSON (dotted paths, array indexes
allowed: `enemies.0.hp`, `enemies.length`), and save a `shot`.

Smoke test, matching the Three.js example world in the scaffold reference:

```json
{
  "seed": 42,
  "steps": [
    { "frames": 30, "shot": "start" },
    { "expect": [["mode", "==", "playing"], ["player.x", "exists", null]] },
    { "hold": ["ArrowRight"], "frames": 60 },
    { "expect": [["player.x", ">", 2], ["mode", "==", "playing"]], "shot": "moved-right" }
  ]
}
```

Action chain for a game with enemies (shoot, HP drops, enemy removed, score rises):

```json
{
  "seed": 7,
  "steps": [
    { "frames": 10 },
    { "expect": [["enemies.length", "==", 1], ["enemies.0.hp", "==", 3], ["score", "==", 0]] },
    { "tap": "KeyJ", "frames": 20 },
    { "expect": [["enemies.0.hp", "==", 2]] },
    { "tap": "KeyJ", "frames": 20 },
    { "tap": "KeyJ", "frames": 20 },
    { "expect": [["enemies.length", "==", 0], ["score", "==", 10]], "shot": "enemy-cleared" }
  ]
}
```

Write one scenario per feature, named after it, and keep old ones: they are the regression suite.
Cover movement, win and lose transitions, score and health changes, boundaries, the start, pause
and restart flow, and each special feature.

## What Claude does with the results

1. Read the summary. On any `FAIL`, fix the first new console error first, then the first failed
   expectation. Change one variable at a time.
2. Open every new PNG in `tests/e2e/out/<scenario>/` with Read. Say in one sentence what is on
   screen: player, enemies, HUD values, anything clipped, blank or overlapping.
3. Compare each PNG with the `.json` saved beside it. A score of 10 in the state and 0 on the HUD is
   a bug even if every expectation passed.
4. A blank or black canvas is a failure, whatever the expectations say.
5. Report the command, the summary line, and the per-screenshot sentences. That is the evidence.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `waitForFunction` times out | No `?test=1` handling, or a JS error before hooks install | The console lines in the output name the error; fix it first |
| Black canvas only in headless | WebGL unavailable in headless Chromium on this machine | `HEADED=1 npm run verify`; or pass `args: ['--enable-unsafe-swiftshader']` to `launch()` to allow software WebGL on recent Chromium builds |
| Positions differ run to run | Real time or `Math.random()` inside rules | Route through `step(dt)` and `rng` (see the determinism notes in `game-test-hooks.md`) |
| Taps ignored | Input polled only as "held" | Use the buffered `pressed` set in `game-test-hooks.md` |
| Godot project | No browser to drive | Use the headless smoke test in `game-test-hooks.md` |
| Passes headless, broken on phones | DPR, touch input, memory or audio unlock | `DEVICE="Pixel 5"` pass, then a real mid-range Android phone |
| Port 4173 in use | Another preview server | Stop it, or set `GAME_URL` to the running server |
