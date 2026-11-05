# Unity Rendering, Performance and Web Builds (Unity 6.3 LTS / 6.6)

Read this file before choosing a render pipeline, writing a renderer feature, chasing frame time,
or shipping a Web build.

---

## 1. Render pipeline choice

Unity's "Render pipelines strategy for 2026" page sets the direction:

- **URP** gets Unity's rendering investment. Planned work includes performance, build times,
  extensibility, real-time GI and SSR. Unity "strongly encourage[s] using URP when starting any new
  project."
- **HDRP:** "no new features are planned". Work is limited to stability, regressions, critical
  issues and Nintendo Switch 2 support (planned for 6.5). It remains a path for existing HDRP titles.
  Do not start a new indie project on it without a reason the user can name.
- **Built-in Render Pipeline (BIRP)** is deprecated as of 6.5. It stays available through 6.7 LTS,
  with support at least to the end of 2028 (2029 for Enterprise/Industry). No removal version is set.

| Project | Pipeline | Notes |
|---|---|---|
| 2D, pixel art, mobile, Switch, VR, web | URP (2D Renderer for 2D) | 6.3 adds "render 3D as 2D" sorting with 2D lights |
| Stylised or mid-fidelity 3D | URP (Forward+) | Forward+ is required for GPU Resident Drawer |
| Existing HDRP game | Stay on HDRP | Plan no new HDRP-only features |
| Existing BIRP game | Port to URP on a branch | Shaders, materials and post-processing are all pipeline-specific |

Switching pipelines mid-production means redoing every custom shader, material and post effect.
Decide during pre-production and record it in an ADR
(`${CLAUDE_PLUGIN_ROOT}/templates/architecture-decision-record.md`).

---

## 2. URP render graph

Render graph is the only path for custom URP passes from Unity 6.4. The 6.4 upgrade guide says
Compatibility Mode is fully removed and the `URP_COMPATIBILITY_MODE` define is gone. On 6.3 LTS,
Compatibility Mode still exists, but write new passes against render graph anyway.

What changes for code (and what agents get wrong):

- Implement `RecordRenderGraph(RenderGraph, ContextContainer)`. Do not implement `Execute(...)` or
  `OnCameraSetup(...)`; those are the pre-render-graph API.
- Get cameras and targets from `frameData.Get<UniversalResourceData>()` and
  `frameData.Get<UniversalCameraData>()`, not from `RenderingData`.
- Blit with `RenderGraphUtils` / `AddBlitPass`, not `cmd.Blit` or `Blitter` calls on a command
  buffer you fetched yourself.

Minimal full-screen material pass. This follows Unity's URP "blit with render graph" pattern;
compare it against the sample in your URP version's docs before relying on it.

```csharp
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public sealed class TintFeature : ScriptableRendererFeature
{
    [SerializeField] private Material _material;
    private TintPass _pass;

    public override void Create()
    {
        _pass = new TintPass
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing,
            requiresIntermediateTexture = true
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (_material == null) return;
        _pass.Setup(_material);
        renderer.EnqueuePass(_pass);
    }

    private sealed class TintPass : ScriptableRenderPass
    {
        private Material _material;

        public void Setup(Material material) => _material = material;

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            UniversalResourceData resources = frameData.Get<UniversalResourceData>();
            if (resources.isActiveTargetBackBuffer) return;

            TextureHandle source = resources.activeColorTexture;
            TextureDesc desc = renderGraph.GetTextureDesc(source);
            desc.name = "_TintColor";
            desc.clearBuffer = false;
            TextureHandle destination = renderGraph.CreateTexture(desc);

            var blit = new RenderGraphUtils.BlitMaterialParameters(source, destination, _material, 0);
            renderGraph.AddBlitPass(blit, passName: "Tint");
            resources.cameraColor = destination;
        }
    }
}
```

Unity's agent plugin ships a skill for reviewing a `ScriptableRendererFeature` for render graph
problems, according to Unity's plugin docs. Use it if the user has the plugin installed.

---

## 3. Shader Graph and VFX Graph

- **Sub Graphs** for reusable logic: noise, UV tricks, dissolve masks.
- **Custom Function nodes** for HLSL the node library lacks. Keep the HLSL in `.hlsl` files under
  version control rather than in inline strings.
- **Keywords** create variants. Each keyword multiplies variant count, so prefer local keywords.
  Use 6.3's Shader Build Settings to strip or convert keywords without code.
- **6.3:** a Terrain target and a UI target (custom UI Toolkit shaders).
- **6.6:** particle nodes for the Built-in Particle System in URP, and preprocessor directives in
  Graph Settings.
- **VFX Graph** runs on the GPU and handles large particle counts, but it does not interact with CPU
  physics. Trigger effects with `VisualEffect.SendEvent`, passing an event ID cached once with
  `Shader.PropertyToID("OnHit")`.
- **WebGL 2** has no compute shaders. VFX Graph needs compute, so check the target before promising
  GPU particles on Web (WebGPU changes this; see §6).

Common recipes: dissolve (noise, Step, Alpha Clip), scrolling UVs (Time, Multiply, Add to UV),
triplanar for untextured geometry, and outlines (inverted-hull or a full-screen edge pass).

---

## 4. Performance workflow

Profile first, on the target device, with a Development Build and Autoconnect Profiler. Editor
numbers lie about player performance.

| Tool | Use it for |
|---|---|
| Profiler (CPU/GPU/Memory modules; 6.3 Highlights module) | Frame-time breakdown, GC alloc per frame |
| Profile Analyzer | Comparing captures before and after a change |
| Memory Profiler package | Leaks, duplicate textures, Addressables handles never released |
| Frame Debugger (6.6 shows constant-buffer values) | Draw-call order, batching breaks, overdraw causes |
| Project Auditor | Static analysis of code and settings; 6.6 adds a statics-reset analyzer |
| UI Toolkit Profiler modules (6.6) | Runtime UI cost |

