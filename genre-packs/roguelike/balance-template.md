---
name: roguelike-balance-template
genre: roguelike
version: "2.0"
description: Balance parameters, tuning tables, and Monte Carlo guidance for roguelike and roguelite games
---

# Roguelike Balance Template

Reference material for `game-balance-check` and `game-designer`. Use this template to define, track, and tune the core numerical systems in a roguelike game.

---

## 1. Run Economy

### Currency Drops Per Room/Floor

Define the primary currency (gold, cells, orbs) and its drop rate per encounter type.

| Encounter Type | Currency Drop (Floor 1) | Scaling Per Floor | Notes |
|----------------|------------------------|-------------------|-------|
| Standard enemy | 5-10 | +3-5 per floor | Base income source |
| Elite enemy | 25-40 | +10-15 per floor | Risk/reward incentive |
| Boss | 80-120 | +30-50 per floor | Major payout |
| Breakable objects | 1-3 | +1 per floor | Exploration reward |
| Secret room | 15-25 | +5-10 per floor | Discovery reward |

**Design rule (Slay the Spire principle)**: A player who fights every standard encounter on a floor should earn enough currency to buy exactly ONE shop item at the next shop. Elites and bosses fund the second and third purchases.

### Shop Pricing Curves

| Item Type | Base Price | Price Scaling Per Floor | Notes |
|-----------|-----------|------------------------|-------|
| Common consumable | 20-30 | +5 per floor | Potions, single-use items |
| Uncommon item | 50-80 | +15 per floor | Build-supporting items |
| Rare item | 120-180 | +30 per floor | Build-defining items |
| Removal/reroll | 75 (fixed or escalating) | +25 per use | Deck/inventory thinning |

**Key ratio**: Shop prices should outpace currency income slightly. The player should never afford everything in a shop -- forced choice creates tension.

### Resource Scaling Formula

```
floor_currency_budget = base_budget * (1 + floor_number * scaling_rate)

Where:
  base_budget = total currency available on floor 1 (all rooms combined)
  scaling_rate = 0.15 - 0.25 (15-25% increase per floor)
```

Example (Slay the Spire-like):
- Floor 1: 80 gold total available
- Floor 2: 80 * 1.20 = 96 gold
- Floor 3: 80 * 1.40 = 112 gold

---

## 2. Damage Curves

### Player DPS vs Enemy HP

The core tension: player damage should grow faster than enemy HP within a floor (feeling of mastery) but enemy HP should spike at floor transitions (renewed challenge).

| Floor | Player Base DPS | Enemy Base HP | Ratio (DPS:HP) | Notes |
|-------|----------------|---------------|-----------------|-------|
| 1 | 10-15 | 20-30 | ~1:2 | 2 hits to kill basic enemy |
| 2 | 20-35 | 50-80 | ~1:2.5 | Synergies emerging |
| 3 | 40-70 | 100-160 | ~1:2.5 | Build defined |
| 4 | 70-120 | 180-280 | ~1:2.5 | Power spikes matter |
| Boss | N/A | 300-800+ | Varies | Multi-phase, pattern-based |

### Power Spike Management

Power spikes occur when the player acquires a build-defining item or synergy. A well-paced roguelike has 2-3 power spikes per run:

```
Power
  |                          ●  ← Power spike 3 (final build)
  |                     ●──●/
  |                ●──●/
  |           ●──●/          ← Power spike 2 (synergy found)
  |      ●──●/
  | ●──●/                   ← Power spike 1 (first key item)
  |/
  +──────────────────────────→ Run Progress
```

**Design rule (Dead Cells principle)**: The first power spike should occur within the first 20% of a run. If the player hasn't found a build-defining item by Floor 2, the run feels aimless.

### Enemy Damage Output

| Floor | Enemy Damage Per Hit | Hits to Kill Player | Notes |
|-------|---------------------|---------------------|-------|
| 1 | 5-8 | 12-15 hits | Forgiving, learning space |
| 2 | 10-15 | 8-10 hits | Mistakes punished |
| 3 | 18-25 | 5-7 hits | Tight execution required |
| 4 | 25-40 | 3-5 hits | Glass cannon territory |

