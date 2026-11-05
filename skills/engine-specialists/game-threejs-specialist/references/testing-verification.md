# Testing and Verification for AI-Built 3D Web Games

The contract below follows the pattern popularized by OpenAI's published `develop-web-game` skill
(`render_game_to_text`, `advanceTime`, Playwright screenshots as the source of truth) and
Anthropic's Claude Code guidance to give the agent "something it can run that comes back pass or
fail". Everything here was run with `@playwright/test@1.64.1` (Chrome Headless Shell 156) against
a Vite 8.3.6 production build of a three r187 + Rapier 0.21 scene on 2026-11-05.

## 1. The test contract

```ts
// src/core/testHooks.ts (verified)
export interface TestHooks {
  advance(ms: number): void;
  snapshot(): Record<string, unknown>;
  pause(paused: boolean): void;
}

declare global {
  interface Window {
    render_game_to_text?: () => string;
    advanceTime?: (ms: number) => void;
    __game?: TestHooks;
  }
}

/** On in dev; in production only with ?test=1. Leaderboard games: gate on import.meta.env.MODE === 'test'. */
export function installTestHooks(hooks: TestHooks): void {
  const enabled = import.meta.env.DEV || new URLSearchParams(location.search).has('test');
  if (!enabled) return;
  window.__game = hooks;
  window.advanceTime = (ms) => hooks.advance(ms);
  window.render_game_to_text = () => JSON.stringify(hooks.snapshot());
}
```

What `snapshot()` returns: the state a player could see or that a test needs to assert, kept small:

```json
{ "tick": 120, "scene": "level1", "backend": "webgl2", "player": { "x": 3.2, "y": 0.5, "hp": 80 },
  "enemies": 4, "score": 150, "drawCalls": 37, "textures": 12 }
```

For competitive or leaderboard games, build a separate test bundle (`vite build --mode test`) and
gate on `import.meta.env.MODE === 'test'`, so production players cannot call `advanceTime`.

## 2. Determinism rules

1. **Start paused in test mode.** `loop.setPaused(new URLSearchParams(location.search).has('test'))`
   before `setAnimationLoop`. A first version paused *after* page load; real frames ran in
   between and screenshots differed run to run. Starting paused fixed it.
2. **Seed everything.** `?seed=N` feeds the PRNG used for spawns, loot and AI. No `Math.random()`
   in simulation code; `Math.random()` is fine for cosmetic particles.
3. **Fixed step only.** `advanceTime(ms)` runs `round(ms / fixedDt)` steps; never depend on frame
   timing in assertions.
4. **No wall-clock in gameplay.** Timers count steps (or accumulate `dt`), never `Date.now()`.
5. **Stable assets.** Wait for the loading manager to finish before the first snapshot; expose
   `loaded: true` in the snapshot.
6. **Reset between scenarios.** A fresh `page.goto()` per test, or a `__game.reset()` hook.

