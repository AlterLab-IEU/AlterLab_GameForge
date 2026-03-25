# AlterLab GameForge -- Engine Comparison Matrix

This document provides a structured comparison of the three major game engines for indie development: Godot, Unity, and Unreal Engine. It is the canonical reference for engine selection decisions across all GameForge skills. Every recommendation here is grounded in shipped games and real-world production experience, not marketing material.

---

## Quick Decision Matrix

**Use Godot if...**
- You are a solo developer or small team (1-5 people)
- You are building a 2D game or a stylized 3D game
- You want to own your tools with no licensing strings attached
- You value a lightweight, fast-iterating development environment
- You want GDScript's accessibility or are comfortable with C#
- You are making a jam game, prototype, or your first commercial release
- Budget is tight and you cannot afford Unity Pro or Unreal's revenue share at scale

**Use Unity if...**
- You need broad platform support (mobile, console, PC, VR, web) from one codebase
- You are building a 2D or 3D game of moderate visual complexity
- Your team knows C# and wants a massive ecosystem of third-party assets and plugins
- You need proven production pipelines for mid-scope projects (10-50 hour games)
- You are targeting mobile as a primary platform
- You want the largest pool of tutorials, documentation, and hirable developers

**Use Unreal Engine if...**
- Visual fidelity is a core pillar of your game (photorealistic or high-end stylized)
- You are building a 3D game and need AAA-grade rendering (Nanite, Lumen, MetaHumans)
- Your team includes C++ developers or you are willing to use Blueprints extensively
- You need large open-world streaming, massive environments, or cinematic production tools
- You are building a multiplayer shooter or action game at scale
- You are comfortable with a heavier engine in exchange for rendering power

---

## Feature Comparison

