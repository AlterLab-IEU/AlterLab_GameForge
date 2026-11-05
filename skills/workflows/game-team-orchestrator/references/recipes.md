# Feature Recipes and Coordination Templates

Recipes for Build mode: features whose work packages depend on each other. Each recipe lists the
waves (what runs in parallel), the artifact each role writes and where, and who rules on the
predictable conflicts. Adjust paths to the project's layout (`design/`, `docs/`, `tests/`).

Sizing rule: two roles suffice for a well-scoped addition (a new status effect: Game Designer for
rules, engine specialist inline for implementation). Three or four cover most content (a new enemy:
designer, art, audio, implementation). Use a full recipe only when a feature creates a new
player-facing system, needs new infrastructure, or changes how several existing systems interact.

---

## Recipe 1: Core mechanic or combat build

Combat touches mechanics, input, animation, feedback, readability, accessibility and test coverage
at once. Getting the order wrong produces rework in every discipline.

| Wave | Role (`subagent_type`) | Writes | Consumes |
|---|---|---|---|
| 1 | `gameforge:game-designer` | `design/gdd/<feature>.md`: rules, damage model, feel targets in frames ("light attack: 6 startup, 3 active, 12 recovery; hitstop 3 frames") | Pillars, user brief |
| 2 | `gameforge:game-technical-director` | `docs/architecture/<feature>.md`: input pipeline and buffering, frame budget ("8 enemies on screen at 60 fps on min spec"), netcode model if online | Wave 1 decisions |
| 3 (parallel) | `gameforge:game-ux-designer` | `design/ux/<feature>-feedback.md`: hitstop curves, screen shake, damage numbers, remapping | Waves 1-2 |
| 3 (parallel) | `gameforge:game-qa-lead` | `tests/plans/<feature>.md`: interaction matrix, exploit cases, regression list | Waves 1-2 |
| 3 (optional) | `gameforge:game-accessibility-specialist` | Report: timing assists, visual cues for audio, hold-to-toggle | Waves 1-2 |
| 4 | Implementation in the main conversation (engine specialist skill or `/gameforge:game-vibe-code`) | Code and tests | All above |
| 5 | Integration checkpoint: one wave with all wave 1-3 roles reviewing the playable build | Reports | Build, test output |

| Conflict | Resolver | Rationale |
|---|---|---|
| "Is this fun?" | Game Designer, Creative Director if pillars are at stake | The designer owns the feel target |
| "Can this ship at budget?" | Technical Director | Performance budgets are architecture decisions |
| "Can players read this?" | UX Designer advises; Technical Director decides implementation | Readability failures show up in every playtest |
| Fun vs. shippable vs. readable deadlock | Producer mediates; user decides | Cross-domain trade-off |

## Recipe 2: Narrative feature

Quests, dialogue systems, branching scenes: story and mechanics must land together.

| Wave | Role | Writes | Consumes |
|---|---|---|---|
| 1 | `gameforge:game-narrative-director` | `design/narrative/<feature>.md`: scene list, branch map, emotional target per scene | Pillars |
| 2 (parallel) | `gameforge:game-designer` | Mechanics integration: which player actions carry story weight, pacing | Branch map |
| 2 (parallel) | `gameforge:game-audio-director` | Emotion map: music states, transitions at branch points, silence cues | Branch map |
| 2 (parallel) | `gameforge:game-art-director` | Environmental storytelling brief: lighting, props, color temperature per beat | Branch map |
| 3 | Integration checkpoint: play the scene with all layers active | Reports | Build |

| Conflict | Resolver |
|---|---|
| Story says one thing, mechanics another | Creative Director (ludonarrative consonance is a top-level creative call) |
| Scored emotion does not match written emotion | Narrative Director sets the target; Audio Director states what is achievable; Creative Director breaks ties |
| Environment contradicts dialogue | Creative Director |

