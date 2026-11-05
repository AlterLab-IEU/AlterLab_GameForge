# Project Audit Checklists (States 2-4)

Use the checklist that matches the detected state. Report findings as a ranked list, not a dump:
what will hurt in the next month comes first.

Severity scale used in the setup report:

| Severity | Meaning |
|---|---|
| Critical | Blocks development or risks losing work (no version control, no build, no core loop) |
| Important | Will cause confusion, rework or bugs within weeks |
| Nice-to-have | Polish; schedule it, do not block on it |

---

## State 2: Concept exists (docs, no code)

Read every design document before judging. Check for these, in this order:

| Item | Critical if missing? | What good looks like |
|---|---|---|
| Core loop | Yes | One sentence: action -> feedback -> reward -> next decision, at the 30-second scale |
| Target player and platform | Yes | A named player motivation and one primary platform |
| Scope estimate | Yes | Team size, hours per week, target date, and a "won't have" list |
| Pillars | Important | 3-5 falsifiable pillars (`${CLAUDE_PLUGIN_ROOT}/templates/game-pillars.md` format) |
| Art and audio direction | Important | References and constraints, even a paragraph each |
| Technical requirements | Important | Engine, target hardware, online or offline, save model |
| Progression | Nice-to-have at this stage | The 30-minute and multi-session loops |
| UI wireframes | Nice-to-have | Rough sketches of the HUD and main menu |

Also check:
- Contradictions between documents (a "cozy" pillar next to a permadeath mechanic).
- Scattered files: propose moving them into `design/` (with the user's OK; never move silently).
- The right moment to start coding: the core loop is written down and one pillar mechanic is
  specified well enough to prototype. Route to `/gameforge:game-prototype`.

## State 3: In progress (code and some docs)

### Codebase scan

| Check | How |
|---|---|
| Size and language | Count source files by extension with Glob |
| Engine and version | From Step 0 |
| Tests | Glob `tests/**`, `test/**`, `Assets/Tests/**`, `*.test.ts`, `*_test.gd` |
| Build and CI | `package.json` scripts, `export_presets.cfg`, `.github/workflows/` |
| Debt markers | Grep `TODO|FIXME|HACK|XXX` in source directories; report counts per directory |
| God files | Source files over ~800 lines (rule of thumb); one-file web games over ~3,000 lines are overdue for a split |
| Hardcoded tuning | Grep for literal speeds, damage, timers in gameplay code instead of data files or exported fields |

### Structural health questions

- Is gameplay logic separated from engine glue, so it can be tested without the engine running?
- Do systems talk through a few clear interfaces (signals, events, interfaces), or does everything
  reach into everything?
- Are assets organized by feature or type, or dumped in one folder?
- Is there a README or `CLAUDE.md` that gets a new contributor (or a fresh agent session) to a running
  game in five minutes?

### AI-built codebase signals

Agent-generated projects fail in recognizable ways. Flag these explicitly:

- One very large file or `main.js` holding everything.
- Game state on `window` globals or other client-trusted state in a multiplayer game (scores, hits
  and purchases must be validated server-side).
- No deterministic restart or test hook, so every check is manual.
- Duplicate implementations of the same system from repeated regenerations.
- Generated assets with no record of tool, prompt or license.

Route to `/gameforge:game-code-review` for the code and `/gameforge:game-ai-assets` to start a
provenance log retroactively.

## State 4: Mature codebase

### Architecture

- Map the major systems and how they communicate; draw the dependency direction.
- Look for circular dependencies between systems or modules.
- State management: explicit state machines, or nested boolean flags?
- Data pipeline: are gameplay values data-driven (Resources, ScriptableObjects, Data Tables, JSON)?

### Documentation

- Coverage: which systems have any documentation? Estimate a percentage.
- Freshness: does the documentation describe the current game or one from months ago? Compare doc
  dates with `git log` on the related code.
- The most dangerous gap: the highest-complexity system with the least documentation. Route it to
  `/gameforge:game-reverse-document`.

### Technical health

| Area | Check |
|---|---|
| Tests | What is covered, what is not; do tests run headless? |
| Build | Does a clean checkout build? Are warnings ignored? |
| Dependencies | Engine version vs. the current table in SKILL.md; packages more than a major version behind; abandoned libraries (for web: `cannon-es`, `kaboom`, `colyseus.js`, Theatre.js are superseded) |
| Performance | Obvious hot-path allocations, per-frame lookups, unbounded spawns |
| Platform shifts | Unity 6.0 LTS out of standard support (2026-10-16): plan a move to 6.3 LTS. UE5 projects: note UE6's Verse and Scene Graph direction. Godot C#: 4.8 needs .NET 10. |

### Output

Produce an effort-vs-impact list:

| Finding | Impact (H/M/L) | Effort (H/M/L) | Do it | Skill |
|---|---|---|---|---|
| [No tests on save system] | H | M | Next sprint | `/gameforge:game-qa-lead` |
| [Docs describe old combat] | M | L | This week | `/gameforge:game-reverse-document` |

Quick wins (high impact, low effort) first; then the biggest risks; then everything else.
