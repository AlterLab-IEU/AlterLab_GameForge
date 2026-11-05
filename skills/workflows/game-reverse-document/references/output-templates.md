# Output Templates: Design and Architecture Modes

Read this before writing design or architecture output. Both start with the shared header and
"Assumptions and limits" block from SKILL.md. Fill every bracket with project evidence; delete a
section only if it truly does not apply, and say why in Assumptions.

## Design mode: reverse-engineered GDD

Write to `design/gdd-reverse-YYYY-MM-DD.md`. Structure follows
`templates/game-design-document.md` in the GameForge plugin so the result can be promoted into a
maintained GDD with `game-gdd-author`.

```markdown
# Reverse-Engineered Game Design Document: [Project Name]
*Reverse-documented from code by GameForge on [date]. Source: [path], commit [hash].*

## Assumptions and limits
- [mode choice, scope, sampled areas, binary assets not analyzed, count of UNVERIFIED claims]

## 1. Overview
- **Engine:** [engine and version] | **Language:** [GDScript / C# / C++ + Blueprint / TypeScript]
- **Genre (inferred):** [from mechanics, e.g. top-down roguelite]
- **Platforms targeted:** [from export presets / build profiles / package scripts]
- **Scope:** [small/medium/large] -- [N] scenes, [N] scripts, [N] content entries in data files
- **Pillars (inferred):** [2-4 phrases the mechanics consistently serve] -- INFERRED

## 2. Core loop
- **Moment to moment:** [verbs from input handlers]
- **Session loop:** [run / level / match structure from scene flow]
- **Long-term loop:** [progression and meta systems, or "none found"]

## 3. Mechanics
### [Mechanic name]
**Player experience:** [what it feels like, in player language]
**Rule:** [exact rule in design language]
**Parameters:** | name | value | location |
**Interactions:** [other mechanics it modifies or depends on]
**Intent:** STATED / INFERRED / UNVERIFIED -- [evidence: comment, commit, test]

## 4. Systems
### [System name]
**Purpose:** [what it contributes to the player experience]
**Components:** [files, classes, scenes, data assets]
**Key behaviors:** [bullets]
**Depends on / provides to:** [systems]
**Agent-written:** [yes / mixed / no, from commit trailers]

## 5. Content inventory
| Type | Count | Source of truth | Notes |
|---|---|---|---|
| Levels / rooms | [N] | [scenes/levels/] | |
| Enemies | [N] | [data/enemies/*.tres] | |
| Items / upgrades | [N] | [data/items.json] | |

## 6. Balance parameters
[All tunable values grouped by system: name, value, unit, location, and whether the value is a
literal in code (flag) or lives in data]

## 7. Economy (if present)
[Currencies, faucets, sinks, prices; route deeper analysis to game-economy-designer]

## 8. UX, accessibility and localization status
- Input remapping: [present/absent] | Subtitles/captions: [ ] | Text in string tables: [% estimate]
- Settings found: [list]

## 9. Inconsistencies and gaps
| # | Finding | Evidence | Impact |
|---|---|---|---|
| 1 | Two save systems | autoload/save.gd, systems/persist.gd | progress loss risk |

## 10. UNVERIFIED items for the team to confirm
1. [claim] -- [where it came from] -- [question to answer]

## 11. What code cannot tell you
[Narrative intent, art direction, audio direction, target audience, business model -- suggest which
GameForge skills should author each]
```

## Architecture mode: overview

Write to `docs/architecture/overview-YYYY-MM-DD.md`.

```markdown
# Architecture Overview: [Project Name]
*Reverse-documented from code by GameForge on [date]. Source: [path], commit [hash].*

## Assumptions and limits

## 1. Technology stack
| Layer | Choice | Version | Evidence |
|---|---|---|---|
| Engine / framework | [Godot / Unity / Unreal / three + Vite] | [x.y] | [file] |
| Physics | [Jolt / GodotPhysics / PhysX-era / Chaos / Rapier] | | |
| Networking | [none / ENet / NGO / Colyseus 0.18] | | |
| Key packages/plugins | [list] | | [manifest] |
| Build and CI | [workflow files, export presets, build profiles] | | |

## 2. Boot sequence
1. [entry scene/map/index.html] -> 2. [global singletons/subsystems/stores initialized] -> 3. [first
gameplay scene]

## 3. Project structure
[Annotated tree, two levels, with what each folder owns]

## 4. Architectural patterns detected
### Pattern: [e.g. autoload singletons as service locators]
**Where:** [files] | **Why it was likely chosen:** [INFERRED rationale]
**Trade-offs here:** [benefits and risks in this codebase] | **Alternatives:** [options]

## 5. Systems
### [System]
**Pattern:** [state machine / event-driven / ECS / MVC variant]
**Entry points:** [functions, scenes, events] | **Data flow:** [inputs -> processing -> outputs]
**Extension points:** [where new behavior plugs in] | **Coupling:** [tight/loose, to what]
**Per-frame cost centers:** [update loops, allocations noticed -- "profile first"]

## 6. Cross-cutting concerns
- **State ownership:** [who owns game state; is anything owned twice?]
- **Communication:** [signals / C# events / delegates / event bus / store subscriptions]
- **Authority (if networked):** [server-authoritative? client-trusted values found?]
- **Configuration and data:** [where tuning lives; literals vs data assets]
- **Error handling and logging:** [patterns, silent catches]
- **Testing:** [frameworks, coverage of gameplay rules, CI status]
- **Generated and protected files:** [.godot/, *.uid, .meta, Intermediate/, dist/ handling]

## 7. Churn and risk hotspots
| File | Commits (last 90 days) | Agent-written | Why it is risky |
|---|---|---|---|

## 8. Technical debt register
| Area | Issue | Severity | Suggested fix | Evidence |
|---|---|---|---|---|

## 9. Invariants a change must keep
[Rules the code relies on but nothing enforces: "Player must exist before HUD _ready", "scores
only computed server-side"]

## 10. Recommendations
[Refactors, tests to add, ADRs to formalize, docs to write next]
```

## ADR draft format

For each significant architectural choice found (engine, physics backend, networking model, state
management, save format, asset loading strategy), write a draft to
`docs/architecture/adr-draft-NNN-<slug>.md`, numbering after the highest existing ADR. Drafts are proposals for
the team to accept or correct, following `templates/architecture-decision-record.md` in the
GameForge plugin.

```markdown
# ADR-[NNN]: [Decision, e.g. "Autoload singletons for global services"]
**Status:** Proposed (reverse-documented [date]; not yet confirmed by the team)
**Evidence:** project.godot [autoload] lines 12-18; commit 4be21aa "add SaveManager autoload"

## Context
[What problem the code shows this solving; constraints visible in code]

## Decision (as implemented)
[What the code actually does]

## Rationale
[STATED reasons from commits/comments, else INFERRED, labelled]

## Consequences observed
- Positive: [ ]
- Negative: [ ] (for example: hidden dependencies, test difficulty)

## Open questions
- [UNVERIFIED items the team must answer to accept this ADR]
```
