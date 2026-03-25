# AlterLab GameForge Roadmap

Current version: **v1.2.0** (29 skills, 17 templates, 8 docs)

---

## v1.2.0 — Depth & Polish (SHIPPED)

### New Skills

| Skill | What | Why | Scope |
|-------|------|-----|-------|
| `game-economy-designer` | Dedicated agent for virtual economy design — currency flows, sink/source modeling, monetization ethics | Economy design is the #1 gap reported in indie dev communities. Current coverage is split across game-designer and economy-model template, neither deep enough. | Agent skill, ~300 lines |
| `game-accessibility-specialist` | Dedicated agent for inclusive game design — motor, visual, auditory, cognitive accommodations | EAA compliance (June 2025) makes this non-optional. Current UX designer handles it as a subsection, not deeply enough. | Agent skill, ~350 lines |
| `game-localization-manager` | Workflow for managing translation pipelines, string extraction, cultural adaptation | Zero localization coverage currently. Indie games lose 40-60% of potential market without localization. | Workflow skill, ~250 lines |
| `game-analytics-setup` | Workflow for integrating telemetry, defining KPIs, building dashboards | No analytics coverage. Data-driven balancing is referenced but never operationalized. | Workflow skill, ~200 lines |

### Skill Upgrades

| Target | What | Why | Scope |
|--------|------|-----|-------|
| All 9 agents | Add `## When NOT to Use Me` section | Reduces misrouting. Current trigger descriptions tell Claude when to route TO each agent but not when to route AWAY. | ~20 lines each, 180 total |
| `game-brainstorm` | Add market validation phase | Currently ideation-heavy with no market sizing or competitive check. Great ideas that nobody wants are still worthless. | +50 lines |
| `game-balance-check` | Add statistical validation methods | Currently qualitative. Needs Monte Carlo simulation guidance, distribution analysis, expected value calculations. | +80 lines |
| `game-launch` | Add live service / post-launch operations | Covers launch day but not day 2+. Indie devs need patch cadence, community management, and metrics monitoring guidance. | +60 lines |
| Engine specialists | Add migration guides between engines | Common ask. "I have a Godot prototype, should I move to Unity for mobile?" needs structured decision framework. | +40 lines each |

### Templates

| Template | What | Why |
|----------|------|-----|
| `playtester-survey.md` | Standardized playtest feedback collection form | Playtest skill references collecting feedback but provides no instrument |
| `competitive-analysis.md` | Market positioning and competitor feature matrix | No template for the market research that should precede every project |
| `accessibility-audit.md` | Accessibility compliance checklist by disability category | Needed for EAA compliance, pairs with planned accessibility specialist |

### Documentation

| Doc | What | Why |
|-----|------|-----|
| `docs/monetization-ethics.md` | Ethical monetization framework — loot box psychology, dark pattern identification, regulatory landscape | Economy model references ethics but has no canonical standard |
| `docs/engine-comparison.md` | Structured comparison matrix for Godot/Unity/Unreal | Frequently asked, currently answered ad-hoc by engine specialists |

---

## v1.3.0 — Automation & Intelligence (Medium Term)

### MCP Integrations

| Integration | What | Why | Scope |
|-------------|------|-----|-------|
| GitHub Issues workflow | Skills auto-create issues for bugs found during code review, playtest findings, QA results | Currently all output is text in chat. Structured issue creation reduces copy-paste overhead. | Hook + workflow changes |
| Notion GDD sync | Game Design Document template syncs to Notion pages, stays updated as design evolves | GDDs rot when they live only in markdown. Notion integration keeps the living document alive. | MCP tool integration |
| Figma asset pipeline | Art director skill can reference Figma files, extract style tokens, validate asset specs | Asset pipeline is described but not connected to actual design tools. | MCP tool integration |

### Advanced Workflows

| Workflow | What | Why | Scope |
|----------|------|-----|-------|
| `game-postmortem` | Structured post-mortem workflow pulling git history, milestone data, retrospective notes | Post-mortem template exists but has no automated data collection. | Workflow skill, ~300 lines |
| `game-market-research` | Market sizing, competitor analysis, trend detection for game concepts | Brainstorming has no market validation step. This fills that gap. | Workflow skill, ~250 lines |
| `game-ci-pipeline` | CI/CD setup for game builds — automated testing, build pipelines, deployment | Technical director mentions CI but no operational skill exists. | Workflow skill, ~200 lines |

