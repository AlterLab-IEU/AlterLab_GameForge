# GameForge Workflow Guide -- Development Lifecycle

This guide maps the game development lifecycle to GameForge skills. Use it to decide which skill to
run at each phase, what each phase should produce, and which templates support the work. If you only
want a recommendation for right now, run `/gameforge:game-help`.

All 41 skills (11 studio agents, 25 workflows, 5 engine specialists), the 11 studio subagents, the 7
hooks and the 21 templates are mapped below. Phases overlap in practice -- pre-production bleeds into
prototyping, production runs alongside testing -- but the sequence defines the primary focus of each
stage. Two lanes run through it:

- **Full lane** (phases 0-10): a commercial project with a schedule, a team (even a team of one plus
  agents), and a store launch.
- **Fast lane** (below): an AI-built game for a jam, a portal, or a weekend, where "playable tonight"
  matters more than a GDD.

Engine choices referenced here are current as of November 2026: Godot 4.7 (4.8 in beta), Unity 6.3
LTS / 6.6, Unreal Engine 5.8, Three.js r187, Phaser 4. See [engine-comparison.md](engine-comparison.md).

---

## Fast Lane: AI-Built Web Game (hours to days)

| Step | Run | Output |
|---|---|---|
| 1. Pick an idea worth 5-10 minutes of play | `/gameforge:game-brainstorm` | Three original concepts, one chosen |
| 2. Spec, scaffold, build in verified iterations | `/gameforge:game-vibe-code` | Playable build, `progress.md`, git checkpoints |
| 3. Engine depth when the agent gets stuck | `/gameforge:game-threejs-specialist`, `/gameforge:game-web2d-specialist` | Correct, current API usage |
| 4. Art and audio | `/gameforge:game-ai-assets` | Consistent assets plus a provenance log |
| 5. Online play (optional) | `/gameforge:game-multiplayer` | Server-authoritative netcode plan |
| 6. Ship | `/gameforge:game-web-publish` | itch.io / portal build within size limits, disclosures |

Jams add `/gameforge:game-jam-mode` in front for theme analysis and an hour-by-hour plan. Anything
that survives the fast lane and becomes a real project re-enters the full lane at Phase 1 through
`/gameforge:game-start`, with `/gameforge:game-reverse-document` to catch up the design docs.

Principles that hold in both lanes are in [vibe-coding.md](vibe-coding.md): every step ends in a
check, keep original IP, log every generated asset, and plan distribution rather than hoping for a
viral spike.

---

## Phase 0: Ideation

The spark. Raw ideas are generated, filtered and shaped into viable concepts.

- **Run**: `/gameforge:game-brainstorm`, then `/gameforge:game-market-research`
- **Roles**: Creative Director, Game Designer
- **Templates**: `game-concept.md`, `game-pillars.md`, `competitive-analysis.md`
- **Output**: Concept document, core loop in one sentence, 3-5 pillars, target player motivations,
  comparable titles
- **Theory**: MDA (start from the desired aesthetics), player motivation models, design pillars
  ([game-design-theory.md](game-design-theory.md))

**Phase gate**: the concept states its core loop in one sentence, names 3-5 pillars and its target
players, and is original (no recreation of an existing game). Otherwise return to brainstorming.

---

## Phase 1: Pre-Production

The concept becomes a plan.

