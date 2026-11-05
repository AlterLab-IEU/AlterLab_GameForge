# Performance and Download Budgets

Read this when setting or auditing a budget, diagnosing a regression, preparing a web or mobile
build, or adding runtime AI. Hard limits come from platform documentation (accessed 2026-11-05);
everything labelled *rule of thumb* is a studio starting point to replace with your own profiling.

## 1. How to set a budget

1. **Pick the minimum-spec device** for each target and own one (or a cloud device lab slot).
   Budgets are set on that device, never on the development machine.
2. **Pick the frame target** per platform: 30 fps is acceptable for many mobile, handheld and
   strategy games; action games need 60; competitive and high-refresh targets may need 120.
3. **Split the frame** across systems and give each a named owner.
4. **Write the performance contract** into `docs/architecture/performance-budget.md`; a feature
   does not merge until it proves it fits.
5. **Automate the check** in CI (section 7) and review the trend at every milestone gate.

## 2. Frame budgets

| Target | Budget per frame | Typical use |
|---|---|---|
| 30 fps | 33.3 ms | Mobile under thermal limits, handheld, turn-based, heavy simulation |
| 60 fps | 16.67 ms | Default for action games on desktop and console; web on mid-range devices |
| 90 fps | 11.1 ms | Common VR headset refresh |
| 120 fps | 8.33 ms | Competitive, high-refresh displays |

**Starting split at 60 fps** (rule of thumb; rebalance per game):

| System | ms | Notes |
|---|---|---|
| Rendering (CPU submit + GPU) | 8.0 | GPU-bound games shift budget here from gameplay |
| Gameplay logic | 3.0 | AI, state machines, scripting |
| Physics | 2.0 | Fixed step; Unity defaults to 0.02 s (50 Hz), Godot to 60 ticks/s |
| Audio | 1.0 | Mix and DSP on the audio thread |
| Scripting/GC spikes | 1.5 | Budget the worst frame, not the average |
| Headroom | ~1.2 | Absorbs OS and driver noise |

Measure the 99th-percentile frame, not the mean. Players feel hitches, not averages.

## 3. Memory and draw calls (rules of thumb)

Set memory budgets from the min-spec device's usable memory after the OS reserve, then measure.
Starting points to revise:

| Target | Texture memory | Draw calls per frame |
|---|---|---|
| Mobile (native) | 256 MB or less | 100-200 |
| Mobile web | Stay well under the browser's tab limit; YouTube Playables caps the JS heap at 512 MB | 100-200 |
| PC mid-range | ~2 GB | 1,500-2,500 |
| Console | Per platform documentation | 2,000-4,000 |

Modern batching changes these numbers a lot (Unity's SRP Batcher and GPU Resident Drawer, Unreal
Nanite, three.js `BatchedMesh` and `InstancedMesh`, Phaser 4 `SpriteGPULayer`). Profile before
trusting any table, including this one.

## 4. Web download budgets (hard limits)

| Channel | Initial download | Total | Other requirements |
|---|---|---|---|
| CrazyGames | 50 MB or less up to the gameplay-start event; **20 MB or less for the mobile homepage** | 250 MB and 1,500 files | Chrome and Edge; externally hosted games reach gameplay within 20 s; DPR forced to 1 on iOS; games not smooth on 4 GB Chromebooks are disabled; Unity games disabled on iOS by default [1] |
| Poki | No numeric cap on the current page; warns players leave after ~10 s of loading | -- | `gameplayStart()` on first input; no external requests; works with ad blockers [2] |
| YouTube Playables | Under 30 MiB (under 15 MiB recommended) | Under 250 MiB; each file under 30 MiB; saves under 3 MiB | JS heap capped at 512 MB [3] |
| itch.io | ZIP with `index.html` | Upload limit varies; check the current page | SharedArrayBuffer toggle for threaded builds [4] |
| Own domain | No limit, but every second of load costs players | -- | Static hosting outlives backend-dependent games [5] |

**Getting under budget**
- Code-split: boot scene first, lazy-load levels and audio after `gameplayStart`.
- Textures: KTX2 (UASTC for normals and masks, ETC1S for color) via `gltf-transform`; cap at
  1024-2048 px for web.
- Geometry: Meshopt by default (fast decode, covers animation and morph targets); Draco is
  slightly smaller on the wire but slower to decode.
- Audio: WebM/Opus with an MP3 or AAC fallback; stream music instead of preloading it.
- Measure with `du -sh dist` and the browser network panel (transfer size, not disk size).
- Engine floor: an empty Defold HTML5 build is about 1 MB; physics WASM such as Rapier 0.21 adds
  about 3 MB [5]. Godot and Unity web builds start far larger, so test early against the
  20 MB mobile limit if portals matter.

