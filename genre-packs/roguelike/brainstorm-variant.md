---
name: roguelike-brainstorm-variant
genre: roguelike
version: "2.0"
description: Genre-tailored ideation prompts and constraint generators for roguelike game brainstorming
---

# Roguelike Brainstorm Variant

Extension prompts for `game-brainstorm` when the target genre is roguelike or roguelite. These prompts replace generic ideation with genre-specific constraints that produce tighter, more viable concepts.

---

## 1. Core Run Loop Prompts

These prompts define the fundamental structure of your roguelike. Answer all three before moving to systems design.

### The Run Identity Question
> **What is the one mechanic that makes each run feel fundamentally different from the last?**
>
> In Slay the Spire, it's the card draft -- every run builds a different deck. In Hades, it's the boon selection -- every run combines different god powers. In Balatro, it's the joker collection -- every run scores differently.
>
> Your answer should be a single mechanic, not a list. If you need a list, you haven't found your core yet.

### The Persistence Question
> **What carries between runs, and why does it deserve to persist?**
>
> Categories of persistence (pick one or two, not all):
> - **Nothing** (traditional roguelike): Only player knowledge persists. Purest form.
> - **Unlocks** (roguelite): New items, characters, or modes enter the pool. Expands possibility space.
> - **Resources** (meta-progression): Currency spent on permanent upgrades. Risk: trivializing difficulty.
> - **Narrative** (story roguelike): Story advances regardless of run outcome. Hades model.
>
> **Danger zone**: If your persistence system makes runs easier over time (rather than more varied), you're building a grind game, not a roguelike.

### The Variation Question
> **What makes each run feel different in the first 5 minutes?**
>
> Players decide within the first few rooms whether this run is "a good one." What creates that feeling?
> - Different starting loadout?
> - Different map/biome layout?
> - Different early item/card offer?
> - Different challenge modifier?
>
> If runs feel the same for the first 10 minutes and only diverge later, you have an engagement problem.

---

## 2. Genre Constraint Prompts

These prompts force you to confront the design tensions unique to roguelikes.

### Permadeath Justification
> **How does permadeath serve the player experience, not just the genre label?**
>
> Permadeath is not free. It costs the player time and emotional investment. What does it buy them?
> - **Stakes**: Decisions matter because failure is permanent (Spelunky)
> - **Freshness**: Every run is a clean slate for experimentation (Slay the Spire)
> - **Story**: Death is a narrative mechanic, not a fail state (Hades)
> - **Learning**: Each death teaches something specific (Dead Cells)
>
> If you can't articulate what permadeath adds, consider whether your game is actually a roguelike or a linear game with randomized levels.

### Skill vs Luck Balance
> **What is the relationship between skill and luck in your game?**
>
> Plot your game on this spectrum:
> ```
> Pure Skill ←————————————————————————→ Pure Luck
> Dead Cells    Hades    Slay the Spire    Binding of Isaac    Vampire Survivors
> ```
>
> Neither extreme is wrong, but you must design for your position:
> - **Skill-heavy**: Needs tight controls, readable telegraphs, consistent enemy patterns
> - **Luck-heavy**: Needs pity systems, build-salvage mechanics, shorter runs to reduce frustration
> - **Balanced**: Needs both -- skill expression in execution, luck in item acquisition

### The "One More Run" Test
> **Why does the player start another run after dying?**
>
> The answer must be intrinsic, not extrinsic:
> - BAD: "Because they need 50 more cells to unlock the next weapon" (grind motivation)
> - GOOD: "Because they just realized poison + speed build might work and they want to try it" (curiosity motivation)
> - GOOD: "Because they want to see what Megaera says after that last interaction" (narrative motivation)
> - GOOD: "Because they almost beat the boss and know they can do it" (mastery motivation)

---

## 3. Systems Design Prompts

### Item/Power Design
> **Design your item system with exactly 3 constraints:**
>
> 1. **Total item pool size**: _____ items (aim for 80-200)
> 2. **Items acquired per run**: _____ items (aim for 8-20)
> 3. **Synergy density**: _____ % of items have at least one explicit synergy partner (aim for 30%+)
>
> Now: Can a player reasonably discover most synergies within 20 runs? If not, your pool is too large or your synergy density is too low.

