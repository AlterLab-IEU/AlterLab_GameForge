# Agent-Built Prototypes

How to get a coding agent to build a throwaway that answers the question in `QUESTION.md`, and
nothing more. The patterns come from Anthropic's Claude Code best-practice docs ("give Claude
something it can run that comes back pass or fail"), OpenAI's published `develop-web-game` skill
(`render_game_to_text`, `advanceTime`, Playwright screenshots as the source of truth), and
practitioner write-ups from 2026 (Simon Willison's *Battle Drones*; the Vibe Jam 2026 Gold winner).

---

## 1. Kickoff prompt

```
Read prototypes/<name>/QUESTION.md. Build the smallest playable thing that tests that hypothesis.

Constraints:
- Everything in prototypes/<name>/. Do not import from or modify src/.
- One file is fine. No architecture. Hardcoded values are fine.
- Primitives only (rectangles, circles, capsules). No asset loading unless QUESTION.md needs it.
- Put every tuning number in one TUNING object and show a live debug panel to edit it.
- R restarts in under a second. ?seed=<n> makes runs reproducible.
- Fixed-step simulation: step(dt) at 60 Hz, render separately.
- Expose window.render_game_to_text() and window.advanceTime(ms) (spec below).
- Write one Playwright test that plays the core action and saves a screenshot.

Stop when the test passes. Then tell me: what you built, the TUNING defaults, and everything
in QUESTION.md's "Out of scope" you deliberately did not build.
```

Follow-ups that keep it honest:

```
Run the test again and show me the output and the screenshot path. Do not say it works
without the output.

List three ways this prototype could give a misleading answer to the hypothesis.

Variant B: copy the folder to prototypes/<name>-b and change only <design variable>. Same
TUNING names, same hooks, same restart key. Show me the diff.
```

## 2. Minimal scaffolds

Pick the stack the eventual game will use, unless the question is pure feel and a web throwaway is
faster. Versions as of November 2026.

| Stack | Scaffold | Run | Check |
|---|---|---|---|
| Three.js (3D web) | `npm create vite@latest <name> -- --template vanilla`, then `npm install three@0.187.0` | `npm run dev` | `npx playwright test` |
| Phaser 4 (2D web) | `npm create vite@latest <name> -- --template vanilla`, then `npm install phaser@4` | `npm run dev` | `npx playwright test` |
| No build step | One `index.html` with an import map pinned to an exact version (`three@0.187.0`) | Any static server | Playwright against the static server |
| Godot 4.7 | New project in `prototypes/<name>/`, one scene, one script | Editor F5 | `godot --headless --path prototypes/<name> --quit-after 600` as a smoke run; check the output for `SCRIPT ERROR` lines rather than trusting the exit code |
| Unity 6.3 LTS | One scene in a scratch project (never inside the production project's `Assets/`) | Play mode | Edit-mode test in batch mode if the question is about logic |
| Unreal 5.8 | Blueprint-only scratch project | PIE | Manual; Unreal is rarely the cheapest prototype stack |

Phaser 4 notes for agents: the Canvas renderer is deprecated (use WebGL); `preFX`/`postFX` became
Filters; `setTintFill` became `setTintMode`. Three.js notes: `Clock` is deprecated in favor of
`Timer`; use `WebGLRenderer` unless the question needs WebGPU features.

## 3. Test hooks (web)

Deterministic stepping is what lets an agent verify its own work. Without `advanceTime`, automated
checks are flaky.

```js
// TUNING: every number a tester might want to change, in one place.
export const TUNING = { runSpeed: 6.0, dashSpeed: 18.0, dashTime: 0.18, dashCooldown: 0.6, gravity: 30 };

const FIXED_DT = 1 / 60;
const params = new URLSearchParams(location.search);
const TEST_MODE = params.has('test');           // pauses the real-time loop for automated tests
let state = createState(Number(params.get('seed') ?? 1));

function step(dt) { /* read input flags, update state.player, state.enemies, state.score ... */ }
function render() { /* draw state; never mutate it here */ }

// Real-time loop with an accumulator; disabled in test mode.
let acc = 0, last = performance.now();
function frame(now) {
  acc += Math.min((now - last) / 1000, 0.25); last = now;
  while (acc >= FIXED_DT) { step(FIXED_DT); acc -= FIXED_DT; }
  render();
  if (!TEST_MODE) requestAnimationFrame(frame);
}
if (!TEST_MODE) requestAnimationFrame(frame);

// Hooks for agents and Playwright. Keep them out of any public build.
window.advanceTime = (ms) => {
  for (let t = 0; t < ms; t += FIXED_DT * 1000) step(FIXED_DT);
  render();
};
window.render_game_to_text = () => JSON.stringify({
  t: state.time,
  player: { x: +state.player.x.toFixed(2), y: +state.player.y.toFixed(2), dashing: state.player.dashing },
  enemies: state.enemies.length,
  score: state.score,
  phase: state.phase,            // "playing" | "won" | "lost"
});

addEventListener('keydown', (e) => { if (e.key === 'r') state = createState(state.seed); });
```

Playwright check:

```js
// tests/proto.spec.js
import { test, expect } from '@playwright/test';

test('dash clears the gap', async ({ page }) => {
  await page.goto('/?test=1&seed=1');
  await page.keyboard.down('ArrowRight');
  await page.evaluate(() => window.advanceTime(500));
  await page.keyboard.press('Shift');
  await page.evaluate(() => window.advanceTime(400));
  const s = JSON.parse(await page.evaluate(() => window.render_game_to_text()));
  expect(s.phase).toBe('playing');
  expect(s.player.x).toBeGreaterThan(8);
  await page.screenshot({ path: 'shots/dash.png' });
});
```

Treat the screenshot as the source of truth: open it. A passing assertion with a black screenshot is
a failing prototype.

## 4. Debug panel

- Web: `lil-gui` (0.21) bound to `TUNING`; add a "copy values" button so the tested values go into
  the report.
- Godot: `@export` variables on one node, edited live through the remote scene tree while the game
  runs.
- Unity: `[SerializeField]` fields on one MonoBehaviour, edited in the Inspector during play mode
  (remember they reset when play mode ends; copy the values out).

## 5. Headless simulation for systems questions

For "is the economy too generous?" or "does strategy X dominate?", a simulation answers faster than
a playtest.

```
Write prototypes/<name>/sim.js: a headless version of the rules with no rendering.
Implement three bot policies: greedy, cautious, random. Run 500 seeded runs per policy.
Output a table: win rate, median run length, resource at end (p10/p50/p90), and the most
common winning build. Print the seeds of the five most extreme runs so I can replay them.
```

Read the bot code before trusting the table: a bot that never uses a mechanic makes that mechanic
look useless. Replay a few extreme seeds by hand.

## 6. Placeholder assets

| Need | Fastest option | Notes |
|---|---|---|
| Shapes, characters | Primitives, colored rectangles | Best default: no provenance to track |
| Sprites, tiles | CC0 packs (for example Kenney) or a generator | Log generator output in `AI-USE.md` |
| Sound effects | jsfxr-style synthesizers, CC0 libraries, or a generator | Same |
| Music | Silence, or one CC0 loop | Music is rarely the question; treat AI music services whose legal status is unsettled (Suno, Udio) as placeholder-only |
| Voice | Text on screen | Generated voice clones of real people: never, even as placeholders |

Every generated asset gets a row in `AI-USE.md` with status `placeholder`. When the project needs
real assets, `/gameforge:game-ai-assets` runs the production pipeline and provenance log.

## 7. When the agent struggles

| Symptom | Likely cause | Move |
|---|---|---|
| Ten prompts in, still not playable | Scope too big or wrong stack | Cut Must items; switch to a web throwaway |
| Each fix breaks something else | Agent patching over a regression | Revert to the last passing commit, re-prompt one change |
| Tests pass, game feels wrong | The check tests the wrong thing | Write the feel criteria as observable behavior; then playtest |
| Physics differs run to run | Variable timestep or unseeded randomness | Fixed step, seed everything |
| The prototype keeps growing features | Nobody is enforcing the question | Re-read QUESTION.md aloud; new idea = new prototype |
