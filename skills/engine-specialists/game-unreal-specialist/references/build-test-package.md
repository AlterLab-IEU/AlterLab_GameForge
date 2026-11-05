# Command-Line Builds, Automation Tests and Packaging (UE 5.8)

Read this before building, testing or packaging from a terminal, wiring the agent verification loop,
or setting up Git for an Unreal project. CI pipeline design itself lives in `/gameforge:game-ci-pipeline`.

Throughout, `UE` is the engine root (for example `C:/Program Files/Epic Games/UE_5.8` or a source
build), `PROJ` is the absolute path to `MyGame.uproject`, and `MyGame` is the project/target name.
Absolute paths avoid most "project not found" failures.

---

## 1. Where the tools live

| Tool | Windows | Linux | macOS |
|---|---|---|---|
| UnrealBuildTool wrapper | `UE/Engine/Build/BatchFiles/Build.bat` | `UE/Engine/Build/BatchFiles/Linux/Build.sh` | `UE/Engine/Build/BatchFiles/Mac/Build.sh` |
| AutomationTool (UAT) | `UE/Engine/Build/BatchFiles/RunUAT.bat` | `UE/Engine/Build/BatchFiles/RunUAT.sh` | `UE/Engine/Build/BatchFiles/RunUAT.sh` |
| Headless editor | `UE/Engine/Binaries/Win64/UnrealEditor-Cmd.exe` | `UE/Engine/Binaries/Linux/UnrealEditor-Cmd` | the equivalent binary under `UE/Engine/Binaries/Mac/` |
| Project files | `GenerateProjectFiles.bat` in the engine root, or right-click the `.uproject` | `GenerateProjectFiles.sh` | `GenerateProjectFiles.sh` |

The **Project Launcher** prints the exact UAT command line it runs for a launch profile. When a
packaging flag is in doubt, build the profile once in the editor and copy that command: it is
correct for your engine version.

## 2. Compile the editor target (fastest check that C++ is sound)

```bash
# Windows (Git Bash or PowerShell; quote paths with spaces)
"$UE/Engine/Build/BatchFiles/Build.bat" MyGameEditor Win64 Development -Project="$PROJ" -WaitMutex

# Linux
"$UE/Engine/Build/BatchFiles/Linux/Build.sh" MyGameEditor Linux Development -Project="$PROJ" -WaitMutex

# macOS
"$UE/Engine/Build/BatchFiles/Mac/Build.sh" MyGameEditor Mac Development -Project="$PROJ" -WaitMutex
```

- Close the editor first, or Live Coding holds the DLLs. Live Coding is fine for function-body edits
  while the editor runs; after adding or changing `UCLASS`/`UPROPERTY`/`UFUNCTION` declarations,
  close the editor and do a full build.
- Treat new warnings as failures in review: deprecation warnings are how Epic tells you an API is
  going away.
- Regenerate project files after adding or moving source files so the IDE sees them.

## 3. Run automation tests headless

```bash
"$UE/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$PROJ" \
  -ExecCmds="Automation RunTest MyGame;Quit" \
  -unattended -nopause -nosplash -NullRHI -log \
  -ReportExportPath="$(pwd)/Saved/Automation/Reports"
```

- `Automation RunTest MyGame` runs every test whose path starts with `MyGame`; chain names with `+`
  (`MyGame.Combat+MyGame.Save`) or filter by group with `Group:<Name>`. `Quit` closes the editor
  when the queue finishes.
- `-NullRHI` skips GPU rendering; drop it for tests that need rendering (screenshot comparisons).
- `-ReportExportPath` writes a JSON report plus HTML. **Parse the JSON for failures; do not rely on
  the process exit code alone.** Grep the log for `Error:` and `Ensure` too.
- Tests run in the editor context here. Client-only tests need a packaged build (Gauntlet,
  `RunUAT RunUnreal`, is the heavier framework for that).

### Writing tests

**Simple test** (pure logic, fastest):

```cpp
// Source/MyGame/Private/Tests/DamageMathTests.cpp
#include "Misc/AutomationTest.h"
#include "Combat/DamageMath.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FDamageMathArmorTest, "MyGame.Combat.DamageMath.ArmorReducesDamage",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)

bool FDamageMathArmorTest::RunTest(const FString& Parameters)
{
    TestEqual(TEXT("50 armor halves 100 damage"), DamageMath::Apply(100.f, 50.f), 50.f);
    TestTrue(TEXT("damage never negative"), DamageMath::Apply(10.f, 1000.f) >= 0.f);
    return true;
}

#endif
```

**Automation Spec** (BDD style, good for systems with setup):

