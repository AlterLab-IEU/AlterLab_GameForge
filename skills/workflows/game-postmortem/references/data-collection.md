# Post-Mortem Data Collection Recipes

Read before Phase 1. All commands are read-only. Run them from the project root; replace
`<start>`, `<end>`, `<tagA>`, `<tagB>` with dates or tags. If a command fails (no git, no `gh`, no
tags), record "no data" and move on; never invent a number to fill the gap.

## Duration and cadence

```
# Total commits and first/last commit
git rev-list --count HEAD
git log --reverse --format="%ad %h %s" --date=short | head -1
git log -1 --format="%ad %h %s" --date=short

# Commits per ISO week (crunch and dead zones)
git log --since=<start> --until=<end> --format="%ad" --date=format:%G-W%V | sort | uniq -c

# Commits by hour of day and weekday (late nights, weekends)
git log --since=<start> --until=<end> --format="%ad" --date=format:%H | sort | uniq -c
git log --since=<start> --until=<end> --format="%ad" --date=format:%a | sort | uniq -c
```

Reading it:
- Weeks with two to three times the median commit count, especially before a milestone tag,
  suggest crunch. Confirm with the team before calling it crunch; agent sessions also inflate
  commit counts without extra human hours.
- Gaps of several weeks are dead zones: illness, burnout, a blocked dependency, or work happening
  outside git (art, audio, design). Ask which.
- Many commits late at night or at weekends on a project with a "normal hours" plan is a morale
  and sustainability finding, stated without blame.

## Milestones

```
git tag -l --sort=creatordate --format="%(refname:short) %(creatordate:short)"
git rev-list --count <tagA>..<tagB>
git log <tagA>..<tagB> --oneline | head -50
```

No tags: use milestone dates from `production/milestones/` or the GDD §17 and `--since/--until`.

## Contributors and ownership

```
git shortlog -sn --no-merges HEAD
git shortlog -sn --no-merges <tagA>..<tagB>
```

Use to find bus-factor risks (one person owns a critical system), not to rank people.

## Churn hotspots

```
# Most-changed files over the period
git log --since=<start> --until=<end> --format= --name-only | sort | uniq -c | sort -rn | head -20

# Most-changed files in agent-trailer commits only
git log --since=<start> --until=<end> -i --grep="Co-Authored-By: Claude" --format= --name-only | sort | uniq -c | sort -rn | head -20
```

Reading it: files near the top of both lists are where agent code and instability overlap; check
them against the bug list. Generated or engine files (lock files, `.import`, `.meta`, scene
files) can dominate; filter them out mentally or with a path argument (`-- src/ scripts/`).

## Agent share per milestone

```
git rev-list --count -i --grep="Co-Authored-By: Claude" <tagA>..<tagB>
git rev-list --count <tagA>..<tagB>
git log <tagA>..<tagB> --oneline -i --grep="revert"
```

- The trailer is Claude Code's default co-author line; other agents use other trailers, and teams
  can disable trailers. Adjust the pattern, or rely on the "Mode" column in sprint files.
- Squash merges hide per-commit trailers; check the merge commit body instead.
- Agent share of commits is not agent share of work. Report it next to tasks by build mode from
  the sprint files and verify hours from `velocity.md`.

## Issues and bugs

```
gh issue list --state closed --limit 200
gh issue list --state open --limit 200
gh issue list --state closed --label bug --limit 200
```

If the project uses another tracker, ask the user for an export. Useful fields: created, closed,
severity, system, origin (agent-led / agent-assisted / hand / unknown), where caught (checks /
play / review / players).

Derived:
- **Bug lag:** closed date minus created date, median per system.
- **Escape rate:** bugs first reported by players / all bugs.
- **Agent-traced defect rate per milestone:** agent-origin defects / agent tasks done.

## Project records to read

| File | What to take from it |
|---|---|
| `production/sprints/sprint-NN.md` | Goal, planned tasks with build mode and verify estimates, carry-over |
| `production/sprints/sprint-NN-retro.md` | Lens findings, One Things, actions and whether they were done |
| `production/sprints/velocity.md` | Planned vs done, verify plan vs actual, agent-traced defects per sprint |
| `production/milestones/*` | Definitions of done, milestone retros |
| `design/gdd.md` change log | Scope added after lock, cuts, rule changes |
| AI asset provenance log | Generated assets, tools, licenses, placeholders and their replacement |
| Store page AI disclosure | Whether it matches the provenance log |

## Recurring-theme scan

Search retros for repeated problems:
```
Grep for the same words across production/sprints/*-retro.md and production/milestones/*-retro.md:
"late", "blocked", "reopened", "regression", "scope", "unreviewed", "placeholder"
```
A theme in three or more consecutive retros is a systemic pattern for Phase 3. Quote the dates.

## Never

- Never estimate missing numbers. "No data" is a finding, and usually a lesson.
- Never run commands that change the repository (checkout, bisect, reset, stash) during a
  post-mortem.
- Never rank individuals by commit count.
