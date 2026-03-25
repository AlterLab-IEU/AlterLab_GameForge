# AlterLab GameForge -- Indie Game Development Skills for Claude Code

## Project Overview

AlterLab GameForge is a collection of 22 production-grade Claude AI skills purpose-built for indie game development. The skills are organized into three categories:

- **9 Studio Agents** -- Specialized roles that emulate a full game studio team
- **10 Workflow Skills** -- Structured processes for common game dev tasks
- **3 Engine Specialists** -- Deep expertise for Godot, Unity, and Unreal Engine

Every skill is grounded in established game design theory (MDA Framework, Self-Determination Theory, Flow Theory, Bartle's Player Types) and delivers structured, actionable output.

## Shared Documentation

All skills reference a common knowledge base. These docs provide the theoretical and procedural foundation:

- `@docs/collaboration-protocol.md` -- How agents hand off work, share context, and avoid duplication
- `@docs/game-design-theory.md` -- MDA Framework, Flow Theory, SDT, Bartle taxonomy, and design lenses
- `@docs/coordination-rules.md` -- Turn order, conflict resolution, escalation paths between agents
- `@docs/agent-hierarchy.md` -- Reporting structure and decision authority for all 9 agents
- `@docs/coding-standards.md` -- Code style, architecture patterns, and engine-specific conventions

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
  |
  +-- Technical Director (architecture, performance, tools)
        +-- QA Lead (testing, bug tracking, quality gates)
        +-- UX Designer (player experience, accessibility, usability)
```

**Decision authority:**
- **Creative conflicts** (art style vs. narrative tone) -- Creative Director decides
- **Technical conflicts** (performance vs. feature scope) -- Technical Director decides
- **Scope conflicts** (feature cut vs. deadline) -- Producer decides
- **Cross-domain conflicts** (creative vs. technical tradeoffs) -- Producer mediates, Creative Director and Technical Director negotiate

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

### Workflow Routing

| User Intent | Route To |
|---|---|
| Starting a new game project | `game-start` |
| Ideation, brainstorming, concept exploration | `game-brainstorm` |
| Reviewing a game design document | `game-design-review` |
| Reviewing game code or architecture | `game-code-review` |
| Planning a development sprint | `game-sprint-plan` |
| Building a rapid prototype | `game-prototype` |
| Running a playtest session | `game-playtest` |
| Checking game balance and tuning | `game-balance-check` |
| Preparing for release or store submission | `game-launch` |
| Coordinating multiple agents on a task | `game-team-orchestrator` |

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
| `session-start` | PostToolUse | Initialize session state, load project context |
| `session-stop` | Stop | Save session state, write session log |
| `pre-compact` | PreToolUse | Archive context before memory compaction |
| `validate-commit` | PreToolUse | Enforce commit message convention before git commits |
| `detect-gaps` | PostToolUse | Identify missing skill coverage in agent responses |
| `log-agent` | PostToolUse | Record which agents were invoked and their outputs |

## Templates

The `templates/` directory contains starter templates for common game development artifacts:

- Game Design Document (GDD)
- Technical Design Document (TDD)
- Sprint planning sheets
- Playtest report forms
- Balance spreadsheet structures
- Store page copy templates

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

## Session State

Active session data is stored in `production/session-state/` and session logs in `production/session-logs/`. Both directories are gitignored. The hooks manage this state automatically.

## Project Structure

```
AlterLab_GameForge/
  skills/
    agents/          -- 9 studio agent skills
    workflows/       -- 10 workflow skills
    engine-specialists/  -- 3 engine-specific skills
  docs/              -- Shared knowledge base
  hooks/             -- Session lifecycle hooks
  templates/         -- Starter templates for game dev artifacts
  scripts/           -- Validation and utility scripts
  production/        -- Runtime session data (gitignored)
  CLAUDE.md          -- This file
  README.md          -- Project showcase
  marketplace.json   -- Plugin manifest for Claude Code
  package.json       -- Project metadata
```
