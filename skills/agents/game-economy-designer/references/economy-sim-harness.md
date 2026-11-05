# Economy Simulation Harnesses -- Spreadsheet, Python, JavaScript

Load this before modeling any currency, drop table or progression economy, or before asking a
coding agent to build an economy simulator. Both scripts below were run as written (Python 3,
Node 22) on 2026-11-05; the sample output is real output from the sample config. They are
starting points: extend the config and behavior rules to match your game, and keep the config
file the single source of truth that the game also reads.

---

## 1. Pick the cheapest model that answers the question

| Question | Tool | Time |
|---|---|---|
| Are prices and earn rates in the right ballpark? | Spreadsheet stock-flow | 30 minutes |
| How long does each archetype take to reach milestone X? | Python stock-flow harness (section 3) | 1 hour |
| What does the unluckiest 5% of players experience with this drop table or gacha? | Monte Carlo (section 4) | 15 minutes |
| Does an exploit or a 10x faucet bug break the economy, and how fast? | Harness with a stress config | 30 minutes |
| Do player markets inflate? | Agent-based sim with trading rules, or a live test server | Days; only if you have a market |
| Web game wants the sim in the same language as the game | JavaScript version, sharing `src/data/*.json` | 1 hour |

Machinations.io is a purpose-built visual tool for faucet/sink diagrams if the team prefers a
graphical model; export its parameters to the same config the game reads.

---

## 2. Spreadsheet layout (one tab per currency)

| Column | Meaning |
|---|---|
| Day | 1..365 |
| Minutes played (per archetype) | sessions x minutes, one column per archetype |
| Inflow per faucet | rate x minutes (or per day); one column per faucet |
| Upkeep outflow | repairs, fees, consumables |
| Purchases | next item price if affordable under the archetype's buying rule |
| Balance | previous balance + inflow - outflow |
| Owned items | count per purchase sink |
| Time-to-milestone | first day the milestone condition is true |

Rules: inputs live on a separate "Tuning" tab with named ranges; never type a number into a
formula. Conditional formatting flags balances that grow every week after the first month
(sinks saturating) and milestones that a casual archetype never reaches.

---

## 3. Python stock-flow harness

`design/economy/econ.json` (sample):
```json
{
  "currency": "gold", "days": 180,
  "archetypes": {
    "casual": {"share": 0.6, "sessions_per_day": 1, "minutes_per_session": 30, "skill": 0.8, "buy_chance": 0.8},
    "regular": {"share": 0.3, "sessions_per_day": 2, "minutes_per_session": 45, "skill": 1.0, "buy_chance": 0.7},
    "dedicated": {"share": 0.1, "sessions_per_day": 3, "minutes_per_session": 90, "skill": 1.2, "buy_chance": 0.5}
  },
  "faucets": [
    {"name": "enemy_drops", "per_minute": 8, "skill_scaled": true},
    {"name": "quest_rewards", "per_minute": 6, "skill_scaled": false},
    {"name": "daily_bonus", "per_day": 150}
  ],
  "upkeep_sinks": [{"name": "repairs", "per_minute": 3}],
  "purchase_sinks": [
    {"name": "upgrades", "base_price": 1500, "growth": 1.25, "count": 20},
    {"name": "cosmetics", "base_price": 5000, "growth": 1.0, "count": 30}
  ],
  "random_reward": {"name": "rare_chest", "chance_per_session": 0.05, "value": 2000, "pity_sessions": 30},
  "milestone": {"sink": "upgrades", "count": 10},
  "alerts": {"max_gini": 0.6, "max_weekly_balance_growth_pct": 5, "max_faucet_share": 0.4, "max_casual_to_dedicated_milestone_ratio": 5, "max_saturated_share": 0.05}
}
```

