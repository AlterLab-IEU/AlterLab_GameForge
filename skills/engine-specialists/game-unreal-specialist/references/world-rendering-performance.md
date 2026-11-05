# World, Rendering and Performance Budgets (UE 5.8)

Read this before choosing a lighting path, turning on Nanite or World Partition, planning crowds
(Mass) or AI (StateTree), or profiling a frame. Numbers marked *Epic* come from Epic's documentation;
numbers marked *rule of thumb* are starting points for indie scope, to be replaced by your own
measurements on your minimum-spec hardware.

---

## 1. Frame budgets for indie scope

| Target | Frame budget | Typical split (*rule of thumb*) |
|---|---|---|
| 60 fps (PC, current consoles, Steam Deck "performance") | 16.6 ms | Game thread 8-10 ms, render thread 8-10 ms, GPU 14-15 ms with headroom |
| 30 fps (cinematic or handheld fallback) | 33.3 ms | Spend the extra time on GPU, not on more Blueprint Tick |

Profile on the **minimum-spec machine you will list on the store page**, in a packaged Development or
Test build, never only in the editor. The editor adds overhead and hides streaming and PSO hitches.

## 2. Lighting: pick a path in pre-production

| Path | Status (5.8) | Choose when | Cost notes |
|---|---|---|---|
| **Lumen, High/Epic** (software or hardware ray tracing) | Production | Dynamic time of day, destructible or player-built spaces, PC/console | *Epic:* Lumen GI + reflections + volumetric fog target 8 ms (30 fps) and 4 ms (60 fps) at 1080p on consoles |
| **Lumen Lite** (Medium GI: irradiance fields with probe occlusion) | Beta | Low-end PC, handhelds; Epic says about twice as fast as Lumen high quality and it is the new default for current-generation handhelds | At Medium, Lumen reflections are off and Screen Space Reflections are used |
| **Baked lighting** (GPU Lightmass) + SSGI/SSR | Production | Static levels, stylised art, the widest hardware range | Build time and lightmap memory instead of per-frame GPU cost |
| **MegaLights** | Production-ready in 5.8 | Many shadow-casting dynamic lights (interiors, neon, torches) | Still measure: light count is cheaper, not free |