## 5. Mobile web and browser constraints

| Constraint | Detail [5] |
|---|---|
| Audio unlock | `AudioContext` must resume from a user gesture; Firefox needs sticky activation |
| Pointer Lock | Not available in iOS Safari |
| Fullscreen | Not available on iPhone (iPad from 16.4, with an overlay) |
| Orientation lock | `screen.orientation.lock` not in Safari |
| Threads | SharedArrayBuffer requires cross-origin isolation (COOP/COEP headers), which some hosts cannot set |
| WebGPU | Not universal (no Firefox on Linux, Android or Intel Macs); ship a WebGL 2 fallback |
| Godot web | Compatibility renderer (WebGL 2) only; no C# web export; single-threaded by default [6] |
| Device spread | A game smooth on an iPhone stuttered on a mid-range Android in practitioner reports; test both [7] |

**Mobile web heuristics** (rule of thumb): cap device pixel ratio at 1.5-2 (CrazyGames forces 1 on
iOS), keep draw calls around 100-200, avoid per-frame allocation (GC pauses are visible), and
pause rendering when the tab is hidden.

## 6. Native mobile

- Thermal throttling cuts sustained performance; profile a 20-minute session, not a 2-minute one
  (rule of thumb).
- Google Play requires 16 KB memory-page support for apps with native code that target Android 15+;
  the enforcement date for updates has moved, so check the Play Console. Godot added support in
  4.5 [8][9].
- Battery and heat are budget items: offer a 30 fps option even when 60 is the default.

## 7. Runtime AI inference (rules of thumb)

- Shared AI budget on the main thread: 2 ms per frame at 60 fps at most; run inference on worker
  threads and never block the frame on a model.
- Response targets: under ~500 ms for text, under ~1 s for synthesized voice; hide latency with
  animation, barks or pre-fetched lines.
- Cloud inference adds roughly 50-200 ms of network latency, more on mobile; always keep a local
  or scripted fallback.
- Cost: model cost per session and per monthly active player; set hard spend caps with alerts at
  50%, 75% and 90%; cache responses and rate-limit per player.
- On-device small models trade cost for VRAM; budget their memory like any other asset.

## 8. CI performance gates

| Gate | Threshold (rule of thumb) | Action |
|---|---|---|
| Frame time on benchmark scene (p99) | +5% vs baseline over 3 runs | Warn |
| Same | +10%, or over budget | Block merge |
| Memory peak | Over budget | Block merge |
| Web initial download | Over the strictest target portal limit | Block release |
| Build time (incremental) | Over 15 minutes | Ticket for the TD |

Keep a "golden" benchmark scene per platform, record baselines per engine version, and re-baseline
after every engine upgrade. Implementation details: `/gameforge:game-ci-pipeline`.

## 9. Measurement tools

| Engine | Tools |
|---|---|
| Godot | Built-in profiler and monitors, visual profiler, `--print-fps`, remote debugging on device |
| Unity | Profiler, Frame Debugger, Memory Profiler, Profile Analyzer |
| Unreal | Unreal Insights, `stat unit`, `stat gpu`, `ProfileGPU` |
| Web | Browser DevTools Performance and Memory panels, three.js `renderer.info`, `stats-gl`, Lighthouse for load |

## Sources

All accessed 2026-11-05.
1. CrazyGames technical requirements: https://docs.crazygames.com/requirements/technical
2. Poki requirements and quality: https://developers.poki.com/guide/requirements-quality
3. YouTube Playables stability requirements: https://developers.google.com/youtube/gaming/playables/certification/requirements_stability
4. itch.io HTML5 upload (via Summer Engine guide, upload limit unverified): https://www.summerengine.com/make-great-games/publish-an-html5-game
5. GameForge web-stack brief: MDN browser-compat-data 8.1.8, npm registry, Defold and Rapier docs, Vibe Jam link-rot analysis (secondary): https://cdn.jsdelivr.net/npm/@mdn/browser-compat-data@8.1.8/data.json ; https://www.michaelscheiwiller.com/blog/vibe-jam-link-rot
6. Godot 4.7 web export docs: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
7. VL Studio, "Vibe-Coding a Game in 2026" (updated 2026-11-02): https://vlstudio.app/blog/vibe-coding-a-game-2026/
8. Android developers, Support 16 KB page sizes: https://developer.android.com/guide/practices/page-sizes
9. It's FOSS, Godot 4.5 release: https://itsfoss.com/news/godot-4-5-release/
