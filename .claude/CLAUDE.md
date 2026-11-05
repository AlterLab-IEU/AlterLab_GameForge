# AlterLab GameForge -- Maintainer Guide

This file is for people (and Claude sessions) working **on** GameForge. Plugin users never see it:
Claude Code does not load a plugin's CLAUDE.md, so anything users need lives in a skill
(`skills/workflows/game-help/` is the user-facing start page).

## What this repository is

A Claude Code plugin named `gameforge`, published through the `alterlab-gameforge` marketplace in
this same repository.

```
.claude-plugin/
  plugin.json          plugin manifest; lists the three skill category folders
  marketplace.json     marketplace manifest; one plugin, source "./"
  icon.png             1024 px listing icon (source: .github/icon.svg)
skills/
  agents/              11 studio-role skills (Tier 1-2 of docs/agent-hierarchy.md)
  workflows/           25 process skills with defined outputs
  engine-specialists/  5 engine skills (Godot, Unity, Unreal, Three.js, 2D web)
agents/                11 plugin subagents; each loads its role from skills/agents/<name>/SKILL.md
hooks/                 hooks.json + 7 POSIX sh hooks + lib/common.sh
docs/                  shared knowledge base cited by skills
templates/             document templates skills fill in
genre-packs/           genre reference material (roguelike, narrative)
starters/              files users copy into their game project (CLAUDE.md per engine, settings.json)
scripts/validate.py    repository validator
tests/hooks.test.sh    hook test suite
```

Install from a local checkout while developing:

```bash
claude --plugin-dir .
```

## Rules that keep the plugin working

**Paths.** Inside `SKILL.md` and `agents/*.md`, refer to bundled files as
`${CLAUDE_PLUGIN_ROOT}/docs/...`, `${CLAUDE_PLUGIN_ROOT}/templates/...`, and to a skill's own files as
`${CLAUDE_SKILL_DIR}/references/...`. Claude Code substitutes these only in skill and agent bodies, so
everywhere else (docs, templates, genre packs, README) use ordinary relative links. Never use
`@docs/...`: that import syntax only works in a CLAUDE.md. Starters are copied into users' projects,
so they refer to skills as `/gameforge:<skill>` and never link to repository files.

**Skill frontmatter.** Only documented fields: `name` (equals the directory), `description`
(third person, triggers plus a "Not for" boundary, at most 400 characters), `argument-hint`,
`allowed-tools`, `effort`, and where needed `context`, `disable-model-invocation`. Do not add
`version`, `model` or `memory`. `allowed-tools` pre-approves tools, so never list bare `Bash`;
scope it (`Bash(git diff *)`). `context: fork` runs the skill as a background subagent without the
conversation and without `AskUserQuestion`; it is reserved for report generators
(`game-code-review`, `game-reverse-document`, `game-market-research`).

**Size.** `SKILL.md` is at least 200 lines for agents and engine specialists, 150 for workflows, and
at most 500 (hard cap 550). Long code, catalogs and per-engine variants go in `references/*.md`, each
linked from `SKILL.md` with an instruction saying when to read it.

**Subagents.** `agents/*.md` may use `memory`, `effort`, `model: inherit`, `tools`, `color`; plugin
subagents ignore `hooks`, `mcpServers` and `permissionMode`, so do not use them.

**Hooks.** POSIX `sh` only (they must parse under `dash`), no required `jq`, silent outside game
projects, no file writes before the project opts in, documented output channels only
(`SessionStart` stdout, `PreToolUse` permission decisions). Every behaviour change needs a case in
`tests/hooks.test.sh`. User-facing reference: `docs/hooks.md`.

**Content integrity.** Version numbers, policies and dates must come from a source and be dated
("as of Unity 6.3 LTS"). Claims about named games or studios must be public record and attributed.
Statistics are sourced or labelled as rules of thumb. Code must be correct for the versions named.
GameForge steers users toward original games; no skill should help recreate a specific existing game.

## Checks

```bash
python3 scripts/validate.py          # frontmatter, sizes, references, links, counts, manifests
bash tests/hooks.test.sh -v          # hooks under POSIX sh, jq and fallback parsers
claude plugin validate . --strict    # Claude Code's own manifest and component validation
claude plugin details gameforge      # token cost per skill (after installing locally)
```

CI runs all three on every pull request (`.github/workflows/validate-skills.yml`).

## Releases

1. Bump the version in `.claude-plugin/plugin.json`, the plugin entry in
   `.claude-plugin/marketplace.json`, and `package.json` (the validator checks they agree).
2. Add a `## [x.y.z]` section to `CHANGELOG.md`.
3. Update counts in README and docs if skills, templates or hooks changed (the validator flags stale
   counts).

## Commit convention

| Prefix | Use |
|---|---|
| `feat:` | New skill, hook, template, or documentation |
| `improve:` | Enhancement to an existing skill or workflow |
| `fix:` | Bug fix, broken reference, or typo correction |
| `docs:` | README, CONTRIBUTING, or docs-only changes |
| `chore:` | Scripts, CI, config, or repo maintenance |

## Where things are decided

- Skill routing for users: `skills/workflows/game-help/SKILL.md`
- Lifecycle mapping: `docs/workflow-guide.md`
- Role authority and escalation: `docs/agent-hierarchy.md`, `docs/coordination-rules.md`
- Quality bar: `docs/skill-quality-rubric.md` (automated gate plus five scored dimensions)
- Building games with AI agents: `docs/vibe-coding.md`