| Dimension | Godot 4.x | Unity 6 (2025) | Unreal Engine 5.5 |
|---|---|---|---|
| **License** | MIT (fully open source, no fees ever) | Free tier (Revenue < $200K). Plus $399/seat/year. Pro $2,040/seat/year. Runtime fee controversially introduced 2023, partially rolled back 2024. | Free until $1M gross revenue, then 5% royalty. First $1M is always royalty-free. |
| **Primary languages** | GDScript (Python-like), C#, C++ (via GDExtension) | C# | C++, Blueprints (visual scripting) |
| **2D capabilities** | Excellent. Purpose-built 2D renderer, pixel-perfect support, TileMap system, 2D physics, 2D lighting. Best-in-class for 2D among the three. | Good. 2D toolkit with Tilemap, SpriteRenderer, 2D physics. Mature but less elegant than Godot's dedicated 2D pipeline. | Weak for pure 2D. Paper2D exists but is deprecated/unsupported. Use Godot or Unity for 2D. |
| **3D rendering** | Capable. Vulkan-based renderer with PBR, global illumination (SDFGI, VoxelGI), and decent visual quality. Not AAA-grade but sufficient for stylized and mid-fidelity 3D. | Strong. URP for performance, HDRP for high fidelity. Shader Graph for visual shader authoring. Proven in production across thousands of 3D games. | Best-in-class. Nanite (virtualized geometry), Lumen (global illumination), MetaHumans, virtual shadow maps. The rendering benchmark. |
| **Editor size / startup** | ~80 MB download. Launches in seconds. Minimal resource footprint. | ~10-15 GB install. Moderate startup time. Hub + Editor architecture. | ~50-100 GB install. Heavy startup. Shader compilation on first project open can take 30+ minutes. |
| **Build times** | Fast. Incremental builds in seconds for GDScript. C# builds slightly slower. | Moderate. C# compilation is fast, but asset processing and shader compilation add time. IL2CPP builds (for mobile/console) are slow. | Slow. C++ compilation is inherently slow. Hot reload helps iteration but full builds take minutes to hours depending on project size. |
| **Asset store / marketplace** | Small but growing. Godot Asset Library has fewer assets than competitors. Community plugins fill gaps. | Massive. Unity Asset Store is the largest game dev marketplace. Thousands of production-ready assets, tools, and plugins. | Large. Unreal Marketplace has high-quality assets, many free monthly offerings, and Megascans (free with UE). Quality floor is higher than Unity Asset Store. |
| **Platform export** | Windows, macOS, Linux, Android, iOS, Web (HTML5). Console support possible via third-party (W4 Games provides console porting services). | Windows, macOS, Linux, Android, iOS, Web, PS4/PS5, Xbox, Switch. Broadest first-party console support. | Windows, macOS, Linux, Android, iOS, PS4/PS5, Xbox, Switch. Strong console support. |
| **Console support** | No first-party console export. W4 Games (founded by Godot contributors) offers commercial console porting. Community efforts exist but are not production-ready without external support. | First-party console support included. The standard path for indie-to-console. | First-party console support included. Stronger for AAA console titles. |
| **Multiplayer / networking** | Built-in high-level multiplayer API (RPCs, synchronizers). ENet and WebSocket support. Adequate for indie-scale multiplayer. | Mirror (community), Netcode for GameObjects (Unity official), Photon (third-party). Fragmented but options exist for every scale. | Replication system battle-tested by Fortnite. Best built-in networking for large-scale multiplayer. |
| **Audio** | Basic audio bus system. Positional audio. Adequate for most needs. No built-in adaptive audio. | FMOD and Wwise integration available. Built-in audio is functional but most serious projects use middleware. | Built-in MetaSounds system for procedural/adaptive audio. Excellent for dynamic soundscapes. |
| **UI / HUD** | Control nodes with anchoring, theming, and responsive layout. Clean and intuitive for game UI. | Canvas/UI Toolkit (newer). UI Toolkit is powerful but the Canvas system remains more commonly used. Mature but transitioning. | UMG (Unreal Motion Graphics). Powerful but complex. Slate for editor/tool UI. |
| **Animation** | AnimationPlayer, AnimationTree, Tween system. Good for 2D. 3D animation is functional but less polished than competitors. | Mecanim (state machine), Timeline, Animation Rigging. Mature and well-documented. | Sequencer (cinematic), Control Rig, animation state machines, IK. Best-in-class for character animation and cinematics. |
| **Version control** | Text-based scene format (`.tscn`, `.tres`). Git-friendly. Merging scene files is feasible. | Binary scene format by default. Unity YAML mode enables text scenes but merge conflicts are painful. Plastic SCM (Unity-owned) or Git LFS recommended. | Binary assets (.uasset). Git is difficult. Perforce is the standard. Unreal Git plugin exists but large projects struggle. |
| **Documentation** | Good official docs. Growing community tutorials. Smaller knowledge base than competitors. GDScript has fewer Stack Overflow answers. | Excellent. Massive tutorial ecosystem, extensive official docs, years of community content. Most Googleable engine. | Good official docs but dense. Steeper learning curve documentation. Community content tends toward advanced topics. |
| **Learning curve** | Low for 2D. Moderate for 3D. GDScript is approachable for beginners. Node-based architecture is intuitive. | Moderate. C# is accessible. Component system takes time to master. Massive feature set means many ways to do the same thing. | High. C++ is inherently harder. Blueprints lower the barrier but complex systems require code. Engine complexity is significant. |
| **Performance** | Good for indie scale. Vulkan renderer is capable. Not suited for massive open worlds or photorealistic rendering. GDScript is slower than C#/C++ but rarely the bottleneck for indie-scope games. | Good. IL2CPP provides near-native performance for C# code. DOTS/ECS for data-oriented high-performance scenarios (steep learning curve). | Best raw performance. C++ with engine optimizations. Nanite and World Partition handle massive scenes. Built for scale. |

---

## Team Size Recommendations

| Team Size | Recommended Engine | Reasoning |
|---|---|---|
| Solo developer | Godot or Unity | Godot for 2D or if budget is zero. Unity for broader platform needs or 3D. Both have low-friction solo workflows. |
| 2-5 person team | Godot, Unity, or Unreal | All viable. Choose based on genre and visual target. Godot for 2D/stylized, Unity for cross-platform, Unreal for visual fidelity. |
| 6-15 person team | Unity or Unreal | At this scale, asset pipelines, team collaboration tools, and production-proven workflows matter more. Godot's ecosystem is thinner for larger team coordination. |
| 15+ person team | Unity or Unreal | Enterprise tooling, console deployment pipelines, and established production workflows become critical. |

---

## Genre Fit

