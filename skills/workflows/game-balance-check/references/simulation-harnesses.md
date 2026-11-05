# Simulation Harnesses Agents Can Build

A balance harness runs the game's rules thousands of times without rendering, with fixed seeds,
and writes one row per run for analysis. Coding agents build these quickly; the human's job is to
make sure the harness measures the real game. Commands below assume harness files live in
`tools/balance/` and output in `tools/balance/out/` (gitignore the output).

## 1. Architecture

```
            +---------------------------+
            |  rules core (pure)        |  state + step(dt, input) / resolve(choice)
            |  seeded RNG streams       |  reads tuning data, no rendering, no wall clock
            +-------------+-------------+
                          |
       +------------------+------------------+
       |                  |                  |
  game view          balance harness     unit tests
  (renders state,    (bots choose,        (Vitest, GUT,
   reads input)       loops seeds,         NUnit, UE
                      writes JSONL/CSV)    automation)
```

If the rules are tangled into rendering or physics callbacks, the first task is extracting the
part the balance question needs (combat resolution, drop rolls, economy ticks, run generation)
into the pure core. A harness that re-implements the rules "close enough" will drift from the game
and produce confident, wrong answers.

## 2. Seeded randomness

Use your own small PRNG for rules so results match across Node, every browser and every platform.
Integer-only generators such as mulberry32 are deterministic everywhere:

```ts
// src/sim/rng.ts
export function mulberry32(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;   // [0, 1)
  };
}

// Separate streams so a bot change does not change the dungeon, and a loot change does not change AI.
export function streams(seed: number) {
  return {
    world: mulberry32(seed),
    loot:  mulberry32(seed ^ 0x9e3779b9),
    ai:    mulberry32(seed ^ 0x85ebca6b),
    bot:   mulberry32(seed ^ 0xc2b2ae35),
  };
}
```

Engines: Godot `RandomNumberGenerator` with `.seed` set (one instance per stream, never the global
`randf()` inside rules); Unity `new System.Random(seed)` per stream rather than
`UnityEngine.Random`; Unreal `FRandomStream(Seed)`.

## 3. Monte Carlo runner (TypeScript, Node)

Node 22.18+ and 24 run `.ts` files directly by stripping types (no enums or namespaces; import
paths keep the `.ts` extension). On older Node, run the same file with `npx tsx`.

```ts
// tools/balance/montecarlo.ts   usage: node tools/balance/montecarlo.ts 10000
import { mkdirSync, writeFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { simulateRun } from '../../src/sim/run.ts';
import { tuning } from '../../src/tuning/tuning.ts';
import { policies } from './policies.ts';

const RUNS = Number(process.argv[2] ?? 10_000);
const commit = execSync('git rev-parse --short HEAD').toString().trim();
mkdirSync('tools/balance/out', { recursive: true });

const rows: string[] = [];
for (const [policy, choose] of Object.entries(policies)) {
  for (let seed = 1; seed <= RUNS; seed++) {
    const r = simulateRun({ seed, tuning, choose });
    rows.push(JSON.stringify({
      commit, policy, seed,
      floor: r.floorReached, won: r.won, gold: r.goldEarned, deaths: r.deaths, turns: r.turns,
    }));
  }
}
const out = `tools/balance/out/montecarlo-${commit}.jsonl`;
writeFileSync(out, rows.join('\n') + '\n');
console.log(`wrote ${rows.length} runs to ${out}`);
```

`package.json`: `"balance": "node tools/balance/montecarlo.ts"`, so agents and teammates run
`npm run balance -- 10000`.

## 4. Bot policies (archetypes)

Bots stand in for player archetypes. Several simple, readable policies beat one clever one:

