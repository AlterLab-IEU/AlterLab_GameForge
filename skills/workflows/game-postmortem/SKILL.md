---
name: game-postmortem
description: >
  Runs a data-driven post-mortem for a shipped, canceled or major-phase project: git history, sprint
  and retro records, scope and quality trends, and what AI agents contributed and cost per
  milestone, ending in owned lessons archived to production/milestones/. Use for "post-mortem",
  "project review", "what did we learn". Not for a single sprint (use game-retrospective).
argument-hint: "[project, or milestone name such as alpha]"
effort: high
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(git log *), Bash(git rev-list *), Bash(git shortlog *), Bash(git tag *), Bash(gh issue list *), Bash(sort *), Bash(uniq *), Bash(head *)
---

# AlterLab GameForge -- Project Post-Mortem

Every shipped game has a story behind it that is worth more to the next project than the game
itself. The post-mortem is where that story is extracted, structured and turned into reusable
knowledge. Without one, the team repeats the same mistakes on the next project, not because it is
incompetent but because memory is selective and unstructured reflection drifts toward narratives
instead of patterns. The GDC Vault and decades of Game Developer magazine postmortems exist
because studios learned this the hard way.

A good post-mortem is not a blame session and not a victory lap. It is a structured data
extraction: facts first, then reflection, then patterns, then a small number of lessons that
each change something concrete.

Projects built with coding agents add a question earlier post-mortems never had to answer: **what
did the agents actually contribute, and what did they cost?** This workflow answers it per
milestone, with numbers, so the next project can decide where agents belong.

## Relationship to game-retrospective

`game-retrospective` handles sprints and milestones: short cycles, immediate actions for the next
sprint. The post-mortem covers a whole project or a major phase and looks for systemic patterns
across those cycles. It ingests every retro it can find.

- "What should we do differently next sprint?" -> `/gameforge:game-retrospective`
- "What should we do differently next project (or next phase)?" -> this skill

## When to Use / When Not To

Use after a launch, a cancellation, a major milestone (vertical slice, alpha, beta, 1.0), before
starting a new project (to retrieve and apply the last post-mortem), or when a new team member
asks "what went wrong last time?"

| Instead of this skill... | Use |
|---|---|
| A single sprint or milestone retro | `/gameforge:game-retrospective` |
| Reviewing the design document | `/gameforge:game-design-review` |
| Live-game metrics and KPIs after launch | `/gameforge:game-analytics-setup` |
| Starting the next project with these lessons | `/gameforge:game-start` |

## Critical Rules

1. **No blame, only patterns.** Attribute problems to processes, decisions and conditions, never
   to people. "The rendering pipeline had no review gate" is actionable. "Dave wrote bad shaders"
   is toxic and useless. The same applies to tools: "the agent broke it" is not a root cause.
2. **Data before feelings.** Collect the quantitative record (commits, velocity, scope, bugs, AI
   use) before reflection. Numbers anchor the conversation and prevent revisionist memory.
3. **Equal weight to successes and failures.** Analyzing only failures breeds helplessness; only
   successes, blind spots.
4. **Concrete over abstract.** "Communicate better" is not a lesson. "Hold a 15-minute art/code
   sync at the start of each sprint" is. Every lesson produces an action with an owner and a check.
5. **AI use is measured per milestone.** Agent share, review cost, defects traced to agent code
   and vibe debt come from records, not from impressions.
6. **Archive it where the next project will find it.** `production/milestones/` and a pointer in
   the project's `CLAUDE.md` or design index. A post-mortem nobody rereads has zero value.
7. **If you publish, be consistent.** A public post-mortem's statements about AI use must match
   the game's store disclosures and credits.

## Phase 0: Scope and Setup

Ask **one** AskUserQuestion (defaults in bold):
1. Scope -- **whole project** / a phase or milestone (name it) / canceled project.
2. Audience -- **internal only** / team blog / public post-mortem or talk.
3. Team or solo (decides whether Phase 2 is a group session or self-reflection).

