# Unity CI (Unity 6.3 LTS and 6.6)

Read this before writing a Unity pipeline. Versions and inputs verified November 2026 against the
GameCI action manifests and docs, and Unity's CLI release notes.

## Three ways to build Unity in CI

| Option | Status (Nov 2026) | Use when |
|---|---|---|
| **GameCI actions** (`game-ci/unity-test-runner@v4`, `game-ci/unity-builder@v4`) | Mature, community-maintained; GameCI's docs mark v4 as current. `unity-builder` v4 is at 4.8.x; a new **v6** major (2026-08-29) runs through a `game-ci/cli` binary | Default for GitHub-hosted Linux runners and Docker-based builds |
| **Unity CLI** (`unity ...`) | Official, standalone binary, **beta** (1.0.0-beta.16 on 2026-11-03); includes `unity ci init`, `unity build`, `unity test`, `unity license activate` | Teams already using Unity AI/CLI locally; evaluate on a branch before relying on it |
| **Raw editor batch mode** (`Unity -batchmode -nographics ...`) | Stable, documented for years | Self-hosted runners with the editor installed; maximum control |

Pin whichever you choose. For GameCI v6, also pin `cliVersion` (it defaults to `latest`), and test
the upgrade on a branch: it is a new architecture, not a drop-in patch.

## Licensing secrets (GameCI)

| License | Secrets | Notes |
|---|---|---|
| Personal | `UNITY_LICENSE` (contents of `Unity_lic.ulf`), `UNITY_EMAIL`, `UNITY_PASSWORD` | Activate once in Unity Hub with the CI account; the `.ulf` lives at `~/.local/share/unity3d/Unity/Unity_lic.ulf` (Linux), `/Library/Application Support/Unity/Unity_lic.ulf` (macOS), `C:\ProgramData\Unity\Unity_lic.ulf` (Windows) |
| Plus/Pro | `UNITY_SERIAL`, `UNITY_EMAIL`, `UNITY_PASSWORD` | Do not follow the Personal steps with a Pro license; the builder and test runner return the seat after use |
| Floating license server | `unityLicensingServer` input | Seat acquired before the build and returned after |

GameCI's docs advise avoiding special characters in the CI account password. Use a dedicated CI
Unity account, never a developer's personal account.

## Workflow: tests, then multi-platform build (GameCI v4)

```yaml
name: unity-ci
on:
  pull_request:
  push:
    branches: [main]
    tags: ["v*"]
permissions:
  contents: read
  checks: write          # test runner publishes a check with results
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true }
      - uses: actions/cache@v6
        with:
          path: Library
          key: Library-test-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: Library-test-
      - uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          testMode: all          # EditMode + PlayMode
          githubToken: ${{ secrets.GITHUB_TOKEN }}

  build:
    needs: test
    if: github.event_name != 'pull_request'
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        targetPlatform: [StandaloneWindows64, StandaloneLinux64, WebGL]
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true, fetch-depth: 0 }    # full history for semantic versioning
      - uses: actions/cache@v6
        with:
          path: Library
          key: Library-${{ matrix.targetPlatform }}-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-${{ matrix.targetPlatform }}-
            Library-
      - uses: game-ci/unity-builder@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          targetPlatform: ${{ matrix.targetPlatform }}
          buildName: EmberDrift
          # buildProfile: Assets/Settings/Build Profiles/Release-Windows.asset   # Unity 6 build profiles
      - uses: actions/upload-artifact@v7
        with:
          name: Build-${{ matrix.targetPlatform }}
          path: build/${{ matrix.targetPlatform }}
          retention-days: 14
          if-no-files-found: error
```

Outputs land in `build/<targetPlatform>/` by default (`buildsPath` input). For Pro licenses, swap
`UNITY_LICENSE` for `UNITY_SERIAL`.

## Gotchas

- **Library cache is the biggest win.** A cold import re-imports every asset. Key on `Assets/`,
  `Packages/` and `ProjectSettings/`; caches are per-OS, so a Windows cache never restores on Linux.
  GitHub evicts entries unused for 7 days and caps a repository at 10 GB by default, so large
  Library folders across many platforms will thrash: cache only your two most-built targets.
- **Git LFS bandwidth.** `lfs: true` downloads every LFS object on every job. Cache `.git/lfs`
  (recipe in `pipeline-hardening.md`) or check out LFS only in build jobs.
- **Runner memory and disk.** GitHub-hosted Linux runners are modest; large projects run out of
  memory or disk during import or IL2CPP. Options: trim imports, split builds, larger hosted
  runners, or self-hosted runners.
- **IL2CPP vs Mono.** IL2CPP is slower to build; use Mono for PR/test builds and IL2CPP for release
  builds via build profiles or `customParameters`.
- **Editor version.** GameCI reads `ProjectSettings/ProjectVersion.txt` to pick an image. A version
  without a published image fails; stay on versions GameCI publishes images for.
- **Unity 6.6 Fast Enter Play Mode** is on by default, so static state no longer resets between
  PlayMode tests in the editor; tests that pass in CI but fail locally (or the reverse) often trace to
  statics.
- **WebGL/WebGPU.** Unity 6.6 has WebGPU as an opt-in graphics API (disable Auto Graphics API, put
  WebGPU first, keep WebGL 2 as fallback). CI builds the same way; smoke-test with the web job.

## Unity CLI path (beta)

The Unity CLI is a standalone binary that drives editors and Unity services. From its release
notes (1.0.0-beta.16, 2026-11-03):

| Command | Use in CI |
|---|---|
| `unity ci init` | Generates CI workflow files; its workflows run `unity license activate` with the serial from the step environment |
| `unity license activate` / `unity license status` | Activate and check licenses on the runner |
| `unity install-modules ... --accept-eula` | Install build-target modules non-interactively |
| `unity build --target <platform>` | Build; refuses a dirty working tree unless `--allow-dirty-build`; some options (`--execute-method`, `--profile`, `--log-file`) need the editor closed |
| `unity test [project]` | Runs Edit Mode and Play Mode tests in batch mode |
| `unity doctor --ci --skip-license` | Environment check for runners licensed another way |

Because it is beta, generate the workflow with `unity ci init`, read it, pin the CLI version it
installs, and keep a GameCI or batch-mode fallback until it reaches 1.0. The same CLI hosts Unity's
official MCP server for local agent use; that is an editor/agent integration, not a CI step.

## Raw batch mode (self-hosted runners)

```bash
"$UNITY_PATH" -batchmode -nographics -quit \
  -projectPath . -buildTarget StandaloneWindows64 \
  -executeMethod BuildScripts.CI.BuildWindows \
  -logFile -                      # log to stdout
# Tests: -runTests -testPlatform PlayMode -testResults results.xml  (omit -quit with -runTests)
```

`BuildScripts.CI.BuildWindows` is your own static editor method calling
`BuildPipeline.BuildPlayer` (or activating a build profile). Fail the job on a non-zero exit code
and upload the log as an artifact.

## Deploy hand-off

Upload `build/StandaloneWindows64` and `build/StandaloneLinux64` artifacts and deploy them with
`game-ci/steam-deploy@v3` (see `deploy-targets.md`); WebGL builds go to itch.io, Cloudflare or
Netlify through the web deploy recipes.
