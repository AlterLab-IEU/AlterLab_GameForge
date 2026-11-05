---
name: game-code-review
description: >
  Reviews game code and AI-agent changes as a forked reviewer and writes a severity-ranked report:
  frame-rate independence, hot-path allocations, state and resource lifecycle, hallucinated engine
  APIs and leaked secrets, for Godot, Unity, Unreal and web. Use for "review my code", "review this
  PR", "check what the agent wrote". Not for design documents (use game-design-review).
argument-hint: "[path, git range like main..HEAD, or blank for uncommitted changes]"
effort: high
context: fork
allowed-tools: Read, Glob, Grep, Write, Bash(git diff *), Bash(git log *), Bash(git show *), Bash(git status *)
---

# AlterLab GameForge -- Game Code Review

Game code fails in ways web code does not. An allocation in a request handler costs latency; the
same allocation in an update loop costs frame drops the player feels in their hands. A state bug in
an app shows stale data; in a game it lets the player walk through walls. And in 2026 a growing
share of the code you are asked to review was written by an agent: plausible, confident, compiles
on the first try, and calls an API that was renamed two engine versions ago.

This review runs two lenses at once:

1. **Game correctness** -- frame independence, hot paths, state machines, resource lifecycle,
   data-driven tuning, input abstraction, concurrency.
2. **AI-change audit** -- outdated and hallucinated APIs, invented packages, duplicated systems,
   dead code, client-trusted state, secrets in shipped bundles, engine-generated files touched by
   MCP tools.

A finding that would ship a bug outranks every style concern. The output is a report, not a patch.

## How this skill runs

This skill runs as a **forked subagent**: no conversation history, no chance to ask questions,
read access to the repository plus `git diff/log/show/status`, and Write only for the report.
Therefore:

- **Never ask.** Resolve ambiguity with the defaults below and list every assumption at the top of
  the report under "Assumptions". The caller can re-run with a narrower target.
- **Never modify code.** Write exactly one file: the report. Return a short summary (verdict, counts
  by severity, top three findings, report path) as the final message.
- **Target** is `$ARGUMENTS`:

| `$ARGUMENTS` looks like | Review scope | How to collect it |
|---|---|---|
| empty | Uncommitted work | `git status --porcelain`, `git diff HEAD`, plus untracked source files |
| a git range (`main..HEAD`, `HEAD~5..HEAD`) | Those commits | `git log --stat <range>`, `git diff <range>` |
| a branch name | Branch vs default branch | `git diff main...<branch>` (fall back to `master`) |
| a file or directory | Whole files, not a diff | Glob + Read; architecture map first |
| contains `full` | Whole project, sampled | Architecture map, then the riskiest systems first |

If the diff is larger than about 3,000 changed lines, review the gameplay-critical and
network/security-relevant files fully and the rest by sampling; say so in Assumptions.

## Step 0: Context and calibration

Gather silently before reading the diff:

1. **Engine and version.** `.gameforge/project.json` (`engine`, `engine_version`, `phase`), else
   `project.godot` (`config/features`), `ProjectSettings/ProjectVersion.txt`, `*.uproject`
   (`EngineAssociation`), or `package.json` dependencies (`three`, `@react-three/fiber`, `phaser`,
   `pixi.js`, `kaplay`, `excalibur`, `babylonjs`, `playcanvas`).
2. **Phase.** `concept`/`prototype`/jam code gets maintainability findings downgraded one level.
   Security, secrets, client trust and data loss are **never** downgraded.
3. **AI provenance.** `git log --format='%h %an %s%n%b' <range>` and look for `Co-Authored-By:`
   trailers naming an AI tool, agent branch names, `progress.md`, or an AI-use log. Treat
   agent-authored changes with the audit in Step 2 in full; human changes get it spot-checked.
