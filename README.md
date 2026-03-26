<div align="center">

<img src=".github/header-banner.svg" width="100%" alt="AlterLab GameForge">

<br>

<a href="skills/"><img src="https://img.shields.io/badge/Skills-34-7C3AED?style=for-the-badge&logo=bookstack&logoColor=white" alt="Skills"></a>
<a href="skills/agents/"><img src="https://img.shields.io/badge/Agents-11-2563EB?style=for-the-badge&logo=databricks&logoColor=white" alt="Agents"></a>
<a href="skills/workflows/"><img src="https://img.shields.io/badge/Workflows-20-0D9488?style=for-the-badge&logo=databricks&logoColor=white" alt="Workflows"></a>
<a href="skills/engine-specialists/"><img src="https://img.shields.io/badge/Engines-Godot%20%7C%20Unity%20%7C%20Unreal-E11D48?style=for-the-badge&logo=godotengine&logoColor=white" alt="Engines"></a>
<a href="https://www.anthropic.com"><img src="https://img.shields.io/badge/Claude-AI%20Powered-F97316?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude AI"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="MIT License"></a>

<br>

<a href="templates/"><img src="https://img.shields.io/badge/Templates-20-8B5CF6?style=for-the-badge&logo=files&logoColor=white" alt="Templates"></a>
<a href="hooks/"><img src="https://img.shields.io/badge/Hooks-11-3B82F6?style=for-the-badge&logo=webhook&logoColor=white" alt="Hooks"></a>
<a href="docs/"><img src="https://img.shields.io/badge/Docs-15-06B6D4?style=for-the-badge&logo=readthedocs&logoColor=white" alt="Docs"></a>
<a href="genre-packs/"><img src="https://img.shields.io/badge/Genre%20Packs-2-14B8A6?style=for-the-badge&logo=rocket&logoColor=white" alt="Genre Packs"></a>
<a href="starters/"><img src="https://img.shields.io/badge/Starters-3-14B8A6?style=for-the-badge&logo=rocket&logoColor=white" alt="Starters"></a>
<a href=".github/workflows/"><img src="https://img.shields.io/badge/CI-Passing-22C55E?style=for-the-badge&logo=githubactions&logoColor=white" alt="CI"></a>
<a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-Welcomhe-22C55E?style=for-the-badge&logo=githubactions&logoColor=white" alt="PRs Welcome"></a>

<br><br>

<h3>34 Production-Grade Claude AI Skills for Indie Game Development</h3>

<p><em>From concept to launch -- studio agents, dev workflows, engine specialists, and genre packs in one toolkit.</em></p>

</div>

<br>

---

## What's New in v2.0.0

- **3 new workflow skills**: Game Jam Mode (48-72h compressed workflows), CI Pipeline (engine-specific CI/CD with Steam/itch.io deployment), GDD Author (guided section-by-section authoring)
- **Engine deepening**: Networking, animation, VFX, AI, and material system sections added to all 3 engine specialists
- **2 genre packs**: Roguelike (888 lines) and Narrative (943 lines) -- design patterns, balance frameworks, and ideation prompts grounded in shipped games
- **CI validation**: 486 automated checks via `validate.sh` + GitHub Actions pipeline
- **Quality rubric**: 5-dimension scoring system (Trigger/Depth/Consistency/Usefulness/Voice) with 8+ minimum bar
- **AI-native gamedev guide**: Honest assessment of AI tools for game development -- what ships today vs what's hype

---

## 30-Second Quick Start

```bash
# 1. Install GameForge into Claude Code
claude install github:AlterLab-IEU/AlterLab_GameForge

# 2. Start your first game project
claude> /game-start

# 3. You now have a GDD skeleton, tech stack recommendation, and milestone plan.
#    Keep going:
claude> /game-brainstorm
claude> /game-designer
claude> /game-godot-specialist
```

That's it. 34 skills are now available as slash commands. Each one transforms Claude into a specialized game dev expert with real frameworks, structured outputs, and production-grade templates.

