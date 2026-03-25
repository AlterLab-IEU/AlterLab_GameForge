# AlterLab GameForge -- Agent Hierarchy

This document defines the organizational structure, decision authority, and escalation paths for all GameForge agents.

## Three-Tier Structure

```
Tier 1 -- Leadership
├── Creative Director (creative vision, pillar guardianship, tone)
├── Technical Director (architecture, performance, tech stack)
└── Producer (schedule, scope, resources, cross-domain mediation)

Tier 2 -- Department Leads
├── Game Designer (mechanics, systems, balance, progression)
├── Art Director (visual identity, asset pipeline, UI art, VFX)
├── Audio Director (sonic identity, adaptive audio, mixing, music)
├── Narrative Director (story, dialogue, world-building, lore)
├── QA Lead (testing strategy, release gates, regression, coverage)
└── UX Designer (accessibility, onboarding, player feedback, usability)

Tier 3 -- Specialists
├── Godot Specialist (GDScript, signals, shaders, scene tree)
├── Unity Specialist (DOTS, Shader Graph, Addressables, C#)
└── Unreal Specialist (GAS, Blueprint/C++, Nanite, Lumen)
```

## Decision Authority

Each tier has a defined scope of authority. Agents make decisions within their scope and escalate beyond it.

**Tier 1 -- Leadership**: Sets the direction for their entire domain. Creative director owns the creative vision. Technical director owns the architecture. Producer owns the schedule and scope.

**Tier 2 -- Department Leads**: Makes decisions within their specialty that align with Tier 1 direction. The game designer decides mechanical details without needing creative director approval for every variable -- but the creative director can override if a mechanic contradicts the pillars.

**Tier 3 -- Specialists**: Makes engine-specific implementation decisions within the constraints set by Tier 2. The Godot specialist decides which node types to use -- but the technical director sets the performance budget, and the game designer defines the behavior.

## Escalation Paths

When an agent encounters a decision beyond their authority, they escalate:

| Agent | Escalates To | For |
|---|---|---|
| Game Designer | Creative Director | Mechanic conflicts with creative pillars |
| Art Director | Creative Director | Visual style direction, cross-art-domain conflicts |
| Audio Director | Creative Director | Sonic identity direction, audio-visual sync disputes |
| Narrative Director | Creative Director | Story direction, tone conflicts |
| QA Lead | Technical Director | Technical quality standards, release readiness |
| UX Designer | Technical Director | Implementation feasibility of UX patterns |
| Engine Specialists | Technical Director | Architecture decisions, platform limitations |
| Creative Director | Producer | Creative scope vs. schedule trade-offs |
| Technical Director | Producer | Technical scope vs. schedule trade-offs |
| Any Agent | Producer | Cross-domain conflicts, resource requests |

## Conflict Resolution Routes

Conflicts are routed by type, not by seniority:

**Creative conflicts** (art vs. narrative, mechanics vs. tone, audio vs. visual style):
Route to Creative Director. The creative director evaluates against the project's pillars and makes a binding decision.

**Technical conflicts** (performance vs. features, architecture trade-offs, platform constraints):
Route to Technical Director. The technical director evaluates against architecture principles and performance targets.

**Cross-domain conflicts** (creative ambition vs. technical feasibility, quality vs. timeline):
Route to Producer for mediation. The producer convenes the relevant directors, facilitates negotiation, and ensures the user makes the final call on unresolvable trade-offs.

**Scope conflicts** (adding features, cutting features, timeline changes):
Route to Producer. The producer evaluates against the cut list, burndown data, and milestone commitments. Presents options to the user.

## Delegation Map (Global)

When any agent needs work from another domain, they follow this routing:

| Need | Route To | Through |
|---|---|---|
| Creative direction | Creative Director | Direct (Tier 1 access) |
| Technical guidance | Technical Director | Direct (Tier 1 access) |
| Schedule/scope decision | Producer | Direct (Tier 1 access) |
| Mechanic design | Game Designer | Via Creative Director or direct if scoped |
| Visual assets | Art Director | Via Creative Director or direct if scoped |
| Audio assets | Audio Director | Via Creative Director or direct if scoped |
| Story/dialogue | Narrative Director | Via Creative Director or direct if scoped |
| Testing | QA Lead | Via Technical Director or direct if scoped |
| UX review | UX Designer | Via Technical Director or direct if scoped |
| Engine implementation | Engine Specialist | Via Technical Director |
| Multi-agent coordination | Team Orchestrator | Via Producer |
