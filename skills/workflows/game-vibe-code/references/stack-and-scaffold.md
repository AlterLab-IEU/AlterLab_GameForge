# Stack and Scaffold Reference

Read this before scaffolding a vibe-coded game. Versions were checked against the npm registry on
5 Nov 2026; engine facts come from the GameForge web-stack and AI-tooling research briefs (see the
Sources list in `docs/vibe-coding.md`). Pin exact versions in `package.json` so every session, and
every agent, builds against the same APIs.

## Pinned versions (as of 5 Nov 2026)

| Package or tool | Pin | Released | Notes |
|---|---|---|---|
| `three` | `0.187.0` (r187) | 2026-10-30 | ESM only; the `.min.js` builds are gone and `three.cjs` is a deprecation stub |
| `@types/three` | `0.187.0` | 2026-10-30 | Matches r187 |
| `vite` | `8.3.6` | 2026-11-05 | Vite 8 (2026-03-12) bundles with Rolldown only; needs Node 20.19+ or 22.12+ |
| `create-vite` | `9.3.4` | 2026-11-05 | Supports `--no-interactive` and `--no-immediate` (agents cannot answer prompts) |
| `phaser` | `4.2.1` | 2026-07-09 | MIT; `import Phaser from 'phaser'` works since 4.1 |
| `@dimforge/rapier3d-compat` | `0.21.0` | 2026-09-25 | About 3 MB of WASM; add only when you need real 3D physics |
| `@dimforge/rapier2d-compat` | `0.21.0` | 2026-09-25 | 2D option when Arcade physics is not enough |
| `playwright` | `1.64.1` | 2026-10-14 | Verification harness; Apache-2.0 |
| `lil-gui` | `0.21.0` | 2025-10-12 | Dev-only tuning panel |
| `@react-three/fiber` | `9.8.2` | 2026-10-14 | Only if the user lives in React; v10 is alpha, do not ship it |
| Godot | 4.7.2 stable | 2026-08-18 | 4.8 is in beta (beta 2 on 2026-10-29); its .NET build needs .NET 10 |

Alternatives worth naming: LittleJS 1.29.1 for tiny, size-capped builds; Kaplay 3001.0.19 for
beginners (avoid the v4000 alpha); PixiJS 8.22.0 when you want a renderer, not a framework.

## Choosing between them

| Signal from the user | Pick |
|---|---|
| "3D", "first person", "flying", "racing", jam that recommends Three.js | Three.js + Vite |
| "2D", "pixel art", "platformer", "arcade", portal-first | Phaser 4 + Vite |
| "Steam", "console later", "I want an editor", C# background | Godot 4.7 (route depth to `game-godot-specialist`) |
| "Already in Unity or Unreal" | Keep it; this loop works with their MCP integrations (see `docs/mcp-integrations.md` in the plugin) |
| Tiny size cap or a 13 KB-style challenge | LittleJS |

## Scaffold: 3D web (Three.js)

Run from an empty folder (a folder containing only `.git` counts as empty for create-vite). Never
pass `--overwrite`; it deletes existing files.

```bash
npm create vite@9.3.4 . -- --template vanilla-ts --no-interactive --no-immediate
npm install three@0.187.0 lil-gui@0.21.0
npm install -D @types/three@0.187.0 playwright@1.64.1
npx playwright install chromium
```

Delete the template's demo files (`src/counter.ts`, `src/assets/`, everything in `src/main.ts`),
keep `index.html` with its `<div id="app"></div>`, and replace `src/style.css` with
`html, body { margin: 0; height: 100%; overflow: hidden; background: #000; }` (import it from
`main.ts`). Then add the scripts and config below.

## Scaffold: 2D web (Phaser 4)

```bash
npm create vite@9.3.4 . -- --template vanilla-ts --no-interactive --no-immediate
npm install phaser@4.2.1 lil-gui@0.21.0
npm install -D playwright@1.64.1
npx playwright install chromium
```

Do the same template cleanup as for Three.js; Phaser's `parent: 'app'` mounts into the template's
`<div id="app"></div>`.

## `package.json` scripts (both web stacks)

The vanilla-ts template already sets `"type": "module"` and `"build": "tsc && vite build"`, so the
build doubles as a typecheck.

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "build:test": "tsc && vite build --mode test",
    "preview": "vite preview",
    "verify": "npm run build:test && node tests/e2e/verify.mjs",
    "debt": "node tests/structure.mjs",
    "budget": "node tests/budget.mjs",
    "licenses": "node tests/licenses.mjs"
  }
}
```

Create `.env.test` containing the single line `VITE_TEST_HOOKS=1`. `npm run verify` builds in test
mode, so the test hooks, debug overlay and tuning panel are compiled in; `npm run build` makes the
release bundle without them. Upload only release builds, and run `npm run build` before
`npm run budget` so the budget measures what players download.

`npm run verify -- dash` appends `dash` to the script, so the harness runs only matching
scenarios. `verify.mjs` lives in the verification reference; `structure.mjs`, `budget.mjs` and
`licenses.mjs` live in the vibe-debt reference.

## `vite.config.ts`

```ts
import { defineConfig } from 'vite';

