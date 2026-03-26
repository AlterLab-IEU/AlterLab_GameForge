---
name: roguelike-patterns
genre: roguelike
version: "2.0"
description: Core design patterns, anti-patterns, and analytical frameworks for roguelike and roguelite game development
---

# Roguelike Design Patterns

Reference material for `game-designer`, `game-brainstorm`, and `game-balance-check`. This document catalogs the structural patterns that define roguelike games, grounded in shipped titles and postmortem analysis.

---

## 1. Permadeath Philosophy

Permadeath is the genre's defining constraint. It transforms every decision into a meaningful one because the consequence of failure is total.

### The Learning Loop

Death in a well-designed roguelike teaches. The player dies, understands why, and applies that knowledge to the next run. This is the core engagement loop:

```
Attempt -> Encounter Unknown -> Make Decision -> Succeed or Die -> Learn -> Attempt Again
```

**Spelunky** codified "solvable randomness": every death is the player's fault, even when the level is procedurally generated. The system never generates an impossible scenario. The player always had a path -- they just didn't see it or execute it.

**Hades** softened permadeath with narrative justification. Zagreus returns to the House of Hades after each death, and the story advances. Death is a narrative beat, not a punishment. This is the gold standard for making permadeath feel like progression rather than loss.

### Run Structure

A run is a single attempt from start to finish. Run structure defines the pacing arc:

| Component | Purpose | Example |
|-----------|---------|---------|
| **Opening** | Low stakes, build momentum, establish the run's identity | Slay the Spire Act 1: easy fights, card draft begins |
| **Midgame** | Power spikes, build definition, escalating challenge | Dead Cells: biome 2-3, weapon synergies emerge |
| **Climax** | Maximum difficulty, build tested to its limit | Hades: Hades boss fight, all boons tested simultaneously |
| **Resolution** | Victory or death, clear feedback on what worked | Balatro: final ante, did your deck scale enough? |

### Session Length

Session length is a critical design parameter. Too short and runs feel inconsequential. Too long and permadeath feels punishing.

| Game | Average Run | Target Audience |
|------|-------------|-----------------|
| Vampire Survivors | 15-30 min | Casual, mobile-friendly |
| Slay the Spire | 45-90 min | Strategic, session-based |
| Hades | 20-40 min | Action, replayable |
| Dead Cells | 30-60 min | Action, skill-based |
| Balatro | 30-60 min | Strategic, escalating |
| Enter the Gungeon | 30-45 min | Action, bullet hell |

**Design rule**: If your run takes longer than 60 minutes, you need checkpoints or meta-progression generous enough that a failed long run still feels worthwhile.

### Risk/Reward Loops

Every room, floor, and decision should present a risk/reward tradeoff:

- **Slay the Spire**: Elite fights are harder but drop relics. Do you take the elite path or the safe path?
- **Hades**: Boon choices force you to commit to a build direction. Taking Ares over Athena changes your entire run.
- **Dead Cells**: Timed doors reward speed but punish exploration. Cursed chests give powerful items but make you one-hit-kill for 10 enemies.
- **Risk of Rain 2**: Time is the enemy. Looting longer makes you stronger but makes enemies scale harder. The tension between "one more chest" and "get to the teleporter" is the core decision.

---

## 2. Procedural Generation Patterns

Procedural generation (procgen) creates replayability but introduces the risk of sameness, impossible layouts, and meaningless variation.

### Wave Function Collapse (WFC)

WFC generates levels by propagating constraints from a set of hand-authored tiles. Each tile defines adjacency rules (which tiles can neighbor it on each side). The algorithm collapses possibilities one cell at a time, ensuring global consistency.

**Strengths**: Produces visually coherent layouts. Scales well. Easy to add new tile types.
**Weaknesses**: Can produce dead ends or disconnected regions without post-processing. Generation time can spike on large grids.
**Best for**: Top-down dungeon layouts, terrain generation, room interiors.
**Used by**: Bad North (island generation), Townscaper (architectural generation).

### Binary Space Partitioning (BSP)

