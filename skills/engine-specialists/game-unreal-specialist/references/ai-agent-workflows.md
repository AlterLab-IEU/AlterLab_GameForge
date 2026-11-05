# AI Coding Agents in Unreal Projects (UE 5.7-5.8)

Read this before letting Claude Code (or any agent) change an Unreal project: connecting the UE 5.8
Unreal MCP plugin, writing Python editor scripts, or reviewing agent-written C++. Facts about Unreal
MCP come from Epic's "Unreal MCP in Unreal Editor" documentation for UE 5.8; check it again when you
upgrade, because the plugin is Experimental.

---

## 1. Who touches what

| Surface | Agent edits directly | Agent edits through a tool | Human only |
|---|---|---|---|
| `Source/` C++, `*.Build.cs`, `*.Target.cs` | Yes, then the verification loop | | Architecture sign-off |
| `Config/*.ini`, `.uproject` (JSON plugin list) | Yes, small diffs | | Platform and rendering defaults |
| Automation tests, Python scripts, docs | Yes | | |
| `.uasset` / `.umap` (Blueprints, levels, materials, Data Assets) | **Never as text**; GameForge's hook denies it | Python editor scripting, Unreal MCP | Blueprint graph logic review, level art, lighting |
| `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/` | Never (generated; the hook denies it) | | |
| Feel, visuals, performance on hardware | | | Playtest in PIE and in a packaged build |

When a change needs a Blueprint, the agent writes the C++ base class and gives the human exact
editor steps (create Blueprint subclass of `AWeapon`, set `Mesh`, override `OnFired`, call parent).

## 2. Unreal MCP (UE 5.8, Experimental)

UE 5.8 ships an Experimental Unreal MCP plugin that lets an MCP client such as Claude Code drive the
editor. The tools come from the **All Toolsets** plugin (the Toolset Registry); documented
capabilities include spawning actors, configuring lighting, creating material instances, inspecting
Slate widgets and running automation tests, with Python toolsets such as `SceneTools`, `ActorTools`,
`MaterialInstanceTools` and `ObjectTools`.

**Setup**

1. Enable the **Unreal MCP** and **All Toolsets** plugins (Toolset Registry is enabled with them;
   Terminal is optional) and restart the editor.
2. The server auto-starts per Editor Preferences, or run `ModelContextProtocol.StartServer [port]`
   in the console. Command-line overrides: `-ModelContextProtocolStartServer`, `-ModelContextProtocolPort=N`.
3. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the console. It writes (or merges
   into) `.mcp.json` at the project root, pointing at `http://127.0.0.1:8000/mcp`.
4. Start Claude Code in the project root, approve the project-scoped server, and check it with `/mcp`.
5. The server advertises three meta-tools by default (`list_toolsets`, `describe_toolset`,
   `call_tool`). Have the agent list and describe toolsets before calling anything; do not let it
   guess tool names.

Transport is HTTP with Server-Sent Events only (no stdio, no WebSocket). Debug with the log category
`LogModelContextProtocol` or `npx @modelcontextprotocol/inspector` over Streamable HTTP.

**Security rules (non-negotiable)**

- [ ] Keep the default loopback binding. Epic: "There is no authentication layer; the plugin is not
      safe to expose beyond the local machine." Never forward port 8000, tunnel it, or publish it
      from a container, VM or cloud workstation.
- [ ] No authentication means any process on the machine can drive your editor. Run it only on a
      workstation you control, and stop the server (`ModelContextProtocol.StopServer`) when done.
- [ ] Treat the toolsets, especially the Python-backed ones, as **arbitrary code execution inside
      the editor** with your user's file permissions.
- [ ] Commit or shelve before every MCP session. Afterwards review the changed-files list in source
      control; binary assets have no readable diff, so keep sessions small and scoped.
- [ ] Do not start the server from game code (`IModelContextProtocolModule::StartServer()`) or ship a
      cooked build with it enabled.
- [ ] `ModelContextProtocol.EnableAnalytics` defaults to true; set it according to your team's
      telemetry policy.
- [ ] It is **not a CI service**: editor-only workflows, loopback only. CI uses `UnrealEditor-Cmd`
      commandlets and RunUAT (`build-test-package.md`).