4. **Ground truth for API checks.** The installed versions, not your memory:
   `node_modules/<pkg>/package.json` and its `.d.ts` files (web), `Library/PackageCache/<pkg>@<ver>/`
   and `Packages/manifest.json` (Unity), the engine version in `project.godot` (Godot), the
   `.uproject` association and `Build.cs` modules (Unreal). If you cannot confirm an API locally,
   mark the finding **Verify**, never Confirmed.
5. **Standards.** `${CLAUDE_PLUGIN_ROOT}/docs/coding-standards.md` is the house standard (data-driven
   values, frame independence, hot-path discipline, AI-assisted code rules).

## Critical rules

1. **Where code runs sets severity.** An allocation in a pause-menu handler is fine; the same line in
   `_physics_process`, `Update`, `Tick` or a `requestAnimationFrame` loop is a GC hitch.
2. **Evidence or it is a question.** Every finding cites `file:line` and quotes the offending code.
   Performance worries without proof are labelled "profile first".
3. **Engine idioms over abstract purity.** Godot signals are not Unity events are not Unreal
   delegates. Judge code by its engine's conventions and version.
4. **Gameplay numbers live in data.** Damage, speed, cooldowns, spawn rates, drop chances belong in
   resources, ScriptableObjects, DataTables or JSON, not literals.
5. **Plausible is not correct.** Agent-written code that compiles is where hallucinated parameters,
   renamed APIs and duplicated systems hide. Read it as if a stranger wrote it in a hurry.
6. **The client is hostile.** In anything networked or with leaderboards, purchases or rewards, any
   value the client computes and the server accepts is an exploit until proven otherwise.
7. **Report, do not refactor.** Suggest the smallest fix that removes the risk; leave redesigns to
   `game-technical-director`.

## Step 1: Change map

Before judging lines, understand the shape of the change.

```
CHANGE MAP
---------------------------------------------------------------------------
File / system              | Kind            | Runs per frame? | Agent-authored?
---------------------------------------------------------------------------
src/player/controller.ts   | gameplay logic  | yes             | yes (Co-Authored-By)
scenes/level_02.tscn       | scene (MCP edit)| n/a             | likely
package.json               | new dependency  | n/a             | yes
---------------------------------------------------------------------------
Systems touched: [movement, scoring, net sync]
New systems introduced: [list -- check each against existing ones in Step 2]
```

For directory or `full` reviews, also build the architecture map: major systems, where they live,
what they depend on, and whether gameplay is separated from engine/rendering code.

## Step 2: AI-change audit

Run every check on agent-authored changes; spot-check the rest. Patterns, grep recipes and
examples are in `${CLAUDE_SKILL_DIR}/references/ai-change-audit.md` -- read it before this step.

| # | Check | What it catches | Default severity |
|---|---|---|---|
| A1 | **Outdated APIs** | Code written for an older engine or library version: Godot 3 syntax in a 4.x project, `Rigidbody.velocity` in Unity 6, legacy input in UE5, `new THREE.Clock()` on r187, Phaser 3 `setPipeline` on Phaser 4 | MAJOR (CRITICAL if it fails to compile or silently no-ops) |
| A2 | **Hallucinated APIs** | Methods, properties, signals, enum values or parameters that do not exist in the installed version | CRITICAL when on a live code path |
| A3 | **Invented or wrong packages** | New dependencies that are misspelled, unmaintained, the wrong package with a similar name, or unpinned | CRITICAL for unknown publishers; MAJOR otherwise |
| A4 | **Duplicated systems** | A second input handler, save system, event bus, audio manager or state store next to the existing one | MAJOR |
| A5 | **Dead and orphaned code** | Unused functions, files nothing references, commented-out blocks, debug overlays left on, feature flags never read | MINOR (MAJOR if it ships debug or cheat paths) |
| A6 | **Client-trusted state** | Scores, currency, unlocks, hit detection, purchases or cooldowns decided on the client and accepted by a server or leaderboard; game state exposed on `window` | CRITICAL when networked or monetized |
| A7 | **Secrets in shipped code** | API keys in source, `VITE_`-prefixed secrets, LLM keys called from the browser, tokens in exported scenes or config | CRITICAL |
| A8 | **Engine-generated files** | Hand-edited `.godot/`, `*.uid`, Unity `Library/`, regenerated `.meta` GUIDs, Unreal `Intermediate/`, built `dist/` committed | MAJOR |
| A9 | **Silent failure** | Empty `catch`, errors swallowed to "make it work", null checks that hide a missing node, retries without limits | MAJOR |
| A10 | **Test theater** | Tests added with the change that assert nothing, mock the system under test, or were edited to pass | MAJOR |
| A11 | **Scope creep** | Changes outside the stated task: reformatted files, renamed public APIs, project settings flipped | MINOR (MAJOR for project/physics/render settings) |
| A12 | **Originality and licensing** | Ripped assets, decompiled code, verbatim copies of GPL code or of a specific existing game | MAJOR; escalate to the producer |

