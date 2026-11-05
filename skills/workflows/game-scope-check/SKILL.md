---
name: game-scope-check
description: >
  Checks scope against time and capacity: feature inventory, MoSCoW with effort caps, impact and
  risk scores, buffer math, scope-creep signals and a cut list, with velocity calibrated for
  AI-agent work and vibe debt counted as risk. Use for "scope creep", "can we fit this", "what
  should we cut", "are we on track". Not for sprint task planning (use game-sprint-plan).
argument-hint: "[feature list, milestone or deadline to evaluate]"
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git log *), Bash(git shortlog *), Bash(git diff --stat *)
effort: medium
---

# AlterLab GameForge -- Scope Check

Games rarely die from one bad decision. They die from a feature list that grows one reasonable
addition at a time until it no longer fits the team that has to finish it. Adding feels like
progress and cutting feels like failure; this workflow inverts that. Cutting is the skill, and a
tight scope is the achievement. **A finished game with eight polished features beats an abandoned
one with twenty half-built ones.**

AI coding agents change the arithmetic but not the principle. They make the first playable and
the boilerplate dramatically cheaper, which makes it easy to add features. They do not make
integration, content, QA, polish or review proportionally cheaper, and unreviewed agent code
creates debt that comes due later. The 2026 Vibe Jam gold winner, built with Claude Code in about
two weeks (roughly 27k lines, 188+ commits, per Wccftech's July 2026 report on its workflow), was scoped to
5-10 minutes of play, and its creator built the 3D map by hand. Scope to what the whole pipeline
can finish, not to how fast the prototype appeared.

## Purpose & Triggers

**Use this workflow when:**
- The feature list has grown since the last check, or nobody has ever done one.
- Someone says "can we fit this in?" or "it'd only take the agent an hour."
- A milestone, demo, festival or launch date is approaching and confidence is low.
- Sprint velocity keeps missing plan, or agent sessions keep re-fixing the same systems.
- The team feels overwhelmed and cannot say why.

**Do NOT use this workflow when:**

| Need | Route to |
|---|---|
| Turning the agreed scope into sprint tasks | `game-sprint-plan` |
| Making the final ship-date or scope call, risk register, milestones | `game-producer` (this check feeds its decision) |
| De-risking one unknown feature before estimating it | `game-prototype` |
| Scoping a 48-72 hour jam | `game-jam-mode` |
| Assessing code health and refactor needs in detail | `game-code-review`, `game-technical-director` |
| Reviewing the design itself | `game-design-review` |
| Looking back at why scope slipped | `game-retrospective`, `game-postmortem` |

## Inputs I Read First
- `.gameforge/project.json` (phase, pillars), feature lists and the GDD in `design/`, sprint plans
  in `production/sprints/`, milestones in `production/milestones/`, previous checks in
  `production/scope/`, and `production/session-state/active.md`.
- **Git history as velocity evidence** (read-only): `git log --since="8 weeks ago" --oneline`,
  `git shortlog -sn --since="8 weeks ago"`, `git diff --stat <last-milestone-tag>..HEAD`, and the
  share of commits with agent co-author trailers. Real throughput beats remembered throughput.
- Ask up to three AskUserQuestion items, with defaults:
  1. **Deadline and what it is**: demo or festival, early access, 1.0 launch, publisher milestone.
  2. **Capacity**: people x honest hours per week (default: one person, 15 h/week, part-time).
  3. **How the code gets written**: mostly by agents, mixed (default), mostly by hand.

## Critical Rules

1. **One in, one out.** Adding a feature means cutting one of equal effort. No "we'll work harder."
2. **Effort caps.** Must Haves take no more than 60% of estimated effort, with about 20% in Could
   Haves as contingency (the DSDM/Agile Business Consortium MoSCoW guidance); Should Haves fill the
   rest. If Must Haves exceed 60%, the plan is at risk however important each feature feels.
3. **Score, don't debate.** Disagreements challenge individual scores, not the outcome.
4. **Buffer is not optional.** Below 20% buffer, expect to miss the date (rule of thumb). Buffer is
   for surprises, never for features.
5. **Freeze dates are real.** No new features in the final days before a milestone (default three
   working days; a week before a festival or store submission).
6. **Estimate the whole feature.** Design + code + content + integration + QA + polish + review.
   Agents speed up some of these and not others; estimate each part separately.
7. **Velocity comes from evidence.** Plan from measured throughput on finished work, not from how
   fast a prototype appeared.
8. **Vibe debt is scope.** Agent-written code nobody has reviewed, tested or understood is work
   that has not been done yet. Put its stabilization cost in the plan.
9. **Write the cut list before you need it.** Decide what goes first while everyone is calm.

## Workflow

**PHASE 1: Feature Inventory**

Catalog everything planned, in progress, requested or assumed. Do not filter yet.

```
FEATURE INVENTORY
ID   | Feature                 | Status       | Requested by | Pillar served
F01  | Grapple traversal       | in progress  | design       | "fluid movement"
F02  | Online co-op            | requested    | Discord      | --
F03  | Settings + rebinding    | assumed      | --           | (table stakes)
```

Probe for the hidden features that never make lists but always take time: settings, rebinding,
save/load and save migration, controller support, pause and quit flows, basic accessibility
options, localization hooks, tutorial or onboarding, credits, crash reporting, store page assets
and trailer, demo build, platform builds (Steam Deck, web, mobile), achievements, AI-use
disclosure and the asset provenance log, analytics consent. Read
`${CLAUDE_SKILL_DIR}/references/cut-list-playbook.md` for the full hidden-feature checklist and
the cut techniques used in Phase 8.

**PHASE 2: Estimate by Work Type, Calibrated for AI Agents**

Estimate each feature in hours, split by work type, then apply the team's velocity ratios:

| Work type | With coding agents (planning assumption until measured) |
|---|---|
| Boilerplate, scaffolding, menus, data plumbing, debug tools | Much faster |
| First prototype of one mechanic | Much faster |
| Integration with other systems, cross-system bugs | Little or no speedup; often slower if the code is unreviewed |
| Content: levels, writing, art direction, audio | Little speedup; AI assets add review, cleanup and provenance work |
| QA and playtesting | No speedup; more code shipped faster means more to test |
| Polish, juice, feel | Bound by human iteration and playtest cycles |
| Review of agent output | New cost that hand-written code did not have |

Read `${CLAUDE_SKILL_DIR}/references/ai-velocity-calibration.md` before estimating a project
built with agents: it explains the evidence behind each row, gives starting multipliers explicitly
labeled as assumptions, and shows how to replace them with ratios measured from the project's own
git history after two sprints.

If you have never built something like a feature before, double its estimate; if the engine or
domain is new to the team, add 25-50% on top (rules of thumb). Mark anything you cannot estimate
as UNKNOWN: an unknown is a prototype task, not a number.

**PHASE 3: MoSCoW with Effort Caps**

```
MUST HAVE (cap: 60% of effort) -- the game does not function or ship without it
  F01 Grapple traversal ........ 60 h  core verb, pillar "fluid movement"
  F03 Settings + rebinding ..... 18 h  table stakes; accessibility
  Subtotal: [X h] of [total] = [Y%]   -> OK / OVER

SHOULD HAVE -- notably better; a reviewer would notice it missing
  ...
COULD HAVE (about 20%: the contingency pool, first to go)
  ...
WON'T HAVE (this release) -- written down so it stops coming back
  F02 Online co-op ............. reason: networking risk, no pillar, 200+ h
```

Red flags: Won't Have is empty; Must Have over 60%; everything is Must Have (force-rank the Must
Haves against each other and start again).