**Limits to plan around**

- Tool calls run serially on the game thread: one agent at a time, no overlapping calls, and a long
  call freezes the editor while it runs.
- No shipping toolset exposes MCP Resources or Prompts.
- Custom C++ tools added with Live Coding do not register new `UFUNCTION`s; restart the editor. The
  experimental GASToolsets plugin (disabled by default) holds Epic's `UAttributeSetToolset` example.
- Experimental means tool names and behavior can change between engine versions.

**Before 5.8:** community bridges such as chongdashu/unreal-mcp (MIT, self-described experimental,
UE 5.5+) cover Blueprints and actors. Apply the same security rules; if a bridge needs Python remote
execution, enable it only while in use and only on the local machine.

## 3. The UE 5.7 AI Assistant

UE 5.7 added an in-editor AI Assistant in a slide-out panel: hover any editor UI element and press
F1 to start a contextual conversation; it answers questions, gives step-by-step help and generates
C++. Treat it as early-stage: useful for "what does this panel do", not a source of truth for APIs.
Its C++ goes through the same verification loop as any agent's. Check Epic's terms for what is sent
off the machine before using it on confidential projects.

## 4. Python editor scripting: the safe automation path

Python (Python Editor Script Plugin, embedded Python 3.11 in current releases) is **editor-only**: it
cannot run in PIE, standalone or cooked builds. That makes it the right tool for bulk asset work an
agent can write as reviewable text, and the wrong tool for gameplay.

| Run mode | Command |
|---|---|
| Headless commandlet (CI, batch) | `UnrealEditor-Cmd <PROJ> -run=pythonscript -script=<abs path>` (does not load levels by itself) |
| Full editor, run then exit | `UnrealEditor <PROJ> -ExecutePythonScript=<abs path>` (needs Editor Scripting Utilities) |
| Interactive | `py <path>` in the console, or the Output Log in Python mode |

Rules: dry-run by default, apply behind an explicit switch, group edits in
`unreal.ScopedEditorTransaction` so one Undo reverts them, save only what changed, and write a report
the agent can read back.

```python
# Scripts/validate_naming.py -- read-only check; writes Saved/Reports/naming.json
import json
import os
import unreal

PREFIXES = {
    "StaticMesh": "SM_", "SkeletalMesh": "SK_", "Material": "M_",
    "MaterialInstanceConstant": "MI_", "Texture2D": "T_", "Blueprint": "BP_",
    "NiagaraSystem": "NS_",
}

registry = unreal.AssetRegistryHelpers.get_asset_registry()
assets = registry.get_assets_by_path("/Game", recursive=True)

problems = []
for data in assets:
    cls = str(data.asset_class_path.asset_name)
    name = str(data.asset_name)
    prefix = PREFIXES.get(cls)
    if prefix and not name.startswith(prefix):
        problems.append({"asset": str(data.package_name), "class": cls, "expected_prefix": prefix})

out_dir = os.path.join(unreal.Paths.project_saved_dir(), "Reports")
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, "naming.json"), "w") as f:
    json.dump({"checked": len(assets), "problems": problems}, f, indent=2)

unreal.log(f"naming check: {len(problems)} problems in {len(assets)} assets")
```

```python
# Scripts/set_roughness.py -- dry run unless GF_APPLY=1 is set in the environment
import os
import unreal

APPLY = os.environ.get("GF_APPLY") == "1"
FOLDER = "/Game/Environment/Materials"

paths = unreal.EditorAssetLibrary.list_assets(FOLDER, recursive=True)
with unreal.ScopedEditorTransaction("Set roughness on environment MIs"):
    for path in paths:
        asset = unreal.EditorAssetLibrary.load_asset(path)
        if not isinstance(asset, unreal.MaterialInstanceConstant):
            continue
        unreal.log(f"{'SET' if APPLY else 'WOULD SET'} Roughness=0.6 on {path}")
        if APPLY:
            unreal.MaterialEditingLibrary.set_material_instance_scalar_parameter_value(asset, "Roughness", 0.6)
            unreal.EditorAssetLibrary.save_loaded_asset(asset)
```