BSP recursively divides a rectangular space into smaller rectangles, then places rooms within each partition and connects them with corridors. Guarantees connectivity.

**Strengths**: Always produces connected layouts. Predictable room count. Fast.
**Weaknesses**: Layouts feel grid-like. Rooms tend to be rectangular. Limited organic feel.
**Best for**: Traditional dungeon crawlers, roguelikes with discrete rooms.
**Used by**: Classic roguelikes (NetHack-era), many tutorial implementations.

### Cellular Automata

Start with random noise, then apply rules (e.g., "a cell becomes wall if 5+ of its 8 neighbors are walls") over several iterations. Produces organic, cave-like spaces.

**Strengths**: Organic feel. Simple to implement. Good for natural environments.
**Weaknesses**: Can produce disconnected regions (flood-fill cleanup required). Less control over room count and size.
**Best for**: Cave systems, organic environments, biome generation.
**Used by**: Dwarf Fortress (cave generation), Spelunky (level variants).

### Hand-Crafted Rooms + Random Connections (The Hades Model)

Design individual rooms by hand, then connect them randomly. Each room is a curated encounter, but the sequence is procedural.

**Strengths**: Every individual encounter is polished. Designers control difficulty per room. Rooms can tell micro-stories.
**Weaknesses**: Finite room pool means repetition. Requires large content investment. Sequence randomness can create difficulty spikes.
**Best for**: Action roguelikes where encounter quality matters more than spatial novelty.
**Used by**: Hades, Enter the Gungeon, The Binding of Isaac.

### Graph-Based Generation

Define the dungeon as a directed graph of encounters, shops, rest sites, and bosses. Then map the graph onto a spatial layout. This separates pacing design from spatial design.

**Strengths**: Pacing is designed, not random. Graph structure guarantees the player hits shops and rest sites at designed intervals.
**Weaknesses**: Spatial layout can feel disconnected from the pacing graph. Requires two-layer generation.
**Best for**: Games where pacing matters more than spatial exploration.
**Used by**: Slay the Spire (the map IS the graph), FTL (sector map).

---

## 3. Meta-Progression Systems

Meta-progression is what carries between runs. It's the long-term motivation layer that sits on top of the per-run engagement loop.

### Permanent Unlock Systems

| Game | Meta-Currency | What Unlocks | Runs to Full Unlock |
|------|---------------|--------------|---------------------|
| Hades | Darkness, Keys, Diamonds, Ambrosia, Titan Blood | Mirror upgrades, weapon aspects, relationship progress | ~80-100 runs |
| Dead Cells | Cells | Weapons, mutations, abilities, outfits | ~50-80 runs |
| Slay the Spire | Card unlocks per character | New cards enter the card pool | ~5-10 runs per character |
| Risk of Rain 2 | Lunar coins, challenge completions | Characters, items, abilities | ~30-50 runs |
| Balatro | Discover jokers, win with certain decks | New jokers, decks, challenge modes | ~20-40 runs |

### Knowledge as Progression

Some games make the player's knowledge the primary progression system, not mechanical unlocks:

- **Outer Wilds**: No mechanical upgrades. You learn how the solar system works and use that knowledge to explore further.
- **Return of the Obra Dinn**: No unlocks. You piece together the puzzle with deduction. Each playthrough is faster because you know more.

This is the purest form of roguelike design: the player improves, not the character.

### The Meta-Progression Trap

Too much meta-progression undermines the genre. If permanent upgrades make runs trivially easy, the game becomes a grind-to-win progression game wearing a roguelike mask.

**Design rule**: Meta-progression should expand the possibility space (new builds, new strategies, new content), not flatten the difficulty curve. Hades' Mirror of Night gives you options, not raw power. Dead Cells' cell unlocks add weapons to the item pool, not stat boosts.

---

## 4. Item and Ability Design

### Synergy Systems

Synergies are what make roguelikes replayable. When items combine in unexpected ways, every run feels unique.

**Synergy tiers:**

