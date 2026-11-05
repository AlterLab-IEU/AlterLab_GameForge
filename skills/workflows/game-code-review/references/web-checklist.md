# Web Game Review Checklist (Three.js, R3F, Phaser, PixiJS, Kaplay, Vite)

Version anchors (npm registry, November 2026): **three r187** (`three@0.187.0`, WebGL default,
`WebGPURenderer` opt-in with automatic WebGL 2 fallback), **@react-three/fiber 9.8** (v10 is alpha
only), **Phaser 4.2.1**, **PixiJS 8.22**, **Kaplay 3001** (v4000 still alpha), **Vite 8**
(Rolldown-only, Node 20.19+ or 22.12+). Always confirm the installed version in
`node_modules/<pkg>/package.json`; lockfiles beat `package.json` ranges.

## 1. Patterns to stop (A1)

### three.js

| Stop | Use | Since |
|---|---|---|
| `three.min.js` from a CDN, `require('three')` | ESM `import * as THREE from 'three'`, or an import map pinned to `three@0.187.0`; r187 removed `.min.js` builds and the CJS entry is a deprecation stub | r187 |
| `new THREE.Clock()` | `THREE.Timer` | r183 |
| `PostProcessing` (WebGPU) | `RenderPipeline` | r183 |
| `renderAsync()`, `computeAsync()`, `clearAsync()`, `waitForGPU()` | `await renderer.init()` (or `setAnimationLoop`), then `render()` / `compute()` | r181 |
| `PCFSoftShadowMap` | `PCFShadowMap` (now soft on WebGL; removed from WebGPU in r186) | r182 |
| `WebGLCubeRenderTarget` with WebGPU | `CubeRenderTarget` | r183 |
| TSL `positionLocal` for skinned meshes | `positionGeometry` | r185 |
| `colorBufferType` | `outputBufferType` | r182 |
| `Source` | `TextureSource` | r186 |
| `KTX2Loader.detectSupportAsync()` | `detectSupport(renderer)` after `init()` | r181 |
| `PI2`, `directionToColor` | `TWO_PI`, `packNormalToRGB` | r181, r185 |
| `TiledLighting` | `ClusteredLighting` | r185 |
| Custom `Object3D` subclasses with `dispose()` not calling `super.dispose()` | call `super.dispose()` | r186 |

### pmndrs / R3F

- pmndrs `postprocessing`, `@react-three/postprocessing` or the legacy `EffectComposer` with
  `WebGPURenderer`: WebGL-only. Use TSL nodes with `RenderPipeline` on WebGPU.
- R3F v10 alpha code in a v9 project, or v10 alpha in a shipping build. On v10: `state.clock`,
  `onUpdate`, `<color attach="background">` and `shadows` as a Canvas prop are gone or deprecated.
- WebGPU in R3F v9: requires an async `gl` factory that awaits `renderer.init()` and `extend()` with
  the `three/webgpu` namespace; flag sync construction.

### Phaser 3 code in a Phaser 4 project

| Stop | Use |
|---|---|
| `setPipeline('Light2D')` | `setLighting(true)` |
| `preFX` / `postFX` | Filters |
| `BitmapMask` | Mask filter |
| `setTintFill` | `setTintMode` |
| `Geom.Point` | `Vector2` |
| `Mesh`, `Plane`, `Camera3D` | removed |
| Canvas renderer for new work | WebGL (Canvas is deprecated) |
| Raw `gl` calls in render code | `Extern` / RenderNodes |

Also note behavior changes: `roundPixels` defaults to `false`; `Math.TAU` now equals 2pi; compressed
textures must be re-exported for GL Y-up conventions.

### PixiJS 7 code in PixiJS 8

- `new Application({ ... })` used synchronously -> `const app = new Application(); await app.init({ ... })`.
- `app.view` -> `app.canvas`.
- Renderer preference: WebGL is the default; WebGPU only with `preference: 'webgpu'`.

### Libraries to replace