Prefer editor subsystems (`unreal.get_editor_subsystem(unreal.EditorActorSubsystem)`,
`unreal.LevelEditorSubsystem`) over older static helper libraries when manipulating levels and actors.

## 5. What agents get wrong in Unreal

Most models were trained on a decade of UE4 tutorials. Reject these on sight:

| Agent writes | Current practice |
|---|---|
| `GENERATED_UCLASS_BODY()` and `FObjectInitializer` constructors everywhere | `GENERATED_BODY()` and a default constructor |
| `BindAxis("MoveForward")`, `BindAction("Jump", IE_Pressed, ...)`, mappings in `DefaultInput.ini` | Enhanced Input; the legacy mappings were deprecated in UE 5.1 |
| `UProperty*` / `UField` reflection iteration | `FProperty` and `TFieldIterator<FProperty>` (since UE 4.25) |
| PhysX headers and types | Chaos; PhysX is gone in UE5 |
| Matinee, Cascade | Sequencer, Niagara |
| `UFoo* Member;` with no `UPROPERTY()` | `UPROPERTY() TObjectPtr<UFoo> Member;` |
| `FVector` assumed to be three floats | Doubles since UE5 Large World Coordinates; `FVector3f` for float data |
| `ConstructorHelpers::FObjectFinder` with hard-coded asset paths | Assets assigned in Blueprint defaults or Data Assets, soft references for on-demand loads |
| `#include "Engine.h"` in headers | Include what you use; forward-declare |
| `UGameplayStatics::GetPlayerCharacter(this, 0)` in shared code | Get the pawn from the owning controller; index 0 breaks multiplayer and split-screen |
| Flat Gameplay Effect tag properties | Gameplay Effect Components (UE 5.3+) |
| "Hot Reload" | Live Coding for function bodies; close the editor and rebuild for reflection changes |
| Python `AssetData.asset_class` | `asset_class_path` (UE 5.1+ uses `TopLevelAssetPath`) |
| Blueprint "code" written as text, or a hand-edited `.uasset` | C++ base class plus editor steps, Python, or Unreal MCP |
| Confident console variables, plugin names or functions that do not exist | Check console autocomplete, the Plugins window and the API reference for the project's version |

## 6. Review checklist for agent-written Unreal C++

- [ ] Builds clean for the editor target; no new deprecation warnings
- [ ] Every UObject member is a `UPROPERTY` with `TObjectPtr`; no raw owning pointers
- [ ] No per-frame work that could be an event, timer or overlap; Tick disabled by default
- [ ] Replicated state changes only behind `HasAuthority()`; RPC choice justified (see `/gameforge:game-multiplayer`)
- [ ] Gameplay values come from Data Assets/Tables, not literals
- [ ] Headers forward-declare; module dependencies added to Build.cs and plugins to `.uproject`
- [ ] New behavior has an automation test, or the PR says why not
- [ ] No edits in generated folders, no binary assets in the diff unless made through the editor
- [ ] Names follow Epic prefixes (`A`, `U`, `F`, `E`, `I`, `T`, `b` for bools)

## 7. Prompts that work

```text
Read .uproject, Source/MyGame/MyGame.Build.cs and Source/MyGame/Abilities/ first.
Add a C++ Gameplay Ability UGA_Dash following the existing ability pattern. Do not touch Content/.
Then build MyGameEditor, run "Automation RunTest MyGame.Abilities" headless, and report the
compile result, the test report summary and the exact editor steps I need to wire the Blueprint.
```

```text
Write Scripts/fix_texture_groups.py: list every Texture2D under /Game/UI whose LODGroup is not
TEXTUREGROUP_UI, dry run by default, apply only when GF_APPLY=1, one ScopedEditorTransaction,
save only modified assets, and write Saved/Reports/texture_groups.json. Do not run it with GF_APPLY=1.
```

```text
Using the Unreal MCP server: list_toolsets, then describe the actor toolset. Spawn 10 BP_Crate
actors along the spline in the open level as a greybox pass. Make no other changes. Stop and
summarise what you changed so I can review it in source control before saving.
```
