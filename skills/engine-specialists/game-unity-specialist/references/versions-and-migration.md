# Unity Versions, Licensing and Engine Migration (snapshot 2026-11-05)

Read this when choosing or upgrading a Unity version, answering pricing questions, or advising on a
move to or from Unity. Sources: GameForge's AI-tooling research brief (2026-11-05), Unity release
posts and Unity docs.

---

## 1. Which Unity version

| Stream | Status (Nov 2026) | Use it when |
|---|---|---|
| **Unity 6.3 LTS** (6000.3) | Released 2025-12-04; two years of support, to Dec 2027 (+1 year for Enterprise/Industry) | **Default for anything shipping in 2026-2027** |
| **Unity 6.6** (6000.6, Update release) | Released 2026-08-31; latest patch 6000.6.8f1 (2026-11-03) | You need a 6.4–6.6 feature (WebGPU out of experimental, Content Directories, dictionary serialization) and can upgrade again to the next LTS |
| **Unity 6.0 LTS** (6000.0) | **Standard support ended 2026-10-16.** Enterprise/Industry supported to 2027-10-16 | Plan the upgrade to 6.3 LTS now |
| **Unity 6.7** | Next release. Carries an experimental CoreCLR desktop player. Date not committed in Unity's Oct 2026 update | Evaluate on a branch |
| **Unity 7.0 alpha** | 2026-10-05. First CoreCLR Editor (no Mono); C# 9 / .NET Standard 2.1. Not for production | Compatibility testing only |

Cadence: one LTS a year with two years of support, plus several Update releases a year.

**Upgrade hygiene:**
- Upgrade on a branch, with the Library cache deleted.
- Read the "Upgrade to Unity 6.x" guide for every version you skip.
- Accept API Updater changes in a separate commit.
- Run the full test suite and a Play Mode smoke pass per scene before merging.

---

## 2. Feature log that changes advice

**6.0** (Oct 2024):
- GPU Resident Drawer.
- STP upscaler.
- Render graph on by default in URP.
- UI Toolkit runtime data binding.
- `Awaitable` matured.
- Build Profiles.
- The Rigidbody renames (`linearVelocity`, `linearDamping`).
- Multiplayer Center.

**6.3 LTS** (Dec 2025), per Unity's release post:
- Platform Toolkit: a unified API for accounts, saves, controller ownership and achievements.
- Native screen reader support on Windows, macOS, Android and iOS.
- A low-level 2D physics API built on Box2D v3.
- UI Toolkit: native SVG and a Shader Graph UI target.
- Shader Graph terrain support.
- "Render 3D as 2D" sorting.
- Shader Build Settings.
- Render Graph utility passes.
- Profiler Highlights module.
- Scriptable Audio Pipeline (Burst "Scriptable Processors").
- Netcode for Entities host migration.
- `UnityWebRequest` uses HTTP/2 where available.
- Unity Building Blocks.

**6.4:**
- URP Compatibility Mode removed: render graph only.
- ECS packages became core packages.
- The `EntityId` transition began.

**6.5:**
- Built-in Render Pipeline deprecated (available through 6.7 LTS).
- HDRP Switch 2 support.

**6.6** (Aug 2026), per "What's new in Unity 6.6":
- New projects default to Enter Play Mode without domain reload.
- Native `Dictionary` serialization.
- Content Directories replace AssetBundle builds.
- WebGPU "no longer an experimental release"; WebAssembly64; Progressive Asset Loading.
- UI Toolkit `backdrop-filter`.
- Cinemachine, Timeline and Animation Rigging are core packages.
- Burst is a built-in module.
- Dynamic batching is obsolete.
- Compute Light Baker; the Progressive CPU Light Baker is deprecated.
- Managed ECS components are deprecated.
- OpenGL ES 3.0 dropped on Android.
- Intel macOS deprecated.
- `GetInstanceID` removed in favour of `GetEntityId`.

---

## 3. Licensing and pricing