```ts
// tools/balance/policies.ts
import type { Choose } from '../../src/sim/run.ts';
import { expectedValueNow, riskOf, isHeal } from '../../src/sim/heuristics.ts';

export const policies: Record<string, Choose> = {
  // Lower bound: if random play wins often, the game is too easy or a choice is irrelevant.
  random:   (state, options, rng) => options[Math.floor(rng() * options.length)],
  // Exploit finder: always takes the highest immediate value.
  greedy:   (state, options) => options.reduce((a, b) => (expectedValueNow(state, b) > expectedValueNow(state, a) ? b : a)),
  // Typical cautious player: heals below half health, avoids high-risk options.
  cautious: (state, options) =>
    options.find((o) => isHeal(o) && state.hp < state.maxHp / 2) ??
    options.reduce((a, b) => (riskOf(state, b) < riskOf(state, a) ? b : a)),
  // Build-committed player: forces one build to test that build's viability.
  spearOnly: (state, options) => options.find((o) => o.tags?.includes('spear')) ?? options[0],
};
```

Read every policy before trusting a result. A bot that never uses a mechanic makes that mechanic
look useless; a bot with perfect information makes risky options look safe.

## 5. AI-vs-AI tournament (factions, characters, decks)

```ts
// tools/balance/tournament.ts   usage: node tools/balance/tournament.ts 500
import { simulateMatch } from '../../src/sim/match.ts';
import { tuning } from '../../src/tuning/tuning.ts';
import { wilson } from './stats.ts';

const sides = ['ember', 'tide', 'stone', 'gale'] as const;
const GAMES = Number(process.argv[2] ?? 500);   // per pairing, seats swapped every other game

console.log(['row vs col', ...sides].join('\t'));
for (const a of sides) {
  const cells: string[] = [a];
  for (const b of sides) {
    if (a === b) { cells.push('--'); continue; }
    let wins = 0;
    for (let g = 0; g < GAMES; g++) {
      const swap = g % 2 === 1;
      const r = simulateMatch({ seed: 10_000 + g, tuning, p1: swap ? b : a, p2: swap ? a : b });
      if (r.winner === a) wins++;
    }
    const [lo, hi] = wilson(wins, GAMES);
    cells.push(`${((100 * wins) / GAMES).toFixed(0)}% [${(100 * lo).toFixed(0)}-${(100 * hi).toFixed(0)}]`);
  }
  console.log(cells.join('\t'));
}
```

Swap seats to cancel first-move advantage, and run mirror matches separately to measure it. Use
more than one bot policy per side (aggressive, defensive); a faction that only wins with one
playstyle has a different problem than one that loses with all of them.

## 6. Godot headless runner

Run the game's rules from a `SceneTree` script, no window:

```gdscript
# res://tools/balance/sim_runner.gd
# usage: godot --headless --path . -s res://tools/balance/sim_runner.gd -- --runs=10000
extends SceneTree

const RunSim = preload("res://sim/run_sim.gd")       # preload paths: no dependence on the class cache
const Policies = preload("res://tools/balance/policies.gd")

func _initialize() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	var runs := int(args.get("runs", "10000"))
	var tuning: Resource = load("res://tuning/combat.tres")
	DirAccess.make_dir_recursive_absolute("res://tools/balance/out")
	var out := FileAccess.open("res://tools/balance/out/runs.csv", FileAccess.WRITE)
	out.store_line("seed,policy,floor,won,gold,deaths")
	for policy_name in Policies.NAMES:
		for s in range(1, runs + 1):
			var r: Dictionary = RunSim.simulate(s, tuning, Policies.make(policy_name))
			out.store_line("%d,%s,%d,%d,%d,%d" % [s, policy_name, r["floor"], int(r["won"]), r["gold"], r["deaths"]])
	out.close()
	quit(0)
```

Keep `run_sim.gd` free of nodes and scene-tree calls (extend `RefCounted`) so it runs here and in
GUT or gdUnit4 tests unchanged.

## 7. Unity and Unreal

- **Unity**: put rules in plain C# classes in their own assembly. Run the simulation as an Edit Mode
  test that writes CSV, or as a static method invoked with `-batchmode -executeMethod
  BalanceSim.Run -quit`. No Play Mode needed for pure rules.
