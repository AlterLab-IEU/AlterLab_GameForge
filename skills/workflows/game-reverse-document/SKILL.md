---
name: game-reverse-document
description: >
  Generates docs from an existing game codebase as a forked report writer: reverse-engineered GDD,
  architecture overview with ADR drafts, concept document, or a one-page brief for new teammates and
  coding agents (Godot, Unity, Unreal, web). Use for "document this codebase", "generate docs from
  code", "onboard me to this codebase". Not for new designs (use game-gdd-author).
argument-hint: "[design|architecture|concept|brief] [path, default project root]"
effort: high
context: fork
allowed-tools: Read, Glob, Grep, Write, Bash(git log *), Bash(git diff *), Bash(git show *), Bash(git status *)
---

# AlterLab GameForge -- Reverse Documentation

Most games start with passion, not paperwork. A prototype works, then grows, and weeks later nobody,
including its author, can explain its architecture without reading every file. In 2026 add a new
twist: much of that code was written by coding agents across dozens of sessions, each of which knew
only what its prompt told it. The design lives in the code and in commit messages, nowhere else.

This workflow reads the code and writes the documents that should have existed: a design document
in the language of game design, an architecture overview in the language of systems, a concept
document that captures what the prototype is really about, or a one-page brief that lets a new
teammate (human or agent) work safely on day one. It is not an API-doc generator.

Reverse documentation serves three needs: **onboarding** (hours of reading instead of weeks of
archaeology), **preservation** (decisions captured before anyone forgets why), and **diagnosis**
(systems that disagree become visible when documented side by side).

## How this skill runs

This skill runs as a **forked subagent**: no conversation history, no questions to the user,
read access to the repository plus `git log/diff/show/status`, and permission to write new
documentation files. Therefore:

- **Never ask.** Choose the mode and scope with the rules below and list every assumption at the top
  of the document under "Assumptions and limits".
- **Never edit code or existing documents.** Write new files only. If the target file exists, write
  a dated sibling (`...-2026-11-05.md`) and note it.
- **Finish with a summary message:** mode, files written, systems documented, the three most
  important inconsistencies or gaps, and the count of UNVERIFIED items the team should confirm.

### Resolving `$ARGUMENTS`

| First word | Mode | Output file |
|---|---|---|
| `design` | Reverse-engineered GDD | `design/gdd-reverse-YYYY-MM-DD.md` |
| `architecture` | Architecture overview plus ADR drafts | `docs/architecture/overview-YYYY-MM-DD.md`, `docs/architecture/adr-draft-NNN-<slug>.md` |
| `concept` | Concept document from a prototype | `design/concept-reverse-YYYY-MM-DD.md` |
| `brief` | One-page orientation for humans and coding agents | `docs/project-brief.md` |
| anything else or empty | Pick by the defaults below | as above |

The rest of the argument is the path (default: project root). When no mode is given, take the
first rule that matches: (1) a directory or system path below the root means **architecture**;
(2) a `.gameforge/project.json` phase of `concept` or `prototype`, or a jam-sized build, means
**concept**; (3) no GDD in `design/` means **design**; (4) otherwise **architecture**. State the
choice in Assumptions.

## Critical rules

1. **Read before writing.** Every claim traces to a file and line, a commit, or a config key. Cite
   them inline (`player/dash.gd:14`, commit `a3f9b2c`).
2. **Intent over implementation.** "Applies downward force" is code; "the player gets about six
   frames of coyote time after leaving a ledge, so jumps feel forgiving" is design. Write the second
   and cite the first.
3. **Label every intent claim.**
   - **STATED** -- intent is written down: a code comment, commit message, test name, existing doc.
   - **INFERRED** -- strongly implied by behavior and naming.
   - **UNVERIFIED** -- plausible but unsupported; the team must confirm.
   Guessing intent and presenting it as fact is worse than leaving a gap.
4. **Systems, not files.** Organize by game system (movement, combat, economy, UI). A system that
   spans five files across three folders is one section with a file list.
