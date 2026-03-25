# GameForge Workflow Guide -- Development Lifecycle

This document maps the complete game development lifecycle to GameForge skills and agents. Use it to understand which tools to invoke at each project phase, what outputs each phase produces, and which templates support the work.

All 25 skills (9 agents, 10 workflows, 3 engine specialists, 3 meta skills) and 10 templates are mapped below. Phases overlap in practice -- pre-production bleeds into prototyping, production runs parallel to testing -- but the sequence defines the primary focus at each stage.

---

## Phase 0: Ideation

The spark. Raw ideas are generated, filtered, and shaped into viable game concepts.

- **Trigger**: `/game-brainstorm`
- **Agents**: Creative Director, Game Designer
- **Skills Used**: `game-brainstorm`, `game-creative-director`, `game-designer`
- **Templates**: `game-concept.md`
- **Output**: Game concept document, core loop definition, initial design pillars (3-5), target audience profile, competitive landscape sketch
- **Theory Reference**: MDA Framework (desired Aesthetics drive ideation), Quantic Foundry (target audience motivations), Design Pillars Methodology (Section 17)

**Phase Gate**: Concept must articulate the core loop in one sentence, identify 3-5 design pillars, and name the target player motivations. If it cannot, return to brainstorming.

---

## Phase 1: Pre-Production

The concept becomes a plan. Architecture is defined, the GDD takes shape, and the team structure is established.

- **Trigger**: `/game-start [engine]`
- **Agents**: Technical Director, Creative Director, Producer, Game Designer
- **Skills Used**: `game-start`, `game-creative-director`, `game-technical-director`, `game-producer`, `game-designer`
- **Templates**: `game-design-document.md`, `game-concept.md`, `architecture-decision-record.md`
- **Output**: Project scaffold (engine-specific), GDD draft, technical architecture document, production schedule draft, tool pipeline decisions

**Key Activities**:
- Technical Director selects engine and defines architecture (Godot 4.6 / Unity 6.3 / Unreal 5.7)
- Creative Director finalizes design pillars and creative brief
- Game Designer writes the full GDD with mechanics, formulas, and edge cases
- Producer builds the initial milestone plan and sprint cadence

**Phase Gate**: GDD passes `game-design-review`. Architecture Decision Records are filed. Engine specialist confirms the technical approach is viable.

---

## Phase 2: Prototyping

Test the riskiest assumptions before committing to full production. Build the minimum viable interaction.

- **Trigger**: `/game-prototype`
- **Agents**: Game Designer, Technical Director
- **Skills Used**: `game-prototype`, `game-designer`, `game-technical-director`, engine specialist (Godot/Unity/Unreal)
- **Templates**: `game-design-document.md` (prototype section)
- **Output**: Playable prototype proving the core loop, prototype playtest report, go/kill/iterate decision

**Key Activities**:
- Game Designer defines the hypothesis the prototype must test
- Engine Specialist builds the prototype with placeholder assets (target: 1-3 days)
- `game-playtest` validates or invalidates the core loop hypothesis
- Creative Director decides: promote to production, iterate, or kill

**Phase Gate**: Prototype playtest confirms the core loop is engaging with placeholder art. If it is not fun without polish, the mechanic needs redesign -- not more juice (see Game Feel, Oil Framework in theory reference).

---

## Phase 3: Vertical Slice

Build one complete, polished slice of the game that represents final quality across all disciplines.

- **Trigger**: `/game-team-orchestrator` (coordinates all agents)
- **Agents**: All 9 agents
- **Skills Used**: `game-team-orchestrator`, `game-creative-director`, `game-art-director`, `game-audio-director`, `game-narrative-director`, `game-designer`, `game-technical-director`, `game-ux-designer`, `game-qa-lead`, `game-producer`, engine specialist
- **Templates**: `art-bible.md`, `sound-bible.md`, `character-sheet.md`, `level-design-document.md`
- **Output**: One fully polished level/area/sequence, art bible, sound bible, all pipelines validated end-to-end

**Key Activities**:
- Art Director establishes the visual style and produces the art bible
- Audio Director establishes the audio identity and produces the sound bible
- Narrative Director writes sample dialogue and establishes voice/tone
- UX Designer defines the interaction model and accessibility baseline
- QA Lead establishes the test framework and quality gates

**Phase Gate**: The vertical slice is indistinguishable from the intended final quality. All team members agree it represents the target experience. External playtesters validate.

---

## Phase 4: Production

The bulk of content creation. All systems are built, all content is authored, all assets are produced.

