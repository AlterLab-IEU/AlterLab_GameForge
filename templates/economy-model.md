# Economy Model

> **Project:** [Working title]
> **Version:** [Document version]
> **Last Updated:** [Date]
> **Designer:** [Name / role]
> **Status:** [Draft / In Review / Approved]

---

## 1. Currencies

| Currency | Type | Earn Rate | Cap | Exchange Rate | Notes |
|----------|------|-----------|-----|--------------|-------|
| [Gold/Coins] | Primary (soft) | [X per hour of play] | [None / Cap value] | N/A (base currency) | [Used for: equipment, consumables, upgrades] |
| [Gems/Crystals] | Premium (hard) | [X per day from gameplay / purchasable] | [None / Cap value] | [1 Gem = Y Gold] | [Used for: cosmetics, time skips, premium items] |
| [Reputation/Tokens] | Faction | [X per quest/activity] | [Per-faction cap] | [Not exchangeable] | [Used for: faction rewards, unlocks] |
| [Crafting materials] | Resource | [Drop rate per enemy/node] | [Stack size limit] | [Not directly exchangeable] | [Used for: crafting, upgrading] |

### Currency Philosophy
[Describe the economic philosophy. Is it generous or tight? Do players always feel slightly short, or comfortably wealthy? Is there a meaningful choice between spending and saving?]

---

## 2. Faucets (Sources of Currency/Items)

### Primary Faucets

| Source | Currency | Rate | Scaling | Notes |
|--------|----------|------|---------|-------|
| Combat (enemies) | Gold | [X per kill, scaled by enemy tier] | [Linear with zone level] | [Random drop range: X-Y] |
| Quest completion | Gold | [X per quest, scaled by difficulty] | [Fixed per quest] | [One-time per quest] |
| Resource gathering | Materials | [X per node, RNG table] | [Node respawn timer: X min] | [Higher zones = rarer materials] |
| Daily login | Premium | [X per day, bonus at day 7/14/30] | [Fixed] | [Free-to-play floor for premium currency] |
| Achievement/milestone | Mixed | [One-time rewards] | [N/A] | [Signpost progression milestones] |
| Selling items | Gold | [Item value, typically 25-50% of buy price] | [Fixed per item] | [Prevents infinite money via buy/sell loops] |

### Faucet Rules
- **Sell price is always less than buy price** to prevent arbitrage.
- **Drop rates decrease as player level outpaces content level** to discourage farming old content.
- **No single faucet should provide more than [X%] of a player's income** at any stage.

---

## 3. Sinks (Drains on Currency/Items)

### Primary Sinks

| Sink | Currency | Cost Range | Purpose | Frequency |
|------|----------|-----------|---------|-----------|
| Equipment purchase | Gold | [Range by tier] | [Gear progression] | [Per upgrade cycle] |
| Consumables | Gold | [Range] | [Health pots, buffs, ammo] | [Per session, recurring] |
| Upgrades/enhancement | Gold + Materials | [Scaling cost per level] | [Power progression] | [Per item, multi-level] |
| Crafting | Materials | [Recipe-based] | [Create new items] | [As needed] |
| Repair/maintenance | Gold | [% of item value] | [Gold sink, prevents hoarding] | [After death / over time] |
| Fast travel / convenience | Gold or Premium | [Fixed fee] | [Time saving, not power] | [Per use] |
| Cosmetics | Premium | [Fixed prices] | [Monetization (if F2P)] | [One-time per item] |
| Respec/reset | Gold or Premium | [Increasing cost per use] | [Prevents free-infinite-experimentation] | [Occasional] |

### Sink Types

Distinguish between hard sinks and soft sinks when designing your drain systems:

| Type | Mechanism | Examples | Effect on Economy |
|------|-----------|---------|-------------------|
| **Hard Sink** (permanent removal) | Currency/items are destroyed | Consumables used, durability loss (item breaks), death penalties (gold lost), crafting material consumption, repair costs | Directly reduces money supply; essential for controlling inflation |
| **Soft Sink** (temporary restriction) | Currency/items are delayed or gated | Time gates (cooldowns before earning again), decay (unused items lose value over time), lockout timers, seasonal resets | Slows velocity of currency without permanent removal; controls flow rate |

