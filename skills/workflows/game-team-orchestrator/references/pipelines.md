# Named Pipelines: State, Steps and Protocol

A pipeline is a fixed chain of skills, subagent panels, user-run commands and manual work, with its
state saved to `production/session-state/pipeline-<name>.json` after every step. The pre-compact
hook lists every `pipeline-*.json` in that folder as an active pipeline in its snapshot, and the
session-start hook re-injects the snapshot after compaction, so a pipeline survives context
compaction and new sessions as long as the state file is current.

## 1. State schema

```json
{
  "pipeline": "release",
  "schema": 2,
  "status": "in_progress",
  "current_step": "readiness-panel",
  "started_at": "2026-11-05T14:02:00Z",
  "updated_at": "2026-11-05T16:40:00Z",
  "context": {
    "project": "Ember Drift",
    "engine": "godot 4.7",
    "goal": "v1.0.0 on Steam, target 2027-02-18",
    "initiated_by": "user"
  },
  "steps": [
    {
      "id": "code-review",
      "kind": "skill",
      "skill": "game-code-review",
      "status": "completed",
      "output": "docs/reviews/2026-11-05-release-review.md",
      "findings": ["2 Important: save migration lacks a test", "0 Critical"],
      "gate": "no Critical findings",
      "gate_result": "pass"
    },
    {
      "id": "readiness-panel",
      "kind": "panel",
      "agents": ["gameforge:game-producer", "gameforge:game-qa-lead",
                 "gameforge:game-ux-designer", "gameforge:game-accessibility-specialist"],
      "status": "in_progress",
      "reports": {},
      "output": null
    },
    {
      "id": "launch",
      "kind": "user",
      "command": "/gameforge:game-launch steam 2027-02-18",
      "status": "pending"
    }
  ],
  "decisions": [
    {"date": "2026-11-05", "by": "user", "decision": "Skip Next Fest", "rationale": "demo not ready before February"}
  ],
  "open_questions": [],
  "blocked_reason": null,
  "next_action": "Wait for readiness panel reports, then synthesize"
}
```

Field rules:
- `status`: `pending`, `in_progress`, `blocked`, `completed`, `abandoned`
- step `status`: `pending`, `in_progress`, `completed`, `skipped` (with a reason in `findings`),
  `failed`, `waiting_user`
- step `kind`: `skill` (Skill tool), `panel` (subagent wave), `user` (user-invoked command),
  `manual` (work outside the session)
- Keep `findings` and `decisions` to short strings; long material lives in the `output` file.
- Always set `next_action`: it is what a fresh session reads first.

## 2. Protocol

**Start**
1. Check for an existing `production/session-state/pipeline-<name>.json`. If one exists with status
   `in_progress`, `blocked` or `waiting_user`, offer to resume it (AskUserQuestion: Resume /
   Restart / Abandon) before creating anything.
2. Create the file with every step `pending`, `context` filled from `.gameforge/project.json` and
   the user's request.
3. Add one line to `production/session-state/active.md`: "Pipeline <name> running, step <id>".

**Each step**
1. Set the step `in_progress` and `current_step`, save.
2. Run it:
   - `skill`: invoke with the Skill tool and pass the context the skill needs (prior outputs,
     findings). A forked skill (`game-code-review`) cannot see this conversation, so pass paths and
     the focus explicitly in the arguments.
   - `panel`: run SKILL.md Steps 3-5 (briefs, one wave, synthesis). Store each verdict line in
     `reports` and the synthesis path in `output`.
   - `user`: the skill is user-invoked only (`game-launch`, `game-sprint-plan` have model invocation
     disabled). Set `waiting_user`, save, and tell the user the exact command with arguments. When
     they return, read the skill's output file and continue.
   - `manual`: record progress the user reports; do not invent it.
3. Record `status`, `output`, `findings`, `decisions`, `gate_result`; update `updated_at` and
   `next_action`; save.

**Block**
On a failed gate, set the pipeline `status: blocked`, fill `blocked_reason` and `next_action`, and
present the blocker using the collaboration protocol (question, context, options, recommendation).
Do not run later steps until the user resolves or explicitly overrides the gate; record overrides
as decisions with the user as decider.

**Complete**
1. Write the pipeline summary (template below) to `production/orchestration/`.
2. Update `active.md` with outcomes and the next step.
3. Archive the state file so it stops appearing as active:
   `mv production/session-state/pipeline-<name>.json production/session-logs/pipeline-<name>-<YYYY-MM-DD>.json`

## 3. Pipelines

### new-project
Purpose: raw idea to a playable first prototype with a properly set-up project.

| # | id | kind | What | Gate |
|---|---|---|---|---|
| 1 | brainstorm | skill | `game-brainstorm` with the user's idea; output a concept doc | At least one concept the user wants |
| 2 | concept-panel | panel | Creative Director, Producer, Technical Director on the chosen concept | No unaccepted High risk on feasibility or scope |
| 3 | start | skill | `game-start` with the concept doc path; creates `.gameforge/project.json`, folders, engine setup | Project config written |
| 4 | prototype | skill | `game-prototype` for a throwaway test of the core question, or `game-vibe-code` for an agent-built playable | Playable build answers the core question |