If the feature uses LLM-driven NPCs, add the Technical Director (guardrails, cost, on-device or
cloud) and note the disclosure duties in `/gameforge:game-launch` (EU AI Act Art. 50(1), Steam
live-generated content, Microsoft Store 11.16).

## Recipe 3: UI overhaul

Menus, HUD, inventory, settings. Fails when mockups are beautiful and unusable, or usable and
hostile to the game's identity.

| Wave | Role | Writes | Consumes |
|---|---|---|---|
| 1 | `gameforge:game-ux-designer` | `design/ux/<screen-set>.md`: wireframes, flows, information hierarchy, input parity | Feature list, playtest notes |
| 2 (parallel) | `gameforge:game-art-director` | Visual designs within the wireframes: states, atlas plan, style rules | Wireframes |
| 2 (parallel) | `gameforge:game-technical-director` | Implementation plan: UI frame-time budget, scaling, atlas strategy | Wireframes |
| 2 (parallel) | `gameforge:game-accessibility-specialist` | Accommodations: scalable text, contrast, remapping, screen-reader hooks, store-tag claims | Wireframes |
| 3 | Integration checkpoint on minimum spec with colorblind simulation and text at maximum scale | Reports | Build |

| Conflict | Resolution |
|---|---|
| Accessibility vs. aesthetics | Accessibility Specialist advises, Technical Director decides implementation; legally or platform-required accommodations are not negotiable |
| Visual ambition vs. performance | Technical Director sets the limit; Art works inside it |
| Information density vs. clean look | UX Designer decides what information is essential; Art decides how it looks |

## Recipe 4: Performance pass

| Wave | Role | Writes | Consumes |
|---|---|---|---|
| 1 | `gameforge:game-technical-director` (Bash) | `docs/perf/<date>-profile.md`: frame time split CPU/GPU per scene, top hotspots, targets | Profiler captures, min-spec definition |
| 2 | Engine specialist skill inline in the main conversation | Fixes with expected impact and rollback notes | Targets |
| 3 | `gameforge:game-qa-lead` (Bash) | Regression report: before/after per scene, visual and gameplay regressions | Fixes |
| Loop | Back to wave 2 with specific failures until targets pass on min spec | | |

| Conflict | Resolution |
|---|---|
| Fidelity vs. performance | Targets hold; features are simplified or cut, deliberately and on record |
| Risky optimization vs. timeline | Technical Director assesses risk, Producer decides schedule |
| Platform parity vs. polish | The weakest supported platform sets the floor |

## Recipe 5: Launch readiness

| Wave | Role | Writes | Consumes |
|---|---|---|---|
| 1 (parallel) | `gameforge:game-producer` | Backplan with store and review lead times, owners | Target date, platforms |
| 1 (parallel) | `gameforge:game-qa-lead` | Release readiness: open bugs by severity, cert checklist status, benchmarks | Bug data, test output |
| 1 (parallel) | `gameforge:game-ux-designer` | First-hour audit: where new players get lost, settings completeness | Build or recordings |
| 1 (parallel) | `gameforge:game-accessibility-specialist` | Accessibility statement draft, EAA scoping, store tags the build meets | Settings, UI |
| 2 | The user runs `/gameforge:game-launch` with the synthesis as input | Launch readiness report | Wave 1 |

| Conflict | Resolution |
|---|---|
| QA says no-go, Producer wants the date | Quality vs. ship date: QA presents risk, Producer presents schedule impact, the user decides; record the decision and its conditions |
| First-hour audit finds major issues | UX flags; Producer scopes what is fixed before launch, in the day-one patch, or later |
| Store page misrepresents the first hour | Producer corrects the page; screenshots must reflect what players see early |

## Recipe 6: Monetization review

