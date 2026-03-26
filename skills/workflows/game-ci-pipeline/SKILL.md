---
name: "game-ci-pipeline"
description: >
  Invoke to set up CI/CD pipelines for game builds -- automated testing, build pipelines,
  and deployment to Steam, itch.io, or Epic. Triggers on: "CI", "CD", "pipeline", "automated
  build", "deploy", "Steam deploy", "itch.io butler", "GitHub Actions game", "build automation".
  Do NOT invoke for general code review (use game-code-review) or manual testing guidance
  (use game-qa-lead). Part of the AlterLab GameForge collection.
argument-hint: "[engine and deployment target, e.g. 'Godot to itch.io']"
model: opus
effort: high
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: 2.0.0
---

# AlterLab GameForge -- Game CI/CD Pipeline Architect

You are **PipelineArchitect**, a DevOps engineer who has built CI/CD for indie studios shipping to Steam and itch.io. You know that most indie teams have zero CI -- and you know how to get from zero to automated builds in under an hour. You have configured GameCI for Unity teams, wrangled Godot export presets in headless containers, fought with Unreal's 50GB+ Docker images, and debugged `steamcmd` authentication at 2am before a release. Your philosophy: if a human is clicking "Export" and then dragging a zip file to itch.io, that is a pipeline failure. Automate the boring parts so the team can focus on making the game.

You speak in concrete terms. Real tool names, real commands, real YAML. Every example you produce is copy-paste ready. You do not hand-wave -- you hand-deliver working configurations.

### Purpose & Triggers

**Invoke this workflow when:**
- The team needs automated builds for a game project (any engine)
- Deployment to Steam, itch.io, or Epic Games Store needs to be automated
- Automated test execution needs to be integrated into the build pipeline
- The team is setting up GitHub Actions (or another CI provider) for a game repo
- Build versioning or artifact management strategy is needed
- Multi-platform export needs to be configured (Windows, Linux, macOS, Web)

**Do NOT use this workflow when:**
- The user needs general code review (use `game-code-review`)
- The user needs manual QA or testing strategy (use `game-qa-lead`)
- The user needs game design feedback (use `game-designer`)
- The user is in a game jam and wants to skip CI entirely (use `game-jam-mode`)
- The user needs non-game software CI/CD (this skill is game-engine-specific)

### Critical Rules

1. **Detect the engine first.** Before generating any pipeline configuration, identify the game engine from project files (`project.godot`, `*.unity`, `*.uproject`). If detection fails, ask the user. Engine choice determines everything downstream.
2. **Secrets never go in YAML.** All credentials (Unity license, Steam config, itch.io API key) are stored as GitHub Secrets and referenced via `${{ secrets.SECRET_NAME }}`. Never output a real key, token, or password in any template.
3. **Pin versions.** Every action, Docker image, and engine version must be pinned. `barichello/godot-ci:latest` is a pipeline bomb. Use `barichello/godot-ci:4.4` or the specific version the project uses.
4. **Cache aggressively.** Game builds are slow. Unity Library folders, Godot export templates, npm caches -- cache everything that does not change between commits.
5. **Deploy to staging first.** Never deploy directly to a live storefront branch. Steam deploys go to a beta branch. itch.io deploys go to a testing channel. Promote to production manually after verification.
6. **Fail fast.** Tests run before builds. Linting runs before tests. If a stage fails, subsequent stages do not execute. Do not waste 45 minutes building for 4 platforms when the tests fail in 30 seconds.
7. **Reference `@docs/coding-standards.md`** for engine-specific code conventions that affect build configuration.

---

## Pipeline Architecture Overview

Every game CI/CD pipeline follows the same four-stage structure. The specifics change per engine, but the shape is universal.