**Design rule**: The player should never be one-shot by a standard enemy except as a clearly telegraphed, avoidable attack. One-shot deaths from normal encounters feel unfair regardless of player skill level.

---

## 3. Item Rarity Distribution

### Drop Rate Table

| Rarity | Drop Chance (Floor 1) | Drop Chance (Floor 3+) | Pity Timer | Notes |
|--------|----------------------|------------------------|------------|-------|
| Common | 60% | 45% | N/A | Baseline items |
| Uncommon | 28% | 35% | N/A | Build-supporting |
| Rare | 10% | 15% | After 8 non-rare drops | Build-defining |
| Legendary | 2% | 5% | After 15 non-legendary drops | Run-warping |

### Pity Systems

Pity systems prevent the worst-case RNG from ruining runs. Two common approaches:

**Escalating probability**: After each drop that isn't the target rarity, increase the probability of the target rarity by a fixed amount.

```
effective_rate = base_rate + (attempts_since_last * escalation_factor)

Example (Rare items):
  base_rate = 0.10
  escalation_factor = 0.02
  After 5 non-rare drops: effective_rate = 0.10 + (5 * 0.02) = 0.20
```

**Hard pity**: Guarantee the target rarity after N failed attempts. Reset counter on success.

```
Rare pity: guaranteed after 8 non-rare drops
Legendary pity: guaranteed after 15 non-legendary drops
```

**Design rule (Balatro principle)**: Pity timers should be invisible. The player should feel lucky when the pity triggers, not entitled. Never show the pity counter in the UI.

### Item Pool Management

| Metric | Target Range | Notes |
|--------|-------------|-------|
| Total items in pool | 80-200 | Fewer than 80 feels repetitive; more than 200 overwhelms |
| Items per rarity tier | 20-50 per tier | Roughly equal per tier, skewing toward common |
| Items unlocked per run | 1-3 new items | Keeps the pool expanding at a satisfying rate |
| "Trap" items (intentionally weak) | 0-5% | Controversial; some games use them for risk/reward, others avoid entirely |
| Synergy pairs | 15-30% of items | At least 1 in 5 items should have an explicit synergy partner |

---

## 4. Difficulty Scaling Per Floor

### Enemy Scaling Formula

```
enemy_hp = base_hp * (1 + floor * hp_scaling)
enemy_damage = base_damage * (1 + floor * damage_scaling)
enemy_count = base_count + floor * count_increment

Where:
  hp_scaling = 0.3 - 0.5 (30-50% HP increase per floor)
  damage_scaling = 0.2 - 0.4 (20-40% damage increase per floor)
  count_increment = 1-2 (additional enemies per floor)
```

### Room Composition Table

| Floor | Standard Rooms | Elite Rooms | Shop | Rest/Event | Total Rooms |
|-------|---------------|-------------|------|------------|-------------|
| 1 | 6-8 | 1 | 1 | 1-2 | 10-12 |
| 2 | 5-7 | 2 | 1 | 1-2 | 10-12 |
| 3 | 4-6 | 2-3 | 1 | 1-2 | 10-12 |
| Final | 2-3 | 1-2 | 0-1 | 0-1 | 4-6 + Boss |

### Difficulty Modifier Stacking (Ascension/Heat)

For post-game difficulty systems, stack modifiers additively up to a cap:

| Modifier Category | Examples | Max Stack |
|-------------------|----------|-----------|
| Enemy stats | +10% HP per level, +5% damage per level | 10 levels |
| Economy pressure | -10% gold per level, +15% shop prices per level | 5 levels |
| Punishment | Lose X on death, traps deal more damage | 5 levels |
| New content | New enemy types, new room types | Unlimited |

**Design rule (Hades principle)**: Let the player choose WHICH modifiers to activate. Agency over difficulty is more engaging than linear difficulty levels. Hades' Pact of Punishment lets you pick your suffering.

---

## 5. Synergy Scoring

### Evaluating Build Synergy Strength

