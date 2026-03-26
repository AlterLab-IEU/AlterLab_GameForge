---
name: narrative-balance-template
genre: narrative
version: "2.0"
description: Pacing metrics, branch complexity budgets, and consequence mapping for narrative-driven games
---

# Narrative Balance Template

Reference material for `game-balance-check`, `game-narrative-director`, and `game-designer`. Use this template to plan, track, and tune the structural parameters of a narrative-driven game.

---

## 1. Story Pacing Metrics

### Scenes Per Act

A "scene" is a discrete narrative unit: a conversation, an exploration segment, a set-piece, or a puzzle. Scenes are the atoms of pacing.

| Act | Scenes (Short Game) | Scenes (Medium Game) | Scenes (Long Game) | Purpose |
|-----|--------------------|--------------------|-------------------|---------|
| Act 1 (Setup) | 5-8 | 10-15 | 20-30 | Establish world, characters, central question |
| Act 2a (Rising) | 8-12 | 15-25 | 30-50 | Complicate, deepen, introduce subplots |
| Act 2b (Escalation) | 6-10 | 12-20 | 25-40 | Raise stakes, force difficult choices |
| Act 3 (Resolution) | 4-6 | 8-12 | 15-25 | Climax, consequences, denouement |
| **Total** | **23-36** | **45-72** | **90-145** | |

**Reference**: Pentiment has ~60 scenes across 3 acts (25 hours). Disco Elysium has ~120 scenes (30 hours). Firewatch has ~25 scenes (4 hours).

### Dialogue Lines Per Scene

| Scene Type | Lines (Minimum) | Lines (Typical) | Lines (Maximum) | Notes |
|------------|-----------------|-----------------|-----------------|-------|
| Quick exchange | 3-5 | 8-12 | 15 | Information delivery, brief check-in |
| Standard conversation | 10-15 | 20-35 | 50 | Character development, plot advancement |
| Major dialogue scene | 30-50 | 60-100 | 150+ | Confrontation, revelation, climax dialogue |
| Environmental narration | 5-10 | 10-20 | 30 | Internal monologue, description, observation |
| Branching hub | 15-25 per branch | 30-50 per branch | 80+ per branch | Multiple paths through conversation |

**Design rule (Disco Elysium principle)**: If a dialogue scene exceeds 100 lines, break it into segments with environmental interaction, movement, or player-initiated continuation. Walls of text are exposition dumps in disguise.

### Choice Frequency

How often the player makes a meaningful choice determines the feel of agency.

| Pacing Style | Choices Per Hour | Example |
|-------------|-----------------|---------|
| Contemplative | 2-4 | Outer Wilds (exploration choices, not dialogue) |
| Moderate | 5-10 | Pentiment, Life is Strange |
| Conversational | 10-20 | Disco Elysium, Citizen Sleeper |
| Rapid-fire | 20+ | Visual novels with frequent branching |

**Design rule**: Choice frequency should match your game's rhythm. Action-narrative hybrids (Hades) space choices between gameplay. Pure narrative games (Disco Elysium) make dialogue itself the gameplay, so choices are frequent.

---

## 2. Branch Complexity Budget

### Maximum Active Branches

Active branches are storylines that are currently diverged and have not yet converged. More active branches = more state to track = more content to author.

| Complexity Tier | Max Active Branches | State Variables | Content Multiplier | Example |
|----------------|--------------------|-----------------|--------------------|---------|
| Linear+ | 1 (with flavor variations) | 5-10 | 1.1-1.2x | Firewatch, Gone Home |
| Light Branching | 2-3 | 15-30 | 1.3-1.5x | Life is Strange, Telltale games |
| Moderate Branching | 3-5 | 30-60 | 1.5-2.0x | Pentiment, The Witcher 3 |
| Heavy Branching | 5-8 | 60-120 | 2.0-3.0x | Disco Elysium, Baldur's Gate 3 |
| Extreme Branching | 8+ | 120+ | 3.0x+ | Detroit: Become Human |

