---
name: narrative-patterns
genre: narrative
version: "2.0"
description: Core design patterns, anti-patterns, and analytical frameworks for narrative-driven game development
---

# Narrative Game Design Patterns

Reference material for `game-designer`, `game-narrative-director`, and `game-brainstorm`. This document catalogs the structural patterns that define narrative-driven games, from visual novels to narrative RPGs to environmental storytelling experiences.

---

## 1. Branching Architecture

The branching architecture defines how player choices create divergent paths through the story. Every narrative game must choose an architecture -- it determines scope, budget, and the type of player agency you offer.

### Hub-and-Spoke

The story passes through a central hub repeatedly. The player ventures out on missions/quests/chapters (spokes) and returns to the hub, where consequences accumulate and new spokes unlock.

```
          Spoke A
         /
Hub ──── Spoke B ────── Hub (updated) ──── Spoke D
         \                                /
          Spoke C ──────────────────────── Spoke E
```

**Strengths**: Manageable scope. The hub provides a consistent anchor. State changes in the hub are visible and satisfying.
**Weaknesses**: Can feel episodic rather than continuous. Hub visits can become routine.
**Used by**: Hades (House of Hades as hub), Mass Effect (Normandy as hub), Disco Elysium (Whirling-in-Rags as hub), Pentiment (Tassing as hub).

### Parallel Paths

The story splits into 2-3 major paths early on. Each path is a substantially different experience with different characters, locations, and themes. Paths may converge at the ending or remain separate.

```
        Path A ─────────────── Ending A
       /
Start ── Path B ─────────────── Ending B
       \
        Path C ─────────────── Ending C
```

**Strengths**: High replay value. Each playthrough feels genuinely different. Marketing can promise "3 unique stories."
**Weaknesses**: 3x the content for 1x the playtime. Players may never see 66% of the content. Writing quality must be consistent across all paths.
**Used by**: The Witcher 2 (Iorveth/Roche paths), Undertale (Pacifist/Neutral/Genocide), Detroit: Become Human (character-specific paths).

### Bottleneck Structure

Paths diverge and then reconverge at key plot points (bottlenecks). Between bottlenecks, the player has freedom. At bottlenecks, all paths arrive at the same narrative beat, but the player's state (relationships, resources, knowledge) colors how that beat plays out.

```
Start ──┬── A ──┬── Bottleneck 1 ──┬── D ──┬── Bottleneck 2 ──── Ending
        └── B ──┘                  └── E ──┘
        └── C ──┘                  └── F ──┘
```

**Strengths**: Controllable scope. Writers can ensure key story beats happen for all players. Player choices still matter because state carries through bottlenecks.
**Weaknesses**: Players may feel their choices are "funneled" if bottlenecks are too frequent or too similar regardless of path.
**Used by**: The Walking Dead (Telltale), Life is Strange, Pentiment (act structure with bottleneck endings).

### Garden of Forking Paths

True exponential branching. Every choice creates a permanent fork. No convergence. The tree grows wider at every decision point.

```
              ┌── A1a
         ┌── A1 ┤
    ┌── A ┤     └── A1b
    │     └── A2
Start ┤
    │     ┌── B1
    └── B ┤
          └── B2 ──┬── B2a
                   └── B2b
```

**Strengths**: Maximum player agency. Every choice has permanent, visible consequences. Feels genuinely responsive.
**Weaknesses**: Exponential content cost. A game with 10 binary choices needs 1,024 unique endings. Practically impossible at scale without procedural text generation.
**Used by**: Bandersnatch (limited scope), 80 Days (uses procedural generation to manage scope), most choose-your-own-adventure books (short form).

---

## 2. Dialogue System Patterns

### Node-Based Dialogue

Dialogue is a graph of nodes. Each node contains text and links to other nodes. The player selects responses from a list, advancing to the linked node.

```
NPC: "The bridge is out. You'll need another way across."
  ├── [Persuade] "Surely there's something we can arrange."  → Node_Persuade
  ├── [Investigate] "When did the bridge collapse?"           → Node_Investigate
  └── [Leave] "I'll find another way."                       → Node_Leave
```

