---
name: "game-retrospective"
description: >
  Run a structured retrospective after a sprint, milestone, or project completion. Triggers
  when users mention retrospective, retro, post-mortem, lessons learned, "what went well",
  or "what could improve". DO NOT trigger for design reviews (use game-design-review) or
  playtesting (use game-playtest).
argument-hint: "[sprint-N or milestone-name or 'project']"
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
---

# AlterLab GameForge -- Retrospective Workflow

The most valuable artifact a game team produces is not the game. It is the knowledge of how
they built it. A retrospective is the structured extraction of that knowledge before it
evaporates. Without retrospectives, teams make the same mistakes across every sprint, every
milestone, every project. With them, each cycle is measurably better than the last.

Retrospectives are not complaint sessions. They are not blame-finding exercises. They are
diagnostic tools. The goal is to identify specific, actionable changes that will improve the
next cycle. A retrospective that produces vague sentiments ("communication could be better")
has failed. A retrospective that produces concrete actions ("daily 10-minute standups replace
weekly hour-long meetings, starting Monday, owned by [person]") has succeeded.

This workflow provides three retrospective formats scaled to the scope of what you are
reflecting on: sprint, milestone, or full project. Each format shares the same diagnostic
principles but differs in depth, time investment, and output detail.

### Purpose & Triggers

Use this workflow when:
- A sprint has ended and the next one has not started yet
- A milestone has been reached (vertical slice, alpha, beta, release)
- A project is complete and the team wants to capture lessons
- Velocity has dropped and nobody knows why
- Team morale is low and concrete diagnosis is needed
- Before starting a new project, to review lessons from the previous one
- A significant pivot or scope change just happened

Problems this solves:
- Repeating the same mistakes sprint after sprint
- No institutional memory -- lessons learned but never recorded
- Blame-oriented post-mortems that damage trust instead of improving process
- Action items from previous retros that nobody follows up on
- Teams that feel stuck but cannot articulate what is wrong
- Solo developers who skip reflection because "it's just me"

### Critical Rules

1. **Actions, not feelings.** Every discussion thread must end with a concrete action item
   or an explicit decision that no action is needed. "We should communicate better" is not
   an action. "Alice posts a daily update in the project channel by 10am" is an action.

2. **Owners, not teams.** Every action item has exactly one owner. "The team will do X" means
   nobody will do X. One name, one deadline. If nobody volunteers to own it, the action is
   not important enough to keep.

3. **Read the last retro first.** Before starting any retrospective, review the action items
   from the previous one. Did they happen? Were they effective? A retrospective that ignores
   its predecessors is doomed to repeat them.

4. **No blame, only systems.** When something went wrong, ask "what system or process allowed
   this to happen?" not "who caused this?" People operate within systems. Fix the system,
   not the person.

5. **Timebox ruthlessly.** Sprint retro: 15 minutes. Milestone retro: 45 minutes. Project
   post-mortem: 90 minutes maximum. Retros that drag on produce diminishing returns and
   train the team to dread them.

6. **Solo devs retro too.** Being a team of one does not excuse skipping reflection. Solo
   developer retrospectives use journal prompts and are even more important because there
   is nobody else to catch your blind spots.

### Workflow

---

🧠 **FORMAT 1: Sprint Retrospective (15 minutes)**

*Scope: One sprint (1-2 weeks). Quick, focused, immediately actionable.*

This is the lightweight format for regular sprint cadence. Three questions, three items
maximum per category, three action items maximum. The constraint is deliberate -- it forces
prioritization of what actually matters.

**Step 1: Review Previous Actions (2 minutes)**

```
PREVIOUS RETRO ACTIONS
-------------------------------------------------
Action                    | Owner   | Status
-------------------------------------------------
[action from last retro]  | [name]  | [Done/Partial/Not started]
[action from last retro]  | [name]  | [Done/Partial/Not started]
[action from last retro]  | [name]  | [Done/Partial/Not started]
-------------------------------------------------
Carry forward? [List any incomplete actions that are still relevant]
```

If previous actions were not completed, discuss why before generating new ones. Incomplete
actions are a signal, not just housekeeping.

**Step 2: Three Questions (8 minutes)**

```
SPRINT RETRO: [Sprint Name/Number]
Date: [date]
Sprint goal: [the single-sentence sprint goal]
Goal met: [Yes/No/Partially -- explain]

🟢 WHAT WENT WELL (max 3 items)
1. [specific positive outcome] -- Why it worked: [root cause of success]
2. [specific positive outcome] -- Why it worked: [root cause of success]
3. [specific positive outcome] -- Why it worked: [root cause of success]

🔴 WHAT DIDN'T GO WELL (max 3 items)
1. [specific problem] -- Root cause: [system/process failure, not person]
2. [specific problem] -- Root cause: [system/process failure, not person]
3. [specific problem] -- Root cause: [system/process failure, not person]

🔄 WHAT TO CHANGE (max 3 items)
1. [concrete change] -- Expected outcome: [measurable improvement]
2. [concrete change] -- Expected outcome: [measurable improvement]
3. [concrete change] -- Expected outcome: [measurable improvement]
```

**Step 3: Action Items (5 minutes)**

```
SPRINT RETRO ACTIONS
-------------------------------------------------
Action          | Owner   | Deadline      | Success Metric
-------------------------------------------------
[specific act]  | [name]  | [date]        | [how to measure]
[specific act]  | [name]  | [date]        | [how to measure]
[specific act]  | [name]  | [date]        | [how to measure]
-------------------------------------------------
```

---

🎯 **FORMAT 2: Milestone Retrospective (45 minutes)**

*Scope: A major milestone (vertical slice, alpha, beta, release candidate). Deeper
analysis with quantitative metrics and trend tracking.*

This format adds metrics, root cause analysis, and velocity data to the sprint retro
structure. Use it at natural project boundaries.

**Step 1: Goals vs. Results (10 minutes)**

```
MILESTONE RETRO: [Milestone Name]
Date range: [start] to [end]
Sprints covered: [N sprints]

GOALS VS. RESULTS
-------------------------------------------------
Goal                     | Target          | Actual          | Status
-------------------------------------------------
[milestone goal 1]       | [what success   | [what actually  | [Met/Missed/
[milestone goal 2]       |  looked like]   |  happened]      |  Exceeded]
[milestone goal 3]       |                 |                 |
-------------------------------------------------

HEADLINE: [One-sentence summary of the milestone outcome]
```

**Step 2: Quantitative Metrics (10 minutes)**

```
MILESTONE METRICS
-------------------------------------------------
Metric                        | Value    | Trend    | Assessment
-------------------------------------------------
Features planned              | [N]      | --       |
Features completed            | [N]      | [up/dn]  | [completion rate %]
Features cut during milestone | [N]      | [up/dn]  | [scope stability]
Bugs found                    | [N]      | [up/dn]  |
Bugs fixed                    | [N]      | [up/dn]  | [fix rate %]
Open bugs at milestone end    | [N]      | [up/dn]  |
Build stability               | [%]      | [up/dn]  | [% of builds that compiled clean]
Average sprint velocity       | [pts/h]  | [up/dn]  | [compared to previous milestone]
Scope change count            | [N]      | [up/dn]  | [features added/removed mid-milestone]
Team morale (1-5 self-report) | [avg]    | [up/dn]  |
-------------------------------------------------

VELOCITY TREND (sprints within this milestone):
  Sprint 1: [velocity]
  Sprint 2: [velocity]
  Sprint 3: [velocity]
  Trend: [accelerating / stable / decelerating / erratic]
```

**Step 3: Root Cause Analysis (15 minutes)**

For each significant problem identified, trace it to its root:

```
ROOT CAUSE ANALYSIS
-------------------------------------------------
Problem: [what went wrong]
  Why? [immediate cause]
    Why? [cause of the cause]
      Why? [deeper system issue]
        Why? [organizational or process root]
          Why? [fundamental assumption that failed]
Root cause: [the actual thing to fix]
Action: [specific change to prevent recurrence]
-------------------------------------------------
```

Apply the Five Whys technique. The first "why" is almost never the real cause. Keep asking
until you hit a systemic issue that, if fixed, would prevent the entire chain.

**Step 4: Action Items with Owners (10 minutes)**

```
MILESTONE RETRO ACTIONS
-------------------------------------------------
Priority | Action              | Owner   | Deadline | Success Metric
-------------------------------------------------
P1       | [urgent fix]        | [name]  | [date]   | [measurable]
P2       | [important change]  | [name]  | [date]   | [measurable]
P3       | [improvement]       | [name]  | [date]   | [measurable]
-------------------------------------------------

PROCESS CHANGES (effective immediately):
- [change to team process, with rationale]
- [change to tool usage, with rationale]

CARRY FORWARD TO NEXT MILESTONE:
- [systemic issue that needs ongoing attention]
```

---

🚨 **FORMAT 3: Project Post-Mortem (90 minutes)**

*Scope: Full project or major release. Comprehensive, publishable, preserves institutional
knowledge. Reference `@templates/post-mortem.md` for the full template.*

A project post-mortem is not just an internal exercise. It is a historical document. Done
well, it teaches the team's future selves and can be published to teach others. The best
post-mortems in the game industry (Gamasutra/Game Developer archives) are invaluable
precisely because they are honest.

**Step 1: Project Timeline (15 minutes)**

```
PROJECT TIMELINE: [Project Name]
Duration: [start date] to [end date] ([total months])
Team size: [average headcount]
Final scope: [features shipped / features originally planned]

PHASE TIMELINE:
-------------------------------------------------
Phase          | Planned     | Actual      | Delta   | Notes
-------------------------------------------------
Concept        | [dates]     | [dates]     | [+/- weeks] | [key events]
Pre-production | [dates]     | [dates]     | [+/- weeks] | [key events]
Production     | [dates]     | [dates]     | [+/- weeks] | [key events]
Alpha          | [dates]     | [dates]     | [+/- weeks] | [key events]
Beta           | [dates]     | [dates]     | [+/- weeks] | [key events]
Polish         | [dates]     | [dates]     | [+/- weeks] | [key events]
Launch         | [dates]     | [dates]     | [+/- weeks] | [key events]
-------------------------------------------------
Total delta: [how far off the original schedule was the final delivery]
```

**Step 2: Quantitative Results (15 minutes)**

```
PROJECT METRICS
-------------------------------------------------
Category         | Metric                      | Value
-------------------------------------------------
Scope            | Features planned (original) | [N]
                 | Features shipped             | [N]
                 | Features cut                 | [N]
                 | Features added mid-project   | [N]
                 | Net scope change             | [+/- %]
-------------------------------------------------
Quality          | Total bugs filed             | [N]
                 | Bugs fixed                   | [N]
                 | Ship-blocking bugs at launch | [N]
                 | Post-launch critical bugs    | [N]
-------------------------------------------------
Velocity         | Average sprint velocity      | [points/hours]
                 | Velocity trend               | [pattern]
                 | Estimation accuracy          | [actual / estimated %]
-------------------------------------------------
Team             | Peak team size               | [N]
                 | Average morale (1-5)         | [N]
                 | Team changes during project  | [N]
-------------------------------------------------
```

**Step 3: Critical Stage Analysis (30 minutes)**

Instead of the simple good/bad format, analyze what the team learned at each project stage:

```
CRITICAL STAGE ANALYSIS
-------------------------------------------------
STAGE: [e.g., Ideation]
  What we assumed: [beliefs going into this stage]
  What we learned: [reality that contradicted or confirmed assumptions]
  Key decision:    [the most consequential choice made in this stage]
  If we could redo: [what would change with current knowledge]
  Lesson:          [transferable principle for future projects]

STAGE: [e.g., Pre-Production]
  What we assumed: [...]
  What we learned: [...]
  Key decision:    [...]
  If we could redo: [...]
  Lesson:          [...]

[Repeat for: Production, Alpha, Beta, Polish, Launch]
-------------------------------------------------
```

**Step 4: Key Learnings (20 minutes)**

```
KEY LEARNINGS (limit: 5-7 lessons)
-------------------------------------------------
Lesson                          | Evidence              | Applies To
-------------------------------------------------
[transferable principle]        | [specific example]    | [future projects /
                                |                       |  team process /
                                |                       |  technical practice]
-------------------------------------------------
```

Each learning must be backed by specific evidence from the project. "Planning is important"
is not a learning. "Our estimates were 40% under actual time because we did not account for
engine migration overhead, which added 6 weeks to production" is a learning.

**Step 5: Publish Decision (10 minutes)**

```
PUBLISH ASSESSMENT
-------------------------------------------------
Audience:     [internal only / team blog / public post-mortem]
Sensitive items to redact: [list anything not for public consumption]
Value to others: [what would another team learn from reading this?]
Format:       [blog post / talk / internal wiki / all of the above]
-------------------------------------------------
```

### Facilitation Guide

**For Solo Developers:**

You are both the participant and the facilitator. Use these journal prompts:

```
SOLO DEV RETRO PROMPTS
-------------------------------------------------
1. What did I spend the most time on this sprint? Was that the right thing?
2. What task took way longer than expected? Why was my estimate off?
3. What am I avoiding? Why?
4. What tool, technique, or habit saved me time?
5. What would I tell a friend who is about to start the same sprint?
6. Am I still excited about this project? (Be honest. Waning excitement is
   a leading indicator of abandonment.)
7. What is the one thing I will do differently next sprint?
-------------------------------------------------
```

Write down the answers. Do not just think them. Written reflection is 3x more effective
than mental reflection because it forces specificity and creates a record.

**For Teams (2+ people):**

```
FACILITATION CHECKLIST
-------------------------------------------------
Before the retro:
  [ ] Review previous retro actions
  [ ] Collect metrics (velocity, bugs, scope changes)
  [ ] Send pre-retro survey (3 questions: well/not well/change)
  [ ] Book room/call, set timer for the chosen format

During the retro:
  [ ] Start with previous action review (accountability)
  [ ] Read pre-survey responses to seed discussion
  [ ] One person talks at a time (facilitator enforces)
  [ ] No interrupting, no defending, no explaining away
  [ ] Time-box each section (use a visible timer)
  [ ] Capture action items as they emerge, do not save for the end

After the retro:
  [ ] Distribute action items within 1 hour
  [ ] Add actions to sprint backlog or task tracker
  [ ] Schedule follow-up check on actions (mid-sprint)
  [ ] File the retro document in the project archive
-------------------------------------------------
```

### Anti-Patterns

Retrospectives fail when they exhibit these patterns:

- **The Blame Game:** Discussion centers on who made mistakes instead of what systems
  allowed mistakes. Fix: enforce the "no blame, only systems" rule. If blame starts,
  the facilitator redirects: "What process could have caught this earlier?"

- **The Action Graveyard:** Action items are generated but never reviewed. By the next
  retro, nobody remembers what was decided. Fix: Step 1 of every retro is reviewing
  previous actions. No exceptions.

- **The Feelings Forum:** The retro produces emotional catharsis but no concrete changes.
  "We felt rushed" is not an action. Fix: every thread ends with an action item or an
  explicit "no action needed" decision.

- **The Echo Chamber:** The same 2-3 problems appear every retro because root causes
  are never addressed. Fix: use Five Whys to dig past symptoms to systemic causes.

- **The Skipped Retro:** "We're too busy to retro." This is exactly when you need one most.
  A 15-minute sprint retro is never too expensive. The cost of skipping it compounds.

- **The Solo Exemption:** "I'm a solo dev, I don't need retros." Solo devs have the least
  external feedback and the most blind spots. They need retros more than teams do.

### Cross-References

- `@docs/collaboration-protocol.md` -- Communication norms for retro discussions
- `@docs/coordination-rules.md` -- Escalation paths for systemic issues found in retros
- `@docs/game-design-theory.md` -- Flow Theory context for velocity and morale analysis
- `@templates/sprint-plan.md` -- Sprint plan that consumes retro action items
- Workflow handoffs: follows any sprint or milestone, feeds into `game-sprint-plan`
  for the next cycle and `game-scope-check` if scope issues are identified

Part of the AlterLab GameForge -- Indie Game Development Skills suite.
