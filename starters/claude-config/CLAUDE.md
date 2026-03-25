# [YOUR GAME NAME] -- Project Configuration

## Project Overview

- **Game**: [YOUR GAME NAME]
- **Genre**: [YOUR GENRE -- e.g., Action Roguelike, Turn-Based RPG, Puzzle Platformer]
- **Engine**: [YOUR ENGINE -- Godot 4.x / Unity 6.x / Unreal Engine 5.x]
- **Description**: [ONE SENTENCE -- what the player does and why it is fun]
- **Target Platforms**: PC (Steam)
- **Team Size**: Solo developer
- **Current Phase**: Pre-Production

## GameForge Skill Routing

This project uses AlterLab GameForge skills. Route requests to the correct skill based on intent.

### Starting & Planning
| I need to... | Use |
|---|---|
| Start or scaffold the project | `/game-start` |
| Brainstorm ideas or mechanics | `/game-brainstorm` |
| Research the market or competitors | `/game-market-research` |
| Plan a sprint | `/game-sprint-plan` |
| Check scope against timeline | `/game-scope-check` |

### Design & Content
| I need to... | Use |
|---|---|
| Design mechanics, systems, or balance | `/game-designer` |
| Define creative vision or pillars | `/game-creative-director` |
| Write story, dialogue, or lore | `/game-narrative-director` |
| Design art style or asset pipeline | `/game-art-director` |
| Design music, SFX, or audio systems | `/game-audio-director` |
| Design virtual economy or monetization | `/game-economy-designer` |

### Engineering & Quality
| I need to... | Use |
|---|---|
| Review code or architecture | `/game-code-review` |
| Get engine-specific help | `/game-godot-specialist` or `/game-unity-specialist` or `/game-unreal-specialist` |
| Review a design document | `/game-design-review` |
| Build a prototype fast | `/game-prototype` |
| Set up testing or bug tracking | `/game-qa-lead` |
| Improve UX or player experience | `/game-ux-designer` |
| Audit accessibility | `/game-accessibility-specialist` |

### Production & Launch
| I need to... | Use |
|---|---|
| Run a playtest session | `/game-playtest` |
| Check balance and tuning | `/game-balance-check` |
| Prepare for store submission | `/game-launch` |
| Coordinate multiple concerns | `/game-team-orchestrator` |
| Generate docs from existing code | `/game-reverse-document` |
| Set up localization | `/game-localization-manager` |
| Set up analytics and KPIs | `/game-analytics-setup` |
| Run a retrospective | `/game-retrospective` |
| Run a post-mortem | `/game-postmortem` |

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
- AI-assisted code includes attribution: `# AI-assisted: reviewed and modified by [developer]`

## Commit Convention

Every commit follows this format:

| Prefix | Use |
|---|---|
| `feat(system):` | New gameplay feature or system |
| `fix(system):` | Bug fix |
| `balance(system):` | Tuning and balance changes |
| `art:` | Art asset additions or changes |
| `audio:` | Audio asset additions or changes |
| `design:` | Design document changes |
| `ui:` | UI/UX changes |
| `perf:` | Performance optimization |
| `refactor(system):` | Code restructuring without behavior change |
| `test:` | Test additions or changes |
| `chore:` | Build, config, tooling changes |
| `docs:` | Documentation only |

Examples:
```
feat(combat): add dash attack with iframes [GDD-012]
fix(inventory): prevent stack overflow on full inventory
balance(enemies): reduce boss phase 2 health by 15%
art: add tileset for forest biome
audio: add ambient wind loops for exterior scenes
design: update combat GDD with parry system spec
```

## Templates

GameForge includes templates for common game dev artifacts. Reference them when creating new documents:

- Game Design Document: `@templates/game-design-document.md`
- Game Concept: `@templates/game-concept.md`
- Architecture Decision Record: `@templates/architecture-decision-record.md`
- Sprint Plan: `@templates/sprint-plan.md`
- Art Bible: `@templates/art-bible.md`
- Sound Bible: `@templates/sound-bible.md`
- Character Sheet: `@templates/character-sheet.md`
- Economy Model: `@templates/economy-model.md`
- Level Design Document: `@templates/level-design-document.md`
- Release Checklist: `@templates/release-checklist.md`
- Game Pillars: `@templates/game-pillars.md`
- Systems Index: `@templates/systems-index.md`
- Accessibility Audit: `@templates/accessibility-audit.md`

## Project Structure

```
[YOUR GAME NAME]/
  docs/              -- Design documents (GDD, art bible, etc.)
  assets/            -- Game assets (art, audio, fonts)
  config/            -- External gameplay data (balance values, loot tables)
  tests/             -- Automated tests
  CLAUDE.md          -- This file
  .claude/           -- Claude Code configuration
    settings.json    -- Permissions and safety rules
```

Adapt this structure to your engine's conventions. See the engine-specific starter for recommended layouts.

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
