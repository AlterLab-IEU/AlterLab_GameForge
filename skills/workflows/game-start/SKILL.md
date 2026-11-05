---
name: game-start
description: >
  Sets up a game project for GameForge: detects engine and project state, writes
  .gameforge/project.json and production/session-state/, merges the engine starter CLAUDE.md,
  configures Git and Git LFS per engine, and connects coding agents to the engine (MCP servers,
  llms.txt). Use for "start a new game", "set up my project", "onboard me to this codebase",
  "initialize GameForge". Not for finding an idea (use game-brainstorm) or getting something
  playable tonight (use game-vibe-code).
argument-hint: "[engine: godot|unity|unreal|threejs|web2d] [working title]"
effort: high
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git init *), Bash(git lfs *), Bash(git status *), Bash(git log *), Bash(git rev-parse *), Bash(mkdir *)
---

# AlterLab GameForge -- Project Setup and Onboarding

This is the front door of a GameForge project. In one pass it finds out where the project stands,
wires the plugin into it so the hooks and other skills work, sets up version control the way the
engine needs, connects Claude Code to the engine, and leaves a clear next step. It meets the project
where it lives: an empty folder, a design doc with no code, or an inherited codebase all start here.

Two jobs, in this order:

1. **Wire the project** (always): `.gameforge/project.json`, `production/session-state/active.md`,
   `.gitignore` entries, a merged `CLAUDE.md`, Git and Git LFS, agent setup.
2. **Assess the project** (scaled to what exists): gaps, structure, and the next three actions.

## When NOT to use me

| The user wants... | Route to |
|---|---|
| Something playable tonight, built with an AI agent, minimal setup | `/gameforge:game-vibe-code` (offer the 2-minute wiring below first) |
| A 48-72 hour jam entry | `/gameforge:game-jam-mode` |
| A game idea, not a project | `/gameforge:game-brainstorm` |
| A deep engine choice debate | `/gameforge:game-technical-director` with `${CLAUDE_PLUGIN_ROOT}/docs/engine-comparison.md` |
| Documentation for code that already exists | `/gameforge:game-reverse-document` |
| "Which skill do I need?" | `/gameforge:game-help` |

## Critical Rules

1. **Never overwrite.** Existing `CLAUDE.md`, `.gitignore`, `.gitattributes`, `.claude/settings.json`
   and `.gameforge/project.json` are merged, never replaced. Show what you will add before writing.
2. **Detect before prescribing.** Read the project first. Do not assume an empty project or a tidy one.
3. **Ask only what you cannot detect.** If the engine is detectable, do not ask for it.
4. **Re-runs are updates.** If `.gameforge/project.json` exists, this is a re-run: show the current
   values, change only what the user asks, and re-check the wiring.
5. **Localhost-only agent tooling.** Every MCP server you suggest binds to `127.0.0.1`. Tools that
   execute code (Blender MCP, engine scripting bridges) are arbitrary code execution; say so.
6. **No destructive git.** `git init` and `git lfs` setup only. Offer the first commit; do not make it
   without the user's OK.
7. **Scope honesty.** If the user describes a 200-hour game and three weekends, say so now, kindly,
   and route to `/gameforge:game-scope-check`.

## Step 0: Read the room

Gather silently before saying anything:

| Check | How | Tells you |
|---|---|---|
| GameForge config | Read `.gameforge/project.json` | Re-run vs. first run |
| Godot | Glob `project.godot`; read `config/features` for the version | engine `godot` |
| Unity | Read `ProjectSettings/ProjectVersion.txt` (`m_EditorVersion: 6000.3...` = 6.3) | engine `unity` |
| Unreal | Glob `*.uproject`; read `EngineAssociation` | engine `unreal` |
| Web | Read `package.json` dependencies: `three`, `@react-three/fiber`, `@babylonjs/core`, `playcanvas`, `phaser`, `pixi.js`, `kaplay`, `excalibur` | engine id from the table below |
| Other | `Cargo.toml` with `bevy`, `*.yyp` (GameMaker), `game.project` (Defold), `main.lua` + `conf.lua` (LOVE) | `bevy` or `other` |
| Git | `git rev-parse --is-inside-work-tree`, `git status --short`, `git log --oneline -5` | History, dirty files |
| LFS | Read `.gitattributes`; `git lfs version` | LFS installed / tracked |
| Docs and code | Glob `design/**`, `docs/**`, `src/**`, `scripts/**`, `Source/**`, `Assets/Scripts/**`, `tests/**` | Project state |
| Agent config | Read `CLAUDE.md`, `.claude/settings.json`, `.mcp.json` | What is already wired |
| Focus | Read `production/session-state/active.md` | Where the last session stopped |

