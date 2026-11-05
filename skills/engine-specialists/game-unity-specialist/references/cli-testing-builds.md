# Unity from the Command Line: Tests, Builds and the Unity CLI

Read this before running Unity headless, writing a build script, setting up the agent verification
loop, or handing CI work to `/gameforge:game-ci-pipeline`.

---

## 1. Find the Editor binary

Unity's batchmode entry point is the **Editor executable**, not the `unity` CLI. Read the project's
version from `ProjectSettings/ProjectVersion.txt` (`m_EditorVersion: 6000.3.xf1`). Then point an
environment variable at the matching Editor:

| OS | Default Hub install path |
|---|---|
| Windows | `C:\Program Files\Unity\Hub\Editor\<version>\Editor\Unity.exe` |
| macOS | `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity` |
| Linux | `~/Unity/Hub/Editor/<version>/Editor/Unity` |

```bash
export UNITY_EDITOR="$HOME/Unity/Hub/Editor/6000.3.xf1/Editor/Unity"   # adjust to your install
```

The project must **not** be open in another Editor instance. Batchmode fails on the project lock.
If the user keeps the Editor open, drive it through Unity's agent plugin or an MCP server (§5).

---

## 2. Compile check (fastest signal)

Opening the project in batchmode compiles all scripts. With compile errors, batchmode aborts
("Scripts have compiler errors") and exits non-zero.

```bash
"$UNITY_EDITOR" -batchmode -nographics -quit -projectPath . -logFile Logs/compile.log
grep -E "error CS[0-9]+" Logs/compile.log | sort -u
```

Read the **first** error, not the cascade. Treat `warning CS0618` (obsolete API) as a finding as
well. That warning is how deprecated APIs such as `FindObjectOfType` and `Rigidbody.velocity` show
up.

If Unity has generated `.csproj`/`.sln` files and the .NET SDK is installed,
`dotnet build <Assembly>.csproj` can be a quicker smoke check. Unity's own compile stays the source
of truth. Never edit the generated project files: Unity regenerates them, and GameForge's hook
blocks the edit.

---

## 3. Tests (Unity Test Framework)

```bash
# Edit Mode: fast, no scene, pure logic
"$UNITY_EDITOR" -batchmode -nographics -projectPath . -runTests -testPlatform EditMode \
  -testResults Logs/editmode-results.xml -logFile Logs/editmode.log

# Play Mode: runs frames, MonoBehaviour lifecycle, physics
"$UNITY_EDITOR" -batchmode -projectPath . -runTests -testPlatform PlayMode \
  -testResults Logs/playmode-results.xml -logFile Logs/playmode.log

# Narrow the run while iterating
"$UNITY_EDITOR" -batchmode -nographics -projectPath . -runTests -testPlatform EditMode \
  -testFilter "Game.Tests.Inventory" -testResults Logs/inv.xml -logFile Logs/inv.log
```

- **Do not pass `-quit` with `-runTests`.** Unity's command-line reference says `-quit` is not
  supported while tests run. The Editor exits by itself when the run ends.
- `-testPlatform` defaults to EditMode. Results are NUnit XML; parse them instead of trusting the
  exit code alone.
- Other filters: `-testCategory` and `-assemblyNames`. Check the casing of each argument
  (`-testFilter` vs `-testfilter`) against the Test Framework docs for the project's Unity version.
- Play Mode tests that render may need a GPU. Drop `-nographics` for those, or run them on a machine
  with graphics.

Edit Mode test:

```csharp
using Game.Core;
using NUnit.Framework;

namespace Game.Tests
{
    public sealed class DamageMathTests
    {
        [Test]
        public void ArmorReducesDamageButNeverBelowOne()
        {
            Assert.AreEqual(1, DamageMath.Apply(rawDamage: 5, armor: 50));
            Assert.AreEqual(8, DamageMath.Apply(rawDamage: 10, armor: 2));
        }
    }
}
```

Play Mode test (`[UnityTest]` runs as a coroutine across real frames):

```csharp
using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Game.Tests
{
    public sealed class FallingCrateTests
    {
        [UnityTest]
        public IEnumerator CrateFallsUnderGravity()
        {
            var crate = GameObject.CreatePrimitive(PrimitiveType.Cube);
            var body = crate.AddComponent<Rigidbody>();
            float startY = crate.transform.position.y;

            yield return new WaitForSeconds(0.5f);

            Assert.Less(crate.transform.position.y, startY);
            Assert.Less(body.linearVelocity.y, 0f);
            Object.Destroy(crate);
        }
    }
}
```

**What to test in a game:**
- Pure rules: damage, economy, inventory, save serialization round trips.
- ScriptableObject data validation: no null references, values in range. This catches designer
  typos before playtests.
- One Play Mode smoke test per scene: it loads, has no errors in the log, and the player spawns.