- **Run**: `/gameforge:game-start` (creates `.gameforge/project.json`, copies the engine starter,
  sets up Git LFS and the session state that GameForge's hooks use)
- **Roles**: Technical Director, Creative Director, Producer, Game Designer
- **Also**: `/gameforge:game-gdd-author`, `/gameforge:game-design-review`, `/gameforge:game-scope-check`
- **Templates**: `game-design-document.md`, `architecture-decision-record.md`, `systems-index.md`,
  `ai-content-policy.md`
- **Output**: Project scaffold, GDD draft, architecture decisions, milestone plan, an explicit AI-use
  policy (what agents and generators may touch, and how it is disclosed)

**Key activities**
- Technical Director chooses the engine and architecture, including which agent integrations (MCP
  servers, engine AI assistants) are allowed and how they are secured
- Creative Director finalizes pillars and the AI-use stance
- Game Designer writes the GDD with testable acceptance criteria and exposed tuning knobs
- Producer sets milestones against engine support windows and regulatory dates

**Phase gate**: the GDD passes `/gameforge:game-design-review`; ADRs are filed; the engine specialist
confirms the approach is viable.

---

## Phase 2: Prototyping

Test the riskiest assumption before committing to production.

- **Run**: `/gameforge:game-prototype` (one question, throwaway code) or `/gameforge:game-vibe-code`
  (when the prototype should grow into the game)
- **Roles**: Game Designer, Technical Director, engine specialist
- **Output**: A playable answer to one question, a short playtest report, a go / iterate / kill call

**Phase gate**: the core loop is engaging with placeholder art. If it is not fun without polish, the
mechanic needs redesign, not more juice.

---

## Phase 3: Vertical Slice

One complete slice at final quality across every discipline.

- **Run**: `/gameforge:game-team-orchestrator` (delegates to the studio subagents in parallel)
- **Roles**: all eleven
- **Also**: `/gameforge:game-ai-assets` for asset pipelines, `/gameforge:game-multiplayer` if online
- **Templates**: `art-bible.md`, `sound-bible.md`, `character-sheet.md`, `level-design-document.md`,
  `ai-asset-log.md`
- **Output**: One polished level or sequence, art and sound bibles, pipelines proven end to end

**Phase gate**: the slice represents the intended final quality and external playtesters confirm it.

---

## Phase 4: Production

The bulk of content and systems.

- **Run**: `/gameforge:game-sprint-plan` each sprint; `/gameforge:game-code-review` on every
  significant change (especially agent-generated changes)
- **Roles**: all eleven in their domains, plus the engine specialist
- **Also**: `/gameforge:game-balance-check`, `/gameforge:game-localization-manager`,
  `/gameforge:game-analytics-setup`, `/gameforge:game-ci-pipeline`, `/gameforge:game-retrospective`
- **Templates**: `sprint-plan.md`, `level-design-document.md`, `character-sheet.md`,
  `economy-model.md`, `ci-pipeline-config.md`
- **Output**: The complete game

**Key activities**
- Each sprint budgets review and verification time for agent-written code, and a slot for paying
  down vibe debt
- New features, bug fixes, balance changes and new areas follow the named patterns in
  [coordination-rules.md](coordination-rules.md)
- Every generated asset is logged in `ai-asset-log.md` as it lands, not at launch

**Phase gate**: alpha and beta milestone reviews pass; no severity-1 bugs open.

---

## Phase 5: Balance & Tuning

- **Run**: `/gameforge:game-balance-check`
- **Roles**: Game Designer, Economy Designer, QA Lead
- **Templates**: `economy-model.md`; genre balance templates in `genre-packs/`
- **Output**: Tuned values backed by simulation and playtest data, economy validation

**Phase gate**: completion rates match design targets; sinks and faucets balance; the difficulty
curve stays inside the flow channel.

---

## Phase 6: Playtesting

- **Run**: `/gameforge:game-playtest`
- **Roles**: QA Lead, Game Designer, UX Designer, Accessibility Specialist
- **Templates**: `playtester-survey.md`
- **Output**: Session reports, usability findings, onboarding data. AI playtest agents and feedback
  summarizers supplement human sessions; they do not replace them.

**Phase gate**: core loop engagement meets targets; no critical usability or accessibility blockers.

---

## Phase 7: Polish & Optimization

- **Run**: `/gameforge:game-code-review` (performance focus), engine specialist, `/gameforge:game-team-orchestrator`
- **Roles**: Technical Director, Art Director, Audio Director, QA Lead, UX Designer, Accessibility Specialist
- **Templates**: `accessibility-audit.md`
- **Output**: Build at target frame rate on minimum spec (including mobile web if targeted), final
  mix, accessibility audit

**Phase gate**: performance targets met; accessibility verified (European Accessibility Act scope
where it applies); severity-1 and severity-2 bugs resolved.

---

## Phase 8: Release Preparation

- **Run**: `/gameforge:game-launch` (Steam, consoles, mobile stores) or `/gameforge:game-web-publish`
  (itch.io, web portals, Discord Activities, YouTube Playables)
- **Roles**: Producer, Art Director, QA Lead, Technical Director
- **Templates**: `release-checklist.md`, `ai-asset-log.md` (source of every AI disclosure)
- **Output**: Store pages, submission builds, certification results, AI-content disclosures, launch plan

**Phase gate**: certification passed; store pages approved; disclosures filed (Steam AI survey, EU AI
Act Article 50 where applicable); launch-day monitoring in place.

---

## Phase 9: Launch

- **Run**: `/gameforge:game-producer`, `/gameforge:game-qa-lead`, `/gameforge:game-analytics-setup`
- **Output**: Launch telemetry, hotfixes, community response tracking

**Phase gate**: launch-week stability targets met; retention within the expected range.

---

## Phase 10: Post-Launch

- **Run**: `/gameforge:game-postmortem`, `/gameforge:game-retrospective`, `/gameforge:game-sprint-plan`
  (updates), `/gameforge:game-reverse-document` (capture undocumented systems)
- **Templates**: `post-mortem.md`
- **Output**: Post-mortem (including what agents did well and badly, and what review cost), update
  roadmap, process changes for the next project

---

## Quick Reference: Skill-to-Phase Mapping

| Skill | Primary phases | Type |
|---|---|---|
| `game-help` | any | Workflow |
| `game-brainstorm` | 0, fast lane | Workflow |
| `game-market-research` | 0, 1 | Workflow |
| `game-start` | 1 | Workflow |
| `game-gdd-author` | 1, 2 | Workflow |
| `game-design-review` | 1, 3 | Workflow |
| `game-scope-check` | 1, 4, 5 | Workflow |
| `game-prototype` | 2 | Workflow |
| `game-vibe-code` | 2, fast lane | Workflow |
| `game-jam-mode` | fast lane | Workflow |
| `game-ai-assets` | 3, 4, fast lane | Workflow |
| `game-multiplayer` | 1, 3, 4 | Workflow |
| `game-team-orchestrator` | 3, 4, 7, 10 | Workflow |
| `game-sprint-plan` | 4, 10 | Workflow |
| `game-code-review` | 4, 7 | Workflow |
| `game-reverse-document` | 1, 10 | Workflow |
| `game-ci-pipeline` | 4, 8 | Workflow |
| `game-balance-check` | 4, 5, 10 | Workflow |
| `game-playtest` | 2, 3, 4, 5, 6 | Workflow |
| `game-localization-manager` | 4, 8 | Workflow |
| `game-analytics-setup` | 4, 9, 10 | Workflow |
| `game-launch` | 8 | Workflow |
| `game-web-publish` | 8, fast lane | Workflow |
| `game-retrospective` | 4, 10 | Workflow |
| `game-postmortem` | 10 | Workflow |
| `game-creative-director` | 0, 1, 2, 3, 10 | Agent |
| `game-technical-director` | 1, 2, 4, 7, 8, 9, 10 | Agent |
| `game-producer` | 1, 4, 5, 6, 7, 8, 9, 10 | Agent |
| `game-designer` | 0, 1, 2, 4, 5, 6, 10 | Agent |
| `game-narrative-director` | 3, 4 | Agent |
| `game-art-director` | 3, 4, 7, 8 | Agent |
| `game-audio-director` | 3, 4, 7 | Agent |
| `game-qa-lead` | 3, 4, 5, 6, 7, 8, 9, 10 | Agent |
| `game-ux-designer` | 3, 4, 6, 7 | Agent |
| `game-economy-designer` | 4, 5 | Agent |
| `game-accessibility-specialist` | 3, 4, 7 | Agent |
| `game-godot-specialist` | 2, 3, 4, 7, 9 | Engine |
| `game-unity-specialist` | 2, 3, 4, 7, 9 | Engine |
| `game-unreal-specialist` | 2, 3, 4, 7, 9 | Engine |
| `game-threejs-specialist` | 2, 3, 4, 7, fast lane | Engine |
| `game-web2d-specialist` | 2, 3, 4, 7, fast lane | Engine |

The eleven studio agents also run as subagents (`gameforge:game-designer` and so on) that
`game-team-orchestrator` delegates to in parallel; see [agent-hierarchy.md](agent-hierarchy.md).

## Quick Reference: Template-to-Phase Mapping

| Template | Primary phase | Created by |
|---|---|---|
| `game-concept.md` | 0, 1 | Creative Director, Game Designer |
| `game-pillars.md` | 0, 1 | Creative Director |
| `competitive-analysis.md` | 0, 1 | `game-market-research` |
| `game-design-document.md` | 1, 2 | Game Designer, `game-gdd-author` |
| `architecture-decision-record.md` | 1 | Technical Director |
| `systems-index.md` | 1, 4 | Game Designer, Technical Director |
| `ai-content-policy.md` | 1 | Creative Director, Technical Director |
| `jam-concept.md` | fast lane | `game-jam-mode` |
| `jam-submission.md` | fast lane | `game-jam-mode` |
| `art-bible.md` | 3 | Art Director |
| `sound-bible.md` | 3 | Audio Director |
| `character-sheet.md` | 3, 4 | Game Designer, Narrative Director |
| `level-design-document.md` | 3, 4 | Game Designer |
| `ai-asset-log.md` | 3, 4, 8 | `game-ai-assets`, Art and Audio Directors |
| `economy-model.md` | 4, 5 | Economy Designer |
| `sprint-plan.md` | 4 | Producer |
| `ci-pipeline-config.md` | 4 | `game-ci-pipeline` |
| `playtester-survey.md` | 6 | `game-playtest` |
| `accessibility-audit.md` | 7 | Accessibility Specialist |
| `release-checklist.md` | 8 | Producer, `game-launch` |
| `post-mortem.md` | 10 | Producer, `game-postmortem` |

## Hooks Across the Lifecycle

GameForge's 7 hooks run in the background in every phase once a project is detected: a session
briefing (engine, phase, saved focus, gaps), a snapshot before compaction, commit and large-binary
checks, protection for engine-generated files, subagent tracking, and recovery notes after API
failures. See [hooks.md](hooks.md).