- **Trigger**: `/game-sprint-plan` (repeated per sprint)
- **Agents**: All 9 agents in their respective domains
- **Skills Used**: `game-sprint-plan`, `game-designer`, `game-narrative-director`, `game-art-director`, `game-audio-director`, `game-technical-director`, `game-ux-designer`, `game-qa-lead`, `game-producer`, engine specialist, `game-team-orchestrator`
- **Templates**: `sprint-plan.md`, `level-design-document.md`, `character-sheet.md`, `economy-model.md`
- **Output**: All game content, systems, levels, characters, audio, UI -- the complete game

**Key Activities**:
- Producer runs sprint cycles (see Named Workflow Pattern 5 in coordination-rules.md)
- New features follow Pattern 1 (New Feature) from coordination-rules.md
- Bugs follow Pattern 2 (Bug Fix)
- New areas follow Pattern 4 (New Area/Level)
- `game-balance-check` runs regularly to validate economy and difficulty curves
- `game-code-review` reviews all code submissions

**Phase Gate**: Milestone checkpoints (Pattern 6) at alpha and beta. All planned features are implemented. No severity-1 bugs remain open.

---

## Phase 5: Balance & Tuning

Systematic adjustment of all gameplay values based on data and playtesting.

- **Trigger**: `/game-balance-check`
- **Agents**: Game Designer, QA Lead, Producer
- **Skills Used**: `game-balance-check`, `game-designer`, `game-playtest`, `game-qa-lead`
- **Templates**: `economy-model.md`
- **Output**: Tuned gameplay values, balance report, economy validation, difficulty curve verification

**Key Activities**:
- Game Designer analyzes playtest data and telemetry
- `game-balance-check` runs quantitative analysis on progression curves, damage formulas, resource economies, and drop rates
- Balance adjustments follow Pattern 3 (Balance Adjustment) from coordination-rules.md
- All tunable values live in external config (see coding-standards.md, Data-Driven Gameplay Values)

**Phase Gate**: Playtest completion rates match design targets. Economy sinks and faucets balance within acceptable variance. Difficulty curve follows the Flow Channel (theory reference, Section 3).

---

## Phase 6: Playtesting

Structured testing with real players to validate design assumptions and find experiential issues automated testing cannot.

- **Trigger**: `/game-playtest`
- **Agents**: QA Lead, Game Designer, UX Designer, Producer
- **Skills Used**: `game-playtest`, `game-qa-lead`, `game-ux-designer`, `game-designer`
- **Templates**: (playtest report generated by `game-playtest`)
- **Output**: Playtest session reports, usability findings, player behavior heatmaps, onboarding effectiveness data

**Key Activities**:
- UX Designer designs playtest protocols and observation criteria
- QA Lead manages test environments and data collection
- Game Designer interprets player behavior patterns and proposes design changes
- Producer prioritizes playtest-driven changes against the remaining schedule

**Phase Gate**: Core loop engagement meets target metrics. Onboarding effectiveness is validated (see Onboarding Taxonomy, theory reference Section 16). No critical usability blockers remain.

---

## Phase 7: Polish & Optimization

Performance optimization, visual polish, audio mastering, and the final quality push.

- **Trigger**: `/game-code-review` (performance focus), `/game-team-orchestrator`
- **Agents**: Technical Director, Art Director, Audio Director, QA Lead, UX Designer
- **Skills Used**: `game-code-review`, `game-technical-director`, `game-art-director`, `game-audio-director`, `game-qa-lead`, `game-ux-designer`, engine specialist
- **Templates**: None (work is iterative on existing assets)
- **Output**: Optimized build meeting performance targets, polished visuals and audio, final accessibility audit

**Key Activities**:
- Technical Director and engine specialist optimize for target hardware (frame rate, memory, load times)
- Art Director oversees final visual polish pass
- Audio Director completes final audio mix and mastering
- UX Designer runs final accessibility audit against platform certification requirements
- QA Lead runs full regression suite

**Phase Gate**: Game runs at target frame rate on minimum spec hardware. Accessibility compliance verified. All severity-1 and severity-2 bugs resolved.

---

## Phase 8: Release Preparation

Store submissions, marketing assets, platform certification, and launch logistics.

- **Trigger**: `/game-launch`
- **Agents**: Producer, Art Director, QA Lead, Technical Director
- **Skills Used**: `game-launch`, `game-producer`, `game-art-director`, `game-qa-lead`, `game-technical-director`
- **Templates**: `release-checklist.md`
- **Output**: Store page copy, marketing screenshots, submission build, certification test results, launch-day plan

