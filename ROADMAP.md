# AlterLab GameForge Roadmap

Current version: **v2.0.0** (34 skills, 20 templates, 15 docs, 11 hooks, 9 starters, 2 genre packs)

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

## v1.3.0 — Automation & Intelligence (SHIPPED)

### MCP Integrations

| Integration | What | Status |
|-------------|------|--------|
| MCP integration guide | `docs/mcp-integrations.md` — full catalog of 34 game dev MCP servers with tiered recommendations, setup guides, per-engine configs | SHIPPED |
| GitHub Issues workflow | MCP sections in game-producer, game-code-review, game-qa-lead for issue creation | SHIPPED |
| Notion GDD sync | MCP section in game-designer for Notion-backed GDD persistence | SHIPPED |
| Figma asset pipeline | MCP section in game-art-director and game-ux-designer for Figma integration | SHIPPED |
| Engine MCPs | MCP sections in engine specialists referencing godot-mcp (2.6K stars), unity-mcp (7.5K stars), unreal-mcp (1.6K stars) | SHIPPED |
| Audio MCP | MCP section in game-audio-director for ElevenLabs voice/SFX | SHIPPED |

### Advanced Workflows

| Workflow | What | Status |
|----------|------|--------|
| `game-postmortem` | 5-phase post-mortem with shell preprocessing for git stats (384 lines) | SHIPPED |
| `game-market-research` | 6-phase market research with competitive analysis and TAM/SAM/SOM (405 lines) | SHIPPED |
| Shell preprocessing | `!`command`` blocks in game-start (10 detectors) and game-sprint-plan (8 detectors) | SHIPPED |
| Named pipelines | 4 pipeline definitions in game-team-orchestrator with JSON state schema | SHIPPED |
| `game-ci-pipeline` | CI/CD setup for game builds | Deferred to v1.4.0 |

### Skill Intelligence

| Feature | What | Status |
|---------|------|--------|
| Cross-skill memory | `memory: project` on producer, designer, creative-director via persistent agent memory | SHIPPED |
| Adaptive complexity | Shell preprocessing detects project maturity in game-start and game-sprint-plan | SHIPPED |
| Frontmatter modernization | All 31 skills updated: `version`, `model`, `effort`, `context`, `memory`, `disable-model-invocation` | SHIPPED |
| Trigger optimization | All 31 skill descriptions rewritten for auto-invocation with trigger/anti-trigger keywords | SHIPPED |

### New Hooks (5)

| Hook | Event | Purpose |
|------|-------|---------|
| `post-compact` | PostCompact | Restore game dev context after compaction |
| `subagent-track` | SubagentStart/SubagentStop | Log agent delegation for orchestration |
| `instructions-validate` | InstructionsLoaded | Validate required docs on CLAUDE.md load |
| `stop-failure` | StopFailure | Save state and guide recovery on API errors |
| `config-change` | ConfigChange | Detect skill modifications during session |

### Content Freshness

| Update | Details |
|--------|---------|
| Engine versions | Godot 4.6.1 (floatable docks, ObjectDB, SSR rewrite), Unity 6.3 LTS (Havok licensing, pricing), UE 5.7 (Nanite Voxels/Skinning/PVE, SWRT deprecation) |
| COPPA April 2026 | Compliance deadline, biometric identifiers, formal infosec program |
| Steam AI disclosure | Three-tier framework (pre-generated, live-generated, dev tools exempt) |
| PEGI June 2026 | Loot boxes PEGI 16, NFTs PEGI 18, time-limited offers PEGI 12, daily quests PEGI 7 |
| App Store | iOS 26 SDK requirement April 28, 2026, Accessibility Nutrition Label |
| EAA enforcement | MSA designation, fine ranges, scope clarification for games |
| AI content policy | Template updated to match Steam three-tier framework |

---

## v1.4.0 — Launch Ready (SHIPPED)

### Starter Configurations (NEW)

| Starter | What | Status |
|---------|------|--------|
| `starters/claude-config/` | Base CLAUDE.md and settings.json for any game project | SHIPPED |
| `starters/godot/` | Godot 4.x CLAUDE.md and .gitignore with GDScript standards, scene conventions | SHIPPED |
| `starters/unity/` | Unity 6.x CLAUDE.md and .gitignore with C# standards, SO architecture | SHIPPED |
| `starters/unreal/` | Unreal 5.x CLAUDE.md and .gitignore with C++/Blueprint standards, GAS patterns | SHIPPED |
| `starters/README.md` | Setup guide with copy-paste instructions for all engines | SHIPPED |