**Content multiplier** is the ratio of total authored content to content any single player sees. A 2.0x multiplier means you write twice as much as any one player experiences.

### Convergence Points

Convergence points (bottlenecks) are where divergent branches rejoin. They are essential for managing scope.

| Metric | Conservative | Moderate | Ambitious |
|--------|-------------|----------|-----------|
| Convergence frequency | Every 3-5 scenes | Every 8-12 scenes | Every 15-20 scenes |
| State carried through convergence | 2-3 flags | 5-8 flags + 1-2 integers | 10+ flags + relationship values |
| Unique convergence dialogue | 2-3 variants | 4-6 variants | 8+ variants |

**Design rule**: Every convergence point needs at least 2 unique dialogue variants that acknowledge the player's path. Identical convergence dialogue breaks the illusion of agency.

### State Variable Budget

Plan your state complexity before writing begins. Every variable is a testing obligation.

```
TOTAL STATE VARIABLES = Flags + Integers + Enums

Testing burden:
  - 10 binary flags = 1,024 possible states (manageable with automation)
  - 20 binary flags = 1,048,576 states (need state compression / independence assumptions)
  - 30 binary flags = 1,073,741,824 states (untestable without strong independence guarantees)

Mitigation:
  - Group flags into independent clusters (relationship flags don't interact with quest flags)
  - Use enums instead of multiple flags (quest_state: enum of 5 values vs 5 separate flags)
  - Track only what matters for future decisions (retroactive state is free; predictive state is expensive)
```

---

## 3. Choice Consequence Mapping

### Consequence Type Matrix

For each major choice in the game, classify its consequences:

| Choice ID | Description | Immediate Consequence | Delayed Consequence | Permanent Consequence |
|-----------|-------------|----------------------|--------------------|-----------------------|
| C001 | Trust the merchant | Merchant gives information | Merchant appears in Act 2 as ally | Merchant's faction supports you in finale |
| C002 | Accuse the priest | Priest is imprisoned | Priest's followers become hostile | Town's religious structure changes |
| C003 | Share the secret | Ally gains trust (+15) | Ally uses secret in Chapter 4 | Secret becomes public knowledge |

### Consequence Weight Guidelines

| Consequence Type | Response Time | Player Visibility | Content Cost |
|-----------------|---------------|-------------------|--------------|
| **Immediate** | 0-30 seconds | High (NPC reacts, world changes) | Low (dialogue variant) |
| **Short-delay** | 5-30 minutes | Medium (next scene reference) | Low-Medium |
| **Long-delay** | 1-5 hours | Low-Medium (callback required) | Medium |
| **Permanent** | End of game | High (ending affected) | High (unique content) |

### Consequence Density Targets

| Game Length | Immediate per hour | Delayed per act | Permanent total |
|------------|-------------------|-----------------|-----------------|
| Short (3-5h) | 4-6 | 3-5 | 2-3 |
| Medium (10-20h) | 3-5 | 5-8 | 4-6 |
| Long (30+h) | 2-4 | 8-12 | 6-10 |

**Design rule (Witcher 3 principle)**: Front-load immediate consequences to train the player that choices matter. Then introduce delayed consequences once the player is paying attention.

---

## 4. Playthrough Length Targets

### Path Length Analysis

| Path Type | Definition | Target Length | Notes |
|-----------|-----------|---------------|-------|
| **Critical path** | Minimum choices, skip optional content | 60-70% of average | The "speedrun" path; should still feel complete |
| **Average path** | Moderate exploration, some side content | Baseline (100%) | What most players experience |
| **Completionist path** | All side content, all conversations, all secrets | 130-180% of average | Should feel rewarding, not tedious |
| **Replay path** | Second playthrough making different choices | 50-70% of average | Skip known content, focus on divergent branches |

