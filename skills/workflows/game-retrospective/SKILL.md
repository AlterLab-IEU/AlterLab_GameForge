---
name: game-retrospective
description: >
  Runs a sprint or milestone retrospective in the GDC post-mortem tradition: What Went Right, What
  Went Wrong, seven lenses including AI-assisted development, the Kill List and The One Thing, with
  actions fed into the next sprint. Use for "retro", "sprint retrospective", "milestone review",
  "kill list". Not for a whole-project post-mortem (use game-postmortem).
argument-hint: "[sprint-N or milestone name]"
effort: medium
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git log *), Bash(git shortlog *)
---

# AlterLab GameForge -- Sprint and Milestone Retrospective

Game development has the best post-mortem tradition in software. Game Developer magazine's
long-running Postmortem column (reprinted on Gamasutra) covered games such as *Thief: The Dark
Project*, *Baldur's Gate* and *Diablo II* in the same blunt shape: what went right, what went
wrong. No spin, no "learnings and opportunities". This workflow brings that format down to the
sprint and milestone, where the lessons are still cheap to act on.

It is not an agile ceremony. A corporate retro asks "what could we improve?" A game retro asks
"did we build the right game, and did we build it the right way?" One optimizes process; the
other interrogates the creative and technical decisions that decide whether the game is worth
shipping. In 2026 it also asks a third question: **what did the coding agents actually do for us,
and what did they cost?** Teams that cannot answer that with numbers end up either over-trusting
agents or abandoning them on a hunch.

## When to Use / When Not To

Run it when a sprint ends, when a milestone lands (vertical slice, alpha, beta), after a pivot or
a big scope cut, when the game is "fine but not fun" and nobody can say why, or when development
feels stuck.

| Instead of this skill... | Use |
|---|---|
| Whole-project or canceled-project post-mortem | `/gameforge:game-postmortem` |
| Planning the next sprint from these actions | `/gameforge:game-sprint-plan` |
| Project scope has outgrown the schedule | `/gameforge:game-scope-check` |
| Analyzing a playtest session itself | `/gameforge:game-playtest` |
| Reviewing the design document | `/gameforge:game-design-review` |

## Critical Rules

1. **GDC format, not agile format.** "What Went Right / What Went Wrong / Lessons", not "went
   well / didn't go well". Something either went right or it went wrong. No fence-sitting.
2. **Game-specific lenses.** "Did we communicate well?" is a process question. "Did the core loop
   deliver the intended experience?" is a game question. This workflow asks the second kind.
3. **The Kill List is mandatory.** The discipline to cut is the discipline to ship.
4. **"The One Thing" is mandatory.** One specific, actionable sentence. If you cannot pick one,
   you have not thought hard enough.
5. **Evidence over feelings.** "Combat felt off" is not a finding. "Testers disengaged from
   encounters longer than 45 seconds" is. Back findings with playtest notes, data or incidents.
6. **Read the last retro first.** Were its actions done? A problem that appears twice is not an
   awareness problem; it is an execution problem, and the action plan changes.
7. **Systems, not people.** "The build broke three times" leads to "there was no pre-merge check",
   not to a name.
8. **Measure AI use; do not guess it.** Count agent tasks, verify hours and defects traced to
   agent code from the sprint file and git. Opinions about agents are not findings.
9. **Solo developers do this too.** With no colleagues, this document is the external feedback
   loop. Write it down; do not just think it.

## Step 0: Gather Evidence

Read when present:
- The sprint plan `production/sprints/sprint-NN.md` (goal, tasks, build mode, verify hours) or the
  milestone definition in `production/milestones/`.
- The previous retro (`production/sprints/sprint-NN-retro.md` or `production/milestones/*-retro.md`)
  and its actions.
- `production/sprints/velocity.md`, `production/session-state/active.md`.
- Playtest notes (`tests/playtest/`, `/gameforge:game-playtest` reports), the bug list or open issues.
- The AI asset provenance log, if the project keeps one.

Run for the period (adjust dates):
```
git log --since=2026-11-09 --until=2026-11-14 --oneline
git log --since=2026-11-09 --until=2026-11-14 --oneline -i --grep="Co-Authored-By: Claude"
git shortlog -sn --since=2026-11-09 --until=2026-11-14 HEAD
git log --since=2026-11-09 --until=2026-11-14 --oneline -i --grep="revert"
```
The second command counts commits made with Claude Code's default co-author trailer; adjust the
pattern for other agents or if the team turned trailers off. How to trace defects to agent code
and fill the AI metrics is in `${CLAUDE_SKILL_DIR}/references/ai-lens.md`; read it before Lens 7.

Then ask **one** AskUserQuestion: scope (**Sprint, about 15 minutes** / Milestone, about 45
minutes); solo or team; and whether playtest data exists for this period. For team retros,
facilitation scripts are in `${CLAUDE_SKILL_DIR}/references/facilitation.md`.

## The Seven Lenses