## 3. Playwright config (verified)

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests',
  timeout: 30_000,
  use: { baseURL: 'http://localhost:4173', trace: 'retain-on-failure' },
  webServer: {
    command: 'npm run build && npm run preview -- --port 4173 --strictPort',
    port: 4173,
    reuseExistingServer: !process.env.CI,
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

- Test the production build (`vite preview`), not the dev server: it is what players get, and it
  catches `base` path and asset-inlining mistakes.
- Headless Chromium rendered WebGL without extra flags in this setup. It exposes `navigator.gpu`
  but reports "No available adapters", so `WebGPURenderer` runs its WebGL 2 backend. CI therefore
  covers the fallback path; check real WebGPU manually on desktop Chrome/Safari and a phone.
- A WebKit project (`devices['iPhone 15']`) needs `npx playwright install webkit` plus system
  libraries; it emulates viewport and touch, not iOS Safari's GPU, memory or audio policy.
- Software rendering is slow; that is why assertions use `advanceTime`, not `waitForTimeout`.

## 4. Smoke spec (verified, three consecutive identical runs)

```ts
// tests/smoke.spec.ts
import { test, expect, type Page } from '@playwright/test';

interface Snapshot { tick: number; lowestY: number; drawCalls: number }

async function state(page: Page): Promise<Snapshot> {
  return JSON.parse(await page.evaluate(() => window.render_game_to_text!()));
}

test('boots, renders, and simulates deterministically', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));
  page.on('console', (m) => m.type() === 'error' && errors.push(m.text()));

  await page.goto('/?seed=42&test=1');
  await page.waitForFunction(() => typeof window.advanceTime === 'function');

  const before = await state(page);
  await page.evaluate(() => window.advanceTime!(2000)); // 120 fixed steps
  const after = await state(page);

  expect(after.tick - before.tick).toBe(120);
  expect(after.lowestY).toBeGreaterThan(-1); // nothing fell through the floor
  expect(after.drawCalls).toBeLessThan(200); // performance budget as a test
  await expect(page).toHaveScreenshot('boot-seed42.png', { maxDiffPixelRatio: 0.02 });
  expect(errors).toEqual([]);
});
```

Interaction pattern (input is sampled inside the fixed step, so press, then advance):

```ts
test('dash moves the player at least 3 units', async ({ page }) => {
  await page.goto('/?seed=7&test=1');
  await page.waitForFunction(() => typeof window.advanceTime === 'function');
  const x0 = JSON.parse(await page.evaluate(() => window.render_game_to_text!())).player.x;
  await page.keyboard.down('ShiftLeft');
  await page.evaluate(() => window.advanceTime!(200));
  await page.keyboard.up('ShiftLeft');
  const x1 = JSON.parse(await page.evaluate(() => window.render_game_to_text!())).player.x;
  expect(x1 - x0).toBeGreaterThanOrEqual(3);
});
```

Screenshot hygiene: baselines are per browser and OS (`boot-seed42-chromium-linux.png`); generate
them in the same environment as CI; update deliberately with `npx playwright test
--update-snapshots` and review the diff images in `test-results/` before committing.

## 5. The agent verification loop

After every meaningful change the agent runs, in order:

1. `npx tsc --noEmit` (types), 2. `npm run build` (bundle, asset paths),
3. `npx playwright test` (behavior + screenshot + zero console errors),
4. opens the newest screenshot or diff image and describes what it sees,
5. appends one line to `progress.md` (what changed, which test proves it, open TODOs).

Rules: fix the first new console error first; change one variable at a time when debugging; test
whole action chains (shoot -> enemy HP drops -> score increments), not single functions. A task is
not done until the check named in the prompt passes. `/gameforge:game-vibe-code` runs this loop
end to end.

## 6. Debug overlay (dev or `?debug`, verified)

```ts
import * as THREE from 'three';
import GUI from 'lil-gui';
import type RAPIER from '@dimforge/rapier3d-compat';

/** Live tuning bound to TUNING; "Copy JSON" lets you paste good values back into tuning.ts. */
export function createDebugPanel(tuning: { player: { moveSpeed: number; jumpImpulse: number } }) {
  const gui = new GUI({ title: 'Tuning' });
  gui.add(tuning.player, 'moveSpeed', 1, 20, 0.1);
  gui.add(tuning.player, 'jumpImpulse', 1, 20, 0.1);
  gui.add({ copy: () => navigator.clipboard.writeText(JSON.stringify(tuning, null, 2)) }, 'copy').name('Copy JSON');
  return gui;
}

/** Rapier collider wireframes; call the returned function once per rendered frame. */
export function createPhysicsDebug(scene: THREE.Scene, world: RAPIER.World) {
  const geo = new THREE.BufferGeometry();
  const lines = new THREE.LineSegments(geo, new THREE.LineBasicMaterial({ vertexColors: true }));
  lines.frustumCulled = false;
  scene.add(lines);
  return () => {
    const { vertices, colors } = world.debugRender();
    geo.setAttribute('position', new THREE.BufferAttribute(vertices, 3));
    geo.setAttribute('color', new THREE.BufferAttribute(colors, 4));
  };
}
```

Load debug tools with `if (params.has('debug')) { const { createDebugPanel } = await
import('./debug'); ... }` so they never reach the production bundle's critical path. Add
`stats-gl` and the r187 `Inspector` (WebGPU) to the same flag. Agents can build richer instruments
cheaply (AI-vs-AI balance runs, replay viewers); ask for them early.

## 7. CI (GitHub Actions sketch)

Use the current major versions of `actions/checkout`, `actions/setup-node` (Node 22) and
`actions/upload-artifact`; the steps that matter are:

```yaml
- run: npm ci
- run: npx playwright install --with-deps chromium
- run: npx tsc --noEmit && npm run build && npx playwright test
# on failure: upload test-results/ (diff images, traces) as an artifact
```

Vite 8 needs Node 20.19+ or 22.12+. For a full pipeline (caching, deploy previews, itch.io
upload), use `/gameforge:game-ci-pipeline`.
