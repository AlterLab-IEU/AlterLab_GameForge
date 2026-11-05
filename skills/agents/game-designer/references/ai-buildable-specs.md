# Designing for AI-Built Prototypes -- Spec Patterns, Tuning Files, Checks

Load this before writing any mechanic spec that Claude Code or another coding agent will
implement. Sources: Anthropic's Claude Code best-practices docs ("give Claude something it can
run that comes back pass or fail"), OpenAI's published `develop-web-game` skill (the
implement, act, pause, observe, adjust loop with `render_game_to_text` and `advanceTime`), and
practitioner write-ups from 2026 (Simon Willison's Battle Drones; the Vibe Jam 2026 Gold winner).
Exposed tuning constants and debug panels are sensible practice but not a documented
vibe-coding standard; treat them as GameForge convention.

---

## 1. Why agent-built specs are different

| Human programmer | Coding agent |
|---|---|
| Asks when a rule is ambiguous | Picks something plausible and moves on |
| Notices the jump feels floaty | Cannot feel anything; can measure everything |
| Remembers last week's decision | Remembers only what is in files and the current context |
| Resists changing a design number to pass a test | Will do it unless told not to |

So the spec must carry: atomic rules, named numbers, explicit edge cases, checks with a method,
and a clear line between machine-verifiable and human-verifiable outcomes.

---

## 2. Full spec template

```markdown
# MECH-[id] [Name]   (status: Draft | Approved | Built | Verified | Cut)
Owner: game-designer   Spec rev: [n]   Updated: YYYY-MM-DD
Fantasy (one line, player's perspective): [...]
Pillar served: [...]

## Rules (atomic, numbered; one behavior per line)
1. ...

## State and events
- State owned: [fields, types, initial values]
- Events emitted: [name(payload)] ; Events consumed: [name]

## Tuning constants  (file: [path])
| Name | Unit | Default | Range | Effect of raising it |
|---|---|---|---|---|

## Formulas
[named variables only; reference constants by name]

## Edge cases
- [boundary, interruption, simultaneous events, save/load mid-action, pause, low frame rate]

## Acceptance checks
| ID | Given / When / Then (numeric) | Method | Verified by |
|---|---|---|---|
| AC-1 | | unit / headless sim / scripted input + state dump / screenshot / playtest | agent / human |

## Kill criteria
[observable condition that cuts or redesigns the mechanic]

## Out of scope
[what the agent must not build yet]
```

Writing rules:
- One behavior per numbered rule. "And" in a rule usually means two rules.
- Units in every constant name (`_px`, `_s`, `_frames`, `_pct`, `_per_s`).
- Frame counts assume a fixed simulation step; state it (60 Hz is a common default).
- Every acceptance check has a tolerance (`240 +/- 2 px`) and a method.
- Kill criteria are written before the build, when you are least attached.

---

## 3. Tuning constants: one source of truth per engine

Principles: one file per system, loaded at startup, hot-reloadable in development, bound to a
debug panel, never duplicated in code. Add a CI grep that fails on known default values appearing
as literals in gameplay code.

### Godot 4.7 (GDScript)
```gdscript
# res://tuning/player_tuning.gd
class_name PlayerTuning extends Resource
@export_range(160, 320) var dash_distance_px: float = 240.0
@export_range(8, 16) var dash_duration_frames: int = 12
@export_range(0, 10) var dash_iframes: int = 6
@export_range(0.3, 1.2) var dash_cooldown_s: float = 0.6
```
Save an instance as `res://tuning/player.tres`; the player script holds
`@export var tuning: PlayerTuning`. The Inspector becomes the tuning panel, `@export_range`
documents the valid range, and text `.tres` files diff cleanly in git.

### Unity 6.3 LTS / 6.6 (C#)
```csharp
[CreateAssetMenu(menuName = "Tuning/Player")]
public sealed class PlayerTuning : ScriptableObject {
    [Range(160, 320)] public float dashDistancePx = 240f;
    [Range(8, 16)]    public int   dashDurationFrames = 12;
    [Range(0, 10)]    public int   dashIFrames = 6;
    [Range(0.3f, 1.2f)] public float dashCooldownS = 0.6f;
}
```
Reference the asset from components. Unity 6.6 enables Fast Enter Play Mode by default, so static
fields are not reset between play sessions: never cache tuning or mutable runtime state in
statics.

### Unreal Engine 5.8 (C++)
- A `UPrimaryDataAsset` subclass with `UPROPERTY(EditDefaultsOnly, meta=(ClampMin, ClampMax))`
  fields per system, or a DataTable imported from CSV for row-based data (enemies, weapons).
- Console variables (`TAutoConsoleVariable`) for live tweaking in development builds only;
  write the final value back to the asset.

### Web (Three.js, Phaser, PixiJS, Kaplay)
```ts
// src/tuning.ts
export const tuning = {
  dash: { distancePx: 240, durationFrames: 12, iFrames: 6, cooldownS: 0.6 },
} as const;
export const ranges = {
  "dash.distancePx": [160, 320], "dash.cooldownS": [0.3, 1.2],
} as const;
```
In development builds (`import.meta.env.DEV` with Vite), bind a panel library such as lil-gui
or Tweakpane to a mutable copy and add an "export JSON" button so tuned values return to the file.
Strip the panel from production builds (portals reject debug code).

---

## 4. Observability: what the agent needs to check its own work

| Hook | Purpose | Web | Engines |
|---|---|---|---|
| State dump | Compact JSON of what matters (positions, HP, cooldowns, score) | `window.render_game_to_text()` | Debug command or test helper that serializes state |
| Deterministic stepping | Advance N fixed steps without wall-clock time | `window.advanceTime(ms)` | Fixed timestep; test harness calls the physics/process step directly |
| Seeded RNG | Reproducible runs | Seed from URL param (`?seed=1337`) | Seed from command-line arg or test setup |
| Event log | Assert ordering and timing | Ring buffer exposed on `window` in DEV | Signal/event recorder in test builds |
| Debug overlay | Human inspection of hitboxes, AI states | Toggle key in DEV | Engine debug draw |

Test runners agents can drive:
- **Web:** Playwright (load page with `?seed=&test=1`, send inputs, call `advanceTime`, read
  `render_game_to_text`, take screenshots). Treat screenshots as evidence for humans, state dumps
  as evidence for assertions.
- **Godot:** GUT or gdUnit4 test suites run headless (`godot --headless` with the framework's
  runner script).
- **Unity:** Unity Test Framework edit-mode and play-mode tests, run from the command line in
  batch mode; Unity's official MCP server and community servers (for example CoplayDev's MCP for
  Unity) can also trigger tests from an agent session.
