---
name: game-sprint-plan
description: >
  Builds a sprint plan for a team or solo developer: one pillar-aligned goal, day-sized tasks that
  each end in a check, dependencies, capacity with buffer, AI-agent estimates with review budgets
  and vibe-debt paydown, written to production/sprints/. Not for whole-project scope (use
  game-scope-check).
argument-hint: "[sprint number, milestone, or focus area]"
effort: high
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git log *), Bash(git status *), Bash(git branch *), Bash(gh issue list *)
---

# AlterLab GameForge -- Sprint Planning

Game sprints fail for different reasons than software sprints. A business-app team struggles with
unclear requirements; a game team struggles with cross-discipline dependencies and the
unpredictability of fun. You can build an inventory system exactly to spec and discover in the
playtest that it makes the game worse. So a game sprint plans discovery time (spikes, feel passes,
playtests) as real work, not as leftovers.

There is a newer failure mode. With Claude Code or a similar agent, code arrives fast, and it is
easy to plan a sprint as if generation were the whole job. It is not. Someone still has to run the
checks, read the diff, play the change and notice what the agent added that nobody asked for.
This workflow budgets that verification on every task, and reserves capacity to pay down the
"vibe debt" that accumulates when agent-written code is accepted faster than it is understood.

The output is a sprint plan file in `production/sprints/` that a team, a solo developer, or a
coding agent working from task cards can execute against.

## When to Use / When Not To

Use before a new sprint, when a solo developer wants to structure the next one or two weeks,
right after a retrospective, when a milestone needs decomposing, or when design work from
`game-gdd-author` or `game-design-review` must become executable tasks.

| Instead of this skill... | Use |
|---|---|
| Is the whole project too big for the date? | `/gameforge:game-scope-check` |
| Reviewing how the last sprint went | `/gameforge:game-retrospective` |
| Milestone dates, risk and publisher-facing schedule | `/gameforge:game-producer` |
| Moment-to-moment agent build loop for one task | `/gameforge:game-vibe-code` |
| Coordinating several studio roles on one problem | `/gameforge:game-team-orchestrator` |
| A 48-72 hour jam schedule | `/gameforge:game-jam-mode` |

## Critical Rules

1. **One goal per sprint.** A single sentence that defines success, framed as a player or project
   outcome ("testers can finish one full run"), not a feature list. Ship everything but miss the
   goal and the sprint failed.
2. **Tasks are at most one day and end in a check.** More than 8 hours of human time means
   decompose further. Every task names how "done" is decided: acceptance check IDs from the GDD, a
   test command and its expected result, or a playtest observation.
3. **Every agent-built task carries a verify budget.** Estimate build time and verify time
   separately. A task whose verification was skipped is not done, whatever the agent reported.
4. **Buffer after estimating.** Subtract 20% of capacity for teams and 30% for solo developers
   (rules of thumb) for meetings, build breaks, hardware, and "I'll just refactor this one thing".
5. **Dependencies are first-class.** A blocked task is not ready. Map chains, find the critical
   path, schedule blockers first.
6. **Scope tiers flex the sprint.** Must / Should / Could / Won't. Cutting a Could on Wednesday is
   healthy; cutting a Must on Friday is a crisis.
7. **Velocity honesty.** Plan from measured completion in `production/sprints/velocity.md`, not from
   hope. If agents doubled your commits but not your completed Musts, your velocity did not double.
8. **Pay down vibe debt every sprint.** A fixed slot, sized from the last retrospective, not
   whatever is left over.
9. **Trace the goal to a pillar.** Infrastructure sprints are fine; call them out. A goal that serves
   no pillar and no infrastructure need is drift; flag it.

## Step 0: Gather Context

Run these (a failure just means "no data"; note it and continue):

```
git log --oneline -20
git status --short
git branch --list
gh issue list --limit 15 --state open
```

Read when present:
- `.gameforge/project.json` -- phase, engine, pillars.
- `production/session-state/active.md` -- current focus, decisions, blockers.
- The latest `production/sprints/sprint-NN.md` and `production/sprints/sprint-NN-retro.md` --
  carry-over, retro actions, the AI lens findings (vibe debt, review cost).
- `production/sprints/velocity.md` -- planned vs completed history.
- `design/gdd.md` §13 (acceptance criteria) and §17 (milestones); `design/systems-index.md`.
- `production/milestones/` -- the current milestone's definition of done.

Then ask **one** AskUserQuestion with up to four questions, offering defaults:
1. Sprint length -- **1 week** (solo default) or 2 weeks (team default).
2. Who is available, and for how many days (note PTO, part-time, contractors).
3. How will most work be built -- by hand, **agent-assisted** (a human drives, the agent drafts),
   or agent-led (the agent implements from task cards, the human verifies).
