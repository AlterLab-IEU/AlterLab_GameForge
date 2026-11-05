# Balance, Rewards and Game Feel -- Working Reference

Load this when writing formulas, progression tables, reward schedules, game-feel specs or a
simulation plan. Numbers marked *rule of thumb* are practitioner starting points, not standards:
set project targets, then validate in simulation and playtest.

---

## 1. Combat balance

### Time-to-kill (TTK) targets (*rules of thumb*)
| Engagement | Starting target | Why |
|---|---|---|
| PvE common enemy | 2-5 s | Long enough to make one decision, short enough to stay snappy |
| PvE elite | 15-30 s | Room for two or three pattern reads |
| PvE boss | 2-5 min, phased | Each phase teaches then tests one pattern |
| PvP | Genre-dependent | Arena shooters short, MOBAs and fighters longer; derive from skill expression |

TTK too short removes decisions; too long creates tedium. Set TTK before you set HP or damage.

### Damage formulas
Throughput:
```
effective_dps = base_damage * attacks_per_s * (1 + crit_chance * (crit_mult - 1)) * (1 - mitigation)
```
Armor with diminishing returns (never reaches 100%):
```
mitigation = armor / (armor + armor_k)      # armor == armor_k gives 50% reduction
```
Flat subtraction (`damage - armor`) degenerates at high armor; if you use it, clamp with a
minimum damage floor and test the floor explicitly.

Checklist for any formula:
- Every variable is a named tuning constant with unit, default and range.
- Evaluate at the corners: level 1 with best gear, max level with starting gear, zero and max
  of every input.
- Check for division by zero, negative results and overflow in integer math.
- Write the inverse: given a target TTK, what HP does an enemy need at each level?

### Progression scaling table
Build this before implementation; regenerate it whenever a constant changes.
| Level | Player DPS | Enemy HP | TTK | Target TTK | Delta |
|---|---|---|---|---|---|
| 1 | | | | | |
| 10 | | | | | |
| 25 | | | | | |
| Max | | | | | |

---

## 2. Curve shapes

| Shape | Formula sketch | Use for | Risk |
|---|---|---|---|
| Linear | `a + b*x` | Tutorials, short games | Boring over long horizons |
| Exponential | `a * r^x` | Enemy scaling within a short run | Crushes players if runs are long |
| Logarithmic | `a + b*ln(1+x)` | Player power, diminishing stat returns | Late upgrades feel weak; pair with new verbs |
| S-curve | `L / (1 + e^(-k(x-x0)))` | Campaign pacing, learning curves | Plateau needs fresh content or systems |
| Polynomial | `a * x^p` | XP-to-level tables (p between 1.5 and 2.5 is common) | Tune p with time-to-level, not by eye |

Always tabulate time-to-milestone per player archetype (casual, average, dedicated), not just
the curve value. A curve is a schedule of hours, not a picture.

---

## 3. Difficulty

- **Static tiers** (Easy/Normal/Hard) are honest and predictable. Name them by experience
  ("Story", "Standard", "Brutal"), and describe what changes.
- **Dynamic difficulty adjustment** works when invisible: vary spawn counts, enemy aggression
  timers and drop rates, not visible stats. Never in competitive modes. Log every adjustment so
  playtests can see it.
- **Rubber-banding** in competitive games: the trailing player gets opportunities (shortcuts,
  catch-up routes), not handouts that ignore skill. Players read granted advantages as unfair.
- **Assist options** (slower game speed, damage reduction, invulnerability toggles) are
  accessibility features, not difficulty modes. Coordinate with `game-accessibility-specialist`.
- **Flow:** keep challenge slightly above current skill; spikes must be readable and
  recoverable. See the Flow section of `docs/game-design-theory.md` in the plugin.

---

## 4. Reward schedules

| Timescale | Typical reward | Frequency target (*rule of thumb*) |
|---|---|---|
| 30 s | Score ticks, combo counters, pickups | Continuous |
| 5 min | Loot, XP chunk, checkpoint | Each encounter |
| Session | Level-up, story reveal, new ability | Once or twice per session |
| Meta | Unlock tier, mastery badge, season reward | Weekly or per campaign act |

### Random rewards
- Variable schedules sustain engagement more than fixed ones (Ferster and Skinner, *Schedules of
  Reinforcement*, 1957). That power is why they need guardrails.
- Pair every random table with **bad-luck protection**: a pity counter (guarantee after N
  misses) or an increasing chance per miss. Simulate the 95th-percentile unlucky player.
- Publish odds whenever a random outcome can be bought, directly or through a purchasable
  currency. Paid random items now drive a PEGI 16 minimum for games submitted from June 2026;
  route anything paid to `game-economy-designer`.

### Loss aversion
Prospect theory estimates losses weigh roughly twice as much as equal gains (Tversky and
Kahneman, 1992). Design failure to teach: show what killed the player, keep partial progress,
or convert loss into another resource. Avoid erasing long stretches of play with no lesson.

