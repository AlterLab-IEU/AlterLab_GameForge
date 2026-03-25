# AlterLab GameForge -- Coordination Rules

These rules govern how agents communicate, delegate, escalate, and resolve conflicts. Every agent must follow these rules when interacting with other agents. No exceptions.

## 1. Vertical Delegation

Decisions flow downward through the hierarchy defined in `@docs/agent-hierarchy.md`. Tier 1 (leadership) sets direction. Tier 2 (department leads) executes within their domain. Tier 3 (specialists) implements within their engine.

**Rule**: Never skip tiers for complex decisions. A producer does not tell an engine specialist how to implement a shader. The producer tells the technical director about a performance requirement, and the technical director works with the engine specialist on implementation.

**Simple requests** (factual questions, status checks) may skip tiers. Complex requests (design changes, architectural decisions, scope adjustments) must not.

## 2. Horizontal Consultation

Agents at the same tier may consult each other freely. The art director can ask the audio director about timing for synchronized audio-visual effects. The game designer can discuss narrative hooks with the narrative director.

**Rule**: Same-tier consultation is advisory, not binding. The art director cannot commit the audio director to a deliverable. Only vertical delegation creates commitments. Horizontal consultation shares information and aligns intent.

**Cross-domain binding decisions** (decisions that constrain another agent's work) require escalation to a shared parent or to the producer for coordination.

## 3. Conflict Resolution

Conflicts between agents are normal and expected. Different domains have legitimately competing priorities. The resolution path depends on the conflict type:

| Conflict Type | Resolver | Process |
|---|---|---|
| Creative vs. Creative | Creative Director | Both agents present their case. Creative director decides based on pillar alignment. |
| Technical vs. Technical | Technical Director | Both agents present constraints. Technical director decides based on architecture principles. |
| Creative vs. Technical | Producer mediates | Creative and technical directors negotiate. Producer ensures scope and schedule are respected. |
| Scope vs. Schedule | Producer | Producer evaluates trade-offs, presents options to user, executes user's decision. |
| Quality vs. Ship Date | Producer + QA Lead | QA presents risk assessment. Producer presents schedule impact. User decides. |

**Rule**: The resolver's decision is final for that conflict. Agents do not relitigate resolved conflicts. If new information emerges that changes the calculus, a new conflict may be raised -- but the original resolution stands until explicitly overturned.

## 4. Change Propagation

When a decision in one domain affects other domains, the producer coordinates notification and impact assessment.

**Process**:
1. The agent making the change notifies the producer of the change and its expected cross-domain impact.
2. The producer identifies all affected agents.
3. The producer communicates the change to affected agents with context and timeline.
4. Affected agents assess impact on their domain and report back.
5. If impact is significant, the producer convenes the affected agents for alignment.

**Rule**: No agent may make a change that affects another domain's work without going through this propagation process. Surprises between domains are production failures.

## 5. No Unilateral Cross-Domain Changes

An agent may not modify, override, or constrain another agent's deliverables without that agent's explicit agreement.

**Examples of violations**:
- The art director changing a UI layout that UX designed
- The game designer altering narrative branching without the narrative director's input
- The technical director disabling audio features for performance without the audio director's awareness

**The correct path**: Raise the issue, involve both domain owners, escalate to the appropriate resolver if they disagree.

## 6. File Ownership

Each agent has designated directories and file types within the project. Agents create and modify files within their domain. Cross-domain file modifications require the owning agent's involvement.

**Ownership does not mean isolation.** Other agents read and reference files across domains constantly. Ownership governs who writes, not who reads.

When `game-team-orchestrator` coordinates a multi-agent feature, it establishes temporary shared ownership for that feature's artifacts, with clear write-access assignments for each agent.

## 7. Named Workflow Patterns

The following patterns define the standard agent coordination sequences for common production scenarios. Each pattern names the workflow, lists the steps in order, and identifies the responsible agent or skill at each step. Agents should recognize these patterns by name and follow the prescribed sequence.

### Pattern 1: New Feature

Full lifecycle for adding a new gameplay feature, from concept to ship.

1. **Creative Director** defines the feature's creative intent and pillar alignment
2. **Game Designer** writes the feature specification (mechanics, rules, formulas, edge cases)
3. **Technical Director** architects the implementation (system design, dependencies, performance budget)
4. **Narrative Director** defines narrative integration (dialogue hooks, lore implications, story impact)
5. **Art Director** specifies visual requirements (asset list, style guidance, UI mockups)
6. **Audio Director** specifies audio requirements (SFX list, music cues, adaptive audio rules)
7. **UX Designer** designs the player-facing experience (interaction flow, accessibility requirements, onboarding)
8. `game-design-review` validates the design document against pillars and theory
9. Engine Specialist implements the feature (Godot/Unity/Unreal)
10. `game-code-review` reviews the implementation for standards compliance
11. **QA Lead** writes test cases and executes validation
12. `game-playtest` runs a focused playtest session on the feature
13. **Producer** signs off and schedules integration into the next build

### Pattern 2: Bug Fix

Rapid diagnosis-to-fix cycle for production bugs.

1. **QA Lead** documents the bug with reproduction steps, severity, and affected systems
2. **Technical Director** triages: assigns severity, identifies root cause domain, assigns to agent
3. Engine Specialist diagnoses the root cause at the code level
4. **Game Designer** assesses gameplay impact (does the fix change balance or player experience?)
5. Engine Specialist implements the fix
6. `game-code-review` reviews the fix for regression risk
7. **QA Lead** verifies the fix and runs regression tests
8. **Producer** approves the fix for merge into the target build

### Pattern 3: Balance Adjustment

Iterative tuning of gameplay values based on data or feedback.

1. **Game Designer** identifies the balance issue (from playtest data, analytics, or player feedback)
2. `game-balance-check` runs quantitative analysis on current values and their systemic impact
3. **Game Designer** proposes new values with rationale and predicted outcomes
4. **Technical Director** validates that the change is data-driven (external config, not code change)
5. **QA Lead** runs automated balance tests against edge cases
6. `game-playtest` validates the adjusted values with playtesters
7. **Producer** approves the balance change for the next build

### Pattern 4: New Area/Level

Creating a new playable area, level, or zone.

1. **Creative Director** defines the area's thematic intent and narrative purpose
2. **Game Designer** specifies encounters, pacing, objectives, and progression flow
3. **Narrative Director** writes environmental narrative, dialogue, and lore elements
4. **Art Director** creates the visual design brief (style, lighting, palette, landmark design)
5. **Audio Director** designs the soundscape (ambient audio, music transitions, interactive audio)
6. Engine Specialist builds the level using the design specification
7. **UX Designer** reviews wayfinding, readability, and accessibility of the space
8. `game-playtest` runs navigation and pacing playtests
9. **QA Lead** validates completability, performance, and boundary testing

### Pattern 5: Sprint Cycle

Standard sprint workflow from planning to retrospective.

1. **Producer** defines sprint scope based on milestone goals and backlog priority
2. `game-sprint-plan` generates the sprint plan with task assignments and capacity allocation
3. **Technical Director** validates technical feasibility of the sprint scope
4. All agents execute assigned tasks within the sprint window
5. **QA Lead** runs end-of-sprint regression and new feature validation
6. **Producer** runs sprint review with stakeholders
7. **Producer** facilitates retrospective and adjusts process for the next sprint

### Pattern 6: Milestone Checkpoint

Quality gate for major milestone reviews (alpha, beta, gold).

1. **Producer** compiles milestone deliverables checklist against milestone criteria
2. **Creative Director** validates creative vision alignment across all deliverables
3. **Technical Director** validates performance targets, stability metrics, and technical debt status
4. **QA Lead** presents the bug dashboard: open bugs by severity, regression trends, test coverage
5. `game-playtest` runs a milestone playtest session with fresh testers
6. **UX Designer** runs accessibility audit against platform certification requirements
7. **Producer** compiles milestone report and makes go/no-go recommendation

### Pattern 7: Release Pipeline

End-to-end process from final build to store availability.

1. **Producer** initiates release freeze -- no new features, bug fixes only
2. **QA Lead** executes the full regression test suite
3. **Technical Director** validates build stability, platform compliance, and performance benchmarks
4. **UX Designer** completes final accessibility compliance review
5. `game-launch` generates store metadata, descriptions, and submission checklists
6. **Art Director** finalizes store assets (screenshots, capsule art, trailer assets)
7. **Audio Director** signs off on final audio mix and mastering
8. **QA Lead** runs platform-specific certification tests (console TRCs/XRs, store policies)
9. **Producer** submits the build to platform stores
10. **Producer** coordinates launch-day monitoring and rapid-response plan

### Pattern 8: Rapid Prototype

Fast iteration cycle for testing a new mechanic or concept before committing to full production.

1. **Creative Director** states the hypothesis the prototype must test
2. **Game Designer** defines the minimum mechanic set required to test the hypothesis
3. `game-prototype` generates the prototype scaffold with placeholder assets
4. Engine Specialist implements the prototype (target: 1-3 days of work)
5. `game-playtest` runs a focused playtest to validate or invalidate the hypothesis
6. **Game Designer** documents findings and recommendations
7. **Creative Director** decides: promote to full production, iterate, or kill
8. **Producer** schedules the outcome (production pipeline or backlog retirement)

### Pattern 9: Live Event

Planning and execution for time-limited in-game events (seasonal events, community challenges, limited-time modes).

1. **Creative Director** defines the event theme, duration, and creative direction
2. **Game Designer** designs event-specific mechanics, rewards, and progression
3. **Narrative Director** writes event narrative content (story hooks, dialogue, lore)
4. **Art Director** specifies event visual assets (themed UI, environment modifications, reward art)
5. **Audio Director** designs event audio (themed music, event-specific SFX)
6. **Technical Director** architects server-side event configuration and scheduling
7. Engine Specialist implements event systems and content
8. `game-balance-check` validates event reward economy against the base game economy
9. **QA Lead** tests event activation, deactivation, edge cases, and timezone handling
10. `game-playtest` runs a pre-launch event playtest
11. **Producer** coordinates event go-live with marketing and community teams
12. **QA Lead** monitors live event telemetry and triages post-launch issues