Define the period's start and end (first commit or phase start; tag, release date or cancellation).
Use tags as milestone boundaries where they exist.

## Phase 1: Data Collection

Run the commands below for the period, then read the project records. Command recipes for cadence,
crunch detection, churn and per-milestone agent share, with how to interpret each, are in
`${CLAUDE_SKILL_DIR}/references/data-collection.md`; read it before running Phase 1.

```
git rev-list --count HEAD
git log --reverse --format="%ad %h %s" --date=short | head -1
git log -1 --format="%ad %h %s" --date=short
git tag -l --sort=creatordate --format="%(refname:short) %(creatordate:short)"
git shortlog -sn --no-merges HEAD
git log --format= --name-only | sort | uniq -c | sort -rn | head -20
git rev-list --count -i --grep="Co-Authored-By: Claude" <tagA>..<tagB>
gh issue list --state closed --limit 200
```

Read when present:
- Every sprint plan and retro in `production/sprints/`, and `production/sprints/velocity.md`.
- Milestone definitions and milestone retros in `production/milestones/`.
- `design/gdd.md` (original vs current version via its change log), `design/pillars.md`,
  `design/systems-index.md`.
- Playtest reports, the bug tracker, store reviews and analytics if shipped.
- The AI asset provenance log and the store AI disclosure text, if any.
- `production/session-state/active.md` and decisions recorded there.

Quantitative picture to assemble:
- Duration (planned vs actual), commit cadence (crunch periods, dead zones), contributors.
- Churn hotspots (most-changed files are complexity or instability hotspots).
- Velocity history: planned vs done per sprint, estimation bias.
- Scope: features planned, added after scope lock, cut, deferred.
- Quality: bugs found vs fixed over time, bugs at ship, where they were caught.
- AI use per milestone (next section).

For solo developers, also read commit messages, `TODO`/`FIXME` density and personal dev logs.

## Phase 2: Reflection

Structured questions. For every answer ask "what specific change would address this next time?"
until a concrete action appears. In team sessions collect answers individually first.

**What went well (preserve and amplify)**
1. Which single decision had the most positive impact?
2. Which tool, process or practice would you use again without hesitation?
3. Which risk was identified early and mitigated?
4. Which feature shipped closest to the original vision, and why?
5. Where did agents (if used) clearly pay for themselves?

**What went wrong (understand and fix)**
1. Which decision caused the most rework?
2. Which problem was visible early but addressed late?
3. Where did hand-offs between disciplines or people break down?
4. Which feature drifted furthest from the design, and what caused the drift?
5. Which deliberate shortcuts (including accepted agent code) cost more than they saved?

**What was surprising (learn from the unexpected)**
1. Which task took dramatically longer or shorter than estimated, and why?
2. Which player or tester feedback was most unexpected?
3. Which tool or technology behaved differently than expected, better or worse?
4. Which external event most affected scope or timeline?
5. Which assumption turned out to be wrong?

## Phase 3: Pattern Analysis

Cross-reference Phase 1 data with Phase 2 reflections. Incidents are symptoms; patterns are causes.

- **Estimation:** consistently under or over? By what factor? Per discipline? Did accuracy
  improve over the project?
- **Dependencies:** which hand-offs caused delays? Recurring bottlenecks (always waiting on art,
  on review, on the one person who knows the build)?
- **Scope:** feature creep after scope lock; proactive vs reactive cuts; cut features creeping back.
- **Quality:** lag between introducing and finding bugs; consistently buggy systems and why;
  which gates (tests, review, playtest) caught what, and what reached players.
- **Communication:** decisions documented or verbal? How often reversed? Information silos?
- **AI-assisted development:** see below.

A problem that appears in three consecutive sprint retros and was never resolved is a systemic
failure, not a sprint issue. Call it out by name with the retro dates.

## AI-Assisted Workflow

**Build the per-milestone AI ledger.** One row per milestone, from velocity.md, milestone retros,
git trailers and the bug tracker:

