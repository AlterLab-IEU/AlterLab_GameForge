# Web Game CI (Vite 8, Three.js/R3F, Phaser 4, PixiJS 8, Godot web exports)

Read this before writing a pipeline for a browser game. Versions verified on npm, November 2026:
Vite 8.3 (Rolldown-only; needs Node 20.19+ or 22.12+), `@playwright/test` 1.64, Wrangler 4.x,
`netlify-cli` 27.x.

## Pipeline shape

| Stage | PR | main | tag `v*` |
|---|---|---|---|
| Install (`npm ci`, cached) | yes | yes | yes |
| Typecheck + lint (`tsc --noEmit`, ESLint) | yes | yes | yes |
| Unit tests (Vitest) | yes | yes | yes |
| Production build (`vite build`) | yes | yes | yes |
| Budget + secret scan on `dist/` | yes | yes | yes |
| Playwright smoke test against `vite preview` | yes | yes | yes |
| Preview deploy (Cloudflare/Netlify branch URL) | yes | -- | -- |
| Deploy itch.io / production host | -- | staging channel | release channel |

Static hosting survives longest: in a 2026 analysis of Vibe Jam entries, games that depended on a
backend went offline fastest (secondary source). Keep the deploy target static unless the design
needs a server.

## Workflow

```yaml
name: web-ci
on:
  pull_request:
  push:
    branches: [main]
    tags: ["v*"]
permissions:
  contents: read
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build-test:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true }
      - uses: actions/setup-node@v7
        with: { node-version: 24, cache: npm }
      - run: npm ci
      - run: npx tsc --noEmit
      - run: npm run lint --if-present
      - run: npm run test --if-present -- --run      # Vitest in CI mode
      - run: npm run build                            # vite build -> dist/
      - name: Budget and secret scan
        run: |
          bytes=$(du -sb dist | cut -f1); files=$(find dist -type f | wc -l)
          echo "dist: $((bytes/1048576)) MiB, $files files"
          test "$bytes" -le $((50*1048576)) || { echo "::error::dist over 50 MiB budget"; exit 1; }
          test "$files" -le 1500 || { echo "::error::over 1500 files"; exit 1; }
          if grep -rEl 'sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|-----BEGIN [A-Z ]*PRIVATE KEY' dist; then
            echo "::error::possible secret in dist/"; exit 1; fi
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test
      - uses: actions/upload-artifact@v7
        if: always()
        with:
          name: playwright-report
          path: playwright-report
          retention-days: 7
      - uses: actions/upload-artifact@v7
        with:
          name: web-build
          path: dist
          retention-days: ${{ startsWith(github.ref, 'refs/tags/') && 30 || 7 }}
          if-no-files-found: error
```

Set the budget numbers from the target you ship to, not from this file: CrazyGames documents an
initial download of 50 MB or less (20 MB or less for its mobile homepage) and 250 MB / 1,500 files
total; YouTube Playables documents an initial bundle under 30 MiB (15 MiB preferred) and 250 MiB
total; Poki asks for a small download and no external requests. Re-check portal docs before launch
with `game-web-publish`.

## Playwright smoke test

`playwright.config.ts`:

```ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests/smoke',
  timeout: 60_000,
  use: {
    baseURL: 'http://localhost:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    launchOptions: {
      // GPU-less CI runners: Chromium no longer falls back to software WebGL automatically.
      // Opt in to SwiftShader explicitly (per Chromium's SwiftShader docs).
      args: ['--use-gl=angle', '--use-angle=swiftshader-webgl', '--enable-unsafe-swiftshader'],
    },
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'npm run preview -- --port 4173 --strictPort',
    url: 'http://localhost:4173',
    reuseExistingServer: !process.env.CI,
  },
});
```

`tests/smoke/boot.spec.ts`:

