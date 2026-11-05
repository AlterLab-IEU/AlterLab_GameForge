# Engine Landscape, Late 2026

Read this before recommending an engine, planning an upgrade, or writing an engine ADR. Snapshot as
of 2026-11-05; every line carries a source number. Re-check release pages before committing a
project to a version: engines ship patches monthly.

## 1. Godot (MIT)

| Line | Status | Headline changes |
|---|---|---|
| 4.5 | Stable, Sept 2025 | Shader baker, stencil buffer, experimental editor screen reader, SDL3 gamepads [1] |
| 4.6 | 2026-01-26; patches to 4.6.3 (2026-05-20) | **Jolt is the default physics engine for new 3D projects**, new IK framework, SSR overhaul [2] |
| **4.7 (current stable)** | 4.7 on 2026-06-18; **4.7.2 on 2026-08-18** | HDR output, AreaLight3D, new Asset Store replaces the Asset Library, VirtualJoystick, Android export stable [3][4] |
| 4.8 (beta) | Beta 1 on 2026-10-15 (feature freeze), beta 2 on 2026-10-29 | Typed non-allocating physics queries, texture streaming, contact shadows, smaller text-scene diffs. **The .NET build needs .NET 10+.** macOS binaries ship per architecture [5] |

**Web export (4.6/4.7 docs)** [6]:
- Compatibility renderer (WebGL 2) only. "Godot currently does not support WebGPU."
- **C# projects cannot be exported to the web.** Web-first Godot projects use GDScript.
- Single-threaded export is the default; threads need `COOP: same-origin` and
  `COEP: require-corp` (or the PWA service-worker workaround). GDExtension on web needs extension
  support plus cross-origin isolation.
- Audio: "Sample" mode (default, low latency, no effects) or "Stream" mode (full features, higher
  latency).

**Agents**: no official MCP server and no `llms.txt` (docs return 404) [7]. Plain-text `.tscn`,
`.tres` and `.gd` files are easy for agents to edit directly; the GameForge hook protects `.godot/`
and `*.uid`. Since 2026-06-30 the Godot Foundation rejects substantial AI-authored contributions
to the *engine itself*; games made with Godot are unaffected [8].

**Consoles**: through third-party porting providers; no public console export templates.

## 2. Unity

**Support** [9][10]:
- **6.3 LTS** released 2025-12-04, supported to **2027-12-04**.
- **6.6** Update release 2026-08-31 (6000.6.8f1 on 2026-11-03). Update releases are superseded
  quickly; ship on an LTS.
- **6.0 LTS ended standard support on 2026-10-16**; Enterprise and Industry customers get support
  to 2027-10-16.
- Cadence: one LTS a year with two years of support, plus several Update releases.

**Unity 6.6 changes that matter for architecture** [11]:
- Fast Enter Play Mode is on by default, so **static fields no longer reset** between play sessions.
- The Inspector serializes dictionaries natively.
- Content Directories start replacing AssetBundles.
- WebGPU leaves experimental per a secondary source; in the 6.6 docs it is opt-in: disable Auto
  Graphics API, put WebGPU first, keep WebGL 2 as fallback [12].
- Cinemachine 2 is deprecated.

**Next**: the **Unity 7.0 alpha** (2026-10-05) is the first CoreCLR editor with no Mono. It still
targets C# 9; no date for .NET 10 / C# 14. 6.7 LTS is the bridge release, date not committed [13].

**Pricing** [14]: Runtime Fee canceled Sept 2024. Personal is free below US$200K revenue or
funding. Pro rose 5% on 2026-01-12 to US$2,310 per seat per year.

**Unity AI** [15][16]: open beta since 2026-05-04. In-editor agent (Ask, Agent and Plan modes,
Skills, rollback, asset Generators) uses credits: included in Pro and above, US$10/month on
Personal. AI Gateway lets you bring a third-party agent you already pay for. The official MCP
server (via the Unity CLI) and the official agent plugin for Claude Code, Codex and others are
documented as free with Unity 6.0+. A May 2026 Unity blog tied MCP to a Unity AI subscription, so
confirm current terms before budgeting. Unity also publishes `docs.unity.com/llms.txt`.