**Tools**: Yarn Spinner, Ink, Twine, Dialogue System for Unity, custom implementations.
**Strengths**: Visual authoring in tools like Yarn. Easy to test and debug. Clear structure.
**Weaknesses**: Can feel mechanical. "Choose the blue option" rather than "have a conversation."
**Used by**: Most RPGs (Baldur's Gate 3, Divinity: Original Sin 2), visual novels (Ren'Py-based games).

### Ink/Yarn Integration

Ink (Inkle Studios) and Yarn (Yarn Spinner) are scripting languages designed for branching narrative. They separate story logic from presentation, allowing writers to author in a text-based format while the engine handles rendering.

**Ink** features:
- Knots (sections), stitches (subsections), diverts (jumps)
- Conditional text based on variables
- Gather points for reconverging branches
- Tunnels for reusable story segments

**Yarn** features:
- Node-based structure with Markdown-like syntax
- Commands for triggering game events
- Variables and conditional logic
- Localization support built in

**Design rule**: If your game has more than 50 dialogue nodes, use a dedicated narrative scripting language. Managing branching dialogue in a general-purpose scripting language becomes unmaintainable fast.

### State-Machine Dialogue

Dialogue is driven by the game's state machine rather than a static graph. NPC dialogue changes based on the current world state, quest progress, relationship values, and player history.

```
if relationship > 70 AND quest_bridge == "complete":
    "You fixed the bridge! I knew I could count on you."
elif relationship > 70:
    "I trust you. The bridge... it's been weighing on me."
elif quest_bridge == "complete":
    "The bridge is fixed. I suppose I owe you thanks."
else:
    "The bridge is out. You'll need another way across."
```

**Strengths**: Dialogue feels responsive to the world. Characters seem aware of what's happening. Reduces the "NPC repeats the same line" problem.
**Weaknesses**: Combinatorial explosion of states. Hard to test all permutations. Writers need to think systematically, not just narratively.
**Used by**: Disco Elysium (skill-based state checks), Citizen Sleeper (dice + state), Hades (relationship + run state), Pentiment (historical state tracking).

---

## 3. Choice Design

### Meaningful Choices

A choice is meaningful when the player can anticipate (at least partially) the consequences, the consequences are different enough to matter, and the choice reflects the player's values or strategy.

**Three types of meaningful choice:**

1. **Moral dilemmas**: No objectively "right" answer. Both options have costs. Undertale's mercy-or-kill mechanic. The Witcher 3's quest resolutions.
2. **Strategic tradeoffs**: Both options are beneficial, but in different ways. Slay the Spire's card draft. Disco Elysium's skill point allocation.
3. **Identity choices**: The choice defines who the player character is. Pentiment's background selection. Mass Effect's Paragon/Renegade responses.

**Design rule (Telltale principle)**: A choice is meaningful if at least 30% of players choose each option. If 95% pick Option A, Option B is either poorly presented or obviously inferior.

### False Choices (Illusion of Choice)

The player selects from options, but all paths lead to the same outcome. Used sparingly, this can give the feeling of agency without the content cost of true branching.

**When false choice works:**
- The player feels heard even if the outcome is the same. "I chose to be kind, and the NPC acknowledged it, even though the quest resolved the same way."
- Flavor text changes even if plot doesn't. Different descriptions, different emotional tone.

**When false choice fails:**
- The player discovers the illusion. "Wait, this dialogue is the same regardless of what I picked." Trust collapses.
- Overuse. If most choices are false, the entire choice system feels performative.

**Design rule**: Never have more than 2 consecutive false choices. After 2 false choices, the next choice must have visible, meaningful consequences.

### Delayed Consequences

The player makes a choice and doesn't see the result until much later. This creates a sense that the world is complex and responsive, and it rewards attentive players.

**Implementation patterns:**
- **Flag and trigger**: Set a flag when the choice is made. Check the flag hours later when the consequence fires. Simple, reliable.
- **Accumulator**: Multiple small choices contribute to a threshold. When the threshold is crossed, a consequence triggers. Disco Elysium's Thought Cabinet.
- **Reputation decay**: Consequences fade over time unless reinforced. A single kind act is forgotten; consistent kindness changes the relationship.

