<h1 align="center">AlterLab GameForge</h1>

<p align="center">
  <strong>22 production-grade Claude AI skills for indie game development</strong><br />
  <em>From concept to launch -- one skill at a time</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Skills-22-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Agents-9-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Workflows-10-teal?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Engines-Godot%20%7C%20Unity%20%7C%20Unreal-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Claude-AI%20Powered-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" />
</p>

<p align="center">
  Built by <a href="https://github.com/AlterLab-IEU">AlterLab Creative Technologies Laboratory</a>
</p>

---

## What Is This?

AlterLab GameForge is a curated collection of **22 Claude AI skills** that give you a full indie game studio inside your terminal. Each skill is a deep, production-grade instruction set that transforms Claude into a specialized game development expert -- from creative direction and narrative design to engine-specific coding and launch preparation.

GameForge is the third entry in the **AlterLab Skills Trilogy**:

| Collection | Focus | Skills |
|---|---|---|
| [AlterLab FC Skills](https://github.com/AlterLab-IEU/AlterLab-FC-Skills) | Communication students | 72 |
| [AlterLab Academic Skills](https://github.com/AlterLab-IEU/AlterLab-Academic-Skills) | Researchers & academics | 186+ |
| **AlterLab GameForge** | **Indie game developers** | **22** |

Whether you are a solo developer building your first game or a small team shipping your tenth, GameForge gives you access to expert-level guidance across every discipline of game development.

## What Makes These Skills Different?

**Agentic execution, not chat.** Each skill is a fully realized agent persona with deep domain knowledge, structured output templates, and explicit collaboration protocols. They don't just answer questions -- they produce deliverables.

**Grounded in game design theory.** Every design decision references established frameworks:
- **MDA Framework** (Mechanics, Dynamics, Aesthetics) for systematic design analysis
- **Self-Determination Theory** (Autonomy, Competence, Relatedness) for player motivation
- **Flow Theory** (Csikszentmihalyi) for difficulty curve and engagement tuning
- **Bartle's Player Types** for audience segmentation and feature prioritization

**Cinematic design thinking.** The Creative Director and Art Director skills incorporate principles from film, theater, and visual storytelling -- not just game-specific references.

**Accessibility as design, not afterthought.** The UX Designer skill builds WCAG compliance, colorblind modes, and input remapping into the core design process.

**Ethical monetization.** The Game Designer and Producer skills include frameworks for fair-to-player monetization -- no dark patterns, no predatory mechanics.

**No stubs.** Every skill is 150-300+ lines of substantive content with concrete output templates, decision frameworks, and real examples.

## Skill Overview

<details>
<summary><strong>Studio Agents (9)</strong> -- Your virtual game studio team</summary>

| Skill | Description |
|---|---|
| `game-creative-director` | Defines and guards the creative vision, design pillars, and tonal identity of the project |
| `game-technical-director` | Architects the technical foundation -- engine setup, performance budgets, and tool pipelines |
| `game-producer` | Manages scope, schedule, milestones, risk, and cross-team coordination |
| `game-designer` | Designs core mechanics, progression systems, economy, and balance tuning |
| `game-narrative-director` | Crafts story architecture, dialogue systems, lore bibles, and branching narratives |
| `game-art-director` | Establishes visual style, asset pipelines, UI art direction, and style guides |
| `game-audio-director` | Designs music direction, SFX libraries, adaptive audio systems, and mixing strategies |
| `game-qa-lead` | Builds test plans, bug taxonomies, regression suites, and quality gates |
| `game-ux-designer` | Designs player-facing experience -- onboarding, accessibility, HUD, and usability testing |

</details>

<details>
<summary><strong>Workflow Skills (10)</strong> -- Structured processes for game dev tasks</summary>

| Skill | Description |
|---|---|
| `game-start` | Bootstraps a new game project with GDD skeleton, tech stack selection, and milestone plan |
| `game-brainstorm` | Runs structured ideation sessions with diverge/converge phases and concept scoring |
| `game-design-review` | Reviews a game design document for completeness, consistency, and feasibility |
| `game-code-review` | Reviews game code for architecture, performance, maintainability, and engine best practices |
| `game-sprint-plan` | Plans a development sprint with task breakdown, dependencies, and risk flags |
| `game-prototype` | Guides rapid prototyping -- scope the core loop, build the minimal playable, evaluate |
| `game-playtest` | Structures a playtest session -- goals, metrics, observer guides, and feedback synthesis |
| `game-balance-check` | Analyzes game balance -- economy, difficulty curves, progression pacing, and edge cases |
| `game-launch` | Prepares for release -- store pages, build checklists, marketing beats, and day-one patches |
| `game-team-orchestrator` | Coordinates multiple agents on a complex task, managing handoffs and resolving conflicts |

</details>

<details>
<summary><strong>Engine Specialists (3)</strong> -- Deep expertise for your engine of choice</summary>

| Skill | Description |
|---|---|
| `game-godot-specialist` | GDScript/C# patterns, scene tree architecture, signal design, and Godot 4 best practices |
| `game-unity-specialist` | C# patterns, ECS vs. MonoBehaviour, asset bundles, and Unity-specific optimization |
| `game-unreal-specialist` | C++/Blueprint patterns, Gameplay Ability System, Niagara, and Unreal-specific pipelines |

</details>

## Quick Start

### Using with Claude Code CLI

Install individual skills as slash commands:

```bash
# Install the entire GameForge collection
claude install github:AlterLab-IEU/AlterLab-GameForge

# Use any skill as a slash command
claude> /game-start
claude> /game-designer
claude> /game-godot-specialist
```

### Using with Claude Projects

1. Create a new Claude Project
2. Copy the contents of any `SKILL.md` file into the project's custom instructions
3. Start chatting -- Claude will adopt that skill's persona and methodology

### Using Individual Skills

Each skill is a self-contained Markdown file. You can:
- Copy-paste into any Claude interface as a system prompt
- Add to your `.claude/commands/` directory for local slash commands
- Reference in your project's `CLAUDE.md` for automatic activation

## Architecture

GameForge is designed as an interconnected skill system, not a loose collection of prompts.

```
                    +-------------------+
                    |    CLAUDE.md      |  Routing & config
                    +-------------------+
                             |
              +--------------+--------------+
              |              |              |
     +--------+--+  +-------+---+  +-------+--------+
     |  Agents   |  | Workflows |  |   Engine       |
     |  (9)      |  |  (10)     |  |   Specialists  |
     +-----------+  +-----------+  |   (3)          |
              |              |     +----------------+
              +--------------+
                      |
              +-------+-------+
              |  Shared Docs  |
              +---------------+
              | collaboration-protocol.md
              | game-design-theory.md
              | coordination-rules.md
              | agent-hierarchy.md
              | coding-standards.md
              +---------------+
                      |
         +------------+------------+
         |            |            |
    +----+---+  +-----+----+  +---+-------+
    | Hooks  |  | Templates|  | Scripts   |
    +--------+  +----------+  +-----------+
```

**Shared Docs** provide the theoretical and procedural foundation that all skills reference. This ensures consistency -- the Game Designer and QA Lead use the same balance frameworks, the Art Director and UX Designer share accessibility standards.

**Hooks** manage session lifecycle: initializing state, logging agent activity, validating commits, and detecting coverage gaps.

**Templates** provide starter structures for common artifacts (GDD, TDD, sprint plans, playtest reports) so skills can generate immediately usable output.

## The AlterLab Skills Trilogy

GameForge is part of a broader vision: making expert knowledge accessible through AI skills.

| | AlterLab FC Skills | AlterLab Academic Skills | AlterLab GameForge |
|---|---|---|---|
| **Domain** | Communication & media | Research & academia | Indie game development |
| **Skills** | 72 | 186+ | 22 |
| **Agents** | Faculty, advisors, critics | Researchers, reviewers, analysts | Studio team leads |
| **Workflows** | Project pipelines | Research workflows | Dev pipelines |
| **Specialists** | Platform-specific | Method-specific | Engine-specific |
| **Theory Base** | Communication theory | Research methodology | Game design theory |

All three collections follow the same skill format, share the same quality standards, and are designed to work within the Claude Code ecosystem.

## Project Structure

```
AlterLab_GameForge/
|
+-- skills/
|   +-- agents/
|   |   +-- game-creative-director/SKILL.md
|   |   +-- game-technical-director/SKILL.md
|   |   +-- game-producer/SKILL.md
|   |   +-- game-designer/SKILL.md
|   |   +-- game-narrative-director/SKILL.md
|   |   +-- game-art-director/SKILL.md
|   |   +-- game-audio-director/SKILL.md
|   |   +-- game-qa-lead/SKILL.md
|   |   +-- game-ux-designer/SKILL.md
|   |
|   +-- workflows/
|   |   +-- game-start/SKILL.md
|   |   +-- game-brainstorm/SKILL.md
|   |   +-- game-design-review/SKILL.md
|   |   +-- game-code-review/SKILL.md
|   |   +-- game-sprint-plan/SKILL.md
|   |   +-- game-prototype/SKILL.md
|   |   +-- game-playtest/SKILL.md
|   |   +-- game-balance-check/SKILL.md
|   |   +-- game-launch/SKILL.md
|   |   +-- game-team-orchestrator/SKILL.md
|   |
|   +-- engine-specialists/
|       +-- game-godot-specialist/SKILL.md
|       +-- game-unity-specialist/SKILL.md
|       +-- game-unreal-specialist/SKILL.md
|
+-- docs/
|   +-- collaboration-protocol.md
|   +-- game-design-theory.md
|   +-- coordination-rules.md
|   +-- agent-hierarchy.md
|   +-- coding-standards.md
|
+-- hooks/
|   +-- session-start.sh
|   +-- session-stop.sh
|   +-- pre-compact.sh
|   +-- validate-commit.sh
|   +-- detect-gaps.sh
|   +-- log-agent.sh
|
+-- templates/
|   +-- gdd-template.md
|   +-- tdd-template.md
|   +-- sprint-plan-template.md
|   +-- playtest-report-template.md
|   +-- balance-sheet-template.md
|   +-- store-page-template.md
|
+-- scripts/
|   +-- validate.js
|
+-- production/           (gitignored)
|   +-- session-state/
|   +-- session-logs/
|
+-- CLAUDE.md             Project-level Claude config
+-- README.md             This file
+-- marketplace.json      Plugin manifest
+-- package.json          Project metadata
+-- CONTRIBUTING.md       Contribution guide
+-- LICENSE               MIT License
+-- .gitignore
```

## Contributing

We welcome contributions that improve existing skills or propose new ones. See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- How to fork, branch, edit, and submit a PR
- Commit message conventions (`feat:`, `improve:`, `fix:`, `docs:`, `chore:`)
- Quality bar requirements (200+ lines for agents, 150+ for workflows)
- Testing process (load into Claude Code, run 3+ test prompts)
- The AlterLab skill format reference

## License

This project is licensed under the [MIT License](LICENSE).

You are free to use, modify, and distribute these skills in your own projects -- commercial or otherwise. Attribution is appreciated but not required.

## Credits

<p align="center">
  Created by <strong>Cem Ipek</strong><br />
  <a href="https://github.com/AlterLab-IEU">AlterLab Creative Technologies Laboratory</a><br />
  Izmir University of Economics<br /><br />
  <em>Building the tools we wish we had.</em>
</p>

---

<p align="center">
  <sub>Part of the AlterLab Skills Trilogy: FC Skills (72) | Academic Skills (186+) | GameForge (22)</sub>
</p>
