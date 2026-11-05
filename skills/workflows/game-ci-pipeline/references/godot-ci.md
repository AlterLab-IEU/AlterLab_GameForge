# Godot CI (4.7 stable, 4.8 beta, GDScript and .NET)

Read this before writing a Godot pipeline. Versions verified November 2026.

## Choosing the runner setup

| Situation | Use | Why |
|---|---|---|
| GDScript, Godot 4.7.x stable | Container `barichello/godot-ci:4.7.2` | Editor plus matching export templates preinstalled; tags exist per patch release (4.7, 4.7.1, 4.7.2 published 2026-08-18) |
| C#, Godot 4.7.x | Container `barichello/godot-ci:mono-4.7.2` plus .NET SDK step if you build solutions | .NET-enabled editor and templates |
| Godot 4.8 betas, or C# on 4.8 | `chickensoft-games/setup-godot@v2` (v2.4.3, 2026-10-01) with `actions/setup-dotnet@v6` installing .NET 10 | No container image tracks betas; the 4.8 .NET build needs .NET 10 |
| macOS or Windows runners (signing, notarization, native tests) | `chickensoft-games/setup-godot@v2` | Installs Godot directly on the runner; 4.8 ships per-architecture macOS binaries, so pick the runner arch deliberately |

Pin the image tag or the `version:` input to the exact patch the team uses. Never `latest`:
export templates must match the editor version exactly or exports fail or produce broken builds.

## Prerequisites in the repository

1. `export_presets.cfg` committed (not in `.gitignore`), with **no credentials in it**. Preset names
   are case-sensitive and must match the workflow exactly; quote names with spaces.
2. `.godot/` ignored; `*.uid` files (4.4+) committed.
3. Tests under `res://tests` (GUT 9.x for Godot 4, or gdUnit4).
4. Large binaries in Git LFS (match `lfs_threshold_mb` in `.gameforge/project.json`).
5. C#: a `global.json` if you use `setup-godot`'s `version: global.json` mode.

Version facts that bite: the Godot 4.5 C# docs require .NET 8 or later (.NET 9 for Android export);
4.8's .NET build needs .NET 10; **C# projects cannot export to the web** in Godot 4.x; web export uses
the Compatibility renderer (WebGL 2) only.

## Workflow: GDScript, 4.7.2, test then export

```yaml
name: godot-ci
on:
  pull_request:
  push:
    branches: [main]
    tags: ["v*"]
permissions:
  contents: read
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
env:
  GODOT_VERSION: "4.7.2"

jobs:
  test:
    runs-on: ubuntu-24.04
    container: { image: "barichello/godot-ci:4.7.2" }
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true }
      - name: Move preinstalled templates/config to the job HOME
        run: |
          mkdir -p ~/.local/share/godot/export_templates ~/.config
          mv /root/.config/godot ~/.config/godot || true
          mv /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable ~/.local/share/godot/export_templates/ || true
      - name: Import assets
        run: godot --headless --import
      - name: Unit tests (GUT)
        run: godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

  export:
    needs: test
    runs-on: ubuntu-24.04
    container: { image: "barichello/godot-ci:4.7.2" }
    strategy:
      fail-fast: false
      matrix:
        include:
          - { preset: "Windows Desktop", out: "build/windows/EmberDrift.exe", name: windows }
          - { preset: "Linux",           out: "build/linux/EmberDrift.x86_64", name: linux }
          - { preset: "Web",             out: "build/web/index.html",          name: web }
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true }
      - name: Templates to HOME
        run: |
          mkdir -p ~/.local/share/godot/export_templates ~/.config
          mv /root/.config/godot ~/.config/godot || true
          mv /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable ~/.local/share/godot/export_templates/ || true
      - name: Import
        run: godot --headless --import
      - name: Export ${{ matrix.preset }}
        run: |
          mkdir -p "$(dirname '${{ matrix.out }}')"
          godot --headless --export-release "${{ matrix.preset }}" "${{ matrix.out }}"
      - uses: actions/upload-artifact@v7
        with:
          name: ${{ matrix.name }}
          path: build/${{ matrix.name }}
          retention-days: ${{ startsWith(github.ref, 'refs/tags/') && 30 || 7 }}
          if-no-files-found: error
```