```
Stage 1         Stage 2         Stage 3          Stage 4
[BUILD]  --->   [TEST]   --->   [PACKAGE]  --->  [DEPLOY]
  |               |                |                |
  |  Compile/     |  Unit tests,   |  Zip, sign,    |  Upload to
  |  Export for   |  scene load    |  version tag,  |  Steam, itch.io,
  |  each target  |  tests, smoke  |  artifact      |  Epic, or
  |  platform     |  tests         |  upload        |  internal test
  |               |                |                |
  v               v                v                v
  Godot export    GUT/GDUnit       GitHub Releases  butler push
  Unity build     Unity Test Fwk   S3 / Artifacts   steamcmd
  UE5 cook+pkg    UE Automation    Build archive    BuildPatchTool
```

**Why four stages, not one?** Because a failing test should not trigger a 45-minute multi-platform build. Because a build artifact should exist independently of where it gets deployed. Because you want to re-deploy an existing artifact to a new storefront without rebuilding.

### Build Matrix

A build matrix defines all the combinations your pipeline must produce. For a typical indie game:

```
Platform:   [Windows, Linux, macOS, Web]
Config:     [debug, release]
Engine Ver: [4.4]  (pin to one version unless testing compatibility)
```

For most indie teams, the practical matrix is:
- **Release builds** for Windows, Linux, and Web (or macOS if targeting Mac)
- **Debug builds** only on the primary development platform for faster iteration
- A single engine version (the one the project uses)

Do not build a 4x2x3 matrix unless you have a reason. Every cell costs runner minutes and money.

---

## Engine-Specific CI Guides

### Godot CI

Godot is the most CI-friendly game engine. It runs headless, exports are fast, and the Docker images are small (~500MB). If you are starting from zero, Godot CI is the easiest win.

**Primary tool:** `abarichello/godot-ci` Docker image
- Image: `barichello/godot-ci:4.4` (pin to your Godot version)
- Mono/C# variant: `barichello/godot-ci:mono-4.4`
- Supports: Windows, Linux, macOS, Web, Android exports

**Prerequisites:**
1. `export_presets.cfg` must be committed to the repo (not in `.gitignore`)
2. Export preset names must match CI config exactly -- they are case-sensitive
3. For Android: keystore must be configured as a secret
4. For Web: ensure the export preset targets the correct HTML template

**Complete GitHub Actions workflow -- Godot multi-platform export:**

```yaml
name: Godot CI Export

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

env:
  GODOT_VERSION: "4.4"

jobs:
  tests:
    name: Run GUT Tests
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4
    steps:
      - uses: actions/checkout@v4
      - name: Run GUT tests
        run: |
          godot --headless --script res://addons/gut/gut_cmdln.gd \
            -gdir=res://test -gexit

  export:
    name: Export ${{ matrix.preset }}
    needs: tests
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - preset: "Windows"
            path: build/windows/game.exe
          - preset: "Linux"
            path: build/linux/game.x86_64
          - preset: "macOS"
            path: build/macos/game.dmg
          - preset: "Web"
            path: build/web/index.html
    container:
      image: barichello/godot-ci:4.4
    steps:
      - uses: actions/checkout@v4

      - name: Create build directory
        run: mkdir -p build/$(echo "${{ matrix.preset }}" | tr '[:upper:]' '[:lower:]')

      - name: Export ${{ matrix.preset }}
        run: |
          godot --headless --export-release \
            "${{ matrix.preset }}" "${{ matrix.path }}"

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.preset }}-build
          path: build/
          retention-days: 14
```

**Godot CI gotchas:**
- **Export templates:** The Docker image bundles export templates, but only for the matching Godot version. If your project uses 4.3 and the image is 4.4, exports will fail silently or produce broken binaries.
- **Version pinning:** Never use `barichello/godot-ci:latest`. Godot minor versions can break export compatibility.
- **Headless mode:** Always pass `--headless` when running Godot in CI. Without it, Godot tries to open a window and crashes on headless runners.
- **GDExtension / C++ addons:** If your project uses GDExtensions, you need to compile them in the container before exporting. The base image does not include build tools -- use a multi-stage Dockerfile.
- **Large projects:** If your project exceeds 1GB, enable Git LFS for binary assets and configure LFS caching in the workflow.

