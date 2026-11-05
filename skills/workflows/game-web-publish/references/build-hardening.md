# Build Hardening for Browser Games

Facts dated 2026-11-05. Sources: Vite build guide (vite.dev), Godot 4.7 "Exporting for the Web",
CrazyGames technical requirements, Poki requirements, YouTube Playables stability requirements,
MDN autoplay guide and browser-compat-data 8.1.8. Numbers marked "rule of thumb" are judgment,
not platform rules.

## 1. Vite 8 production config

Vite 8.0 shipped 2026-03-12 with Rolldown as its only bundler; it needs Node 20.19+ or 22.12+.
The default build target is Baseline "Widely Available" for that major: Chrome/Edge 111+,
Firefox 114+, Safari 16.4+. Rolldown options live under `build.rolldownOptions`.

```ts
// vite.config.ts
import { defineConfig } from 'vite';

export default defineConfig(({ mode }) => ({
  // Relative base: itch.io, portals and Discord serve from a subdirectory or proxy.
  base: './',
  build: {
    outDir: `dist/${mode}`,          // one folder per target: dist/itch, dist/crazygames ...
    emptyOutDir: true,
    sourcemap: mode === 'staging',   // never publish maps on public channels
    assetsInlineLimit: 4096,         // Vite default; raise only for many tiny icons
    chunkSizeWarningLimit: 1500,     // games ship big chunks; keep the warning meaningful
  },
}));
```

`package.json` scripts, one per target:

```json
{
  "scripts": {
    "dev": "vite",
    "build:itch": "vite build --mode itch",
    "build:crazygames": "vite build --mode crazygames",
    "build:poki": "vite build --mode poki",
    "build:playables": "vite build --mode playables",
    "build:web": "vite build --mode web",
    "preview": "vite preview --outDir dist/web"
  }
}
```

Each mode loads `.env.<mode>`, for example `.env.crazygames` containing `VITE_PLATFORM=crazygames`.
Read it as `import.meta.env.VITE_PLATFORM` and select the adapter (see `portals.md`). Use
`import.meta.env.BASE_URL` exactly as written for runtime asset URLs; computed access such as
`import.meta.env['BASE_URL']` is not replaced.

Dynamic `import()` of the adapter keeps other platforms' SDK code out of the bundle:

```ts
// src/platform/index.ts
import type { Platform } from './types';

export async function loadPlatform(): Promise<Platform> {
  switch (import.meta.env.VITE_PLATFORM) {
    case 'crazygames': return (await import('./crazygames')).default;
    case 'poki':       return (await import('./poki')).default;
    case 'playables':  return (await import('./playables')).default;
    default:           return (await import('./web')).default;
  }
}
```

## 2. Measuring the build

Run after every build; paste the output into the build report.

```bash
npm run build:crazygames
du -sh dist/crazygames                 # total size
ls -lS dist/crazygames/assets | head -20   # largest files first
ls -R dist/crazygames | wc -l          # rough file count (counts directory headers too)
```

Initial download is what loads before the first interaction (CrazyGames measures it up to the
`gameplayStart` event; Playables up to `gameReady`). Find it in the browser: DevTools > Network,
disable cache, reload, interact once, read the transferred total. Record both the transferred
(compressed) and resource (uncompressed) totals.

## 3. Budgets

| Item | Hard limit | Comfortable target |
|---|---|---|
| Initial download | CrazyGames ≤50 MB; ≤20 MB for its mobile homepage. Playables <30 MiB | ≤15 MB (rule of thumb; Playables SHOULD <15 MiB) |
| Total build | itch.io ≤500 MB extracted; CrazyGames ≤250 MB; Playables <250 MiB | As small as content allows |
| Files | itch.io ≤1,000; CrazyGames ≤1,500; Playables ≤8,000; Cloudflare Pages Free 20,000 | Pack sprites into atlases, audio into fewer files |
| Single file | itch.io ≤200 MB; Playables <30 MiB (SHOULD <512 KiB); Cloudflare Pages 25 MiB | Split anything above 25 MiB |
| JS heap | Playables ≤512 MB peak | Profile on a 4 GB device |
| Load to interactive | Poki: players leave after ~10 s; Playables SHOULD ≤5 s | ≤5 s on mid-range phone |

