# Pipeline Hardening: Caching, LFS, Retention, Secrets, AI Review

Read this before finalizing any pipeline. Facts about GitHub Actions limits come from GitHub's
docs and the action manifests as of November 2026.

## Current action majors (verified November 2026)

| Action | Major | Latest tag seen | Notes |
|---|---|---|---|
| `actions/checkout` | v7 | v7.0.1 (2026-07-17) | v7 refuses to check out fork PR code under `pull_request_target`/`workflow_run` unless `allow-unsafe-pr-checkout: true` |
| `actions/cache` | v6 | v6.1.0 (2026-06-23) | Node 24 runtime since v5: self-hosted runners need runner 2.327.1+ |
| `actions/upload-artifact` | v7 | v7.0.2 (2026-10-07) | `retention-days` 1-90 |
| `actions/download-artifact` | v8 | v8.0.2 (2026-10-07) | |
| `actions/setup-node` | v7 | v7.1.0 (2026-10-07) | v6+ auto-caches npm when `packageManager` is npm |
| `actions/setup-dotnet` | v6 | v6.1.0 (2026-11-02) | Use for Godot .NET (10.0.x on 4.8) |
| `game-ci/unity-test-runner` | v4 | v4.4.0 (2026-08-29) | v5 is in beta |
| `game-ci/unity-builder` | v4 (docs-current) | v4.8.2; v6.0.0 (2026-08-29) | v6 runs via `game-ci/cli`; pin `cliVersion` |
| `game-ci/steam-deploy` | v3 | v3.2.2 (2026-10-25) | Pin `cliVersion` |
| `chickensoft-games/setup-godot` | v2 | v2.4.3 (2026-10-01) | Betas and .NET builds |
| `MikeSchulze/gdUnit4-action` | v1 | v1.4.1 | gdUnit4 tests |
| `cloudflare/wrangler-action` | v4 | v4.1.3 (2026-09-24) | Defaults to Wrangler v4 |
| `anthropics/claude-code-action` | v1 | v1.0.268 (2026-11-04) | Optional AI review |

These drift. Before committing a workflow, check each action's releases page (or run
`git ls-remote --tags https://github.com/<owner>/<repo>`) and update the table you hand the user.

## Pinning

- Minimum: pin to a major tag (`@v7`) for first-party `actions/*`.
- Better for third-party actions that receive secrets (deploy, licensing): pin to a full commit SHA
  with a comment naming the version, and let Dependabot or Renovate propose updates:

```yaml
- uses: game-ci/steam-deploy@<full-40-char-sha>   # v3.2.2
```

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule: { interval: weekly }
```

- Docker images: exact tags (`barichello/godot-ci:4.7.2`), never `latest`.
- Tools downloaded in steps (`butler`, `wrangler`, `netlify-cli`): the butler broth URL always
  serves latest stable, so log `butler -V`; pin Wrangler with `wranglerVersion` and npm CLIs with
  `@major`.

## Caching recipes

GitHub caches are scoped per branch (PRs can read the base branch's cache), evicted after 7 days
without access, and capped at 10 GB per repository by default (raisable, billed beyond the
default). Caches are per-OS. Cache what is slow to rebuild and stable between commits.

| Engine | Cache | Key |
|---|---|---|
| Unity | `Library/` per target platform | `Library-<platform>-${{ hashFiles('Assets/**','Packages/**','ProjectSettings/**') }}` |
| Godot | `~/.nuget/packages` (C#); setup-godot's own cache | `nuget-${{ hashFiles('**/*.csproj') }}` |
| Unreal | DDC and `Intermediate/` on the persistent self-hosted runner disk, not the Actions cache | n/a |
| Web | npm cache via `setup-node` (`cache: npm`); Playwright browsers optional | lockfile hash |
| All | Git LFS objects (`.git/lfs`) | hash of `git lfs ls-files -l` |

### Git LFS cache

```yaml
- uses: actions/checkout@v7          # lfs: false here; we pull after restoring the cache
- name: LFS object list
  run: git lfs ls-files -l | cut -d' ' -f1 | sort > .lfs-assets-id
- uses: actions/cache@v6
  with:
    path: .git/lfs
    key: lfs-${{ hashFiles('.lfs-assets-id') }}
    restore-keys: lfs-
