# Engine Comparison Matrix (Late 2026)

The canonical engine-selection reference for GameForge skills, as of **2026-11-05**. It covers:
- **Native engines:** Godot, Unity and Unreal.
- **Web engines:** Three.js / React Three Fiber, Babylon.js, PlayCanvas, Phaser and PixiJS.
- **Brief notes:** GameMaker, Defold and Bevy.

Versions, prices and license terms come from the numbered sources. Genre and team-size guidance is practitioner judgment and is labeled as such. Validate any engine choice with a one-week prototype before committing.

Related: [AI-native game development](ai-native-gamedev.md), [MCP integrations](mcp-integrations.md), [coding standards](coding-standards.md).

---

## Versions at a Glance

| Engine | Current stable | Next / preview | Support notes |
|---|---|---|---|
| **Godot** | **4.7.2** (2026-08-18). 4.7 shipped 2026-06-18 [1][3] | **4.8 beta 2** (2026-10-29); the .NET build needs **.NET 10+** [2] | MIT. 4.6 (2026-01-26) made Jolt the default 3D physics engine for new projects [4] |
| **Unity** | **6.3 LTS** (2025-12-04, supported to 2027-12-04). **6.6** Update release (2026-08-31) [7][8] | **7.0 alpha** (2026-10-05), the first CoreCLR editor (no Mono, still C# 9). 6.7 LTS is the bridge release, date not committed [10] | **6.0 LTS left standard support 2026-10-16** (Enterprise/Industry to 2027-10-16) [7] |
| **Unreal** | **5.8** (2026-06-17), Epic's last planned major UE5 release [15] | **UE6 early access targeted late 2027**, built around Verse and Scene Graph [17] | Blueprints and Actors to be phased out over time; Epic promises a free Blueprint-to-Verse converter [17] |
| **Three.js** | **r187** (`three@0.187.0`, 2026-10-30) [19] | Releases every 1–3 months | R3F 9.8.2 is stable. R3F v10 is alpha only (10.0.0-alpha.6) [19][22] |
| **Babylon.js** | **9.x** (9.0 announced 2026-03-26; 9.33.3 on 2026-11-05) [19][23] | — | Apache-2.0 |
| **PlayCanvas** | Engine **2.23.3** (2026-10-15) [19] | 2.24 beta | Engine, hosted Editor, React and Web Components entry points [25] |
| **Phaser** | **4.2.1** (2026-07-09). 4.0 shipped 2026-04-10 [19][26] | — | Phaser AE is a separate, agent-oriented commercial product [27] |
| **PixiJS** | **8.22.0** (2026-10-01) [28] | — | v8 init is async |
| **GameMaker** | **LTS 2026.0** (May 2026) [29] | New runtime GMRT in beta; C# planned as a preview | — |
| **Defold** | **1.14.0** (2026-10-12) [30] | — | wasm-only web builds since 1.13 |
| **Bevy** | **0.20** (2026-10-08; 0.20.1 on 2026-10-28) [31] | — | Pre-1.0: expect breaking changes each release |

**Market context.**
- **GDC 2026 State of the Industry:** Unreal is the primary engine for 42% of respondents and Unity for 30%. Godot is at 11% among newer indies [36].
- **2026 Vibe Jam** (945 AI-built web games): about 65% used Three.js and 5–6% used Phaser. 21 games used Godot (secondary analysis) [37].

---

## Choose X When

| Choose | When | Think twice when |
|---|---|---|
| **Godot** | 2D or stylized 3D for desktop and mobile. You want zero license cost, small installs, fast iteration, and **text files an agent can read, edit and diff** | You need console at launch without a porting budget, **C# on the web**, or high-end 3D fidelity |
| **Unity** | Mobile-first, a console path, a C# team, a deep Asset Store, or the **most complete official agent integration** (Unity AI MCP plus the Claude Code plugin) | Per-seat Pro fees above US$200K revenue hurt, or you want a fully text-diffable project |
| **Unreal** | High-fidelity 3D, large worlds, cinematic tools, or built-in networking at scale | The game is 2D, the team is tiny and needs fast iteration, or the target is the web. Agent support is experimental and assets are binary |
| **Three.js / R3F** | 3D web, instant-play links, jams, AI-agent-built games. Everything is code and the browser check loop takes seconds | You need a full editor and content pipeline for a long project (consider Babylon.js or PlayCanvas) |
| **Babylon.js** | Batteries-included web 3D: Havok physics, Frame Graph, node editors, inspector | You want the largest pool of examples and agent training data (Three.js) |
| **PlayCanvas** | An editor-centric web team that needs a collaborative browser editor, an official Editor MCP server, and Gaussian splats | You want a code-only workflow with no hosted editor |
| **Phaser 4** | 2D web games, jams, portals, Reddit/Devvit-style social games | You need a custom renderer architecture (PixiJS) or native console builds |
| **PixiJS 8** | A fast 2D renderer you build your own architecture around; UI-heavy or custom-engine 2D | You want scenes, physics, audio and input handled for you (Phaser) |
| **GameMaker** | Designer-friendly 2D with a one-time commercial license | You need 3D, or consoles without an Enterprise subscription |
| **Defold** | Tiny web and mobile builds, Lua, free license, consoles for approved developers | You need a large asset store or high-end 3D |
| **Bevy** | Rust programmers who want ECS and code-first workflows | You need stability across versions or an artist-friendly editor today |

---

## Native Engines: Core Matrix

| Dimension | Godot 4.7 / 4.8 | Unity 6.3 LTS / 6.6 | Unreal 5.8 |
|---|---|---|---|
| **License & fees** | MIT. No fees, no royalties | Personal is free below US$200K revenue or funding. **Pro US$2,310/seat/year** (up 5% on 2026-01-12). Runtime Fee cancelled Sept 2024 [11][12] | 5% royalty on lifetime gross above US$1M per product. **3.5% under Launch Everywhere**. Revenue from Epic Games Store sales is royalty-free [18] |
| **Languages** | GDScript, C# (.NET), C++ via GDExtension | C# | C++, Blueprints. Verse arrives with UE6 |
| **2D** | Excellent: dedicated 2D renderer, TileMap layers, 2D physics and lighting | Good: Tilemap, SpriteRenderer, 2D physics and lights | Weak; not recommended for 2D-first games |
| **3D rendering** | Forward+, Mobile and Compatibility renderers. 4.7 adds HDR output and AreaLight3D; 4.8 beta adds texture streaming and contact shadows [2][3] | URP for reach, HDRP for fidelity. 6.6 adds DXC/SM6 for DX12 [9] | Nanite, Lumen, MegaLights (production-ready in 5.8), Lumen "Lite" in beta [15] |
| **Physics** | Jolt is the default for new 3D projects (4.6+) [4] | PhysX (3D), Box2D-based 2D physics | Chaos; Chaos Cloth production-ready in 5.8 [15] |
| **Desktop / mobile** | Windows, macOS, Linux, Android, iOS | Windows, macOS, Linux, Android, iOS, XR | Windows, macOS, Linux, Android, iOS, XR |
| **Consoles** | No first-party export, because console SDKs are under NDA. Use third-party porting (e.g. W4 Games) | First-party support for approved platform developers | First-party support for approved platform developers |
| **Web** | Yes, with limits (see [web export](#platforms-and-web-export-limits)) | Yes, with heavy builds. WebGPU is opt-in in 6.6 | **No first-party web export** [39] |
| **Source control** | Text scenes and resources (`.tscn`, `.tres`); Git-friendly | YAML scenes (Force Text) plus `.meta` GUIDs. Git LFS or Unity Version Control | Binary `.uasset`. Perforce is the norm; Git LFS with locking for small teams |
| **Networking** | High-level multiplayer API (ENet, WebSocket, WebRTC) | Netcode for GameObjects / Entities, plus third-party stacks | Replication system, proven at large scale |
| **Learning curve** | Low for 2D, moderate for 3D | Moderate; many overlapping legacy and new systems | High; C++ plus a large engine surface |
| **Editor weight** | Small download, starts in seconds | Large install through Unity Hub | Very large install; first shader compile is slow |
| **Changes to plan for** | 4.8 .NET build needs .NET 10 and ships per-architecture macOS binaries [2] | 6.6: Fast Enter Play Mode is on by default, so **static fields no longer reset**. Content Directories start replacing AssetBundles. Cinemachine 2 is deprecated [9]. Unity 7 moves to CoreCLR [10] | UE6's move to Verse and Scene Graph; 5.8 is the last planned major UE5 [15][17] |

---

## Web Engines Matrix

| Dimension | Three.js r187 (+ R3F 9.8) | Babylon.js 9 | PlayCanvas 2.23 | Phaser 4.2 | PixiJS 8.22 |
|---|---|---|---|---|---|
| **License** | MIT | Apache-2.0 | Engine MIT; hosted Editor (check plan terms) | MIT. Phaser AE is PolyForm Shield [27] | MIT |
| **Scope** | 3D renderer plus scene graph. Bring your own physics (Rapier 0.21, Jolt 1.1), audio and UI | Full 3D engine: Havok Physics V2, GUI, inspector, node editors, Frame Graph v1 [23][24] | Full 3D engine plus a collaborative browser editor [25] | Full 2D framework: scenes, input, audio, tilemaps, Arcade physics | 2D renderer plus display tree. Bring physics (planck, rapier2d) and audio (`@pixi/sound`) |
| **Renderer** | `WebGLRenderer` is the default. `WebGPURenderer` is opt-in for TSL and compute, with automatic WebGL 2 fallback [20] | WebGL 2 and WebGPU (clustered lighting on both) [23] | WebGL 2 or WebGPU [25] | WebGL (Canvas renderer deprecated); no WebGPU renderer announced [26] | WebGL by default; WebGPU via `preference: 'webgpu'` [28] |
| **Agent support** | Official `llms.txt`; no official MCP | `llms.txt` | `llms.txt`, **Editor MCP server**, agent skills [25] | `llms.txt`, which steers agents to Phaser AE [27] | `llms.txt` |
| **Watch-outs** | ESM-only. Many r181–r187 renames (`Clock`→`Timer`, `PostProcessing`→`RenderPipeline`). pmndrs postprocessing is WebGL-only. Don't ship R3F v10 alpha [21][22] | More opinionated engine; check bundle size against portal budgets | Editor-centric workflow; ESM scripts (`.mjs`) for new code | Phaser 3 code does not port as-is (Filters, RenderNodes, removed `Geom.Point`) [26] | Async `await app.init()`; v7 tutorials are stale |
| **Best for** | 3D jams, vibe-coded builds, custom 3D web games | Production web 3D with an editor-style toolchain | Teams that want an editor and MCP-driven automation | 2D web default; portals and jams | Custom 2D engines, UI-heavy games |

**Smaller web options**
- **Kaplay:** 3001 is stable; avoid the v4000 alpha.
- **LittleJS 1.29:** a tiny footprint for size-capped builds.
- **Excalibur 0.32:** still pre-1.0.
- **Needle Engine:** built on three.js. Its stable release is 5.1.16, but npm `latest` points to a 6.0 alpha, so pin it [19].

For depth, see `/gameforge:game-threejs-specialist` and `/gameforge:game-web2d-specialist`.

---

## Other Engines Worth Knowing

**GameMaker** [29]
- **Language and focus:** GML, 2D-focused.
- **Pricing:**
  - Free for non-commercial use, including desktop, web, mobile and GX.games exports.
  - **Professional is a US$99.99 one-time commercial license** that adds CI builds.
  - **Console export requires the Enterprise subscription** (price not listed).
- **Roadmap:** LTS 2026.0 shipped in May 2026. The new runtime, GMRT, is in beta, with C# planned as a preview.
- **Agent docs:** `llms.txt` status is undetermined (403).

**Defold** [30]
- **Language and license:** Lua. Free under the Defold License, which is derived from Apache 2.0, with no royalties. You may not commercialize modified versions of the editor or engine.
- **Web builds:** wasm-only since 1.13. An empty HTML5 project is about 1.06 MB, and a WebGPU backend exists.
- **Consoles:** Switch and PlayStation for approved developers. Secondary reports say 1.14.0 added free Xbox support for approved developers.
- **Agent docs:** official `llms.txt` and `llms-full.txt`.

**Bevy** [31]
- **Language and license:** Rust, dual MIT/Apache-2.0. ECS-first and code-first.
- **0.20 highlights:** Solari path tracing on Metal, BSN scenes, and shaders moving to WESL.
- **Web limits:** mesh shaders are not supported on the web, and Basis Universal is the recommended texture compression. Whether the default web backend is WebGPU or WebGL 2 is UNVERIFIED.
- **Agent docs:** no `llms.txt` (404).
- **Agent caution:** frequent breaking changes make agent training data go stale quickly. Pin the version and paste the migration guide into context.

---

## Licensing and Fees

| Engine | What you pay | Worked example |
|---|---|---|
| Godot | US$0. Console porting through a partner is quoted per project | — |
| Unity | US$0 on Personal below US$200K revenue or funding. Above that, Pro at US$2,310/seat/year [11] | 5 Pro seats: **US$11,550/year** |
| Unreal | 5% of lifetime gross above US$1M per product. 3.5% under Launch Everywhere (ship on the Epic Games Store at the same time or first). EGS sales royalty-free [18] | US$2M lifetime gross outside EGS: 5% × US$1M = **US$50,000**, or **US$35,000** at 3.5% |
| GameMaker | Free (non-commercial). US$99.99 one-time (Professional). Enterprise subscription for consoles [29] | — |
| Defold, Bevy, Three.js, Babylon.js, Phaser, PixiJS | US$0 (open source) | Phaser AE and the PlayCanvas hosted Editor have their own commercial terms |

**Honest read.** For a game that earns under US$1M, every engine here is effectively free. Pick on fit, iteration speed and target platform, not on fees.

---

## Platforms and Web Export Limits

| Engine | Web export | Limits that bite |
|---|---|---|
| Godot 4.7 | Yes | **Compatibility renderer (WebGL 2) only**, no WebGPU. **C# projects cannot export to the web.** Threads need COOP/COEP headers (single-threaded is the default). Audio "Sample" mode (default) has no effects [5] |
| Unity 6.6 | Yes | Large builds. WebGPU is opt-in (disable Auto Graphics API, put WebGPU first, keep WebGL 2 as fallback) [13]. Reports that WebGPU left experimental in 6.6 are unconfirmed in the WebGPU manual page. CrazyGames disables Unity games on iOS by default because of memory crashes [32] |
| Unreal 5.8 | **No** | HTML5 left the engine in the 4.23/4.24 era. Only gated community forks of UE4 remain [39] |
| GameMaker | Yes (web, GX.games) | — |
| Defold | Yes (wasm) | Small: an empty HTML5 project is about 1.06 MB [30] |
| Bevy | Yes (WASM) | No mesh shaders on the web [31] |
| Three.js, Babylon.js, PlayCanvas, Phaser, PixiJS | Native | You own the loading budget, audio unlock and the fallback renderer |

**Browser realities (2026)** [35]
- **WebGPU** ships in Chrome/Edge 113+ and Safari 26. Firefox has it on Windows and Apple Silicon macOS, but not on Linux (Nightly only) or Android (flag only). **Keep a WebGL 2 fallback.**
- **iPhone** has no Fullscreen API and no Pointer Lock.
- **Audio** must be resumed from a user gesture.

**Portal budgets** [32][33][34]
- **CrazyGames:** initial download of 50 MB or less, and **20 MB or less for the mobile homepage**.
- **Poki:** players leave if loading takes more than about 10 seconds.
- **YouTube Playables:** initial bundle under 30 MiB.

Ship web builds with `/gameforge:game-web-publish`.

---

## Team-Size Fit

These are judgment calls, not rules.

| Team | Native default | Web default | Why |
|---|---|---|---|
| Solo | Godot, or Unity for mobile/console | Phaser (2D), Three.js (3D) | Low friction, fast loop, nothing to license |
| 2–5 | Godot, Unity or Unreal by genre and fidelity | Three.js + R3F, Babylon.js, PlayCanvas | Choose on visual target and platforms |
| 6–15 | Unity or Unreal; Godot with a strong tech lead | Babylon.js or PlayCanvas (editor workflows) | Asset pipelines, hiring pool and tooling start to dominate |
| 15+ | Unity or Unreal | Rare; usually a custom engine on Three.js or Babylon.js | Console pipelines, enterprise support, established workflows |

---

## Genre Fit

Practitioner judgment. Validate it with a prototype.

| Genre | Strong fit | Viable | Weak fit |
|---|---|---|---|
| 2D platformer / pixel art | Godot, GameMaker, Phaser | Unity, Defold | Unreal |
| 2D roguelite / survivor | Godot, Unity, Phaser | GameMaker, PixiJS, Bevy | Unreal |
| Narrative / visual novel | Godot, Unity | Phaser, PixiJS (web) | Unreal (overhead) |
| Stylized 3D action / platformer | Unity, Godot | Unreal, Three.js | — |
| High-fidelity 3D / open world | Unreal | Unity (HDRP) | Godot, web engines |
| Multiplayer shooter at scale | Unreal | Unity | Godot and web (fine for small session games) |
| Strategy / management sim | Unity, Godot | Bevy (ECS-heavy sims) | Unreal |
| Mobile casual | Unity, Defold | Godot, Phaser (wrapped) | Unreal |
| Instant-play web / jam | Three.js, Phaser | PlayCanvas, Babylon.js, Kaplay, LittleJS, Godot web | Unreal (no web), Unity (heavy builds) |
| VR / XR | Unity, Unreal | Godot (OpenXR), Three.js (WebXR) | — |

Route netcode questions to `/gameforge:game-multiplayer`.

---

## Engines and AI Coding Agents

| Factor | Godot | Unity | Unreal | Web (Three.js / Phaser / PixiJS) |
|---|---|---|---|---|
| **Official agent integration** | None | Unity AI MCP server (beta), Unity CLI, Claude Code plugin [14] | Unreal MCP plugin, 5.8 (experimental, editor-only, loopback, no auth) [16] | PlayCanvas Editor MCP; none for the others |
| **Community MCP** | Coding-Solo/godot-mcp | CoplayDev/unity-mcp | chongdashu/unreal-mcp | Playwright MCP for any web build |
| **`llms.txt`** | No | Yes | Undetermined (403) | Yes (Three.js, Phaser, PixiJS, Babylon.js, PlayCanvas, R3F) |
| **Can the agent read and diff the source of truth?** | **Yes.** Scenes, resources and scripts are text | **Partly.** C# yes; YAML scenes with `.meta` GUIDs are fragile | **Mostly no.** `.uasset` and Blueprints are binary; C++ yes | **Yes.** Code plus JSON/GLB assets |
| **Check loop** | `godot --headless` script and test runs | Editor test runner or CLI; domain reloads add time | C++ compile plus editor; automation tests via MCP | `npm run build`, unit tests, Playwright screenshots, all in seconds |
| **Typical agent mistakes** | Godot 3 APIs in Godot 4 code (`KinematicBody` → `CharacterBody`, `yield` → `await`) [38] | Assuming static fields reset (6.6), editing `.meta` files, mixing legacy and new Input/UI systems | Logic hidden in Blueprints the agent can't read; long compile loops | Deprecated three.js APIs (`three.min.js`, `Clock`, `PostProcessing`), Phaser 3 APIs in Phaser 4, R3F v10 alpha APIs |
| **Policy note** | The Godot Foundation bans AI-authored engine PRs (engine contributions only) [6] | — | — | Phaser's `llms.txt` steers to its commercial Phaser AE |

**Guidance for AI-assisted builds**
1. **The tightest loop is on the web.** Three.js (3D) or Phaser (2D), pinned versions, `llms.txt` in `CLAUDE.md`, and Playwright checks. Run the loop with `/gameforge:game-vibe-code`.
2. **For native and text-first, use Godot.** The agent edits the real files, and `godot --headless` verifies them. Pin the docs version to your engine (`docs.godotengine.org/en/4.7/`).
3. **Unity has the most official agent integration.** Use it on Unity 6+ with the Unity AI MCP server or plugin. Commit before each session and review prefab and scene diffs.
4. **On Unreal, keep agent-touched logic in C++ or Python editor scripts**, where diffs are reviewable. Use the 5.8 MCP plugin for editor operations and treat it as experimental.
5. **Every engine needs the same discipline:**
   - Pin versions.
   - Give the agent a pass/fail check.
   - Review architecture by hand.
   - Use `/gameforge:game-code-review` on agent-generated changes.

---

## Migration Difficulty

| From / To | Godot | Unity | Unreal | Web (JS/TS) |
|---|---|---|---|---|
| **Godot** | — | Medium: GDScript to C#; node to component paradigm | Hard: C++ and Blueprints, different scene model | Medium: logic ports, scenes rebuilt in code |
| **Unity** | Medium: C# carries over; component to node shift | — | Hard: C# to C++, Actor model | Medium-hard: C# to TS; rebuild rendering and UI |
| **Unreal** | Hard: rendering downgrade, full rewrite | Medium-hard: C++ to C#; materials rebuilt | — | Hard: no web path |
| **Web (JS/TS)** | Medium: rewrite in GDScript or C# | Medium: TS to C# | Hard | Easy to medium between libraries (e.g. Phaser to PixiJS) |

**Rules**
- **Assets and documents transfer.** Art, audio and design documents carry over with minor format work.
- **Code, shaders, materials and UI do not transfer.** Budget a rewrite.
- **Migrate early or not at all.** After alpha, a migration is a restart in all but name.
- **Pricing is no longer a reason to move.** The Unity Runtime Fee no longer exists [12].

---

## Decision Checklist

| Question | Engine implication |
|---|---|
| Is the game primarily 2D? | Godot, Phaser, GameMaker, Unity, Defold, PixiJS |
| Is high-fidelity 3D a core pillar? | Unreal; Unity HDRP |
| Must it be playable instantly in a browser? | Three.js, Phaser, PlayCanvas, Babylon.js. Godot only with GDScript (no C# web export). Not Unreal |
| Console at launch? | Unity or Unreal. Godot only with a porting partner. GameMaker needs Enterprise. Defold for approved developers |
| Mobile primary? | Unity, Defold, Godot; web wrapped with Capacitor |
| Team language? | GDScript or C# → Godot. C# → Unity. C++ → Unreal. TS/JS → web engines. Rust → Bevy. Lua → Defold |
| Will an AI agent write most of the code? | Prefer text-first engines (web, Godot) or Unity with its official MCP. Plan around Unreal's binary assets |
| Revenue expectations above US$200K? | Budget Unity Pro seats. Unreal royalty above US$1M |
| Need marketplace assets? | Unity Asset Store, Fab (Unreal); Godot's new Asset Store (4.7) is younger [3] |

---

## Cross-References

- Engine depth:
  - Native: `/gameforge:game-godot-specialist`, `/gameforge:game-unity-specialist`, `/gameforge:game-unreal-specialist`.
  - Web: `/gameforge:game-threejs-specialist`, `/gameforge:game-web2d-specialist`.
- Engine selection in project context, and the performance strategy that follows: `/gameforge:game-technical-director`.
- Whether the engine choice fits scope and timeline: `/gameforge:game-scope-check`.
- Project setup that records `engine` and `engine_version` in `.gameforge/project.json`: `/gameforge:game-start`.
- Engine-specific conventions: [coding standards](coding-standards.md).
- Agent wiring: [MCP integrations](mcp-integrations.md).

---

## Sources

All accessed 2026-11-05. The date in parentheses is the publication or update date where known.

1. Godot blog index (4.7.1, 4.7.2, 4.8 beta 2): https://godotengine.org/blog/
2. Godot, "Dev snapshot: Godot 4.8 beta 1": https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/ (2026-10-15)
3. Godot 4.7 release page: https://godotengine.org/releases/4.7/ (2026-06-18)
4. Godot 4.6 release page: https://godotengine.org/releases/4.6/ (2026-01-26)
5. Godot documentation (4.7), "Exporting for the Web": https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
6. Godot contribution policy: https://godotengine.org/article/contribution-policy-2026/ (2026-06-30)
7. endoflife.date, Unity: https://endoflife.date/unity (updated 2026-11-04) ; Unity 6 support: https://unity.com/releases/unity-6/support
8. Unity, "Unity 6.3 LTS is now available": https://unity.com/blog/unity-6-3-lts-is-now-available (2025-12-04)
9. Unity Manual, "New in Unity 6.6": https://docs.unity3d.com/6000.6/Documentation/Manual/WhatsNewUnity66.html
10. Unity Discussions, "CoreCLR, Scripting, and .NET Update, October 2026": https://discussions.unity.com/t/coreclr-scripting-and-net-update-october-2026/1738338 (2026-10-05)
11. Unity pricing updates: https://unity.com/products/pricing-updates ; 80.lv, Unity 2026 price changes: https://80.lv/articles/unity-announces-its-upcoming-2026-price-changes (2025)
12. GameFromScratch, "The Unity Run-Time Fee Is Dead": https://gamefromscratch.com/the-unity-run-time-fee-is-dead-prices-increased/ (Sept 2024)
13. Unity documentation (6.6), enable WebGPU: https://docs.unity.com/en-us/engine/6000.6/manual/platform-specific/webgl/develop/graphics/web-gpu/enable
14. Unity, AI tools page: https://unity.com/features/ai ; "Unity's plugin for Claude Code": https://docs.unity.com/en-us/ai/unity-plugin/claude-code (updated Oct 2026)
15. GamesBeat, "Epic Games launches Unreal Engine 5.8": https://gamesbeat.com/epic-games-launches-unreal-engine-5-8/ (2026-06-17)
16. Epic Games, "Unreal MCP in Unreal Editor": https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor?lang=en-US (UE 5.8)
17. Inven Global, Sweeney on UE6: https://www.invenglobal.com/articles/22928/ceo-tim-sweeney-unreal-engine-6-will-fundamentally-change-the-development-paradigm (2026-06-18)
18. Unreal Engine license: https://www.unrealengine.com/license ; TweakTown, 3.5% Launch Everywhere: https://www.tweaktown.com/news/100826/epic-offers-new-3-5-royalty-to-developers-if-they-launch-on-games-store/index.html
19. npm registry metadata, queried 2026-11-05: `https://registry.npmjs.org/<package>`. Packages: three, @react-three/fiber, @babylonjs/core, playcanvas, phaser, pixi.js, kaplay, excalibur, littlejsengine, @needle-tools/engine
20. three.js `llms.txt`: https://threejs.org/llms.txt
21. three.js Migration Guide: https://github.com/mrdoob/three.js/wiki/Migration-Guide
22. R3F v10 migration guide: https://r3f.docs.pmnd.rs/next/migration/v10
23. Microsoft, "Announcing Babylon.js 9.0": https://blogs.windows.com/windowsdeveloper/2026/03/26/announcing-babylon-js-9-0/ (2026-03-26)
24. Babylon.js physics docs: https://doc.babylonjs.com/features/featuresDeepDive/physics/usingPhysicsEngine ; `llms.txt`: https://doc.babylonjs.com/llms.txt
25. PlayCanvas `llms.txt`: https://developer.playcanvas.com/llms.txt ; Editor MCP server: https://github.com/playcanvas/editor-mcp-server
26. Phaser v4.0.0 release: https://github.com/phaserjs/phaser/discussions/7274 (2026-04-10) ; v3→v4 migration guide: https://cdn.jsdelivr.net/npm/phaser@4.2.1/changelog/v4/4.0/MIGRATION-GUIDE.md ; Phaser 4.2: https://phaser.io/news/2026/07/phaser-4-2-spine-renderer-mesh2d-stencil
27. Phaser `llms.txt` and Phaser AE: https://phaser.io/llms.txt ; https://phaser.io/kernel
28. PixiJS releases: https://github.com/pixijs/pixijs/releases ; quick start: https://pixijs.com/8.x/guides/getting-started/quick-start.md
29. GameMaker LTS 2026: https://gamemaker.io/en/blog/lts-2026-release ; plans and pricing: https://gamemaker.io/en/get
30. Defold blog (1.14.0): https://defold.com/blog/ ; license: https://defold.com/license/ ; 1.13.0 release: https://forum.defold.com/t/defold-1-13-0-has-been-released/82980 ; Xbox support (secondary): https://www.digitalcitizen.life/defold-1-14-0-adds-free-xbox-support-for-approved-developers/
31. Bevy 0.20: https://bevy.org/news/bevy-0-20/ (2026-10-08) ; crates.io: https://crates.io/api/v1/crates/bevy
32. CrazyGames technical requirements: https://docs.crazygames.com/requirements/technical
33. Poki requirements: https://developers.poki.com/guide/requirements-quality
34. YouTube Playables requirements: https://developers.google.com/youtube/gaming/playables/certification/requirements_stability
35. WebGPU implementation status: https://github.com/gpuweb/gpuweb/wiki/Implementation-Status ; MDN browser-compat-data 8.1.8: https://cdn.jsdelivr.net/npm/@mdn/browser-compat-data@8.1.8/data.json
36. GDC, 2026 State of the Game Industry: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/ (Jan 2026)
37. Vibe Jam link-rot and engine analysis (secondary): https://www.michaelscheiwiller.com/blog/vibe-jam-link-rot
38. Godot docs, "Upgrading from Godot 3 to Godot 4": https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html
39. Unreal Engine forums, "HTML5 support?": https://forums.unrealengine.com/t/html5-support/1172997 ; Unreal Engine 4.24 Preview: https://forums.unrealengine.com/t/unreal-engine-4-24-preview/133067