`tools/econ_sim.py`:
```python
#!/usr/bin/env python3
"""Economy simulation harness: stock-flow per player plus Monte Carlo variance.

Usage:  python3 tools/econ_sim.py design/economy/econ.json --players 2000 --seed 1337 --out production/econ
Writes daily.csv and summary.md to --out. Exits 1 if any alert threshold is breached (CI-friendly).
Reads only the JSON config: the game and the simulation must share one source of truth.
"""
import argparse, csv, json, os, random, statistics, sys


def gini(values):
    xs = sorted(max(0.0, v) for v in values)
    n, total = len(xs), sum(xs)
    if n == 0 or total == 0:
        return 0.0
    weighted = sum((i + 1) * x for i, x in enumerate(xs))
    return (2 * weighted) / (n * total) - (n + 1) / n


def pct(xs, p):
    xs = sorted(xs)
    if not xs:
        return None
    return xs[round(p / 100 * (len(xs) - 1))]


class Player:
    def __init__(self, archetype, cfg):
        self.arch, self.cfg = archetype, cfg
        self.balance = 0.0
        self.owned = {s["name"]: 0 for s in cfg["purchase_sinks"]}
        self.pity = 0
        self.milestone_day = None


def price(sink, owned):
    return sink["base_price"] * sink["growth"] ** owned


def simulate_day(p, day, cfg, rng, faucet_totals, sink_totals):
    a = cfg["archetypes"][p.arch]
    for _ in range(a["sessions_per_day"]):
        minutes = a["minutes_per_session"] * min(2.0, max(0.25, rng.gauss(1.0, 0.25)))
        for f in cfg["faucets"]:
            if "per_minute" in f:
                amt = f["per_minute"] * minutes * (a["skill"] if f.get("skill_scaled") else 1.0)
                p.balance += amt
                faucet_totals[f["name"]] += amt
        for s in cfg["upkeep_sinks"]:
            amt = min(p.balance, s["per_minute"] * minutes)
            p.balance -= amt
            sink_totals[s["name"]] += amt
        rr = cfg.get("random_reward")
        if rr:
            p.pity += 1
            if rng.random() < rr["chance_per_session"] or p.pity >= rr["pity_sessions"]:
                p.balance += rr["value"]
                faucet_totals[rr["name"]] += rr["value"]
                p.pity = 0
    for f in cfg["faucets"]:
        if "per_day" in f:
            p.balance += f["per_day"]
            faucet_totals[f["name"]] += f["per_day"]
    for s in cfg["purchase_sinks"]:  # priority order: players save for the first unfinished sink
        while p.owned[s["name"]] < s["count"]:
            cost = price(s, p.owned[s["name"]])
            if p.balance < cost or rng.random() > a["buy_chance"]:
                return check_milestone(p, day, cfg)
            p.balance -= cost
            p.owned[s["name"]] += 1
            sink_totals[s["name"]] += cost
    check_milestone(p, day, cfg)


def check_milestone(p, day, cfg):
    m = cfg["milestone"]
    if p.milestone_day is None and p.owned[m["sink"]] >= m["count"]:
        p.milestone_day = day


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("config")
    ap.add_argument("--players", type=int, default=2000)
    ap.add_argument("--seed", type=int, default=1337)
    ap.add_argument("--out", default="production/econ")
    args = ap.parse_args()
    cfg = json.load(open(args.config))
    rng = random.Random(args.seed)
    archs = list(cfg["archetypes"])
    weights = [cfg["archetypes"][k]["share"] for k in archs]
    players = [Player(rng.choices(archs, weights)[0], cfg) for _ in range(args.players)]
    names = [f["name"] for f in cfg["faucets"]] + ([cfg["random_reward"]["name"]] if cfg.get("random_reward") else [])
    faucet_totals = {n: 0.0 for n in names}
    sink_totals = {s["name"]: 0.0 for s in cfg["upkeep_sinks"] + cfg["purchase_sinks"]}
    os.makedirs(args.out, exist_ok=True)
    medians, rows = [], []
    for day in range(1, cfg["days"] + 1):
        for p in players:
            simulate_day(p, day, cfg, rng, faucet_totals, sink_totals)
        bal = [p.balance for p in players]
        medians.append(statistics.median(bal))
        rows.append({"day": day, "median_balance": round(medians[-1]), "p95_balance": round(pct(bal, 95)),
                     "gini": round(gini(bal), 3)})
    with open(os.path.join(args.out, "daily.csv"), "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)

    al, alerts = cfg["alerts"], []
    final_gini = rows[-1]["gini"]
    if final_gini > al["max_gini"]:
        alerts.append(f"Gini {final_gini} > {al['max_gini']}")
    last4 = [(medians[d] - medians[d - 7]) / max(medians[d - 7], 1) * 100 for d in range(len(medians) - 28, len(medians))]
    worst_growth = max(last4) if len(medians) > 35 else 0.0
    if worst_growth > al["max_weekly_balance_growth_pct"]:
        alerts.append(f"Median balance grew {worst_growth:.1f}%/week in the last 4 weeks (> {al['max_weekly_balance_growth_pct']}%)")
    saturated = sum(1 for p in players if all(p.owned[s["name"]] >= s["count"] for s in cfg["purchase_sinks"]))
    if saturated / len(players) > al["max_saturated_share"]:
        alerts.append(f"{saturated / len(players):.0%} of players own every sink item: add aspirational sinks")
    total_in = sum(faucet_totals.values()) or 1
    for n, v in faucet_totals.items():
        if v / total_in > al["max_faucet_share"]:
            alerts.append(f"Faucet {n} supplies {v / total_in:.0%} of inflow (> {al['max_faucet_share']:.0%})")
    lines = [f"# Economy sim -- {cfg['currency']}, {args.players} players, {cfg['days']} days, seed {args.seed}", "",
             "| Archetype | Players | Milestone p5 / p50 / p95 (day) | Never reached | Final balance p50 |",
             "|---|---|---|---|---|"]
    p50 = {}
    for k in archs:
        group = [p for p in players if p.arch == k]
        days = [p.milestone_day for p in group if p.milestone_day]
        p50[k] = pct(days, 50)
        lines.append(f"| {k} | {len(group)} | {pct(days, 5)} / {p50[k]} / {pct(days, 95)} | "
                     f"{sum(1 for p in group if not p.milestone_day)} | {round(statistics.median(p.balance for p in group))} |")
    lo, hi = archs[0], archs[-1]
    if p50[lo] is None or p50[hi] is None:
        alerts.append(f"Milestone not reached at p50 by {lo if p50[lo] is None else hi}")
    elif p50[lo] / p50[hi] > al["max_casual_to_dedicated_milestone_ratio"]:
        alerts.append(f"{lo} reaches milestone {p50[lo] / p50[hi]:.1f}x later than {hi}")
    lines += ["", "| Faucet | Share |", "|---|---|"] + [f"| {n} | {v / total_in:.0%} |" for n, v in faucet_totals.items()]
    total_out = sum(sink_totals.values()) or 1
    lines += ["", "| Sink | Share |", "|---|---|"] + [f"| {n} | {v / total_out:.0%} |" for n, v in sink_totals.items()]
    lines += ["", f"Final Gini: {final_gini}", "", "## Alerts"] + ([f"- {a}" for a in alerts] or ["- none"])
    open(os.path.join(args.out, "summary.md"), "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))
    sys.exit(1 if alerts else 0)


if __name__ == "__main__":
    main()
```

