# Game-Side Test Hooks Reference

Read this when wiring a game for verification: the modules the game itself needs so the
Playwright harness in `verification-harness.md` can drive it, plus the Godot equivalent and the
determinism rules that keep checks stable. Code targets the versions pinned in
`stack-and-scaffold.md` (Vite 8 vanilla-ts template with its strict lint flags, `three@0.187.0`,
`phaser@4.2.1`, Godot 4.7). The three.js and Phaser entry files that use these modules are in
`stack-and-scaffold.md`.

## Core modules (`src/core/`)

### `testHooks.ts`

```ts
declare global {
  interface Window {
    render_game_to_text?: () => string;
    advanceTime?: (ms: number) => void;
  }
}

// Hooks, overlay and tuning panel exist only in dev and in test builds (`vite build --mode test`,
// with VITE_TEST_HOOKS=1 in .env.test). In a release build DEBUG_BUILD is the constant false,
// so the bundler drops that code.
export const DEBUG_BUILD = import.meta.env.DEV || import.meta.env.VITE_TEST_HOOKS === '1';
export const params = new URLSearchParams(window.location.search);
export const TEST_MODE = DEBUG_BUILD && params.has('test');
export const SEED = Number(params.get('seed') ?? Date.now()) >>> 0;

export interface TestHooks {
  renderGameToText: () => string;
  advanceTime: (ms: number) => void;
}

export function installTestHooks(hooks: TestHooks): void {
  if (!TEST_MODE) return;
  window.render_game_to_text = hooks.renderGameToText;
  window.advanceTime = hooks.advanceTime;
}
```

### `loop.ts`: fixed step, interpolation-ready, test-drivable

```ts
export const STEP_MS = 1000 / 60;

export interface Loop {
  frame: (now: number) => void;      // call from requestAnimationFrame or renderer.setAnimationLoop
  advanceTime: (ms: number) => void; // deterministic stepping for tests
}

export function createLoop(step: (dt: number) => void, render: (alpha: number) => void, manual: boolean): Loop {
  let acc = 0;
  let last: number | undefined;
  return {
    frame(now) {
      if (!manual) {
        acc += Math.min(now - (last ?? now), 250); // clamp long gaps (tab switches, breakpoints)
        while (acc >= STEP_MS) {
          step(STEP_MS / 1000);
          acc -= STEP_MS;
        }
      }
      last = now;
      render(manual ? 1 : acc / STEP_MS); // alpha in [0,1) for interpolating between steps
    },
    advanceTime(ms) {
      const n = Math.max(1, Math.round(ms / STEP_MS));
      for (let i = 0; i < n; i++) step(STEP_MS / 1000);
      render(1);
    },
  };
}
```

### `rng.ts`: seeded randomness (mulberry32)

```ts
export type Rng = () => number;

export function mulberry32(seed: number): Rng {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
```

Rule for `CLAUDE.md`: game code never calls `Math.random()`; it takes the `rng` it is given. Phaser
code may also use `Phaser.Math.RND`, which the game config seeds.

### `input.ts`: held keys plus "pressed since last step"

```ts
export interface InputSample { down: Set<string>; pressed: Set<string> }

export function createInput(target: Window) {
  const down = new Set<string>();
  const pressed = new Set<string>();
  target.addEventListener('keydown', (e) => {
    if (!e.repeat) pressed.add(e.code);
    down.add(e.code);
  });
  target.addEventListener('keyup', (e) => down.delete(e.code));
  target.addEventListener('blur', () => down.clear());
  return {
    sample(): InputSample {
      const s = { down: new Set(down), pressed: new Set(pressed) };
      pressed.clear();
      return s;
    },
  };
}
```

Buffering `pressed` means a tap that starts and ends between two steps still counts. Map key codes
to actions in one place (see `main.ts` in the scaffold reference) so remapping and touch controls
touch one file.

### `debugOverlay.ts`: toggled with the backquote key

```ts
import { SEED } from './testHooks';

export function createDebugOverlay(getText: () => string): () => void {
  const el = document.createElement('pre');
  el.style.cssText =
    'position:fixed;left:8px;top:8px;margin:0;padding:6px 8px;max-height:90vh;overflow:hidden;' +
    'font:12px/1.3 monospace;color:#cfe;background:rgba(0,0,0,.65);pointer-events:none;z-index:10';
  document.body.appendChild(el);
  let visible = true;
  window.addEventListener('keydown', (e) => {
    if (e.code !== 'Backquote') return;
    visible = !visible;
    el.style.display = visible ? 'block' : 'none';
  });
  let last = performance.now();
  let fps = 60;
  return () => {
    const now = performance.now();
    fps += (1000 / Math.max(1, now - last) - fps) * 0.1;
    last = now;
    if (visible) el.textContent = `fps ${fps.toFixed(0)}  seed ${SEED}\n${getText()}`;
  };
}
```