```
| Milestone | Agent-trailer commits / total | Tasks AL / A / H | Verify ratio (AL) | Reopen rate | Agent-traced defects (Crit/Maj/Min) | Escape stage (checks/play/players) | Vibe debt added / paid |
|-----------|-------------------------------|------------------|-------------------|-------------|-------------------------------------|------------------------------------|------------------------|
| Prototype | 210 / 260 | 34 / 12 / 9 | 0.6x | 22% | 1 / 6 / 14 | 30 / 50 / 20% | 18 / 4 |
| Vertical slice | 140 / 230 | 15 / 25 / 20 | 1.1x | 11% | 0 / 3 / 9 | 55 / 40 / 5% | 9 / 12 |
```

Then answer, with evidence:
- **What agents did well:** task types that landed first time (for example tools, UI wiring,
  tests, data plumbing). Name the tasks.
- **What agents did poorly:** task types reopened or traced to defects (for example tuning, edge
  cases, architecture changes, platform-specific behavior). Name the tasks.
- **Review cost:** total verify hours vs build hours per mode; unreviewed merges and what they cost later.
- **Defects traced to agent code:** count, severity, where caught. Defects that reached players
  are the headline number.
- **Vibe debt:** when it peaked, what paying it down cost, what it blocked.
- **Workflow changes:** which guardrails (card fields, check commands, `CLAUDE.md` rules, review
  gates) were added, and whether the numbers moved after them.
- **Assets and disclosure:** was every generated asset logged (the `/gameforge:game-ai-assets`
  provenance log)? Did the shipped store disclosure
  (Steam's rules of 2026-01-16 cover shipped AI content including localization and marketing;
  code assistants are exempt) match the log? Any placeholders that nearly shipped?

If the project kept no records of agent use, say so plainly, estimate nothing, and make "record
build mode and defect origin from day one" a lesson.

**Using an agent to run this post-mortem.** Delegate the data pass: running the git recipes,
reading every sprint file and retro, building the velocity and AI ledgers, listing recurring
retro themes with dates. Keep human: Phase 2 answers, root-cause judgments, which lessons matter,
and anything that will be published.

**Industry context, cited, used sparingly.** In the GDC 2026 State of the Game Industry survey,
36% of respondents use generative AI at work and 52% say it is harming the industry. Readers of a
public post-mortem will ask how AI was used; answer with the ledger, not adjectives.

## Phase 4: Lesson Extraction

```
LESSON
Pattern observed: [what happened, with the supporting data]
Root cause:       [why, traced to a process, decision or condition]
Impact:           [cost in time, quality, morale or scope]
Lesson:           [one sentence]
Action:           [specific change for the next project or phase]
Owner:            [role]
Verification:     [how we will know the change happened and worked]
```

Aim for 5-10 strong lessons, not 20 shallow ones. Categorize each: process, technical, design,
production, communication, AI-assisted development. Each should be something the team can point
to in six months and say "we changed this because of the post-mortem, and here is what happened".

Example of an AI-assisted development lesson:
```
Pattern observed: 14 of 21 agent-traced defects in the prototype were movement and physics edge
                  cases; 12 were found only by play. Agent-led cards listed no edge cases.
Root cause:       Cards referenced GDD §5 rules but not §7 edge cases; the check command had no
                  physics simulation tests.
Impact:           ~30 h of rework across S03-S06; two playtests spent on known bugs.
Lesson:           Agents implement the rules they are given and nothing at the boundaries.
Action:           Every agent-led card copies its §7 edge cases; physics sim tests join the check
                  command before any agent touches movement.
Owner:            Lead developer
Verification:     Agent-traced edge-case defects per milestone, tracked in the AI ledger.
```

## Phase 5: Actions and Archival

```
ACTION ITEM
ID:           PM-[project]-[nn]
Lesson:       [reference]
Action:       [specific change]
Owner:        [role]
Deadline:     [ideally before the next project or phase starts]
Status:       Not started / In progress / Done
Verification: [how to confirm]
```

