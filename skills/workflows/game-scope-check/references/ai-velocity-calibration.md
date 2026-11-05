# Calibrating Velocity for AI-Agent Development

How fast does a team really go when Claude Code or another coding agent writes much of the code?
Faster at some work, not at all at other work, and the difference is where schedules break. This
file collects what the public evidence (as of November 2026) supports, gives starting
multipliers that are **explicitly assumptions**, and shows how to replace them with the project's
own measured numbers.

## 1. What the evidence supports

| Observation | Source |
|---|---|
| Brainstorming (81%) and code assistance (47%) are the top uses among the 36% of GDC 2026 survey respondents who use generative AI at work | GDC 2026 State of the Game Industry (Jan 2026) |
| The 2026 Vibe Jam gold winner was built with Claude Code in about two weeks (~27k lines, 188+ commits). The developer spent most of their own time brainstorming, planning and playing; ran 2-3 parallel agent sessions on separate subsystems; built the 3D map by hand in an editor; and scoped the game to about 5-10 minutes of play | Wccftech, 2026-07-13 |
| Simon Willison built the browser RTS *Battle Drones* through 321 agent commits, called it "actually fun to play," and said he reviewed "almost none of the code" | simonwillison.net, 2026-10-20 |
| A jam judge rated the best 2026 Vibe Jam games at about "3rd year student" level | levels.io, 2026-06-17 |
| Agents "are bad at knowing when the structure underneath needs to change"; repeated regeneration leaves code without "structural rationale" | Practitioner blog (Apr 2026); arXiv 2512.11922 |
| No well-sourced commercial hit attributable mainly to AI assistance was found; reporting shows tiny teams prototyping faster, more cloning, and fewer artist and junior roles | GameForge research brief (Nov 2026), citing Rest of World (2026) on team sizes |

Reading across these: agents compress the time to a first playable and the cost of tooling and
boilerplate. They do not remove the human-bound parts (deciding what is fun, building content
with intent, playtesting, polishing feel), and code nobody reviewed is deferred work, not finished
work.

## 2. Starting multipliers (assumptions, not data)

Use these only until the project has two sprints of its own measurements. Multiply a hand-written
estimate by the factor. They are GameForge planning assumptions derived from the observations
above, not measured industry figures.

| Work type | Starting multiplier with agents | Why |
|---|---|---|
| Boilerplate, scaffolding, menus, save plumbing, build scripts | 0.4 | Well-trodden code; agents excel |
| Debug tools, editors, sim harnesses, test hooks | 0.4 | Cheap with agents, and they pay back later |
| First prototype of one mechanic | 0.5 | Fast to playable; the design iteration is still human |
| Integration across systems, cross-system bugs | 1.0 | Context-heavy; structure problems surface here |
| Content with intent (levels, encounters, writing, art direction) | 1.0 | Human judgment bound |
| AI-generated assets used in the shipped game | 1.0, plus review and provenance time | Cleanup, retopology, consistency passes, disclosure |
| QA and playtesting | 1.2 | More code shipped faster means more surface to test |
| Polish, juice, feel | 1.0 | Bound by human iteration and playtest cycles |
| Review of agent-written code that ships | +0.2 of the code estimate | A cost hand-written code did not have |
| Multiplayer, netcode, server authority | 1.0 | Prototypes are fast; correct, secure netcode is not |

Example: a combat system estimated at 40 h by hand: 10 h boilerplate (x0.4 = 4), 15 h integration
(x1.0 = 15), 10 h feel and polish (x1.0 = 10), 5 h QA (x1.2 = 6), review (0.2 x 25 h of code = 5).
Calibrated: 40 h becomes 40 h, not 10 h. The speedup is real in the boilerplate row and absorbed
everywhere else. That is the usual result, and why "the agent will do it in an evening" scopes fail.

## 3. Measuring the project's real velocity

Keep a small log at `production/sprints/velocity.md`:

```markdown
| Feature | Work type split (est h) | Actual h | Ratio | Agent-written? | Reviewed? | Notes |
|---|---|---|---|---|---|---|
| Grapple | code 12, integ 8, polish 10 | 41 | 1.37 | mostly | yes | rope physics fought the camera |
| Pause menu | code 4, QA 1 | 3 | 0.60 | yes | yes | |
```

After two sprints, compute the median ratio per work type and replace the starting multipliers.
Use medians, not means; one disaster feature should not set the plan.

Git history supplies supporting evidence (all read-only):

```bash
git log --since="8 weeks ago" --oneline                          # throughput: commits per week
git shortlog -sn --since="8 weeks ago"                           # who (or what) is committing
git log --since="8 weeks ago" --oneline -i --grep="co-authored-by: claude"   # agent-assisted commits
git log --since="4 weeks ago" --oneline --grep="^fix"            # fix commits (conventional commits)
git log --since="4 weeks ago" --oneline --grep="^feat"           # feature commits
git diff --stat v0.3-milestone..HEAD                             # size of change since last milestone
git log --since="4 weeks ago" --name-only --pretty=format: -- src/   # files touched most often
```

Signals to report:
- **Fix-to-feature ratio** rising over time: rework is eating capacity.
- **Same files in most commits**: a hotspot that needs structure, not more prompts.
- **Commits up, finished features flat**: activity is not progress.
- **Estimate ratio above 1.5 for integration work**: plan the remaining integration at that ratio.

Commit counts measure activity, not value. Use them to ask questions, never as the velocity number
itself; the velocity number is finished, reviewed, tested features per sprint.

## 4. Vibe debt as a scope line

Treat unreviewed, untested agent code in shipping systems as unfinished work:
- Estimate a **stabilization budget**: review, tests, refactor of the worst hotspots. Starting
  assumption 10-20% of remaining code hours when the vibe-debt score (SKILL.md, Phase 6) is 4-7.
- At a score of 8 or more, schedule a stabilization sprint before any new feature. Every feature
  added on an unstable base costs more than its estimate.
- Prototype code promoted to production without a rewrite decision is the most common source.
  Decide explicitly: keep (and review), rewrite, or throw away.

## 5. Planning heuristics for agent-built projects

- Scope to the hook: one clear idea a player understands in seconds, playable in minutes, then
  expand only what playtests prove.
- Put the cheap-with-agents work (tools, editors, debug panels, sim harnesses) early; it lowers
  the cost of everything after it.
- Put the expensive human work (content, feel, playtesting) on the critical path in the schedule,
  because that is where it is.
- Re-run the scope check at every milestone and whenever a "quick" feature is proposed.