How to get under budget, in order of payoff:
1. **Lazy-load everything after the first level.** Load menu + level 1 up front; stream the rest
   with dynamic `import()` and `fetch` during play.
2. **Compress textures and meshes.** glTF through `gltf-transform optimize` (Meshopt by default,
   texture size 2048 by default); KTX2 for GPU-compressed textures. For skinned or animated
   models, pass `--flatten false --join false`. Details belong to `game-threejs-specialist`.
3. **Audio**: Opus in WebM or Ogg with an MP3/AAC fallback for older Safari; mono for SFX;
   music streamed, not decoded up front.
4. **Fonts**: subset to the glyphs you use; bundle locally (Poki blocks external font CDNs).
5. **Dependencies**: check what the bundle actually includes. A physics WASM (Rapier 0.21 is about
   3 MB) or a second rendering library can dominate a small game.

## 4. Engine exports

### Godot 4.x (4.7 docs)
- Web export uses the **Compatibility renderer (WebGL 2)**; Forward+ and Mobile are not available.
  "Godot currently does not support WebGPU."
- **C# projects cannot be exported to the web** in Godot 4.
- **Single-threaded export is the default since 4.3** and the preferred mode. Enabling Thread
  Support requires `Cross-Origin-Opener-Policy: same-origin` and
  `Cross-Origin-Embedder-Policy: require-corp`, or the PWA option that ensures these headers via a
  service worker when you cannot configure the server.
- GDExtension on the web needs Extension Support plus cross-origin isolation.
- Audio: "Sample" playback (default) has low latency but no AudioEffects; "Stream" supports all
  audio features at higher latency.
- Serve `.wasm` as `application/wasm` and compress `.wasm` and `.pck`. Use a size-optimized export
  template with unused modules disabled when the engine payload dominates.

### Unity 6 WebGL / Web
- Publishing Settings: Compression Format Brotli (smallest) or Gzip; enable **Decompression
  Fallback** when the host cannot set `Content-Encoding` headers.
- Unity 6.6: WebGPU is opt-in (disable Auto Graphics API, put WebGPU first, keep WebGL 2 as
  fallback). Treat WebGPU on the web as a progressive enhancement.
- CrazyGames disables Unity games on iOS by default because of memory crashes; plan for desktop
  and Android first, and follow the portal's Unity optimization guide.
- Strip engine code (managed stripping level High), and test IL2CPP builds early: build times are
  long, so CI helps (`game-ci-pipeline`).

### Three.js / R3F, Phaser, PixiJS
- Ship the ESM build through Vite; never a CDN `three.min.js` (removed in r187).
- WebGL renderer by default; WebGPU only when you need it and always with a WebGL 2 fallback.
- Engine-level performance work routes to `game-threejs-specialist` or `game-web2d-specialist`.

## 5. Headers

Two jobs: caching and (optionally) cross-origin isolation.

| File | Header |
|---|---|
| Hashed assets (`assets/*-[hash].*`) | `Cache-Control: public, max-age=31536000, immutable` |
| `index.html`, unhashed loaders, service worker | `Cache-Control: no-cache` |
| `.wasm` | `Content-Type: application/wasm` |
| Threaded builds only | `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp` |

Host-specific files are in `hosting-and-pwa.md`. Verify after deploy:
- DevTools > Network > select `index.html` > Response Headers.
- Console: `self.crossOriginIsolated` returns `true` only when isolation works.
- Console: `typeof SharedArrayBuffer` is `"function"` in isolated contexts.

Pitfalls with `require-corp`:
- Every cross-origin subresource needs CORS or `Cross-Origin-Resource-Policy`. Third-party ad or
  analytics scripts usually do not, and break silently.