### Documentation Overhaul (NEW)

| Doc | What | Status |
|-----|------|--------|
| `README.md` rewrite | Quick start section, "Where Do I Start?" routing table, architecture diagram, starters section, trilogy links | SHIPPED |
| `docs/workflow-examples.md` | Three end-to-end walkthroughs showing skill chaining in real scenarios | SHIPPED |
| `docs/FAQ.md` | Frequently asked questions with practical answers | SHIPPED |
| `docs/directory-conventions.md` | Recommended project directory layout for GameForge projects | SHIPPED |
| `CONTRIBUTING.md` | Full contribution guide with format reference, PR workflow, skill template | SHIPPED |

### Flexibility Pass

| Feature | What | Status |
|---------|------|--------|
| Hook rewrite (all 11) | Removed `set -e`, eliminated bash arrays, replaced hardcoded `src/` with `find_source_dirs`, all hooks end with `exit 0` | SHIPPED |
| `game-start` update | Engine-aware project bootstrapping with starter config references | SHIPPED |
| Directory conventions doc | `docs/directory-conventions.md` — recommended layouts without rigidity | SHIPPED |

### Community Infrastructure (NEW)

| Feature | What | Status |
|---------|------|--------|
| Issue templates (3) | Bug report, feature request, skill request — with YAML frontmatter, labels, structured sections | SHIPPED |
| PR template | Pull request template with type checkboxes and quality checklist | SHIPPED |
| `CODE_OF_CONDUCT.md` | Contributor Covenant code of conduct | SHIPPED |
| `SECURITY.md` | Security policy for skill-based projects | SHIPPED |
| `.github/SUBMISSIONS.md` | Awesome-list submission drafts for 5 curated lists | SHIPPED |
| `.gitignore` expansion | Coverage for OS files, IDE, Node, env, logs, GameForge runtime, Godot, Unity, Unreal, build outputs | SHIPPED |

### Deferred to v2.0.0

| Feature | Reason |
|---------|--------|
| `game-ci-pipeline` | Deferred from v1.3.0 and v1.4.0 — lower priority than starters and docs |
| `game-jam-mode` | Community request — deferred to v2.0.0 scope |
| Engine sub-specialists | Depth gap vs CCGS, but current single specialists cover core needs |
| File-type rules | Production quality gates — deferred pending user feedback |
| Guided GDD authoring | CCGS /design-system equivalent — deferred |
| Team composition profiles | Intelligence feature — deferred from v1.3.0 |

---

## v2.0.0 — Platform & Ecosystem (SHIPPED)

### New Skills

| Skill | What | Status |
|-------|------|--------|
| `game-ci-pipeline` | CI/CD setup for game builds — engine-specific pipelines (Godot, Unity, Unreal), deployment automation (Steam, itch.io, Epic), GitHub Actions examples (930 lines) | SHIPPED |
| `game-jam-mode` | Compressed 48-72 hour workflows for game jams — 6-phase workflow, theme interpretation, scope ruthlessness protocol (474 lines) | SHIPPED |
| `game-gdd-author` | Guided section-by-section GDD authoring — 10-section process, pillar validation, scope tier marking (683 lines) | SHIPPED |

### Depth Expansion

| Feature | What | Status |
|---------|------|--------|
| Engine deepening | Networking, animation, VFX, AI, and material system sections added to all 3 engine specialists (+100 lines each) | SHIPPED |
| Skill quality rubric | `docs/skill-quality-rubric.md` — 5-dimension scoring system (Trigger/Depth/Consistency/Usefulness/Voice) with minimum 8+ bar | SHIPPED |
| AI-native features | `docs/ai-native-gamedev.md` — honest assessment of AI game dev tools, integration points mapped to existing skills | SHIPPED |
| File-type rules | Production quality gates for different code types | Deferred to v2.1.0 |
| Team composition profiles | Users define team size/composition, skills adapt | Deferred to v2.1.0 |

### Genre Packs

| Pack | What | Status |
|------|------|--------|
| Roguelike | PATTERNS.md (358 lines), balance-template.md (298 lines), brainstorm-variant.md (191 lines) — permadeath, run structure, proc-gen, meta-progression, synergy systems, Monte Carlo validation | SHIPPED |
| Narrative | PATTERNS.md (455 lines), balance-template.md (225 lines), brainstorm-variant.md (218 lines) — branching architecture, choice design, dialogue systems, consequence modeling, 10+ reference games | SHIPPED |
| Genre pack spec | `docs/genre-pack-spec.md` — format specification for contributing genre packs | SHIPPED |

