# Post-Mortem Report

## Project
- **Game Title**: [name]
- **Milestone/Sprint**: [what period this covers]
- **Date**: [date]
- **Author**: [name]

## Goals vs. Results
| Goal | Target | Actual | Status |
|------|--------|--------|--------|
| [e.g., Complete combat system] | [Sprint 3] | [Sprint 4] | Late |
| [e.g., 60 FPS on target hardware] | [60 FPS] | [55 FPS] | Missed |

## Timeline of Key Events
| Date | Event | Impact |
|------|-------|--------|
| [date] | [e.g., Scope change requested] | [delayed feature X by 1 week] |

## What Went Well
| Item | Root Cause | Reproducible? |
|------|-----------|--------------|
| [e.g., Art pipeline was fast] | [AI asset generation + strong art direction] | Yes -- document pipeline |

## What Went Poorly
| Item | Root Cause | Preventable? |
|------|-----------|-------------|
| [e.g., Scope crept] | [No formal change freeze date] | Yes -- add freeze 3 days before milestone |

## Quantitative Metrics
- Features planned: [N] | Completed: [N] | Cut: [N] | Deferred: [N]
- Bugs found: [N] | Fixed: [N] | Known shippable: [N]
- Build stability: [% of days with working build]
- Team morale (1-5): [self-reported]

## AI-Assisted Development
One row per milestone, built from sprint records, git trailers, the bug tracker and the provenance
log (`design/ai-asset-log.md`, from the [AI asset log template](ai-asset-log.md)). If no records
were kept, say so and estimate nothing; recording build mode and defect origin from day one becomes
an action item. `/gameforge:game-postmortem` builds this ledger from the repository.

| Milestone | What agents built | Agent share (agent-trailer commits / total) | Review cost (verify h / build h) | Defects traced to agent code (Crit/Maj/Min; reached players) | Assets generated (logged / total) | Disclosures filed vs provenance log |
|-----------|-------------------|---------------------------------------------|----------------------------------|--------------------------------------------------------------|-----------------------------------|-------------------------------------|
| [e.g., Prototype] | [e.g., input rebinding, save system, debug overlay] | [210 / 260] | [0.6x] | [1 / 6 / 14; 0] | [12 / 12] | [n/a: no public build] |
| [e.g., Vertical slice] | [Tasks or systems] | [N / N] | [Nx] | [N / N / N; N] | [N / N] | [e.g., Steam survey matches log; 2 marketing images missing, fixed] |

- **What agents did well:** [task types that landed first time; name them]
- **What agents did poorly:** [task types reopened or traced to defects; name them]
- **Vibe debt:** [when it peaked, what paying it down cost, what it blocked]
- **Guardrails added:** [check commands, `CLAUDE.md` rules, review gates; did the numbers move?]
- **Disclosure check:** [every shipped AI asset has a log row; store disclosures (Steam, itch.io,
  others) match the log; no placeholder AI content reached a public build]

## Action Items
| Action | Owner | Deadline | Status |
|--------|-------|----------|--------|
| [e.g., Implement change freeze policy] | [Producer] | [next sprint] | Pending |

## Key Learnings
1. [Lesson that applies beyond this project]
2. [Lesson that applies beyond this project]
3. [Lesson that applies beyond this project]