Classify the state:

| State | Signals | Assessment depth |
|---|---|---|
| 1. Empty | No engine files, no code, no docs | Setup + concept stub |
| 2. Concept | Design docs, no code | Setup + doc gap analysis |
| 3. In progress | Code and some docs | Setup + structural health check |
| 4. Mature | Code, CI, tests, history | Setup + audit |

## Step 1: Ask the few questions that matter

Use one AskUserQuestion call with at most four questions, each with a recommended default:

1. **Engine** (only if not detected). Offer the two or three that fit what they said, with the
   recommended one first. Defaults: 2D web or jam -> Phaser 4; 3D web -> Three.js; 2D or stylized 3D
   desktop -> Godot 4.7; broad platform reach or mobile -> Unity 6.3 LTS; high-end 3D -> Unreal 5.8.
2. **Working title** (default: the folder name).
3. **Goal**: weekend or jam game / portfolio piece / commercial release. A weekend web game gets the
   2-minute wiring and a hand-off to `/gameforge:game-vibe-code`; a jam goes to
   `/gameforge:game-jam-mode`.
4. **Permissions file**: install the GameForge `.claude/settings.json` starter? (default: yes if none
   exists).

The best engine is the one the team already knows. Switching mid-project costs more than a
suboptimal first choice. For anything beyond these defaults, route to
`/gameforge:game-technical-director`.

### Current engine versions (as of November 2026)

| Engine | Start new projects on | Know before you pick |
|---|---|---|
| Godot | **4.7.2** stable (4.7 released 2026-06-18) | 4.8 is in beta; its .NET build needs .NET 10. Web export uses the Compatibility renderer (WebGL 2) only, and C# projects cannot export to the web in 4.6/4.7. Jolt is the default 3D physics engine since 4.6. |
| Unity | **6.3 LTS** (supported to Dec 2027) | 6.6 is the current Update release. 6.0 LTS left standard support on 2026-10-16. Unity 7.0 alpha is the first CoreCLR editor: not for production. Personal is free under US$200K revenue or funding; the Runtime Fee is gone. In 6.6, Fast Enter Play Mode is on by default, so static fields no longer reset. |
| Unreal | **5.8** (2026-06-17) | The last planned UE5 major; UE6 early access is targeted for late 2027 (Verse, Scene Graph). 5% royalty above US$1M lifetime gross (3.5% under Launch Everywhere). No official browser export. |
| Three.js | **r187** (`three@0.187.0`) | `WebGLRenderer` is the default; `WebGPURenderer` is opt-in with automatic WebGL 2 fallback. ESM-only: pin the exact version. React Three Fiber 9.8 is stable; v10 is alpha. |
| Phaser | **4.2.1** | Phaser 4 is stable (MIT). The Canvas renderer is deprecated. Phaser AE is a separate, commercially licensed product. |
| PixiJS | **8.22** | `await app.init()` is async; WebGL is the default renderer. |
| Web tooling | **Vite 8** | Rolldown is the only bundler; needs Node 20.19+ or 22.12+. |

Record the exact version you detect or install in `engine_version`.

## Step 2: Wire GameForge into the project

Run `mkdir -p .gameforge production/session-state production/session-logs`, then write the files
below. Creating `.gameforge/` and `production/session-state/` opts the project into GameForge's
state hooks (pre-compact snapshot, recovery note, session and agent logs).

### 2a. `.gameforge/project.json`

```json
{
  "name": "Ember Drift",
  "engine": "godot",
  "engine_version": "4.7",
  "phase": "concept",
  "pillars": [],
  "commit_convention": "conventional",
  "lfs_threshold_mb": 20
}
```

| Key | Values | Read by |
|---|---|---|
| `name` | Working title | skills |
| `engine` | `godot`, `unity`, `unreal`, `threejs`, `r3f`, `babylon`, `playcanvas`, `phaser`, `pixi`, `kaplay`, `excalibur`, `bevy`, `other` | skills |
| `engine_version` | Major.minor you detected, e.g. `"4.7"`, `"6.3"`, `"5.8"`, `"r187"` | skills |
| `phase` | `concept`, `pre-production`, `prototype`, `vertical-slice`, `production`, `polish`, `release`, `post-launch` | session briefing, skills |
| `pillars` | 3-5 short phrases; leave `[]` until `/gameforge:game-brainstorm` or `/gameforge:game-creative-director` defines them | creative director, design review |
| `commit_convention` | `conventional` (default), `gameforge`, `off` | commit hook |
| `lfs_threshold_mb` | Integer, default `20` | commit hook (blocks larger non-LFS files) |