4. Which milestone this sprint serves, if `production/milestones/` does not make it obvious.

If velocity data is missing, say this sprint establishes the baseline and plan conservatively.

## Step 1: Sprint Goal

```
Format: "By the end of this sprint, [deliverable] is [state] so that [value]."

GOOD: "By the end of this sprint, the core combat loop is playable with 3 enemy types so that
       we can run the first combat playtest on Friday."
GOOD: "By the end of this sprint, save/load round-trips all current game state so that
       playtesters can resume sessions."
BAD:  "Work on combat stuff."            (not evaluable)
BAD:  "Fix bugs and add features."       (two goals)

Serves pillar: [name]  |  Milestone: [name]  |  Goal check: [how we will know on the last day]
```

## Step 2: Task Decomposition

Break the goal into features, features into tasks, tasks into sub-tasks until each is at most one
day of human time (build plus verify). Add non-feature work: bug fixes, retro actions, vibe-debt
items, reviews, playtests.

```
TASK CARD
ID:          S07-03
Title:       Dash: implement cooldown and stamina cost
Done when:   AC-002-2 and AC-002-4 pass (`npm run check`), dash capture attached
Build mode:  H (by hand) | A (agent-assisted) | AL (agent-led)
Build est:   2h      Verify est: 1.5h      Total: 3.5h
Owner:       Sam            Discipline: code
Depends on:  S07-01         Tier: Must          Spike: no
Out of scope: air dash, dash VFX
```

Sizing (total human hours):

| Total | Typical task |
|---|---|
| 1-2 h | Known bug with a repro, a config change, one knob added to a tuning file |
| 3-4 h | Small system with a clear spec and checks |
| 5-6 h | Significant task with some unknowns |
| 7-8 h | At the ceiling; decompose if at all possible |
| > 8 h | Must be split |

