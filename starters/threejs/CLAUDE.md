# [YOUR GAME NAME] -- Three.js Web Game

Project instructions for Claude Code. Copy this file to your game's root as `CLAUDE.md` (or
append it to an existing one) and replace the `[BRACKETED]` placeholders. Versions below were
current and verified together on 2026-11-05; change them only on purpose.

- **Game**: [NAME] -- [ONE SENTENCE: what the player does and why it is fun]
- **Targets**: desktop + mobile browsers | **Distribution**: [itch.io / CrazyGames / Poki / own domain]
- **Engine id for GameForge**: `threejs` (or `r3f` if you use React Three Fiber)

## Commands (a task is not done until these pass)

```bash
npm run dev            # Vite dev server
npx tsc --noEmit       # type-check
npm run build          # tsc --noEmit && vite build  -> dist/
npm run preview        # serve dist/ on :4173 (what players get)
npm test               # Playwright: builds, previews, runs tests/*.spec.ts
npx playwright test --update-snapshots   # only when a visual change is intended; review diffs first
npm run assets         # your gltf-transform script: assets-src/ -> public/models/
```

`package.json` scripts: `"dev": "vite"`, `"build": "tsc --noEmit && vite build"`,
`"preview": "vite preview"`, `"test": "playwright test"`. Node 20.19+ or 22.12+ (Vite 8).

## Stack (pinned with --save-exact; do not upgrade without asking)

| Package | Version | Note |
|---|---|---|
| `three` / `@types/three` | 0.187.0 (r187) | ESM only. `WebGLRenderer` by default |
| `@dimforge/rapier3d-compat` | 0.21.0 | Physics; lazy-load it if the menu does not need it |
| `vite` | 8.3.6 | Rolldown bundler |
| `typescript` | 7.0.2 | `strict: true`, `noUncheckedIndexedAccess: true` |
| `@playwright/test` | 1.64.1 | Verification loop |
| `@gltf-transform/cli` | 4.5.1 | Asset pipeline; KTX2 needs KTX-Software `ktx` 4.4+ on PATH |
| `stats-gl` / `lil-gui` | 4.2.3 / 0.21.0 | Dev-only overlays |
| R3F only: `@react-three/fiber` / `drei` / `@react-three/rapier` | 9.8.2 / 10.7.9 / 2.2.0 | With `react` 19.3.1. Not the v10 alpha |

## Folder layout

```
index.html                 # <div id="app">, <div id="ui"> overlay
vite.config.ts             # base: './', build.assetsInlineLimit: 0
src/
  main.ts                  # boot only: renderer, loop, first scene
  core/                    # loop.ts, tuning.ts, rng.ts, input.ts, audio.ts, assets.ts, testHooks.ts
  game/                    # systems/, entities/, levels/
  render/                  # materials, post-processing, camera rigs
  ui/                      # HTML/CSS HUD and menus
public/                    # optimized runtime assets: models/, textures/, audio/, basis/
assets-src/                # source files before optimization (Git LFS for large binaries)
tests/                     # Playwright specs and screenshot baselines
docs/architecture/         # decision records
production/session-state/  # active.md: current focus and next steps (GameForge)
```

