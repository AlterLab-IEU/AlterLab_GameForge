---
name: narrative-genre-pack
genre: narrative
version: "2.0"
description: Design patterns, pacing templates, and brainstorm prompts for narrative-driven games
---

# Narrative Genre Pack

Design reference material for narrative-driven game development. This pack enriches existing GameForge skills with genre-specific knowledge -- it is not a skill itself.

## When to Use This Pack

- You are designing a game where **story and player choice are the primary engagement mechanics**
- You are building a **visual novel**, **walking sim**, **narrative RPG**, **interactive fiction**, or **narrative hybrid**
- You need **pacing metrics** for scene structure, branching complexity, or consequence mapping
- You are brainstorming and want **narrative-specific ideation constraints**

## Contents

| File | Purpose | Integrates With |
|------|---------|-----------------|
| [PATTERNS.md](PATTERNS.md) | Branching architecture, dialogue systems, choice design, environmental storytelling, MDA analysis | `game-narrative-director`, `game-designer`, `game-creative-director` |
| [balance-template.md](balance-template.md) | Pacing metrics, branch complexity budgets, consequence mapping, voice line budgets | `game-balance-check`, `game-narrative-director` |
| [brainstorm-variant.md](brainstorm-variant.md) | Narrative-specific ideation prompts, character design tools, world-building constraints | `game-brainstorm` |

## Reference Games Covered

Disco Elysium, Hades, Outer Wilds, Undertale, Pentiment, Citizen Sleeper, Baldur's Gate 3, The Witcher 3, Life is Strange, The Walking Dead (Telltale), Detroit: Become Human, Gone Home, What Remains of Edith Finch, Firewatch, Mass Effect, Stanley Parable, Spec Ops: The Line.

## Example Workflow

1. Run `game-brainstorm` with your initial concept
2. Load `brainstorm-variant.md` prompts to define the central question and emotional arc
3. Use `PATTERNS.md` to select branching architecture and dialogue system patterns
4. Use `balance-template.md` to set pacing targets and branch complexity budgets
5. Run `game-narrative-director` with the genre pack loaded for narrative-aware character and story development

## Contributing

See `@docs/genre-pack-spec.md` for the genre pack format specification and `CONTRIBUTING.md` for the contribution workflow. Improvements to reference games, anti-patterns, and pacing formulas are welcome.

---

*Part of [AlterLab GameForge](https://github.com/AlterLab-IEU/AlterLab_GameForge) genre packs*