export default defineConfig({
  base: './', // relative asset URLs: works on itch.io, portals and any subpath
});
```

## Project layout

```
.
├── CLAUDE.md                 # commands first, rules, gotchas (template in SKILL.md)
├── progress.md               # handoff file; first line "Original prompt: ..."
├── design/vibe-spec.md       # one-page spec
├── docs/iteration-log.md     # append-only log; doubles as the AI-use record
├── design/ai-asset-log.md    # provenance for every shipped asset (GameForge template)
├── .env.test                 # VITE_TEST_HOOKS=1 (test builds only)
├── index.html
├── public/                   # static assets copied as-is (public/lazy/ = loaded after start)
├── src/
│   ├── main.ts               # wiring only: renderer, loop, hooks
│   ├── tuning.ts             # every feel number
│   ├── core/                 # loop.ts, input.ts, rng.ts, testHooks.ts, debugOverlay.ts, tuningPanel.ts
│   ├── game/                 # pure rules on plain data: no DOM, no three/phaser imports
│   ├── render/               # turns state into meshes/sprites; never writes game state
│   ├── ui/                   # menus, HUD
│   └── net/                  # only if online; server code lives in server/
└── tests/
    ├── e2e/verify.mjs
    ├── e2e/scenarios/*.json
    ├── structure.mjs
    ├── budget.mjs
    └── licenses.mjs
```

Add `tests/e2e/out/` to `.gitignore`; screenshots are evidence for the session, not history.

## Entry file: Three.js (`src/main.ts`)

Uses the core modules from `game-test-hooks.md`. The rules live in `src/game/world.ts`, so the
renderer only reads state.

```ts
import * as THREE from 'three';
import { createLoop } from './core/loop';
import { createInput } from './core/input';
import { mulberry32 } from './core/rng';
import { DEBUG_BUILD, installTestHooks, params, SEED, TEST_MODE } from './core/testHooks';
import { createDebugOverlay } from './core/debugOverlay';
import { maybeInstallTuningPanel } from './core/tuningPanel';
import { createWorld, snapshot, stepWorld, type InputState } from './game/world';

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
document.querySelector('#app')!.appendChild(renderer.domElement);

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x101018);
scene.add(new THREE.HemisphereLight(0xffffff, 0x223344, 2));
const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);
camera.position.set(0, 8, 10);
camera.lookAt(0, 0, -5);

const rng = mulberry32(SEED);
const world = createWorld(rng);
const player = new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1), new THREE.MeshStandardMaterial({ color: 0x7fd1ff }));
scene.add(player);
const hazardGeo = new THREE.SphereGeometry(0.5, 16, 12);
const hazardMat = new THREE.MeshStandardMaterial({ color: 0xff6040 });
const hazardMeshes = world.hazards.map(() => {
  const m = new THREE.Mesh(hazardGeo, hazardMat);
  scene.add(m);
  return m;
});

const keys = createInput(window);
const readInput = (): InputState => {
  const k = keys.sample();
  return {
    left: k.down.has('ArrowLeft') || k.down.has('KeyA'),
    right: k.down.has('ArrowRight') || k.down.has('KeyD'),
    up: k.down.has('ArrowUp') || k.down.has('KeyW'),
    down: k.down.has('ArrowDown') || k.down.has('KeyS'),
    restart: k.pressed.has('KeyR'),
  };
};

const overlay = import.meta.env.DEV || (DEBUG_BUILD && params.has('debug'))
  ? createDebugOverlay(() => JSON.stringify(snapshot(world), null, 1))
  : null;
maybeInstallTuningPanel(import.meta.env.DEV || (DEBUG_BUILD && params.has('tune')));

function render(): void {
  player.position.set(world.player.x, 0.5, world.player.z);
  world.hazards.forEach((h, i) => hazardMeshes[i].position.set(h.x, 0.5, h.z));
  renderer.render(scene, camera);
  overlay?.();
}

const loop = createLoop((dt) => stepWorld(world, readInput(), dt, rng), render, TEST_MODE);
renderer.setAnimationLoop((now) => loop.frame(now));
installTestHooks({ renderGameToText: () => JSON.stringify(snapshot(world)), advanceTime: loop.advanceTime });

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});
```

## Pure rules: `src/game/world.ts`

```ts
import { TUNING } from '../tuning';
import type { Rng } from '../core/rng';

export interface InputState { left: boolean; right: boolean; up: boolean; down: boolean; restart: boolean }
export interface Vec2 { x: number; z: number }
export interface World { mode: 'playing' | 'lost'; time: number; score: number; player: Vec2; hazards: Vec2[] }

const spawn = (rng: Rng): Vec2 => ({ x: (rng() - 0.5) * 16, z: -20 - rng() * 20 });

export function createWorld(rng: Rng): World {
  return { mode: 'playing', time: 0, score: 0, player: { x: 0, z: 0 }, hazards: Array.from({ length: 5 }, () => spawn(rng)) };
}

export function stepWorld(w: World, input: InputState, dt: number, rng: Rng): void {
  if (w.mode === 'lost') {
    if (input.restart) Object.assign(w, createWorld(rng));
    return;
  }
  const s = TUNING.player.moveSpeed * dt;
  w.player.x += (Number(input.right) - Number(input.left)) * s;
  w.player.z += (Number(input.down) - Number(input.up)) * s;
  w.time += dt;
  for (const h of w.hazards) {
    h.z += TUNING.hazards.speed * dt;
    if (h.z > 5) { Object.assign(h, spawn(rng)); w.score += 1; }
    if (Math.abs(h.x - w.player.x) < 0.9 && Math.abs(h.z - w.player.z) < 0.9) w.mode = 'lost';
  }
}

const r2 = (n: number) => Math.round(n * 100) / 100;

export function snapshot(w: World) {
  return {
    coords: '3D world units: +x right, +z toward camera, y up; everything on y=0',
    mode: w.mode, time: r2(w.time), score: w.score,
    player: { x: r2(w.player.x), z: r2(w.player.z) },
    hazards: w.hazards.map((h) => ({ x: r2(h.x), z: r2(h.z) })),
  };
}
```

`src/tuning.ts` for this example: `export const TUNING = { player: { moveSpeed: 6 }, hazards: { speed: 9 } };`

## Entry file: Phaser 4 (`src/main.ts`)

Phaser owns its loop. In test mode, let the first real frame boot the scene, then put the loop to
sleep and drive `game.step()` from `advanceTime`. `READY` fires before the loop starts, so sleeping
inside a `READY` handler does nothing; use the first `POST_RENDER` instead.

```ts
import Phaser from 'phaser';
import { PlayScene } from './scenes/PlayScene';
import { installTestHooks, SEED, TEST_MODE } from './core/testHooks';
import { STEP_MS } from './core/loop';

const game = new Phaser.Game({
  type: Phaser.WEBGL, // the Canvas renderer is deprecated in Phaser 4
  parent: 'app',
  width: 960,
  height: 540,
  backgroundColor: '#14141c',
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  physics: { default: 'arcade', arcade: { gravity: { x: 0, y: 900 } } },
  seed: [String(SEED)], // seeds Phaser.Math.RND
  scene: [PlayScene],
});

game.events.once(Phaser.Core.Events.POST_RENDER, () => {
  if (TEST_MODE) game.loop.sleep(); // from here on, tests own the clock
  let t = performance.now();
  installTestHooks({
    renderGameToText: () => JSON.stringify((game.scene.getScene('play') as PlayScene).snapshot()),
    advanceTime: (ms) => {
      const n = Math.max(1, Math.round(ms / STEP_MS));
      for (let i = 0; i < n; i++) {
        t += STEP_MS;
        game.step(t, STEP_MS);
      }
    },
  });
});
```

## Phaser scene with a snapshot: `src/scenes/PlayScene.ts`

```ts
import Phaser from 'phaser';
import { TUNING } from '../tuning';

export class PlayScene extends Phaser.Scene {
  private player!: Phaser.GameObjects.Rectangle;
  private playerBody!: Phaser.Physics.Arcade.Body;
  private keys!: Record<'left' | 'right' | 'jump' | 'restart', Phaser.Input.Keyboard.Key>;
  private mode: 'playing' | 'lost' = 'playing';

  constructor() {
    super('play');
  }

  create(): void {
    this.mode = 'playing';
    const floor = this.add.rectangle(350, 520, 700, 40, 0x334455); // gap after x=700 is the fail state
    this.physics.add.existing(floor, true);
    this.player = this.add.rectangle(120, 400, 24, 32, 0x7fd1ff);
    this.physics.add.existing(this.player);
    this.playerBody = this.player.body as Phaser.Physics.Arcade.Body;
    this.physics.add.collider(this.player, floor);
    const kb = this.input.keyboard!;
    this.keys = { left: kb.addKey('LEFT'), right: kb.addKey('RIGHT'), jump: kb.addKey('SPACE'), restart: kb.addKey('R') };
  }

  update(): void {
    if (this.mode === 'lost') {
      if (Phaser.Input.Keyboard.JustDown(this.keys.restart)) this.scene.restart();
      return;
    }
    const b = this.playerBody;
    b.setVelocityX((Number(this.keys.right.isDown) - Number(this.keys.left.isDown)) * TUNING.player.moveSpeed);
    if (Phaser.Input.Keyboard.JustDown(this.keys.jump) && b.blocked.down) b.setVelocityY(-TUNING.player.jumpVelocity);
    if (this.player.y > 600) this.mode = 'lost';
  }

  snapshot() {
    if (!this.playerBody) return { mode: 'booting' };
    const b = this.playerBody;
    return {
      coords: '2D pixels: origin top-left, +x right, +y down',
      mode: this.mode,
      player: { x: Math.round(this.player.x), y: Math.round(this.player.y), vx: Math.round(b.velocity.x), vy: Math.round(b.velocity.y), onGround: b.blocked.down },
    };
  }
}
```

`src/tuning.ts` for this example: `export const TUNING = { player: { moveSpeed: 220, jumpVelocity: 480 } };`
These are starting points to tune by playing, not recommendations.

The template's `tsconfig.json` enables `verbatimModuleSyntax`, `noUnusedLocals`,
`noUnusedParameters` and `erasableSyntaxOnly`. Tell Claude: use `import type` for types, prefix
unused parameters with `_`, and avoid `enum`, namespaces and constructor parameter properties.

## Godot 4.7 path

- The user creates the project in the Godot Project Manager (4.7.2 stable), or Claude writes the
  plain-text `project.godot`, `.tscn` and `.gd` files directly. Deep scene and node work goes to
  `game-godot-specialist`.
- Layout: `project.godot`, `scenes/`, `scripts/`, `autoload/test_hooks.gd`, `autoload/tuning.gd`,
  `tests/`. Never edit `.godot/` or `*.uid` files (GameForge's hooks block it).
- Headless commands (pre-approved in this skill as `godot --headless *`):
  - First run on a fresh checkout: `godot --headless --path . --import`
  - Smoke test: `godot --headless --path . --fixed-fps 60 --quit-after 1200 -- --test --seed=42 --frames=300`
- Web export: Compatibility renderer (WebGL 2) only; C# projects cannot export to the web; threads
  need cross-origin isolation (COOP/COEP) or the PWA workaround. Packaging goes to `game-web-publish`.
- Agents: Godot has no official MCP server or `llms.txt`. The main community server is
  Coding-Solo/godot-mcp (`claude mcp add godot -- npx @coding-solo/godot-mcp`), which runs the project
  and reads debug output. The Godot Foundation's 2026-06-30 ban on AI-authored PRs covers engine
  contributions only, not games made with Godot.

Godot `CLAUDE.md` commands block:

```markdown
# Commands
- Import (fresh checkout): godot --headless --path . --import
- Check after every change: godot --headless --path . --fixed-fps 60 --quit-after 1200 -- --test --seed=42 --frames=300
  (exit 0 and a STATE line = pass; any "SCRIPT ERROR" or "ERROR:" line = fail)
- The human runs the game from the editor for feel checks.
```

## Patterns to refuse (outdated code agents still write)

| Do not write | Write instead |
|---|---|
| `three.min.js` from a CDN, `require('three')` | ESM imports from `three@0.187.0` (or an import map pinned to that exact version) |
| `new THREE.Clock()` | `THREE.Timer` (Clock is deprecated since r183) or the timestamp from `setAnimationLoop` |
| `PostProcessing` with WebGPU | `RenderPipeline` (renamed in r183) |
| `renderAsync()`, `computeAsync()`, `waitForGPU()` | `await renderer.init()`, then `render()` / `compute()` |
| `PCFSoftShadowMap` | `PCFShadowMap` (now soft on WebGL) |
| pmndrs `postprocessing` or `EffectComposer` with `WebGPURenderer` | WebGL renderer for those, or TSL `RenderPipeline` nodes |
| Phaser 3 `setPipeline('Light2D')`, `preFX`/`postFX`, `BitmapMask`, `setTintFill`, `Geom.Point` | `setLighting(true)`, Filters, the Mask filter, `setTintMode`, `Vector2` |
| PixiJS v7 `new Application({...})` | `const app = new Application(); await app.init({...})` |
| `colyseus.js`, `kaboom`, `cannon-es` | `@colyseus/sdk`, `kaplay`, Rapier or Jolt |
| R3F v10 alpha APIs in a shipping game | R3F 9.8 |

Put the two or three rows relevant to the chosen stack in the project's `CLAUDE.md` under
"Gotchas"; that is where an agent will see them.