Archive:
- Write `production/milestones/postmortem-<project-or-phase>.md` (ask before overwriting),
  following `${CLAUDE_PLUGIN_ROOT}/templates/post-mortem.md` extended with the sections below.
- Add a one-line pointer in the project's `CLAUDE.md` or design index so the next session and the
  next project find it.
- Lessons that change how agents should work (card fields, checks, forbidden patterns) go into the
  project's `CLAUDE.md` or its agent instructions, with the user's approval, and into the build
  loop the next project runs with `/gameforge:game-vibe-code`.
- Update `production/session-state/active.md`: **Decisions** gets the top three lessons.
- For a public version, read `${CLAUDE_SKILL_DIR}/references/gdc-format.md`; it has the long-form
  GDC-style format and a publishing checklist.

## Output Format

```markdown
# Post-Mortem: [Project or phase]
**Period:** [start] to [end] ([n] weeks) | **Team:** [size or solo] | **Scope:** project / phase: [name]
**Outcome:** shipped [date, platforms] / canceled [date] / milestone reached [name]
**Audience:** internal / blog / public

## Executive summary
[3-5 sentences: what was built, whether it met its goals, the top three lessons]

## Goals vs results
| Goal | Target | Actual | Status |
|---|---|---|---|

## Quantitative overview
| Metric | Planned | Actual | Delta |
|---|---|---|---|
| Duration | | | |
| Features (T1 / T2 / T3) | | | |
| Features added after scope lock / cut | | | |
| Average sprint completion | | | |
| Bugs at ship (by severity) | | | |
| Agent-trailer commits / total | -- | | |

## Timeline of key events
| Date | Event | Impact |
|---|---|---|

## What went well
| Item | Root cause | Reproducible? |
|---|---|---|

## What went wrong
| Item | Root cause | Preventable? |
|---|---|---|

## Surprises
1. [Unexpected finding and what it revealed]

## Pattern analysis
### Estimation  ### Dependencies  ### Scope  ### Quality  ### Communication
[Analysis with data for each]

## AI-assisted development
[AI ledger table per milestone]
- Did well: ...
- Did poorly: ...
- Review cost: ...
- Defects traced to agent code: ...
- Vibe debt: ...
- Assets and disclosure: ...

## Lessons
### Lesson 1: [title]
[Lesson block]

## Action items
| ID | Action | Owner | Deadline | Status | Verification |
|---|---|---|---|---|---|

## Appendix
- Sprint and milestone retro index (dates, One Things)
- Commit cadence and churn hotspots
- Bug trajectory
```

## Quality Criteria

- Quantitative data is present and supports the qualitative findings.
- At least three "went well" and three "went wrong" findings, each with evidence.
- At least two systemic patterns, with the retros or data that show them.
- An AI-assisted development section with a per-milestone ledger, or an explicit statement that
  no records exist and a lesson to fix that.
- Every lesson has an action, an owner, a deadline and a verification.
- No blame language aimed at people (or at tools as a stand-in for people).
- The document is archived in `production/milestones/` and pointed to from the project.
- Uncomfortable findings are stated, not softened.

## Example Requests

| Request | Approach |
|---|---|
| "We shipped. Let's do a post-mortem." | All phases; full git and sprint history; lessons for the next project. |
| "Alpha is done. What did we learn?" | Phase-scoped to project start through the alpha tag; lessons applied before beta. |
| "This project was canceled. Anything salvageable?" | Weight Phase 3; honest but constructive; salvage list of reusable systems and tools. |
| "Solo dev, first game finished." | Phase 2 as self-reflection; cadence shows work habits and crunch; personal process actions. |
| "We built most of it with Claude Code. Was it worth it?" | AI ledger per milestone in depth; compare reopen and defect rates across modes and over time. |
| "Starting a new project. What did the last post-mortem say?" | Read the archived file, check which actions were done, feed open lessons into `/gameforge:game-start`. |
