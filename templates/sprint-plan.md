# Sprint Plan

> **Sprint:** [Sprint number, e.g., Sprint 7]
> **Dates:** [Start date] - [End date]
> **Duration:** [Number of days/weeks]
> **Sprint Goal:** [One sentence describing the sprint's primary objective]

---

## Team Capacity

| Team Member | Role | Available Days | Notes |
|-------------|------|---------------|-------|
| [Name] | [Role, e.g., Lead Designer] | [X / total days] | [PTO, reduced hours, etc.] |
| [Name] | [Role, e.g., Programmer] | [X / total days] | |
| [Name] | [Role, e.g., Artist] | [X / total days] | |
| **Total** | | **[Sum] person-days** | |

**Vibe-debt paydown:** [X h] reserved this sprint (10-15% of capacity as a rule of thumb; use the
high end after an agent-led sprint) for unreviewed agent merges, oversized files, gameplay literals
that belong in tuning files, and missing tests around agent-written logic. Plan it with
`/gameforge:game-sprint-plan`.

---

## Task List

| # | Task | Mode | Owner | Build h | Verify h | Dependency | Priority | Done when | Status |
|---|------|------|-------|---------|----------|------------|----------|-----------|--------|
| 1 | [Task description] | [H / A / AL] | [Name] | [h] | [h] | None | Must | [Check that passes, e.g. "AC-002-2 green in `npm run check`"] | [ ] Not Started |
| 2 | [Task description] | [Mode] | [Name] | [h] | [h] | Task 1 | Must | [Check] | [ ] Not Started |
| 3 | [Task description] | [Mode] | [Name] | [h] | [h] | None | Should | [Check] | [ ] Not Started |
| 4 | [Task description] | [Mode] | [Name] | [h] | [h] | Task 2 | Should | [Check] | [ ] Not Started |
| 5 | [Task description] | [Mode] | [Name] | [h] | [h] | None | Could | [Check] | [ ] Not Started |
| 6 | [Vibe-debt paydown item] | [Mode] | [Name] | [h] | [h] | None | Debt slot | [e.g. "tests green, no file over 300 lines"] | [ ] Not Started |

**Mode:** H = by hand; A = agent-assisted (a human drives, the agent drafts); AL = agent-led (the
agent implements from the task card, a human verifies).
**Verify h** is human time: run the check, read the diff, play the change. Rules of thumb until you
have three sprints of your own data: A about 30-50% of build time, AL at least equal to build time.
**Done when** names something a person can run or watch, never "works" or "done".

**Status values:** Not Started / In Progress / In Review / Done / Blocked / Cut

---

## Scope Tiers

### Must Have (Sprint fails without these)
- [ ] [Deliverable 1 — tied to sprint goal]
- [ ] [Deliverable 2 — tied to sprint goal]
- [ ] [Deliverable 3 — tied to sprint goal]

### Should Have (Expected but can slip to next sprint)
- [ ] [Deliverable 4]
- [ ] [Deliverable 5]

### Could Have (Bonus if time allows)
- [ ] [Deliverable 6]
- [ ] [Deliverable 7]

### Won't Have (Explicitly deferred)
- [Deliverable 8 — reason for deferral]
- [Deliverable 9 — reason for deferral]

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|-----------|--------|------------|-------|
| [Technical risk, e.g., physics system instability] | [High/Med/Low] | [High/Med/Low] | [Action plan] | [Name] |
| [Dependency risk, e.g., waiting on art assets] | [High/Med/Low] | [High/Med/Low] | [Action plan] | [Name] |
| [Scope risk, e.g., feature more complex than estimated] | [High/Med/Low] | [High/Med/Low] | [Action plan] | [Name] |

---

## Definition of Done

A task is "Done" when ALL of the following are true:

- [ ] Code compiles and runs without errors
- [ ] Feature matches acceptance criteria from the GDD
- [ ] Unit tests written and passing (where applicable)
- [ ] No known regressions in existing features
- [ ] Code reviewed by at least one other team member
- [ ] Agent-written changes: diff read and change played by a human; verify hours logged
- [ ] Assets are final quality (not placeholder) OR placeholder is clearly marked
- [ ] Performance within budget (frame rate, memory, load time)
- [ ] Documented in code comments and/or design docs

---

## Carry-Over from Previous Sprint

[List anything that was not completed in the previous sprint and is being pulled into this one.]

| Task | Original Sprint | Reason for Carry-Over |
|------|----------------|----------------------|
| [Task] | Sprint [N-1] | [Why it was not completed] |

---

## Sprint Retrospective Notes

> Fill in at sprint end.

### What went well
- [Item]
- [Item]

### What could improve
- [Item]
- [Item]

### Action items for next sprint
- [ ] [Concrete action with owner]
- [ ] [Concrete action with owner]

### Velocity
- **Planned:** [X points/hours]
- **Completed:** [Y points/hours]
- **Carry-over:** [Z points/hours]
- **Verify hours (planned / actual):** [X / Y]
- **Vibe-debt slot used:** [X of Y h, items closed]
