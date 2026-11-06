# Changelog

All notable changes to AlterLab GameForge. Versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- **Hooks on non-UTF-8 Windows.** The `python3` JSON parser in `hooks/lib/common.sh` now reads and
  writes UTF-8 bytes. Python before 3.15 decodes pipes with the Windows ANSI code page, so on a
  Turkish (cp1254) system a path or commit message containing `Ş` or `Ğ` made the parser print
  nothing, and `protect-generated` and `validate-commit` silently allowed the edit or commit.
- **Validator on Windows.** `scripts/validate.py` reads every file as UTF-8 instead of the locale
  encoding, so it no longer needs `PYTHONUTF8=1` on Windows. CI enforces this with `EncodingWarning`.
- **Line endings.** A new `.gitattributes` keeps `*.sh` LF on checkouts with `core.autocrlf=true`, so
  the hooks parse under `dash`.
- **Hook test suite on Windows.** The parser-isolation PATH uses small exec scripts instead of
  symlinks, which Git for Windows copies, leaving `sh.exe` and `git.exe` without their DLLs. Test
  events reach `python3` on stdin, because MSYS rewrites `/tmp/...` arguments for native programs.
  The suite now runs every case under the `jq`, `python3` and `sed` parsers (183 tests), and CI runs
  the suite and the validator on Windows.

## [3.0.0] - 2026-11

A rebuild. GameForge now installs as a spec-compliant Claude Code plugin, every skill was rewritten
against a shared specification and current (November 2026) research, and building games with AI
coding agents and shipping them on the web are first-class paths.

### Breaking

- **Install path.** GameForge is the `gameforge` plugin in the `alterlab-gameforge` marketplace:
  `/plugin install gameforge --marketplace AlterLab-IEU/AlterLab_GameForge`. The previous instruction,
  `claude install github:AlterLab-IEU/AlterLab_GameForge`, reinstalled the Claude Code CLI and never
  installed GameForge.
- **Skill invocation.** Plugin skills are namespaced: `/gameforge:game-start` instead of `/game-start`.
- **Root `marketplace.json` removed.** Claude Code reads `.claude-plugin/marketplace.json` and
  `.claude-plugin/plugin.json`; the old root file used a schema it never loaded.
- **Hooks consolidated from 11 to 7.** `config-change`, `instructions-validate`, `log-agent`,
  `detect-gaps`, `post-compact` and `session-stop` were removed; their useful behaviour moved into
  `session-start` (gaps, post-compaction restore) and `session-end`.
- **`CLAUDE.md` moved to `.claude/CLAUDE.md`** as a maintainer guide. Claude Code does not load a
  plugin's root CLAUDE.md, so user-facing routing now lives in the `game-help` skill.

### Added

- **Skills (7):** `game-vibe-code` (disciplined AI-agent build loop), `game-ai-assets` (AI art, audio
  and voice pipeline with provenance and disclosure), `game-web-publish` (itch.io, web portals,
  Discord Activities, YouTube Playables, PWA, desktop wrappers), `game-multiplayer` (netcode
  architecture across engines and the web), `game-help` (start-here router),
  `game-threejs-specialist` (Three.js r187, React Three Fiber, WebGPU/TSL) and
  `game-web2d-specialist` (Phaser 4, PixiJS 8, Kaplay, Excalibur).
- **Studio subagents (11)** in `agents/`, one per studio role, with project-scoped memory and a fixed
  report format. `game-team-orchestrator` delegates to them in parallel.
- **Hooks:** `protect-generated` (blocks edits to engine-generated files such as `.godot/`, Unity
  `Library/`, Unreal `Intermediate/` and `.uasset`; asks before `.meta`), a Git LFS large-binary
  guard in `validate-commit`, and `session-end`.
- **Docs:** `docs/vibe-coding.md` (building games with AI agents, with sources) and `docs/hooks.md`.
- **Template:** `templates/ai-asset-log.md`, the provenance log that disclosures are drafted from.
- **Starters:** `starters/threejs/` and `starters/web2d/`; `starters/claude-config/settings.json`
  now declares the GameForge marketplace so teammates are prompted to install it.