| Genre | Best Fit | Good Fit | Avoid |
|---|---|---|---|
| 2D Platformer | **Godot** (Brotato, Dome Keeper's UI layer) | Unity (Celeste, Hollow Knight) | Unreal (overkill, weak 2D tools) |
| 2D RPG / Visual Novel | **Godot** | Unity (extensive VN plugins) | Unreal |
| Top-Down Action | **Godot** (Dome Keeper) | Unity (Enter the Gungeon) | Unreal |
| Roguelike / Roguelite | **Godot** (Brotato) | Unity (Dead Cells, Hades used proprietary) | Unreal (overhead not justified) |
| Pixel Art Games | **Godot** (pixel-perfect rendering) | Unity (with setup) | Unreal |
| 3D Platformer | Unity (A Hat in Time) | Unreal, Godot (capable but less proven) | -- |
| 3D First-Person | Unity (Firewatch) or Unreal (depends on fidelity target) | Godot (for stylized/low-poly) | -- |
| Open World RPG | **Unreal** (World Partition, Nanite) | Unity (for smaller worlds) | Godot (not proven at scale for large open worlds) |
| FPS / TPS (Multiplayer) | **Unreal** (Fortnite, networking stack) | Unity (for indie scale) | Godot (networking is capable but less battle-tested) |
| Strategy / Management Sim | **Unity** (RimWorld, Cities: Skylines) | Godot (for 2D strategy) | Unreal (overhead not justified) |
| Horror | Unity (Phasmophobia) or Unreal (depends on visual needs) | Godot (for 2D horror or stylized) | -- |
| Racing | **Unreal** (rendering quality matters) | Unity | Godot (limited 3D vehicle physics tooling) |
| Fighting Game | **Unity** (proven pipeline) | Unreal | Godot (limited fighting game community tooling) |
| Social / Casual | **Unity** (Among Us, mobile deployment) | Godot (for PC/mobile) | Unreal (overkill) |
| VR | **Unity** (broadest VR SDK support) or Unreal (for visual fidelity) | -- | Godot (VR support exists but is less mature) |

---

## Performance Characteristics

| Characteristic | Godot 4.x | Unity 6 | Unreal 5.5 |
|---|---|---|---|
| **Draw calls** | Efficient batching for 2D. 3D draw call overhead higher than competitors for complex scenes. | SRP Batcher reduces draw calls effectively. Good for mid-complexity scenes. | Nanite eliminates traditional draw call concerns for static geometry. Industry-leading. |
| **Physics** | Godot Physics (built-in) or Jolt Physics (integration available). Adequate for indie scale. Not suited for large-scale simulations. | PhysX (NVIDIA) built-in. Reliable and well-optimized. DOTS Physics for ECS-based simulations. | Chaos Physics. Handles large-scale destruction and simulation. Heavier but more capable. |
| **Memory footprint** | Low. Lightweight runtime. Suitable for low-spec hardware and web export. | Medium. Managed runtime (Mono or IL2CPP) adds overhead. Mobile-optimized with URP. | High. Largest runtime footprint. Expects modern hardware. Not ideal for low-spec targets. |
| **Shader compilation** | Fast. Vulkan shader compilation is quick. Minimal stutter on first encounter. | Shader compilation stutter remains an issue in some pipelines. Shader prewarming helps. | Shader compilation can cause significant hitches. PSO caching and precompilation are essential. |
| **Loading times** | Fast. Small project sizes and lightweight scene format. | Moderate. Addressables system for async loading. Scene management adds complexity. | Slow without optimization. World Partition helps for open worlds. Level streaming is powerful but requires setup. |
| **Target hardware floor** | Integrated GPUs, older machines, web browsers. Runs on modest hardware. | Mid-range GPUs for 3D (URP). HDRP requires dedicated GPUs. Mobile-capable. | Dedicated GPUs recommended. Nanite/Lumen require modern hardware. Scalability settings can target lower specs. |

---

## Cost Analysis (2025)

### Godot

| Item | Cost |
|---|---|
| Engine license | $0 (MIT, forever) |
| Console porting (via W4 Games) | ~$15K-50K per platform (estimate, varies by project) |
| Asset Store spending (typical indie) | $0-500 (smaller marketplace, more DIY) |
| Total first-year cost (PC-only) | **$0** |
| Total first-year cost (PC + 1 console) | **~$15K-50K** (porting cost) |

### Unity

| Item | Cost |
|---|---|
| Personal tier | $0 (revenue/funding < $200K/year) |
| Plus tier | $399/seat/year (revenue < $200K but want extra features) |
| Pro tier | $2,040/seat/year (required above $200K revenue) |
| Runtime fee (2024+ revision) | Applies only above $1M trailing 12-month revenue AND 1M installs. Most indies exempt. |
| Asset Store spending (typical indie) | $200-2,000 (huge marketplace, many useful tools) |
| Total first-year cost (solo, < $200K revenue) | **$0-2,000** (asset spending only) |
| Total first-year cost (5-person team, > $200K) | **$10,200-12,200** (Pro licenses + assets) |

### Unreal Engine

| Item | Cost |
|---|---|
| Engine license | $0 until $1M gross revenue, then 5% royalty |
| First $1M | Always royalty-free |
| Megascans, Quixel, MetaHumans | Free with Unreal Engine |
| Marketplace spending (typical indie) | $0-1,000 (many free high-quality assets) |
| Total first-year cost (< $1M revenue) | **$0-1,000** |
| Total cost on $2M gross revenue | **$50,000** (5% of revenue above $1M) |
| Total cost on $5M gross revenue | **$200,000** (5% of revenue above $1M) |

**Honest cost assessment**: Godot is free forever. Unity is free until you succeed, then gets expensive per-seat. Unreal is free until you succeed, then takes a percentage. For an indie game that earns under $1M (the vast majority), all three engines are effectively free. The cost difference only matters when your game is profitable -- and at that point, you can afford it.

---

## 2025 State of Play: Honest Assessments

### Godot

**Strengths**: Completely open source -- no company can change the license terms or introduce surprise fees (the Unity runtime fee fiasco of 2023 drove significant migration to Godot). The 4.x release series brought Vulkan rendering, improved 3D capabilities, C# support, and a modernized editor. The community is growing fast. For 2D games, Godot is arguably the best engine available. The text-based scene format makes version control painless.

**Weaknesses**: The 3D pipeline, while improved, cannot compete with Unity or Unreal for visual fidelity. Console deployment requires third-party services. The asset ecosystem is smaller, meaning more DIY work. Some advanced features (terrain, large-scale navigation, complex physics) require community plugins that vary in quality. C# support in Godot 4 is stable but newer than Unity's decades of C# maturity.

**Trajectory**: Accelerating. Godot's monthly downloads tripled after Unity's 2023 pricing controversy. W4 Games is building commercial infrastructure (console porting, enterprise support). The engine is maturing fast but still trails Unity and Unreal in production-proven tooling.

**Shipped games of note**: Dome Keeper (roguelike mining, 2022), Brotato (arena survivor, 2023), Cassette Beasts (creature collector, 2023), Halls of Torment (horde survivor, 2023), Luck be a Landlord (roguelike deckbuilder, 2022). Mostly 2D, mostly indie scale -- which is exactly where Godot excels.

### Unity

**Strengths**: The largest ecosystem in indie game development. More shipped indie games run on Unity than any other engine. C# is productive, the Asset Store saves months of development, and platform coverage (especially mobile and console) is unmatched. The engine does everything adequately and many things well.

**Weaknesses**: The 2023 runtime fee announcement shattered community trust. While largely walked back, the damage to Unity's reputation persists. The engine has accumulated technical debt -- there are often 2-3 ways to do the same thing (old way, new way, newer way still in preview). DOTS/ECS has been "the future" for years with slow adoption. The company's financial instability (layoffs, leadership changes, strategic pivots) creates ongoing uncertainty about long-term direction.

**Trajectory**: Stabilizing after turbulence. Unity 6 is a consolidation release focusing on stability and performance. The new leadership is attempting to rebuild trust. Unity remains the pragmatic default choice for most indie developers, but it is no longer the only obvious choice.

**Shipped games of note**: Hollow Knight (Metroidvania, 2017), Cuphead (run-and-gun, 2017), Celeste (platformer, 2018), RimWorld (colony sim, 2018), Among Us (social deduction, 2018/2020), Ori and the Will of the Wisps (2020), Disco Elysium (RPG, 2019), Escape from Tarkov (FPS, 2017+), Genshin Impact (action RPG, 2020). The breadth is unmatched.

### Unreal Engine

**Strengths**: The best rendering technology available. Nanite and Lumen are generational leaps. MetaHumans provide production-ready digital humans. The networking stack powers Fortnite (250M+ players). Blueprints make the engine accessible to non-programmers. Epic's Megascans library (free with UE) provides photorealistic assets. The 5% royalty after $1M is straightforward and only kicks in when you are successful.

**Weaknesses**: The heaviest engine by far. Project sizes, build times, and hardware requirements are significantly higher. The learning curve is steep, especially for C++. Iteration speed is slower than Godot or Unity for rapid prototyping. 2D support is effectively nonexistent. Small indie teams may find the engine's complexity overhead does not justify the rendering power if their game is stylized or 2D. The engine is optimized for larger teams with specialized roles.

**Trajectory**: Dominant in AAA, growing in AA-indie. Unreal 5.5 continues to improve Nanite, Lumen, and World Partition. The barrier for indie teams is not cost (it is free until $1M) but complexity and iteration speed. Unreal is the right choice for visually ambitious 3D games and the wrong choice for a 2D roguelike.

**Shipped games of note**: Fortnite (battle royale, 2017+), Returnal (roguelike shooter, 2021), Hellblade II: Senua's Saga (narrative action, 2024), The Talos Principle 2 (puzzle, 2023), Ghostrunner (action, 2020), Mortal Shell (soulslike, 2020). Fewer small-indie titles, more AA and AAA productions.

---

## Migration Difficulty Matrix

If you are considering switching engines mid-project, understand the cost.

| From / To | Godot | Unity | Unreal |
|---|---|---|---|
| **From Godot** | -- | Medium. GDScript to C# requires rewrite. Scene structure concepts are similar. Assets (art, audio) transfer directly. | Hard. GDScript to C++/Blueprints is a large translation. Different scene paradigm. 2D-to-3D migration adds complexity. |
| **From Unity** | Medium. C# knowledge helps (Godot 4 supports C#). Component-to-node paradigm shift. Assets transfer. Unity-specific plugins must be replaced. | -- | Hard. C# to C++. Component system to Actor/Component. Different asset pipeline. Shader rewrite. Expect 60-80% code rewrite. |
| **From Unreal** | Hard. C++/Blueprints to GDScript/C#. Significant paradigm shift. Rendering downgrade likely. | Medium-Hard. C++ to C#. Actor model to GameObject model. Material/shader rewrite. Assets transfer but pipeline changes. | -- |

**General migration rules**:
- Art assets (textures, 3D models, audio) transfer between engines with minor format adjustments
- Code never transfers. Budget a full rewrite.
- Game design documents, spreadsheets, and design systems transfer completely.
- Shaders/materials must be rebuilt from scratch.
- UI must be rebuilt from scratch.
- The earlier you migrate, the cheaper it is. Post-alpha migration is a project restart in all but name.

**Post-Unity-2023 migration note**: Many teams considered migrating after Unity's runtime fee announcement. The teams that migrated successfully were early in development (pre-alpha). Teams in beta or later found that the migration cost exceeded the projected runtime fee for their revenue bracket. Run the math before committing to a migration.

---

## Decision Checklist

Use this checklist to select an engine for a new project:

| Question | Your Answer | Engine Implication |
|---|---|---|
| Is the game primarily 2D? | [Yes/No] | Yes: Godot or Unity. No: All three viable. |
| Is photorealistic or high-fidelity 3D a core pillar? | [Yes/No] | Yes: Unreal. No: All three. |
| Do you need console deployment at launch? | [Yes/No] | Yes: Unity or Unreal. No: All three (Godot can add console later via W4). |
| Is mobile a primary platform? | [Yes/No] | Yes: Unity (strongest mobile pipeline). Godot and Unreal are viable but Unity has the deepest mobile tooling. |
| What is your team's language expertise? | [GDScript/C#/C++] | GDScript: Godot. C#: Godot or Unity. C++: Unreal. |
| What is your team size? | [1-5 / 6-15 / 15+] | 1-5: Any engine. 6-15: Unity or Unreal preferred. 15+: Unity or Unreal. |
| What is your budget for engine costs? | [$0 / $0-5K / $5K+] | $0: Godot. $0-5K: Unity Personal/Plus. $5K+: Any. |
| Do you need VR support? | [Yes/No] | Yes: Unity or Unreal. |
| How important is iteration speed? | [Critical / Important / Secondary] | Critical: Godot (fastest iteration). Important: Unity. Secondary: Unreal. |
| Do you need extensive marketplace assets? | [Yes/No] | Yes: Unity (largest) or Unreal (high quality). No: Godot. |

---

## Cross-References

- **Engine-specific guidance**: Route to `game-godot-specialist`, `game-unity-specialist`, or `game-unreal-specialist` for deep implementation help
- **Architecture decisions**: Route to `game-technical-director` for engine selection within project context
- **Performance requirements**: Route to `game-technical-director` for performance profiling and optimization strategy per engine
- **Project scope vs. engine**: Route to `game-scope-check` to validate that engine choice aligns with project scope and timeline
- **Coding standards by engine**: Reference `@docs/coding-standards.md` for engine-specific code conventions