Never edit `dist/` or `node_modules/` (GameForge's hooks block it); change sources and rebuild.

## Coding rules

**Imports.** `import * as THREE from 'three'`; addons from `three/addons/...`; WebGPU from
`three/webgpu`; TSL from `three/tsl`. Never `three.min.js`, `require('three')` or `THREE.OrbitControls`.

**Frame-rate independence.**
- `THREE.Timer` (not `Clock`): `timer.connect(document)`, `timer.update(t)`, `getDelta()`.
- Simulation and physics run in fixed 1/60 s steps from an accumulator capped at 0.25 s; rendering
  interpolates between the last two steps. Nothing gameplay-related runs in the render callback.
- Timers count steps or accumulate `dt`; never `Date.now()` for gameplay.
- Drive the frame with `renderer.setAnimationLoop(...)`.

**Data-driven tuning.** Every gameplay number (speeds, damage, cooldowns, spawn rates, camera
feel) lives in `src/core/tuning.ts`. Systems import it. Balance commits touch only that file.

**Randomness.** All gameplay randomness goes through the seeded RNG in `src/core/rng.ts`
(`?seed=N`). `Math.random()` is allowed for cosmetic effects only.

**Rendering.**
- `WebGLRenderer` unless a decision record says `WebGPURenderer` (for TSL, compute or the
  `RenderPipeline` post stack). If WebGPU: `await renderer.init()`, keep the WebGL 2 fallback
  working, and test it with `?webgl`.
- Pixel ratio: `Math.min(devicePixelRatio, 2)`, 1.5 on touch devices.
- Shadows: `PCFShadowMap` (soft since r182); at most one shadow-casting light on mobile.
- Post-processing: `EffectComposer` on WebGL; `RenderPipeline` + `three/addons/tsl/display/*`
  on WebGPU. pmndrs `postprocessing` is WebGL-only.

**Memory.** Dispose geometry, materials, textures and render targets on level unload;
`renderer.info.memory` must return to its baseline. No allocations in the step or render loop:
reuse scratch vectors.

**Entities.** Plain classes and a `systems/` folder until entity count demands an ECS (koota
0.6.6 or bitECS 0.4.0). The Three.js object is a view of simulation state, never the source of truth.

**Input and UI.** Poll input once per fixed step from event-fed state; use `KeyboardEvent.code`.
iPhone has no Pointer Lock and no Fullscreen API: provide touch-drag look and an on-screen stick.
HUD and menus are HTML/CSS in `#ui`, not WebGL text.

**Audio.** One `AudioContext`, resumed on the first pointer or key event; pause on
`visibilitychange`. Ship `.webm` (Opus) with an `.mp3` fallback.

## Asset rules

- Sources go in `assets-src/`; only optimized files go in `public/`. Never commit raw generator
  or marketplace output to `public/`.
- Static props and levels: `npx gltf-transform optimize in.glb out.glb --texture-compress webp`.
- Skinned, animated, or looked up by node name:
  `--texture-compress ktx2 --flatten false --join false --palette false --simplify false`
  (the defaults merge and rename nodes, which silently breaks `getObjectByName`).
- Geometry compression: Meshopt (the default). Textures: <= 2048 px (1024 on mobile), KTX2 for
  anything large; WebP and PNG decode to full size in GPU memory.
- Copy `node_modules/three/examples/jsm/libs/basis/` to `public/basis/` for `KTX2Loader`.
- Files >= 20 MB go through Git LFS (GameForge's commit hook blocks them otherwise).
- AI-generated assets: record tool, date, prompt and license in `docs/asset-log.md` (run
  `/gameforge:game-ai-assets`). No ripped or decompiled assets from existing games.
- Everything must load from this origin: no runtime CDN requests (portals forbid them).

## Patterns to reject in any diff

`three.min.js` script tags, `new THREE.Clock()`, `PostProcessing` (now `RenderPipeline`),
`renderAsync()` / `computeAsync()` / `waitForGPU()`, `PCFSoftShadowMap`,
`KTX2Loader.detectSupportAsync()`, `colorBufferType`, GLSL `ShaderMaterial` with
`WebGPURenderer`, `EffectComposer` with `WebGPURenderer`, `cannon-es`, `colyseus.js` (use
`@colyseus/sdk`), bitECS 0.3 `defineQuery`, R3F v10 alpha APIs in a 9.x project, `setState`
inside `useFrame`, uncapped `devicePixelRatio`, `Math.random()` in simulation.

Known-harmless console warnings (do not "fix" by downgrading): R3F 9.8 prints `THREE.Clock: This
module has been deprecated`; `@react-three/rapier` 2.2 prints `using deprecated parameters for the
initialization function`; browsers without WebGPU print `running under WebGL2 backend`.

## Verification loop (for AI agents)

1. Read `package.json` before writing code; write for the installed versions.
2. One feature or fix per change. Name the check it must pass before starting.
3. After each change: `npx tsc --noEmit` -> `npm run build` -> `npm test` -> open the newest
   screenshot in `test-results/` and describe what it shows -> one line in `progress.md`.
4. Test contract (dev, or `?test=1` in production builds):
   - `window.render_game_to_text()` returns JSON of visible state (scene, player, score, entity
     counts, `drawCalls`, `backend`).
   - `window.advanceTime(ms)` steps the fixed-step simulation deterministically.
   - `?seed=N` seeds randomness; in test mode the loop starts paused.
   - `?debug` loads the tuning panel and stats; `?webgl` forces the WebGPU fallback path.
5. A Playwright test fails on any console error. Fix the first new error first.
6. Before a milestone: play the production build on a real mid-range Android phone and an iPhone.
7. Split any file that passes ~500 lines before adding features to it.

## Commits

Format: `type(scope): summary` in the imperative, under 100 characters. Matches GameForge's
`"commit_convention": "conventional"` in `.gameforge/project.json`.

| Type | Use |
|---|---|
| `feat` | New mechanic, system or feature |
| `fix` | Bug fix |
| `balance` | Tuning values only (`src/core/tuning.ts`) |
| `art` / `audio` | Visual or sound assets |
| `design` / `level` | Design docs; level layout or content |
| `ui` | HUD, menus, overlays |
| `perf` | Performance work (state the measured gain) |
| `refactor` / `test` | Restructure without behavior change; tests |
| `chore` / `docs` | Tooling, dependencies, CI; documentation |

Examples: `feat(player): add air dash`, `balance(enemies): lower drone HP from 40 to 32`,
`perf(render): instance rocks, 412 -> 38 draw calls`, `fix(audio): resume context after ad break`.

## GameForge skills

Run `/gameforge:game-start` once to create `.gameforge/project.json` (engine `threejs` or `r3f`).

| I need to... | Run |
|---|---|
| Three.js, R3F, WebGPU, assets, performance help | `/gameforge:game-threejs-specialist` |
| Build features fast with an agent: prompt, play, verify, commit | `/gameforge:game-vibe-code` |
| Generate or clean up AI models, textures, audio (with provenance) | `/gameforge:game-ai-assets` |
| Multiplayer: rooms, netcode, server authority | `/gameforge:game-multiplayer` |
| Ship to itch.io, portals, Discord, YouTube Playables, PWA, desktop | `/gameforge:game-web-publish` |
| Architecture or engine decisions | `/gameforge:game-technical-director` |
| Mechanics, systems, balance | `/gameforge:game-designer`, `/gameforge:game-balance-check` |
| Review code before merging | `/gameforge:game-code-review` |
| Test strategy and bug triage | `/gameforge:game-qa-lead` |
| Automated builds and deploys | `/gameforge:game-ci-pipeline` |
| Playtest and feedback | `/gameforge:game-playtest` |
| 48-72 hour jam plan | `/gameforge:game-jam-mode` |
| Not sure where to start | `/gameforge:game-help` |