### CI/CD & Validation

| Feature | What | Status |
|---------|------|--------|
| Validation script | `scripts/validate.sh` — 9 categories, 486 checks (frontmatter, line count, JSON, hooks, cross-refs, orphans, versions, structure, genre packs) | SHIPPED |
| GitHub Actions | `.github/workflows/validate-skills.yml` — automated validation on push and PRs | SHIPPED |

### Templates & Docs

| Addition | What | Status |
|----------|------|--------|
| `templates/jam-concept.md` | One-page game jam concept template | SHIPPED |
| `templates/jam-submission.md` | Jam submission checklist | SHIPPED |
| `templates/ci-pipeline-config.md` | CI/CD configuration planning template | SHIPPED |
| `docs/ai-native-gamedev.md` | AI tools for game development — production-ready vs experimental | SHIPPED |
| `docs/genre-pack-spec.md` | Format specification for genre packs | SHIPPED |
| `docs/skill-quality-rubric.md` | 5-dimension quality scoring system | SHIPPED |

### Deferred to v2.1.0

| Feature | Reason |
|---------|--------|
| File-type rules | Production quality gates — needs user feedback on which file types matter most |
| Team composition profiles | Intelligence feature — lower priority than genre packs and CI |
| Engine project scaffolding | `game-start` generates actual engine project files — complex, needs per-engine testing |
| Live code analysis | Engine specialists read actual game code — already partially works via Claude Code, needs formalization |
| Build system integration | Skills invoke actual build commands — requires MCP integration work |
| Marketplace listing | Publish to Claude Code marketplace — pending marketplace availability |
| Awesome list submissions | PRs to 5 major awesome-claude lists — ready in `.github/SUBMISSIONS.md`, needs manual submission |

---

## v2.1.0 — Intelligence & Integrations (Next)

### Smart Skills

| Feature | What | Why |
|---------|------|-----|
| File-type rules | `shader-code`, `narrative`, `gameplay-code`, `engine-code` rules | Production quality gates that enforce different standards per file type |
| Team composition profiles | Skills adapt output based on declared team size (solo, small team, studio) | Solo dev doesn't need delegation advice; studio needs coordination protocols |
| Adaptive output depth | Skills detect project maturity and adjust verbosity | Prototype phase: brief. Production phase: exhaustive |

### Engine Deep Integration

| Feature | What | Why |
|---------|------|-----|
| Engine project scaffolding | `game-start` creates actual `project.godot`, `.csproj`, `.uproject` files | Transform from documentation tool to project bootstrapper |
| Live code analysis mode | Engine specialists give file-specific advice after reading actual game code | "Your `player.gd` has 400 lines — here's how to decompose it using composition" |
| Build system hooks | Skills trigger engine builds and report results | Close the feedback loop between design and execution |

### Genre Pack Expansion

| Pack | What | Why |
|------|------|-----|
| Survival-Crafting | Resource loops, crafting trees, base building, threat escalation | 3rd most requested genre after roguelike and narrative |
| Metroidvania | Ability gating, map interconnection, backtracking rewards, boss design | Strong indie presence, distinct design patterns |
| Tower Defense | Wave design, tower economy, pathing, difficulty curves | Underserved in game design tooling |

### Community & Marketplace

| Feature | What | Why |
|---------|------|-----|
| Marketplace listing | Publish to Claude Code marketplace for one-click install | Remove friction from adoption |
| Awesome list submissions | PRs to 5 major lists (drafts ready in `.github/SUBMISSIONS.md`) | Visibility is the #1 growth lever |
| SkillsMP / MCPMarket indexing | Ensure listing on major skill directories | 87K+ skills indexed, GameForge should be there |

---

## v3.0.0 — Platform (Long-Term Vision)

### AI-Native Game Development

| Feature | What | Why |
|---------|------|-----|
| Playtesting simulation | AI simulates player behavior patterns to predict balance issues | Catch problems before human playtesting — highest-value AI application |
| Procedural content review | Skills evaluate proc-gen output for quality, variety, fairness | Close the loop on procedural generation quality |
| Design pattern recognition | Skills detect game design patterns in code and suggest improvements | Bridge between code architecture and game design theory |

### Platform Features

| Feature | What | Why |
|---------|------|-----|
| Skill composition | Skills can declare dependencies and auto-chain | "Run balance-check after every designer session" without manual orchestration |
| Project memory | Cross-session persistence of game design decisions, balance parameters, milestone status | Skills pick up where you left off without re-explaining context |
| Visual dashboard | Web-based overview of project health, skill usage, quality metrics | Make the invisible visible |