## Step 3: Game-runtime checks

Apply these to every changed file on a frame or physics path. The full audits, with flag/fix pairs
per engine, are in `${CLAUDE_SKILL_DIR}/references/game-runtime-checks.md`.

| # | Check | Flag | Default severity |
|---|---|---|---|
| G1 | Delta time | `position += speed` without delta; timers counting frames | CRITICAL in gameplay, MINOR cosmetic |
| G2 | Hot-path allocations | `new`, closures, string building, LINQ, array literals, `GetComponent`, `get_node` long paths per frame | CRITICAL in physics/render loops, MAJOR in gameplay |
| G3 | State integrity | Boolean soup (`is_jumping && is_dead` reachable), unguarded transitions, missing exit cleanup | CRITICAL if gameplay-breaking |
| G4 | Fixed-step physics | Forces or movement in variable-rate callbacks; no interpolation; physics in `requestAnimationFrame` without an accumulator | CRITICAL |
| G5 | Resource lifecycle | Signals/listeners not disconnected, pooled objects not returned, `dispose()` missing on web GPU resources, async loads not cancelled on scene change | MAJOR, CRITICAL if it crashes long sessions |
| G6 | Dependency direction | Low-level systems importing gameplay; god objects; singletons reached from everywhere | MAJOR |
| G7 | Data-driven values | Tuning literals in gameplay code | MAJOR player-facing, MINOR internal |
| G8 | Input abstraction | Raw key checks, hardcoded bindings, no remap path | MAJOR for shipping builds |
| G9 | Concurrency | Shared mutable state across threads, workers or network callbacks without ownership | CRITICAL on crash/corruption |
| G10 | Determinism | `Math.random`/`randf` without seeds in replays or lockstep; float math that differs across browsers or platforms | MAJOR when replays or lockstep exist |
| G11 | Magic numbers | Unnamed constants with no rationale | MINOR; MAJOR in aggregate |

## Step 4: Engine checklist

Read the checklist for the detected engine before judging engine-specific code. Each lists the
APIs agents most often get wrong for current versions, idiom violations, and grep patterns.

