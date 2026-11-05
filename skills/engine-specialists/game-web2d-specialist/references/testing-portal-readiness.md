# Testing and Portal Readiness for 2D Web Games

The Phaser setup below ran with `phaser@4.2.1`, `vite@8.3.6` and `@playwright/test@1.64.1`
(Chrome Headless Shell 156) on 2026-11-05: three consecutive runs passed with identical
screenshots. Stepping hooks for the other frameworks were type-checked against their current
versions. Portal limits come from the portals' own documentation as summarized in GameForge's
research brief (checked 2026-11-05); confirm current numbers with `game-web-publish`.

## 1. The test contract

Every game exposes, in dev and with `?test=1`:

- `window.render_game_to_text()`: compact JSON of what a player could see (scene, player x/y,
  grounded, HP, score, enemy states, wave).
- `window.advanceTime(ms)`: steps the game deterministically in 1/60 s increments.
- `?seed=N`: seeds all gameplay randomness (`Phaser.Math.RandomDataGenerator` with
  `seed: [String(N)]` in the game config, or your own PRNG).

## 2. Phaser hooks (verified)

```ts
// src/testHooks.ts
import type Phaser from 'phaser';

declare global {
  interface Window {
    render_game_to_text?: () => string;
    advanceTime?: (ms: number) => void;
  }
}

/** Dev, or ?test=1: freeze the real loop and step the game deterministically. */
export function installTestHooks(game: Phaser.Game, snapshot: () => Record<string, unknown>): void {
  const params = new URLSearchParams(location.search);
  if (!import.meta.env.DEV && !params.has('test')) return;
  const STEP = 1000 / 60;
  let t = 0;
  game.events.once('ready', () => {
    if (params.has('test')) game.loop.sleep(); // no wall-clock frames in test mode
  });
  window.advanceTime = (ms) => {
    for (let n = Math.round(ms / STEP); n > 0; n--) game.step((t += STEP), STEP);
  };
  window.render_game_to_text = () => JSON.stringify(snapshot());
}
```

```ts
// src/main.ts (after new Phaser.Game(...))
installTestHooks(game, () => {
  const s = game.scene.getScene('Game') as Game | null;
  return s?.player
    ? { scene: 'Game', x: Math.round(s.player.x), y: Math.round(s.player.y), onGround: s.player.body.blocked.down,
        score: game.registry.get('score') ?? 0 }
    : { scene: 'boot' };
});
```