**Used by**: The Witcher 3 (choices in Act 1 determine Act 3 allies), Disco Elysium (Thought Cabinet consequences emerge over hours), Pentiment (Act 1 accusations shape Act 2-3 relationships).

---

## 4. Consequence Modeling

### Immediate Feedback

The player sees the result of their choice within seconds or minutes. NPC reacts, world state changes visibly, new dialogue unlocks.

**Purpose**: Teaches the player that choices matter. Establishes the consequence contract early.
**Risk**: If all consequences are immediate, the world feels reactive but shallow.

### Delayed Reveals

The consequence of a choice manifests hours or even acts later. The player may not connect cause and effect immediately.

**Purpose**: Creates the "oh no, that was because of what I did in Chapter 2" moment. Deepens the sense of a living world.
**Risk**: If the player can't trace cause to effect (even retrospectively), the consequence feels random, not meaningful.
**Design rule**: When a delayed consequence fires, give the player enough context to trace it back. "Remember when you told the merchant about the bridge? Well..." Disco Elysium does this by naming the originating Thought.

### Butterfly Effects

Small, seemingly insignificant choices cascade into large consequences. Named after chaos theory -- a butterfly flaps its wings in Brazil and causes a tornado in Texas.

**Implementation**: Chain multiple flag-and-trigger pairs. Choice A sets Flag 1. Flag 1 modifies the options available in Choice B. Choice B sets Flag 2. Flag 2 determines whether Character X survives in Chapter 5.

**Used by**: Until Dawn (every interaction affects survival), Detroit: Become Human (hundreds of state variables tracked), The Witcher 3 (seemingly minor dialogue choices affect ending).

**Design rule**: Butterfly effects are expensive to author and test. Use sparingly -- 2-3 per game -- and make them spectacular when they fire. They are the moments players share on social media.

### State Variable Tracking

Every narrative game with branching needs a state tracking system. The complexity of your state determines the complexity of your consequences.

| Complexity Level | State Variables | Example |
|-----------------|-----------------|---------|
| Simple | 5-10 binary flags | Visual novels with 2-3 endings |
| Moderate | 20-50 flags + 5-10 integers | Telltale-style episodic games |
| Complex | 100+ flags + relationship integers + inventory | Disco Elysium, Baldur's Gate 3 |
| Extreme | 500+ variables, procedural state | Dwarf Fortress, Crusader Kings 3 |

**Design rule**: Start with the simplest state model that supports your story. Every variable you add is a variable you must test in combination with every other variable. 50 binary flags means 2^50 possible states (over 1 quadrillion).

---

## 5. Environmental Storytelling

### Found Objects

Items, notes, recordings, and artifacts that the player discovers in the environment. They tell stories without dialogue or cutscenes.

**Patterns:**
- **Audio logs**: Bioshock, Gone Home, Tacoma. Player-paced consumption. Risk: "walking audio log simulator."
- **Written documents**: Disco Elysium's world-building books, Outer Wilds' Nomai writings. Reward careful readers.
- **Environmental arrangement**: A table set for two, one chair overturned. Dark Souls' item placements telling stories of past adventurers.
- **Photographs/paintings**: What Remains of Edith Finch, Pentiment. Visual storytelling that rewards observation.

### Environmental Details

The environment itself communicates narrative without discrete "found objects."

- **Wear patterns**: A path worn into grass shows where people walk. Scuff marks on a floor show where furniture was dragged.
- **Architecture**: Building style tells you about the culture. A fortified town tells a different story than an open village.
- **Decay and growth**: Rust, moss, cracks, and new growth communicate time passing and neglect vs care.
- **Contrast**: A child's drawing in a destroyed building. A flower growing through concrete. Contrast creates emotional impact.