**Web**: CrazyGames disables Unity games on iOS by default because of memory crashes [17].

## 3. Unreal Engine

- **5.7** (Nov 2025): PCG and Substrate production-ready; experimental in-editor AI Assistant [18].
- **5.8 (current, 2026-06-17)**: experimental Unreal MCP plugin; MegaLights production-ready;
  Lumen "Lite" in beta; Mesh Terrain and Procedural Vegetation Editor (experimental); MetaHuman
  Animator captures face and body from a single webcam. Epic calls it **the last planned major UE5
  release** [19].
- **UE6** (announced 2026-06-17): **early access targeted for late 2027**, built around **Verse**
  and **Scene Graph**. Blueprints and Actors are to be phased out over time; Epic promises a free
  Blueprint-to-Verse converter. Reports that Blueprints will be deleted outright are unverified [20].
- **Licensing** [21]: 5% royalty above US$1M lifetime gross; 3.5% under Launch Everywhere (Epic
  Games Store at the same time or first); EGS revenue is royalty-free. MetaHumans may be used in
  Unity and Godot; using them to train AI is prohibited [22].

## 4. Web stacks

Full detail lives in the `game-threejs-specialist` and `game-web2d-specialist` skills. What a TD
needs for selection [23]:

| Stack | Current | Notes |
|---|---|---|
| Three.js | r187 (`three@0.187.0`, 2026-10-30) | `WebGLRenderer` is "default, mature"; `WebGPURenderer` for TSL, compute, node materials, with automatic WebGL 2 fallback. ESM-only since r187 (CJS stub). Official `llms.txt` |
| React Three Fiber | 9.8.2 stable; v10 alpha only | v10 goes WebGPU-first; do not ship the alpha |
| Babylon.js | 9.x (9.0 announced 2026-03-26) | Batteries-included engine with Havok physics, Frame Graph, editors; `llms.txt` |
| PlayCanvas | 2.23 | Editor-centric; official Editor MCP server |
| Phaser | 4.2.1 (4.0 on 2026-04-10) | RenderNodes replace pipelines; Filters replace FX; Canvas renderer deprecated; MIT. Its `llms.txt` steers agents to the separate commercial Phaser AE product (vendor steer) |
| PixiJS | 8.22.0 | Async `await app.init()`; WebGL default, WebGPU opt-in |
| Kaplay | 3001.0.19 stable | v4000 still alpha; beginner-friendly at a performance cost |
| Tooling | Vite 8 (Rolldown only; Node 20.19+/22.12+), TypeScript 7 | |

**WebGPU reach** [23]: Chrome/Edge desktop since 113 and Android 12+ since 121; Safari 26 on macOS,
iOS, iPadOS and visionOS; Firefox on Windows since 141 and Apple Silicon macOS, but not Linux,
Android or Intel Macs. **A WebGL 2 fallback is still required.**

**Persistence**: of Vibe Jam entries, 42% from 2025 and 13% from 2026 were already offline by late
2026; backend-dependent games died fastest and static hosting survived best (secondary source)
[24]. Prefer static clients with optional backends for small web games.

## 5. Other engines

| Engine | Current | Notes |
|---|---|---|
| GameMaker | LTS 2026.0 (May 2026) | New runtime GMRT still in beta [25] |
| Defold | 1.14.0 (2026-10-12) | Official `llms.txt` and `llms-full.txt`; wasm-only web; tiny HTML5 builds [26] |
| Bevy | 0.20 (2026-10-08) | Rust ECS; pre-1.0, breaking releases [27] |
| Stride | 4.3 (2025-11-14) | .NET 10, Bepu physics [28] |

## 6. Market context

GDC 2026 State of the Industry: Unreal is the primary engine for 42% of respondents and Unity for
30%; Godot is at 11% among newer indies [29]. Popularity is a hiring and tutorial signal, not a fit
signal.

## 7. Selection scoring sheet

Score 1-5, multiply by weight, and paste into the ADR.