### Ecosystem

| Feature | What | Why |
|---------|------|-----|
| Community genre packs | Contribution pipeline for third-party genre packs with automated quality validation | Scale genre coverage beyond what the core team can produce |
| Skill marketplace | Third-party skills that extend GameForge with specialized expertise | Open the platform to domain experts |
| Engine plugin bridges | MCP servers that connect GameForge skills to live engine editors | Real-time collaboration between Claude and the game engine |

---

## Community Wishlist

Have a feature request? Open an issue with the `wishlist` label.

Current community interests (from indie dev forums and game jam feedback):

- ~~**Game jam mode**~~ — ✅ SHIPPED in v2.0.0 (`game-jam-mode`)
- ~~**Genre templates**~~ — ✅ SHIPPED in v2.0.0 (roguelike + narrative genre packs)
- ~~**Multiplayer architecture**~~ — ✅ SHIPPED in v2.0.0 (networking sections in all 3 engine specialists)
- ~~**Narrative branching tool**~~ — ✅ SHIPPED in v2.0.0 (narrative genre pack with branching architecture patterns)
- ~~**Steam integration**~~ — ✅ SHIPPED in v2.0.0 (`game-ci-pipeline` includes Steam deployment)
- **Mobile optimization skill** — Touch controls, battery life, thermal management, app store specifics
- **VR/XR game skill** — Spatial interaction, comfort settings, locomotion design
- **Asset pipeline automation** — Sprite sheet packing, texture atlasing, LOD generation guidance
- **Console porting checklist** — Platform-specific requirements for Switch, PlayStation, Xbox
- **Survival-crafting genre pack** — Resource loops, crafting trees, base building patterns
- **Multiplayer lobby system** — Matchmaking, lobby management, session persistence

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| v2.0.0 | 2026-03-26 | 34 skills (+game-ci-pipeline, +game-jam-mode, +game-gdd-author), engine deepening (networking, animation, VFX, AI, materials in all 3 specialists), 2 genre packs (roguelike 888 lines, narrative 943 lines), CI validation (486 checks via validate.sh + GitHub Actions), 3 new docs (ai-native-gamedev, genre-pack-spec, skill-quality-rubric), 3 new templates (jam-concept, jam-submission, ci-pipeline-config), genre pack contribution guide in CONTRIBUTING.md |
| v1.4.0 | 2026-03-25 | Starters directory (9 files: base config, Godot, Unity, Unreal), documentation overhaul (README rewrite, workflow-examples, FAQ, directory-conventions, CONTRIBUTING), flexibility pass (all 11 hooks rewritten, hardcoded paths removed, bash arrays eliminated), community infrastructure (3 issue templates, PR template, CODE_OF_CONDUCT, SECURITY, .gitignore expansion, awesome-list submission drafts), docs count 9 to 12 |
| v1.3.0 | 2026-03-25 | 31 skills (+game-postmortem, +game-market-research), MCP integration doc with 34 verified servers, MCP sections in 7 skills, 5 new hooks (post-compact, subagent-track, instructions-validate, stop-failure, config-change), shell preprocessing in game-start and game-sprint-plan, named pipelines in game-team-orchestrator, all 31 skills frontmatter modernized (version, model, effort, context, memory), trigger optimization on all descriptions, engine updates (Godot 4.6.1, Unity 6.3 Havok/pricing, UE 5.7 Nanite/SWRT), regulatory freshness (COPPA April 2026, Steam 3-tier AI, PEGI June 2026, App Store iOS 26 SDK), accessibility updates (EAA enforcement, ESA 24 tags, Apple Nutrition Label), AI content policy template aligned to Steam framework |
| v1.2.0 | 2026-03-25 | 29 skills (+economy-designer, +accessibility-specialist, +localization-manager, +analytics-setup), voice consistency pass on all 25 existing skills, persona rewrites for technical-director and designer, full rebuilds of retrospective and team-orchestrator, 3 new templates, 2 new docs, all 9 agents get "When NOT to Use Me" sections, brainstorm gets market validation, balance gets statistical methods, launch gets post-launch ops, engine specialists get migration guides |
| v1.1.0 | 2026-03-25 | 25 skills (added scope-check, retrospective, reverse-document), 6 docs (added workflow-guide), 4 new templates, engine version updates, regulatory compliance, expanded game design theory |
| v1.0.0 | 2026-03-24 | Initial release — 22 skills, 10 templates, 5 docs, full agent hierarchy |

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) — Part of the AlterLab Skills Trilogy (FC Skills, Academic Skills, GameForge)*
