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