**Key Activities**:
- `game-launch` generates store metadata, descriptions, and submission checklists
- Art Director finalizes store assets (screenshots, capsule art, trailer frames)
- QA Lead runs platform-specific certification tests (console TRCs/XRs)
- Technical Director validates build packaging and distribution pipeline
- Producer coordinates the Release Pipeline (Pattern 7 from coordination-rules.md)

**Phase Gate**: Platform certification passed. Store page approved. Launch-day monitoring plan in place.

---

## Phase 9: Launch

The game goes live. Monitoring, rapid response, and community engagement begin.

- **Trigger**: Release date (coordinated by Producer)
- **Agents**: Producer, QA Lead, Technical Director
- **Skills Used**: `game-producer`, `game-qa-lead`, `game-technical-director`, engine specialist
- **Templates**: None (operational phase)
- **Output**: Launch telemetry reports, hotfix builds (if needed), community response tracking

**Key Activities**:
- Producer coordinates launch-day monitoring across all platforms
- QA Lead monitors crash reports, player-reported bugs, and telemetry anomalies
- Technical Director manages hotfix pipeline for critical launch issues
- Bug fixes follow Pattern 2 (Bug Fix) with expedited timelines
- Live events (if applicable) follow Pattern 9 (Live Event) from coordination-rules.md

**Phase Gate**: Launch-week stability targets met. No critical crashes above threshold. Player retention metrics within acceptable range.

---

## Phase 10: Post-Launch

Retrospective, update planning, and ongoing support.

- **Trigger**: `/game-team-orchestrator` (retrospective mode)
- **Agents**: Producer, all department leads (Creative Director, Technical Director, Game Designer, QA Lead)
- **Skills Used**: `game-producer`, `game-creative-director`, `game-technical-director`, `game-designer`, `game-qa-lead`, `game-sprint-plan` (for update planning)
- **Templates**: (post-mortem generated during retrospective)
- **Output**: Post-mortem document (lessons learned, process improvements), update roadmap, DLC/expansion planning, live event calendar

**Key Activities**:
- Producer facilitates the project retrospective with all agents
- Team documents what worked, what did not, and what to change for the next project
- Game Designer analyzes player data to identify update priorities
- Producer builds the post-launch update roadmap
- Balance adjustments continue based on live player data (Pattern 3)

**Phase Gate**: Retrospective completed and documented. Update roadmap published. Process improvements captured for the next project.

---

## Quick Reference: Skill-to-Phase Mapping

| Skill | Primary Phases | Type |
|---|---|---|
| `game-brainstorm` | 0 | Workflow |
| `game-start` | 1 | Workflow |
| `game-prototype` | 2 | Workflow |
| `game-design-review` | 1, 3 | Workflow |
| `game-sprint-plan` | 4, 10 | Workflow |
| `game-code-review` | 4, 7 | Workflow |
| `game-balance-check` | 4, 5, 10 | Workflow |
| `game-playtest` | 2, 3, 4, 5, 6 | Workflow |
| `game-launch` | 8 | Workflow |
| `game-team-orchestrator` | 3, 4, 7, 10 | Workflow |
| `game-creative-director` | 0, 1, 2, 3, 10 | Agent |
| `game-technical-director` | 1, 2, 4, 7, 8, 9, 10 | Agent |
| `game-producer` | 1, 4, 5, 6, 7, 8, 9, 10 | Agent |
| `game-designer` | 0, 1, 2, 4, 5, 6, 10 | Agent |
| `game-narrative-director` | 3, 4 | Agent |
| `game-art-director` | 3, 4, 7, 8 | Agent |
| `game-audio-director` | 3, 4, 7 | Agent |
| `game-qa-lead` | 3, 4, 5, 6, 7, 8, 9, 10 | Agent |
| `game-ux-designer` | 3, 4, 6, 7 | Agent |
| `game-godot-specialist` | 2, 3, 4, 7, 9 | Engine |
| `game-unity-specialist` | 2, 3, 4, 7, 9 | Engine |
| `game-unreal-specialist` | 2, 3, 4, 7, 9 | Engine |

## Quick Reference: Template-to-Phase Mapping

| Template | Primary Phase | Created By |
|---|---|---|
| `game-concept.md` | 0, 1 | Creative Director, Game Designer |
| `game-design-document.md` | 1, 2 | Game Designer |
| `architecture-decision-record.md` | 1 | Technical Director |
| `art-bible.md` | 3 | Art Director |
| `sound-bible.md` | 3 | Audio Director |
| `character-sheet.md` | 3, 4 | Game Designer, Narrative Director |
| `level-design-document.md` | 3, 4 | Game Designer |
| `economy-model.md` | 4, 5 | Game Designer |
| `sprint-plan.md` | 4 | Producer |
| `release-checklist.md` | 8 | Producer |
