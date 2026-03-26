---
name: roguelike-genre-pack
genre: roguelike
version: "2.0"
description: Design patterns, balance templates, and brainstorm prompts for roguelike and roguelite games
---

# Roguelike Genre Pack

Design reference material for roguelike and roguelite game development. This pack enriches existing GameForge skills with genre-specific knowledge -- it is not a skill itself.

## When to Use This Pack

- You are designing a game with **permadeath and run-based progression**
- You are building a **roguelike deckbuilder**, **action roguelike**, **roguelite**, or **roguelike hybrid**
- You need **balance parameters** for item drops, difficulty scaling, or economy tuning in a run-based game
- You are brainstorming and want **genre-specific ideation constraints**

## Contents

| File | Purpose | Integrates With |
|------|---------|-----------------|
| [PATTERNS.md](PATTERNS.md) | Core design patterns, anti-patterns, MDA analysis, reference games | `game-designer`, `game-creative-director` |
| [balance-template.md](balance-template.md) | Run economy, damage curves, drop rates, Monte Carlo setup | `game-balance-check`, `game-economy-designer` |
| [brainstorm-variant.md](brainstorm-variant.md) | Genre-specific ideation prompts and constraint generators | `game-brainstorm` |

## Reference Games Covered

Hades, Slay the Spire, Dead Cells, Balatro, Enter the Gungeon, Risk of Rain 2, Spelunky 2, The Binding of Isaac, Vampire Survivors, Inscryption, Caves of Qud, Cogmind, Rogue Legacy, Monster Train, FTL, Darkest Dungeon.

## Example Workflow

1. Run `game-brainstorm` with your initial concept
2. Load `brainstorm-variant.md` prompts to deepen the concept with roguelike-specific constraints
3. Use `PATTERNS.md` to select which design patterns fit your game
4. Use `balance-template.md` to set initial tuning parameters
5. Run `game-balance-check` with the genre pack loaded for roguelike-aware feedback

## Contributing

See `@docs/genre-pack-spec.md` for the genre pack format specification and `CONTRIBUTING.md` for the contribution workflow. Improvements to reference games, anti-patterns, and balance formulas are welcome.