| Stop | Use |
|---|---|
| `colyseus.js` (frozen 0.16) | `@colyseus/sdk`; Colyseus 0.18 replaced `client.id` with `client.sessionId` |
| `kaboom` (frozen 2023) | `kaplay` |
| `cannon-es` (no releases since 2022) | Rapier (`@dimforge/rapier3d-compat`, call `await RAPIER.init()`) or Jolt |
| Theatre.js for new work | not recommended (public repo inactive since 2024) |
| Howler.js for new work | works, but in maintenance mode; Web Audio directly or the engine's audio |

## 2. Security and trust (A6, A7)

- **`VITE_` variables are public.** Vite inlines every `VITE_`-prefixed variable into the client
  bundle. Any secret there is leaked. Server keys belong in a server, edge function, or CI secret.
- **LLM, TTS or image-generation keys in the browser.** AI NPCs that call model APIs directly from
  client code expose the key and let anyone spend your quota. Proxy through a server with rate
  limits and the guardrails Steam requires for live-generated content.
- **Game state on `window`.** `window.game = game`, `window.player`, or module-level state reachable
  from DevTools lets players set scores and currency. Fine for local debugging; never trusted by a
  server.
- **Leaderboards and rewards.** Scores posted as a number with no server validation (A6).
- **XSS through player content.** `innerHTML` with player names, chat or level titles; use
  `textContent`.
- **`postMessage` without origin checks.** Web games often run inside portal iframes or Discord
  Activities; validate `event.origin` and message shape.
- **Committed build output.** `dist/` in git, or source maps with secrets uploaded publicly.

## 3. Runtime and platform (G-checks)

- **Loop timing.** `requestAnimationFrame` or `setAnimationLoop` deltas used directly for physics
  (G4); high-refresh displays run the loop at 120-240 Hz.
- **Per-frame allocation.** `new THREE.Vector3()` in `useFrame` or the render loop; inline objects in
  R3F JSX props that re-create every render (G2).
- **Disposal.** Geometries, materials, textures and render targets disposed on scene change; WebGL
  context loss handled (`webglcontextlost` listener) rather than crashing (G5).
- **Fallbacks.** Code that requires WebGPU (`navigator.gpu`) without a WebGL 2 path; you still need
  one for Firefox on Linux, Intel Macs and Android, and for GPU-less CI runners.
- **Device pixel ratio.** Uncapped `setPixelRatio(window.devicePixelRatio)`; cap at about 1.5-2 on
  mobile (rule of thumb).
- **Audio unlock.** `AudioContext` created or resumed outside a user gesture; iOS Safari and Firefox
  block it until interaction.
- **Storage.** `localStorage` access not wrapped in try/catch (throws in some private modes and
  portal sandboxes); save data without a version field or migration.
- **Determinism.** `Math.random()` in simulation code that needs replays or lockstep;
  `Math.sin`/`Math.cos` differences between browser engines desync lockstep games.
- **Input.** `event.keyCode` (deprecated) instead of `event.code`; no touch path for mobile web;
  Pointer Lock assumed on iOS Safari (not available).
- **Godot web exports.** C# cannot export to web; threaded exports need `COOP: same-origin` and
  `COEP: require-corp` headers (or the PWA workaround).

## 4. Bundle and dependency hygiene (A3, A5)

- New dependencies checked in `package.json` and the lockfile: real publisher, maintained, pinned,
  no unexpected `postinstall` script.
- Two libraries doing one job (two tween libraries, two state stores, two physics engines) (A4).
- Debug panels (`lil-gui`, `leva`, `stats-gl`) shipped enabled in production builds.
- Large assets imported into the JS bundle instead of `public/` with compression (KTX2, Meshopt).

## 5. Quick verification commands for the report

```
npx tsc --noEmit                 # type errors surface many hallucinated APIs
npm run build                    # Vite 8 production build
grep -rE "sk-|AKIA|AIza|ghp_" dist/   # secret scan of the built bundle
npx playwright test              # smoke test, if the project has one
```