Score each item in the current build on its standalone value and its synergy multiplier:

```
item_value = standalone_power + (synergy_count * synergy_multiplier)

build_strength = sum(item_values) * (1 + synergy_bonus_per_pair * total_synergy_pairs)
```

### Synergy Categories

| Category | Description | Example |
|----------|-------------|---------|
| **Additive** | Items that add to the same stat | Two "+damage" items |
| **Multiplicative** | Items that multiply each other's effect | "Double damage" + "Extra hit" |
| **Conditional** | Items that enable each other's condition | "On poison: +damage" + "Apply poison on hit" |
| **Transformative** | Items that fundamentally change how another works | "Convert all damage to fire" + "Fire damage heals you" |

**Design rule**: Multiplicative and transformative synergies create the memorable moments. Additive synergies are filler. Aim for at least 30% of your item pool to participate in multiplicative or transformative synergies.

### Entropy Tracking

Track the entropy (randomness) of each run to ensure build diversity:

```
build_entropy = -sum(p_i * log2(p_i)) for each item category

Where p_i = fraction of items in category i / total items acquired

High entropy (>3.0): Diverse build, many categories represented
Low entropy (<1.5): Focused build, dominated by one category
```

**Target**: Average build entropy across 1000 runs should be 2.0-3.0. Below 2.0 means one build dominates. Above 3.0 means builds lack identity.

---

## 6. Monte Carlo Simulation Setup

### Purpose

Run automated simulations of thousands of runs to validate balance before playtesting. Monte Carlo simulation catches statistical outliers that manual testing misses.

### Simulation Parameters

```
SIMULATION CONFIG:
  runs: 10,000
  floors_per_run: 4-5
  rooms_per_floor: 10-12
  player_skill: "average" (hits 60% of optimal DPS, avoids 70% of avoidable damage)

METRICS TO TRACK:
  - Win rate (target: 15-25% for average skill)
  - Average run length (minutes)
  - Distribution of causes of death (floor, enemy type, resource starvation)
  - Item pick rates (no item should be picked >80% or <5% of the time)
  - Synergy frequency (how often do synergy pairs co-occur)
  - Currency surplus/deficit per floor (should trend toward slight deficit)
  - Power spike timing (what % of run has passed when first rare+ item appears)
```

### Red Flags

| Metric | Red Flag | Likely Cause |
|--------|----------|--------------|
| Win rate >40% | Too easy | Enemy scaling too slow, items too powerful |
| Win rate <10% | Too hard | Enemy scaling too fast, items too weak, no pity system |
| One item picked >80% | Dominant item | Item is too strong or has no viable alternative |
| Deaths >50% on Floor 1 | Harsh opening | Starting stats too low, Floor 1 enemies too strong |
| Currency surplus growing each floor | Economy too generous | Drop rates too high, shop prices too low |
| Build entropy <1.5 across runs | One dominant build | Synergy system funnels toward one archetype |

### Simulation Pseudocode

```python
def simulate_run(config):
    player = Player(base_stats)
    inventory = []

    for floor in range(config.floors):
        rooms = generate_rooms(floor, config)
        for room in rooms:
            if room.type == "combat":
                result = simulate_combat(player, room.enemies, inventory)
                if result == "death":
                    return RunResult(floor=floor, cause=room.enemies, items=inventory)
                player.currency += result.drops
            elif room.type == "shop":
                purchase = ai_purchase(player, inventory, room.shop_items)
                inventory.append(purchase)
                player.currency -= purchase.price
            elif room.type == "item_room":
                item = roll_item(floor, config.drop_rates, pity_counter)
                inventory.append(item)

        # Boss fight
        boss_result = simulate_combat(player, floor_boss(floor), inventory)
        if boss_result == "death":
            return RunResult(floor=floor, cause="boss", items=inventory)

    return RunResult(floor="victory", items=inventory)
```

---

*This template extends `@templates/economy-model.md` with roguelike-specific parameters. Use alongside `@genre-packs/roguelike/PATTERNS.md` for design context and `game-balance-check` for automated analysis.*
