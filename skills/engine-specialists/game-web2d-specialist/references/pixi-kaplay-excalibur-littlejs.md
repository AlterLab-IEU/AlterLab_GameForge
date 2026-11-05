# PixiJS 8, Kaplay 3001, Excalibur 0.32 and LittleJS 1.29

All snippets type-checked against `pixi.js@8.22.0`, `kaplay@3001.0.19`, `excalibur@0.32.0` and
`littlejsengine@1.29.1` with TypeScript 7.0.2 on 2026-11-05. Bundle sizes are GameForge
measurements of a minimal scene built with Vite 8.3.6 (minified / gzip).

## 1. PixiJS 8.22

**Profile:** a fast 2D renderer, not a game engine. Entry chunk 245 KB / 71 KB, with renderer
chunks loaded on demand (575 KB / 171 KB emitted in total). You add scenes, physics, input and
audio (`@pixi/sound` 6.0.2). React integration: `@pixi/react` 8.0.5 (React 19).

```ts
import { Application, Assets, Sprite, Container, type Texture } from 'pixi.js';

const STEP_MS = 1000 / 60;

export async function bootPixi(parent: HTMLElement) {
  const app = new Application();
  await app.init({                 // v8: async init; the constructor takes no options
    resizeTo: parent,
    background: '#1d1d28',
    antialias: false,
    preference: 'webgl',           // default since 8.1.6; 'webgpu' or an array (8.18+) to opt in
    resolution: Math.min(devicePixelRatio, 2),
    autoDensity: true,
  });
  parent.appendChild(app.canvas);  // v8: app.canvas (v7: app.view)

  const tex = await Assets.load<Texture>('assets/hero.png');
  tex.source.scaleMode = 'nearest'; // pixel art (v7: baseTexture.scaleMode)
  const world = new Container();
  const hero = new Sprite(tex);
  hero.anchor.set(0.5);
  world.addChild(hero);
  app.stage.addChild(world);

  let acc = 0;
  let vx = 120;
  app.ticker.add((ticker) => {      // v8: callback receives the Ticker
    acc += Math.min(ticker.deltaMS, 250);
    while (acc >= STEP_MS) {        // fixed-step simulation on a variable ticker
      hero.x += (vx * STEP_MS) / 1000;
      if (hero.x > app.screen.width || hero.x < 0) vx = -vx;
      acc -= STEP_MS;
    }
  });
  return app;
}
```

```ts
import { Graphics, Text, BitmapText, Assets, AnimatedSprite, type Spritesheet } from 'pixi.js';

export const box = new Graphics().rect(0, 0, 32, 32).fill(0xe05a47).stroke({ width: 2, color: 0xffffff });
export const label = new Text({ text: 'Score 0', style: { fontFamily: 'monospace', fontSize: 16, fill: 0xffffff } });
export const hud = (s: string) => new BitmapText({ text: s, style: { fontFamily: 'Pixel', fontSize: 8 } });

export async function hero() {
  const sheet = await Assets.load<Spritesheet>('assets/sprites.json'); // TexturePacker JSON
  const run = new AnimatedSprite(sheet.animations['hero_run']!);
  run.animationSpeed = 0.2;
  run.play();
  return run;
}
```

Recent PixiJS additions: WebGPU render bundles (8.20), HTML-in-Canvas textures (8.19), TS 7
support (8.21).

### PixiJS 7 -> 8

| v7 | v8 |
|---|---|
| `new Application({ width, height, ... })` (sync) | `const app = new Application(); await app.init({ ... })` |
| `app.view` | `app.canvas` |
| `PIXI.*` globals, `@pixi/*` sub-packages | Named imports from the single `pixi.js` package |
| `Loader.shared`, `Sprite.from(url)` before loading | `await Assets.load(url)` |
| `baseTexture.scaleMode = SCALE_MODES.NEAREST` | `texture.source.scaleMode = 'nearest'` |
| `graphics.beginFill(c).drawRect(...).endFill()` | `new Graphics().rect(...).fill(c)` |
| `new Text('hi', style)` | `new Text({ text: 'hi', style })` |
| `ticker.add((delta) => ...)` | `ticker.add((ticker) => ... ticker.deltaTime / ticker.deltaMS ...)` |
| WebGPU expected by default | WebGL is the default renderer; `preference: 'webgpu'` to opt in |

## 2. Kaplay 3001 (stable)

**Profile:** the maintained successor to Kaboom (frozen at 3000.1.17 since 2023). 188 KB / 68 KB.
Terse component API, quick to learn, good for jams and first games. The v4000 line is still
alpha (`4000.0.0-alpha.27.1`, 2026-05-12) even though the roadmap targeted Q1 2026: stay on 3001
unless you accept alpha churn. A Phaser-published comparison reports Kaplay slower and more
prone to agent hallucinations than Phaser; that is a vendor claim, but agents do mix Kaboom,
Kaplay 3001 and 4000 APIs, so pin the version and name it in prompts.