Every retro passes through all seven. Not every lens produces findings every time; you still look.

**Lens 1: Core loop validation.** Did the loop deliver the intended experience, and was it fun
before content and progression were layered on?
- Strip away content and progression: is the verb set satisfying for 10 minutes in a test room?
- Where does the player feel agency, and where constrained? Are those the right places?
- Did the loop's rhythm drift during implementation? Is one cycle the right length for the session target?
- Reference: *Celeste* began as a four-day PICO-8 jam game (2015); the movement was proven long
  before the full game existed. Did you prove your loop before building content on it?

**Lens 2: Pillar integrity.** Did the pillars hold, or drift? Was drift deliberate evolution or
unconscious erosion?
- For each pillar, name a decision this period where it changed the outcome. None means it is not operational.
- Name one moment a pillar was compromised and why (schedule, tech limit, a better idea).
- Did an implicit pillar emerge that the team keeps prioritizing? Name it now.

**Lens 3: Scope tier review.** Did Must / Should / Could protect the right work?
- How many Musts shipped, were downgraded, or cut? Would you make each downgrade again?
- Which Should or Could ate more time than planned? Was it worth it?
- Planned vs done hours, and where the gap came from (estimates, verification, interruptions).
- Reference: Jason Schreier's *Blood, Sweat, and Pixels* (2017) describes the years Eric Barone
  spent building *Stardew Valley* alone, with no outside scope authority, and the toll it took.
  Scope discipline is also self-care.

**Lens 4: Flow state analysis.** Where did players enter flow, and where did they bounce?
- Sketch the intended challenge curve for a session; overlay what testers did (retries, long
  sessions, audible reactions vs phone checks, quits).
- Name the flow breakers: menus mid-action, unskippable text, loads at tension peaks.
- Is the difficulty a curve or a cliff? Are the walls intentional gates or friction? Frustration
  is acceptable only when every failure teaches something.

**Lens 5: Technical debt audit.** Which shortcuts are now blocking progress, and which were worth it?
- Top five shortcuts: cost to fix vs cost of not fixing over the next milestone.
- Which debt bought a deadline that mattered (good debt)? Which now causes bugs (bad debt)?
- Does debt cluster in one system? That system needs a redesign, not another patch.
- Bus factor: if the one person who understands the save system leaves, what breaks?

**Lens 6: Ludonarrative check.** Where did mechanics and story reinforce each other, and where did
they contradict?
- Three moments where they aligned; what made them work?
- Any contradiction ("time is running out" while side quests are farmable for hours)?
- What do the mechanics alone say about the game's themes? Is that intended?
- Reference: Clint Hocking coined "ludonarrative dissonance" in a 2007 essay on *BioShock*.
  *Disco Elysium* shows the opposite pole: its skills speak as voices in the dialogue itself.

**Lens 7: AI-assisted development.** What did coding and asset agents do for this period, and at
what cost? Fill the metrics block, then answer:
- Which task types did agents land first time? Which needed rework, and why (vague card, missing
  check, invented rules, wrong architecture)?
- Review cost: verify hours planned vs actual by build mode. Were any agent commits merged unreviewed?
- Defects traced to agent-written code: how many, how severe, caught by checks or only by play?
- Vibe debt added vs paid this period.
- Provenance: is every generated asset logged (`/gameforge:game-ai-assets` keeps the log)? Which
  placeholders are approaching a ship milestone?
- What single change to cards, checks or prompts would have prevented the worst agent issue?

```
AI USE -- Sprint 07
Tasks done (agent-led / assisted / hand):     3 / 4 / 2
Commits with agent trailer:                   18 of 31   Reverts: 2
Verify hours (planned / actual):              9 / 13     AL verify ratio: 1.4x build
Reopened agent tasks:                         1 (S07-03: stamina drained twice per dash)
Defects traced to agent code:                 2 (1 Major, 1 Minor); caught by play 1, checks 1
Out-of-scope additions rejected:              2
Vibe debt (added / paid):                     3 / 2
Generated assets logged:                      6 of 6; placeholders due for replacement by M2: 2
Did well: UI wiring, debug overlay, save round-trip tests
Did poorly: tuning (picked values without playing), physics edge cases
```

Context, not a target: in the GDC 2026 State of the Game Industry survey, 36% of respondents used
generative AI at work and 52% said it is harming the industry. Players, stores and your own team
care how the game is made, so track AI use honestly; do not use these numbers to judge your team.

## The Kill List

Review every feature, system or content piece cut this period. Cutting half-built work is harder
than cutting ideas because the sunk cost is visible; that is why it gets its own section.