Show it in dev, and in test builds with `?debug=1`:
`import.meta.env.DEV || (DEBUG_BUILD && params.has('debug'))`. The overlay prints the same text
the tests read, so a human and the agent look at identical state. Release builds drop it, which
matters because portals such as Poki reject debug code, and the same rule keeps cheat surfaces out
of shipped web builds (`game-qa-lead` applies it to every engine).

### `tuningPanel.ts`: live feel tuning behind `?tune=1`

```ts
import { TUNING } from '../tuning';
import { DEBUG_BUILD } from './testHooks';

export function maybeInstallTuningPanel(enabled: boolean): void {
  if (!DEBUG_BUILD || !enabled) return; // constant check first, so release builds drop lil-gui
  void import('lil-gui').then(({ default: GUI }) => {
    const gui = new GUI({ title: 'Tuning: copy values into src/tuning.ts' });
    for (const [group, values] of Object.entries(TUNING)) {
      const folder = gui.addFolder(group);
      for (const key of Object.keys(values)) folder.add(values as Record<string, number>, key);
    }
    gui.add({ copy: () => navigator.clipboard.writeText(JSON.stringify(TUNING, null, 2)) }, 'copy').name('Copy JSON');
  });
}
```

Call `maybeInstallTuningPanel(import.meta.env.DEV || (DEBUG_BUILD && params.has('tune')))` from
`main.ts`. Release builds never load the panel. Vite 8.3 still writes an unreferenced lil-gui chunk
(about 30 KB) to `dist/assets/`; nothing imports it, and you can delete it before upload. Game code
must read `TUNING.x.y` at the moment it uses it, not copy it into a local at startup, or live edits
do nothing. Do not declare `TUNING` with `as const`; the panel mutates it.

## Godot headless smoke test

Headless Godot has no display, so there are no screenshots; the check is text state on stdout plus
a clean exit. Add this as an autoload named `TestHooks`, and put every node whose state matters in
a group called `snapshot` with a `snapshot() -> Dictionary` method.

```gdscript
# res://autoload/test_hooks.gd
# godot --headless --path . --fixed-fps 60 --quit-after 1200 -- --test --seed=42 --frames=300 --hold=move_right
extends Node

var test_mode := false
var _frames_left := 0
var _held := PackedStringArray()

func _ready() -> void:
	if not OS.is_debug_build():
		return  # release exports never honor test arguments
	for arg in OS.get_cmdline_user_args():
		if arg == "--test":
			test_mode = true
		elif arg.begins_with("--seed="):
			seed(int(arg.get_slice("=", 1)))
		elif arg.begins_with("--frames="):
			_frames_left = int(arg.get_slice("=", 1))
		elif arg.begins_with("--hold="):
			_held = arg.get_slice("=", 1).split(",")
	if test_mode:
		for action in _held:
			Input.action_press(action)

func _physics_process(_delta: float) -> void:
	if not test_mode:
		return
	_frames_left -= 1
	if _frames_left <= 0:
		print("STATE ", JSON.stringify(render_game_to_text()))
		get_tree().quit(0)

func render_game_to_text() -> Dictionary:
	var state := {
		"coords": "2D pixels: origin top-left, +x right, +y down",
		"physics_frame": Engine.get_physics_frames(),
	}
	for node in get_tree().get_nodes_in_group("snapshot"):
		if node.has_method("snapshot"):
			state[String(node.name)] = node.snapshot()
	return state
```

- `--fixed-fps 60` disables real-time sync, so each frame is exactly one 1/60 s step.
- `--quit-after 1200` is the safety net if the game never reaches its quit.
- Arguments after `--` are read with `OS.get_cmdline_user_args()`.
- Pass: exit code 0, a `STATE {...}` line whose values meet the feature's expectation, and no
  `SCRIPT ERROR` or `ERROR:` lines. Claude reads all three from the command output.
- For Godot web exports, the Playwright script still catches load failures and console errors.
  Exposing `render_game_to_text` to JavaScript goes through `JavaScriptBridge`; take that to
  `game-godot-specialist`.

## Determinism notes

- Fixed timestep with an accumulator; render interpolates with `alpha`. Test at more than one
  frame rate, and use continuous collision detection for fast bodies (general physics advice, not
  agent-specific).
- No real time inside rules: no `performance.now()`, `Date.now()`, `setTimeout` or CSS animation
  driving gameplay. Phaser tweens and timers run on the game clock, which `game.step()` advances.
- Battle Drones' replays desynced because Chrome and Safari return different `Math.sin` and
  `Math.cos` results; custom functions fixed it. That matters for lockstep multiplayer and replays,
  not for single-player tests on one browser.
- Rapier is the deterministic choice when physics must replay identically.
