# Deploy Targets and Versioning

Read this before writing any deploy job. Rule zero: CI deploys to a **test** destination (Steam beta
branch, itch.io staging page or channel, preview URL). A human promotes to players.

## Steam (SteamPipe)

### One-time setup

1. Create a **dedicated build account** in Steamworks with only the permissions needed to upload
   and set builds live on beta branches. Valve recommends a dedicated build account for security.
2. If the app is released, the build account needs a phone number or the Steam Mobile App attached
   to set builds live (Valve's SteamPipe docs).
3. Log in once with SteamCMD on a trusted machine to complete Steam Guard, then base64-encode
   `config/config.vdf` from the SteamCMD home. Logging in again with a password issues a new Steam
   Guard token, so CI reuses this authorized session instead.
4. Secrets: `STEAM_USERNAME`, `STEAM_CONFIG_VDF` (base64), and `STEAM_APP_ID` (a variable is fine;
   it is not secret).

### Job (GameCI steam-deploy v3)

```yaml
  deploy-steam:
    needs: build
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-24.04
    environment: steam                  # require a reviewer before any upload
    steps:
      - uses: actions/download-artifact@v8
        with: { path: builds }          # one folder per uploaded artifact name
      - uses: game-ci/steam-deploy@v3
        with:
          username: ${{ secrets.STEAM_USERNAME }}
          configVdf: ${{ secrets.STEAM_CONFIG_VDF }}
          appId: ${{ vars.STEAM_APP_ID }}
          buildDescription: ${{ github.ref_name }}
          rootPath: builds
          depot1Path: Build-StandaloneWindows64     # depot IDs default to appId+1, +2 ...
          depot2Path: Build-StandaloneLinux64
          releaseBranch: beta
```

`game-ci/steam-deploy` v3.2.2 (2026-10-25) also accepts `firstDepotIdOverride`, per-depot install
scripts, `extraExclusions` and `debugBranch`, and outputs the Steam `buildId`. Like GameCI's
builder v6 it now installs a `game-ci/cli` binary (`cliVersion`, default `latest`); pin it.

### Branch policy

| Branch | Who sets it live | How |
|---|---|---|
| `beta` (password or private) | CI on tags | `releaseBranch: beta` / `SetLive` in the app build VDF |
| `staging` | Producer, after internal test | Steamworks web UI |
| `default` | Producer, after sign-off | Steamworks web UI only: SteamPipe states the default branch cannot be set live automatically |

Depots: one per platform (Windows x64, Linux x64, macOS), optionally a shared content depot. Keep
debug symbols out of player depots (the action excludes `*.pdb` by default).

### Plain SteamCMD (self-hosted or local)

```bash
steamcmd +login "$STEAM_USERNAME" +run_app_build "$PWD/steam/app_build.vdf" +quit
```

with `"SetLive" "beta"` in `app_build.vdf`. Never put the password on the command line in CI logs.

## itch.io (butler)

| Fact | Detail |
|---|---|
| Install | `https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default` (permanent URL, latest stable) |
| Auth | `BUTLER_API_KEY` env var; get the key via `butler login` locally or from itch.io API keys settings (source `wharf`). Revoke immediately if it appears in a log |
| Push | `butler push <dir> user/game:channel` |
| Version | `--userversion 1.2.3` or `--userversion-file buildnumber.txt` |
| No-op uploads | `--if-changed` skips a push identical to the latest build |
| Preview | `--dry-run` shows what would be pushed |
| Channel tags | Names containing `win`/`windows`, `linux`, `mac`/`osx`, `android` are auto-tagged; HTML5 "playable in browser" is set once on the edit page |

```yaml
      - name: Push desktop and web builds
        env: { BUTLER_API_KEY: "${{ secrets.BUTLER_API_KEY }}" }
        run: |
          V="${{ github.ref_name }}"
          ./butler push builds/windows "$ITCH_TARGET:windows" --userversion "$V" --if-changed
          ./butler push builds/linux   "$ITCH_TARGET:linux"   --userversion "$V" --if-changed
          ./butler push builds/web     "$ITCH_TARGET:html5"   --userversion "$V" --if-changed
```

Set `ITCH_TARGET` (`user/game`) as a repository variable. For staging, push to a second, restricted
itch.io page (`user/game-staging`) and promote by pushing the same artifact to the public page.
itch.io requires disclosure of generative-AI content on the page and removed bulk AI uploads in
November 2026; the disclosure is a page setting, not a CI step, but release checklists should
confirm it (`game-launch`).

## Web hosts

Cloudflare Pages, Netlify and itch.io HTML5 recipes are in `web-ci.md`. Portal SDK integration and
submission rules (Poki, CrazyGames, YouTube Playables, Discord Activities) belong to
`game-web-publish`.

## Epic Games Store

Uploads use Epic's BuildPatchTool with organization, product, artifact and client credentials from
the Epic developer portal. Documentation is thin and most indies upload per release by script.
Automate Steam and itch.io first; add Epic only when upload frequency justifies it, keep the client
secret in a protected environment, and never upload from PR workflows.

## GitHub Releases

For tagged builds you want to keep: attach zipped artifacts to a release with
`gh release create "$TAG" builds/*.zip --notes-file CHANGELOG-excerpt.md` (needs
`permissions: contents: write` on that job only).

## Versioning

| Scheme | Source | Example | Good for |
|---|---|---|---|
| SemVer tag | `github.ref_name` | `v1.4.0` | Releases |
| Tag + build number | `git rev-list --count HEAD` | `v1.4.0+912` | Store build descriptions |
| Short SHA | `git rev-parse --short HEAD` | `a3f9b2c` | Internal builds, bug reports |

Inject the version so players and crash reports show it:
- **Godot:** `sed -i "s/^config\/version=.*/config\/version=\"$V\"/" project.godot` before export;
  read with `ProjectSettings.get_setting("application/config/version")`.
- **Unity:** GameCI's builder versions builds (`versioning: Semantic` by default, or `Custom` with
  `version:`); it needs full history (`fetch-depth: 0`).
- **Unreal:** write the version into `Config/DefaultGame.ini` (`ProjectVersion=` under
  `[/Script/EngineSettings.GeneralProjectSettings]`) before BuildCookRun.
- **Web:** `define: { __APP_VERSION__: JSON.stringify(process.env.APP_VERSION) }` in
  `vite.config.ts`, with `APP_VERSION: ${{ github.ref_name }}` in the build step env.

## Local deploy script (for releases cut by hand)

```bash
#!/usr/bin/env bash
set -euo pipefail
# Usage: scripts/deploy.sh [itch|steam|both] [version]
TARGET="${1:-itch}"; VERSION="${2:-$(git describe --tags --always)}"
: "${ITCH_TARGET:?set ITCH_TARGET=user/game}"
deploy_itch() {
  butler push build/windows "$ITCH_TARGET:windows" --userversion "$VERSION" --if-changed
  butler push build/linux   "$ITCH_TARGET:linux"   --userversion "$VERSION" --if-changed
  butler push build/web     "$ITCH_TARGET:html5"   --userversion "$VERSION" --if-changed
}
deploy_steam() {
  steamcmd +login "$STEAM_USERNAME" +run_app_build "$PWD/steam/app_build.vdf" +quit
  echo "Uploaded to the beta branch. Promote in Steamworks after testing."
}
case "$TARGET" in
  itch) deploy_itch ;; steam) deploy_steam ;; both) deploy_itch; deploy_steam ;;
  *) echo "Unknown target: $TARGET (itch|steam|both)"; exit 1 ;;
esac
```