### Skill Intelligence

| Feature | What | Why |
|---------|------|-----|
| Cross-skill memory | Skills remember context from previous invocations via MCP memory server | Currently each skill invocation is stateless. A sprint plan can't reference last sprint's retrospective. |
| Adaptive complexity | Skills detect project maturity (prototype/alpha/beta/release) and adjust depth accordingly | Same skill gives same output whether the game is day 1 or month 12. Should scale. |
| Team composition profiles | Users define their actual team (solo dev, 3-person team, 10-person studio) and skills adjust advice | Solo dev doesn't need the same sprint plan structure as a 10-person team. |

---

## v2.0.0 — Platform & Ecosystem (Long Term Vision)

### Multi-Engine Deep Integration

| Feature | What | Why |
|---------|------|-----|
| Engine project scaffolding | `game-start` generates actual engine project files, not just documentation | Skills currently output markdown. A truly useful start skill would create `project.godot`, scene files, initial scripts. |
| Live code analysis | Engine specialists read actual game code and provide contextual advice | Currently skills give generic guidance. Reading the actual `player.gd` or `PlayerController.cs` and giving specific refactor advice would be transformative. |
| Build system integration | Skills invoke actual build commands, run game, capture screenshots | Connect to the actual development loop, not just the planning phase. |

### Community & Marketplace

| Feature | What | Why |
|---------|------|-----|
| Skill marketplace listing | Publish to Claude Code marketplace for one-click install | Currently requires manual git clone. Marketplace listing makes discovery frictionless. |
| Community skill contributions | CONTRIBUTING.md + skill template + validation CI for community PRs | 25 skills cover core needs. Community can build niche skills (VR, mobile, specific genres). |
| Genre-specific skill packs | Expansion packs: RPG Pack, Platformer Pack, Narrative Pack with genre-tailored agents | Current skills are genre-agnostic. Genre packs add specialized knowledge (RPG: quest design, skill trees; Platformer: level flow, difficulty curves). |

### AI-Native Features

| Feature | What | Why |
|---------|------|-----|
| Playtesting simulation | AI simulates player behavior patterns to predict balance issues before human playtesting | Most powerful application of AI in game dev — catch problems before they reach players. |
| Procedural content review | Skills evaluate proc-gen output for quality, variety, fairness | Procedural generation is growing but quality control is manual. AI review closes the loop. |
| Design pattern recognition | Skills detect common game design patterns in code and suggest improvements | "Your inventory system matches the Observer pattern but has coupling issues" — connecting code to design. |

---

## Community Wishlist

Have a feature request? Open an issue with the `wishlist` label.

Current community interests (from indie dev forums and game jam feedback):

- **Multiplayer architecture skill** — Netcode, rollback, state sync, lobby systems
- **Mobile optimization skill** — Touch controls, battery life, thermal management, app store specifics
- **VR/XR game skill** — Spatial interaction, comfort settings, locomotion design
- **Narrative branching tool** — Dialogue tree visualization, consequence tracking, Ink/Yarn integration
- **Asset pipeline automation** — Sprite sheet packing, texture atlasing, LOD generation guidance
- **Game jam mode** — Compressed versions of all workflows for 48-hour game jams
- **Genre templates** — Starter GDDs for common genres (roguelike, metroidvania, visual novel, tower defense)
- **Steam integration** — Steamworks SDK guidance, achievement design, workshop support
- **Console porting checklist** — Platform-specific requirements for Switch, PlayStation, Xbox

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| v1.2.0 | 2026-03-25 | 29 skills (+economy-designer, +accessibility-specialist, +localization-manager, +analytics-setup), voice consistency pass on all 25 existing skills, persona rewrites for technical-director and designer, full rebuilds of retrospective and team-orchestrator, 3 new templates, 2 new docs, all 9 agents get "When NOT to Use Me" sections, brainstorm gets market validation, balance gets statistical methods, launch gets post-launch ops, engine specialists get migration guides |
| v1.1.0 | 2026-03-25 | 25 skills (added scope-check, retrospective, reverse-document), 6 docs (added workflow-guide), 4 new templates, engine version updates, regulatory compliance, expanded game design theory |
| v1.0.0 | 2026-03-24 | Initial release — 22 skills, 10 templates, 5 docs, full agent hierarchy |

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) — Part of the AlterLab Skills Trilogy (FC Skills, Academic Skills, GameForge)*