**Design guideline:** A healthy economy needs both. Hard sinks control total supply (M), soft sinks control velocity (V). If you only have soft sinks, inflation is inevitable.

### Stock/Flow Definitions

Understanding the difference between stocks and flows is critical for economy monitoring:

- **Stocks** are quantities at a point in time: gold held, health points, items in inventory, reputation score.
- **Flows** are rates of change: income per second, damage per hit, gold spent per session, items acquired per hour.

**Monitoring guidance:**
- Track stocks over time per player cohort. Plot median and P90 values.
- Alert on exponential stock growth — it signals broken faucets or insufficient sinks.
- Monitor flow ratios (faucet rate / sink rate). Target a ratio of 1.0-1.2 for a slightly generous economy.

### Quantity Theory of Virtual Money

Apply the Quantity Theory of Money to predict and control inflation in your virtual economy:

**M × V = P × Q**

| Variable | Meaning | Game Example |
|----------|---------|-------------|
| **M** (Money Supply) | Total currency in circulation | Sum of all gold held by all players |
| **V** (Velocity) | How often each unit changes hands | Average gold transactions per unit per day |
| **P** (Price Level) | Average price of goods | Average cost of items in player-to-player trade |
| **Q** (Transaction Volume) | Number of transactions | Total trades per day |

**Practical use:** If M increases (faucets outpace sinks) and V stays constant, then P must rise (inflation). Use this to predict when prices will spiral and preemptively increase sinks or reduce faucets.

### Economy Simulation