1. **Intended synergies**: Designed by the developer. Slay the Spire's Shiv cards + "After You Play 3 Attacks" relics.
2. **Emergent synergies**: Discovered by players from the interaction of simple rules. The Binding of Isaac's item stacking producing absurd combinations.
3. **Broken synergies**: Unintended combinations that trivialize the game. These need monitoring and either balancing or celebrating (some games lean into brokenness as a feature -- Vampire Survivors).

### Build Diversity

A healthy roguelike offers multiple viable builds that feel meaningfully different to play:

- **Hades**: Each weapon has 4 aspects, each aspect favors different boon combinations. 6 weapons x 4 aspects x multiple boon paths = hundreds of viable builds.
- **Slay the Spire**: Each character has 3-4 archetype builds (Ironclad: Strength, Block, Exhaust, Body Slam). Runs succeed when you find synergies within an archetype.
- **Risk of Rain 2**: Each survivor has a playstyle, but items can push any survivor into unexpected builds. Engineer with movement speed items plays completely differently than Engineer with damage items.

### Power Curve Management

The player should feel progressively more powerful within a run, but enemies should scale to maintain tension.

```
Player Power: ████████████████████████████████████████ (linear-to-exponential growth)
Enemy Scaling: ████████████████████████████████████     (linear growth, slightly behind)
Tension:       ██████████████████████████████████████   (maintained by spikes and boss encounters)
```

**Balatro** does this exceptionally: your scoring potential grows exponentially as jokers synergize, but blind targets also escalate. The gap between your power and the target is the tension.

---

## 5. Difficulty Design

### Within-Run Difficulty

Difficulty within a single run follows a sawtooth pattern: escalation punctuated by recovery.

```
Difficulty
  |      /\      /\        /\
  |    /    \  /    \    /    \/\
  |  /       \/      \/        \
  | /                            (Boss)
  +-----------------------------------> Time
    Floor 1   Floor 2   Floor 3   Final
```

Each floor starts with easier encounters, escalates to a mini-boss or elite, then resets slightly at the next floor's opening. The overall trend is upward.

### Across-Run Difficulty (Ascension/Heat Systems)

Post-completion difficulty modifiers add replayability for skilled players:

- **Slay the Spire Ascension** (20 levels): Each level adds a specific modifier (less gold, harder elites, more HP on enemies). Players choose their challenge level.
- **Hades Heat** (64 levels per weapon): Modular difficulty. Players pick which modifiers to stack. This gives agency -- you choose HOW it's harder, not just that it is.
- **Dead Cells Boss Cells** (5 levels): Each level fundamentally changes the game by restricting healing, adding enemies, and altering biome connections.

**Design rule**: Higher difficulty should change how you play, not just how long you survive. Stat inflation alone is lazy difficulty design.

### Entropy Management

Entropy is the measure of randomness and chaos within a run. Too little entropy and runs feel the same. Too much and player skill is irrelevant.

- **Low entropy**: Player has high control. Slay the Spire's card draft is low entropy -- you choose what enters your deck.
- **High entropy**: Player has low control. The Binding of Isaac's item rooms are high entropy -- you get a random item with no choice.
- **Managed entropy**: Systems that let the player reduce entropy. Hades' boon rerolling (Fated Authority) lets you reject bad RNG. Dead Cells' item recycling lets you convert unwanted items.

**Design rule**: Give the player at least one entropy-reduction mechanism per run. The feeling of "I can work with this" is more satisfying than "I got lucky."

---

## 6. Anti-Patterns

### Death Tax

**Problem**: Losing progress feels punishing, not challenging. The player loses resources, unlocks, or time with no compensating benefit.
**Symptom**: Players quit after death instead of immediately starting a new run.
**Fix**: Ensure every run contributes something -- meta-currency, narrative progress, knowledge, or at minimum a sense of "I know what to do differently now."
**Example of the problem**: Early roguelikes with no meta-progression where 2-hour runs ended with nothing gained.
**Example of the fix**: Hades advances the story with every death. You always have a reason to talk to characters between runs.

### Optimal Path