**Spikes.** Unknown technology or an untested approach gets a time-boxed spike first ("Spike:
can Jolt handle 200 stacked crates at 60 fps on the Steam Deck? max 4h"). A spike produces a
decision and a note, not shippable code. Agents make spikes cheap; keep the time box anyway.

**Feel passes.** Anything whose success is "it feels right" gets an explicit tuning task with a
playtest check. These do not compress with agents.

## Step 3: Dependency Mapping

The usual chain is design spec -> art/audio asset -> code integration -> QA verification, with
placeholders letting code start before final assets land.

```
S07-01 Design dash rules (§5.2 locked)
  -> S07-03 Implement cooldown + stamina (AL)
       -> S07-06 Integrate dash SFX (needs S07-04 audio)
            -> S07-09 QA: regression run + playtest check AC-002-5
CRITICAL PATH: S07-01 -> S07-03 -> S07-06 -> S07-09 = 11h across 3 people
```

If the critical path is longer than the sprint, rescope or split across sprints. For solo
developers every chain is sequential. Discipline-by-discipline chains and a fuller risk catalog
are in `${CLAUDE_SKILL_DIR}/references/planning-catalogs.md`; read it for team sprints with art,
audio and QA hand-offs, or when the user asks for Kanban.

## Step 4: Estimating with AI Agents

Agents change which work is cheap, not how much judgment a game needs. Read
`${CLAUDE_SKILL_DIR}/references/agent-estimation.md` before estimating any A or AL task; it has
the evidence behind this table, per-task-type verify checklists and a calibration worksheet.

| Speeds up a lot | Speeds up somewhat | Barely speeds up |
|---|---|---|
| Boilerplate, UI wiring, menus | Gameplay systems with a written spec and checks | Game feel and tuning (needs playing) |
| Save/load and data plumbing | Bug fixes with a reliable repro | Level and content authoring that needs taste |
| Editor tools, debug overlays, cheat menus | Shader and VFX tweaks judged by screenshot | Art direction, hero assets, audio mix |
| Test harnesses, AI-vs-AI balance simulators | Porting between frameworks with tests | Playtests and synthesizing feedback |
| Greybox prototypes and spikes | Refactors covered by tests | Performance on real target devices |
| Converting literals to tuning files | Localization plumbing | Multiplayer authority and anti-cheat |
| | | Architecture changes; platform certification and store submission |

**Verify budget (GameForge rules of thumb, replace with your own ratios after three sprints):**

| Build mode | Verify estimate | Verification includes |
|---|---|---|
| H | normal review time | check command, review by a second person on teams |
| A | about 30-50% of build time | check command, read the diff, play the change |
| AL | at least equal to build time | check command, read the diff or a targeted review, play the change, look for out-of-scope additions, confirm knobs not literals |

**Parallel agent sessions** multiply the verify queue, not capacity. The 2026 Vibe Jam winner ran
two or three Claude Code sessions on separate subsystems and spent most of the human time on
planning and playing. Plan no more concurrent AL tasks than the owner can verify the same day.

## Step 5: Vibe-Debt Paydown Slot

Reserve **10-15% of capacity** every sprint (rule of thumb; use the high end after an agent-led
sprint or when the last retro's AI lens flagged debt). Candidates:

- Agent commits merged without review in the last sprint (count them in the retro).
- Duplicate code paths for the same behavior; dead code; leftover debug hooks.
- Oversized files (single-file web games grow past a few thousand lines quickly); split them.
- Gameplay literals that never moved into tuning files.
- Systems with no tests around agent-written logic; flaky tests from unseeded randomness.
- Stale `CLAUDE.md` or project notes the agent relies on.
- Findings from `/gameforge:game-code-review`, `TODO`/`FIXME` markers, high-churn files.

Paydown tasks get checks like any other ("dash.gd under 300 lines; tests green; no literal in
movement code").

## Step 6: Scope Tiering

| Tier | Rule | Share of capacity (rule of thumb) |
|---|---|---|
| **Must** | The goal fails without it; scheduled first, protected | at most 60% |
| **Should** | Strengthens the goal; cut only under real pressure | about 25% |
| **Could** | Polish and stretch; cut first, no guilt | about 15% |
| **Won't** | Considered and deferred; written down so it is not relitigated | 0% |

## Step 7: Capacity

```
Per person:  available days  x  productive hours/day (5-6, rule of thumb)  =  raw hours
Team raw hours                                                [ ]
- Buffer (20% team / 30% solo)                                [ ]
- Vibe-debt slot (10-15%)                                     [ ]
- Ceremonies, playtests, reviews not already in task cards    [ ]
= Plannable hours                                             [ ]

Planned task totals (build + verify):  Must [ ] | Should [ ] | Could [ ] | Remaining [ ]
```

If Remaining is negative: cut Coulds, then Shoulds. Still negative: the goal is too ambitious.
Rescope the goal; do not "try harder". Verify hours count against the person who verifies, which
on a solo project is always the developer.

## Step 8: Risks

Name three to five risks for this sprint with an observable trigger.

| Risk | Prob | Impact | Mitigation | Trigger (when to act) |
|---|---|---|---|---|
| Agent-built dash regresses movement | M | H | Movement tests in the check command; revert, do not patch over | Any movement AC goes red |
| Audio for S07-06 late | M | M | Placeholder SFX; integrate final in S08 | Not delivered by Wednesday |
| Engine or tool update mid-sprint | L | H | Pin engine and tool versions for the sprint | Update prompt appears |
| Verify queue backs up | M | M | Cap concurrent AL tasks at 2 | More than 2 AL tasks awaiting verify |

## Step 9: Velocity Calibration

Append one planned row to `production/sprints/velocity.md` now; the retrospective fills in actuals.

```
| Sprint | Dates | Planned h | Done h | Rate | Verify plan h | Verify actual h | AL/A/H tasks | Agent-traced defects | Notes |
|--------|-------|-----------|--------|------|---------------|-----------------|--------------|----------------------|-------|
| S07 | 11-09..11-13 | 26 | -- | -- | 9 | -- | 3/4/2 | -- | first sprint with AL tasks |
```

- Average completion under 80%: overcommitting; cut planned hours by the gap.
- Over 95%: room for one more Should or Could.
- Wild swings (50% then 95%): fix estimation before raising scope.
- Verify actual far above plan: your verify ratios are wrong; raise them before adding AL tasks.
- Completion under 75% for three sprints running: run `/gameforge:game-scope-check` before
  planning the next sprint.

## Solo Developer and Kanban Mode

For one or two people, sprint ceremonies can cost more than they return. Offer Kanban: Backlog ->
In Progress (WIP limit 2-3 solo, 3-4 for a pair) -> Verify -> Done, with a 15-minute weekly
review. Keep the Verify column: with agents it is where work piles up. Details, swimlanes and
tool options are in `${CLAUDE_SKILL_DIR}/references/planning-catalogs.md`.

## Working with AI Coding Agents

How to run the planned sprint when tasks are built with Claude Code or a similar agent.

- **Task card = prompt.** Hand the agent the card, the GDD sections it references and the
  project's `CLAUDE.md`. Fresh session per task; one long-lived session only for context-heavy bugs.
- **Check command first.** The card's "Done when" names a command that returns pass or fail
  (`npm run check`, a headless Godot test run, Unity `-runTests`, an Unreal automation filter).
  Ask the agent for evidence (test output, screenshot) before you accept "done".
- **One task, one commit.** Small diffs; when a change regresses, revert it rather than patching
  on top. Commits from agent sessions keep their co-author trailer so the retrospective can count them.
- **Keep the plan live.** At the end of each working session, update
  `production/session-state/active.md` (Now = current card, Next = next card, Blocked on) and the
  card's status in the sprint file.
- **Log what the retro will need.** Per task: build mode, actual verify hours, and whether a
  later defect traced back to it. Without this the AI lens in `/gameforge:game-retrospective` is
  guesswork.
- **Route the work.** Build loops go through `/gameforge:game-vibe-code`; generated art, audio or
  voice go through `/gameforge:game-ai-assets` so provenance is logged as it is made.

Prompt pattern for an AL task:
```
Implement task S07-03 from production/sprints/sprint-07.md. Read only the card, GDD §5.2 and §9,
and CLAUDE.md. Read knobs from data/tuning/dash.tres; no literals. Stop when AC-002-2 and
AC-002-4 pass under `godot --headless -s addons/gut/gut_cmdln.gd -gexit`, show me the output,
and list every file you changed. Do not touch anything listed under "Out of scope".
```

## Output

Write `production/sprints/sprint-NN.md` (ask before overwriting), following
`${CLAUDE_PLUGIN_ROOT}/templates/sprint-plan.md` with the AI columns below. Append the planned row
to `production/sprints/velocity.md` and update `production/session-state/active.md`.

```markdown
# Sprint 07 -- 2026-11-09 to 2026-11-13 (5 working days)
**Goal:** By the end of this sprint, dash is playable with cooldown, stamina cost and SFX so that
Friday's playtest can judge movement feel.
**Pillar:** Read the current | **Milestone:** M1 Prototype | **Goal check:** 4/5 testers chain two dashes unprompted

## Capacity
| Person | Role | Days | Raw h | Notes |
|---|---|---|---|---|
| Sam | code + design | 5 | 27 | solo; 30% buffer |

Raw 27 h - buffer 8 h - vibe-debt slot 3 h (S07-08) = **16 h plannable** for Must/Should/Could.

## Tasks
| ID | Task | Mode | Build h | Verify h | Owner | Depends | Tier | Done when | Status |
|---|---|---|---|---|---|---|---|---|---|
| S07-01 | Lock dash rules (§5.2) | H | 1 | 0.5 | Sam | -- | Must | §5.2 reviewed, knobs in §9 | Not started |
| S07-03 | Cooldown + stamina | AL | 2 | 2 | Sam | S07-01 | Must | AC-002-2, AC-002-4 green | Not started |
| S07-05 | Dash debug overlay | AL | 1 | 0.5 | Sam | S07-03 | Should | overlay toggles with F3 | Not started |
| S07-08 | Split player.gd (900 lines) | A | 2 | 1 | Sam | -- | Debt slot | tests green, no file > 300 lines | Not started |

## Won't (this sprint)
- Air dash -- needs the stamina tuning from Friday's playtest first.

## Dependency map
S07-01 -> S07-03 -> S07-05 ; S07-08 independent

## Risks
| Risk | Prob | Impact | Mitigation | Trigger |
|---|---|---|---|---|

## Definition of Done (every task)
- [ ] Its "Done when" check passes and the evidence is linked or pasted
- [ ] Diff read (or targeted review for AL tasks); nothing out of scope added
- [ ] No gameplay literals; knobs live in the tuning file
- [ ] Played in a build, not only tested
- [ ] AI-generated assets, if any, logged with provenance
- [ ] Status and verify hours updated in this file

## Carry-over from Sprint 06
| Task | Reason |
|---|---|
```

## Quality Criteria

- The goal is one evaluable sentence with a pillar, a milestone and a goal check.
- Every task is at most 8 hours total and has a "Done when" check.
- Every A or AL task has a separate verify estimate that follows the ratios (or calibrated ones).
- A vibe-debt slot exists and is filled with named tasks.
- Must stays at or under about 60% of plannable hours; the buffer is applied after estimating.
- Dependencies are mapped and blockers scheduled first; at least three risks have triggers.
- The plan cites velocity history when it exists and appends a row to `velocity.md`.
- Anyone, including an agent reading the file, can tell what to do first, second and third.

## Example Requests

| Request | Approach |
|---|---|
| "Plan our next two-week sprint." | Full Steps 0-9 and the output file. |
| "Solo dev, plan my week." | 1-week sprint, 5-8 cards, 30% buffer, one debt task, one or two risks. |
| "We keep missing commitments." | Step 9 first: planned vs done and verify plan vs actual over 3-5 sprints. |
| "Claude builds most of our code now. How do we plan?" | Step 4 and 5 in depth; set AL verify ratios; cap concurrent AL tasks. |
| "Our artist has two days this sprint." | Front-load art on those days, placeholders as mitigation, code after delivery. |
| "Turn the GDD milestone into tasks." | Pull §13 checks and §17 done criteria straight into "Done when". |