**PHASE 4: Feature Scoring Matrix**

**Score = (Impact x Feasibility) / Risk**, each 1-5.

```
Feature | Impact | Feasibility | Risk | Score | Verdict
F01     | 5      | 4           | 2    | 10.0  | KEEP
F02     | 3      | 1           | 5    | 0.6   | CUT
```

- **Impact**: 5 core loop depends on it; 4 major experience gain; 3 reviewers would mention it;
  2 minor polish; 1 players never see it.
- **Feasibility**: 5 built this exact thing before; 3 understood but new; 1 nobody has done it.
  Score feasibility of *shipping and maintaining* it, not of the agent scaffolding it. "Claude
  wrote a netcode prototype in an evening" is feasibility 4 for the prototype and often 1-2 for
  shipped, server-authoritative multiplayer.
- **Risk**: 5 could derail the project; 3 could slip a sprint; 1 low consequence.

Verdicts: 3.0 or higher KEEP; 2.0-3.0 EVALUATE (can risk drop or scope shrink?); below 2.0 CUT to
Won't Have.

**PHASE 5: Timeline and Buffer**

```
CAPACITY
  People x honest hours/week x weeks remaining     = gross hours
  minus overhead (admin, community, marketing, ~15-25%) = net hours

WORK REMAINING (calibrated, Phase 2)
  Must + Should + Could                           = planned hours
  plus vibe-debt stabilization budget (Phase 6)   = total planned

BUFFER = net - total planned        BUFFER % = buffer / net
  30%+    GREEN   room for surprises
  20-30%  YELLOW  tight; no new features
  10-20%  ORANGE  one surprise from missing; execute the cut list's first tier
  <10%    RED     the date will be missed; cut now or move the date
  <0%     OVER    impossible as planned
```

