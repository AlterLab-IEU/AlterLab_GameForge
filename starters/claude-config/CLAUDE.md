# [YOUR GAME NAME] -- Project Configuration

## Project Overview

- **Game**: [YOUR GAME NAME]
- **Genre**: [YOUR GENRE -- e.g., Action Roguelike, Turn-Based RPG, Puzzle Platformer]
- **Engine**: [YOUR ENGINE -- Godot 4.7 / Unity 6.3 LTS / Unreal Engine 5.8 / Three.js / Phaser 4]
- **Description**: [ONE SENTENCE -- what the player does and why it is fun]
- **Target Platforms**: PC (Steam)
- **Team Size**: Solo developer
- **Current Phase**: Pre-Production

## GameForge Skill Routing

This project uses the AlterLab GameForge plugin. Skills run as `/gameforge:<skill>`; describing
the task in plain language also works. Unsure which one fits? Run `/gameforge:game-help`.

### Starting and planning
| I need to... | Use |
|---|---|
| Find direction | `/gameforge:game-help` |
| Brainstorm original concepts | `/gameforge:game-brainstorm` |
| Research the market | `/gameforge:game-market-research` |
| Set up the project (config, starter, LFS) | `/gameforge:game-start` |
| Write the GDD section by section | `/gameforge:game-gdd-author` |
| Plan a sprint / check scope | `/gameforge:game-sprint-plan`, `/gameforge:game-scope-check` |

### Design and content
| I need to... | Use |
|---|---|
| Vision, pillars, tone | `/gameforge:game-creative-director` |
| Mechanics, systems, tuning | `/gameforge:game-designer` |
| Economy and monetization | `/gameforge:game-economy-designer` |
| Story, dialogue, lore | `/gameforge:game-narrative-director` |
| Art style and asset pipeline | `/gameforge:game-art-director` |
| Music, SFX, voice | `/gameforge:game-audio-director` |
| Generate art or audio with AI (logged) | `/gameforge:game-ai-assets` |

### Building and quality
| I need to... | Use |
|---|---|
| Build with an AI agent, verified step by step | `/gameforge:game-vibe-code` |
| Throwaway prototype for one question | `/gameforge:game-prototype` |
| Engine help | `/gameforge:game-godot-specialist`, `/gameforge:game-unity-specialist`, `/gameforge:game-unreal-specialist`, `/gameforge:game-threejs-specialist`, `/gameforge:game-web2d-specialist` |
| Architecture and performance | `/gameforge:game-technical-director` |
| Online play | `/gameforge:game-multiplayer` |
| Review code (especially agent-written) | `/gameforge:game-code-review` |
| Tests and release gates | `/gameforge:game-qa-lead` |
| UX and accessibility | `/gameforge:game-ux-designer`, `/gameforge:game-accessibility-specialist` |
| CI builds and deploys | `/gameforge:game-ci-pipeline` |

### Testing, shipping and reflecting
| I need to... | Use |
|---|---|
| Playtest / balance | `/gameforge:game-playtest`, `/gameforge:game-balance-check` |
| Localize / analytics | `/gameforge:game-localization-manager`, `/gameforge:game-analytics-setup` |
| Steam, console or mobile launch | `/gameforge:game-launch` |
| Browser release (itch.io, portals) | `/gameforge:game-web-publish` |
| Several roles on one problem | `/gameforge:game-team-orchestrator` |
| Retrospective / post-mortem | `/gameforge:game-retrospective`, `/gameforge:game-postmortem` |

## Coding Standards

These rules apply to all game code in this project. They are non-negotiable.

### Frame-Rate Independence
- All movement, timers, cooldowns, and animations use delta time. Never assume a fixed frame rate.
- Physics use a fixed timestep. Rendering interpolates between physics states.
- Timers track elapsed time, not frame counts.