Leave feel and balance to humans (`/gameforge:game-playtest`, `/gameforge:game-balance-check`).

---

## 4. Builds

Command-line builds, per the Unity 6.3 manual's "Build from the command line" page:

```bash
# Custom build script (recommended): name the target explicitly on the command line
"$UNITY_EDITOR" -batchmode -nographics -quit -projectPath . \
  -executeMethod Game.Editor.BuildScript.BuildWindows -buildTarget StandaloneWindows64 \
  -logFile Logs/build-windows.log

# Unity 6 Build Profiles: pass the profile asset instead of a target
# (an asset path in this project; confirm the syntax in the Editor command-line reference)
"$UNITY_EDITOR" -batchmode -nographics -quit -projectPath . \
  -executeMethod Game.Editor.BuildScript.BuildActiveProfile \
  -activeBuildProfile "Assets/Settings/Build Profiles/Web.asset" -logFile Logs/build-web.log
```

- Always pass `-buildTarget` or `-activeBuildProfile`. Unity warns that switching targets inside a
  batchmode script does not reliably take effect.
- One target per process. Unity cannot build several targets in one command-line invocation.
- A plain `-build` with `-buildTarget` or `-activeBuildProfile` builds without a script. Check the
  Editor command-line reference for its output-path syntax.

Build script (place in the Editor-only assembly):

```csharp
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Profile;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace Game.Editor
{
    public static class BuildScript
    {
        public static void BuildWindows() =>
            Run(BuildPipeline.BuildPlayer(new BuildPlayerOptions
            {
                scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray(),
                locationPathName = "Builds/Windows/Game.exe",
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            }));

        public static void BuildActiveProfile() =>
            Run(BuildPipeline.BuildPlayer(new BuildPlayerWithProfileOptions
            {
                buildProfile = BuildProfile.GetActiveBuildProfile(),
                locationPathName = "Builds/Profile",
                options = BuildOptions.None
            }));

        private static void Run(BuildReport report)
        {
            Debug.Log($"Build {report.summary.result}: {report.summary.totalSize} bytes, " +
                      $"{report.summary.totalErrors} errors, {report.summary.totalTime}");
            if (report.summary.result != BuildResult.Succeeded)
                EditorApplication.Exit(1);
        }
    }
}
```

The Web target is still `BuildTarget.WebGL` in the enum, even though Unity 6 calls the platform
"Web". Builds started from the Build Profiles window do not run custom scripts; this one is for the
command line and CI.

---

## 5. The Unity CLI (`unity`)

Unity's standalone CLI, separate from the Editor binary:

- **Install:**
  - macOS/Linux: `curl -fsSL https://unity.com/install.sh | bash`
  - Windows: `winget install Unity.CLI`
  - Also packaged for Homebrew (`brew install --cask unity-cli`), apt and dnf.
- **Requirements:** Windows 10 21H1+, macOS 14+, Ubuntu 22.04+ / RHEL 9 (glibc 2.34+).

| Task | Command (per Unity CLI docs, Nov 2026) |
|---|---|
| Health check | `unity doctor`, `unity --version` |
| Sign in | `unity auth login`, `unity auth status`. For CI, set `UNITY_SERVICE_ACCOUNT_ID` / `UNITY_SERVICE_ACCOUNT_SECRET` |
| Install an Editor plus modules | `unity install lts -m webgl android` or `unity install 6000.3.7f1` |
| Add modules later | `unity install-modules -e <version> -m ios` |
| New project / open | `unity projects create MyGame --no-cloud`, `unity open ./MyGame` |
| List installed Editors | `unity editors -i` |
| Editor link for agents | `unity pipeline install` (adds the Pipeline package), `unity status` (checks the Editor connection) |
| Optional Unity MCP server | `unity mcp configure` |

According to Unity's agent plugin README, the CLI can also run builds and tests. Read
`unity --help` for the exact subcommands in the installed version. Do not guess flags.

---

## 6. Agent verification loop (copy into the project's CLAUDE.md)

1. **Edit** C# or data. Let Unity create `.meta` files; never write GUIDs.
2. **Compile:** refresh through the Unity plugin/MCP if the Editor is open, otherwise run the §2
   batchmode compile. There must be zero `error CS`. Review every new `CS0618`.
3. **Console:** read Editor or player log errors, not just compiler output. Missing references and
   serialization errors only show there.
4. **Tests:** run Edit Mode tests, then the Play Mode smoke tests for the touched scenes.
5. **Diff review:** `git status` / `git diff`.
   - Each new asset has exactly one new `.meta`.
   - No existing `.meta` GUID changed.
   - No `Library/`, `Temp/`, `UserSettings/` or `*.csproj` files.
   - Scene and prefab YAML changes are the ones you intended.
6. **Play it:** a human enters Play Mode for anything touching feel, UI or camera.
7. **Record:** note decisions and next steps in `production/session-state/active.md`.