Phase defaults by state: Empty -> `concept`; Concept -> `pre-production`; In progress -> `prototype`
or `production` (ask if unclear); Mature -> `production` or later.

### 2b. Session state and `.gitignore`

Write `production/session-state/active.md`; the session-start hook shows its first lines to Claude at
the start of every session and after compaction:

```markdown
# Active focus
**Now:** project setup with /gameforge:game-start (2026-11-05)
**Decisions:** engine Godot 4.7.2 (team knows GDScript); Git LFS for source art and audio
**Next:** /gameforge:game-brainstorm to pick the concept; then /gameforge:game-prototype
**Blocked on:** nothing
```

Append to `.gitignore` (create it if missing; never duplicate lines):

```
production/session-state/
production/session-logs/
```

### 2c. `CLAUDE.md` from the engine starter

| Engine | Starter |
|---|---|
| Godot | `${CLAUDE_PLUGIN_ROOT}/starters/godot/CLAUDE.md` |
| Unity | `${CLAUDE_PLUGIN_ROOT}/starters/unity/CLAUDE.md` |
| Unreal | `${CLAUDE_PLUGIN_ROOT}/starters/unreal/CLAUDE.md` |
| Three.js, R3F, Babylon, PlayCanvas | `${CLAUDE_PLUGIN_ROOT}/starters/threejs/CLAUDE.md` |
| Phaser, PixiJS, Kaplay, Excalibur | `${CLAUDE_PLUGIN_ROOT}/starters/web2d/CLAUDE.md` |
| Other or undecided | `${CLAUDE_PLUGIN_ROOT}/starters/claude-config/CLAUDE.md` |

- **No `CLAUDE.md` yet:** copy the starter (Read it, Write it to `CLAUDE.md`) and fill the bracketed
  placeholders from `project.json`.
- **`CLAUDE.md` exists:** merge. Keep every existing line. Add the starter's missing sections inside
  one delimited block so a re-run can update it in place:

  ```markdown
  <!-- gameforge:start (managed by /gameforge:game-start; edit freely, re-runs update only this block) -->
  ...starter sections the project did not already have...
  <!-- gameforge:end -->
  ```

  Where the user's rules conflict with the starter (commit format, folder layout, naming), keep the
  user's and list the conflict in the report.
- Make sure the first lines of `CLAUDE.md` say how to run and check the game (the build or test
  command). Claude Code's own best-practice guidance is to keep `CLAUDE.md` short and lead with the
  check command; a long `CLAUDE.md` is read less carefully, not more.

### 2d. Optional `.claude/settings.json`

If the user said yes, use `${CLAUDE_PLUGIN_ROOT}/starters/claude-config/settings.json`. It enables the
GameForge marketplace and plugin, allows read-only git and `git lfs track`, asks before push, merge
and rebase, and denies force-push, `reset --hard`, `rm -rf` and reading `.env` or keystores. If a
settings file exists, merge key by key: union the `allow`/`ask`/`deny` arrays, never remove a user
rule, and never move a user's `deny` into `allow`.

## Step 3: Version control and Git LFS

1. **Init.** If not a repository: `git init -b main`.
2. **Ignore.** Merge the engine's `.gitignore` block from
   `${CLAUDE_SKILL_DIR}/references/vcs-setup.md` (read it now; it has per-engine `.gitignore` and
   `.gitattributes` blocks and the engine-specific traps).
3. **LFS.** Check `git lfs version`. If Git LFS is missing, tell the user how to install it (it is a
   system package) and continue; the commit hook will still block non-LFS files at or above
   `lfs_threshold_mb`. If present: `git lfs install --local`, merge the engine's `.gitattributes`
   block, then verify with `git lfs track` (lists patterns).

| Engine | LFS policy in one line |
|---|---|
| Godot | Text scenes and resources (`.tscn`, `.tres`, `.gd`) stay in git; source art, audio, models and fonts go to LFS. Commit `*.import` and `*.uid` files; ignore `.godot/`. |
| Unity | Set Asset Serialization to **Force Text** and keep meta files visible; YAML scenes and prefabs stay in git; textures, audio, models, `.psd` go to LFS. Never ignore `.meta` files. |
| Unreal | `.uasset` and `.umap` are binary: LFS from the first commit, marked `lockable` so teammates can `git lfs lock` them. |
| Web | LFS for source files (`.blend`, `.psd`, `.kra`, masters). Keep shipped runtime assets small and in normal git if you deploy straight from the repository: branch-based GitHub Pages serves LFS pointer files, not the binaries. |