```ts
import { test, expect } from '@playwright/test';

test('boots, accepts input, no console errors', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });

  await page.goto('/?test=1');                       // test hooks only behind a flag
  const canvas = page.locator('canvas').first();
  await expect(canvas).toBeVisible({ timeout: 20_000 });

  await canvas.click();                              // user gesture: unlocks audio, starts play
  await page.keyboard.press('Space');
  await page.waitForTimeout(1000);

  // Optional deterministic hooks exposed only when ?test=1 (strip from production builds):
  const state = await page.evaluate(() => (window as any).render_game_to_text?.() ?? null);
  if (state) expect(JSON.parse(state).scene).toBe('play');

  await expect(page).toHaveScreenshot('play.png', { maxDiffPixelRatio: 0.05 });
  expect(errors).toEqual([]);
});
```

Notes:
- **WebGPU will not run on hosted runners.** No GPU means no WebGPU adapter; the smoke test
  exercises your WebGL 2 fallback, which three.js `WebGPURenderer` and PixiJS provide. Keep that path
  working; real players on Firefox for Linux/Android and Intel Macs need it too.
- **Screenshot baselines** must be generated on the same OS and browser as CI (generate them in a
  CI run, commit, then compare). Software rendering differs from local GPUs.
- **Deterministic hooks** (`render_game_to_text`, `advanceTime(ms)`) make agent-driven and CI tests
  reliable; expose them only behind a test flag so production builds do not hand players a state
  editor on `window`.
- **Godot web exports** use the same smoke test against the exported folder served by any static
  server; threaded exports need COOP/COEP headers on that server too.

## Deploy recipes

### itch.io with butler (HTML5 channel)

```yaml
  deploy-itch:
    needs: build-test
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-24.04
    environment: itch           # protect with required reviewers if you like
    steps:
      - uses: actions/download-artifact@v8
        with: { name: web-build, path: dist }
      - name: Install butler
        run: |
          curl -sSL -o butler.zip https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default
          unzip -q butler.zip && chmod +x butler && ./butler -V
      - name: Push
        env: { BUTLER_API_KEY: "${{ secrets.BUTLER_API_KEY }}" }
        run: ./butler push dist "${{ vars.ITCH_USER }}/${{ vars.ITCH_GAME }}:html5" --userversion "${{ github.ref_name }}" --if-changed
```

`index.html` must sit at the root of the pushed folder. butler auto-tags channels containing `win`,
`linux`, `mac` or `android`; marking a channel "playable in browser" is done once on the itch.io
edit page. Enable itch's SharedArrayBuffer option only if your build needs threads.

### Cloudflare Pages via Wrangler

```yaml
  deploy-cloudflare:
    needs: build-test
    runs-on: ubuntu-24.04
    permissions: { contents: read, deployments: write }
    steps:
      - uses: actions/download-artifact@v8
        with: { name: web-build, path: dist }
      - uses: cloudflare/wrangler-action@v4
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          wranglerVersion: "4"
          command: pages deploy dist --project-name=ember-drift --branch=${{ github.head_ref || github.ref_name }}
```

Non-production branches get preview URLs; deploys from the project's production branch go live.
Scope the API token to Pages edit on one account. Cloudflare Workers static assets (`wrangler
deploy` with an `assets` directory) are the alternative when you also need an edge function, for
example to proxy an AI NPC's model calls so no key ships to the client.

### Netlify via CLI

```yaml
      - run: npx netlify-cli@27 deploy --dir=dist ${{ startsWith(github.ref, 'refs/tags/v') && '--prod' || format('--alias=pr-{0}', github.event.number) }}
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

Without `--prod`, Netlify creates a draft deploy at a unique URL, which suits PR previews.

### Cross-origin isolation headers (threads, SharedArrayBuffer)

Cloudflare Pages and Netlify both read a `_headers` file from the published folder; put it in
`public/` so Vite copies it into `dist/`:

```
/*
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
```

GitHub Pages cannot set custom headers; threaded Godot exports there need the service-worker
workaround or a different host.

## Web-specific secrets rules

- Anything prefixed `VITE_` is compiled into the client bundle. CI secrets used at build time must
  never be exposed through `VITE_` variables or `define`.
- Deploy tokens (Cloudflare, Netlify, butler) are used only in deploy jobs, never in the build job
  that runs PR code from forks.
- The `dist/` grep above is a backstop, not a scanner. Add a real secret scanner for the repository
  (see `pipeline-hardening.md`).