Run and sample output (seed 1337, 2,000 players):
```
$ python3 tools/econ_sim.py design/economy/econ.json --players 2000 --seed 1337
| Archetype | Players | Milestone p5 / p50 / p95 (day) | Never reached | Final balance p50 |
|---|---|---|---|---|
| casual | 1189 | 81 / 92 / 100 | 0 | 15811 |
| regular | 615 | 33 / 37 / 41 | 0 | 41761 |
| dedicated | 196 | 13 / 14 / 20 | 0 | 42200 |
Final Gini: 0.36
## Alerts
- Median balance grew 49.9%/week in the last 4 weeks (> 5%)
- 9% of players own every sink item: add aspirational sinks
- Faucet enemy_drops supplies 43% of inflow (> 40%)
- casual reaches milestone 6.6x later than dedicated
$ echo $?
1
```
Reading it: the sample economy is healthy on inequality (Gini 0.36) but runs out of things to
buy. Balances keep climbing in the last month and 9% of players (the dedicated archetype) own
everything, so the next design move is an aspirational or progressive sink, not a faucet nerf.
The casual-to-dedicated milestone gap (6.6x) exceeds the 5x rule of thumb, so either lower
early upgrade growth or add a casual-friendly faucet (daily bonus, catch-up rewards).

Extending it:
- **Premium currency:** add a second config and a purchase probability per archetype; report
  real-money spend percentiles per archetype, never just averages.