Add external lead times as fixed blocks, not buffer: store and portal review (Engadget reported
on 2026-11-04 that Steam build reviews were taking up to 12 business days against a 3-5 day
target), console certification and resubmission, festival demo deadlines, localization turnaround.

**PHASE 6: Vibe-Debt Assessment**

Count agent-built debt as scope risk. Score each signal 0 (absent), 1 (some) or 2 (severe):

| Signal | How to see it |
|---|---|
| Unreviewed agent code in core systems | Commits with agent co-author trailers touching core files that no human reviewed |
| Rework loop | Many `fix:` commits on the same files; agent sessions re-fixing earlier fixes |
| Monolith growth | One file or scene holding most of the game (single-file web games past a few thousand lines are a common warning sign) |
| Thin tests | Feature count rising faster than test count; no smoke test (see `game-qa-lead`) |
| Hard-coded tuning | Balance numbers scattered through code (see `game-balance-check`) |
| Nobody can explain it | The team cannot describe how a core system works without asking the agent |
| Client-trusted state | Multiplayer or leaderboards that trust the client |

0-3: normal; 4-7: add a stabilization budget (rule of thumb: 10-20% of remaining code hours);
8+: stop adding features until a stabilization sprint lands. Structural refactors are a
Technical Director decision; route the evidence to `game-technical-director` and
`game-code-review`.

**PHASE 7: Scope-Creep Detection**

```
Signal                                                        | Y/N
Feature list grew since last check                            |
Won't Have is empty                                           |
Everything is Must Have                                       |
Features added without an equal cut                           |
Estimates on existing features trending up                    |
Features arriving from casual chat or "the agent can do it"   |
Prototypes promoted to production without a rewrite decision  |
Buffer shrinking sprint over sprint                           |
Milestone date moved more than once                           |
Team morale falling despite visible "progress"                |
0-2 healthy | 3-4 early warning | 5-7 active creep | 8-10 full scope reset
```

**PHASE 8: Cut List**

Write an ordered cut list now, in tiers with triggers, so cuts happen on schedule rather than in
a panic: Tier 1 executes when buffer drops below 20%, Tier 2 below 10%, Tier 3 if the date is
fixed and buffer goes negative. For each candidate, prefer the cheapest technique that keeps the
pillar: cut, shrink, fake, reuse, or defer to post-launch. Never cut save integrity, crash fixes,
basic settings and accessibility, or compliance and disclosure work. The playbook reference has
the techniques and template.

**PHASE 9: Change Freeze**

```
Milestone: [name] on [date]          Freeze: [date minus 3 working days; a week for festivals/submission]
After freeze, allowed:   bug fixes, polish on existing features, store assets, build pipeline
After freeze, banned:    new features of any size, scope changes, new assets for unbuilt features,
                         "quick" agent-generated additions
Breaking the freeze:     Producer approval + equal cut + written rationale; counts as a creep signal
```

**PHASE 10: Report and Hand Off**

Write the Scope Assessment Report to `production/scope/YYYY-MM-DD-scope-check.md`, hand the
agreed scope to `game-sprint-plan`, send decisions needing authority to `game-producer`, and update
`production/session-state/active.md` with the traffic-light status, the cuts made and the next
check date.

## Working with AI Coding Agents

**What to delegate to the agent during a scope check**
- Building the feature inventory from the GDD, TODOs, issues and code (`grep` for TODO/FIXME,
  stubbed functions, feature flags).
- Splitting estimates by work type and filling the scoring matrix as a first draft.
- Summarizing git history: commits per week, fix-vs-feature ratio, files touched most often.

**What the human decides**
- Impact scores and pillar fit. The agent does not know what makes the game worth playing.
- Whether a prototype gets promoted, rewritten or thrown away.
- What gets cut. The agent will happily keep everything.

**Planning guardrails for agent-built games**
- **The ten-minute feature is not ten minutes.** A feature that took ten minutes to prompt still
  needs integration, content, tests, polish, review and support. Estimate those parts.
- **Prototype speed is not production velocity.** Re-measure after two sprints of finished,
  reviewed, tested work; replace the starting multipliers with the measured ones.
- **Budget review time explicitly**, as its own line, for every agent-built system that ships.
- **Keep the game original.** Claude Code declines to recreate specific existing games (since
  late October 2026); scope features as your own design and genre mechanics, not as "X from game Y."
- **Distribution is scope too.** With stores and portals flooded with fast-made games, budget real
  hours for store page, trailer, demo and community, not just features.