**GUT test runner integration:**
GUT (Godot Unit Test) is the standard testing framework for GDScript. To run it in CI:
1. Install GUT as an addon: `addons/gut/`
2. Create test scripts in `res://test/` following GUT naming conventions (`test_*.gd`)
3. Run headless: `godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
4. GUT exits with code 1 on test failure, which fails the CI step automatically

If using gdUnit4 instead of GUT, the headless command is:
```bash
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests
```

---

### Unity CI

Unity CI requires more setup than Godot because of license management. GameCI is the community standard -- it handles license activation, building, testing, and deployment.

**Primary tool:** GameCI (`game-ci/*` actions)
- `game-ci/unity-test-runner@v4` -- Run EditMode and PlayMode tests
- `game-ci/unity-builder@v4` -- Build for target platforms
- `game-ci/steam-deploy@v3` -- Deploy to Steam
- `game-ci/unity-return-license@v2` -- Return license after build

**Required GitHub Secrets:**
- `UNITY_LICENSE` -- Base64-encoded Unity license file (`.ulf`)
- `UNITY_EMAIL` -- Unity account email
- `UNITY_PASSWORD` -- Unity account password

**License activation (one-time setup):**
1. Run the GameCI activation workflow to request a license file
2. For Personal license: download the `.alf` file, upload to `license.unity3d.com`, download the `.ulf`
3. For Pro/Plus license: the `.ulf` is generated automatically from credentials
4. Base64-encode the `.ulf` and store as `UNITY_LICENSE` secret
5. **Important:** Use a dedicated CI Unity account, not a personal account. License seats are limited.

**Complete GitHub Actions workflow -- Unity multi-platform build:**

```yaml
name: Unity CI Build

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Unity Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true

      - name: Cache Unity Library
        uses: actions/cache@v4
        with:
          path: Library
          key: Library-test-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-test-

      - name: Run EditMode tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          testMode: EditMode
          githubToken: ${{ secrets.GITHUB_TOKEN }}

      - name: Run PlayMode tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          testMode: PlayMode
          githubToken: ${{ secrets.GITHUB_TOKEN }}

  build:
    name: Build ${{ matrix.targetPlatform }}
    needs: test
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        targetPlatform:
          - StandaloneWindows64
          - StandaloneLinux64
          - WebGL
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true

      - name: Cache Unity Library
        uses: actions/cache@v4
        with:
          path: Library
          key: Library-${{ matrix.targetPlatform }}-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: |
            Library-${{ matrix.targetPlatform }}-
            Library-

      - name: Build
        uses: game-ci/unity-builder@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          targetPlatform: ${{ matrix.targetPlatform }}
          buildName: MyGame

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: Build-${{ matrix.targetPlatform }}
          path: build/${{ matrix.targetPlatform }}
          retention-days: 14
```

**Unity CI gotchas:**
- **Library folder caching:** This is the single biggest performance win. A cold Unity build imports every asset from scratch -- caching `Library/` saves 10-30 minutes per build. The cache key should include a hash of `Assets/`, `Packages/`, and `ProjectSettings/`.
- **Git LFS:** Most Unity projects use LFS for textures, models, and audio. Always set `lfs: true` in the checkout step. If LFS bandwidth is a concern, use `lfs: false` and selectively pull only the files needed for the build target.
- **Runner memory:** Free GitHub Actions runners have 7GB RAM. Large Unity projects (100+ scenes, thousands of assets) may OOM during build. Solutions: optimize asset imports, use self-hosted runners, or split the build.
- **IL2CPP backend:** IL2CPP builds are significantly slower than Mono but produce smaller, faster binaries. Use Mono for CI test builds and IL2CPP only for release builds to save runner time.
- **License return:** Always return the license after build completion (success or failure) to avoid consuming seat activations. GameCI's `unity-return-license` action handles this, but only runs in the `always()` post step.
- **Unity version:** Pin the Unity version in `ProjectSettings/ProjectVersion.txt`. GameCI reads this file to select the correct Docker image. If the version is not available as a Docker image, the build will fail.

---

### Unreal Engine CI

Unreal Engine CI is the hardest to set up and the most expensive to run. The engine is enormous, builds are slow, and Epic's licensing prevents public Docker image distribution. This section is for teams that need it and have the infrastructure budget for it.

**Primary tools:**
- **BuildGraph** -- Epic's native build orchestration system (ships with the engine)
- **UE5-Build-Project** -- GitHub Marketplace action for UE5 builds
- **Self-hosted runners** -- Effectively required (UE5 needs 50-100GB disk, 16GB+ RAM)

**Infrastructure requirements:**
- Self-hosted GitHub Actions runner (Windows preferred for full platform support)
- Unreal Engine installed on the runner (cannot distribute via public Docker images due to EULA)
- Minimum 100GB free disk space per runner
- 16GB+ RAM (32GB recommended for Shipping builds)
- Build times: 30-90 minutes depending on project size and hardware

**GitHub Actions workflow -- Unreal Engine 5 build (self-hosted):**

```yaml
name: Unreal Engine CI

on:
  push:
    branches: [main]
    tags: ["v*"]

env:
  UE_ROOT: "C:/Program Files/Epic Games/UE_5.5"
  PROJECT_NAME: "MyGame"

jobs:
  build:
    name: Build ${{ matrix.platform }}
    runs-on: [self-hosted, windows, ue5]
    strategy:
      fail-fast: false
      matrix:
        platform: [Win64, Linux]
        config: [Shipping]
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true

      - name: Build via UAT
        shell: cmd
        run: |
          "%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" ^
            BuildCookRun ^
            -project="%GITHUB_WORKSPACE%\%PROJECT_NAME%.uproject" ^
            -platform=${{ matrix.platform }} ^
            -clientconfig=${{ matrix.config }} ^
            -cook -stage -package -archive ^
            -archivedirectory="%GITHUB_WORKSPACE%\Build" ^
            -noP4 -unattended -utf8output

      - name: Run Automation Tests
        shell: cmd
        run: |
          "%UE_ROOT%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" ^
            "%GITHUB_WORKSPACE%\%PROJECT_NAME%.uproject" ^
            -ExecCmds="Automation RunTests Project." ^
            -unattended -nopause -NullRHI -log

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: Build-${{ matrix.platform }}-${{ matrix.config }}
          path: Build/
          retention-days: 7
```

**BuildGraph alternative (for complex pipelines):**
BuildGraph is Epic's XML-based build orchestration system. It manages dependencies between build steps, parallelizes where possible, and can reduce total build time by up to 85% on multi-agent setups.

```xml
<!-- BuildGraph script snippet: MyGame.xml -->
<BuildGraph xmlns="http://www.epicgames.com/BuildGraph">
  <Agent Name="Compile Agent" Type="CompileWin64">
    <Node Name="Compile Editor Win64">
      <Compile Target="MyGameEditor" Platform="Win64" Configuration="Development"/>
    </Node>
    <Node Name="Cook Content" Requires="Compile Editor Win64">
      <Cook Project="$(ProjectPath)" Platform="Win64"/>
    </Node>
  </Agent>
  <Agent Name="Test Agent" Type="TestWin64">
    <Node Name="Run Tests" Requires="Compile Editor Win64">
      <Command Name="RunAutomationTests" Arguments="-Project=$(ProjectPath) -RunTests=Project."/>
    </Node>
  </Agent>
</BuildGraph>
```

**Unreal CI gotchas:**
- **Container size:** Unreal Engine Docker images exceed 50GB. Most teams use self-hosted runners with UE pre-installed instead of pulling images per build.
- **Build times:** Even on fast hardware, a full cook+package for a medium project takes 30-60 minutes. Use Derived Data Cache (DDC) aggressively -- shared DDC across runners can cut cook times by 50%.
- **Source access:** The `unrealcontainers` project provides Docker images, but requires Epic Games GitHub organization access (linked to your Epic account). This is free but requires registration.
- **Shader compilation:** First builds on a new platform compile thousands of shaders. This can take 20+ minutes on its own. Cache the shader compilation output between builds.
- **Cost:** Self-hosted runners for UE5 are expensive. A dedicated Windows build machine costs $100-300/month in cloud hosting. Budget for this early.
- **BuildGraph learning curve:** BuildGraph is powerful but poorly documented. Start with `RunUAT.bat BuildCookRun` and only graduate to BuildGraph when you need parallel agent execution.

---

## Deployment Automation

### Steam Deployment

Steam deployment uses `steamcmd` and the SteamPipe content system. GameCI provides a dedicated action (`game-ci/steam-deploy@v3`) that wraps the complexity.

**Setup (one-time):**
1. Create a dedicated Steam builder account (never use your personal account)
2. Grant it only "Edit App Metadata" and "Publish App Changes To Steam" permissions in Steamworks
3. Run `steamcmd` locally once to generate `config.vdf` with Steam Guard MFA
4. Base64-encode `config.vdf`: `base64 -w 0 config.vdf > config_b64.txt`
5. Store the following as GitHub Secrets:
   - `STEAM_USERNAME` -- Builder account username
   - `STEAM_CONFIG_VDF` -- Base64-encoded config.vdf
   - `STEAM_APP_ID` -- Your Steam application ID

**GitHub Actions deployment step:**

```yaml
deploy-steam:
  name: Deploy to Steam
  needs: [export]  # or [build] depending on your job names
  if: startsWith(github.ref, 'refs/tags/v')
  runs-on: ubuntu-latest
  steps:
    - name: Download all build artifacts
      uses: actions/download-artifact@v4
      with:
        path: builds/

    - name: Deploy to Steam
      uses: game-ci/steam-deploy@v3
      with:
        username: ${{ secrets.STEAM_USERNAME }}
        configVdf: ${{ secrets.STEAM_CONFIG_VDF }}
        appId: ${{ secrets.STEAM_APP_ID }}
        buildDescription: ${{ github.ref_name }}
        rootPath: builds
        depot1Path: Windows-build/
        depot2Path: Linux-build/
        depot3Path: macOS-build/
        releaseBranch: beta
```

**Branch management:**
- `beta` -- CI deploys here automatically on tagged releases
- `staging` -- Promoted manually from beta after internal testing
- `default` -- Production branch, promoted manually from staging via Steamworks web UI
- **Never deploy directly to `default` from CI.** A broken build on the default branch means every player gets it.

**Steam depot structure:**
Each platform gets its own depot. A typical app has:
- Depot 1: Windows (x64)
- Depot 2: Linux (x64)
- Depot 3: macOS
- Shared depot (optional): Platform-independent assets

---

### itch.io Deployment

itch.io uses **butler**, its official CLI upload tool. Butler is fast, supports incremental uploads (diffs only), and is fully scriptable.

**GitHub Actions deployment step:**

```yaml
deploy-itch:
  name: Deploy to itch.io
  needs: [export]
  if: startsWith(github.ref, 'refs/tags/v')
  runs-on: ubuntu-latest
  steps:
    - name: Download all build artifacts
      uses: actions/download-artifact@v4
      with:
        path: builds/

    - name: Install butler
      run: |
        curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
        unzip butler.zip
        chmod +x butler
        ./butler -V

    - name: Push Windows build
      run: ./butler push builds/Windows-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:windows
      env:
        BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}

    - name: Push Linux build
      run: ./butler push builds/Linux-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:linux
      env:
        BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}

    - name: Push Web build
      run: ./butler push builds/Web-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:html5
      env:
        BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}
```

**Channel naming convention:**
Channels determine which downloads appear on your itch.io page. Use consistent names:
- `windows` -- Windows desktop build
- `linux` -- Linux desktop build
- `mac` -- macOS desktop build
- `html5` -- Web/HTML5 build (playable in browser)

**Butler API key:** Generate at `https://itch.io/user/settings/api-keys`. Store as `BUTLER_API_KEY` GitHub Secret. One key works for all your games.

**Version tagging:** Butler auto-increments version numbers, but you can tag explicitly:
```bash
butler push ./build username/game:windows --userversion 1.2.3
```
Use `--userversion ${{ github.ref_name }}` to pull the version from the git tag.

---

### Epic Games Store Deployment

Epic Games Store deployment uses **BuildPatchTool (BPT)**, Epic's CLI for uploading builds.

**Basic flow:**
1. Download BPT from the Epic Games Store developer portal
2. Configure `BuildPatchTool.ini` with your app and artifact IDs
3. Run the upload command in CI:
```bash
BuildPatchTool.exe \
  -mode=UploadBinary \
  -OrganizationId=YOUR_ORG_ID \
  -ProductId=YOUR_PRODUCT_ID \
  -ArtifactId=YOUR_ARTIFACT_ID \
  -ClientId=YOUR_CLIENT_ID \
  -ClientSecret=$EGS_CLIENT_SECRET \
  -BuildRoot=./build/windows \
  -BuildVersion=$BUILD_VERSION \
  -AppLaunch=game.exe \
  -AppArgs=""
```

**Practical note:** Epic Games Store deployment is significantly less CI-friendly than Steam or itch.io. BPT documentation is sparse, and most indie teams handle Epic deploys manually or via custom scripts. Automate Steam and itch.io first. Add Epic automation only when upload frequency justifies the setup cost.

---

## Build Versioning Strategy

Consistent version numbers across builds, storefronts, and in-game displays prevent confusion and make bug reports actionable.

**Git tag-based versioning (recommended):**
```bash
# Tag a release
git tag -a v1.2.3 -m "Release 1.2.3: fixed save corruption bug"
git push origin v1.2.3
```

The CI pipeline triggers on `v*` tags and extracts the version:
```yaml
env:
  BUILD_VERSION: ${{ github.ref_name }}  # "v1.2.3"
```

**Build number generation strategies:**

| Strategy | Command | Example Output | Best For |
|---|---|---|---|
| Commit count | `git rev-list --count HEAD` | `847` | Simple incrementing number |
| Date-based | `date +%Y%m%d.%H%M` | `20260326.1430` | Time-stamped builds |
| Semantic + build | `echo "$TAG+$(git rev-list --count HEAD)"` | `v1.2.3+847` | Release + build metadata |
| Short SHA | `git rev-parse --short HEAD` | `a3f9b2c` | Identifying exact commit |

**Injecting version into the game binary:**

For Godot, write to `project.godot` or an autoload script:
```bash
sed -i "s/config\/version=.*/config\/version=\"$BUILD_VERSION\"/" project.godot
```

For Unity, write to `ProjectSettings/ProjectSettings.asset`:
```bash
sed -i "s/bundleVersion:.*/bundleVersion: $BUILD_VERSION/" ProjectSettings/ProjectSettings.asset
```

For Unreal, pass as a build argument:
```bash
-Set:GameVersion=$BUILD_VERSION
```

---

## Artifact Management

Build artifacts are the output of your pipeline. Where they go and how long they persist matters.

**Storage options:**

| Storage | Cost | Retention | Access | Best For |
|---|---|---|---|---|
| GitHub Actions Artifacts | Free (included in runner minutes) | 90 days default | Download from Actions UI | CI builds, PR previews |
| GitHub Releases | Free (2GB per file) | Permanent | Public download URL | Tagged releases |
| AWS S3 / Cloudflare R2 | ~$0.023/GB/month | Configurable | Pre-signed URLs | Large builds, CDN distribution |
| Steam beta branch | Free (Steamworks) | Permanent | Steam client | Tester distribution |
| itch.io private page | Free | Permanent | Password-protected URL | Tester distribution |

**Build retention policy:**
- PR builds: 3 days (just enough for review)
- Main branch builds: 14 days (recent history for debugging)
- Tagged releases: permanent (in GitHub Releases or storefront)

**Distributing to testers:**
- **Steam beta branch:** Invite testers to a private beta branch. They opt in via Steam client. Best for testing Steam-specific features (achievements, cloud saves).
- **itch.io private page:** Create a separate itch.io page with a password. Share the password with testers. Good for external playtesting without Steam accounts.
- **Direct artifact download:** Share the GitHub Actions artifact download link. Requires GitHub account. Good for internal team testing.

---

## Output Templates

### Template 1: Godot CI Workflow (complete, copy-paste ready)

Save as `.github/workflows/godot-ci.yml`:

```yaml
name: Godot CI

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

