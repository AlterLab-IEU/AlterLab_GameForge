# AlterLab GameForge -- Agent Hierarchy

This document defines the organizational structure, decision authority, and escalation paths for all GameForge agents.

## Three-Tier Structure

```
Tier 1 -- Leadership
├── Creative Director (creative vision, pillar guardianship, tone, AI-use stance)
├── Technical Director (architecture, performance, tech stack, agent/MCP security)
└── Producer (schedule, scope, resources, cross-domain mediation)

Tier 2 -- Department Leads
├── Game Designer (mechanics, systems, balance, progression)
├── Economy Designer (currencies, sinks and faucets, pricing, monetization ethics)
├── Art Director (visual identity, asset pipeline, UI art, VFX, AI-asset policy)
├── Audio Director (sonic identity, adaptive audio, mixing, music, voice rights)
├── Narrative Director (story, dialogue, world-building, lore)
├── QA Lead (testing strategy, release gates, regression, coverage)
├── UX Designer (onboarding, HUD and menus, player feedback, usability)
└── Accessibility Specialist (motor, visual, auditory, cognitive access; EAA compliance)

Tier 3 -- Specialists
├── Godot Specialist (GDScript/C#, scenes, signals, shaders, exports)
├── Unity Specialist (C#, URP/HDRP, DOTS, Addressables, Unity AI)
├── Unreal Specialist (C++/Blueprints, GAS, Nanite, Lumen, editor scripting)
├── Three.js Specialist (Three.js, React Three Fiber, WebGPU/WebGL, glTF)
└── 2D Web Specialist (Phaser, PixiJS, Kaplay, Excalibur)
```

The creative-side leads (Game Designer, Economy Designer, Art, Audio, Narrative) report to the
Creative Director; QA Lead, UX Designer, Accessibility Specialist and the engine specialists report to
the Technical Director. Workflows (sprint plans, launches, playtests) are processes that any role can
run; they carry no authority of their own.

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
| Accessibility Specialist | Technical Director | Implementation of accommodations (advises on design intent) |
| Economy Designer | Producer | Revenue vs. player trust (advises; Producer decides) |
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
| Accessibility review | Accessibility Specialist | Via Technical Director or direct if scoped |
| Economy or monetization | Economy Designer | Via Creative Director or direct if scoped |
| Engine implementation | Engine Specialist | Via Technical Director |
| Multi-agent coordination | Team Orchestrator | Via Producer |

## Running as Subagents

The eleven Tier 1 and Tier 2 roles also ship as plugin subagents (`agents/` in the plugin, addressed
as `gameforge:game-creative-director`, `gameforge:game-designer`, and so on). Each loads its role from
the matching skill and adds three behaviours:

1. **No questions.** Subagents cannot ask the user anything. They label assumptions
   (`ASSUMPTION:`) and return open questions in their report.
2. **Project memory.** Each keeps a project-scoped memory of decisions it made, accepted and rejected
   proposals, and constraints it discovered, so the fifth consultation agrees with the first.
3. **Fixed report format.** Verdict, key points, artifacts written, assumptions, open questions and
   hand-offs, so `/gameforge:game-team-orchestrator` can synthesize several reports at once.

Authority does not change when a role runs as a subagent: a subagent flags a cross-domain conflict for
the orchestrating conversation, which routes it by the rules above. Parallel consultations are
budgeted (the orchestrator defaults to at most four at once; the subagent hook warns above six).

