# Planning Catalogs: Dependencies, Risks, Kanban

Read for team sprints with art, audio and QA hand-offs, when building the risk register, or when
the user wants Kanban instead of sprints.

## Dependency chains by discipline

```
Design -> Art
  Designer defines enemy behavior         -> artist creates sprite or model
  Level designer creates layout            -> environment artist dresses the space

Art -> Code
  Character sprites or rigs delivered      -> programmer integrates animation states
  UI mockups approved                      -> programmer implements interactive UI

Design -> Code
  Designer specifies a mechanic (+ checks) -> programmer or agent implements the system
  Designer tunes values                    -> programmer exposes knobs in the tuning file

Audio -> Code
  Sound designer delivers SFX              -> programmer wires audio events

Code -> QA
  Feature complete                         -> QA verifies acceptance checks
  Bug fixed                                -> QA confirms fix and runs regression

Any generated asset -> Provenance
  Asset generated                          -> logged (tool, version, prompt, human edits, license)
```

Rules:
- Placeholders unblock integration; schedule the final-asset swap as its own task.
- Art and audio tasks with external contributors go first in the sprint; their slack is lowest.
- A task blocked by another person's task needs a fallback written on the card.
- The critical path is the longest chain of blocking tasks. If it exceeds the sprint, split the
  feature across sprints or rescope.

## Risk catalog

**Technical**
- Never built this system before -> spike early in the sprint.
- Engine or tool update might break things -> pin versions for the sprint.
- Unknown performance on target hardware -> mid-sprint profiling session on the weakest device.
- Cross-browser or cross-device behavior (web) -> test on Safari/iOS and a mid-range Android device.

**Content**
- Assets not ready when code needs them -> placeholders; integrate final later.
- Level design needs several art passes -> blockout first, art pass next sprint.

**Scope**
- Stakeholder feedback mid-sprint -> change-freeze date inside the sprint.
- A Must is harder than estimated -> name in advance which Should gets cut.

**Team**
- Key person unavailable -> no single-person bottleneck on the critical path.
- New member ramp-up -> pair with a senior, halve their capacity estimate.

**Agent-specific**
- Agent-built change regresses a system -> the check command covers it; revert first.
- Verify queue backs up -> cap concurrent agent-led tasks.
- Agent adds unrequested features -> out-of-scope list on every card; reject in review.
- Usage limits or API spend run out mid-sprint -> note the limit; keep H fallbacks for Musts.
- Refusal on clone-shaped tasks -> phrase tasks as the game's own rules.

**Format**

| Risk | Probability | Impact | Mitigation | Trigger (when to act) | Owner |
|---|---|---|---|---|---|

## Scope tier proportions

| Tier | Target share | Why |
|---|---|---|
| Must | at most 60% | Leaves room for the unexpected without touching the goal |
| Should | about 25% | Real value, first thing to cut under pressure |
| Could | about 15% | Polish and stretch; cut first |
| Won't | 0% | Written down so it is not relitigated mid-sprint |

These are rules of thumb. If Must regularly exceeds 60%, the team is overcommitting on critical
work. If Could creeps above 15%, polish is happening before foundations are solid.

## Scope-check trigger

When completion stays under 75% for three or more consecutive sprints, scope has probably grown.
Before the next planning session:
- Run `/gameforge:game-scope-check`.
- Compare the current feature list against the vertical-slice definition.
- List features added since the plan without a matching cut.
- Make an explicit cut or keep decision for each.

## Kanban mode

**When to prefer it:** a solo developer or pair; unpredictable task sizes (R&D-heavy
prototyping); maintenance or post-launch phases where work arrives continuously; when planning
consistently takes longer than it saves.

**Board**
```
Backlog -> Ready (has a "Done when" check) -> In Progress (WIP 2-3 solo / 3-4 pair) -> Verify -> Done
```
- The WIP limit is the discipline. Raising it to fit more work defeats the point.
- Keep **Verify** as its own column. With agents, work piles up there; a full Verify column means
  stop starting and start verifying.
- Only cards with a check may enter Ready.

**Swimlanes:** Code, Art, Audio, Design, Business. Three cards In Progress in three lanes means
three context-switching penalties. Batch by discipline where possible.

**Weekly review (15 minutes, also solo)**
- What moved to Done? What has sat in In Progress or Verify for more than three days, and why?
- Was the WIP limit respected?
- Does the backlog still reflect priorities?
- Which vibe-debt card goes into Ready this week?

**Tools:** HacknPlan (game-development categories), Codecks (card-based, small teams), GitHub
Projects (free, next to the code), Notion (board plus documentation). A markdown file in
`production/sprints/` also works and is readable by agents.