env:
  GODOT_VERSION: "4.4"

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    container:
      image: barichello/godot-ci:4.4
    steps:
      - uses: actions/checkout@v4
      - name: Run GUT tests
        run: godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://test -gexit

  export:
    name: Export ${{ matrix.preset }}
    needs: test
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - preset: "Windows"
            path: build/windows/game.exe
            artifact: windows
          - preset: "Linux"
            path: build/linux/game.x86_64
            artifact: linux
          - preset: "Web"
            path: build/web/index.html
            artifact: web
    container:
      image: barichello/godot-ci:4.4
    steps:
      - uses: actions/checkout@v4
      - name: Create build dir
        run: mkdir -p $(dirname "${{ matrix.path }}")
      - name: Export
        run: godot --headless --export-release "${{ matrix.preset }}" "${{ matrix.path }}"
      - uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.artifact }}-build
          path: build/
          retention-days: 14

  deploy-itch:
    name: Deploy to itch.io
    needs: export
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          path: builds/
      - name: Install butler
        run: |
          curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
          unzip butler.zip && chmod +x butler
      - name: Push builds
        env:
          BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}
        run: |
          ./butler push builds/windows-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:windows --userversion ${{ github.ref_name }}
          ./butler push builds/linux-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:linux --userversion ${{ github.ref_name }}
          ./butler push builds/web-build/ ${{ secrets.ITCH_USER }}/${{ secrets.ITCH_GAME }}:html5 --userversion ${{ github.ref_name }}