**Lumen tuning that pays off** (from Epic's Lumen performance guide):

- Console device profiles default to 30 fps; for 60 fps set the GI and reflection scalability groups
  to High (for example `sg.GlobalIlluminationQuality=2`, `sg.ReflectionQuality=2`).
- Software ray tracing is Lumen's fastest tracing method; hardware ray tracing is Epic's recommended
  default on consoles but needs scene discipline: keep the ray tracing scene under about 100,000
  instances after culling.
- `r.Lumen.Reflections.Allow=0` (fall back to SSR) and `r.Lumen.Reflections.DownsampleFactor=2`
  are the cheapest big wins; avoid hit lighting in most games.
- Expose a Low setting that disables Lumen for the weakest hardware, and test it.

## 3. Nanite

Turn Nanite on for **static environment geometry by default**: rocks, architecture, props, kitbash.
Pair it with Virtual Shadow Maps. It removes manual LOD authoring and draw-call worries; it does not
remove disk and download size, so a 10-million-triangle scan everywhere still bloats the package.

Per the UE 5.8 Nanite documentation:

| Supported | Not supported or limited |
|---|---|
| Opaque and Masked materials | Translucent materials (and therefore mesh decals) |
| World Position Offset (displacement must be clamped) | Morph targets |
| Landscape, Landscape and Blueprint splines | Forward rendering, MSAA, VR stereo, lighting channels |
| Skeletal meshes via the Nanite skeletal mesh path (no geometry LODs; uses animation LODs) | Platforms without DX12/SM6-class GPUs; plan fallbacks |
| Foliage (Nanite Foliage was Experimental in 5.7) | Experimental native ray tracing of Nanite meshes |

Fallback meshes are used for ray tracing by default; lower Fallback Relative Error if ray-traced
shadows or reflections look blobby.

## 4. World Partition and large spaces

| Situation | Use |
|---|---|
| Discrete levels, arenas, a dungeon per map | Classic levels with level streaming. World Partition is overhead you do not need. |
| One continuous world, or 3+ people editing the same map | **World Partition**: automatic grid streaming, One File Per Actor (OFPA), Data Layers, HLODs |
| Reusable interiors or set pieces inside a partitioned world | **Level Instances** |

- **OFPA** stores each placed actor as its own file under `__ExternalActors__`, so two people can edit
  one map without binary merge conflicts. With Git it multiplies the file count; LFS locking still applies.
- **Data Layers** toggle sets of actors (quest states, seasonal dressing, debug).
- **HLODs** must be built (World Partition HLOD builder) before distant cells look right; rebuild as
  part of the content pipeline, not on release day. UE 5.8 improves the HLOD UX and adds World
  Partition streaming views to Unreal Insights.
- Tune runtime grid cell size and loading range against your traversal speed; a fast vehicle needs a
  larger loading range than a walking character.
- **Mesh Terrain** (Experimental, 5.8) is a 3D-mesh terrain that can do overhangs and tunnels; keep
  Landscape for shipping projects until it matures.
- **PCG** (production-ready since 5.7) for rule-based scattering and layout; the **Procedural
  Vegetation Editor** remains Experimental in 5.8.

## 5. AI at scale: StateTree, Behavior Trees, Mass

| Need | Use |
|---|---|
| A handful to a few dozen agents with rich decisions | **Behavior Trees** + Blackboard + EQS, or **StateTree** |
| State-machine-shaped logic (AI, door/encounter flow, NPC schedules) | **StateTree**: a general-purpose hierarchical state machine that combines behavior-tree selectors with states and transitions. UE 5.8 lets trees define their starting state and improves authoring. |
| Hundreds to thousands of simple agents (crowds, swarms, traffic) | **Mass** (MassEntity): data-oriented Fragments processed by stateless Processors, composed into Traits on a MassEntityConfig asset. In 5.8 Mass Signals moved into the core engine and entities can be created off the game thread. |
| Ambient interactions (benches, cover, workstations) | **Smart Objects**, claimed by BT, StateTree or Mass agents |

*Rule of thumb:* most indie games never need Mass. Reach for it when profiling shows per-actor
overhead (Tick, movement, animation) dominating with large agent counts, not before. Perception
(`UAIPerceptionComponent`), NavMesh agent sizes and EQS queries are the usual AI hot spots; give AI
a game-thread budget (for example 1-2 ms, *rule of thumb*) and time-slice decisions.

## 6. Niagara, materials, animation costs

- **Niagara:** GPU simulation for high particle counts, CPU only when gameplay must read particles.
  Pool short-lived systems (`ENCPoolMethod::AutoRelease` when spawning from C++), set Effect Types
  with scalability and significance culling, and watch `stat Niagara`. Cascade is legacy.
- **Materials:** one master material per surface family plus Material Instances; parameter changes
  on instances do not recompile shaders. Material Parameter Collections for global state (wetness,
  time of day). Substrate is production-ready since 5.7 and opt-in; enable it at project start rather
  than mid-production. Shader permutations and pipeline-state (PSO) compilation cause first-use
  hitches on PC; set up PSO precaching or a bundled PSO cache and test a clean-cache packaged run.
- **Animation:** keep Animation Blueprint work on the thread-safe path, use animation budgets or
  update-rate optimization for crowds, and cap active skeletal meshes in view.

## 7. Profiling workflow

1. **Reproduce in a packaged Development/Test build** on min-spec hardware with a fixed camera path
   or a replay.
2. **Classify the bottleneck** with `stat unit` (Game, Draw, GPU, RHI times) and `stat unitgraph`.
3. **Capture a trace** with Unreal Insights: launch with `-trace=default` (add `memory` or other
   channels as needed) and, for a file instead of a live session, `-tracefile=<path>.utrace`; or use
   `Trace.Start` / `Trace.Stop` in the console. Open it in `UnrealInsights` (in the engine's
   `Binaries/<Platform>` folder).
4. **Drill in:** Timing Insights for game/render thread, `ProfileGPU` or `stat gpu` for passes,
   Memory Insights or `memreport -full` for memory, Networking Insights for bandwidth, Audio Insights
   (production-ready in 5.8) for voices and mixing.
5. **Change one thing, re-measure, record** the before/after in the performance report.

| Command | Shows |
|---|---|
| `stat fps`, `stat unit`, `stat unitgraph` | Frame time and which thread is the bottleneck |
| `stat game`, `stat scenerendering`, `stat gpu` | Gameplay tick cost, draw/primitive counts, GPU passes |
| `ProfileGPU` | One-frame GPU breakdown |
| `stat streaming`, `stat memory`, `memreport -full` | Streaming pool and memory snapshots |
| `obj list class=<Class>` | Count live UObjects of a class (leak hunting) |
| `showdebug enhancedinput` | Active mapping contexts and action values |

## 8. Indie performance traps (check these first)

- [ ] Blueprint `Tick` enabled on many actors that only react to events
- [ ] `GetAllActorsOfClass` or line traces every frame instead of cached references or overlap events
- [ ] Synchronous loads (`LoadObject`, hard references) during gameplay
- [ ] Every light dynamic and shadow-casting without MegaLights or a light budget
- [ ] Translucent overdraw (smoke, glass, UI) at full screen resolution
- [ ] Unlimited Niagara systems with no significance or pooling
- [ ] Nanite-off high-poly meshes, or Nanite-on meshes with unsupported translucent materials
- [ ] No PSO cache: first-time hitches that reviewers call "stutter"
- [ ] Scalability settings that never reach Low or disable Lumen on weak hardware
