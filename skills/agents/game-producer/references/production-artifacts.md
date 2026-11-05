# Production Artifacts: Formats and Conventions

Read this when creating or repairing a production file, onboarding a project that has none, or
mirroring production data into a connected tool. Paths follow
`docs/directory-conventions.md` in the GameForge plugin: committed team artifacts live in
`production/`; machine-local state lives in the gitignored `production/session-state/`.

## 1. File map

```
production/
  risk-register.md            # committed: every open and closed risk
  cut-list.md                 # committed: ranked feature list (CD owns ranking)
  calendar.md                 # committed: external dates with lead times
  sprints/
    sprint-07.md              # committed: one file per sprint (from the sprint-plan template)
  milestones/
    gate-vertical-slice-2026-11-19.md
    ai-use-log.md             # committed: AI use per milestone, feeds store disclosures
    postmortem-[name].md      # written by /gameforge:game-postmortem
  session-state/              # gitignored, local to one machine
    active.md                 # hand-off note shown at session start
    velocity.json             # optional; read by /gameforge:game-sprint-plan if present
  session-logs/               # gitignored, written by hooks
```

Never put the only copy of a team decision in `session-state/`: it is not committed and other
people will never see it.

## 2. active.md

The session-start hook prints the first lines of this file into Claude's context at the start of
every session and after compaction. Rules:
- Keep it to about twelve lines; the top five carry everything.
- Overwrite it; do not append history. History belongs in the gate files and decision logs.
- Dates are absolute (`2026-11-19`), never "next Friday".
- Every "Next" item has an owner or a skill to run.

```markdown
# Active focus
**Now:** vertical slice, week 2 of 3: boss arena polish
**Decisions:** cut co-op to post-launch (2026-11-05, producer, cut list #14)
**Next:** gate review 2026-11-19 (producer); Coming Soon page live by 2026-11-24 (marketing)
**Blocked on:** Unity 6.0 -> 6.3 upgrade spike (TD, due 2026-11-12)
**Top risks:** R-03 Steam review lead time (16); R-07 netcode bus factor (15)
**Phase:** vertical-slice (matches .gameforge/project.json)
```

## 3. risk-register.md (worked example)

```markdown
# Risk Register -- Ember Drift                         Reviewed: 2026-11-05

| ID | Risk | Cat. | P | I | Score | Owner | Status |
|---|---|---|---|---|---|---|---|
| R-03 | Steam review takes 12 business days; launch date is fixed | External | 4 | 4 | 16 | Producer | Mitigating |
| R-07 | Only one person understands the netcode | People | 3 | 5 | 15 | TD | Open |
| R-09 | Project is on Unity 6.0 (standard support ended 2026-10-16) | Platform | 5 | 3 | 15 | TD | Mitigating |
| R-11 | Agent-built UI code unreviewed (38 commits) | Quality | 4 | 3 | 12 | QA Lead | Open |
| R-12 | Shop NPC uses live LLM replies; EU Art. 50 disclosure not designed | Regulatory | 3 | 4 | 12 | CD | Open |

### R-03: Steam review lead time
Trigger/date: release 2027-03-12; review reported at up to 12 business days (Engadget, 2026-11-04)
Mitigation: release build submitted by 2027-02-19; Coming Soon page live by 2027-01-15
Contingency: soft launch date in marketing until review passes
Last reviewed: 2026-11-05
```

Close risks by changing Status to Resolved with a date; do not delete rows. A register that only
grows shows the team what was survived.

## 4. cut-list.md

```markdown
# Cut List -- ranked by pillar proximity (approved by CD 2026-10-01)

| Rank | Feature | Pillar fit (1-5) | Cost (pts) | Depends on | Cut impact | Status |
|---|---|---|---|---|---|---|
| 1 | Core dash-and-drift movement | 5 | 40 | -- | No game without it | Active |
| 2 | Storm events | 5 | 30 | Weather system | Loses "tense" pillar peaks | Active |
| ... | | | | | | |
| 13 | Photo mode | 2 | 13 | Camera rework | Nice-to-have marketing tool | At Risk |
| 14 | Online co-op | 2 | 60 | Netcode, lobby | Big but off-pillar | Post-Launch |
```

Cuts execute from the highest rank number upward. The Creative Director re-ranks only at gates.

## 5. calendar.md

```markdown
# External Calendar                                   Last verified: 2026-11-05

| Date | Item | Lead time | Owner | Readiness check | Status |
|---|---|---|---|---|---|
| 2026-12-02 | EU Art. 50(2) marking (runtime generation already on market) | 4 weeks | TD | Shop-NPC output marked | At risk |
| 2027-01-15 | Steam Coming Soon page live | 2 weeks | Marketing | Page approved | Planned |
| 2027-02-19 | Submit release build for Steam review | 3 weeks | Producer | RC passes QA gate | Planned |
| 2027-12-04 | Unity 6.3 LTS support ends | 2 sprints | TD | Upgrade plan in ADR | Watch |
```

## 6. ai-use-log.md

One block per milestone. It is a production record, not the per-asset provenance log (that lives
with `/gameforge:game-ai-assets`), and it feeds `/gameforge:game-launch` disclosures.

```markdown
## Milestone: vertical slice (closed 2026-11-19)
| Area | Tool | What it produced | Ships to players? | Reviewed by | Disclosure needed |
|---|---|---|---|---|---|
| Code | Claude Code | Movement, UI, save system | Code only | TD | No (Steam exempts code assistants) |
| Localization | MT + human review | FR/DE drafts | Yes | Loc lead | Yes (Steam counts localization) |
| Textures | [tool] | 14 prop textures, human-finished | Yes | Art Director | Yes (pre-generated) |
| Placeholders | [tool] | 6 AI placeholders | No; replace by beta | Art Director | Must be gone before any public build |
```

## 7. Gate review file

Name it `production/milestones/gate-[phase]-[YYYY-MM-DD].md` and use the format in SKILL.md. Attach
evidence links (builds, test reports, playtest notes). On ADVANCE, update `"phase"` in
`.gameforge/project.json` (only that key) and `active.md` in the same session.

## 8. Connected tools

Some users have connectors for issue trackers, docs or calendars. Use them only when they are
actually connected in the session, and only after asking:
- Mirror the top-five risks and gate dates to the team's tracker or calendar; keep the committed
  markdown files as the source of truth.
- Pull issue status for burndown when sprint files are missing, and say where the numbers came
  from.
- Never assume a connector exists, and never post to a shared channel without the user's approval.

Without connectors, `git log` is the honest fallback for throughput:
`git log --since="2 weeks ago" --oneline` for volume, `git log --since="2 weeks ago" --stat` for
which systems moved.