### Data-Driven Gameplay Values
- No hardcoded gameplay values. Health, speed, damage, cooldowns, drop rates -- all live in external config files or engine-native data containers (Resources, ScriptableObjects, Data Tables).
- Mathematical and physics constants that never change are exempt.

### State Machine Discipline
- Player states, enemy AI, and game flow use explicit state machines -- not nested if/else chains.
- Every state defines enter, exit, and update logic.
- State transitions are named and validate preconditions.

### Performance: Hot Path Rules
- No memory allocations in update loops.
- Frequently spawned objects use object pools.
- Component and node references are cached at initialization, not queried every frame.

### Resource Cleanup
- Scene transitions explicitly free all scene-specific resources.
- Every event subscription or signal connection is disconnected on scene exit.
- Large assets load asynchronously during loading screens and release on level exit.

### Testability
- Gameplay logic is separated from engine integration so it can be unit tested.
- Dependencies are injected, not pulled from global state.
- Test names describe behavior: "player takes reduced damage when shield is active" not "test_damage".

### Documentation
- Public methods have doc comments explaining what, parameters, return value, and side effects.
- Inline comments explain "why" not "what."
- AI-assisted code is reviewed by a person before merge; generated assets are recorded in `design/ai-asset-log.md` (see `/gameforge:game-ai-assets`).

## Commit Convention

GameForge's commit hook checks this format once `.gameforge/project.json` exists:
`<type>(<optional scope>): <summary>`, under 72 characters.

| Type | Use |
|---|---|
| `feat` | New gameplay feature or system |
| `fix` | Bug fix |
| `balance` | Tuning and balance changes |
| `art`, `audio` | Asset additions or changes |
| `design`, `level`, `narrative` | Design, level and story documents or data |
| `ui` | UI/UX changes |
| `loc` | Localization |
| `perf`, `refactor`, `test` | Performance, restructuring, tests |
| `build`, `ci`, `chore`, `docs` | Build, pipeline, tooling, documentation |

Examples:
```
feat(combat): add dash attack with i-frames
fix(inventory): prevent overflow on full stacks
balance(enemies): reduce boss phase 2 health by 15%
art: forest tileset pass 2
design(combat): specify parry window and feedback
```

## Templates

GameForge bundles templates for the GDD, concept, pillars, ADRs, sprint plans, art and sound bibles,
character sheets, economy models, level docs, accessibility audits, playtest surveys, release
checklists, post-mortems and the AI asset log. You do not copy them by hand: the skill that owns each
document fills in its template (for example `/gameforge:game-gdd-author` for the GDD,
`/gameforge:game-sprint-plan` for sprint plans).

## Project Structure

```
[YOUR GAME NAME]/
  .gameforge/project.json  -- GameForge config: engine, phase, pillars, conventions
  design/                  -- GDD, pillars, level docs, balance data, ai-asset-log.md
  docs/                    -- Architecture, ADRs
  production/              -- Sprints, milestones; session-state/ and session-logs/ are gitignored
  assets/                  -- Source art, audio, fonts (large binaries tracked with Git LFS)
  config/                  -- External gameplay data (balance values, loot tables)
  tests/                   -- Automated tests
  CLAUDE.md                -- This file
  .claude/settings.json    -- Permissions and the GameForge marketplace for teammates
```

Adapt this to your engine's conventions; the engine starters show recommended layouts.

## Design Document Requirements

Every significant gameplay feature needs a design document before implementation. Required sections:

1. **Overview** -- What is this feature? What player experience does it serve?
2. **Player Fantasy** -- What does the player feel while engaging with this feature?
3. **Detailed Rules** -- Complete mechanical specification.
4. **Formulas** -- All math with variable definitions.
5. **Edge Cases** -- Boundary conditions, zero values, simultaneous events.
6. **Dependencies** -- What other systems does this feature touch?
7. **Tuning Knobs** -- Every externalized value with default, valid range, and effect.
8. **Acceptance Criteria** -- Concrete "Given X, when Y, then Z" statements.