Decision points:
- Several viable concepts after step 1: the user picks one before step 2 (AskUserQuestion).
- `game-start` detects an existing project: skip to its state handling, mark step 3 `skipped`.
- Prototype estimate above two weeks: route to `game-scope-check` before step 4.
- Web target and agent-driven build: prefer `game-vibe-code` in step 4.

### design-iteration
Purpose: a design health check after major changes or before a milestone gate.

| # | id | kind | What | Gate |
|---|---|---|---|---|
| 1 | design-review | skill | `game-design-review` on the changed documents in `design/` | Critical findings listed |
| 2 | review-panel | panel | Creative Director, Game Designer, Technical Director, Producer on the Critical and Important findings | Each Critical finding has an owner and a ruling |
| 3 | balance | skill | `game-balance-check` scoped to systems the review flagged | Balance issues listed with proposed values |
| 4 | scope | skill | `game-scope-check` with all accumulated findings | Cut/keep list the user approves |

Decision points:
- No Critical findings in step 1: step 3 runs reduced (only flagged systems).
- Balance reveals an economy problem that needs redesign: pause, run the Monetization review preset
  (recipes.md), then resume at step 3.
- Final output: one synthesis of all four steps, not four reports.

### sprint
Purpose: bookend a sprint with planning and a retrospective, with a quality check before closing.

| # | id | kind | What | Gate |
|---|---|---|---|---|
| 1 | plan | user | User runs `/gameforge:game-sprint-plan` with the milestone or focus | Sprint goal and plan file exist |
| 2 | work | manual | Development; record progress when the user reports it | User signals sprint end |
| 3 | qa-panel | panel | QA Lead (runs the test suite), plus Technical Director if the sprint changed architecture | Regressions listed with command output |
| 4 | retro | skill | `game-retrospective` with the plan (planned) and progress (done) | Lessons and velocity recorded |

Decision points:
- Work runs past the planned end: ask whether to extend or close as-is.
- Completion below roughly 75% for three sprints running (a rule of thumb, adjust to the team):
  recommend `game-scope-check` before the next plan.
- Read `git log` for the sprint window to cross-check reported progress; never infer completion
  from commits alone.

### release
Purpose: pre-release quality gate, ending in the launch workflow.

| # | id | kind | What | Gate |
|---|---|---|---|---|
| 1 | code-review | skill | `game-code-review` (forked) on release-critical paths: crashes, save data, performance, security | No Critical findings |
| 2 | playtest | skill | `game-playtest` focused on the first hour, core loop and showstoppers | No finding that players quit within the first minutes |
| 3 | readiness-panel | panel | Producer, QA Lead, UX Designer, Accessibility Specialist (Launch readiness preset) | Blockers listed with owners |
| 4 | launch | user | User runs `/gameforge:game-launch [platform] [date]` with the synthesis path | Launch readiness report written |

Decision points:
- Step 1 Critical findings: block; fix, then re-run step 1. Do not playtest a crashing build.
- Step 2 first-hour failure: treat as a release blocker equal to a Critical bug.
- Step 4 may surface compliance work (AI disclosure, age rating answers, EAA scope) that sends work
  back to code or content; record it and loop to the relevant step.
- Browser release: replace step 4 with `game-web-publish`.

## 4. Composing and custom pipelines

- Pipelines can follow each other (new-project, then sprint); start the second only after archiving
  the first.
- A custom pipeline uses the same schema with a new `pipeline` name and file
  (`pipeline-<custom-name>.json`). Write its step table in the plan and get approval first.
- Keep pipelines short (three to five steps). Long chains go stale; split them.

## 5. Pipeline status report

```markdown
## Pipeline: [name]   Status: [in_progress / blocked / waiting on you / completed]
Started [date]   Updated [date]   Goal: [context.goal]
| # | Step | Kind | Status | Output |
|---|---|---|---|---|
| 1 | code-review | skill | completed (gate pass) | docs/reviews/... |
| 2 | playtest | skill | completed | production/playtests/... |
| 3 | readiness-panel | panel | in progress | - |
| 4 | launch | user | pending | - |
Decisions so far: [date, by, decision]
Blocker: [none / reason and options]
Next action: [exact command or question]
```

## 6. Pipeline summary (on completion)

```markdown
## Pipeline complete: [name]   [start date] - [end date]
Outcome: [one paragraph]
Key decisions: [date, by, decision, rationale]
Artifacts: [path - produced by]
Gates: [step: pass / overridden by user on date, reason]
Deferred: [items and where they went: backlog, next sprint, post-launch]
State archived to: production/session-logs/pipeline-[name]-[date].json
```