### Length Estimates by Genre

| Subgenre | Critical Path | Average Path | Completionist |
|----------|--------------|-------------|---------------|
| Visual novel (short) | 2-3 hours | 4-6 hours | 8-12 hours (all routes) |
| Walking sim | 1.5-2 hours | 3-4 hours | 5-6 hours |
| Narrative adventure | 4-6 hours | 8-12 hours | 15-20 hours |
| Narrative RPG | 15-20 hours | 30-50 hours | 60-100 hours |
| Interactive fiction (Twine) | 15-30 min | 45-90 min | 2-3 hours (all branches) |

### Word Count Estimates

| Metric | Short Game | Medium Game | Long Game |
|--------|-----------|-------------|-----------|
| Total words authored | 20,000-40,000 | 60,000-150,000 | 200,000-500,000+ |
| Words any player reads | 15,000-30,000 | 40,000-80,000 | 100,000-200,000 |
| Ratio (authored:read) | 1.3-1.5x | 1.5-2.0x | 2.0-3.0x |
| Words per hour (player) | 5,000-8,000 | 4,000-7,000 | 3,000-6,000 |

**Reference**: Disco Elysium contains ~1,000,000 words authored. A single playthrough reads ~200,000 (5:1 ratio). Pentiment contains ~300,000 words.

---

## 5. Voice Line Budget Estimation

If your game includes voice acting, budget early. Voice is typically the most expensive per-word content in a narrative game.

### Estimation Formula

```
total_voice_lines = total_dialogue_lines * voice_coverage_rate

Where voice_coverage_rate:
  - Full voice: 1.0 (every line voiced -- Baldur's Gate 3, expensive)
  - Partial voice: 0.3-0.5 (key scenes only -- Pentiment style)
  - Bark only: 0.05-0.1 (greetings and exclamations only -- many RPGs)
  - No voice: 0.0 (text only -- Disco Elysium base game)
```

### Cost Planning Table

| Voice Tier | Lines | Estimated Studio Hours | Notes |
|------------|-------|----------------------|-------|
| Protagonist | All player-character lines | 40-80 hours | Highest quality requirement |
| Major NPC (4-6 characters) | 200-500 lines each | 8-20 hours each | Distinct voice, emotional range |
| Minor NPC (10-20 characters) | 30-100 lines each | 2-5 hours each | Can share sessions |
| Ambient/Bark (20+ characters) | 5-20 lines each | 0.5-1 hour each | Brief, functional |

### Recording Planning

| Metric | Target |
|--------|--------|
| Lines recorded per studio hour | 30-50 (with retakes) |
| Average line length | 8-15 words |
| Pick-up sessions (re-records) | Budget 15-20% of original session time |
| Localization multiplier | Per language: 1.0x recording time, 1.2x for lip-sync languages |

**Design rule**: If voice budget is tight, voice the first and last lines of every scene and leave the middle as text. Players remember openings and closings. This is the Pentiment approach -- selective voice creates a rhythm.

---

## 6. Narrative Quality Metrics

Track these during development and playtesting to assess narrative health.

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Choice split ratio | No option chosen by >70% of testers | A/B tracking in playtest |
| Consequence recognition | >80% of testers can name at least one consequence of their choices | Post-playtest survey |
| Character memorability | >60% of testers can name 3+ characters unprompted | Post-playtest survey |
| Pacing satisfaction | <10% of testers report "boring" or "rushed" sections | Pacing survey per act |
| Ending satisfaction | >70% of testers rate their ending as "satisfying" even if "not happy" | Post-completion survey |
| Replayability intent | >40% of testers express desire to replay with different choices | Post-completion survey |

---

*This template provides structural parameters for narrative game development. Use alongside `@genre-packs/narrative/PATTERNS.md` for design pattern context and `game-balance-check` for automated pacing analysis. Extends `@templates/game-design-document.md` with narrative-specific metrics.*