**Problem**: One dominant strategy emerges and every other approach is strictly inferior.
**Symptom**: Tier lists with S-tier items and everything else is "never pick."
**Fix**: Balance through synergy, not raw power. An item that's mediocre alone but powerful in combination keeps more of the item pool viable.
**Example of the problem**: Early Slay the Spire builds where Corruption + Dead Branch on Ironclad trivialized every encounter.
**Example of the fix**: Slay the Spire's ongoing balance patches that nerf outliers and buff underperformers based on win-rate data.

### Information Overload

**Problem**: Too many systems, stats, and mechanics introduced simultaneously.
**Symptom**: New players feel overwhelmed and quit before reaching the "fun part."
**Fix**: Gate system introduction across runs. Slay the Spire unlocks cards gradually over the first several runs per character.
**Example of the problem**: Traditional roguelikes with hundreds of unidentified items and no tutorial.
**Example of the fix**: Hades introduces one mechanic per run for the first 10 runs (weapons, boons, mirror, keepsakes, etc.).

### False Randomness

**Problem**: Truly uniform random distributions feel unfair because humans expect streaks to self-correct (the gambler's fallacy).
**Symptom**: Players complain about "bad RNG" even when the math is fair.
**Fix**: Use pseudo-random distribution (PRD) where the probability increases after each failure. Pity systems for item drops.
**Example**: If an item has a 10% drop rate, true random can produce 30+ failures in a row. PRD ensures that by the 15th attempt, the effective rate is much higher.

### Kitchen Sink Syndrome

**Problem**: Too many item types, enemy types, or systems dilute the identity of each component.
**Symptom**: Players can't distinguish between items or remember what anything does.
**Fix**: Fewer items with stronger identities. Every item should change how you play, not just change a number.
**Example of the problem**: Games with 200+ items where most are "+5% damage" with different names.
**Example of the fix**: Balatro has ~150 jokers, but each one has a unique mechanical identity. Players remember jokers by what they DO, not what they're called.

### Grind Wall on Meta-Progression

**Problem**: Early runs feel pointless because meaningful upgrades require dozens of hours of meta-currency farming.
**Symptom**: Players feel the game "doesn't really start" until they've unlocked enough meta-progression.
**Fix**: Front-load meaningful unlocks. The first 5 runs should each unlock something that changes how the game plays.
**Example of the fix**: Hades gives you a new weapon within the first few runs. Dead Cells drops cells generously in early runs.

---

## 7. Reference Games

### Hades (Supergiant Games, 2020)
**Why it matters**: The gold standard for roguelike meta-progression and narrative integration. Proved that roguelikes can have deep stories.
**Key patterns**: Hand-crafted rooms + random connections, modular heat system, narrative-justified permadeath, relationship-driven meta-progression.
**MDA**: Challenge (combat mastery) + Narrative (character relationships) + Discovery (build experimentation).

### Slay the Spire (MegaCrit, 2019)
**Why it matters**: Defined the roguelike deckbuilder subgenre. Pioneered data-driven balance using player statistics.
**Key patterns**: Graph-based map generation, draft-based item acquisition, character archetypes with distinct build paths, Ascension difficulty system.
**MDA**: Challenge (strategic optimization) + Discovery (synergy discovery) + Submission (zen of the card game flow).

### Dead Cells (Motion Twin, 2018)
**Why it matters**: Bridged the gap between action platformer and roguelike. Demonstrated that tight controls can coexist with permadeath.
**Key patterns**: Metroidvania-influenced biome gating, cell-based meta-progression, timed doors as risk/reward, Boss Cells as difficulty tiers.
**MDA**: Challenge (execution skill) + Sensation (fluid combat feel) + Discovery (biome exploration).

### Balatro (LocalThunk, 2024)
**Why it matters**: Proved roguelike mechanics work in any genre (poker). Solo-developed. Became 2024's breakout indie hit.
**Key patterns**: Escalating ante as difficulty scaling, joker synergies as build definition, hand modification as strategic depth, minimalist presentation.
**MDA**: Challenge (score optimization) + Discovery (joker synergy discovery) + Expression (deck identity).

### Enter the Gungeon (Dodge Roll, 2016)
**Why it matters**: Demonstrated bullet hell can merge with roguelike progression. Table flip mechanic as panic button.
**Key patterns**: Bullet-hell-density-as-difficulty, gun identity (every gun feels different), shrine risk/reward, secret floors as exploration reward.
**MDA**: Challenge (dodge mastery) + Sensation (visual spectacle) + Discovery (secret rooms and guns).

### Risk of Rain 2 (Hopoo Games, 2020)
**Why it matters**: Proved 3D roguelikes work. Time-as-enemy creates a unique pacing tension.
**Key patterns**: Time scaling (enemies grow stronger with time), stacking items for exponential power, looping as endgame, survivor-specific playstyles.
**MDA**: Challenge (time pressure optimization) + Sensation (power fantasy escalation) + Fellowship (co-op scaling).

---

## 8. MDA Analysis for Roguelikes

Using the MDA Framework from `@docs/game-design-theory.md`:

### Primary Aesthetics

1. **Challenge**: The core aesthetic. Roguelikes are fundamentally about overcoming difficulty through skill, knowledge, and adaptation.
2. **Discovery**: Finding new items, synergies, strategies, and secrets. Every run should contain at least one moment of "I didn't know that was possible."

### Secondary Aesthetics

3. **Sensation**: The feel of combat, card plays, or dice rolls. Hades' combat feel, Balatro's chip animations, Dead Cells' hit feedback.
4. **Expression**: Building a unique character/deck/loadout that reflects your playstyle. "This is MY build."
5. **Narrative**: Optional but powerful. Hades proved narrative can be a primary aesthetic in roguelikes.

### Dynamics That Produce These Aesthetics

| Dynamic | Produces | Mechanics That Drive It |
|---------|----------|------------------------|
| Build optimization | Challenge + Expression | Item synergies, draft choices, resource allocation |
| Risk assessment | Challenge + Discovery | Room/path selection, cursed items, elite fights |
| Escalating power | Sensation + Expression | Item stacking, combo systems, power spikes |
| Death-and-retry | Challenge + Discovery | Permadeath, meta-knowledge, run variation |
| Narrative progression | Narrative + Discovery | Between-run story beats, relationship unlocks |

### Designing with MDA

When designing a roguelike, start with your target aesthetics and work backward:

1. **Pick 2 primary aesthetics** from the list above. Challenge is almost always one of them.
2. **Identify the dynamics** that produce those aesthetics.
3. **Design mechanics** that create those dynamics.
4. **Playtest** to verify the aesthetics emerge in practice.

Example: If your aesthetics are Challenge + Narrative (Hades model), you need dynamics that tie story progression to death-and-retry. This means: story beats between runs, character relationships that advance regardless of run outcome, and narrative justification for permadeath.

---

## 9. Subgenre Reference

| Subgenre | Defining Feature | Key Reference |
|----------|-----------------|---------------|
| Traditional Roguelike | Turn-based, tile-based, ASCII or tile graphics | Caves of Qud, Cogmind, DCSS |
| Action Roguelike | Real-time combat, skill-based execution | Hades, Dead Cells, Enter the Gungeon |
| Roguelike Deckbuilder | Card-based combat, draft mechanics | Slay the Spire, Monster Train, Inscryption |
| Roguelite | Significant meta-progression between runs | Rogue Legacy, Dead Cells, Hades |
| Bullet Heaven | Roguelike + auto-attack + swarm survival | Vampire Survivors, Brotato |
| Roguelike + [Genre] | Roguelike mechanics in unexpected genre | Balatro (poker), Darkest Dungeon (RPG), FTL (strategy) |

---

*This document is reference material for AlterLab GameForge skills. It enriches `game-designer`, `game-brainstorm`, and `game-balance-check` with roguelike-specific domain knowledge. See `@genre-packs/roguelike/balance-template.md` for tuning parameters and `@genre-packs/roguelike/brainstorm-variant.md` for ideation prompts.*
