# Versions, UE6 Planning and Migration

Read this when the user asks which engine version to target, how to upgrade between UE5 versions,
what UE6 means for a project, whether Unreal is the right engine at all, or how to move a project
from Unity or Godot. Status labels are Epic's (Experimental, Beta, Production-Ready) as given in the
release notes; snapshot taken November 2026.

---

## 1. Recent UE5 releases (what changed for indie teams)

| Version | Released | Changes worth knowing |
|---|---|---|
| **5.6** | 2025-06-03 | MetaHuman Creator moved into the editor (MetaHuman Character asset); Fast Geometry Streaming (Experimental); release focus on 60 Hz open worlds on current hardware |
| **5.7** | 2025-11-12 | PCG framework and Substrate materials production-ready; MegaLights Beta; Nanite Foliage and the Procedural Vegetation Editor Experimental; in-editor AI Assistant (F1 contextual help, C++ generation); MetaHuman Creator on Linux and macOS |
| **5.8** | 2026-06-17 | MegaLights production-ready; Lumen Lite (Beta, medium-quality GI, default on current-gen handhelds); Mesh Terrain (Experimental); Iris replication production-ready per the release notes; Enhanced Input unified with Common Input/UI plus an Input Debugger; StateTree authoring improvements; Mass Signals in core and off-game-thread entity creation; Zen Server cooked output store on by default; Incremental Cooking (Beta); Audio Insights production-ready; Mutable production-ready; MetaHuman Animator single-camera body capture (Experimental); OpenRigLogic (RigLogic and DNA, MIT licence) on GitHub; **Unreal MCP plugin (Experimental)** |

Epic describes 5.8 as the **last planned major UE5 release**; UE5 continues to receive fixes, and
Epic has said another version could follow if needed. Target **5.8** for new projects and for
projects that will ship before UE6 is production-ready. Check the 5.8 hotfix notes before upgrading
a project mid-milestone.

**Licensing (Epic's terms as of late 2026):** 5% royalty on lifetime gross revenue above US$1M per
product; 3.5% under the Launch Everywhere program (release on the Epic Games Store at the same time
or first); revenue from Epic Games Store sales is royalty-free. MetaHumans may be used in other
engines (including Unity and Godot) and sold on Fab; using them to train AI is prohibited. Fab is
Epic's unified marketplace; check each asset's licence there before shipping it.

## 2. UE6: planning notes, not plans

What Epic has said (announced at Unreal Fest, June 2026): **UE6 early access is targeted for late
2027**, built around **Verse** (Epic's language, already used in UEFN) and **Scene Graph**. Epic's
CEO described Blueprints and Actors as part of early UE6 but not its long-term foundation, and said a
Blueprint-to-Verse conversion tool will be released free. Reports that Blueprints will be deleted
outright are unverified. Epic has not published a migration path for UE5 C++ projects.

What that means for a project starting now:

- **Ship on UE5.8.** Do not delay a 2026-2028 release waiting for UE6 early access.
- **Keep logic portable:** gameplay rules in plain C++ types and Data Assets, thin Blueprints, few
  engine modifications. Whatever the conversion story turns out to be, small graphs and data-driven
  content move more easily than sprawling ones.
- **Learning Verse is optional:** worthwhile if you also build in UEFN; not a reason to rewrite.
- **Re-evaluate** when UE6 early access ships, with a spike branch, not on the main line.

## 3. Upgrading between UE5 versions

1. Branch, and make sure everything is committed (including LFS objects).
2. Read the release notes' upgrade and deprecation sections for every version you skip.
3. Switch the engine association (right-click the `.uproject` or edit `EngineAssociation`), regenerate
   project files, and build the editor target from the command line.
4. Fix errors, then every new deprecation warning. Update plugins (marketplace plugins often lag).
5. Run `-run=CompileAllBlueprints`, all automation tests, and open every map.
6. Resave assets only when needed and in a dedicated commit, so the content diff is reviewable.
7. Package a Development build and smoke-test before merging.

## 4. Is Unreal the right engine?

**Strong fit:**

- 3D games where lighting and geometry fidelity are part of the pitch (Nanite, Lumen, MegaLights).
- Teams with at least one programmer comfortable in C++, or Blueprint-only projects of modest scope.
- Large or continuous worlds (World Partition, PCG, HLODs).
- Ability-heavy action games (GAS) and server-authoritative multiplayer (built-in replication,
  dedicated servers).
- Projects that want the Epic ecosystem: MetaHuman, Fab, Epic Online Services, Epic Games Store terms.

**Weak fit (say so plainly):**

- **2D games.** Paper2D exists, but Godot, Unity or a web 2D framework is the faster path
  (`/gameforge:game-godot-specialist`, `/gameforge:game-unity-specialist`, `/gameforge:game-web2d-specialist`).
- **Browser games.** Unreal has no supported web export (HTML5 was moved out of the engine in 4.24);
  Pixel Streaming streams from a server GPU per player, a hosting cost most indie games cannot carry.
  Use `/gameforge:game-threejs-specialist` or `/gameforge:game-web2d-specialist`.
- **Low-spec and small-download targets** (mobile-first, older laptops): possible, but the engine's
  defaults assume modern GPUs and large installs.
- **Tight iteration loops on code** with no C++ experience on the team: C++ build times and the
  Gameplay Framework learning curve are real schedule costs.

Engine choice is a technical-director decision; bring the trade-offs to `/gameforge:game-technical-director`.

## 5. Migrating to Unreal

| From | Maps to in Unreal | Gotcha |
|---|---|---|
| Unity `GameObject` + `MonoBehaviour` | `AActor` + `UActorComponent` | Actors are heavier; not everything should be one (use components and plain structs) |
| Unity Prefab | Blueprint class | Binary asset: no merges, lock while editing |
| Unity `ScriptableObject` | `UPrimaryDataAsset` / Data Table row | Register primary asset types with the Asset Manager |
| Unity C# events / Godot signals | Delegates (`DECLARE_DYNAMIC_MULTICAST_DELEGATE`) and Blueprint event dispatchers | Dynamic delegates are slower; use native delegates for C++-only paths |
| Godot scene tree + autoloads | Actors in levels + Subsystems | Learn GameMode / GameState / PlayerController / PlayerState before writing logic |
| Godot GDScript hot reload | Live Coding for function bodies, full rebuild for reflection changes | Budget for build times; split modules early |
| Either: text scenes in Git | Binary `.uasset`/`.umap` in Git LFS (or Perforce) | Set up LFS and locking before the first content commit |

**Effort (rule of thumb, for a team new to Unreal):** a jam-sized prototype takes weeks, mostly
learning the Gameplay Framework; a mid-sized indie project is a redesign around Unreal's framework
measured in months, not a line-by-line port. Re-scope with `/gameforge:game-scope-check` before
committing to a migration.