```
KILL LIST: [Sprint/Milestone]
| Feature cut | Stage when cut (idea/design/in progress/nearly done) | Reason | Correct call? |
|-------------|------------------------------------------------------|--------|---------------|

Cuts that were correct:      [feature] -- right because [reason]
Cuts that were too late:     [feature] -- should have gone at [stage]; cost of delay [hours]
Cuts that were premature:    [feature] -- evidence it deserved to survive: [...]
Should have been cut:        [feature] -- shipped/kept because [inertia/sunk cost/attachment]
Agent-added, never asked for: [feature] -- kept or removed, and why
The earlier cut:             if we started over, we would cut [feature] on day one because [...]
The fiercer protection:      we should have protected [feature] harder because [...]
```

If nothing was cut, ask whether the scope was too safe or whether cuts happened silently.

## "The One Thing"

The single most important thing we learned is: ____________________

- **Specific:** "playtest the core loop in isolation before building content on it", not
  "communicate better".
- **Actionable:** it changes a specific behavior next sprint or milestone.
- **Honest:** the comfortable lesson and the true lesson are rarely the same.

Good: "We should have cut crafting in week two; it served no pillar and took 30% of implementation
time." Good: "Agent-led tasks without edge cases on the card were reopened three times out of four;
every AL card now copies the relevant §7 edge cases."
Bad: "We need to plan better." "We should have had more time."

## Sprint Retro Format

Write to `production/sprints/sprint-NN-retro.md`. The milestone format (goals vs reality, full
lens analysis, five right / five wrong, process changes) is in
`${CLAUDE_SKILL_DIR}/references/milestone-format.md`; read it for milestone retros. It extends the
shared `${CLAUDE_PLUGIN_ROOT}/templates/post-mortem.md` (goals vs results, timeline, metrics,
action items), so milestone retros and the project post-mortem line up section for section.

```markdown
# Sprint 07 Retrospective -- 2026-11-09 to 2026-11-13
**Goal:** [the sprint goal] | **Goal met:** Yes / No / Partly -- [one sentence why]
**Done:** 22 of 26 planned hours (85%) | **Verify:** 13 h actual vs 9 h planned

## Previous actions
| Action from last retro | Done? | If not, why |
|---|---|---|

## Lenses (findings only; "no change" is a valid entry)
- **Core loop:**
- **Pillars:**
- **Scope:**
- **Flow:**
- **Tech debt:**
- **Ludonarrative:**
- **AI-assisted development:** [metrics block + answers]

## What went right (max 3)
1. [Specific] -- why: [root cause of success]

## What went wrong (max 3)
1. [Specific] -- root cause: [system or decision, not a person]

## Kill List
[table]

## The One Thing
[one sentence]

## Actions (max 3)
| Action | Owner | Due | How we will know it worked |
|---|---|---|---|
```

## Working with AI Coding Agents

How to run the retro itself with Claude, and what the agent must not decide.

- **Let the agent assemble the evidence.** It can read the sprint file, previous retro, velocity
  log and git history, fill the AI metrics block, list cut and carried-over tasks, and draft a
  timeline. That saves the first ten minutes of every retro.
- **Keep the judgments human.** Whether something went right or wrong, which cut was correct,
  and The One Thing come from the people who played and built the game. An agent's draft of
  "what went wrong" is a prompt for discussion, not a finding.
- **Do not let the agent grade its own work unchallenged.** Defects traced to agent code and
  reopened agent tasks come from the bug list and the sprint file, not from the session that
  wrote the code.
- **Turn lessons into guardrails.** The best AI-lens actions change inputs: a card field, a
  check added to the check command, a line in `CLAUDE.md`, a required edge-case list. Feed them to
  `/gameforge:game-sprint-plan` and, for the build loop, `/gameforge:game-vibe-code`.
- **Size the vibe-debt slot.** Report debt added vs paid so the next plan can size its paydown
  slot from data.

Prompt for the evidence pass:
```
Read production/sprints/sprint-07.md, the previous retro and velocity.md, and run the git log
commands from the retro skill for 2026-11-09..2026-11-14. Fill the AI USE block and list:
tasks done / carried / cut, reopened tasks, reverts. Do not judge what went right or wrong.
```

## Close-Out

1. Write the retro file (ask before overwriting).
2. Fill the actuals in the sprint's row of `production/sprints/velocity.md`: done hours, rate,
   verify actual, agent-traced defects.
3. Put the actions into the next sprint's backlog (carry-over section of the next sprint file, or
   hand them to `/gameforge:game-sprint-plan`).
4. Update `production/session-state/active.md`: **Decisions** gets The One Thing; **Next** gets
   the top action.
5. If the same problem appeared in two consecutive retros, or completion has been under 75% for
   three sprints, recommend `/gameforge:game-scope-check` or a milestone-level conversation with
   `/gameforge:game-producer`.

## Quality Bar

- Every lens was considered, including Lens 7 with numbers, not impressions.
- Findings cite evidence: playtest notes, data, task IDs or commits.
- The Kill List exists, including agent-added features nobody asked for.
- The One Thing is specific, actionable and honest.
- At most three actions for a sprint (five for a milestone), each with an owner, a date and a
  success measure.
- No finding blames a person.
- The previous retro's actions were reviewed first.
