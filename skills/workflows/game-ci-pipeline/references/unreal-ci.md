# Unreal Engine CI (UE 5.8)

Read this before writing an Unreal pipeline. Unreal CI is the hardest and most expensive of the
three engines: the engine is large, cooks are slow, and the EULA prevents distributing engine
images publicly. Plan for a self-hosted build machine from the start.

## Infrastructure

| Need | Guidance |
|---|---|
| Runner | Self-hosted GitHub Actions runner (Windows for Win64 and console targets), engine pre-installed. Runner version 2.327.1 or newer, because current `actions/*` majors run on Node 24 |
| Disk | Engine install plus project, DDC and staged builds: budget hundreds of GB on fast SSD (rule of thumb) |
| Memory | 32 GB or more for shipping cooks of mid-size projects (rule of thumb); shader compilation is the peak |
| Engine | Launcher install (`C:/Program Files/Epic Games/UE_5.8`) for Blueprint and C++ projects; a source build with an Installed Build (`InstalledEngineBuild.xml`) for teams that patch the engine |
| Containers | The community `unrealcontainers` images require linking your Epic account to GitHub for engine access; images are tens of GB, so most indies keep the engine on the runner instead |
| Content | Git LFS or Perforce for `.uasset`/`.umap`; `lfs: true` on checkout |

Security: a self-hosted runner executes whatever a workflow tells it to. Never attach one to a
public repository where forks can trigger workflows, and restrict which workflows can use it
(runner groups, labels, `if: github.repository == 'org/repo'`).

## Workflow: BuildCookRun on a self-hosted runner

```yaml
name: unreal-ci
on:
  push:
    branches: [main]
    tags: ["v*"]
  workflow_dispatch:
permissions:
  contents: read
concurrency:
  group: unreal-${{ github.ref }}
  cancel-in-progress: false     # never cancel a half-written DDC or staged build

env:
  UE_ROOT: "C:/Program Files/Epic Games/UE_5.8"
  PROJECT: "EmberDrift"

jobs:
  build:
    runs-on: [self-hosted, windows, ue58]
    timeout-minutes: 240
    strategy:
      fail-fast: false
      matrix:
        platform: [Win64, Linux]   # Linux target needs the cross-compile toolchain installed
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true, clean: false }   # keep Intermediate/ between runs on a persistent runner
      - name: BuildCookRun
        shell: cmd
        run: >
          "%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun
          -project="%GITHUB_WORKSPACE%\%PROJECT%.uproject"
          -platform=${{ matrix.platform }} -clientconfig=Shipping
          -build -cook -stage -package -archive
          -archivedirectory="%GITHUB_WORKSPACE%\Build\${{ matrix.platform }}"
          -noP4 -unattended -utf8output
      - uses: actions/upload-artifact@v7
        with:
          name: Build-${{ matrix.platform }}
          path: Build/${{ matrix.platform }}
          retention-days: 7
          if-no-files-found: error

  automation-tests:
    runs-on: [self-hosted, windows, ue58]
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true, clean: false }
      - name: Run project automation tests
        shell: cmd
        run: >
          "%UE_ROOT%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
          "%GITHUB_WORKSPACE%\%PROJECT%.uproject"
          -ExecCmds="Automation RunTests Project.; Quit"
          -unattended -nopause -nullrhi -log
          -ReportExportPath="%GITHUB_WORKSPACE%\TestReport"
      - uses: actions/upload-artifact@v7
        if: always()
        with: { name: automation-report, path: TestReport, retention-days: 14 }
```

Order: put the cheap automation tests first on PRs (or a nightly) and the full cook on `main` and
tags. A failing test should not cost a 60-minute cook.

## BuildGraph, when one script is not enough

BuildGraph is Epic's XML build-orchestration layer in AutomationTool. Graduate to it when you need
parallel agents, shared compile output across targets, or many platforms. Invocation:

```
RunUAT.bat BuildGraph -Script=Build/EmberDrift.xml -Target="Package Win64" -set:Configuration=Shipping
RunUAT.bat BuildGraph -Script=Build/EmberDrift.xml -ListOnly        # print nodes without running
```

```xml
<BuildGraph xmlns="http://www.epicgames.com/BuildGraph">
  <Option Name="Configuration" DefaultValue="Development" Description="Client configuration"/>
  <Agent Name="Win64 Build" Type="Win64">
    <Node Name="Compile Editor">
      <Compile Target="EmberDriftEditor" Platform="Win64" Configuration="Development"/>
    </Node>
    <Node Name="Compile Game" Requires="Compile Editor">
      <Compile Target="EmberDrift" Platform="Win64" Configuration="$(Configuration)"/>
    </Node>
    <Node Name="Cook Win64" Requires="Compile Editor">
      <Cook Project="$(RootDir)/EmberDrift/EmberDrift.uproject" Platform="Windows"/>
    </Node>
    <Node Name="Package Win64" Requires="Compile Game;Cook Win64">
      <Command Name="BuildCookRun" Arguments="-project=$(RootDir)/EmberDrift/EmberDrift.uproject -platform=Win64 -clientconfig=$(Configuration) -skipbuild -skipcook -stage -package -archive"/>
    </Node>
  </Agent>
</BuildGraph>
```

Start with plain `BuildCookRun`; BuildGraph's power comes with a learning curve and sparse docs.
Use `-ListOnly` to sanity-check graphs an agent writes before running them.

## Speed: DDC and shader caches

- **Derived Data Cache.** Persist the local DDC on the runner disk between runs, and configure a
  shared DDC for teams with several machines. Cold cooks spend much of their time rebuilding derived
  data and compiling shaders.
- **Incremental builds.** On a persistent runner use `clean: false` and keep `Intermediate/` and
  `Binaries/`; wipe them when the engine version changes.
- **Iterative cooking** for development builds; full cooks for release tags.
- **Only build what you ship.** One Shipping target per platform on tags; Development builds on
  `main` for playtesting.

## What not to automate through MCP

UE 5.8's experimental Unreal MCP plugin is **editor-only, bound to `127.0.0.1:8000`, and
unauthenticated**. It is a tool for a developer's local agent session, not a CI service: do not run
an editor with it enabled on a build machine, and never expose its port. Automation in CI goes
through RunUAT, BuildGraph, commandlets and the automation test framework. UE 5.7's experimental
in-editor AI Assistant is likewise a local tool.

## Deploy hand-off

Archive output per platform, then deploy with `game-ci/steam-deploy@v3` or SteamCMD
(`deploy-targets.md`). For the Epic Games Store, BuildPatchTool uploads are usually scripted per
release; automate Steam and itch.io first.