- **Trading:** model only if the game has a market; add transaction taxes as a sink.
- **Seasons and resets:** zero or decay balances at season boundaries and report the reset loss.
- **Stress tests:** copy the config, multiply one faucet by 10 (exploit), and record how many
  days until the saturation alert fires. That number is your incident-response window.

---

## 4. JavaScript Monte Carlo for drop tables and gacha (web games)

`src/data/drops.json`:
```json
{ "baseChance": 0.01, "softPityStart": 50, "softPityStep": 0.05, "hardPity": 70,
  "pricePerPull": 1.5, "currency": "USD", "maxAcceptableP95": 65 }
```

`tools/drop-sim.mjs`:
```js
// tools/drop-sim.mjs -- Monte Carlo for a drop table with pity. Run: node tools/drop-sim.mjs src/data/drops.json 100000 1337
import { readFileSync } from "node:fs";

const [, , path = "drops.json", trialsArg = "100000", seedArg = "1337"] = process.argv;
const table = JSON.parse(readFileSync(path, "utf8"));
const trials = Number(trialsArg);

// mulberry32: small seeded PRNG so results are reproducible across machines
function rng(seed) {
  return () => {
    seed |= 0; seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const rand = rng(Number(seedArg));

// pulls needed to get the target rarity once, honoring soft and hard pity
function pullsToTarget() {
  for (let pull = 1; ; pull++) {
    const soft = Math.max(0, pull - table.softPityStart) * table.softPityStep;
    const chance = pull >= table.hardPity ? 1 : Math.min(1, table.baseChance + soft);
    if (rand() < chance) return pull;
  }
}

const results = Array.from({ length: trials }, pullsToTarget).sort((a, b) => a - b);
const q = (p) => results[Math.round((p / 100) * (results.length - 1))];
const mean = results.reduce((s, x) => s + x, 0) / results.length;
console.log(`trials=${trials} mean=${mean.toFixed(1)} p5=${q(5)} p50=${q(50)} p95=${q(95)} max=${results.at(-1)}`);
if (table.pricePerPull) {
  console.log(`real-money cost: p50=${(q(50) * table.pricePerPull).toFixed(2)} p95=${(q(95) * table.pricePerPull).toFixed(2)} ${table.currency}`);
}
if (q(95) > table.maxAcceptableP95) { console.error(`FAIL: p95 ${q(95)} > ${table.maxAcceptableP95}`); process.exit(1); }
```

Run and sample output:
```
$ node tools/drop-sim.mjs src/data/drops.json 100000 1337
trials=100000 mean=42.5 p5=6 p50=53 p95=59 max=68
real-money cost: p50=79.50 p95=88.50 USD
```
Read the p95, not the mean: one player in twenty pays at least the p95 figure for the target
item. If that number would embarrass you in a press article, lower the hard pity or the price.
Publish the odds and the pity rule in-game; PEGI now gives paid random items a 16 minimum for
games submitted from June 2026, and several jurisdictions require odds disclosure (see
`regulatory-landscape.md`).

---

## 5. Making an agent build and run it

Prompt:
```
Build tools/econ_sim.py from design/economy/model.md. It must read every rate and price from
design/economy/econ.json (the same file the game loads). Model the archetypes in the model doc.
Output production/econ/daily.csv and production/econ/summary.md, and exit 1 when any alert in the
config's "alerts" block fires. Run it with seed 1337 and paste the summary. Do not change any value
in econ.json or the alert thresholds; if results look wrong, explain why instead.
```
Verification checklist before you trust the numbers:
- [ ] The sim reads the same config file as the game (grep the game code for the path).
- [ ] A hand-calculated case matches: one casual player, day 1, no randomness.
- [ ] Changing the seed changes details but not conclusions.
- [ ] A deliberately broken config (10x faucet) makes the alerts fire.
- [ ] No agent edits to thresholds or tuning values in the same commit as the sim.
- [ ] Results and seed are saved under `production/econ/` and summarized in the economy model doc.

CI: run the harness on every change to `econ.json` (see `/gameforge:game-ci-pipeline`); a red
economy check blocks the merge just like a failing unit test.