## Step 4: Agent setup

Connect Claude Code to the engine so it can check its own work. Read
`${CLAUDE_SKILL_DIR}/references/agent-setup.md` before this step; it has the install commands, the
check command per engine, and the security notes. Summary:

| Engine | Official integration | Main alternative / docs for agents |
|---|---|---|
| Unity | Unity's Claude Code plugin (`/plugin marketplace add Unity-Technologies/unity-agent-plugin`, then `/plugin install unity@unity-agent-plugin`); needs the Unity CLI. Unity MCP server via `unity mcp configure`. Unity AI open beta since 2026-05-04. | CoplayDev/unity-mcp (MIT); `docs.unity.com/llms.txt` |
| Unreal | Unreal MCP plugin, UE 5.8, **experimental, editor-only, unauthenticated**, on `127.0.0.1:8000` | chongdashu/unreal-mcp (community) |
| Godot | None. No official MCP server or `llms.txt`. | Coding-Solo/godot-mcp (community). Godot's text `.tscn` and `.gd` files are easy for agents to edit directly. |
| Three.js / R3F | No MCP server | `threejs.org/llms.txt`, `threejs.org/docs/llms-full.txt`, `r3f.docs.pmnd.rs/llms.txt` |
| 2D web | No MCP server | `phaser.io/llms.txt` (it steers agents to the commercial Phaser AE; Phaser 4 is the MIT framework) |
| Any web game | Playwright MCP for screenshots and input | `claude mcp add playwright npx @playwright/mcp@latest` |

Rules: show the command and let the user run or approve it; every server stays on localhost; review a
community server's repository before installing it; never put API keys in `CLAUDE.md` or committed
config. The Godot Foundation's 2026 ban on AI-authored code applies to contributions to the engine
itself, not to games made with Godot.

## Step 5: Scaffold and assess

Add the GameForge overlay where it does not exist; keep the engine's own layout untouched:

```
design/            GDD, pillars, concept, balance data
docs/              architecture notes, ADRs
production/        sprints/, milestones/, session-state/ (ignored), session-logs/ (ignored)
prototypes/        throwaway experiments (never promoted to production code)
```

Engine layouts: Godot `scenes/`, `scripts/`, `assets/`, `addons/` beside `project.godot`; Unity
`Assets/Scripts/`, `Assets/Scenes/`, `Assets/Prefabs/`; Unreal `Source/`, `Content/`, `Config/`; web
`src/`, `public/`. See `${CLAUDE_PLUGIN_ROOT}/docs/directory-conventions.md`.

Then scale the assessment to the state from Step 0. Read
`${CLAUDE_SKILL_DIR}/references/project-audit.md` for States 3 and 4; it has the checklists.

| State | Do |
|---|---|
| 1. Empty | Create `design/concept.md` from `${CLAUDE_PLUGIN_ROOT}/templates/game-concept.md` with whatever the user already knows; leave the rest for `/gameforge:game-brainstorm`. Note the engine choice and why in `docs/architecture/0001-engine-choice.md` using `${CLAUDE_PLUGIN_ROOT}/templates/architecture-decision-record.md`. |
| 2. Concept | Read the design docs. Flag missing core loop, pillars, scope estimate, target platform, art and audio direction. Rate each Critical / Important / Nice-to-have. Route to `/gameforge:game-design-review` or `/gameforge:game-gdd-author`. |
| 3. In progress | Structural health: god files, gameplay mixed with engine glue, hardcoded tuning values, no tests, TODO/FIXME count. Rank by what will hurt next month. |
| 4. Mature | Architecture map, doc coverage and freshness, test coverage, build health, dependency age. Produce an effort-vs-impact list. Route to `/gameforge:game-reverse-document` and `/gameforge:game-code-review`. |

For an AI-heavy prototype found in State 3 (one huge file, no tests, generated assets), say so plainly
and recommend `/gameforge:game-code-review` before new features; that is vibe debt, and it compounds.

## Step 6: Report and hand off

Write the report to `production/setup-report.md`, update `active.md` with the next step, and offer
the first commit: `chore: initialize GameForge project` passes the default commit convention.

## Working with AI Coding Agents

Setup is where an agent-built project is won or lost: the agent can only verify what the project
lets it run.

