# CI/CD Pipeline Configuration

> Planning template for setting up automated builds and deployment. Fill this in before writing your pipeline YAML.

---

## Project Details

| Field | Value |
|-------|-------|
| **Game Name** | [Your game name] |
| **Engine** | [Godot 4.7 / Unity 6.3 LTS or 6.6 / Unreal 5.8 / Web: Vite + Three.js, Phaser 4 or PixiJS 8] |
| **Repository** | [GitHub / GitLab / Bitbucket] |
| **Team Size** | [Solo / 2-5 / 5+] |

---

## Build Targets

| Platform | Build Type | Priority | Notes |
|----------|-----------|----------|-------|
| Windows | Release | [High/Medium/Low] | [x64 only / x86+x64] |
| Linux | Release | [High/Medium/Low] | |
| macOS | Release | [High/Medium/Low] | [Notarization needed?] |
| Web (HTML5) | Release | [High/Medium/Low] | [For demos/jams] |
| Android | Release | [High/Medium/Low] | [APK / AAB] |
| iOS | Release | [High/Medium/Low] | [Xcode signing needed] |

---

## Deployment Targets

| Store | Branch/Channel | Auto-Deploy? | Secrets Needed |
|-------|---------------|-------------|----------------|
| Steam (beta) | beta | [Yes/No] (on tags, behind a required reviewer) | `STEAM_USERNAME`, `STEAM_CONFIG_VDF` (base64 of an authorized SteamCMD `config.vdf`); variable `STEAM_APP_ID` |
| Steam (default) | default | No: a human sets it live in Steamworks after testing | None in CI |
| itch.io | html5/windows/linux/mac | [Yes/No] | `BUTLER_API_KEY`; variable `ITCH_TARGET` (`user/game`) |
| Cloudflare Pages (web) | branch preview / production | [Yes/No] | `CLOUDFLARE_API_TOKEN` (scoped to Pages edit on one account), `CLOUDFLARE_ACCOUNT_ID`; project name as a variable |
| Netlify (web) | draft deploy per PR / `--prod` on tags | [Yes/No] | `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID` |
| Epic Games | default | [Yes/No] | BuildPatchTool credentials |
| Google Play | production/internal | [Yes/No] | Service account JSON |
| App Store | TestFlight/production | [Yes/No] | API key, certificates |

---

## Test Automation

| Test Type | Framework | Runs In CI? | Notes |
|-----------|----------|------------|-------|
| Unit Tests | [GUT/gdUnit4 / Unity Test Framework / UE Automation / Vitest] | [Yes/No] | |
| Integration Tests | [Custom] | [Yes/No] | |
| Build Smoke Test | [Launch and exit cleanly / Playwright load-and-play for web builds] | [Yes/No] | |

---

## Versioning Strategy

| Field | Value |
|-------|-------|
| **Scheme** | [Semantic (1.2.3) / CalVer (2026.03.1) / Build number] |
| **Source** | [Git tags / commit count / manual] |
| **Injected into game?** | [Yes — where? / No] |

---

## Pipeline Triggers

| Trigger | Action |
|---------|--------|
| Push to `main` | [Build + Test + Deploy to staging] |
| Push to `release/*` | [Build + Test + Deploy to production] |
| Pull Request | [Build + Test only] |
| Git tag `v*` | [Build + Test + Deploy + Create GitHub Release] |
| Manual dispatch | [Full pipeline with environment selection] |

---

## Secrets Inventory

| Secret Name | Where Stored | Used By |
|-------------|-------------|---------|
| [STEAM_USERNAME], [STEAM_CONFIG_VDF] | GitHub Secrets (protected `steam` environment) | Steam deployment to the beta branch |
| [BUTLER_API_KEY] | GitHub Secrets | itch.io deployment |
| [CLOUDFLARE_API_TOKEN], [CLOUDFLARE_ACCOUNT_ID] | GitHub Secrets | Cloudflare Pages deployment |
| [NETLIFY_AUTH_TOKEN], [NETLIFY_SITE_ID] | GitHub Secrets | Netlify deployment |
| [UNITY_LICENSE] | GitHub Secrets | Unity build activation |
| [GODOT_EXPORT_TEMPLATES] | Cache / download | Godot export |

Deploy tokens are used only in deploy jobs, never in build jobs. Web builds: anything prefixed
`VITE_` is compiled into the client bundle, so no secret ever goes through it; grep `dist/` for key
patterns before deploying.

---

## Estimated Pipeline Duration

| Stage | Estimated Time |
|-------|---------------|
| Checkout + Setup | 1-2 min |
| Build (per platform) | [5-30 min depending on engine] |
| Tests | [1-10 min] |
| Deploy | [2-5 min per target] |
| **Total** | [Estimate] |

---

*Template from [AlterLab GameForge](https://github.com/AlterLab-IEU/AlterLab_GameForge) -- use with `/gameforge:game-ci-pipeline`*