5. **Surface inconsistencies.** If movement assumes tiles and collision assumes continuous space, or
   two save systems exist, that is a headline finding, not a footnote.
6. **Know what you cannot read.** Unreal Blueprints and `.uasset`/`.umap` files are binary; Unity and
   Godot scenes are text but carry tuned values and wiring. Document what is visible and list the
   binary or editor-only logic as a limit.
7. **One pipeline, four outputs.** The analysis below is shared; only the output format changes.

## Phase 1: Project scan

1. **Engine and version.** `.gameforge/project.json`; else `project.godot`,
   `ProjectSettings/ProjectVersion.txt`, `*.uproject`, or `package.json` dependencies (`three`,
   `@react-three/fiber`, `phaser`, `pixi.js`, `kaplay`, `excalibur`, `babylonjs`, `playcanvas`),
   `Cargo.toml` with `bevy`. Note the language mix (GDScript/C#, C#, C++/Blueprint, TS/JS).
2. **Entry points.** Godot `run/main_scene` and `[autoload]` in `project.godot`; Unity scenes in
   `ProjectSettings/EditorBuildSettings.asset`; Unreal `GameDefaultMap` and `GlobalDefaultGameMode`
   in `Config/DefaultEngine.ini`; web `index.html` -> `src/main.*`.
3. **Shape and scale.** Annotated directory tree (two levels), counts of scripts, scenes, assets and
   tests from Glob. Classify: small (under ~50 scripts), medium, large. For large projects, document
   the core loop systems fully and the rest at inventory depth; say so.
4. **Existing knowledge.** README, `CLAUDE.md`, `design/`, `docs/`, `progress.md`, `SPEC.md`,
   `production/session-state/active.md`, code comment density, test presence.
5. **History.** `git log --oneline -50` for the arc of development; `git log --stat` to find churn
   hotspots (files changed most often are the fragile ones); `git log --format='%h %s%n%b'` for
   `Co-Authored-By:` trailers that show which systems were agent-written. Commit messages are often
   the only STATED intent a vibe-coded project has.

## Phase 2: System detection

Game systems leave recognizable fingerprints in every engine. Read
`${CLAUDE_SKILL_DIR}/references/system-fingerprints.md` before this phase: it lists the signals for
movement, combat, inventory, UI, audio, save/load, AI, progression, physics, camera, economy,
networking, localization and analytics, plus engine-specific registration points (autoloads,
ScriptableObjects, subsystems, stores and ECS worlds).

Record the inventory:

```
SYSTEM INVENTORY
---------------------------------------------------------------------------------
System       | Files                              | Complexity | Depends on        | Agent-written?
---------------------------------------------------------------------------------
Movement     | player/player.gd, player/dash.gd   | medium     | Input, Physics    | mostly
Scoring      | systems/score.gd, net/board.gd     | low        | Combat, Net       | yes
Save/Load    | autoload/save.gd, systems/persist.gd | medium   | all stateful      | mixed  <- two systems
---------------------------------------------------------------------------------
ORPHANED: tools/old_spawner.gd (no references; last changed 2026-08-02)
MISSING:  no audio bus setup; no localization (strings hardcoded in 31 files)
```

## Phase 3: Mechanics extraction

A mechanic is a rule that governs interaction. For each system, extract:

```
MECHANIC: Air dash
  Implementation: player/dash.gd:14-62 (state DASH in player/states.gd:40)
  Rule: one dash per airtime; 0.18 s at 3x run speed; refreshes on landing or wall contact
  Parameters: dash_time 0.18, dash_mult 3.0, refresh_on_wall true (dash_tuning.tres)
  Interactions: cancels attack wind-up; disables gravity while active
  Intent: STATED (commit 8c1d2e0 "dash should refresh on walls for flow") / feel goal INFERRED
```

Look in: state machines (each state is a behavior), input handlers (each action is a verb),
collision callbacks (each is an interaction rule), timers and cooldowns (pacing decisions), constants
and data files (balance parameters), and tests (the closest thing to a written spec).

## Phase 4: Dependency mapping

```
DEPENDENCY MAP
[Movement] --reads--> [Input]          [Combat] --modifies--> [Health]
[Movement] --uses---> [Physics]        [UI]     --reads-----> [Health, Inventory]
[Save]     --reads--> [all stateful]   [Score]  --trusts----> [client values]   <- flag

TIGHT COUPLINGS: Combat writes Player.hp directly instead of a damage signal/event
CIRCULAR:        GameManager <-> UIManager (initialization order risk)
ISOLATED:        WeatherSystem (nothing depends on it; intentional or abandoned?)
```

## Phase 5: Write the output

Full templates for the design and architecture modes, and the ADR draft format, are in
`${CLAUDE_SKILL_DIR}/references/output-templates.md`; read it before writing either. They follow
`${CLAUDE_PLUGIN_ROOT}/templates/game-design-document.md` and
`${CLAUDE_PLUGIN_ROOT}/templates/architecture-decision-record.md`.

Every output starts with the same header:

```markdown
# [Title]
*Reverse-documented from code by GameForge on 2026-11-05. Source: [path], commit [short hash].*

## Assumptions and limits
- Mode chosen: design (no GDD found in design/).
- Blueprint logic in Content/Blueprints/ is binary and was not analyzed; 14 assets listed by name only.
- 9 intent claims are UNVERIFIED; they are marked inline and listed at the end.
```

### Mode: concept (inline template)

Use for jam builds and prototypes being promoted to real projects. It follows
`${CLAUDE_PLUGIN_ROOT}/templates/game-concept.md`.

```markdown
# Game Concept: [Project Name] (reverse-documented)

## Core
- **Pitch (inferred):** A one-room roguelite where every dash leaves a trail that damages enemies.
- **Core verb:** dash. **Core loop:** clear room -> pick one of three trail upgrades -> next room.
- **Session shape:** 6-10 minute runs (run timer default 600 s in run_config.tres).

## What the player experiences
- Moment to moment: [from mechanics] -- Intent: INFERRED
- What makes it interesting: [the mechanical interaction that is genuinely novel]

## Mechanics summary
| Mechanic | Rule (design language) | Key parameters | Evidence |
|---|---|---|---|
| Dash trail | Trail lasts 1.2 s, 4 dmg/tick | trail_life, trail_dps | dash.gd:30, STATED in commit |

## Presentation
- Art approach: [pixel / low-poly / vector; resolution, palette files]
- Audio: [present/absent; placeholder or final; AI-generated assets listed in provenance log?]

## Scope assessment
- Current state: prototype -- 3 room types, 5 enemies, 9 upgrades counted in data/
- Missing for a shippable game: save system, settings menu, audio mix, localization, onboarding

## Strengths and gaps (from code evidence)
## Recommended next steps
```

### Mode: brief (inline template)

A one-page orientation that a new teammate, or a fresh coding-agent session, reads first. Keep it
under 80 lines. It does not replace `CLAUDE.md`; it ends with a suggested snippet the team may paste
into it.

```markdown
# Project Brief: [Project Name]
**Engine:** Godot 4.7.2 (GDScript) | **Phase:** prototype | **Updated:** 2026-11-05 from commit a3f9b2c

## Run and check
- Run: `godot --path .` | Tests: `godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`
- Web build: `npm run build` (if present) | CI: .github/workflows/godot-ci.yml

## Systems map (one line each)
| System | Lives in | Owns | Talk to it via |
|---|---|---|---|
| Movement | player/ | velocity, dash state | InputMap actions |
| Save | autoload/save.gd | save.json v3 | SaveManager.save()/load() |

## Invariants (do not break)
- Gameplay values live in *.tres resources, never literals (see data/).
- Scores are computed server-side in net/board.gd; the client sends events only.
- One save system: autoload/save.gd. systems/persist.gd is legacy (see Known problems).

## Do not touch
- .godot/, *.uid (commit, never hand-edit), export_presets.cfg credentials

## Known problems
- Two save paths (autoload/save.gd and systems/persist.gd); dash tuning duplicated in dash.gd and dash_tuning.tres.

## Suggested CLAUDE.md snippet
> Check command: `godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`.
> One system per job: reuse SaveManager, AudioBus, InputMap actions; ask before adding dependencies.
```

## Working with AI Coding Agents

Reverse documentation is the antidote to vibe debt: agents write code faster than anyone writes
down why.

- **Run it at phase changes.** After a jam, after a vibe-coded prototype proves fun, before
  onboarding anyone, and before a big refactor. `/gameforge:game-reverse-document brief` is cheap
  enough to run weekly on an agent-built project.
- **Give agents the brief, not the codebase.** A fresh session that reads `docs/project-brief.md`
  first stops re-inventing existing systems, the most expensive agent habit. Keep the brief and the
  project `CLAUDE.md` short and lead with the check command.
- **Use git as the intent record.** Agent sessions leave rationale in commit messages, `progress.md`
  and `SPEC.md`; cite them as STATED intent. If commits say nothing ("update files"), say so in
  limits and recommend the team adopt descriptive commit subjects.
- **Verify by hand:** every UNVERIFIED claim, every design rule that drives balance, and every
  architecture invariant the brief asks agents to respect. A wrong invariant in a brief is worse
  than none, because agents follow it.
- **Mark agent-written systems.** The inventory's "Agent-written?" column tells reviewers where to
  apply `/gameforge:game-code-review` with the full AI-change audit.
- **Track asset provenance too.** If the scan finds AI-generated art, audio or voice without a
  provenance log, list it under gaps and route to `/gameforge:game-ai-assets`.
- For the agent build loop itself, use `/gameforge:game-vibe-code`.

## Quality checklist

```
[ ] Mode, scope and every assumption stated at the top
[ ] Every system traces to files; every mechanic cites file:line or a commit
[ ] Every intent claim labelled STATED / INFERRED / UNVERIFIED, with UNVERIFIED items listed at the end
[ ] Orphaned code, duplicate systems and missing systems listed
[ ] Dependencies mapped, including circular and client-trusting edges
[ ] All tunable parameters extracted, grouped by system, with their data file or literal location
[ ] Organized by game system, not by folder
[ ] Binary and editor-only logic listed as a limit, not silently skipped
[ ] No code or existing document modified; new files only
[ ] Readable by someone who has never opened the project
```

## Hand-offs

| Next step | Skill |
|---|---|
| Validate the reverse-engineered design against pillars and player experience | `game-design-review` |
| Audit the code quality and AI-written changes the inventory flagged | `game-code-review` |
| Turn the reverse GDD into a maintained, section-by-section GDD | `game-gdd-author` |
| Decide what to cut or keep given the documented scope | `game-scope-check` |
| Architecture decisions the overview surfaced | `game-technical-director` |

Shared vocabulary: `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md` (MDA, loops, flow) for design
language and `${CLAUDE_PLUGIN_ROOT}/docs/coding-standards.md` for the architecture standards the
technical debt register measures against.

## When NOT to use me

- Writing new design from a blank page: `game-gdd-author` or `game-brainstorm`.
- Reviewing code for bugs and AI debt: `game-code-review`.
- Planning the next sprint from what you find: `game-sprint-plan`.
- Engine how-to questions: the engine specialist for your stack.

## Example requests

1. **"I have a jam prototype and want to turn it into a real project."** Concept mode on the root:
   pitch, loop, mechanics with parameters, honest scope gap list.
2. **"A new developer joins Monday."** Brief mode first (one page), then architecture mode for the
   systems they will own.
3. **"We built for months with Claude Code and never wrote a design doc."** Design mode; expect a
   STATED-heavy document from commit messages and an "Agent-written?" inventory.
4. **"Document `src/combat/` so I can refactor it safely."** Architecture mode on that path: entry
   points, data flow, coupling, and the invariants a refactor must keep.
5. **"I forgot why the economy works this way."** Design mode on `systems/economy/`: rules, faucets
   and sinks, parameters, and every UNVERIFIED intent listed for you to confirm.