### Procedural Generation Scope
> **What is procedurally generated, and what is hand-crafted?**
>
> | Element | Generated | Hand-Crafted | Hybrid |
> |---------|-----------|--------------|--------|
> | Level layout | | | |
> | Enemy placement | | | |
> | Item distribution | | | |
> | Boss encounters | | | |
> | Story events | | | |
> | Music/atmosphere | | | |
>
> **Rule of thumb**: Hand-craft anything that needs to feel authored (boss fights, story moments, tutorial). Generate anything that needs variety (level layout, item drops, enemy waves).

### Difficulty Curve Architecture
> **Sketch your difficulty curve for a single run:**
>
> ```
> Difficulty
>   |
>   |
>   |
>   |
>   +────────────────────────→ Run Progress
>     Start    Mid     Late    Boss
> ```
>
> Now answer:
> - Where are the recovery points? (Shops, rest sites, healing)
> - Where are the spikes? (Elites, mini-bosses, environmental hazards)
> - Does the curve match your target session length?

---

## 4. Subgenre Exploration

Use these prompts to explore specific roguelike subgenres.

### Action Roguelike (Hades, Dead Cells, Enter the Gungeon)
> - What is the core action verb? (Slash, shoot, dodge, dash)
> - How does the action feel at minute 1 vs minute 30? Does it evolve?
> - What is the dodge/invincibility mechanic? Every action roguelike needs one.
> - How many inputs does the player manage simultaneously? (Aim for 4-6 at most)

### Roguelike Deckbuilder (Slay the Spire, Monster Train, Inscryption)
> - What is your "card" equivalent? (Actual cards, dice, tiles, words)
> - How does the deck thin? Removal is as important as addition.
> - What is the energy/resource system that limits plays per turn?
> - How many cards should a winning deck contain? (Slay the Spire: 15-25 is typical)

### Roguelite with Heavy Meta-Progression (Rogue Legacy, Dead Cells)
> - How many runs until a new player has unlocked 50% of meta-progression?
> - Can a skilled player win Run 1 with zero unlocks? (If not, is that intentional?)
> - Does meta-progression add options or add power? (Options = good. Power = dangerous.)
> - What is the "I'm done" moment? When does meta-progression feel complete?

### Traditional Roguelike (Caves of Qud, DCSS, Cogmind)
> - Is your game turn-based? If so, how do you make turns feel weighty?
> - How deep is the simulation? (Inventory, hunger, identification, crafting)
> - What information is hidden vs revealed? (Unidentified items, fog of war, secret rooms)
> - How do you onboard new players into a complex system? (Or do you intentionally not?)

### Roguelike Hybrid (Balatro, FTL, Darkest Dungeon)
> - What non-roguelike genre are you combining with? (Poker, strategy, RPG, puzzle)
> - Which roguelike elements are you keeping? (Permadeath, procgen, item acquisition)
> - Which are you discarding? (And why?)
> - What does the roguelike structure add to the base genre that wasn't there before?

---

## 5. Market Positioning Prompts

> **What does your roguelike offer that Hades, Slay the Spire, and Dead Cells do not?**
>
> If your answer is "better graphics" or "more content," reconsider. The market leaders have years of content and polish. Your advantage must be structural:
> - A mechanic they can't retrofit (Balatro's poker scoring)
> - A theme they haven't explored (Inscryption's horror-deckbuilder)
> - An audience they don't serve (Vampire Survivors' casual-roguelike)
> - A platform they don't target (mobile-first roguelike with 5-minute runs)

> **Complete this sentence: "It's like [Reference Game] but [Key Difference]."**
>
> This is your elevator pitch. If the key difference isn't immediately compelling, iterate until it is.
>
> Examples:
> - Balatro: "It's like Slay the Spire but with poker hands instead of cards."
> - Vampire Survivors: "It's like a roguelike but you only move -- attacks are automatic."
> - Inscryption: "It's like Slay the Spire but the card game is a horror escape room."

---

*This document extends `game-brainstorm` with roguelike-specific prompts. Use after the initial brainstorm session to deepen the concept with genre-appropriate constraints. See `@genre-packs/roguelike/PATTERNS.md` for design pattern reference.*