| Engine | Read |
|---|---|
| Godot 4.x (GDScript, C#) | `${CLAUDE_SKILL_DIR}/references/godot-checklist.md` |
| Unity 6.x | `${CLAUDE_SKILL_DIR}/references/unity-checklist.md` |
| Unreal Engine 5.x | `${CLAUDE_SKILL_DIR}/references/unreal-checklist.md` |
| Web (Three.js, R3F, Phaser, PixiJS, Kaplay, Vite) | `${CLAUDE_SKILL_DIR}/references/web-checklist.md` |

Version anchors as of November 2026: Godot 4.7.2 stable with 4.8 in beta (its .NET build needs .NET
10); Unity 6.3 LTS and 6.6; Unreal Engine 5.8; Three.js r187 (WebGL default, `WebGPURenderer` opt-in);
Phaser 4; PixiJS 8; Vite 8. If the project pins an older version, judge against that version and add
an "upgrade note" finding only when the old version is out of support.

## Step 5: Standard quality

After game and AI checks: naming consistency with engine conventions, file organization, error
handling, documentation of public APIs and non-obvious math, test coverage of gameplay rules,
duplication. Keep this section short; it rarely holds the findings that matter.

## Step 6: Rank and write the report

### Severity and confidence

| Severity | Meaning | Merge guidance |
|---|---|---|
| **CRITICAL** | Ships a bug players hit, a crash, an exploit, data loss, or a leaked secret | Block merge |
| **MAJOR** | Wrong under realistic conditions, or debt that compounds every sprint | Fix this sprint |
| **MINOR** | Real but low impact | Batch into cleanup |
| **NIT** | Preference or polish | Optional |

| Confidence | Meaning |
|---|---|
| **Confirmed** | Seen in the code and checked against local ground truth (installed package, engine version) |
| **Likely** | Strong pattern match; not executed or profiled |
| **Verify** | Needs a run, a profile, or a doc lookup for the pinned version; say exactly what to check |

Sort findings by severity, then confidence. Merge duplicates (one finding, many locations). Cap NITs
at five. Verdict: **Block** (any CRITICAL), **Fix then merge** (MAJORs only), **Merge** (MINOR/NIT).

### Output

Write the report to `production/reviews/code-review-YYYY-MM-DD-<slug>.md` (create the folder; never
overwrite an existing report, add `-2`). Use this structure:

```markdown
# Code Review: [target, e.g. "main..feature/dash" or "src/combat/"]
**Project:** Ember Drift | **Engine:** Godot 4.7.2 (GDScript) | **Phase:** prototype
**Reviewed:** 2026-11-05 | **Files:** 14 changed (+612 / -88) | **Agent-authored:** 11 of 14
**Verdict:** Block -- 2 CRITICAL, 3 MAJOR, 4 MINOR, 2 NIT

## Assumptions
- No argument given; reviewed uncommitted changes against HEAD.
- `.gameforge/project.json` missing; engine version read from `project.godot` features ("4.7").
- Multiplayer code present (`net/`), so client-trust checks applied at full severity.

## Findings

### CRITICAL
**CR-01 Score accepted from client** -- `net/leaderboard.gd:42` -- A6 -- Confirmed
> `rpc_id(1, "submit_score", score)` ... server stores `score` unchanged.
Why it matters: any player can post an arbitrary score; the board is meaningless on day one.
Fix: server derives score from validated events (kills, time) or re-simulates the run seed.

**CR-02 `move_and_slide(velocity, Vector2.UP)`** -- `player/player.gd:88` -- A1 -- Confirmed
> Godot 3 signature in a 4.7 project; parse error in 4.x.
Fix: set `velocity` and `up_direction` as properties, then call `move_and_slide()`.

### MAJOR
**CR-03 Second input layer** -- `systems/input_router.gd` (new) -- A4 -- Likely
> Duplicates the InputMap actions already read in `player/player.gd:12-30`.
Fix: delete the router or migrate all reads to it; one source of truth for bindings.

### MINOR / NIT
- CR-06 Dash tuning literals -- `player/dash.gd:7,9,15` -- G7 -- move to `dash_tuning.tres`.

## AI-change audit summary
| Check | Result | Findings |
|---|---|---|
| A1 Outdated APIs | 1 found | CR-02 |
| A2 Hallucinated APIs | none found | -- |
| A3 Packages | n/a (no new deps) | -- |
| A6 Client trust | 1 found | CR-01 |
| A7 Secrets | none found (scanned src/, export_presets.cfg) | -- |

## Verify by hand (commands for the human or main session)
- `godot --headless --check-only --script res://player/player.gd` (parse check)
- Profile `enemy_spawner.gd` at 200 enemies; CR-07 is "profile first".

## What is good
- Clean state machine in `player/states/` with explicit enter/exit.

## Next actions (effort-to-impact order)
1. CR-01 server-side scoring (half a day) -- blocks any public build.
2. CR-02 Godot 4 movement API (10 minutes).
3. CR-03 remove duplicate input router (1 hour).
```

Finish by returning: verdict, counts, the three highest findings with IDs, and the report path.

## Working with AI Coding Agents

This review is built to sit inside an agent loop, not after it.

- **Review per change, not per milestone.** Run `/gameforge:game-code-review main..HEAD` at the end
  of each agent feature branch or session. Agent debt accumulates silently; a 300-line review
  catches what a 9,000-line review skims past.
- **Feed findings back as tasks, one per prompt.** Paste a single finding ID with its fix into the
  next agent turn ("Fix CR-02 only; do not touch other files"). Batch prompts invite scope creep.
- **Make the agent prove fixes.** Ask for the check command output (parse check, unit test, build
  exit code, Playwright screenshot) with each fix, then re-run this review on the fix commit.
- **Verify by hand, always:** anything touching networking, purchases, saves, secrets, physics
  settings, or project/export settings; every new dependency; every file an MCP tool edited inside
  the editor (scene files, prefabs, `.uasset`s) because those changes are hard to diff.
- **Never delegate the verdict.** The reviewer flags; a human decides to merge.
- **MCP edits are code changes.** Unity's official MCP server (Unity AI open beta), Unreal 5.8's
  experimental editor-only MCP plugin and community servers such as Coding-Solo/godot-mcp can change
  scenes and settings directly. Review the resulting diff like any other commit, and keep those
  servers bound to localhost.
- **Upstream contributions are different.** Since 2026-06-30 the Godot Foundation rejects
  substantially AI-authored contributions to the engine itself. This applies to engine PRs, not to
  games made with Godot; flag it only when the diff targets `godotengine/godot`.
- For the build-with-agents loop itself (spec, check command, small diffs) use
  `/gameforge:game-vibe-code`; for provenance of AI-generated art and audio use
  `/gameforge:game-ai-assets`.

Guardrails to recommend when the audit finds repeated agent debt: a short project `CLAUDE.md` that
leads with the check command, a pinned engine version in `.gameforge/project.json`, a ban on new
dependencies without approval, and this review wired into CI (`/gameforge:game-ci-pipeline` has
an optional AI-review job).

## Quality bar

A finished review:
- cites `file:line` and quotes code for every finding;
- ranks by player impact, not by theoretical purity;
- checks APIs against the installed version, and marks anything unconfirmed as Verify;
- states every assumption made instead of asking;
- separates prototype shortcuts from production debt using the project phase;
- labels performance concerns "profile first" unless measured;
- names at least one thing the code does well;
- ends with a short, ordered action list.

## When NOT to use me

| Need | Use instead |
|---|---|
| Review a design document or GDD | `game-design-review` |
| Architecture decisions, tech stack, performance budgets | `game-technical-director` |
| Test strategy, bug triage, regression plans | `game-qa-lead` |
| Document an undocumented codebase | `game-reverse-document` |
| Wire reviews, tests and builds into CI | `game-ci-pipeline` |
| Netcode architecture and authority model | `game-multiplayer` |
| Engine-specific implementation help | `game-godot-specialist`, `game-unity-specialist`, `game-unreal-specialist`, `game-threejs-specialist`, `game-web2d-specialist` |

## Example requests

1. **"Review what Claude wrote today."** Empty argument: uncommitted diff, full AI-change audit,
   engine checklist, runtime checks on frame-path files.
2. **"Review `main..feature/online-scores`."** Range review with A6 (client trust) and A7 (secrets)
   at full weight; expect a server-authority finding if scores are submitted raw.
3. **"We get frame drops in combat -- review `src/combat/`."** Directory review weighted to G2, G5
   and G4; every performance finding paired with a profiling step.
4. **"Is the prototype ready to become production code?"** `full` review in production calibration:
   data-driven values, dependency direction, duplicated systems, test coverage.
5. **"The game behaves differently on my teammate's machine."** G1, G4 and G10 first: delta time,
   fixed-step physics, determinism and platform-dependent math.