- Portals embed you in their iframe; whether their page is isolated is outside your control. Ship
  single-threaded to portals.
- itch.io offers a SharedArrayBuffer option on the HTML5 embed settings (reported by secondary
  sources; confirm on your Edit page). Test the uploaded build, not localhost.

## 6. Runtime hardening snippets

### Audio unlock (iOS and Firefox)
iOS puts the `AudioContext` into an "interrupted" state on interruption or backgrounding;
CrazyGames notes that a visibility listener alone is not enough. Resume inside a gesture:

```ts
const ctx = new AudioContext();
function unlockAudio() {
  if (ctx.state !== 'running') void ctx.resume();
}
for (const ev of ['pointerdown', 'touchend', 'keydown'] as const) {
  window.addEventListener(ev, unlockAudio, { passive: true });
}
document.addEventListener('visibilitychange', () => {
  if (document.hidden) void ctx.suspend();   // resume happens on the next gesture
});
```

### Storage that never crashes the game

```ts
export const store = {
  get(key: string): string | null {
    try { return window.localStorage.getItem(key); } catch { return null; }
  },
  set(key: string, value: string): void {
    try { window.localStorage.setItem(key, value); } catch { /* private mode or quota */ }
  },
};
```

Route saves through the platform adapter so Playables (`ytgame.game.saveData`, <3 MiB) and
CrazyGames (Data module) use their own storage.

### Keep the page from scrolling (Poki requirement, good everywhere)

```ts
const blocked = new Set(['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' ']);
window.addEventListener('keydown', (e) => { if (blocked.has(e.key)) e.preventDefault(); });
window.addEventListener('wheel', (e) => e.preventDefault(), { passive: false });
```

Add `user-select: none` (and `-webkit-user-select: none`) to `body` to stop the iOS magnifier and
context menus (CrazyGames recommendation).

### Pixel ratio and resize

```ts
const MAX_DPR = 2; // rule of thumb; 1.5 for heavy 3D on phones
function resize(renderer: { setPixelRatio(n: number): void; setSize(w: number, h: number): void }) {
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, MAX_DPR));
  renderer.setSize(window.innerWidth, window.innerHeight);
}
window.addEventListener('resize', () => resize(renderer));
```

### Pause on hide
Pause simulation and audio on `visibilitychange` and on platform pause events
(`ytgame.system.onPause`, ad-break start). Resume only on the matching resume signal.

### Platform API gaps (MDN BCD 8.1.8)
- Pointer Lock: not in iOS Safari.
- Fullscreen API: not on iPhone (iPad from 16.4 with an overlay). Design for a full-viewport canvas.
- `screen.orientation.lock`: not in Safari. Show a "rotate your device" overlay instead.
- Gamepad works everywhere; `vibrationActuator` is missing in Firefox and on iOS.

## 7. Error capture

Log uncaught errors with the build version so reports from portals are traceable:

```ts
const BUILD = `${import.meta.env.VITE_PLATFORM}-${__APP_VERSION__}`;
window.addEventListener('error', (e) => report({ build: BUILD, msg: e.message, src: e.filename }));
window.addEventListener('unhandledrejection', (e) => report({ build: BUILD, msg: String(e.reason) }));
```

Define `__APP_VERSION__` with Vite's `define` from `package.json`. Where external requests are
blocked (Poki), `report` should buffer to the console only.

## 8. Pre-upload sweep

- [ ] `grep -r "localhost\|127.0.0.1" dist/<target>` returns nothing
- [ ] No `sk_`, `secret`, `api_key`, bot tokens or `.env` contents in `dist/`
- [ ] No source maps in public builds (`ls dist/<target>/assets | grep map` is empty)
- [ ] Debug panels and cheat keys gated behind `import.meta.env.DEV`
- [ ] Version string visible in the settings or pause menu
- [ ] Build report filled from real measurements
