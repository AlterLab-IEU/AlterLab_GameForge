# Milestone Retrospective Format

Read for milestone retros (vertical slice, alpha, beta). It covers several sprints, runs about 45
minutes, and is written to `production/milestones/<milestone>-retro.md`. For a whole-project or
canceled-project review, use `/gameforge:game-postmortem` instead; it ingests these files.

Inputs: every sprint retro in the milestone, `production/sprints/velocity.md`, the milestone's
definition of done, playtest reports, the bug list, and the AI asset provenance log.

```markdown
# Milestone Retrospective: [Milestone] -- [start] to [end]
**Sprints covered:** S05-S08 | **Team:** [size or solo] | **Phase after this:** [next phase]

**Headline:** [one sentence: the story of this milestone]

## Goals vs reality
| Goal (from the milestone definition) | Target | Actual | Verdict |
|---|---|---|---|
| Vertical slice playable start to end | 3 cases, final art | 2 cases, final art; 1 greybox | Missed |
| 60 fps on Steam Deck | 60 | 52 in the courtroom scene | Missed |

## Velocity across the milestone
| Sprint | Planned h | Done h | Rate | Verify plan / actual | Agent-traced defects |
|---|---|---|---|---|---|

## Seven lenses (full analysis)
### Core loop validation
[Is the loop proven? Where is it weak? Evidence.]
### Pillar integrity
[Per pillar: held / bent / broke, with the decision that showed it. Grade A-F.]
### Scope tier review
| Feature | Starting tier | Ending tier | Move justified? |
|---|---|---|---|
### Flow state analysis
[Intended challenge curve vs observed player behavior; flow breakers; flow peaks.]
### Technical debt audit
| Debt item | Cost to fix | Cost of ignoring | Fix now / defer |
|---|---|---|---|
### Ludonarrative check
[Where mechanics and story align; where they fight.]
### AI-assisted development
| Measure | This milestone | Trend vs previous milestone |
|---|---|---|
| Tasks agent-led / assisted / hand | | |
| Verify ratio (AL) | | |
| Reopen rate (A + AL) | | |
| Agent-traced defects (by severity) | | |
| Escape stage (checks / play / players) | | |
| Vibe debt added / paid | | |
| Generated assets logged / placeholders outstanding | | |
What agents did well: [task types, with examples]
What agents did poorly: [task types, with examples]
Workflow changes adopted this milestone and whether they worked: [...]

## What went right (5, GDC format)
1. **[Title]** -- [2-3 sentences: what, why it worked, specific enough to repeat]
2.
3.
4.
5.

## What went wrong (5, GDC format)
1. **[Title]** -- [2-3 sentences: what, root cause in a system or decision, impact]
2.
3.
4.
5.

## Kill List
[Full format from the skill, including agent-added features]

## The One Thing
[one sentence]

## Actions
| Priority | Action | Owner | Due | Success measure |
|---|---|---|---|---|
| P1 | | | | |
| P2 | | | | |
| P3 | | | | |

## Process changes (effective immediately)
- [Change] -- [rationale]

## Carry forward
- [Systemic issue that needs attention through the next milestone]
```

After writing it:
- Update the milestone's status in `production/milestones/`.
- Update `production/session-state/active.md` (Decisions: The One Thing; Next: the P1 action).
- If `.gameforge/project.json` `phase` should change (for example `prototype` -> `vertical-slice`),
  propose the change and update it only with the user's agreement.