- **Unreal:** Automation tests (Session Frontend or command-line `Automation RunTests`); the
  UE 5.8 experimental Unreal MCP plugin can run them from an agent, editor-only and on localhost.

Engine and MCP setup is `game-technical-director` and engine-specialist territory; the designer
only needs to know which checks are cheap to automate.

---

## 5. Check recipes by mechanic type

| Mechanic | Agent-verifiable check | Human check |
|---|---|---|
| Movement (jump, dash) | Displacement and timing after N fixed steps within tolerance | Weight, control, camera comfort |
| Combat damage | Formula output for a table of inputs; TTK median from 1,000 simulated fights | Impact feel, telegraph readability |
| Cooldowns and resources | Use blocked until cooldown elapses; resource never negative | Rhythm, frustration |
| AI behavior | State transitions under scripted stimuli; no stuck states over 10,000 steps | Believability, fairness |
| Progression | Time-to-unlock per archetype from simulation within band | Sense of growth |
| Drop tables | 10,000-trial distribution matches spec; pity triggers at N | Excitement, fairness perception |
| Procedural levels | 1,000 seeds pass reachability and density checks | Variety, landmark memorability |
| UI feedback | Event fires within 1 frame of action (event log) | Clarity at a glance |
| Fun | Not agent-verifiable | Playtest with fresh players |

---

## 6. Balance harnesses an agent can build in an afternoon

Ask for these early; they are the cheapest design instruments available in 2026.
- **Formula table generator:** reads the tuning file, prints the scaling table (level vs DPS,
  HP, TTK) as CSV and Markdown.
- **Monte Carlo runner:** 10,000+ trials of drops or crits; prints percentiles.
- **Bot league:** headless matches between builds with random, greedy and archetype policies;
  prints win and pick rates; flags dominant and dead options.
- **Sweep tool:** varies one constant across its range, holding others fixed; plots the metric.
  One variable at a time.
- **Replay recorder:** input log plus seed reproduces any session; attach to bug reports.

Precedent: Willison's Battle Drones post (October 2026) describes 1,200+ AI-vs-AI balance
matches and an agent-built debug tool; he also notes cross-browser `Math.sin`/`Math.cos`
differences desynced replays until he used custom functions. Determinism is a design requirement
the moment you rely on replays or lockstep.

---

## 7. Prompts

**Critique before build**
```
Read design/gdd/mech-014-dash.md. Do not write code yet.
1. List every ambiguity, missing edge case, and rule that conflicts with existing specs in design/gdd/.
2. For each acceptance check, say how you would automate it, or why you cannot.
3. Propose the tuning file location and the debug hooks you will add.
```

**Build to spec**
```
Implement MECH-014 exactly as specified. Read every number from the tuning file; no literals in
gameplay code. Add automated tests for AC-1 to AC-4. Run them and paste the output.
Do not change tuning defaults, ranges or check thresholds. If a check cannot pass, stop and explain.
Commit as: feat(player): add dash [MECH-014]
```

**Verify**
```
Run all checks tagged MECH-014. Report a table: check, result, evidence (output or screenshot path).
List each tuning constant you read and its source file. Grep gameplay code for 240, 12 and 0.6.
```

**Fun pass (human leads, agent proposes)**
```
MECH-014 passes its checks but playtesters call it floaty. Propose three variants, each changing at
most two tuning constants within their ranges, and predict the player-facing effect of each.
Do not edit anything until I choose.
```

**Sweep**
```
Write tools/sweep.py (or tools/sweep.ts) that runs the headless dash test for dash_distance_px from 160
to 320 in steps of 20 and prints hazard-skip rate per value. Use seed 1337.
```

---

## 8. Guardrails

- **Spec drift:** when behavior changes, the spec changes in the same commit. Reviewers reject
  code that contradicts an Approved spec.
- **Threshold tampering:** a diff that touches both a tuning default and a test threshold is a red
  flag; review it by hand.
- **Silent scope creep:** the "Out of scope" list is binding; agents love to add features.
- **Handoff notes:** after each session, record decisions and open questions in
  `production/session-state/active.md` so the next agent (or human) starts from the spec, not from
  memory of a chat.
- **Originality:** describe mechanics as rules and numbers; do not ask an agent to reproduce a
  specific commercial game. Claude Code declines such requests (late October 2026), and ripped
  assets or decompiled code invite takedowns.