> **Alternative:** Copy any [`SKILL.md`](skills/) file into a [Claude Project's](https://claude.ai) custom instructions. Same result, different interface.

<br>

## "Where Do I Start?"

Not sure which skill to use? Pick your situation:

| Your situation | Run this | What happens |
|:---|:---|:---|
| "I have nothing -- just a vague idea" | `/game-start` | Bootstraps a GDD skeleton, picks your tech stack, builds a milestone plan |
| "I have a concept and want to explore it" | `/game-brainstorm` | Structured ideation with diverge/converge phases, concept scoring, market validation |
| "I have code but no docs" | `/game-reverse-document` | Generates design documentation from your existing codebase |
| "I need to plan my next sprint" | `/game-sprint-plan` | Task breakdown, dependency mapping, risk flags, velocity estimation |
| "I'm preparing to launch" | `/game-launch` | Store page prep, release checklist, patch cadence, community management plan |
| "I need my code reviewed" | `/game-code-review` | Architecture review, performance audit, engine best practices |
| "I want to check my game's balance" | `/game-balance-check` | Statistical validation -- Monte Carlo, distribution analysis, EV calculations |

> For full workflow walkthroughs, see [docs/workflow-examples.md](docs/workflow-examples.md).

<br>

---

## Skill Catalog

### Studio Agents -- Your Virtual Game Studio Team (11)

<details>
<summary><b>Click to expand</b></summary>

<br>

| # | Skill | What It Does |
|:---:|:---|:---|
| 1 | **Creative Director** | Defines and guards creative vision, design pillars, and tonal identity |
| 2 | **Technical Director** | Architects engine setup, performance budgets, and tool pipelines |
| 3 | **Producer** | Manages scope, schedule, milestones, risk, and cross-team coordination |
| 4 | **Game Designer** | Designs core mechanics, progression systems, economy, and balance tuning |
| 5 | **Narrative Director** | Crafts story architecture, dialogue systems, lore bibles, and branching narratives |
| 6 | **Art Director** | Establishes visual style, asset pipelines, UI art direction, and style guides |
| 7 | **Audio Director** | Designs music direction, SFX libraries, adaptive audio, and mixing strategies |
| 8 | **QA Lead** | Builds test plans, bug taxonomies, regression suites, and quality gates |
| 9 | **UX Designer** | Designs onboarding flows, accessibility, HUD, and usability testing |
| 10 | **Economy Designer** | Designs virtual economies -- currency flows, sink/source modeling, monetization ethics |
| 11 | **Accessibility Specialist** | Drives inclusive design -- motor, visual, auditory, cognitive accommodations, EAA compliance |

</details>

### Workflow Skills -- Structured Dev Processes (20)

<details>
<summary><b>Click to expand</b></summary>

<br>

| # | Skill | What It Does |
|:---:|:---|:---|
| 1 | **Game Start** | Bootstraps a new project -- GDD skeleton, tech stack, milestone plan |
| 2 | **Brainstorm** | Structured ideation with diverge/converge, concept scoring, market validation |
| 3 | **Design Review** | Reviews a GDD for completeness, consistency, and feasibility |
| 4 | **Code Review** | Reviews game code for architecture, performance, and engine best practices |
| 5 | **Sprint Plan** | Plans a dev sprint with tasks, dependencies, and risk flags |
| 6 | **Prototype** | Guides rapid prototyping -- scope the core loop, build minimal playable, evaluate |
| 7 | **Playtest** | Structures playtest sessions -- goals, metrics, observer guides, feedback synthesis |
| 8 | **Balance Check** | Analyzes game balance with Monte Carlo, distribution analysis, EV calculations |
| 9 | **Launch** | Prepares release and post-launch ops -- store pages, patch cadence, community |
| 10 | **Team Orchestrator** | Coordinates multiple agents with spawn recipes for complex tasks |
| 11 | **Scope Check** | Evaluates scope against timeline, team size, and budget |
| 12 | **Retrospective** | Runs GDC-format post-mortems with kill list review |
| 13 | **Reverse Document** | Generates design docs from existing game code |
| 14 | **Localization Manager** | Manages translation pipelines, string extraction, cultural adaptation |
| 15 | **Analytics Setup** | Integrates telemetry, defines KPIs, builds dashboards, privacy-first |
| 16 | **Post-Mortem** | Structured post-mortem pulling git history, milestone data, lessons learned |
| 17 | **Market Research** | Competitive landscape, market sizing, audience profiling, positioning strategy |
| 18 | **Game Jam Mode** | Compressed 48-72 hour workflows -- theme interpretation, scope ruthlessness, 6-phase jam pipeline |
| 19 | **CI Pipeline** | CI/CD for game builds -- engine-specific pipelines, Steam/itch.io deployment, GitHub Actions templates |
| 20 | **GDD Author** | Guided section-by-section GDD authoring -- pillar validation, scope tiers, MDA integration |

</details>

### Engine Specialists -- Deep Expertise for Your Engine (3)

<details>
<summary><b>Click to expand</b></summary>

<br>

| # | Skill | What It Does |
|:---:|:---|:---|
| 1 | **Godot Specialist** | GDScript/C# patterns, scene tree architecture, signal design, Godot 4 best practices |
| 2 | **Unity Specialist** | C# patterns, ECS vs. MonoBehaviour, asset bundles, Unity-specific optimization |
| 3 | **Unreal Specialist** | C++/Blueprint patterns, Gameplay Ability System, Niagara, Unreal pipelines |

</details>

<br>

---

## How Skills Work

Each skill is a structured `.md` file (typically 150--300+ lines). When loaded into Claude Code or a Claude Project, it transforms Claude into an autonomous agent with:

- **Deep domain knowledge** -- real game design frameworks (MDA, Flow Theory, SDT, Bartle's Player Types), not generic advice
- **Structured output templates** -- production-ready GDDs, art bibles, sprint plans written directly to your project
- **Collaboration protocols** -- skills coordinate through shared docs, agent hierarchy, and handoff rules
- **Engine awareness** -- engine specialists know your platform's APIs, patterns, and best practices

Skills are interconnected. The Game Designer and QA Lead reference the same balance frameworks. The Art Director and UX Designer share accessibility standards. The Producer coordinates all of them through a defined hierarchy.

> **Format:** Every `SKILL.md` has YAML frontmatter (`name`, `category`, `version`, `description`) followed by role definition, capabilities, frameworks, output templates, and collaboration rules. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full format reference.

<br>

## Usage Examples

| You say... | Skill activated |
|:---|:---|
| *"Help me start a new roguelike project"* | `game-start` |
| *"Design the core combat loop for my action RPG"* | `game-designer` |
| *"Write a branching dialogue system for my visual novel"* | `game-narrative-director` |
| *"Review my GDD for scope issues"* | `game-design-review` + `game-scope-check` |
| *"Set up my Godot 4 project with proper scene architecture"* | `game-godot-specialist` |
| *"Plan my next two-week sprint"* | `game-sprint-plan` |
| *"Prepare my Steam store page for launch"* | `game-launch` |
| *"Run a structured playtest for my prototype"* | `game-playtest` |
| *"Audit my game's economy balance"* | `game-balance-check` + `game-economy-designer` |
| *"Generate design docs from my existing codebase"* | `game-reverse-document` |
| *"Set up analytics and KPIs for my game"* | `game-analytics-setup` |
| *"Localize my game for the Japanese market"* | `game-localization-manager` |
| *"Analyze the competitive landscape for cozy farm sims"* | `game-market-research` |
| *"Run a post-mortem on this milestone"* | `game-postmortem` |
| *"I'm doing a 48-hour game jam this weekend"* | `game-jam-mode` |
| *"Set up CI/CD for my Godot project"* | `game-ci-pipeline` |
| *"Help me write my GDD section by section"* | `game-gdd-author` |

> For complete end-to-end walkthroughs, see [docs/workflow-examples.md](docs/workflow-examples.md). For common questions, see [docs/FAQ.md](docs/FAQ.md).

<br>

---

## Setting Up Your Game Project

GameForge skills work out of the box for general questions. But to get engine-aware, project-specific guidance, copy a **starter config** into your game project.

```bash
# Copy the base config into your game project
cp starters/claude-config/CLAUDE.md /path/to/your-game/CLAUDE.md
mkdir -p /path/to/your-game/.claude
cp starters/claude-config/settings.json /path/to/your-game/.claude/settings.json

# Add your engine's config (pick one)
cat starters/godot/CLAUDE.md >> /path/to/your-game/CLAUDE.md      # Godot
cat starters/unity/CLAUDE.md >> /path/to/your-game/CLAUDE.md      # Unity
cat starters/unreal/CLAUDE.md >> /path/to/your-game/CLAUDE.md     # Unreal
```

Fill in the `[BRACKETED PLACEHOLDERS]` with your game's details -- project name, genre, one-liner description. Everything else works out of the box.

> Full setup instructions: [starters/README.md](starters/README.md)

<br>

## Architecture

```
+-------------------+
|    CLAUDE.md      |  Routing & config
+-------------------+
         |
+--------+---------+-----------+
|                  |           |
+----------+  +-----------+  +----------------+
| Agents   |  | Workflows |  | Engine         |
|   (11)   |  |   (20)    |  | Specialists(3) |
+----------+  +-----------+  +----------------+
     |              |              |
     +---------+----+--------------+
               |
       +-------+-------+
       | Shared Docs   |  15 reference documents
       +---------------+
               |
   +-----------+-----------+-----------+
   |           |           |           |
+--------+ +----------+ +----------+ +-------------+
| Hooks  | | Templates| | Starters | | Genre Packs |
|  (11)  | |   (20)   | |   (3)    | |     (2)     |
+--------+ +----------+ +----------+ +-------------+
```

<br>

## Genre Packs

Genre packs are in-repo reference material that enrich existing skills with genre-specific design patterns, balance frameworks, and ideation prompts. They are not standalone skills -- they are consumed by `game-brainstorm`, `game-designer`, `game-balance-check`, and `game-gdd-author` when a genre is specified.

| Pack | Lines | What It Covers |
|:---|:---:|:---|
| **Roguelike** | 888 | Permadeath, run structure, proc-gen, meta-progression, synergy systems, Monte Carlo validation, 6+ reference games |
| **Narrative** | 943 | Branching architecture, choice design, dialogue systems, consequence modeling, environmental storytelling, 10+ reference games |

> Want to contribute a genre pack? See the [genre pack contribution guide](CONTRIBUTING.md#contributing-a-genre-pack) and [format spec](docs/genre-pack-spec.md).

<br>

## Project Structure

```
AlterLab_GameForge/
 skills/
   agents/                  # 11 studio agent skills
   workflows/               # 20 workflow skills
   engine-specialists/      # 3 engine-specific skills
 genre-packs/               # Genre-specific reference material
   roguelike/               #   Permadeath, proc-gen, synergy systems
   narrative/               #   Branching, dialogue, consequence modeling
 docs/                      # 15 shared knowledge base documents
 hooks/                     # 11 session lifecycle hooks
 templates/                 # 20 starter templates for game dev artifacts
 starters/                  # Engine-specific project configs
   claude-config/           #   Base config (all engines)
   godot/                   #   Godot 4.x conventions
   unity/                   #   Unity 6.x conventions
   unreal/                  #   Unreal Engine 5.x conventions
 scripts/                   # Validation scripts (validate.sh)
 .github/workflows/         # CI validation pipeline
 CLAUDE.md                  # Project-level Claude config & routing
 marketplace.json           # Plugin manifest for Claude Code
 package.json               # Project metadata
```

<br>

## MCP Integrations

GameForge skills integrate with 34 verified MCP servers for game development -- engine MCPs (Godot, Unity, Unreal), asset pipelines (Figma, ElevenLabs), project management (GitHub, Notion), and more.

Seven skills have built-in MCP sections: Producer, Code Review, QA Lead, Designer, Art Director, UX Designer, and Audio Director.

> Full catalog and setup guides: [docs/mcp-integrations.md](docs/mcp-integrations.md)

<br>

---

## Contributing

We welcome contributions. Quick ways to get started:

- Fix a typo or improve a skill section
- Add a FAQ entry or workflow example
- Create a new skill following the architecture

```bash
git checkout -b improve/game-designer
# Edit skills/agents/game-designer/SKILL.md
git commit -m "improve: game-designer -- better economy balance models"
git push origin improve/game-designer
```

> Full guide: [CONTRIBUTING.md](CONTRIBUTING.md) | Format reference: [CLAUDE.md](CLAUDE.md)

<br>

## License

This project is licensed under the **[MIT License](LICENSE)** -- free to use, modify, and distribute.

<br>

## Credits

<div align="center">

**Built by Cem Ipek at [AlterLab Creative Technologies Laboratory](https://github.com/AlterLab-IEU)**

34 skills -- 3 categories -- 2 genre packs -- 1 prompt away from expert-level game development

---

<sub>If you find this useful, consider giving it a star.</sub>
<br>
<a href="#">Back to Top</a>

</div>

<br>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,9,5&height=100&section=footer" width="100%" alt="Footer">