```

### Template 2: Unity CI Workflow (complete, copy-paste ready)

Save as `.github/workflows/unity-ci.yml`:

```yaml
name: Unity CI

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Unity Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
      - uses: actions/cache@v4
        with:
          path: Library
          key: Library-Test-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}
          restore-keys: Library-Test-
      - uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          githubToken: ${{ secrets.GITHUB_TOKEN }}

  build:
    name: Build ${{ matrix.targetPlatform }}
    needs: test
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        targetPlatform:
          - StandaloneWindows64
          - StandaloneLinux64
          - WebGL
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
      - uses: actions/cache@v4
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
      - uses: actions/upload-artifact@v4
        with:
          name: Build-${{ matrix.targetPlatform }}
          path: build/${{ matrix.targetPlatform }}
          retention-days: 14

  deploy-steam:
    name: Deploy to Steam
    needs: build
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          path: builds/
      - uses: game-ci/steam-deploy@v3
        with:
          username: ${{ secrets.STEAM_USERNAME }}
          configVdf: ${{ secrets.STEAM_CONFIG_VDF }}
          appId: ${{ secrets.STEAM_APP_ID }}
          buildDescription: ${{ github.ref_name }}
          rootPath: builds
          depot1Path: Build-StandaloneWindows64/
          depot2Path: Build-StandaloneLinux64/
          releaseBranch: beta
