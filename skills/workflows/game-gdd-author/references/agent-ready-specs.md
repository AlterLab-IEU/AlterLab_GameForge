# Agent-Ready Specs: Acceptance Checks, Tuning Knobs, Build Briefs

Read before drafting Steps 4, 5, 6 and 12 of the GDD workflow. The goal: every T1 system section
can be handed to a coding agent and the result can be judged by something that returns pass or fail.

## Why this matters

- Anthropic's Claude Code best practices: give Claude "something it can run that comes back pass
  or fail" (a test, a build exit code, a screenshot next to a mockup), ask for evidence, and write
  the spec before building in a fresh session.
- OpenAI's published `develop-web-game` skill runs a loop of "implement -> act -> pause -> observe
  -> adjust", exposes `window.render_game_to_text()` (compact JSON of visible state) and
  `window.advanceTime(ms)` (deterministic stepping), and treats Playwright screenshots as "the
  source of truth". Without deterministic stepping, automated game tests are flaky.
- Agents fill unstated details with plausible inventions. A rule with a threshold and a named knob
  leaves nothing to invent.

## Anatomy of an acceptance check

| Field | Rule |
|---|---|
| ID | `AC-<system number>-<n>`, stable once code references it |
| Given / When / Then | One behavior per check; no "and also" |
| Threshold | A number, an exact state, or a ratio of testers |
| Check type | **Auto: unit**, **Auto: sim** (game stepped N frames), **Auto: browser** (Playwright), **Manual: playtest**, **Manual: review** |
| How it is observed | Which state field, log line, screenshot or tester behavior decides it |

Write knob names, not values, in the Then clause ("advances DASH_DISTANCE"), so retuning never
breaks the check. Keep the threshold in the Threshold column.

### Auto vs Manual

- **Auto** when a program can decide: positions, timers, state transitions, resource totals,
  save/load round trips, input remapping, frame budgets on a fixed scene, download size.
- **Manual** when only people can decide: fun, feel, readability, tone, difficulty perception.
  Make them sharp anyway: "4 of 5 first-time testers cross the first gap without a prompt" beats
  "dash feels good". Tester counts like 4/5 are rules of thumb for small playtests, not statistics.
- Target at least two Auto checks per T1 system. A T1 system with only Manual checks cannot be
  verified by an agent between playtests.

## Check types by stack

Typical invocations; adjust paths to the project. Put the chosen one in the GDD §15 as the
project's **check command** and at the top of the project's `CLAUDE.md`.

| Stack | Auto: unit / sim | Auto: end-to-end | Agent tooling notes (as of Nov 2026) |
|---|---|---|---|
| Godot 4.7 | GUT or gdUnit4 test scripts; run headless, e.g. `godot --headless -s addons/gut/gut_cmdln.gd -gexit` | Scene tests that step physics frames and assert on a state dictionary | No official MCP server; Coding-Solo/godot-mcp (community) can launch the project and read debug output. Text `.tscn`/`.gd` files are easy for agents to edit. |
| Unity 6.3 LTS / 6.6 | Unity Test Framework EditMode tests | PlayMode tests: `Unity -batchmode -projectPath . -runTests -testPlatform PlayMode -testResults results.xml` | Unity AI open beta (since 2026-05-04) includes an official MCP server via the Unity CLI and a Claude Code plugin; the community MCP for Unity can also run tests. Note 6.6 Fast Enter Play Mode: static fields no longer reset between runs. |
| Unreal 5.8 | Automation spec / unit tests | `UnrealEditor-Cmd <Game>.uproject -ExecCmds="Automation RunTests <Filter>;Quit" -unattended -nullrhi` | UE 5.8 ships an experimental Unreal MCP plugin: editor-only, localhost, unauthenticated. Not a CI service. |
| Web (Three.js, Phaser, PixiJS) | Vitest on pure game logic (rules, formulas, reducers) | Playwright drives the page, calls `advanceTime(ms)`, reads `render_game_to_text()`, saves screenshots | Keep game logic out of render code so it can be unit-tested without a canvas. |

## State observation hooks (spec them in §15)

Specify these as T1 technical requirements for any agent-built game:

1. **State snapshot.** One function that returns the gameplay-relevant state as JSON or a
   dictionary: player position and velocity, resources, timers, current mode, visible entities.
   Web: `window.render_game_to_text()`. Engines: a debug-only `get_debug_state()` on a game manager.
