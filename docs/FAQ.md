# Frequently Asked Questions

---

### 1. What is GameForge?

GameForge is a Claude Code plugin that gives you a full indie game studio: 41 skills (11 studio
agents, 25 workflows, 5 engine specialists), 11 studio subagents that keep project memory, 7
lifecycle hooks, and a shared knowledge base of design theory, engine comparisons and
AI-in-gamedev guidance. Each skill is a researched instruction set with frameworks, decision rules
and output templates, not a persona prompt.

### 2. How do I install it?

In Claude Code (2.1.275 or later):

```
/plugin install gameforge --marketplace AlterLab-IEU/AlterLab_GameForge
```

Or in two steps, from a session or a shell:

```
/plugin marketplace add AlterLab-IEU/AlterLab_GameForge
/plugin install gameforge@alterlab-gameforge
```

```bash
claude plugin marketplace add AlterLab-IEU/AlterLab_GameForge
claude plugin install gameforge@alterlab-gameforge
```

Skills are then available as `/gameforge:<skill>`, for example `/gameforge:game-start`. Claude
also invokes them automatically when your request matches. To have teammates prompted to install
GameForge when they open your game repo, copy `starters/claude-config/settings.json` to
`.claude/settings.json`.

Older instructions that say `claude install github:AlterLab-IEU/AlterLab_GameForge` are wrong:
`claude install` reinstalls the Claude Code binary itself.

### 3. Where do I start?

Run `/gameforge:game-help`. It reads your project (engine, phase, existing docs) and recommends one
skill or a short chain. For a brand-new project run `/gameforge:game-start`; for "playable tonight"
run `/gameforge:game-vibe-code`.

### 4. Do I need all 41 skills?

No. Every skill's description sits in Claude's context so it can be invoked automatically (about a
hundred tokens each); the full skill only loads when it is used, and deep reference material inside a
skill loads only when that part of the work needs it. A solo Godot developer might mostly use
`game-start`, `game-designer`, `game-godot-specialist` and `game-sprint-plan`. Run
`claude plugin details gameforge` to see the exact token cost.

### 5. Which engines does it support?

Design, production, narrative, QA and launch skills are engine-agnostic. Five engine specialists go
deep: **Godot 4.7/4.8**, **Unity 6.3 LTS / 6.6**, **Unreal Engine 5.8**, **Three.js / React Three
Fiber** (WebGPU and WebGL), and **2D web** (Phaser 4, PixiJS 8, Kaplay, Excalibur). The session hook
detects your engine from its project files and routes engine questions to the right specialist.

### 6. What are the hooks doing in my project?

Nothing, unless it is a game project. In a game project they brief Claude at session start (engine,
phase, saved focus), snapshot state before compaction, check commit messages (after you opt in), stop
commits of large binaries that Git LFS is not tracking, and block edits to engine-generated files such
as `.godot/`, Unity `Library/` or Unreal `.uasset`. Everything is documented in [hooks.md](hooks.md),
and `GAMEFORGE_HOOKS=off` turns them all off.

### 7. What is the difference between agents, workflows and subagents?

**Studio agents** are roles you consult: the Game Designer thinks about mechanics and balance; the
Technical Director about architecture and risk. **Workflows** are guided processes with a defined
output, like a sprint plan or a release checklist. **Subagents** are the same eleven roles running in
their own context: `/gameforge:game-team-orchestrator` sends them work in parallel and synthesizes
their reports, and each keeps a project-scoped memory of its decisions.

### 8. Does GameForge help me build games with AI coding agents?

Yes; that is a first-class path in v3. `/gameforge:game-vibe-code` runs a disciplined loop (spec,
scaffold, one verified feature at a time, git checkpoints, a `progress.md` hand-off) so an agent-built
game stays playable and maintainable. Every skill also has a section on working with AI coding
agents for its role. The background is in [vibe-coding.md](vibe-coding.md).

### 9. Will it help me clone a game I love?

It will help you build an original game that keeps the mechanic you love. GameForge steers away from
recreating specific existing games (names, characters, art, music, levels, look), and Claude Code
itself declines such requests. Original designs are also what stores and portals reward; clones are
increasingly removed.

### 10. What about AI-generated art, audio and disclosure?

`/gameforge:game-ai-assets` covers tool choice and licences, style consistency, post-processing, and a
provenance log (`templates/ai-asset-log.md`) from which disclosures are drafted: Steam's AI content
survey, itch.io tagging, and the EU AI Act's transparency rules. `/gameforge:game-launch` and
`/gameforge:game-web-publish` check those disclosures before release.

### 11. Can I use the skills outside Claude Code?

The `SKILL.md` files are plain Markdown and readable anywhere; you can paste one into a Claude
Project's instructions. You lose slash commands, file operations, hooks, subagents and the
`${CLAUDE_PLUGIN_ROOT}` references to shared docs, so Claude Code is the intended home.

### 12. Can I create my own skills?

Yes. Follow [CONTRIBUTING.md](../CONTRIBUTING.md): documented frontmatter only, `SKILL.md` between
the category minimum and 500 lines with deep material in `references/`, concrete output templates,
and `python3 scripts/validate.py` passing. Genre-specific material can ship as a genre pack
([genre-pack-spec.md](genre-pack-spec.md)).

### 13. What else does AlterLab make?

GameForge is one of AlterLab's skill collections, built to the same standards:

- [**AlterLab FC Skills**](https://github.com/AlterLab-IEU/AlterLab-FC-Skills): skills for communication students: PR and advertising, cinema, new media, GenAI production, visual communication, research methods
- [**AlterLab Academic Skills**](https://github.com/AlterLab-IEU/AlterLab-Academic-Skills): evaluated academic research skills across many research domains, with a citation verifier and research-to-review pipelines

---

**Still have questions?** [Open an issue](https://github.com/AlterLab-IEU/AlterLab_GameForge/issues).

*Built by [AlterLab](https://github.com/AlterLab-IEU), Izmir University of Economics.*
