# CI/CD Pipeline Configuration

> Planning template for setting up automated builds and deployment. Fill this in before writing your pipeline YAML.

---

## Project Details

| Field | Value |
|-------|-------|
| **Game Name** | [Your game name] |
| **Engine** | [Godot 4.x / Unity 6.x / Unreal 5.x] |
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
| Steam | default | [Yes/No] | `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_TOTP_SECRET` |
| Steam (beta) | beta | [Yes/No] | Same as above |
| itch.io | html5/windows/mac/linux | [Yes/No] | `BUTLER_API_KEY` |
| Epic Games | default | [Yes/No] | BuildPatchTool credentials |
| Google Play | production/internal | [Yes/No] | Service account JSON |
| App Store | TestFlight/production | [Yes/No] | API key, certificates |

---

## Test Automation

| Test Type | Framework | Runs In CI? | Notes |
|-----------|----------|------------|-------|
| Unit Tests | [GUT/gdUnit4 / Unity Test Framework / UE Automation] | [Yes/No] | |
| Integration Tests | [Custom] | [Yes/No] | |
| Build Smoke Test | [Launch and exit cleanly] | [Yes/No] | |

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
| [STEAM_USERNAME] | GitHub Secrets | Steam deployment |
| [BUTLER_API_KEY] | GitHub Secrets | itch.io deployment |
| [UNITY_LICENSE] | GitHub Secrets | Unity build activation |
| [GODOT_EXPORT_TEMPLATES] | Cache / download | Godot export |

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

*Template from [AlterLab GameForge](https://github.com/AlterLab-IEU/AlterLab_GameForge) -- use with `/game-ci-pipeline`*