Notes:
- The "move templates" step mirrors the godot-ci project's own example: GitHub container jobs run
  with a `HOME` that is not `/root`, so the preinstalled templates must be moved.
- `--import` first makes the first export on a clean checkout reliable and surfaces missing assets.
- For C# with the `mono-` image, the template folder ends in `.stable.mono`; add
  `godot --headless --build-solutions --quit` before exporting.
- `if-no-files-found: error` turns a silent empty export into a red build.

## Workflow fragment: Godot 4.8 beta with .NET 10

```yaml
  build-dotnet:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v7
        with: { lfs: true }
      - uses: actions/setup-dotnet@v6
        with: { dotnet-version: "10.0.x" }
      - uses: chickensoft-games/setup-godot@v2
        with:
          version: 4.8.0-beta.2      # match the beta your team runs; or "global.json"
          use-dotnet: true
          include-templates: true
      - run: dotnet restore
      - run: godot --headless --build-solutions --quit || exit 0
      - run: dotnet test --no-restore
      - run: godot --headless --export-release "Linux" build/linux/EmberDrift.x86_64
```

Check `setup-godot`'s version-string format (it follows GodotSharp version strings, for example
`4.0.0-beta.16`) against the exact 4.8 beta tag before committing.

## Test runners

| Framework | CI command or action | Exit behavior |
|---|---|---|
| GUT 9.x | `godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` | Non-zero on failure with `-gexit` |
| gdUnit4 | `MikeSchulze/gdUnit4-action@v1` with `godot-version` and `paths: res://tests` (supports `godot-net` for C#) | Fails the step; can publish a report |
| C# unit tests | `dotnet test` on a test project that does not need the engine running | Standard |
| Parse check | `godot --headless --check-only --script res://path/file.gd` | Non-zero on parse errors; cheap PR gate for agent-written scripts |

## Platform-specific export notes

- **Web.** Single-threaded export has been the default since 4.3. Threaded exports need
  `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` from the
  host (Cloudflare/Netlify `_headers`; itch.io's SharedArrayBuffer toggle). GDExtension on the web
  needs Extension Support plus cross-origin isolation. Smoke-test the web export with the Playwright
  job in `web-ci.md`.
- **Android.** Supply the keystore through Godot's documented env vars, never through
  `export_presets.cfg`: `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`,
  `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` (debug variants exist). Decode a base64 secret to a file
  at job start and delete it at the end.
- **macOS.** Code signing and notarization need Apple credentials as secrets; run on a macOS runner
  or follow Godot's macOS export docs for signing from other platforms. Expect notarization to be
  the slowest step; run it only on tags.
- **Windows.** Code signing (if any) only on tag builds; keep certificates in secrets or a signing
  service, never in the repo.

## Caching

The container image already holds the editor and templates, so the main cache wins are:
- `.godot/imported/` keyed on a hash of source assets is possible but often not worth the size;
  measure import time first. Never commit `.godot/`.
- `~/.nuget/packages` for C# keyed on `**/*.csproj`.
- `setup-godot` caches its own downloads (`cache: true` by default).

## Common first-run failures

| Symptom | Cause | Fix |
|---|---|---|
| "No export template found" | Template version folder not under the job's `HOME`, or version mismatch | Run the move step; pin image tag to the project's exact version |
| "Invalid export preset name" | Case or spacing mismatch | Copy the name from `export_presets.cfg` |
| Export succeeds, game shows pink/missing assets | Import never ran, LFS pointers instead of files | `--import` step; `lfs: true` on checkout |
| C# build fails on 4.8 | .NET 8 SDK on the runner | `actions/setup-dotnet@v6` with `10.0.x` |
| Web build blank on host | Threads enabled without COOP/COEP | Disable threads or set headers |