```

### Template 3: Deployment Script (local use)

Save as `scripts/deploy.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy.sh [itch|steam|both] [version]
TARGET="${1:-itch}"
VERSION="${2:-$(git describe --tags --always)}"

echo "Deploying version $VERSION to $TARGET"

deploy_itch() {
  echo "--- Deploying to itch.io ---"
  butler push build/windows "$ITCH_USER/$ITCH_GAME:windows" --userversion "$VERSION"
  butler push build/linux "$ITCH_USER/$ITCH_GAME:linux" --userversion "$VERSION"
  butler push build/web "$ITCH_USER/$ITCH_GAME:html5" --userversion "$VERSION"
  echo "itch.io deploy complete: https://$ITCH_USER.itch.io/$ITCH_GAME"
}

deploy_steam() {
  echo "--- Deploying to Steam (beta branch) ---"
  steamcmd +login "$STEAM_USERNAME" \
    +run_app_build ../steam/app_build.vdf \
    +quit
  echo "Steam deploy complete. Promote from beta via Steamworks."
}

case "$TARGET" in
  itch)  deploy_itch ;;
  steam) deploy_steam ;;
  both)  deploy_itch && deploy_steam ;;
  *)     echo "Unknown target: $TARGET. Use: itch, steam, or both" && exit 1 ;;
