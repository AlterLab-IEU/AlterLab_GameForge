# AlterLab GameForge -- Indie Game Development Skills for Claude Code

## Project Overview

AlterLab GameForge is a collection of 34 production-grade Claude AI skills purpose-built for indie game development. The skills are organized into three categories:

- **11 Studio Agents** -- Specialized roles that emulate a full game studio team
- **20 Workflow Skills** -- Structured processes for common game dev tasks
- **3 Engine Specialists** -- Deep expertise for Godot, Unity, and Unreal Engine

Additionally, 2 genre packs (Roguelike, Narrative) provide genre-specific reference material.

Every skill is grounded in established game design theory (MDA Framework, Self-Determination Theory, Flow Theory, Bartle's Player Types) and delivers structured, actionable output.

## Shared Documentation

All skills reference a common knowledge base. These docs provide the theoretical and procedural foundation:

- `@docs/collaboration-protocol.md` -- How agents hand off work, share context, and avoid duplication
- `@docs/game-design-theory.md` -- MDA Framework, Flow Theory, SDT, Bartle taxonomy, and design lenses
- `@docs/coordination-rules.md` -- Turn order, conflict resolution, escalation paths between agents
- `@docs/agent-hierarchy.md` -- Reporting structure and decision authority for all 11 agents
- `@docs/coding-standards.md` -- Code style, architecture patterns, and engine-specific conventions
- `@docs/workflow-guide.md` -- 11-phase development lifecycle mapping all 31 skills to project phases
- `@docs/monetization-ethics.md` -- Ethical monetization framework, dark pattern identification, regulatory landscape
- `@docs/engine-comparison.md` -- Structured comparison matrix for Godot, Unity, and Unreal Engine
- `@docs/mcp-integrations.md` -- MCP server ecosystem for game dev, engine-specific recommendations, setup guides
- `@docs/ai-native-gamedev.md` -- AI tools for game development, production-ready vs experimental assessment
- `@docs/genre-pack-spec.md` -- Format specification for genre-specific enhancement packs
- `@docs/skill-quality-rubric.md` -- 5-dimension quality scoring system for skill evaluation

Always check these docs before answering game development questions. They contain the canonical standards for this project.

## Agent Hierarchy

The studio agents follow a clear hierarchy for decision-making:

```
Producer (coordination, schedule, scope)
  |
  +-- Creative Director (vision, pillars, tone)
  |     +-- Art Director (visual style, assets, UI art)
  |     +-- Audio Director (music, SFX, adaptive audio)
  |     +-- Narrative Director (story, dialogue, lore)
  |     +-- Game Designer (mechanics, systems, balance)
  |     +-- Economy Designer (currency flows, monetization, virtual economy)
  |
  +-- Technical Director (architecture, performance, tools)
        +-- QA Lead (testing, bug tracking, quality gates)
        +-- UX Designer (player experience, accessibility, usability)
        +-- Accessibility Specialist (inclusive design, EAA compliance, accommodations)
```

**Decision authority:**
- **Creative conflicts** (art style vs. narrative tone) -- Creative Director decides
- **Technical conflicts** (performance vs. feature scope) -- Technical Director decides
- **Scope conflicts** (feature cut vs. deadline) -- Producer decides
- **Cross-domain conflicts** (creative vs. technical tradeoffs) -- Producer mediates, Creative Director and Technical Director negotiate
- **Monetization conflicts** (revenue vs. player trust) -- Economy Designer advises, Producer decides
- **Accessibility conflicts** (accommodation vs. design intent) -- Accessibility Specialist advises, Technical Director decides implementation

## Skill Routing Rules

Route user requests to the correct skill based on intent:

### Agent Routing

| User Intent | Route To |
|---|---|
| Vision, pillars, creative direction, tone | `game-creative-director` |
| Architecture, performance, tech stack | `game-technical-director` |
| Schedule, scope, milestones, risk | `game-producer` |
| Mechanics, systems, balance, progression | `game-designer` |
| Story, dialogue, lore, worldbuilding | `game-narrative-director` |
| Visual style, asset pipeline, UI art | `game-art-director` |
| Music, SFX, adaptive audio, mixing | `game-audio-director` |
| Testing, bugs, quality gates, regression | `game-qa-lead` |
| Player experience, accessibility, usability | `game-ux-designer` |
| Virtual economy, currency design, monetization | `game-economy-designer` |
| Inclusive design, motor/visual/auditory/cognitive accommodations, EAA | `game-accessibility-specialist` |

### Workflow Routing

| User Intent | Route To |
|---|---|
| Starting a new game project | `game-start` |
| Ideation, brainstorming, concept exploration | `game-brainstorm` |
| Market research, competitive analysis, market sizing | `game-market-research` |
| Reviewing a game design document | `game-design-review` |
| Reviewing game code or architecture | `game-code-review` |
| Planning a development sprint | `game-sprint-plan` |
| Building a rapid prototype | `game-prototype` |
| Running a playtest session | `game-playtest` |
| Checking game balance and tuning | `game-balance-check` |
| Preparing for release or store submission | `game-launch` |
| Coordinating multiple agents on a task | `game-team-orchestrator` |
| Evaluating scope against timeline | `game-scope-check` |
| Running a sprint/milestone/project retrospective | `game-retrospective` |
| Running a post-mortem or project review | `game-postmortem` |
| Generating documentation from existing code | `game-reverse-document` |
| Translation, localization, internationalization (i18n) | `game-localization-manager` |
| Analytics, telemetry, KPIs, data-driven design | `game-analytics-setup` |
| Game jam participation (48-72 hour compressed development) | `game-jam-mode` |
| CI/CD pipeline setup, automated builds, deployment | `game-ci-pipeline` |
| Writing a game design document section by section | `game-gdd-author` |

### Engine Specialist Routing

Detect the game engine from project files and route accordingly:

| Detection Signal | Route To |
|---|---|
| `project.godot`, `.gd` files, `*.tscn` scenes | `game-godot-specialist` |
| `*.unity`, `*.cs` scripts, `ProjectSettings/` | `game-unity-specialist` |
| `*.uproject`, `*.cpp`/`*.h` with UE macros, Blueprints | `game-unreal-specialist` |

If no engine is detected, ask the user which engine they are targeting before routing.

## Hooks

The following hooks run automatically during Claude Code sessions:

| Hook | Event | Purpose |
|---|---|---|
| `session-start` | SessionStart | Initialize session state, load project context |
| `session-stop` | Stop | Save session state, write session log |
| `pre-compact` | PreCompact | Archive context before memory compaction |
| `validate-commit` | PreToolUse | Enforce commit message convention before git commits |
| `detect-gaps` | PostToolUse | Identify missing skill coverage in agent responses |
| `log-agent` | PostToolUse | Record which agents were invoked and their outputs |
| `post-compact` | PostCompact | Restore essential context after context compaction |
| `subagent-track` | SubagentStart/SubagentStop | Log subagent delegation for orchestration tracking |
| `instructions-validate` | InstructionsLoaded | Validate required docs exist when CLAUDE.md loads |
| `stop-failure` | StopFailure | Save session state and guide recovery on API errors |
| `config-change` | ConfigChange | Detect skill/config modifications during session |

## Templates

The `templates/` directory contains starter templates for common game development artifacts:

- Game Design Document (`game-design-document.md`)
- Game Concept (`game-concept.md`)
- Architecture Decision Record (`architecture-decision-record.md`)
- Sprint Plan (`sprint-plan.md`)
- Art Bible (`art-bible.md`)
- Sound Bible (`sound-bible.md`)
- Character Sheet (`character-sheet.md`)
- Economy Model (`economy-model.md`)
- Level Design Document (`level-design-document.md`)
- Release Checklist (`release-checklist.md`)
- Game Pillars (`game-pillars.md`)
- Systems Index (`systems-index.md`)
- AI Content Policy (`ai-content-policy.md`)
- Post-Mortem Report (`post-mortem.md`)
- Playtester Survey (`playtester-survey.md`)
- Competitive Analysis (`competitive-analysis.md`)
- Accessibility Audit (`accessibility-audit.md`)
- Jam Concept (`jam-concept.md`)
- Jam Submission Checklist (`jam-submission.md`)
- CI Pipeline Configuration (`ci-pipeline-config.md`)

Reference templates with `@templates/template-name.md` in skill outputs.

## Commit Convention

All commits to this repository must follow this convention:

| Prefix | Use |
|---|---|
| `feat:` | New skill, hook, template, or documentation |
| `improve:` | Enhancement to an existing skill or workflow |
| `fix:` | Bug fix, broken reference, or typo correction |
| `docs:` | README, CONTRIBUTING, or docs-only changes |
| `chore:` | Scripts, CI, config, or repo maintenance |

Examples:
```
feat: add game-economy-designer agent skill
improve: expand game-designer balance section with MDA analysis
fix: correct agent hierarchy in coordination-rules doc
docs: update quick start section in README
chore: add frontmatter validation to validate script
```

## Quality Standards

- Agent skills: minimum 200 lines of substantive content
- Workflow skills: minimum 150 lines of substantive content
- Engine specialists: minimum 200 lines with engine-specific code examples
- No stubs or placeholder sections
- Every skill must include concrete output templates
- All cross-references between skills must be valid
- All skills must include `argument-hint` in frontmatter
- All skills must include `allowed-tools` in frontmatter
- Agent skills should include `effort` level (max for directors, high for leads)
- Agent skills with isolated context should use `context: fork`

## Session State

Active session data is stored in `production/session-state/` and session logs in `production/session-logs/`. Both directories are gitignored. The hooks manage this state automatically.

## Project Structure

```
AlterLab_GameForge/
  skills/
    agents/              -- 11 studio agent skills
    workflows/           -- 20 workflow skills
    engine-specialists/  -- 3 engine-specific skills
  genre-packs/           -- Genre-specific reference material (not skills)
    roguelike/           -- Roguelike design patterns, balance, brainstorm
    narrative/           -- Narrative game patterns, pacing, brainstorm
  docs/                  -- 15 shared knowledge base documents
  hooks/                 -- 11 session lifecycle hooks
  templates/             -- 20 starter templates for game dev artifacts
  scripts/               -- Validation scripts (validate.sh)
  starters/              -- Engine-specific project configs
  production/            -- Runtime session data (gitignored)
  .github/workflows/     -- CI validation pipeline
  CLAUDE.md              -- This file
  README.md              -- Project showcase
  marketplace.json       -- Plugin manifest for Claude Code
  package.json           -- Project metadata
```