| Wave | Role | Writes / answers |
|---|---|---|
| 1 | `gameforge:game-economy-designer` | Economy model and monetization proposal, checked against `${CLAUDE_PLUGIN_ROOT}/docs/monetization-ethics.md` |
| 2 (parallel) | `gameforge:game-creative-director` | Pillar and player-trust fit |
| 2 (parallel) | `gameforge:game-producer` | Revenue vs. scope and schedule; decides revenue-vs-trust conflicts |
| 2 (parallel) | `gameforge:game-ux-designer` | Purchase-flow clarity, no dark patterns, refund paths |
| 2 (optional) | `gameforge:game-accessibility-specialist` | EAA e-commerce scope for purchase flows |

Flag rating impact early: under PEGI's criteria for games submitted from June 2026, paid random
items default to PEGI 16 and time-limited offers to PEGI 12.

## Recipe 7: AI-use stance and asset policy

| Wave | Role | Writes / answers |
|---|---|---|
| 1 | `gameforge:game-creative-director` | Project AI-use stance using `${CLAUDE_PLUGIN_ROOT}/templates/ai-content-policy.md` |
| 2 (parallel) | `gameforge:game-art-director`, `gameforge:game-audio-director`, `gameforge:game-narrative-director` | Per-domain allowed tools, licence checks, human-edit requirements, disclosure needs |
| 3 | `gameforge:game-producer` | Cost, schedule and disclosure plan; owner of the provenance log |

Generation itself and the provenance log (`design/ai-asset-log.md`): `/gameforge:game-ai-assets`.

---

## Templates

### Feature decomposition
```
FEATURE DECOMPOSITION: [name]
Recipe: [1-7 or custom]      Owner: [accountable role]
WP-1 [package]  Role: [subagent_type or "main thread"]  Writes: [path]
     Inputs: [...]  Depends on: none  Parallel with: WP-2
WP-2 [package]  Role: [...]  Writes: [path]  Depends on: WP-1
Checkpoints: CP-1 after WP-2: [what is validated]
Conflict risks: [domain A] vs [domain B]: [why] -> [resolver]
```

### Hand-off document (written by you between sequential waves)
```
HAND-OFF: [from role] -> [to role]   Feature: [name]   Date: [date]
Context (3-5 sentences): [what was done and why]
Decisions locked (reopen only through escalation):
- [decision]: [rationale] ([role], [date])
Constraints: [technical] [creative] [schedule]
Deliverables: [path]
Open questions for the next role: [question: context]
Acceptance criteria for the next step: [criterion]
```

### Decision log entry (append to the synthesis and to active.md)
```
DECISION: [what]   BY: [role or user]   DATE: [date]
AFFECTS: [roles/domains]   IMPACT: [downstream change]
STATUS: [notified / acknowledged / contested]
```
Decisions that constrain another domain need that domain's acknowledgment before work proceeds
(`${CLAUDE_PLUGIN_ROOT}/docs/coordination-rules.md`, change propagation).

### Coordination status
```
COORDINATION STATUS: [feature]   [date]
| Role | Work package | Status | Blocked on |
|---|---|---|---|
| gameforge:game-designer | Mechanics spec | Done | - |
| gameforge:game-technical-director | Architecture | In progress | - |
| gameforge:game-ux-designer | Feedback design | Waiting | Architecture |
Active blockers: [role] needs [artifact] from [role]; escalate by [date]
Pending decisions: [decision] with [resolver] since [date]
Next checkpoint: [condition]
```

### Stuck work package
A package is stuck after three divergent revisions, or when it waits on a conflict the escalation
path has not resolved. Diagnose: missing input (re-brief the upstream role with a deadline),
unclear requirements (ask the user, then re-brief with a narrower question), or unresolved conflict
(escalate one level: Producer for scope, Creative Director for vision, Technical Director for
architecture). Never let a role spin.

### Feature completion report
```
FEATURE COMPLETE: [name]   Recipe: [n or custom]   Dates: [start - end]
Roles involved: [list]    Waves run: [n]    Subagent runs: [n]
Key decisions: [top three, with role and rationale]
Conflicts and rulings: [top two]
Artifacts: [path - role]
Open items: [deferred to sprint / post-launch]
Coordination lessons: [what to repeat] [what to change]
```