- **Tests and CI:** `tests/hooks.test.sh` (119 cases, every engine fixture, with and without `jq`) on
  Linux and macOS; `claude plugin validate --strict`; a plugin icon.
- **`.gameforge/project.json`:** per-project config (engine, phase, pillars, commit convention, LFS
  threshold) created by `game-start` and read by hooks and skills.

### Changed

- **Every existing skill upgraded** against one specification: late-2026 engine versions and tools,
  a "Working with AI Coding Agents" section per role, an integrity pass that removed anecdotes about
  named games that are not public record, persona memory claims replaced with file-based continuity,
  and long material moved into on-demand `references/` files (`SKILL.md` capped at 500 lines).
- **Leaner context, measured with `claude plugin details`:** a skill now costs 8.3k tokens on
  average when invoked (largest 9.8k), down from 10.8k (largest 16.6k), while carrying far more
  material in on-demand `references/`. Descriptions were tightened to at most 400 characters, so 41
  skills plus 11 subagents add about 7.1k tokens to a session, versus 5.8k for v2's 34 skills.
- **Tool pre-approval hardened:** no skill pre-approves unscoped `Bash` or interpreter wildcards such
  as `Bash(python3 *)`; the validator rejects both.
- **Frontmatter:** removed fields Claude Code ignores (`version`, `memory`) and the forced
  `model: opus`, so skills follow the user's model choice. `context: fork` is kept only for
  report-style skills (`game-code-review`, `game-reverse-document`, `game-market-research`), because
  forked skills run as subagents that cannot ask the user questions. `allowed-tools` no longer
  pre-approves unscoped `Bash`.
- **References:** about 180 `@docs/` and `@templates/` imports, which only resolve inside a CLAUDE.md,
  were rewritten to `${CLAUDE_PLUGIN_ROOT}/...` in skills and relative links in docs.
- **Docs:** workflow guide maps all 41 skills and 21 templates; engine comparison, MCP integrations
  and AI-native gamedev rewritten from sourced late-2026 research; agent hierarchy covers all roles
  and subagents; FAQ, directory conventions, quality rubric and genre-pack spec updated.
- **Validator:** `scripts/validate.sh` (486 line-count and presence checks) replaced by
  `scripts/validate.py`, which checks manifests, documented fields, fork rules, tool scoping, size
  caps, path and cross-skill references, doc links and counts quoted in docs.

### Fixed

- Engine detection reported every non-Godot project as Unity (an `ls | head` pipeline always
  succeeded).
- The subagent tracker crashed with an arithmetic error on its first run (`grep -c || echo 0`
  produced two lines).
- The commit hook, documented as enforcing the commit convention, never read the commit message,
  never blocked, and scanned every JSON file in the project on every tool call.
- `log-agent` read `$1`, but hooks receive JSON on stdin, so it logged empty agent names.
- Post-compaction context was sent as `systemMessage`, which only the user sees.
- Session logging ran on `Stop`, which fires after every turn, not at session end.
- The stop-failure recovery file could be invalid JSON when a commit subject contained quotes.
- Starter `settings.json` permission rules that could never match (`Bash(rm -r /)*`,
  `Bash(curl*|*sh)`).
- Stale counts across README, CLAUDE.md, FAQ and the workflow guide (31 vs 34 skills, 11 vs actual
  hooks, missing templates).

## [2.0.0]

Three workflow skills (`game-jam-mode`, `game-ci-pipeline`, `game-gdd-author`), deeper engine
specialists, roguelike and narrative genre packs, a CI validation script, the skill quality rubric
and the AI-native gamedev guide.

## [1.4.0]

Engine starters, documentation overhaul, community files.

## [1.3.0]

MCP integration guide, advanced workflows, trigger tuning.

## [1.2.0]

Voice consistency pass, persona rewrites, deeper skills.

## [1.1.0]

Research-driven upgrade: 25 skills, 14 templates, 6 shared docs.

## [1.0.0]

Initial release: 22 game development skills for Claude Code.