2. **Deterministic stepping.** Advance the simulation by a fixed timestep on demand
   (`advanceTime(ms)` on the web; a fixed-step loop the test can drive in engines).
3. **Seeded randomness.** One RNG seed knob for tests; every random draw goes through it.
4. **Debug-only gating.** Hooks compile out or are disabled in release builds and are never
   trusted for multiplayer authority.

## Tuning knobs as exposed constants

Every number in a rule becomes a named knob in a data file the game reads at startup. This follows
`docs/coding-standards.md` (no hardcoded gameplay values). Exposing knobs in a debug panel is a
GameForge convention; no published vibe-coding source documents it as standard practice, but it is
what lets a designer retune without another agent session.

| Field | Rule |
|---|---|
| Name | `SCREAMING_SNAKE`, prefixed by system (`DASH_DISTANCE`) |
| Default | The value the first build ships with |
| Range | Min-max the debug panel allows; outside it is a design change, not tuning |
| Unit | units, s, %, pts, cards |
| Effect when raised | One sentence, from the player's point of view |
| Lives in | The single file that owns it |

Where knobs live per stack:

| Stack | Knob container | Debug panel |
|---|---|---|
| Godot | Custom `Resource` with `@export` fields, saved as `data/tuning/<system>.tres` | In-game `CanvasLayer` with sliders, debug builds only |
| Unity | `ScriptableObject` asset per system under `Assets/Data/Tuning/` | Runtime debug UI or a custom inspector |
| Unreal | `UDataAsset` or a DataTable per system; config-backed settings for global values | Console variables or an editor utility widget |
| Web | `src/tuning/<system>.ts` exporting one frozen object, or `public/tuning.json` | lil-gui or Tweakpane, behind a `?debug` flag |

Rules: one owner file per system; no knob duplicated in code; tests import knob values rather than
repeating literals; the knobs table in the GDD is the source of truth and the file mirrors it.

## Build brief

The unit of work handed to a coding agent (and to `/gameforge:game-vibe-code`). One system, one
brief, one fresh session.

```markdown
#### Build brief -- SYS-003 Witness Interrogation
Goal: The player questions a witness by choosing an approach; matching the witness's affinity
reveals one hidden fact, mismatching lowers Trust.
Pillars: Discovery, Rhetoric, Consequence. Tier: T1.
Inputs: approach choice (sympathetic / aggressive / logical); witness data (affinity, facts, Trust).
Outputs: revealed fact event; Trust change persisted to the witness record.
Rules: GDD §5.3. Formulas: GDD §6 rows 3-4. Knobs: TRUST_PENALTY, TRUST_MAX, FACTS_PER_WITNESS.
Must pass: AC-003-1 (match reveals exactly one unrevealed fact), AC-003-2 (mismatch lowers Trust by
TRUST_PENALTY, floor 0), AC-003-3 (Trust persists across save/load).
Observability: state snapshot includes witness.trust and witness.revealed_facts.
Out of scope: dialogue writing, portraits, voice, any new approach type.
Done when: the check command passes, the three checks are green, and a short capture or
screenshot sequence of one interrogation is attached.
```

## Critique before build

Run these in order before any build brief goes to an agent. They implement the spec -> critique ->
build pattern.

```
1. Read design/gdd.md §4-§7 and design/pillars.md. Critique SYS-003 only: contradictions with
   the pillars, rules that cannot be implemented as written, numbers without knobs, missing edge
   cases. Do not write code.
2. For each issue, propose the smallest spec change. I will accept or reject each.
3. Rewrite the SYS-003 acceptance checks with thresholds and check types. Mark anything you had
   to assume as [ASSUMPTION].
4. Produce the build brief. Stop.
```

Building happens in a fresh session that reads only the brief, the referenced GDD sections and
the project's `CLAUDE.md`.

## Spec smells that make agents fail

| Smell | What the agent does | Fix |
|---|---|---|
| "Responsive", "snappy", "fair" with no number | Picks a value and moves on | Add a knob and a Manual check with a threshold |
| Rules split across sections with different numbers | Implements whichever it read last | One owner section; others link to it |
| "Similar to [existing game]" as the rule | Imitates, or declines a recreation | Write the rule itself; keep comparisons in §1 |
| No out-of-scope list | Adds adjacent features | Every brief lists what not to build |
| State only visible on screen | Cannot verify without screenshots | Add fields to the state snapshot |
| Randomness without a seed | Flaky tests, "works on my run" | Seed knob; deterministic stepping |