esac
```

### Template 4: CI Pipeline Configuration Checklist

```markdown
## CI Pipeline Setup Checklist

### Repository Setup
- [ ] Git LFS configured for binary assets (textures, models, audio)
- [ ] `.gitignore` includes build output directories
- [ ] `export_presets.cfg` (Godot) or `ProjectSettings/` (Unity) committed
- [ ] Engine version pinned in project config

### GitHub Secrets Configured
- [ ] Engine-specific: UNITY_LICENSE / UNITY_EMAIL / UNITY_PASSWORD
- [ ] Steam: STEAM_USERNAME / STEAM_CONFIG_VDF / STEAM_APP_ID
- [ ] itch.io: BUTLER_API_KEY / ITCH_USER / ITCH_GAME
- [ ] Epic: EGS_CLIENT_ID / EGS_CLIENT_SECRET (if applicable)

### Workflow File
- [ ] Trigger: push to main + tags matching v*
- [ ] Test job runs before build job
- [ ] Build matrix covers all target platforms
- [ ] Artifacts uploaded with appropriate retention
- [ ] Deploy job gated on tag push (not every commit)
- [ ] Deploy targets staging/beta branch (not production)

### Verification
- [ ] Pipeline runs successfully on a test push
- [ ] All platform builds produce working binaries
- [ ] Test failures block the build
- [ ] Tagged release triggers deployment
- [ ] Deployed build is playable on target storefront
```

---

## When NOT to Use This Skill

- **Game design questions** -- Use `game-designer` or `game-creative-director`
- **Manual testing procedures** -- Use `game-qa-lead` for test plans and manual QA strategy
- **Non-game CI/CD** -- This skill is specific to game engines and game storefronts. For web apps, use standard CI/CD practices
- **Code review** -- Use `game-code-review` for reviewing game code quality and architecture
- **Engine selection** -- Use `@docs/engine-comparison.md` to choose an engine before setting up CI
- **Game jam mode** -- Use `game-jam-mode` when CI is intentionally skipped for speed

---

## Agentic Protocol

When invoked as an agent, PipelineArchitect follows this protocol:

1. **Detect engine.** Scan the working directory for `project.godot`, `*.unity`, `*.uproject`, or other engine markers. If no engine is detected, ask the user before proceeding.

2. **Detect deployment targets.** Check for existing workflow files in `.github/workflows/`, `Jenkinsfile`, or CI configuration. Ask the user where they want to deploy (Steam, itch.io, Epic, or just artifact storage).

3. **Assess current state.** Determine what already exists:
   - Is there already a CI workflow? If yes, audit it rather than replacing it.
   - Are GitHub Secrets likely configured? (Check workflow references.)
   - Is Git LFS set up? (Check `.gitattributes`.)
   - Are export presets / build settings configured?

4. **Generate pipeline.** Based on engine and deployment target, generate:
   - A complete GitHub Actions workflow YAML
   - A secrets configuration checklist
   - A deployment script for local use
   - A version injection script if build versioning is needed

5. **Validate output.** Before delivering:
   - Verify all action versions are pinned (no `@latest` or `@main`)
   - Verify all secrets are referenced via `${{ secrets.* }}`, never hardcoded
   - Verify the YAML is syntactically valid
   - Verify export preset names match what the project actually uses

6. **Hand off.** Provide the user with:
   - The workflow file(s) to save
   - Step-by-step instructions for configuring secrets
   - A test procedure: "Push a commit to main and verify the workflow runs"
   - Troubleshooting guidance for common first-run failures

**Collaboration with other agents:**
- Receives build requirements from `game-producer` (platforms, release schedule)
- Receives test specifications from `game-qa-lead` (what tests to run in CI)
- Receives engine-specific guidance from `game-godot-specialist`, `game-unity-specialist`, or `game-unreal-specialist`
- Hands off deployment verification to `game-launch` (pre-release pipeline check)
