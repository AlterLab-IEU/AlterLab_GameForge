# Lens 7: Measuring AI-Assisted Development

Read before running Lens 7. The aim is a short, factual account of what coding and asset agents
did this period and what they cost, so the next sprint plan can size verify budgets and the
vibe-debt slot from data.

## Where the numbers come from

| Metric | Source |
|---|---|
| Tasks by build mode (agent-led / assisted / hand) | "Mode" column in `production/sprints/sprint-NN.md` |
| Verify hours planned vs actual | "Verify h" columns in the sprint file |
| Reopened tasks | Status history in the sprint file (Done -> In Progress) |
| Commits made with an agent | Co-author trailer in git (Claude Code adds one by default) |
| Reverts | Commits whose message contains "revert" |
| Defects traced to agent code | Bug list with an origin field (see below) |
| Out-of-scope additions rejected | Review notes on AL tasks |
| Vibe debt added / paid | Debt items opened in review vs debt tasks done |
| Generated assets and placeholders | The project's AI asset provenance log |

## Git recipes (read-only)

```
# All commits in the period
git log --since=<start> --until=<end> --oneline

# Commits carrying Claude Code's co-author trailer (case-insensitive)
git log --since=<start> --until=<end> --oneline -i --grep="Co-Authored-By: Claude"

# Files touched by those commits (where agent code lives)
git log --since=<start> --until=<end> -i --grep="Co-Authored-By: Claude" --name-only --format=

# Reverts in the period
git log --since=<start> --until=<end> --oneline -i --grep="revert"

# Which commit introduced a suspicious line (pickaxe search)
git log -S"stamina -= DASH_COST" --oneline

# History of a function or line range
git log -L :apply_dash:scripts/player/dash.gd --oneline
```

Notes:
- Trailers are a proxy. Teams that turn them off, squash merges, or use other agents with
  different trailers need their own pattern, or the sprint file's Mode column alone.
- Commit counts measure activity, not progress. Report them next to completed Must hours.

## Tracing defects to agent code

Use a simple origin field on every bug when it is fixed (a GameForge convention, not an
industry standard):

| Origin | Meaning |
|---|---|
| agent-led | Introduced in a task built by an agent with the human verifying afterwards |
| agent-assisted | Introduced while a human drove the agent |
| hand | Written by hand |
| unknown | Could not be traced; do not guess |

How to fill it: when fixing, find the introducing commit (`git log -S`, `git log -L`, or the
task the bug appeared after) and record the origin plus the task ID in the fix commit body or the
bug tracker, for example `Introduced-in: S07-03 (agent-led)`.

Also record **where it was caught**: automated check, human play, code review, or a player after
release. Defects in agent code that only play or players catch mean the checks are too thin.

## Derived numbers

| Number | Formula | Use |
|---|---|---|
| Verify ratio per mode | verify actual h / build actual h | Replaces the rules of thumb in sprint planning |
| Reopen rate | reopened tasks / done tasks, per mode | Signals vague cards or missing checks |
| Agent-traced defect rate | agent-origin defects / A + AL tasks done | Trend across sprints matters more than one value |
| Escape stage | share of defects caught by checks vs play vs players | Where to add Auto checks |
| Debt balance | debt items added - debt items paid | Sizes the next vibe-debt slot |

## Reading the pattern

| Pattern | Likely cause | Action for next sprint |
|---|---|---|
| Agent tasks reopened for wrong behavior | Cards without edge cases or acceptance checks | AL cards must list GDD §7 edge cases and check IDs |
| Verify actual far above plan | Ratios too optimiztic; diffs too large | Raise AL verify ratio; smaller cards |
| Defects caught only by play | Missing Auto checks | Add simulation or browser checks to the check command |
| Agent picked tuning values | Tuning handed to the agent | Tuning tasks become hand tasks with the knob panel |
| Out-of-scope features keep appearing | No out-of-scope list; long sessions | Out-of-scope on every card; fresh session per task |
| Same subsystem keeps breaking | Structure needs to change; agent keeps patching | Human-written design note, then an agent-implemented refactor |
| Unreviewed agent commits merged | Verify queue overflow | Cap concurrent AL tasks; review before merge |
| Generated placeholder near a ship milestone | Replacement never scheduled | Replacement task with a date; provenance log updated |

## Provenance and disclosure hygiene

Check each period, because launch is too late to reconstruct it:
- Every generated asset is in the provenance log with tool, version, prompt, human edits, license.
- Placeholders have a replacement milestone.
- Steam's disclosure (rules of 2026-01-16) covers shipped AI content, including localization and
  marketing assets; code assistants are exempt. itch.io requires generative-AI disclosure. If the
  log and the planned store disclosure disagree, raise it now.
- Generated audio from tools whose legal status is unsettled for shipped games (Suno, Udio) is
  flagged for replacement before release.

## Context, cited

GDC 2026 State of the Game Industry (more than 2,300 respondents): 36% use generative AI at work,
52% say it is harming the industry (up from 30% in 2025 and 18% in 2024); the most common uses
were brainstorming and code assistance. Use this to explain why tracking matters, never as a
benchmark for your team.
