# Statistical Methods for Balance

Distribution choices, expected value, waiting times, win-rate confidence, matchup matrices and
sensitivity analysis. Thresholds marked "rule of thumb" are starting points to calibrate against
your own game, not industry standards.

## 1. Pick the distribution on purpose

| Distribution | Use for | Watch for |
|---|---|---|
| **Normal** (mean, sd) | Damage spread, stat variation, AI reaction jitter | Tails: sd too high produces outliers that read as bugs. Clamp. |
| **Uniform** | Picking among equal options, spawn positions | Streaks. Five identical drops in a row is plausible and feels rigged. |
| **Bernoulli / geometric** | "X% chance per try"; attempts until first success | Long waits (see section 3); this is where bad-luck protection lives. |
| **Exponential** | Time between random events (rare spawns, world events) | Long gaps make players think the event is broken. |
| **Weighted table** | Loot tables, rarity tiers | Weights drift as items are added; re-normalize and re-simulate each time. |

**Variance controls** (choose one and say so in the design doc):
- **Shuffle bag**: put N outcomes in a bag, draw without replacement, refill when empty. Guarantees
  frequency over each bag; removes streaks entirely.
- **Pseudo-random distribution (PRD)**: chance starts low and rises after each failure, resetting
  on success (the approach Warcraft III and Dota 2 use for many proc chances). Same average rate,
  far fewer streaks.
- **Hard pity**: guarantee after N failures. Simple, transparent, easy to communicate.
- **Soft pity**: weight increases after a threshold. Smoother, harder to explain.

## 2. Expected value

```
EV = sum over outcomes of (probability x value)

Upgrade gamble:
  Success     70%  +10 damage
  No change   25%    0
  Downgrade    5%   -5 damage
  EV = 0.70*10 + 0.25*0 + 0.05*(-5) = 6.75  -> always worth taking on paper

Felt EV with losses weighted about 2x (loss aversion):
  0.70*10 + 0.05*(-5*2) = 6.5  -> still positive, but the 5% downgrade is what players remember
```

Use EV to check that:
- no option has the highest EV in every context (a dominant strategy);
- riskier options pay more on average than safe ones, or risk is never worth taking;
- the safe option stays viable;
- buy/sell, craft/salvage and currency-exchange loops have no arbitrage (EV of a cycle must be
  negative or zero, or players will farm it forever).

## 3. Waiting times for "X% per try"

The number of tries until the first success is geometric. Averages hide the pain:

| Drop chance per try | Median tries | 1 in 20 players still waiting after | 1 in 100 still waiting after |
|---|---|---|---|
| 10% | 7 | 29 | 44 |
| 5% | 14 | 59 | 90 |
| 1% | 69 | 298 | 458 |

Formula: P(no success in n tries) = (1 - p)^n, so the tries for a given "still waiting" share q is
n = ln(q) / ln(1 - p).

Set bad-luck protection from these tails. Example: 1% per pull with a hard pity at 90 pulls gives
an expected cost of about 60 pulls, and about 41% of players reach the pity. If you want the pity
to be a rare safety net instead of the common path, the base rate or the threshold has to move.
Run the numbers before publishing them; players will.

## 4. Win rates need confidence intervals

A 55% win rate over 100 games is not evidence of imbalance. Use the Wilson score interval:

```ts
// tools/balance/stats.ts
export function wilson(wins: number, n: number, z = 1.96): [number, number] {
  if (n === 0) return [0, 1];
  const p = wins / n;
  const d = 1 + (z * z) / n;
  const center = (p + (z * z) / (2 * n)) / d;
  const margin = (z * Math.sqrt((p * (1 - p)) / n + (z * z) / (4 * n * n))) / d;
  return [center - margin, center + margin];
}
```

| Observed | 95% interval | Read |
|---|---|---|
| 55 of 100 | about 45-64% | Could easily be 50%. Gather more. |
| 550 of 1,000 | about 52-58% | Likely a real edge. |
| 5 of 8 playtests | about 31-86% | Tells you almost nothing. |

Games needed for a margin of about plus or minus 5 points near 50%: about 385. For plus or minus 2
points: about 2,400. Simulations make these sample sizes cheap; human playtests and early telemetry
rarely reach them, so treat small-sample win rates as leads.

## 5. Matchup matrices (competitive and asymmetric games)

```
WIN RATE, row vs column (500 simulated games per pairing, seats swapped)
           Ember   Tide    Stone   Gale
Ember      --      55%     40%     52%
Tide       45%     --      58%     43%
Stone      60%     42%     --      55%
Gale       48%     57%     45%     --
```

Rules of thumb:
- 45-55% per matchup: healthy counterplay.
- 40-60%: acceptable if the disadvantaged side has tools to outplay it.
- Outside 40-60%: the counter is too hard; nerf the advantage or give the weaker side an answer.
- One side above 52% against everyone: overpowered; nerf it directly (cleaner than buffing all others).
- One side below 48% against everyone: underpowered; buff it directly.

Check the matrix per bot policy and, once telemetry exists, per skill bracket. A matchup can be
even overall and lopsided at high skill.

## 6. Build win-rate analysis (PvE, roguelikes, RPGs)

```
Build       Win rate   Pick rate   Avg clear time   Runs
spear       61%        68%         34 min           412
fire-staff  44%        12%         41 min            73
daggers     52%        20%         29 min           121
```

Red flags (rules of thumb):
- One build above about 70% pick rate: overpowered or perceived as such; the meta is stale.
- A build below about 30% win rate: feels unplayable; buff or rework it.
- High win rate, low pick rate: a hidden gem; make it more discoverable before nerfing it.
- Low win rate, high pick rate: players love the fantasy; buff it to reward the choice.

Use the roguelike genre pack's synergy scoring and entropy tracking for deeper build analysis.

## 7. Sensitivity analysis

Before shipping a change, test how sensitive the system is to the parameter:

1. Identify the parameter (spear damage 25 -> 22).
2. Simulate at three magnitudes: conservative (-5%), proposed (-12%), aggressive (-20%).
3. For each, trace the dependency graph: TTK per enemy type, economy (repairs, replacement rate),
   time to mid-game and endgame, and likely perception (a -12% nerf on a weapon that already felt
   weak can feel like -30%).
4. If results swing sharply within a few percent of the proposed value, the system is brittle at
   that parameter; prefer a structural fix (compress the power range, add a counter) over fine
   number tuning.

A compressed power range (the best option only moderately ahead of the worst) makes systems less
sensitive: a nerf moves an option from "top" to "viable" instead of from "viable" to "useless."

## 8. Reading simulation output

- **Median vs mean**: a big gap means skew; report the median as "typical."
- **P5 / P95**: the unlucky and lucky experiences. A wide band means luck dominates skill.
- **Worst 1%**: what the unluckiest players live through; this is where safety nets go.
- **Top outliers**: choice combinations far above the median are exploits waiting to be found.
- **Per-policy differences**: if the random bot does nearly as well as the greedy bot, the
  decisions do not matter enough.