**Rendering cost levers (Unity 6):**
- **SRP Batcher:** on by default in URP. Keep materials SRP Batcher-compatible.
- **GPU Resident Drawer:** Unity 6. Needs Forward+ in URP. Aimed at scenes with many instances of
  the same meshes. Measure it on your lowest target before and after; do not assume a win.
- **Static batching** for immovable geometry. **Dynamic batching is obsolete in 6.6.** Do not
  recommend enabling it.
- **STP (Spatial-Temporal Post-processing):** Unity 6's built-in upscaler for render-scale wins.
- **LOD Groups and occlusion culling** for dense 3D scenes. Bake occlusion for interiors.
- **Lighting:** 6.6 adds the Compute Light Baker and deprecates the Progressive CPU Light Baker.

**C# hot-path rules:**
- Zero allocations per frame in steady state. No LINQ, no string concatenation, no boxing, and no
  `new List<T>()` inside `Update`.
- Cache `GetComponent` results, `Animator.StringToHash`, `Shader.PropertyToID` and `WaitForSeconds`.
- Use the non-allocating physics queries (`Physics.RaycastNonAlloc`, `OverlapSphereNonAlloc`) and
  `CompareTag` instead of `tag ==`.
- Pool frequently spawned objects with `UnityEngine.Pool.ObjectPool<T>`.
- Thousands of homogeneous entities: consider Jobs + Burst first, then ECS (see `dots-ecs.md`).

**Rule-of-thumb budgets** (starting points to confirm by profiling, not Unity numbers):

| Target | Frame | Draw calls / SetPass | Texture memory |
|---|---|---|---|
| Mid-range Android, 30 fps | 33.3 ms | ~100-200 | ~300-500 MB |
| Switch-class handheld, 30-60 fps | 16.6-33.3 ms | ~300-800 | ~1-1.5 GB |
| Desktop, 60 fps | 16.6 ms | ~1,000-3,000 | Depends on min spec |
| Web, mobile browser | 33.3 ms | ~100-200 | Keep the heap small (iOS memory crashes) |

---

## 5. Platform notes that bite (6.6)

- Android: **OpenGL ES 3.0 is no longer supported** in 6.6, and only adaptive icons are supported.
- macOS: Intel (x86_64) support is **deprecated** in 6.6, and Unity will remove it in a future release.
- `UNITY_64` and `DEVELOPMENT_BUILD` scripting symbols are deprecated in 6.6 in favour of a new
  managed code variant setting. Search the code for them before upgrading.
- Burst is a built-in module in 6.6 rather than a separate package.

---

## 6. Web builds (Unity "Web" platform, formerly WebGL)

**When Unity Web is the right call:** you already have a Unity game and want a browser demo, a portal
release or a jam build. **When it is not:** a web-first game with tight download budgets. Download
size, start-up time and iOS memory are where Unity Web struggles. A web-native stack is usually
better there: route 3D to `game-threejs-specialist` and 2D to `game-web2d-specialist`. Shipping and
portals go to `/gameforge:game-web-publish`.

### WebGPU status

- **Unity 6.6:** "What's new in Unity 6.6" has the heading "WebGPU no longer an experimental
  release". GameForge's web-stack research brief rated this claim **UNVERIFIED** because it had only
  a secondary source. The primary What's New page now states it.
- WebGPU is still **opt-in**. Unity enables WebGL 2 by default.
- **To enable it:** Player Settings > Web > Other Settings, untick **Auto Graphics API**, add
  **WebGPU** and drag it to the top of the list. Keep **WebGL 2** below it as the fallback. Unity
  tries the next API on the list when the browser lacks the first.
- Also in 6.6: WebGPU device filtering and a stricter compatibility mode.
- **WebAssembly64** allows up to 16 GB of memory. Unity says it "isn't recommended for load-time
  sensitive scenarios", and Safari does not support it.
- **Progressive Asset Loading** for Web builds is new in 6.6.
- **Browser support** (per the web brief):
  - Chrome/Edge 113+ on desktop.
  - Safari 26+.
  - Firefox on Windows from 141 and on Apple Silicon macOS from 145/147.
  - **Still a WebGL 2 fallback case:** Firefox on Linux, Firefox on Android and Intel Macs.
- On 6.3 LTS, treat WebGPU as experimental and ship WebGL 2.

### Settings checklist

- [ ] Compression: Brotli (or Gzip) with correct `Content-Encoding` headers from the host. Tick
      **Decompression Fallback** only when the host cannot set headers; it costs start-up time.
- [ ] Managed Stripping Level High, and IL2CPP code generation optimised for size. Keep a
      `link.xml` for reflection-only types.
- [ ] Texture compression suited to the targets: ASTC/ETC2 for mobile browsers, DXT/BC for desktop.
- [ ] Load content on demand with Addressables or 6.6 Progressive Asset Loading. Keep the first
      download small.
- [ ] Assume C# code runs on the main thread. Do not depend on `Task.Run` or
      `Awaitable.BackgroundThreadAsync` for parallelism.
- [ ] Start audio only after a user gesture, because browsers block autoplay.
- [ ] Test on a real iPhone. CrazyGames disables Unity games on iOS by default because of memory
      crashes (per its technical requirements).
- [ ] Portal budgets (CrazyGames, per its technical requirements):
  - 50 MB or less initial download, and 20 MB or less for the mobile homepage.
  - 250 MB and 1,500 files total.
- [ ] Poki warns that players leave after about 10 s of loading. Measure time-to-first-input.