- **Runtime Fee:** cancelled in Sept 2024. There is no per-install fee.
- **Personal:** free for individuals and businesses with up to US$200K in revenue and funding.
- **Pro:** rose 5% on 2026-01-12, from US$2,200 to **US$2,310 per seat per year** (US$210/month on the
  monthly plan), per Unity's pricing-updates page.
- **Enterprise:** required above US$25M annual revenue; custom pricing.
- **Unity AI:** included in Pro and above. Personal users pay US$10/month for credits. AI Gateway lets
  you bring your own agent subscription.

Prices change. Link the user to `unity.com/products/pricing-updates` rather than quoting from memory
in a budget.

---

## 4. When Unity is the right engine

- **Many platforms from one codebase:** mobile, Switch and Switch 2, PlayStation, Xbox, PC, XR and
  Web. 6.3's Platform Toolkit reduces per-platform account, save and achievement work.
- **2D with a mature toolset:** URP 2D Renderer, tilemaps, Sprite Atlas Analyzer, Box2D v3 low-level
  API.
- **XR:** OpenXR plus vendor SDKs (Meta, Android XR, visionOS via PolySpatial).
- **Teams that know C#** and want the largest third-party asset and tooling market.
- **Agent-assisted teams:** in late 2026, Unity ships an official Claude Code plugin and an MCP server
  (both in beta under Unity AI). Unreal 5.8's MCP plugin is experimental and editor-only, and Godot
  has no official server.

## 5. When to look elsewhere

- **Top-end 3D fidelity** where Nanite/Lumen-class features are central: Unreal (`game-unreal-specialist`).
- **Tiny, open-source, text-first projects,** or a team that wants no licence tiers: Godot (`game-godot-specialist`).
- **Web-first games with tight download budgets:** Three.js/R3F (`game-threejs-specialist`), or
  Phaser/PixiJS (`game-web2d-specialist`).
- **Unity's real costs:**
  - Stack choices multiply: URP or HDRP, UGUI or UI Toolkit, MonoBehaviour or ECS, NGO or Netcode
    for Entities.
  - Editor iteration slows on large projects.
  - Per-seat Pro pricing above the Personal threshold.
  - The 2023 Runtime Fee episode, although cancelled, is still a trust factor for some teams. Note it
    as a business risk; do not editorialise.

## 6. Coming from another engine

**From Godot:**
- A `Node` tree becomes `GameObject` + components.
- `Resource` becomes `ScriptableObject`.
- `@export` becomes `[SerializeField] private`.
- Signals become C# events or SO event channels.
- GDScript hot reload becomes a compile/reload cycle. Assembly definitions keep it short.
- Scenes and prefabs are YAML with GUID references. They are not hand-editable like `.tscn`.

**From Unreal:**
- Blueprints have no first-party equivalent; logic is C#. Visual scripting exists but is rarely the
  main tool.
- The Gameplay Framework (GameMode, PlayerState) is yours to build. A small set of SO-configured
  services usually suffices.
- GAS maps loosely to an SO-driven ability system.
- Replication maps to NGO or Netcode for Entities (`/gameforge:game-multiplayer`).
- No Nanite/Lumen equivalent. Plan LODs, lightmaps, APV and GPU Resident Drawer instead.

**First-week gotchas:**
- Confirm Force Text serialization and Visible Meta Files before the first commit.
- Commit `.meta` files with their assets, always.
- Prefabs and nested prefabs keep scene merges small. Use UnityYAMLMerge (Smart Merge) for the rest.
- Pick one stack per axis (pipeline, UI, input, architecture) and write it down in an ADR.

**Port effort** (rules of thumb, not measured data; scale by asset count and platform count):

| Project | Rough effort |
|---|---|
| Jam game or prototype (<10K lines) | 1-2 weeks |
| Small commercial indie (10-50K lines) | 2-4 months |
| Shipped title (50K+ lines, several platforms) | 4-8+ months |