### Novelty pacing
Introduce a new verb, enemy type, system or reward type at regular intervals across the whole
game, not only in hour one. Plot novelty per hour; flat stretches predict churn.

---

## 5. Game feel (Swink's components: input, response, context, polish, metaphor)

Starting ranges, all *rules of thumb* at 60 fps; tune in a real build:

| Element | Starting range | Notes |
|---|---|---|
| Input buffer | 4-8 frames | Accept early inputs for the next action |
| Coyote time | 4-6 frames | Allow jumps just after leaving a ledge |
| Hitstop | 2-5 frames (about 30-80 ms) | Freeze attacker and target on heavy hits; scale with impact |
| Screen shake | 50-200 ms, exponential decay | Scale amplitude with impact; always offer reduce/off |
| Camera zoom punch | 3-8% for 100-200 ms | Critical hits, big impacts |
| Audio sync | Within 1-2 frames of the visual event | Late audio reads as weak impact |
| Anticipation / action / follow-through | Readable anticipation on enemy attacks | Telegraphs are a difficulty knob |

Feel spec format:
```
FEEL-003 Heavy hit
- trigger: damage >= heavy_hit_threshold
- hitstop_frames: 4 (range 2-6)
- shake: amplitude 6 px, decay exp 0.85/frame (range 3-10 px), respects settings.shake_scale
- sfx: hit_heavy, offset 0 frames; vfx: spark_burst, offset 0 frames
- rumble: 120 ms, 0.6 strength, respects settings.rumble_enabled
- verified by: human (feel), agent (timings via event log)
```

---

## 6. Simulation methods

| Method | Good for | Cost | Notes |
|---|---|---|---|
| Spreadsheet model | Formulas, curves, time-to-unlock | Minutes | Start here; one row per level or session |
| Monte Carlo script | Drop tables, crit variance, pity timers | An hour of agent time | 10,000+ trials; report 5th/50th/95th percentiles |
| Scripted bot league | Build and option win rates, dominant strategies | A few hours | Random, greedy and archetype policies; hundreds of matches per pairing |
| Headless game sim | Real rules, real numbers | Needs deterministic stepping | Best fidelity; reuse acceptance-check hooks |
| Reinforcement learning agents | Exploit discovery in large strategy spaces | High | Rarely worth it for small teams; scripted bots find most problems first |

Rules:
- Simulate with the same tuning file the game reads, not a copy.
- Seed every run and log the seed; a balance bug you cannot reproduce cannot be fixed.
- Flag options outside a win-rate band (for example 45-55%) and any option nobody picks.
- Simulations optimize measurable metrics; designers optimize feel. Use both.

Dominant-strategy report format:
```
Bot league, 2026-11-05, seed 1337, 500 matches per pairing, tuning rev a1b2c3
| Build | Win rate | Pick rate (greedy bot) | Flag |
|---|---|---|---|
| Glass Cannon | 63% | 41% | DOMINANT: check crit_mult cap |
| Turtle | 38% | 2% | DEAD: armor_k too high or regen too low |
```

---

## 7. Systemic design checks

Interaction matrix: rows and columns are systems or element types; each cell is one of
`designed`, `allowed emergent`, `blocked (reason)`.

| | Fire | Water | Electric | Wood | Metal |
|---|---|---|---|---|---|
| Fire | -- | blocked: extinguish | allowed | designed: burns | allowed: heats |
| Electric | allowed | designed: conducts | -- | blocked | designed: conducts |

Exploit triage: patch an emergent strategy only if it trivializes challenge or breaks another
player's experience. If it is fun and costly to execute, consider making it a feature.

---

## 8. Procedural generation checks

Constraint-based generators (WaveFunctionCollapse and its variants) produce locally valid
layouts that may still be unplayable. Combine hand-authored anchors (key rooms, landmarks,
narrative beats) with generated connective space, then verify every seed automatically:
- path exists from start to every required objective (pathfinding check);
- resource and enemy density within bands per area;
- difficulty estimate within the target curve for that depth;
- no softlocks (keys behind their own doors, unreachable exits).

Generate 1,000 seeds in CI and fail the build on any violation; keep failing seeds as
regression fixtures.

---

## 9. Frameworks beyond MDA

All documented in `docs/game-design-theory.md` (bundled with the plugin):
- **DDE (Design, Dynamics, Experience)**, Walk, Gorlich and Barrett (2017): finer-grained
  experience vocabulary when MDA's aesthetics feel too coarse.
- **Quantic Foundry Gamer Motivation Model** (Nick Yee): survey-based motivation axes; more
  useful than Bartle for checking a target audience assumption.
- **Self-Determination Theory**: autonomy, competence, relatedness as the test for whether a
  progression system motivates or merely obligates.
- **Flow** (Csikszentmihalyi): clear goals, immediate feedback, challenge matched to skill.
