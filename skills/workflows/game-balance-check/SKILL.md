---
name: game-balance-check
description: >
  Validates and tunes game balance: economy faucets and sinks, progression and difficulty curves,
  reward pacing, win rates and dominant strategies, using agent-runnable simulations (Monte Carlo,
  AI-vs-AI) and telemetry. Use for "balance", "tuning", "difficulty spike", "Monte Carlo", "win
  rate". Not for designing currencies or monetization (use game-economy-designer).
argument-hint: "[system to analyze or tune]"
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(npm run balance*), Bash(npx vitest *), Bash(node tools/balance/*), Bash(python3 tools/balance/*), Bash(godot --headless *), Bash(git log *), Bash(git diff *)
effort: high
---

# AlterLab GameForge -- Balance Check

Balance is not making everything equal. It is making every choice feel fair while keeping
decisions meaningful: every option has a trade-off, every intended playstyle is viable, and no
single strategy is best everywhere. A perfectly symmetric game has no interesting decisions.

This workflow validates economy, progression, difficulty and reward systems with explicit models,
then checks those models against evidence: simulations an agent can build and run in minutes,
playtest observations, and telemetry from real players. The math tells you what the system does.
Playtests tell you how it feels. You need both.

## Purpose & Triggers

**Use this workflow when:**
- Currency inflates or deflates; players hoard or are always broke.
- One strategy, build, weapon or character dominates and the rest go unused.
- Progression feels too fast, too slow, or uneven (dead zones, then spikes).
- Players breeze through or hit walls; deaths cluster at one encounter.
- A new item, character, ability or system must fit into existing balance.
- Reward pacing sags in the mid-game; retention drops at a recognizable point.
- You need a simulation harness, a Monte Carlo run or an AI-vs-AI tournament.
- A pre-playtest or pre-launch balance pass.

**Do NOT use this workflow when:**

| Need | Route to |
|---|---|
| Designing currencies, pricing, monetization ethics | `game-economy-designer` |
| Designing or redesigning a mechanic | `game-designer` (if the system is broken, tuning will not save it) |
| How the balance *feels* to players | `game-playtest` |
| Bugs, crashes, exploits caused by code defects | `game-qa-lead` |
| Building the analytics pipeline and dashboards | `game-analytics-setup` |
| Systems not defined yet | `game-prototype` first |

## Inputs I Read First
- `.gameforge/project.json` (engine, phase), the GDD and economy model in `design/`
  (`${CLAUDE_PLUGIN_ROOT}/templates/economy-model.md` is the expected shape), prior reports in
  `design/balance/`, tuning data files, and any playtest or telemetry exports.
- **Genre templates**: for run-based games read
  `${CLAUDE_PLUGIN_ROOT}/genre-packs/roguelike/balance-template.md` (run economy, damage curves,
  rarity and pity, floor scaling, synergy scoring, Monte Carlo setup). For story-driven games read
  `${CLAUDE_PLUGIN_ROOT}/genre-packs/narrative/balance-template.md` (pacing, branch budgets,
  choice-consequence weight, playthrough length). Use them as the checklist for that genre.
- Ask up to three AskUserQuestion items, with defaults:
  1. **System and symptom** (default: "the one players complain about most").
  2. **Evidence available**: none (spreadsheet and simulation), playtest notes, live telemetry.
  3. **Target player**: session length and archetype mix (default: 30-60 minute sessions,
     average player as the primary target).

## Critical Rules

1. **Balance is relative.** 100 damage means nothing without enemy health, alternatives, ammo
   scarcity and skill ceiling.
2. **Dominant strategies kill decisions.** Every viable strategy needs at least one situation where
   it is the wrong choice.
3. **Perception beats arithmetic.** A mathematically fair system can feel unfair. Losses weigh
   roughly twice as much as equal gains (Tversky and Kahneman's 1992 estimate of the loss-aversion
   coefficient is about 2.25); streaks feel rigged even when they are random.
4. **Never balance in a vacuum.** Map the dependency graph before changing a number; trace every
   change through it.
5. **Evidence hierarchy**: live telemetry > playtest observation > simulation > spreadsheet >
   intuition. Simulations validate the math, not the fun; a playtest closes the loop.
6. **Numbers live in data, not code.** Tuning constants sit in data files with units, ranges and a
   change log, so designers and agents can change them without touching logic.
7. **Reproducible or it did not happen.** Every simulation result cites its seed, build commit,
   config file and iteration count.
8. **Ground the analysis** in Flow, SDT and MDA from
   `${CLAUDE_PLUGIN_ROOT}/docs/game-design-theory.md`.

## Workflow

**Step 1: Inventory and Dependency Map**

List every:
- **Currency**: gold, XP, stamina, crafting materials, reputation, premium currency.
- **Faucet**: quest rewards, drops, selling, daily bonuses.
- **Sink**: shops, upgrades, repairs, consumables, fees. Mark **hard sinks** (currency destroyed)
  versus **soft sinks** (currency changes hands or form). Hard sinks control inflation; soft sinks
  only slow velocity.
- **Progression track**: level, gear score, skill tree, unlocks, meta-progression.
- **Difficulty variable**: enemy stats, spawn rates, AI behavior, timers, hazards.
- **Reward mechanism**: loot, unlocks, cosmetics, narrative beats, achievements.

Draw the dependency graph (Mermaid is fine). It is your guard rail: before changing any number,
trace which systems move with it.

**Step 2: Expose Tuning Constants**

If balance numbers are scattered through code (common in agent-built games), the first deliverable
is moving them into one data source the game, the simulation and a debug panel all read:
- Godot: a custom `Resource` (`.tres`); Unity: `ScriptableObject` assets; Unreal: Data Assets or
  Data Tables; web: a typed `tuning.json` (or `tuning.ts`) module with hot reload in dev.
- Every constant gets a unit, a sane range and a one-line purpose. A debug panel (lil-gui,
  Tweakpane or Leva on the web; an in-game dev menu in engines) lets designers tune live.
- Changes go through version control with a line in `design/balance/tuning-changelog.md`.

Read `${CLAUDE_SKILL_DIR}/references/tuning-constants.md` before extracting constants; it has
per-engine examples, a schema and the change-log format.

**Step 3: Economy Validation**

Map flows per currency:
```
Quest rewards --500 g/h--> [Gold] --300 g/h--> Equipment (hard sink)
Monster drops --200 g/h--> [Gold] --150 g/h--> Consumables (hard sink)
Daily login   --100 g/day->[Gold] --100 g/h--> Player trading (soft sink)
Net accumulation: +150 g/h before trading -> slow inflation; check against the next gear tier price
```

Net accumulation = faucets minus hard sinks. Persistent positive accumulation inflates (currency
stops mattering); negative deflates (players feel poorer over time). A common target is a mild
surplus periodically reset by large purchases (next gear tier, base upgrade).

Model at least three archetypes and the time each takes to reach key milestones:

| Milestone | Casual (30 min/day) | Average (1-2 h/day) | Hardcore (4+ h/day) | Target |
|---|---|---|---|---|
| First major upgrade | ? | ? | ? | 1-2 sessions |
| Mid-game plateau | ? | ? | ? | [design target] |
| Endgame entry | ? | ? | ? | [design target] |

Rule of thumb: when casual takes more than about five times as many hours as hardcore for the same
milestone, the economy leans on grind. If premium currency, loot boxes or gacha exist, hand the
fairness and ethics review to `game-economy-designer` with your numbers attached; note that PEGI
rates games with paid random items at 16 or higher for submissions from June 2026.

**Step 4: Progression Curves**

Plot player power (for combat games, roughly damage output x survivability) against time or
content. Name the shape:
- **Linear**: predictable, flat-feeling after the midpoint ("I leveled but I don't feel stronger").
- **Exponential**: huge early, forces enemies onto a numbers treadmill ("the numbers mean nothing").
- **Logarithmic**: front-loaded, then stagnant ("nothing makes me stronger anymore").
- **S-curve**: fast learning phase, steady middle, mastery plateau where skill and expression
  matter more than raw power. The usual target.

Then scan for **dead zones** (long stretches with no meaningful gain: add a reward or justify it
narratively) and **spike zones** (one item doubling effectiveness devalues everything before it).
For each level gate: reachable through normal play within 2-3 sessions, content stays engaging
while working toward it, progress is visible, and it feels like an achievement, not a wall.

**Step 5: Difficulty**

- **Challenge-skill fit** per section (Flow): rising difficulty tracks rising mastery, with
  deliberate oscillation (hard encounter, then a breather). Find anxiety (challenge far above
  skill) and boredom (skill far above challenge).
- **Difficulty modes**, from weakest to strongest implementation: stat multipliers only;
  stats plus enemy count and placement; changed AI behavior; changed systems and mechanics.
- **Dynamic difficulty**: if present, it should be invisible and slow to react (adjusting after one
  death is too twitchy; after several deaths at one encounter is reasonable). If absent, offer
  assist and accessibility options with `game-accessibility-specialist`.
- **Time to kill**: fast (under 1 s) is tactical and punishing; medium (2-5 s) gives an engagement
  window; slow (10 s+) suits bosses and needs varied player actions to avoid tedium. Check TTK
  against genre expectations and how it scales with player power.

**Step 6: Reward Pacing**

Classify each reward system: fixed ratio (every N actions), variable ratio (random per action:
the most compulsive schedule, so use it with care), fixed interval (timers, dailies), variable
interval (random events). Then check:
- Probabilities of randomized rewards are disclosed to players.
- Bad-luck protection exists for rare rewards; set the threshold from simulation (the 95th and
  99th percentile wait), not from a number copied from another game.
- Duplicates convert to meaningful value.
- Random *losses* (item loss on death, failed upgrades that downgrade) are rare and telegraphed;
  they hurt about twice as much as equivalent gains feel good.
- No gap longer than about two sessions without a meaningful reward (rule of thumb); fill gaps with
  intermediate rewards or visible progress toward the next one.
- Endgame shifts from power growth to lateral goals (mastery, cosmetics, challenges, social).

**Step 7: Simulate**

Pick the cheapest method that answers the question:

| Question | Method |
|---|---|
| Deterministic flows and time-to-X | Spreadsheet, or Machinations for visual flow models |
| Distribution of outcomes with randomness | Monte Carlo over the game's own rules code |
| Dominant strategies, build or faction balance | AI-vs-AI tournament with several bot policies |
| Exploits a clever player would find | Greedy or search-based bots; RL only if cheaper options failed |
| Frame-level feel (TTK, dodge windows) | Headless sim of the real game loop at fixed time step |

Harness requirements: it runs **the same rules code as the game** (never a parallel
reimplementation that drifts), headless, seeded, at fixed time step, faster than real time, and
writes one row per run to CSV or JSONL. Run at least 10,000 iterations per scenario, and 100,000+
when the event of interest is rarer than 1%. Read
`${CLAUDE_SKILL_DIR}/references/simulation-harnesses.md` before building or extending a harness:
it has the architecture, TypeScript and GDScript runners, bot policies, a parity test and a
determinism checklist.

Interpret distributions, not averages:
- **Median vs mean**: a wide gap means skew; the median is the typical player.
- **5th and 95th percentiles**: the unlucky and lucky experiences. A wide band means luck
  outweighs skill.
- **Worst 1%**: if those runs are miserable (200 attempts for a "guaranteed" drop, an unwinnable
  seed), add a safety net.
- **Outliers above the median**: a choice combination producing 10x the median outcome will be found
  and will become the meta.

Read `${CLAUDE_SKILL_DIR}/references/statistical-methods.md` for distribution choices, expected
value, matchup matrices, build win-rate red flags, confidence intervals and sensitivity analysis.

**Step 8: Tune from Telemetry**

Once real players exist (playtest builds, Steam Playtest, early access, live):
- Compare telemetry with the simulation's predictions. Where they disagree, the model is missing
  a player behavior; fix the model before tuning.
- Balance-relevant metrics: deaths and quits per encounter, completion time per level, pick and
  win rate per build or character, currency stock and flow per player segment, time between
  rewards, upgrade purchase order.
- For economies, watch stock levels by segment, faucet and sink volumes, velocity, and inequality
  (a Gini coefficient across players); extreme concentration means casual players are not served.
- One change per tuning iteration where possible, with the predicted effect written down *before*
  the change ships. Remote config makes this cheap; it also makes it tempting to change five
  things at once.
- Small samples mislead: report confidence intervals on win and completion rates. Event schemas and
  dashboards come from `/gameforge:game-analytics-setup`.

**Step 9: Trace Each Change (DDE and Sensitivity)**

For every proposed change, trace three layers:
- **Design**: what number changes (sword damage 25 -> 22).
- **Dynamics**: how behavior changes (TTK up, ammo use up, players kite more).
- **Experience**: how it feels (deliberate and tactical, or spongy and tedious?).

If you can predict Design and Dynamics but not Experience, you need a playtest, not more math.
Run the sensitivity check at three magnitudes (conservative, proposed, aggressive); if outcomes
swing wildly within a few percent, the system is brittle there and needs a structural fix.

**Step 10: Report and Hand Off**

Write the Balance Report to `design/balance/YYYY-MM-DD-[system].md`, append accepted changes to
`design/balance/tuning-changelog.md`, and update `production/session-state/active.md` with the top
change, its predicted effect and when it will be checked. Hand perception questions to
`game-playtest` and any code defects found by the sims to `game-qa-lead`.

## Working with AI Coding Agents

Simulation harnesses, bots and debug panels used to be a week of tooling work; with a coding agent
they are often an afternoon, so build them early. Simon Willison's write-up of *Battle Drones*
(October 2026), built through agent commits, describes running over 1,200 AI-vs-AI balance matches
and having Claude build a debug probe he called "effectively free." Treat that as the pattern, not
a promise of results.

**Delegate**
- Extracting hard-coded numbers into the tuning data file, with units and ranges.
- Writing the headless runner, Monte Carlo loop, bot policies, CSV output and summary script.
- Histograms, percentile tables and matchup matrices from the output.
- The debug panel that edits tuning values live.

**Verify by hand**
- **Parity**: the harness imports the game's rules module; it does not re-implement them. Ask for a
  parity test: same seed and inputs through the game and the harness give the same state.
- **Determinism**: run the same seed twice and diff the output. Then run on a second machine or
  browser if the game ships there; floating-point and trig differences between browser engines
  have desynced agent-built games before.
- **Sanity**: compare one simulated metric against a hand-computed expected value. If they differ,
  find out why before reading any other number.
- **Bot policies**: read them. A bot that never uses a mechanic makes that mechanic look weak.
- **Goal-seeking**: an agent asked to "make win rates 50%" may edit the simulation, the bots or the
  test, not the tuning. Lock the harness while tuning and review the diff.

**Prompt that works**: "Read `design/balance/tuning.json` and `src/sim/`. Build
`tools/balance/montecarlo.ts` that imports the sim, runs 10,000 seeded runs per archetype bot,
and writes one JSONL row per run (seed, commit, archetype, floor reached, gold earned, deaths).
Add a parity test against the game loop. Do not change any tuning value or game rule."

Pair this with `/gameforge:game-vibe-code` for the build loop and `/gameforge:game-qa-lead` for
the determinism and parity tests.

## Output Formats

**Balance Report**
```markdown
# Balance Report: [System] -- [YYYY-MM-DD]
**Build/commit:** [hash] | **Tuning file:** [path @ hash] | **Analyst:** [name / agent session]
**Evidence used:** [spreadsheet / simulation / playtest round YYYY-MM-DD / telemetry n=___]

## Executive Summary
[Three sentences: current state, biggest problem, top recommendation with predicted effect.]

## Economy Flows
| Currency | Faucets (per h, avg player) | Hard sinks | Soft sinks | Net | Verdict |
|---|---|---|---|---|---|
| Gold | 700 | 450 | 100 | +250/h | Inflating after hour 6 |

## Time-to-Milestone
| Milestone | Casual | Average | Hardcore | Target | Status |
|---|---|---|---|---|---|

## Progression and Difficulty
- Curve shape: [S-curve / ...]; dead zones: [where]; spike zones: [where]
- Difficulty hot spots: [encounter, death rate, quit rate]; TTK: [current vs target]

## Simulation Results
| Scenario | Runs | Seed range | Median | P5 | P95 | Worst 1% | Notes |
|---|---|---|---|---|---|---|---|
| Archetype: cautious, floors reached | 10,000 | 1-10000 | 7 | 3 | 11 | 2 | 4% of seeds unwinnable by floor 3 |

## Imbalances
| ID | System | Issue | Evidence | Severity | Recommendation | Predicted effect |
|---|---|---|---|---|---|---|
| B1 | Weapons | Spear 68% pick rate, 61% win rate | Sim + telemetry n=412 | Major | Spear crit 25% -> 18% | Pick rate under 45%, win rate 52-55% |

## Changes Not Made (and why)
[Proposals rejected after sensitivity or DDE trace]

## Next Check
[What to measure, when, and what result would reverse the change]
```

**Tuning Change Log entry** (`design/balance/tuning-changelog.md`)
```markdown
## 2026-11-05 -- spear crit chance 0.25 -> 0.18 (commit abc123)
Why: B1 in balance report 2026-11-05; spear dominant in sim and telemetry.
Predicted: spear pick rate under 45%, overall win rate within 2 points.
Check: after 200 runs of telemetry or next playtest round. Revert if win rate drops over 5 points.
```

## Quality Criteria
- Every balance dimension relevant to the game is addressed (economy, progression, difficulty,
  rewards), with genre-template items checked when a genre pack applies.
- Every claim cites its evidence: simulation (seed, commit, runs), playtest round or telemetry
  sample size. No "feels about right."
- Simulations run the game's own rules code, are deterministic, and passed a sanity check against a
  hand-computed value.
- At least three player archetypes are modeled; each has a viable experience.
- Edge cases are covered through percentiles and worst-case runs, not only averages.
- Every recommendation names a specific value change, a predicted effect and a check date.
- Tuning constants live in data with units, ranges and a change log.

## Example Use Cases
1. "Gold piles up by mid-game and everything feels trivial. Find the leak and propose sinks."
2. "Build a Monte Carlo harness for our roguelike's floor economy and tell me how often a run is
   unwinnable by floor 3."
3. "Our four factions: run an AI-vs-AI tournament and build the matchup matrix."
4. "Difficulty flattens in Acts 2 and 3. Analyze the scaling and propose changes."
5. "Our numbers are hard-coded everywhere because Claude wrote the game fast. Move them into a
   tuning file with a debug panel."
6. "Steam Playtest telemetry shows a quit spike at the second boss. Is it balance or readability?"