```ts
import kaplay from 'kaplay';

// global: false keeps the API on `k` instead of window: clearer for agents and bundlers
const k = kaplay({ width: 320, height: 180, letterbox: true, crisp: true, background: '#1d1d28', global: false });

k.loadSprite('hero', 'sprites/hero.png');
k.setGravity(1600);

k.scene('game', () => {
  const player = k.add([k.sprite('hero'), k.pos(80, 40), k.area(), k.body(), 'player']);
  k.add([k.rect(320, 16), k.pos(0, 164), k.area(), k.body({ isStatic: true }), k.color(59, 91, 122)]);
  k.onKeyPress('space', () => { if (player.isGrounded()) player.jump(480); });
  k.onKeyDown('right', () => player.move(140, 0));
  k.onKeyDown('left', () => player.move(-140, 0));
});

k.go('game');
```

- Fixed-rate logic: `k.onFixedUpdate(() => ...)` with `k.fixedDt()`; `onUpdate` runs per frame.
- Options worth knowing (3001 `KAPLAYOpt`): `letterbox`, `crisp`, `pixelDensity`, `texFilter`,
  `maxFPS`, `touchToMouse`, `buttons` (input bindings), `backgroundAudio`, `debugKey`.

### Kaboom -> Kaplay

| Kaboom | Kaplay 3001 |
|---|---|
| `import kaboom from 'kaboom'` | `import kaplay from 'kaplay'` |
| `kaboom({ ... })` with global functions | `const k = kaplay({ global: false, ... })`, call `k.add`, `k.pos`, ... |
| Tutorials from 2022-2023 | Check each API against the 3001 typings in `node_modules/kaplay/dist/doc.d.ts` |

## 3. Excalibur 0.32

**Profile:** TypeScript-first engine with an ECS core, scenes, actors, collision and a fixed
update option. 480 KB / 122 KB. BSD-2-Clause. Pre-1.0: read release notes on every minor bump
(0.33 is in alpha).

```ts
import { Engine, Actor, Color, vec, DisplayMode, Keys, CollisionType } from 'excalibur';

const game = new Engine({
  width: 480,
  height: 270,
  displayMode: DisplayMode.FitScreen,
  pixelArt: true,
  fixedUpdateFps: 60, // physics and update at a fixed rate, independent of refresh
  backgroundColor: Color.fromHex('#1d1d28'),
});

const player = new Actor({ pos: vec(80, 200), width: 12, height: 16, color: Color.Yellow, collisionType: CollisionType.Active });
player.on('preupdate', () => {
  const dir = Number(game.input.keyboard.isHeld(Keys.Right)) - Number(game.input.keyboard.isHeld(Keys.Left));
  player.vel.x = dir * 140;
});
game.add(player);
game.add(new Actor({ pos: vec(240, 262), width: 480, height: 16, color: Color.Gray, collisionType: CollisionType.Fixed }));
void game.start();
```

`fixedUpdateTimestep` takes precedence over `fixedUpdateFps` if both are set.

## 4. LittleJS 1.29.1

**Profile:** tiny engine (137 KB / 52 KB measured) with batched WebGL 2 rendering and a Canvas2D
fallback; tile-based sprites, particles, ZzFX sound effects, a Box2D plugin. Updates at a fixed 60 Hz by
design (`frameRate = 60`); `engineVariableStep` exists if you want per-frame updates.

```ts
import { engineInit, vec2, drawRect, keyIsDown, hsl, setCameraPos, type Vector2 } from 'littlejsengine';

let pos: Vector2;

function gameInit() { pos = vec2(0, 0); setCameraPos(vec2(0, 0)); }
function gameUpdate() { // fixed 60 Hz: per-update speeds, no delta math
  const dir = Number(keyIsDown('ArrowRight')) - Number(keyIsDown('ArrowLeft'));
  pos.x += dir * 0.1;
}
function gameUpdatePost() {}
function gameRender() { drawRect(pos, vec2(1, 1), hsl(0.12, 0.8, 0.6)); }
function gameRenderPost() {}

void engineInit(gameInit, gameUpdate, gameUpdatePost, gameRender, gameRenderPost);
```

Test-friendly settings: `setEngineManualStep(true)` before `engineInit`, then `engineStep(frames)`;
`setHeadlessMode(true)` for server or logic tests.

## 5. Choosing between them (summary)

| Need | Pick |
|---|---|
| Full engine, most examples, portal-ready defaults | Phaser 4 |
| Own architecture, maximum rendering control, React UI | PixiJS 8 |
| First game, teaching, 48-hour jam with beginners | Kaplay 3001 |
| TypeScript-heavy team that wants an ECS engine | Excalibur 0.32 |
| Byte budget (size-limited jams), retro arcade | LittleJS 1.29 |

Whatever the pick: one fixed-step simulation, one tuning file, atlases, a save wrapper, and the
Playwright contract in `testing-portal-readiness.md`.
