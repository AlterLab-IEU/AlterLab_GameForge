# AI-Native Game Development Reference

A practical guide to using AI tools in game development. This document separates production-ready tools from hype, with honest assessments of what works today (March 2026).

---

## Principle: Claude IS the AI

GameForge skills leverage what Claude does best: reading code, analyzing game systems, identifying patterns, and generating structured output. Features where Claude IS the intelligence layer are immediately shippable. Features that require external AI runtime (playtesting bots, real-time NPC dialogue, asset generation) need dedicated platforms.

---

## Production-Ready AI Game Dev Tools

### AI Playtesting & QA

| Tool | What It Does | Cost | Engine Support |
|------|-------------|------|----------------|
| **nunu.ai** | Multimodal AI agents that play your game via rendered frames. Finds visual/interaction/gameplay bugs. | Pricing not public (funded a16z) | Engine-agnostic |
| **Regression Games** | AI agent testing with bot sequences, scripted + exploratory bots. | Free tier available | Unity |
| **Unity ML-Agents** | RL toolkit for training agents to play your game. Discover exploits, test balance. | Free (open source) | Unity |

**What Claude does instead:** Analytical playtesting -- reads game systems code, identifies dominant strategies, missing edge cases, and balance issues WITHOUT executing the game. See `game-balance-check` and `game-playtest` skills.

### AI Asset Generation

| Category | Best Tools (2026) | Quality Level | Cost Range |
|----------|------------------|---------------|------------|
| **Concept Art** | Midjourney v7, Stable Diffusion XL, Scenario | Production-ready for pre-production | $10-60/month |
| **3D Models** | Meshy (props), Tripo (characters), Rodin Gen-2 (hero assets) | Good for prototyping, needs cleanup for production | $20-100/month |
| **Music** | Suno v5, Udio, AIVA | Production-ready for indie | $10-50/month |
| **Voice** | Inworld TTS ($5-10/M chars), ElevenLabs ($206/M chars) | TTS production-ready, not for hero character dialogue | Per-usage |
| **Textures** | Stable Diffusion XL (tiling), Adobe Firefly | Production-ready | $10-50/month |

**What Claude does instead:** Helps plan asset pipelines, write prompts, evaluate specifications. See `game-art-director` and `game-audio-director` skills.

### LLM NPC Dialogue

| Platform | Latency | Features | Indie Viability |
|----------|---------|----------|-----------------|
| **Inworld AI** | <130ms (Mini), <250ms (Max) | Full character AI, lipsync, emotions | Yes (free tier + pay-per-use) |
| **Convai** | ~200ms | NPC actions (open doors, lead player) | Yes |
| **Charisma** | Varies | Dynamic storylines, branching | Yes (indie-friendly pricing) |
| **Custom LLM** | 200-800ms | Full control, higher cost | For teams with ML expertise |

**Cost reality:** 10,000 players x 20 queries each = ~$250/month. Redis caching reduces costs ~73%. Hybrid routing (simple queries via traditional trees, complex via LLM) reduces LLM usage 37-46%.

**Best practice:** Hand-author critical story dialogue. Use LLMs for: shopkeeper banter, ambient world-building, procedural quest text, contextual barks.

**What Claude does instead:** Helps design NPC dialogue systems, write character sheets for LLM context, design prompt templates and guardrails. See `game-narrative-director` skill.

---

## What Claude Code Excels At (AI-Native GameForge Features)

### 1. Game Design Pattern Recognition

Claude reads game code and identifies architectural patterns -- State Machine, Observer/Event, Component/Entity, Object Pool, Command, Strategy -- and maps them to game design concepts. This is already integrated into `game-code-review` as the Game Design Pattern Analysis phase.

**Example output:** "Your inventory system uses Observer but has circular dependencies between ItemStack and InventorySlot. The Mediator pattern would decouple them and make the inventory testable."

### 2. Analytical Playtesting

Claude analyzes game systems code to predict where balance issues, exploits, and edge cases would emerge -- "static playtesting" through reasoning about systems without executing them. Enhanced in `game-balance-check` and `game-playtest`.

### 3. Procedural Generation Review

Claude reviews proc-gen algorithm code for common failure modes (lack of variety, missing constraints, adjacency rule gaps) and analyzes output data for statistical properties. Enhanced in `game-code-review`.

### 4. Systems Design Analysis

Claude traces interactions between game systems to identify emergent behavior, feedback loops, and potential exploits. This is inherent in `game-designer` and `game-balance-check`.

---

## Experimental (Not Yet Production-Ready)

- **AI-driven level design evaluation** -- Assessing "does this level feel fun" requires vision + game domain knowledge. Partial capability via image input but not tuned for game assessment.
- **Autonomous RL playtesting** -- Works in controlled environments (Unity ML-Agents, EA internal tools) but requires significant ML expertise and per-game training.
- **Real-time AI game directors** -- Dynamic difficulty, narrative direction, and event pacing controlled by AI. Left 4 Dead's AI Director was hand-tuned, not ML-based. True AI directors remain research-grade.

---

## Integration Points with GameForge Skills

| Feature | Integrated Into | What It Does |
|---------|----------------|-------------|
| Design pattern recognition | `game-code-review` | Identifies game-specific patterns and anti-patterns in code |
| Analytical playtesting | `game-balance-check`, `game-playtest` | Predicts balance issues and generates test scenarios from code analysis |
| Proc-gen review | `game-code-review` | Reviews proc-gen algorithms for completeness, statistical properties |
| NPC dialogue architecture | `game-narrative-director` | Designs LLM-powered dialogue systems, character sheets, guardrails |
| AI asset pipeline guidance | `game-art-director`, `game-audio-director` | Helps plan AI-assisted asset workflows |
| AI content policy | `templates/ai-content-policy.md` | Steam three-tier AI disclosure framework |

---

*Built by [AlterLab](https://github.com/AlterLab-IEU) -- Part of the AlterLab Skills Trilogy*