```cpp
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

BEGIN_DEFINE_SPEC(FInventorySpec, "MyGame.Inventory",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)
    FInventory Inventory;
END_DEFINE_SPEC(FInventorySpec)

void FInventorySpec::Define()
{
    BeforeEach([this]() { Inventory = FInventory(/*Capacity*/ 3); });

    Describe("AddItem", [this]()
    {
        It("rejects items when full", [this]()
        {
            Inventory.AddItem(TEXT("A")); Inventory.AddItem(TEXT("B")); Inventory.AddItem(TEXT("C"));
            TestFalse(TEXT("fourth item rejected"), Inventory.AddItem(TEXT("D")));
        });
    });
}

#endif
```

- Keep gameplay rules in plain C++ types or UObjects that do not need a world, so most tests are
  simple tests. Agents can write and run these without the editor UI.
- **Functional tests** (`AFunctionalTest` actors placed in a test map) cover behavior that needs a
  world: a door opens, an ability lands, a level loads. Keep test maps small and in their own folder.
- The CQTest plugin offers fixture-style tests on top of the same framework if you prefer that shape.

## 4. Catch broken Blueprints and assets after C++ changes

```bash
# Recompile every Blueprint against the current C++ (catches renamed functions and pins)
"$UE/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$PROJ" -run=CompileAllBlueprints -unattended -nopause

# Run editor Python headless (see ai-agent-workflows.md for scripts)
"$UE/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$PROJ" -run=pythonscript -script="$(pwd)/Scripts/validate_naming.py"
```

- The CompileAllBlueprints commandlet does not cover level Blueprints (reported as UE-234741); open
  the affected maps or cover them with functional tests.
- The `pythonscript` commandlet does not load levels on its own; the script must load what it needs.
- Renaming a `UFUNCTION`, `UPROPERTY` or class breaks every Blueprint that uses it. Use Core
  Redirects in `DefaultEngine.ini` (`[CoreRedirects]`) when a rename is unavoidable, then resave.

## 5. Package a build

```bash
"$UE/Engine/Build/BatchFiles/RunUAT.bat" BuildCookRun \
  -project="$PROJ" -noP4 -utf8output \
  -platform=Win64 -clientconfig=Shipping \
  -build -cook -stage -pak -archive -archivedirectory="$(pwd)/Packaged"
```

| Configuration | Use |
|---|---|
| `Development` | Day-to-day packaged testing; console and stats available |
| `Test` | Performance capture close to Shipping, with some profiling hooks |
| `Shipping` | What players get; no console, smallest and fastest |

- Cooking is the slow step. UE 5.8 enables Zen Server as the cooked output store by default, and
  Incremental Cooking (Beta in 5.8) reuses that output to cut cook times; try it on CI before relying on it.
- Smoke-test every packaged build: launch, load each map, play one loop, quit. A build that cooks but
  crashes on a missing soft reference is common; Shipping logs are minimal, so test Development too.
- Store submission, ratings and builds per storefront: `/gameforge:game-launch`.

## 6. Source control for Unreal with Git

`.uasset` and `.umap` are binary: they cannot be merged and GameForge's file guard blocks agents from
writing them as text. Track them with Git LFS and lock them while editing.

```gitattributes
# .gitattributes
*.uasset filter=lfs diff=lfs merge=lfs -text lockable
*.umap   filter=lfs diff=lfs merge=lfs -text lockable
*.fbx    filter=lfs diff=lfs merge=lfs -text
*.png    filter=lfs diff=lfs merge=lfs -text
*.wav    filter=lfs diff=lfs merge=lfs -text
*.psd    filter=lfs diff=lfs merge=lfs -text lockable
```

- `git lfs lock Content/Maps/Arena.umap` before editing a shared map; unlock after pushing.
- Ignore `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`, `.vs/`, generated solution files,
  and packaged output; keep `Build/<Platform>/` resources such as icons.
- Perforce remains the studio default for large art-heavy teams; Git + LFS is workable for indie teams
  that lock binaries and commit small.

## 7. The agent verification loop

Run this after every agent change to C++, Config or Build.cs, in order, stopping at the first failure:

1. `git diff` the change; confirm no `.uasset`/`.umap` or generated folder was touched.
2. Compile the editor target (section 2). Zero errors; read every new warning.
3. Run the relevant automation tests headless (section 3) and parse the report.
4. If C++ that Blueprints use changed: run CompileAllBlueprints (section 4).
5. If assets were changed through Python or MCP: run the validation script and review the changed
   files list in source control.
6. A human opens the editor, plays the affected feature in PIE, and checks feel, visuals and logs.
7. Before a milestone: package a Development build and smoke-test it (section 5).
