# Frequently Asked Questions

---

### 1. What is GameForge?

GameForge is a collection of 31 structured prompt files (called "skills") that transform Claude into specialized game development experts. These are not chatbot personas -- each skill is a 150--300+ line instruction set with real design frameworks, output templates, and collaboration protocols. Install them into Claude Code and they become slash commands you use while building your game.

### 2. How do I install it?

Run this in your terminal:

```bash
claude install github:AlterLab-IEU/AlterLab_GameForge
```

All 31 skills are immediately available as slash commands (e.g., `/game-start`, `/game-designer`, `/game-godot-specialist`). Alternatively, copy any `SKILL.md` file's contents into a Claude Project's custom instructions for the same effect.

### 3. Do I need all 31 skills?

No. The install command adds all of them, but you only use what you need. A solo Godot developer might primarily use `/game-start`, `/game-designer`, `/game-godot-specialist`, and `/game-sprint-plan`. A narrative-focused team might lean on `/game-narrative-director`, `/game-brainstorm`, and `/game-playtest`. If you want to pick individually, browse the [`skills/`](../skills/) folder and download specific `SKILL.md` files.

### 4. Which game engine does this work with?

GameForge is engine-agnostic at its core -- most skills (design, production, narrative, QA) work regardless of engine. On top of that, there are three engine specialists with deep, engine-specific knowledge: **Godot 4** (GDScript/C#), **Unity** (C#/ECS), and **Unreal Engine** (C++/Blueprints). The skills auto-detect your engine from project files when possible.

### 5. Can I use this with Claude Projects instead of Claude Code?

Yes. Copy the contents of any `SKILL.md` file into a Claude Project's custom instructions. Claude will adopt that skill's persona, frameworks, and output formats. The trade-off is that Claude Projects don't support slash commands or file operations, so skills that write files to your project will produce the content as chat messages instead.

### 6. Do skills work with other AI tools?

Skills are designed for Claude (Claude Code CLI and Claude Projects). The format is plain Markdown with YAML frontmatter, so the content is readable by any system, but the frontmatter fields (`allowed-tools`, `memory`, `context`, `effort`) are Claude Code-specific. Other AI tools won't interpret those fields, and the collaboration protocols between skills rely on Claude's architecture.

### 7. How do I know which skill to use?

Check the ["Where Do I Start?"](../README.md#where-do-i-start) decision table in the README. It maps common situations to the right skill. In Claude Code, you can also just describe what you need in plain language -- the skill routing system will activate the correct skill automatically based on keywords in your request.

### 8. What's the difference between agents and workflows?

**Agents** are roles -- they embody a specific expertise and stay in character throughout a conversation. The Game Designer thinks about mechanics and balance. The Art Director thinks about visual style and asset pipelines. You talk to them like team members.

**Workflows** are processes -- they guide you through a structured sequence of steps with a defined start and end. Sprint Plan takes you from "what should we build?" to a prioritized task list. Launch takes you from "the game is done" to "the game is on the store." They produce a deliverable and finish.

### 9. Can I create my own skills?

Yes. Follow the format in [CONTRIBUTING.md](../CONTRIBUTING.md) -- YAML frontmatter, role definition, capabilities, frameworks, output templates, and collaboration rules. Test with at least 3 prompts in Claude Code, then submit a PR. The minimum quality bar is 150 lines for workflows and 200 lines for agents, with no stub sections.

### 10. What's the AlterLab Skills Trilogy?

GameForge is one of three skill collections built by AlterLab, all sharing the same architecture and quality standards:

- [**AlterLab FC Skills**](https://github.com/AlterLab-IEU/AlterLab_FC_Skills) -- 72 skills for football coaching (tactical analysis, player development, match preparation)
- [**AlterLab Academic Skills**](https://github.com/AlterLab-IEU/AlterLab_Academic_Skills) -- 186+ skills for academic writing (research, papers, grants, peer review)
- **AlterLab GameForge** -- 31 skills for indie game development (this repo)

---

**Still have questions?** [Open an issue](https://github.com/AlterLab-IEU/AlterLab_GameForge/issues) and we'll help you out.

*Built by [AlterLab](https://github.com/AlterLab-IEU) -- Part of the AlterLab Skills Trilogy*