`game.loop.sleep()` stops requestAnimationFrame; `game.step(time, delta)` runs one full frame
(scenes, Arcade's fixed step, rendering). Sleeping on `ready` means no real frames run between
page load and the first `advanceTime` call, which is what makes screenshots repeatable.

## 3. Other frameworks (type-checked)

```ts
import type { Application } from 'pixi.js';
import type { Engine } from 'excalibur';
import { setEngineManualStep, engineStep } from 'littlejsengine';
import type { KAPLAYCtx } from 'kaplay';

/** PixiJS: you own the fixed step, so expose it directly and render once. */
export function pixiHooks(app: Application, step: (dtMs: number) => void) {
  const STEP = 1000 / 60;
  app.ticker.stop();
  window.advanceTime = (ms) => { for (let n = Math.round(ms / STEP); n > 0; n--) step(STEP); app.render(); };
}

/** Excalibur: swap in the TestClock, then step it manually. */
export function excaliburHooks(game: Engine) {
  const clock = game.debug.useTestClock();
  window.advanceTime = (ms) => clock.run(Math.round(ms / (1000 / 60)), 1000 / 60);
}

/** LittleJS: call before engineInit; the engine then only advances on engineStep(frames). */
export function littlejsManual() {
  setEngineManualStep(true);
  window.advanceTime = (ms) => engineStep(Math.round(ms / (1000 / 60)));
}

/** Kaplay 3001: pause and step frames (frame dt is not guaranteed fixed: assert on ranges). */
export function kaplayHooks(k: KAPLAYCtx) {
  k.debug.paused = true;
  window.advanceTime = (ms) => { for (let n = Math.round(ms / (1000 / 60)); n > 0; n--) k.debug.stepFrame(); };
}
```

## 4. Playwright config and spec (verified)

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests',
  timeout: 60_000,
  use: { baseURL: 'http://localhost:4174', trace: 'retain-on-failure' },
  webServer: { command: 'npm run build && npm run preview -- --port 4174 --strictPort', port: 4174, reuseExistingServer: !process.env.CI },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

```ts
// tests/player.spec.ts
import { test, expect, type Page } from '@playwright/test';

interface Snap { scene: string; x: number; y: number; onGround: boolean; score: number }
const snap = async (page: Page): Promise<Snap> => JSON.parse(await page.evaluate(() => window.render_game_to_text!()));

test('player runs right and lands', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });

  await page.goto('/?test=1');
  await page.waitForFunction(() => typeof window.advanceTime === 'function');
  await page.evaluate(() => window.advanceTime!(100));  // Boot -> Game
  await page.waitForFunction(() => JSON.parse(window.render_game_to_text!()).scene === 'Game');
  await page.evaluate(() => window.advanceTime!(1000)); // fall and settle
  const start = await snap(page);
  expect(start.onGround).toBe(true);

  await page.keyboard.down('ArrowRight');
  await page.evaluate(() => window.advanceTime!(500));
  await page.keyboard.up('ArrowRight');
  const after = await snap(page);
  expect(after.x).toBeGreaterThan(start.x + 50);
  await expect(page).toHaveScreenshot('run-right.png', { maxDiffPixelRatio: 0.01 });
  expect(errors).toEqual([]);
});
```

- Test the production build through `vite preview`; it catches `base` path and asset mistakes.
- Headless Chromium rendered Phaser's WebGL renderer without extra flags in this setup.
- Mobile: add a project with `devices['Pixel 7']` (Chromium, touch, small viewport) for layout and
  touch-target checks; it does not emulate a phone's GPU or memory. WebKit projects need
  `npx playwright install webkit` and only approximate iOS Safari.
- Touch input: `page.touchscreen.tap(x, y)` with `hasTouch: true` in the project.

## 5. Agent verification loop

After each change: `npx tsc --noEmit` -> `npm run build` -> `npx playwright test` -> look at the
newest screenshot or diff -> one line in `progress.md`. Fix the first new console error first,
test whole chains (jump -> land on enemy -> enemy stunned -> score +10), and never mark a task done
without the passing check the prompt named. `/gameforge:game-vibe-code` runs this loop end to end.

Debug overlay in dev: Arcade `debug: true` behind `?debug`, a small HTML panel bound to `TUNING`
(sliders that write the live object, plus "copy JSON"), and an FPS readout from
`game.loop.actualFps`.

## 6. Portal readiness: what to measure and where the numbers come from

| Check | How | Limit / source |
|---|---|---|
| Initial download to first input | DevTools Network, cache disabled, throttled to Fast 4G | CrazyGames: <= 50 MB initial, **<= 20 MB for the mobile homepage**, <= 250 MB and <= 1,500 files total. YouTube Playables: initial < 30 MiB (SHOULD < 15), each file < 30 MiB, total < 250 MiB. Poki: no fixed cap on the current page, but players leave after ~10 s |
| Time to gameplay | Stopwatch from navigation to first input | Externally hosted CrazyGames games must reach gameplay within 20 s |
| External requests | Network tab filtered to third-party domains | Poki allows none |
| Chromebook-class performance | Chrome DevTools CPU 4x throttle + a real low-end device | CrazyGames disables games that are not smooth on 4 GB Chromebooks |
| iOS audio | Real iPhone: first tap starts audio; resume after tab switch | `AudioContext` must resume from a user gesture |
| Storage | Incognito and an iframe host | Poki requires incognito-safe storage; Playables caps saves at 3 MiB |
| Heap | DevTools Memory over 10 minutes | Playables caps the JS heap at 512 MB |
| Gameplay events | Portal SDK hooks fire on first input, pause on ads | Poki: `gameplayStart()` on first input; CrazyGames `gameplayStart` event |

Measured framework floors (Vite 8.3.6, minimal scene, gzip): Phaser 4.2.1 355 KB, PixiJS 8.22
171 KB emitted (71 KB entry), Excalibur 0.32 122 KB, Kaplay 3001 68 KB, LittleJS 1.29 52 KB.
Content, not code, usually blows the budget: audio (use Opus, mono SFX, short loops) and
oversized atlases.

The portal SDK integration, store pages, itch.io upload and Discord/Playables packaging belong to
`game-web-publish`; this skill makes sure the build is technically ready for them.