- **Delegate:** scaffolding, `.gitignore`/`.gitattributes` merges, `project.json`, converting an
  existing README into the `CLAUDE.md` block, writing the check command into a script.
- **Verify by hand:** the engine opens the project without import errors; `git lfs ls-files` lists
  a test binary after the first commit; the MCP server answers only on `127.0.0.1`; the check command
  in `CLAUDE.md` actually runs and fails when it should.
- **Give the agent a pass/fail check on day one.** A web game gets `npm run build` plus a Playwright
  screenshot test; Godot gets a headless test runner (GUT or gdUnit4); Unity gets edit-mode tests in
  batch mode; Unreal gets an automation test. Details per engine are in
  `${CLAUDE_SKILL_DIR}/references/agent-setup.md`.
- **Guardrails against vibe debt:** the GameForge hooks already block edits to engine-generated files
  and oversized non-LFS binaries; add the folder layout and "one change per commit" to `CLAUDE.md`, and
  keep `progress.md` (decisions, TODOs) next to `active.md` for long agent runs.
- **Originality:** Claude Code declines to recreate specific existing games (since late October
  2026). If the user's plan is "remake X", set the project up for an original game in X's genre and
  route the concept work to `/gameforge:game-brainstorm`.
- **Assets:** if the team plans AI-generated art, audio or voice, start the provenance log on day
  one with `/gameforge:game-ai-assets`; store disclosures are generated from it later.
- **Fast path:** a user who wants a playable tonight needs only Step 2 (two minutes) and the
  Playwright MCP line, then `/gameforge:game-vibe-code`. Do not run a State 4 audit on a weekend toy.

Prompt that works after setup: "Read CLAUDE.md and production/session-state/active.md, run the check
command, and tell me what is broken before changing anything."

## Output Format

```markdown
# Project Setup Report: [Working title]
**Date:** [YYYY-MM-DD]   **State:** [Empty / Concept / In progress / Mature]
**Engine:** [Godot 4.7.2]   **Phase:** [concept]   **Goal:** [commercial / portfolio / jam / weekend]

## Wiring
| Item | Status | Notes |
|---|---|---|
| .gameforge/project.json | created / updated / unchanged | [values changed] |
| production/session-state/active.md | created | |
| .gitignore (state dirs + engine block) | merged | [lines added] |
| CLAUDE.md | copied / merged (gameforge block) | [conflicts kept as the user's] |
| .claude/settings.json | installed / merged / skipped | |
| Git | initialized / existing ([branch], [N] commits) | |
| Git LFS | tracking [patterns] / not installed | threshold [20] MB |
| Agent setup | [Playwright MCP, godot-mcp, Unity plugin...] | localhost only: [yes] |
| Check command | `[npm run build && npx playwright test]` | ran: [pass/fail/not yet] |

## What exists
- [What is already in good shape]

## Gaps
| Item | Severity | Recommended action |
|---|---|---|
| [No core loop defined] | Critical | /gameforge:game-brainstorm |

## Next three steps
1. [Highest-leverage action, with the skill to run]
2. [...]
3. [...]
```

## Quality Criteria

- The detected state and engine match reality; nothing was assumed that could have been read.
- `.gameforge/project.json` is valid JSON with all seven keys and allowed values.
- `production/session-state/` and `production/session-logs/` are ignored by git.
- No existing file lost a line; every merge is listed in the report.
- Git LFS covers the engine's binary formats, or the report says why not.
- Every suggested MCP server is localhost-only, and code-execution risks are named.
- `CLAUDE.md` leads with a check command that actually runs.
- The user knows exactly what to run next.

## Example Use Cases

1. **"Set up a new Godot project for a 2D roguelike."** Empty state, engine given. Writes the wiring,
   Godot `.gitignore`/LFS blocks, merges the Godot starter, suggests godot-mcp, creates a concept stub,
   points to `${CLAUDE_PLUGIN_ROOT}/genre-packs/roguelike/README.md` and `/gameforge:game-brainstorm`.
2. **"I inherited this Unity project."** Mature state. Detects 6.3 from `ProjectVersion.txt`, checks
   Force Text and meta files, offers Unity's Claude Code plugin, runs the audit, routes to
   `/gameforge:game-reverse-document`.
3. **"I want a little Three.js game this weekend."** Two-minute wiring with `engine: threejs`,
   Playwright MCP, then `/gameforge:game-vibe-code`.
4. **"Re-run setup; we moved to Unreal 5.8."** Re-run: updates `engine` and `engine_version`, adds
   `.uasset`/`.umap` LFS tracking with locking, keeps everything else.