Pair with `/gameforge:game-vibe-code` for the build loop and `/gameforge:game-ai-assets` when AI
assets are part of the content estimate.

**Prompt that works**: "Read `design/` and `production/sprints/`, list every feature (including
assumed ones like settings and save), and split each into design, code, content, integration, QA,
polish and review hours. Use the multipliers in `production/sprints/velocity.md`. Mark anything you
cannot estimate UNKNOWN. Do not classify or cut anything."

## Output Format

```markdown
# Scope Assessment Report -- [Project] -- [YYYY-MM-DD]
**Status:** [GREEN / YELLOW / ORANGE / RED / OVER] | **Milestone:** [name] on [date] | **Freeze:** [date]

## Summary
[2-3 sentences: overall assessment, key concern, recommended action.]

## Capacity and Buffer
| Net capacity | Planned work | Vibe-debt budget | External lead times | Buffer | Buffer % |
|---|---|---|---|---|---|
| 420 h | 290 h | 30 h | Steam review 12 business days | 100 h | 24% (YELLOW) |

## Velocity Basis
- Measured over [N] weeks: [x] features done, estimate accuracy [actual/estimate = 1.4],
  agent-assisted commits [y%], fix:feature commit ratio [z]
- Multipliers used: [measured / starting assumptions from the calibration reference]

## MoSCoW Breakdown
| Category | Features | Hours | % | Cap | Status |
|---|---|---|---|---|---|
| Must | 6 | 170 | 59% | <= 60% | OK |
| Should | 4 | 70 | 24% | -- | -- |
| Could | 3 | 50 | 17% | ~20% | OK |
| Won't | 5 | -- | -- | >= 2 items | OK |

## Feature Scores (descending)
| ID | Feature | I | F | R | Score | Verdict |
|---|---|---|---|---|---|---|

## Vibe-Debt Score: [n]/14 -- [normal / stabilization budget / stop and stabilize]
[Top signals with evidence]

## Scope-Creep Signals: [n]/10
[Active signals]

## Cut List
| Tier | Trigger | Feature | Technique | Hours saved | Pillar impact |
|---|---|---|---|---|---|
| 1 | Buffer < 20% | Weather system | Cut to post-launch | 26 h | none |
| 2 | Buffer < 10% | Boss 3 | Reuse boss 2 arena + new pattern | 30 h | low |

## Decisions Needed (owner)
1. [Decision] -- `game-producer`

## Next Check
[Date or trigger, e.g. end of sprint 6 or any new feature request]
```

## Quality Criteria
- Every feature has an hour estimate split by work type, or is explicitly UNKNOWN with a
  prototype task.
- Velocity is grounded in measured history when history exists; starting multipliers are labeled.
- Must Haves at or under 60% of effort; Won't Have has at least two items.
- Buffer is calculated with external lead times and the vibe-debt budget included.
- No feature scoring under 2.0 remains in Must or Should.
- A tiered cut list with triggers exists, and nothing on the never-cut list is on it.
- A freeze date is set for the next milestone.
- Every decision traces to scores, capacity math or a pillar, not to who argued hardest.

## Anti-Patterns
- **The Rubber Stamp**: nothing gets cut because nobody wants the conflict. A check that cuts
  nothing was probably not honest.
- **The Hostage Feature**: "we already started it." Sunk cost is not a reason; remaining cost
  versus value is.
- **The Stealth Add**: features slip in without going through the matrix, often as "the agent
  already did a version of it."
- **The Ten-Minute Feature**: prompt time mistaken for feature cost.
- **The Infinite Must Have**: "I want this" confused with "the game needs this."
- **The Missing Buffer**: "we'll just work harder." Buffer is reality insurance.

## Cross-References
- `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`: pillar alignment for Impact scores
- `${CLAUDE_PLUGIN_ROOT}/docs/coordination-rules.md`: escalation when scope conflicts arise
- `${CLAUDE_PLUGIN_ROOT}/templates/sprint-plan.md`: consumes this check's agreed scope
- `${CLAUDE_PLUGIN_ROOT}/templates/game-pillars.md`: the pillars features must serve
- Receives input from `game-brainstorm`, `game-design-review` and `game-gdd-author`; feeds
  `game-sprint-plan` and `game-producer`.

## Example Use Cases
1. "Here's my feature list for a Steam Next Fest demo in 6 weeks. Can I fit it?"
2. "Claude built most of the game in a month. Now everything takes forever. Are we over scope?"
3. "We want to add online co-op. What do we cut to make room, and is it even feasible?"
4. "Write us a tiered cut list for the 1.0 launch before we need it."
5. "Measure our real velocity from git and tell me whether the March date is realistic."