Use [Machinations.io](https://machinations.io) to model and simulate your economy before implementation. Machinations provides visual stock-and-flow diagrams purpose-built for game economies. **Model before you build.** Simulate at least 100 hours of player-time before committing to production values.

### Sink Rules
- **Essential progression should never require premium currency.**
- **Repair/maintenance costs should be noticeable but never punishing** (target: 5-15% of session income).
- **Upgrade costs should escalate** so players feel the choice between breadth and depth.

---

## 4. Progression Unlocks

| Unlock | Cost | Currency | Prerequisites | Power Impact |
|--------|------|----------|--------------|-------------|
| [Weapon Tier 2] | [500 Gold] | Gold | [Level 5, complete tutorial] | [+20% DPS] |
| [Ability Slot 2] | [1000 Gold] | Gold | [Level 10] | [Significant — new build options] |
| [Crafting Station] | [2000 Gold + 50 Iron] | Gold + Materials | [Level 8, quest "The Smith"] | [Access to crafting system] |
| [Mount/Vehicle] | [5000 Gold] | Gold | [Level 15, quest "The Journey"] | [Travel speed, quality of life] |
| [Premium Skin Pack] | [500 Gems] | Premium | [None] | [Zero — cosmetic only] |

### Unlock Pacing
[Define the target pacing for major unlocks.]
- **New unlock every [X] minutes/hours** during the first [Y] hours.
- **Unlock frequency decreases** in mid-game as each unlock is more significant.
- **"Nothing new" maximum duration:** [No more than X hours without a meaningful unlock.]

---

## 5. Premium Economy (If Applicable)

### Monetization Model
- [ ] Free-to-Play with microtransactions
- [ ] Premium (buy-to-play) with optional cosmetic store
- [ ] Premium with expansion/DLC model
- [ ] Subscription
- [ ] None (no premium economy)

### Premium Currency Pricing

| Bundle | Amount | Price (USD) | Per-Unit Value | Bonus |
|--------|--------|-------------|----------------|-------|
| Starter | [100 Gems] | [$0.99] | [$0.0099/Gem] | [None — baseline] |
| Standard | [550 Gems] | [$4.99] | [$0.0091/Gem] | [+10%] |
| Premium | [1200 Gems] | [$9.99] | [$0.0083/Gem] | [+20%] |
| Mega | [6500 Gems] | [$49.99] | [$0.0077/Gem] | [+30%] |

### Ethical Guidelines
- [ ] No pay-to-win: premium currency never buys power advantages
- [ ] No predatory mechanics: no loot boxes with premium currency
- [ ] No artificial friction: free players are never intentionally frustrated to drive spending
- [ ] Clear value: players always know exactly what they are buying
- [ ] Refund policy: [Define refund conditions]

### Ethical Monetization

**PEGI Rating Implications (June 2026):**
- Loot boxes with randomized paid content trigger PEGI 16 minimum rating
- NFT or blockchain-based item ownership triggers PEGI 18 rating
- Assess rating impact early — a higher rating narrows your audience

**Virtual Currency Transparency:**
- Always show the real-money equivalent alongside virtual currency prices
- Example: "500 Gems ($4.99)" not just "500 Gems"
- Never obscure the conversion rate through intermediate currencies

**Battle Pass Ethics:**
- Reward effort and time invested, not spending
- Free track must feel rewarding, not punishing
- No FOMO pressure: avoid "miss it forever" language and expiring rewards
- Allow catch-up mechanics for players who miss days

**Dark Pattern Avoidance Checklist:**
- [ ] No forced waits designed to encourage spending
- [ ] No artificial scarcity (fake "limited time" offers that recur)
- [ ] No hidden odds on randomized purchases
- [ ] No pay-to-win advantages
- [ ] No predatory pricing tiers that manipulate anchoring bias

---

## 6. Balance Targets

### Time-to-X Milestones

| Milestone | Target Time | Currency Needed | Notes |
|-----------|------------|----------------|-------|
| First equipment upgrade | [15 min] | [50 Gold] | [Teach the upgrade loop early] |
| First ability unlock | [30 min] | [200 Gold] | [Reward early engagement] |
| Full basic loadout | [2 hours] | [1000 Gold] | [Player should feel "ready" for mid-game] |
| First premium-tier item visible | [1 hour] | [N/A — aspiration] | [Show what they're working toward] |
| Mid-game gear plateau | [8 hours] | [5000 Gold] | [Natural pause before late-game push] |
| End-game entry | [20 hours] | [15000 Gold] | [Meaningful investment, not exhausting] |
| Full end-game gear | [50+ hours] | [50000+ Gold] | [Long-tail for dedicated players] |

### Income Curve
[Describe how earning rate changes over the player's lifetime.]
- **Early game (0-2 hrs):** [Generous, fast rewards to hook engagement]
- **Mid game (2-10 hrs):** [Steady, proportional to time invested]
- **Late game (10+ hrs):** [Slightly increasing returns for mastery, diminishing for grinding]

---

## 7. Health Metrics

### Inflation Indicators

| Metric | Healthy Range | Warning | Action |
|--------|-------------|---------|--------|
| Gold held (median player) | [500-2000 at level 10] | [>5000 = sinks too weak] | [Add gold sinks or reduce faucets] |
| Time between meaningful purchases | [15-60 min] | [>90 min = costs too high] | [Reduce prices or increase income] |
| Premium currency conversion rate | [<5% of players buying] | [<1% = too expensive, >20% = too necessary] | [Adjust pricing/value] |
| Item vendor sell ratio | [<30% of items sold to vendor] | [>50% = loot quality too low] | [Improve drop relevance] |

### Engagement Metrics

| Metric | Target | Measurement |
|--------|--------|------------|
| Session length (median) | [30-60 min] | [Time from login to logout] |
| Sessions per week | [3-5] | [Unique play sessions per 7 days] |
| Progression per session | [Visible improvement] | [At least 1 unlock, upgrade, or quest per session] |
| Currency spend rate | [60-80% of income spent] | [Players should spend, not hoard] |
| Drop satisfaction | [>70% of drops used or valued] | [Survey + sell-rate data] |

---

## Appendix: Formulas

[Reference formulas for the economy model.]

```
Gold per enemy = base_gold * (1 + 0.1 * enemy_level) * difficulty_mult
Item drop chance = base_chance * (1 + luck_stat * 0.01) * rarity_modifier
Upgrade cost = base_cost * (upgrade_level ^ 1.8)
Repair cost = item_value * 0.1 * damage_percentage
XP to level = floor(100 * level ^ 1.5)
```