| Criterion | Weight | Godot | Unity | Unreal | Web stack |
|---|---|---|---|---|---|
| Ships where we need (platforms, portals, consoles) | 3 | | | | |
| Team already fluent | 3 | | | | |
| Genre and fidelity fit | 2 | | | | |
| Support window covers ship date + 1 year | 2 | | | | |
| Iteration speed (build, reload, export) | 2 | | | | |
| Agent tooling (MCP, `llms.txt`, text formats) | 1 | | | | |
| Cost and license at projected revenue | 1 | | | | |
| Download size and load time for target channel | 1-3 | | | | |

Weight download size at 3 for portal games, 1 for Steam-only games.

## Sources

All accessed 2026-11-05.
1. It's FOSS, Godot 4.5: https://itsfoss.com/news/godot-4-5-release/
2. Godot 4.6 release page: https://godotengine.org/releases/4.6/ ; 4.6.3: https://godotengine.org/article/maintenance-release-godot-4-6-3/
3. Godot 4.7 release page: https://godotengine.org/releases/4.7/
4. Godot blog index (4.7.2 on 2026-08-18): https://godotengine.org/blog/
5. Godot 4.8 beta 1: https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/
6. Godot 4.7 web export docs: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
7. Direct `llms.txt` checks: https://docs.godotengine.org/llms.txt (404), https://docs.unity.com/llms.txt (200)
8. The Register, Godot contribution policy (2026-07-01): https://www.theregister.com/ai-and-ml/2026/07/01/godot-says-bye-bye-ai-bans-vibe-coded-contributions/5265344
9. endoflife.date, Unity: https://endoflife.date/unity
10. Unity 6 releases and support: https://unity.com/releases/unity-6/support
11. Unity Manual, New in Unity 6.6: https://docs.unity3d.com/6000.6/Documentation/Manual/WhatsNewUnity66.html
12. Unity 6.6 WebGPU docs: https://docs.unity.com/en-us/engine/6000.6/manual/platform-specific/webgl/develop/graphics/web-gpu/enable
13. Unity Discussions, CoreCLR update Oct 2026: https://discussions.unity.com/t/coreclr-scripting-and-net-update-october-2026/1738338
14. Unity pricing updates: https://unity.com/products/pricing-updates ; 80.lv, 2026 price changes: https://80.lv/articles/unity-announces-its-upcoming-2026-price-changes
15. Unity AI tools page: https://unity.com/features/ai
16. Unity docs, plugin for Claude Code: https://docs.unity.com/en-us/ai/unity-plugin/claude-code ; Unity blog, MCP getting started: https://unity.com/de/blog/unity-ai-mcp-how-to-get-started
17. CrazyGames technical requirements: https://docs.crazygames.com/requirements/technical
18. Digital Production, UE 5.7: https://digitalproduction.com/2025/11/12/unreal-engine-5-7-foliage-pcg-and-in-editor-ai/
19. GamesBeat, UE 5.8: https://gamesbeat.com/epic-games-launches-unreal-engine-5-8/
20. Inven Global, Sweeney on UE6: https://www.invenglobal.com/articles/22928/ceo-tim-sweeney-unreal-engine-6-will-fundamentally-change-the-development-paradigm
21. Unreal Engine license: https://www.unrealengine.com/license
22. CG Channel, MetaHumans in Unity and Godot: https://www.cgchannel.com/2025/06/you-can-now-sell-metahumans-or-use-them-in-unity-or-godot/
23. npm registry metadata and official release notes, per the GameForge web-stack brief: https://github.com/mrdoob/three.js/releases , https://threejs.org/llms.txt , https://phaser.io/news/2026/07/phaser-4-2-spine-renderer-mesh2d-stencil , https://github.com/pixijs/pixijs/releases , https://vite.dev/blog/announcing-vite8 , https://github.com/gpuweb/gpuweb/wiki/Implementation-Status
24. Vibe Jam link-rot analysis (secondary): https://www.michaelscheiwiller.com/blog/vibe-jam-link-rot
25. GameMaker LTS 2026.0: https://gamemaker.io/en/blog/lts-2026-release
26. Defold blog: https://defold.com/blog/ ; https://defold.com/llms.txt
27. Bevy 0.20: https://bevy.org/news/bevy-0-20/
28. Stride 4.3: https://stride3d.net/blog/announcing-stride-4-3-in-dotnet-10/
29. GDC 2026 State of the Game Industry: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/