**Used by**: Dark Souls (every item placement is narrative), Outer Wilds (the entire game is environmental storytelling), What Remains of Edith Finch (each room tells a life story), Pentiment (Tassing's architecture reflects centuries of history).

### Unreliable Narrators

The narrator or viewpoint character is not trustworthy. The player must piece together the truth from contradictory information.

**Implementation patterns:**
- **Contradictory sources**: Two characters tell different versions of the same event. The player decides who to believe.
- **Narrator correction**: The narrator says one thing, but the environment shows another. Stanley Parable. What Remains of Edith Finch.
- **Memory distortion**: The viewpoint character's memories are unreliable. Events change when revisited. Pentiment's accusation system.

### Show-Don't-Tell

The most powerful narrative pattern in games. Instead of telling the player what happened, show them through gameplay, environment, or character behavior.

- **TELL**: "The war devastated this region." (text on screen)
- **SHOW**: The player walks through a destroyed village. NPCs flinch at loud noises. Children play with sticks as swords. No one explains -- the player reads the environment.

**Design rule**: For every major narrative beat, ask "Can I show this instead of telling it?" If the answer is yes, showing is almost always more impactful.

---

## 6. Character Development Patterns

### Character Arcs

A character arc is the transformation a character undergoes over the course of the story. In games, arcs can be authored (predetermined) or player-driven (shaped by choices).

| Arc Type | Description | Example |
|----------|-------------|---------|
| **Positive change** | Character overcomes a flaw | Hades' Zagreus learns about his family |
| **Negative change** | Character succumbs to a flaw | Spec Ops: The Line's Walker |
| **Flat arc** | Character doesn't change; they change the world | Outer Wilds' protagonist |
| **Player-driven** | Player choices determine the arc direction | Disco Elysium's Harry |

### Relationship Systems

Tracking and evolving relationships between the player character and NPCs. Relationships are the emotional backbone of narrative games.

**Models:**
- **Binary**: Friend or foe. Simple, clear consequences. The Walking Dead.
- **Spectrum**: -100 to +100 relationship value. Gradual change, threshold-based events. Mass Effect, Hades.
- **Multi-axis**: Multiple relationship dimensions (trust, respect, romance, rivalry). Baldur's Gate 3, Fire Emblem.
- **State-based**: Relationship is a state machine with transitions triggered by events. Pentiment (defined by key accusations and interactions).

### Loyalty Mechanics

Characters who must be earned through consistent behavior, not a single choice.

**Implementation**: Track a "loyalty" value that increases with alignment-consistent actions and decreases with betrayals. At thresholds, unlock new dialogue, quests, or story branches.

**Design rule (Mass Effect principle)**: Loyalty should never be binary. A character at 60% loyalty should behave differently than one at 90%. Smooth gradients feel more human than sharp thresholds.

---

## 7. Pacing

### Tension Curves

Narrative pacing follows a tension curve -- the emotional intensity of the story over time.

```
Tension
  |         ╱╲
  |        ╱  ╲     ╱╲
  |   ╱╲  ╱    ╲   ╱  ╲     ╱╲╱╲  ← Climax
  |  ╱  ╲╱      ╲ ╱    ╲   ╱
  | ╱              ╲     ╲ ╱
  |╱                      ╱        ← Resolution
  +────────────────────────────────→ Time
   Act 1    Act 2a   Act 2b   Act 3
```

### Quiet Moments

Games need breathing room between intense sequences. Quiet moments serve multiple purposes:

- **Emotional processing**: The player absorbs what just happened. Hades' conversations between runs.
- **World-building**: Low-stakes exploration reveals details. Pentiment's daily life in Tassing.
- **Relationship development**: Characters talk when not under pressure. Mass Effect's Normandy conversations.
- **Player agency**: The player chooses what to engage with. Open exploration between story beats.

**Design rule (Hades principle)**: After every high-tension sequence, provide a safe space where the player controls the pace. No timers, no threats, no urgency. Let them breathe.

### Climax Structure

The climax is the highest point of tension where the story's central question is answered.

**Game-specific climax patterns:**
- **Boss fight as narrative climax**: The final boss IS the story's antagonist. Defeating them resolves the narrative. Hades, Undertale.
- **Choice as climax**: The final decision carries the weight of everything that came before. Mass Effect 3, Pentiment.
- **Revelation as climax**: The player discovers the truth. Outer Wilds, Return of the Obra Dinn.
- **Performance as climax**: The player must execute at peak skill, and the narrative rides on the result. Celeste (climb the mountain = confront anxiety).

### Episodic vs Continuous Narrative

| Structure | Description | Strengths | Weaknesses |
|-----------|-------------|-----------|------------|
| **Episodic** | Self-contained chapters/episodes with their own arcs | Each session feels complete; easier to stop and resume | Can feel disconnected; overarching plot may feel thin |
| **Continuous** | One unbroken narrative thread from start to finish | Deep immersion; strong narrative momentum | Hard to stop mid-session; losing progress feels worse |
| **Hybrid** | Episodes within an overarching narrative | Best of both; session satisfaction + long-term investment | Harder to write; must balance episode arcs and series arc |

**Used by**: Episodic (Pentiment's three acts), Continuous (Outer Wilds), Hybrid (Hades' run-based episodes within ongoing story).

---

## 8. Anti-Patterns

### Choice Paralysis

**Problem**: Too many choices, most of them meaningless, overwhelm the player.
**Symptom**: Players spend more time in dialogue menus than engaging with the story. Decision fatigue sets in.
**Fix**: Limit choices to 2-4 options per decision point. Every option must be meaningfully different. Cut options that lead to the same outcome.
**Example of the problem**: Dialogue trees with 8+ options where 5 of them are "ask about lore" variations.
**Example of the fix**: Disco Elysium limits most choices to 2-4 options, each tied to a specific skill. The skill itself is the character you're playing.

### Invisible Consequences

**Problem**: The player makes choices but can't trace cause to effect. Consequences happen, but the player doesn't know their choice caused them.
**Symptom**: "I don't think my choices matter" even when they do.
**Fix**: When a delayed consequence fires, provide a breadcrumb back to the cause. UI indicator, dialogue reference, or journal entry.
**Example of the problem**: A character dies in Chapter 5 because of a Chapter 1 choice, but nothing links the two events.
**Example of the fix**: The Witcher 3 often has NPCs explicitly reference your past decisions when consequences land. "You told me to trust the sorceress. Look where that got us."

### Exposition Dumps

**Problem**: Long passages of text or dialogue that explain the world, lore, or backstory without player interaction.
**Symptom**: Players skip dialogue. Eyes glaze over. Ctrl+click through text.
**Fix**: Break exposition into discoverable fragments. Distribute across environmental storytelling, optional dialogue, and found objects. Let curious players assemble the full picture while casual players get the gist.
**Example of the problem**: A 10-minute cutscene explaining the world's history before the game starts.
**Example of the fix**: Outer Wilds distributes its entire lore across a solar system. You learn by exploring, not by reading a codex.

### The Dialogue Menu Problem

**Problem**: Players treat dialogue as a menu to exhaust rather than a conversation to have. They click every option systematically.
**Symptom**: Dialogue feels like a checklist, not an interaction.
**Fix**: Make some dialogue options mutually exclusive. Disco Elysium does this with skill checks -- you only get the Rhetoric option if your Rhetoric is high enough. Pentiment does this with background choices -- your education determines which dialogue options are available.

### Consequence Whiplash

**Problem**: A minor choice has massive, disproportionate consequences. The player feels the game is unfair.
**Symptom**: "I just chose to be polite and now an entire city is destroyed?"
**Fix**: Match consequence magnitude to choice magnitude. Small choices should have small consequences. Signal when a choice is important through framing, music, camera work, or explicit warnings.

---

## 9. Reference Games

### Disco Elysium (ZA/UM, 2019)
**Why it matters**: Revolutionized dialogue by making skills into characters. Your Electrochemistry skill argues with your Logic skill. Dialogue IS gameplay.
**Key patterns**: Skill-based state-machine dialogue, Thought Cabinet as delayed consequences, environmental storytelling through item examination, internal monologue as character development.
**MDA**: Narrative (detective story) + Expression (skill build = personality) + Discovery (world-building through dialogue).

### Hades (Supergiant Games, 2020)
**Why it matters**: Proved that roguelike structure can deliver deep, linear narrative. Every death advances the story. No wasted runs.
**Key patterns**: Hub-and-spoke with run-based spokes, relationship systems across runs, narrative-justified permadeath, exhaustive dialogue pool (no repeated lines for 80+ runs).
**MDA**: Narrative (family drama) + Challenge (combat roguelike) + Expression (relationship choices).

### Outer Wilds (Mobius Digital, 2019)
**Why it matters**: Pure environmental storytelling. No dialogue trees, no choice mechanics, no branching. Just a solar system full of mysteries and a player who learns.
**Key patterns**: Knowledge as progression, environmental storytelling at every scale (macro: planets, micro: individual notes), time loop as narrative structure, show-don't-tell as core philosophy.
**MDA**: Discovery (exploration and deduction) + Narrative (piecing together history) + Challenge (puzzle-solving).

### Undertale (Toby Fox, 2015)
**Why it matters**: Made the choice to fight or spare enemies into the game's central mechanical and narrative question. Meta-narrative about player behavior in games.
**Key patterns**: Parallel paths (Pacifist/Neutral/Genocide), meta-narrative awareness, mechanical consequences (spare = harder combat but better story), permanent consequences across save files.
**MDA**: Narrative (meta-commentary on violence in games) + Challenge (bullet-hell combat) + Expression (moral identity through gameplay).

### Pentiment (Obsidian Entertainment, 2022)
**Why it matters**: Historical narrative game that uses background and education choices to gate dialogue options. Your character's identity shapes what conversations are possible.
**Key patterns**: Bottleneck structure (three acts with convergence), background-gated dialogue, accusation system with permanent consequences, historical research as game mechanic.
**MDA**: Narrative (historical mystery) + Discovery (historical world-building) + Expression (character identity through background).

### Citizen Sleeper (Jump Over the Age, 2022)
**Why it matters**: Narrative dice game that makes resource scarcity a narrative mechanic. Every day you choose where to spend limited dice, and that choice shapes your story.
**Key patterns**: Dice allocation as narrative choice, clock-based consequence timers, relationship unlocks through consistent investment, multiple endings based on relationship priorities.
**MDA**: Narrative (survival story) + Challenge (resource management) + Expression (priority choices reveal character).

---

## 10. MDA Analysis for Narrative Games

Using the MDA Framework from `@docs/game-design-theory.md`:

### Primary Aesthetics

1. **Narrative**: The core aesthetic. Players engage with narrative games to experience a story, whether authored, emergent, or co-created.
2. **Fantasy**: Players inhabit a role, explore a world, and experience situations impossible in real life.
3. **Expression**: Players express identity through choices -- moral alignment, relationship priorities, dialogue tone.

### Secondary Aesthetics

4. **Discovery**: Uncovering hidden story elements, lore fragments, secret paths, and environmental details.
5. **Challenge**: Puzzle-solving, dialogue skill checks, resource management in service of narrative goals.
6. **Sensation**: Atmosphere, music, visual storytelling, voice acting -- the sensory experience of the narrative.

### Dynamics That Produce These Aesthetics

| Dynamic | Produces | Mechanics That Drive It |
|---------|----------|------------------------|
| Choice and consequence | Narrative + Expression | Branching dialogue, state tracking, delayed consequences |
| World exploration | Discovery + Fantasy | Environmental storytelling, found objects, optional areas |
| Character relationships | Narrative + Expression | Relationship values, loyalty mechanics, dialogue state |
| Role embodiment | Fantasy + Expression | Background selection, skill-gated dialogue, character identity |
| Atmosphere building | Sensation + Narrative | Music, art direction, environmental detail, pacing |

---

*This document is reference material for AlterLab GameForge skills. It enriches `game-narrative-director`, `game-designer`, and `game-brainstorm` with narrative-specific domain knowledge. See `@genre-packs/narrative/balance-template.md` for pacing metrics and `@genre-packs/narrative/brainstorm-variant.md` for ideation prompts.*