- **Unreal**: put rules in plain C++ (or `UObject`s without world dependencies) and run them from
  a commandlet (`UBalanceSimCommandlet`, invoked with `UnrealEditor-Cmd Project.uproject
  -run=BalanceSim -nullrhi`) or an automation test that writes CSV to `Saved/Balance/`.

## 8. Summarizing output (Python, standard library only)

```python
# tools/balance/summarize.py
# usage: python3 tools/balance/summarize.py tools/balance/out/montecarlo-abc123.jsonl floor
import json
import statistics
import sys
from collections import defaultdict

path, metric = sys.argv[1], sys.argv[2]
by_policy = defaultdict(list)
with open(path) as f:
    for line in f:
        row = json.loads(line)
        by_policy[row["policy"]].append(float(row[metric]))

def pct(xs, p):
    xs = sorted(xs)
    k = (len(xs) - 1) * p / 100
    lo = int(k)
    hi = min(lo + 1, len(xs) - 1)
    return xs[lo] + (xs[hi] - xs[lo]) * (k - lo)

print(f"{'policy':<10}{'n':>7}{'mean':>9}{'median':>9}{'p1':>8}{'p5':>8}{'p95':>8}")
for policy, xs in sorted(by_policy.items()):
    print(f"{policy:<10}{len(xs):>7}{statistics.fmean(xs):>9.2f}{statistics.median(xs):>9.2f}"
          f"{pct(xs, 1):>8.2f}{pct(xs, 5):>8.2f}{pct(xs, 95):>8.2f}")
```

Paste the table into the Balance Report with the file name, which already contains the commit.

## 9. Parity and determinism tests

```ts
// src/sim/harness.test.ts  (Vitest)
import { describe, it, expect } from 'vitest';
import { simulateRun } from './run.ts';
import { runGameHeadless } from '../game/headless.ts';   // the real game loop with the renderer stubbed
import { replay } from '../../tools/balance/replay.ts';
import { tuning } from '../tuning/tuning.ts';
import inputs from './fixtures/run-1337-inputs.json';

describe('balance harness', () => {
  it('is deterministic: same seed twice gives identical results', () => {
    const a = simulateRun({ seed: 1337, tuning, choose: replay(inputs) });
    const b = simulateRun({ seed: 1337, tuning, choose: replay(inputs) });
    expect(b).toEqual(a);
  });

  it('matches the real game loop for the same seed and inputs', () => {
    const harness = simulateRun({ seed: 1337, tuning, choose: replay(inputs) });
    const game = runGameHeadless({ seed: 1337, inputs });
    expect(game.summary()).toEqual(harness);
  });
});
```

Record the input fixture once from a real play session using the game's test hooks (see
`/gameforge:game-qa-lead`).

## 10. Determinism checklist

- [ ] Every random draw in the rules goes through a seeded stream; no `Math.random()`,
      unseeded `UnityEngine.Random`, or global `randf()` inside rules.
- [ ] Fixed time step; no wall-clock time (`Date.now()`, `Time.time`) inside rules.
- [ ] No dependence on hash-map iteration order (C# `Dictionary` order is not guaranteed; JS
      objects reorder integer-like keys). Sort keys or use arrays.
- [ ] Transcendental math (`sin`, `cos`, `exp`, `pow`) is avoided in rules that must match across
      browsers or platforms; use lookup tables or fixed-point where bit-exact results matter.
      Simon Willison reported Chrome/Safari trig differences desyncing *Battle Drones* replays
      (October 2026) until custom functions replaced them.
- [ ] Physics: general-purpose engines are not bit-exact across platforms by default. If balance
      depends on physics outcomes, simulate with a deterministic build (Rapier publishes
      `@dimforge/rapier2d-deterministic` and `rapier3d-deterministic`) or keep physics out of the
      balance question.
- [ ] Output rows carry seed, commit and policy, so any surprising run can be replayed in the game.
- [ ] Running the same command twice produces byte-identical output.