- run: git lfs pull
```

LFS bandwidth and storage are metered on GitHub; this recipe downloads each object once per cache
lifetime instead of once per job. Keep `.gitattributes` patterns in step with the project's
`lfs_threshold_mb` (GameForge's commit hook blocks non-LFS binaries above it).

## Artifacts and retention

| Build | Retention | Where |
|---|---|---|
| PR builds | 3-7 days | Actions artifacts |
| `main` builds | 7-14 days | Actions artifacts |
| Release tags | Permanent | GitHub Releases, Steam/itch builds |
| Test reports, Playwright traces | 7-14 days, uploaded `if: always()` | Actions artifacts |

Artifacts default to 90 days, which quietly eats storage quota for large game builds; always set
`retention-days`. Use `if-no-files-found: error` so an empty export fails loudly.

## Secrets

| Rule | How |
|---|---|
| Store secrets in GitHub Secrets; non-secret IDs in Variables (`vars.*`) | App IDs, itch user/game, project names are variables |
| Deploy credentials live in **Environments** with required reviewers | `environment: steam` on deploy jobs |
| Fork PRs never see secrets | Default for `pull_request`; never use `pull_request_target` to build fork code (checkout v7 now refuses by default) |
| Least privilege `GITHUB_TOKEN` | Top-level `permissions: contents: read`; widen per job (`checks: write`, `pull-requests: write`, `contents: write` only for releases) |
| Never echo secrets | No `set -x` in steps that use them; GitHub masks known values, not derived ones (base64-decoded files) |
| Files from secrets | Decode keystores/`config.vdf` to `$RUNNER_TEMP`, delete in an `if: always()` step |
| Rotate on exposure | A leaked butler key, Steam config or Cloudflare token is rotated first, investigated second |
| Scan the repo | Enable GitHub secret scanning and push protection where available, or run a scanner such as gitleaks in CI |
| Web bundles | No secret in `VITE_` variables or `define`; grep `dist/` before deploy (see `web-ci.md`) |

Per-target secrets:

| Target | Secrets | Variables |
|---|---|---|
| Unity (GameCI) | `UNITY_LICENSE` or `UNITY_SERIAL`, `UNITY_EMAIL`, `UNITY_PASSWORD` | -- |
| Steam | `STEAM_USERNAME`, `STEAM_CONFIG_VDF` | `STEAM_APP_ID` |
| itch.io | `BUTLER_API_KEY` | `ITCH_USER`, `ITCH_GAME` or `ITCH_TARGET` |
| Cloudflare | `CLOUDFLARE_API_TOKEN` (scoped), `CLOUDFLARE_ACCOUNT_ID` | project name |
| Netlify | `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID` | -- |
| Godot Android | keystore (base64), `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `..._PASSWORD` | -- |
| AI review | `ANTHROPIC_API_KEY` (or OAuth token / cloud provider auth) | -- |

## Workflow hygiene

- `concurrency` with `cancel-in-progress: true` for PR and `main` builds; `false` for deploys and
  Unreal cooks on persistent runners.
- `timeout-minutes` on every job (engine builds can hang on license or import dialogs).
- Fail fast: lint and tests gate builds; builds gate deploys (`needs:`).
- `fail-fast: false` on platform matrices so one platform's failure does not hide another's.
- Validate YAML before pushing: `actionlint` if installed, then a push to a throwaway branch.

## Optional: AI review job

An AI reviewer comments on PRs; it never approves, merges or deploys. Run it only on PRs from the
same repository (secrets), keep its tools read-only plus commenting, and treat its comments as a
second reader, not a gate.

```yaml
name: ai-review
on:
  pull_request:
    types: [opened, synchronize]
permissions:
  contents: read
  pull-requests: write
  id-token: write
jobs:
  review:
    if: github.event.pull_request.head.repo.full_name == github.repository
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v7
        with: { fetch-depth: 0 }
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # Optional: install GameForge so the job can use its game-specific review
          plugin_marketplaces: https://github.com/AlterLab-IEU/AlterLab_GameForge.git
          plugins: gameforge@alterlab-gameforge
          prompt: |
            REPO: ${{ github.repository }}  PR: ${{ github.event.pull_request.number }}
            Review this PR as a game code reviewer. Use /gameforge:game-code-review on
            origin/${{ github.base_ref }}...HEAD if available. Post one summary comment with
            CRITICAL and MAJOR findings only (file:line, why, fix). Do not push commits.
          claude_args: |
            --allowedTools "Read,Glob,Grep,Write,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(gh pr comment:*),Bash(gh pr diff:*)"
```

Check the action README for your pinned version before relying on the `plugins` inputs; the
documented minimal form is `anthropic_api_key` + `prompt` + `claude_args`. Budget API cost per PR,
and skip the job on draft PRs or docs-only changes with `paths-ignore`.

What does **not** belong in CI: engine MCP servers. Unreal 5.8's MCP plugin is editor-only,
loopback-only and unauthenticated; Unity's official MCP server and community Godot servers drive a
local editor for a developer's agent session. CI drives engines through their command lines.
