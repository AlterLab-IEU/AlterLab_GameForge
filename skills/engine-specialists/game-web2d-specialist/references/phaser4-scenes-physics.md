# Phaser 4 Scenes, Objects and Physics

Every block below was type-checked against `phaser@4.2.1` with TypeScript 7.0.2 (`strict`,
`noUncheckedIndexedAccess`). The Boot/Game/Hud flow, the pooled enemy state machine and the test
hooks also ran under Playwright 1.64.1 in headless Chromium with deterministic stepping.

## 1. Tuning and saves first

```ts
// src/tuning.ts -- every gameplay number in one place; balance commits touch only this file
export const TUNING = {
  view: { width: 480, height: 270 }, // 16:9 base resolution, scaled with FIT
  player: { runSpeed: 140, jumpVelocity: -330, coyoteMs: 100, jumpBufferMs: 120 },
  world: { gravityY: 900 },
  enemy: { patrolSpeed: 40, chaseSpeed: 70, aggroRange: 80, stunMs: 600 },
};
```

The versioned save wrapper is in `phaser4-content-pipeline.md`.

## 2. Boot: placeholder art so the game runs before assets exist

```ts
import Phaser from 'phaser';

export class Boot extends Phaser.Scene {
  constructor() { super('Boot'); }

  create(): void {
    const g = this.make.graphics({}, false);
    g.fillStyle(0xf2c14e).fillRect(0, 0, 12, 16).generateTexture('player', 12, 16).clear();
    g.fillStyle(0x3b5b7a).fillRect(0, 0, 16, 16).generateTexture('tile', 16, 16).clear();
    g.fillStyle(0xe05a47).fillRect(0, 0, 14, 10).generateTexture('enemy', 14, 10).destroy();
    this.registry.set('score', 0);
    this.scene.start('Game'); // real projects: start('Preload')
  }
}
```

`Graphics#generateTexture` replaces v3's removed `Create.GenerateTexture`/`TextureManager.generate`.
Placeholder shapes let an agent build and test every mechanic before any art exists.

## 3. Game scene with platformer feel (verified)

```ts
import Phaser from 'phaser';
import { TUNING } from '../tuning';

export class Game extends Phaser.Scene {
  player!: Phaser.Types.Physics.Arcade.SpriteWithDynamicBody;
  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private keys!: Record<'A' | 'D' | 'W' | 'SPACE', Phaser.Input.Keyboard.Key>;
  private lastGroundedAt = 0;
  private jumpPressedAt = -Infinity;

  constructor() { super('Game'); }

  create(): void {
    const { width, height } = TUNING.view;
    const ground = this.physics.add.staticGroup();
    for (let x = 0; x < width; x += 16) ground.create(x + 8, height - 8, 'tile');
    for (let x = 160; x < 260; x += 16) ground.create(x + 8, height - 72, 'tile');

    this.player = this.physics.add.sprite(40, height - 40, 'player');
    this.player.setCollideWorldBounds(true);
    this.physics.add.collider(this.player, ground);

    const enemies = this.physics.add.group({ allowGravity: false, immovable: true });
    const e = enemies.create(300, height - 21, 'enemy') as Phaser.Types.Physics.Arcade.SpriteWithDynamicBody;
    e.setVelocityX(-TUNING.enemy.patrolSpeed);
    this.physics.add.overlap(this.player, enemies, () => this.scene.restart());

    this.player.enableFilters();                                         // Phaser 4 Filters
    this.player.filters!.internal.addGlow(0xffffff, 2);
    this.cameras.main.filters.external.addVignette(0.5, 0.5, 0.9, 0.3);  // x, y, radius, strength

    const kb = this.input.keyboard!;
    this.cursors = kb.createCursorKeys();
    this.keys = kb.addKeys('A,D,W,SPACE') as typeof this.keys;
    this.scene.launch('Hud'); // parallel UI scene: unaffected by camera zoom/shake
  }

  update(time: number): void {
    const left = this.cursors.left.isDown || this.keys.A.isDown;
    const right = this.cursors.right.isDown || this.keys.D.isDown;
    const jumpJustDown =
      Phaser.Input.Keyboard.JustDown(this.cursors.up) ||
      Phaser.Input.Keyboard.JustDown(this.keys.W) ||
      Phaser.Input.Keyboard.JustDown(this.keys.SPACE);

    const p = TUNING.player;
    this.player.setVelocityX((Number(right) - Number(left)) * p.runSpeed);
    if (this.player.body.blocked.down) this.lastGroundedAt = time;
    if (jumpJustDown) this.jumpPressedAt = time;
    const canCoyote = time - this.lastGroundedAt <= p.coyoteMs;   // late jump off a ledge
    const buffered = time - this.jumpPressedAt <= p.jumpBufferMs; // early press before landing
    if (canCoyote && buffered) {
      this.player.setVelocityY(p.jumpVelocity);
      this.jumpPressedAt = -Infinity;
      this.lastGroundedAt = -Infinity;
    }
  }
}
```

The Vignette defaults (radius 0.5, strength 0.5) darken a 480x270 scene heavily; pass explicit
values. Variable jump height: when the jump key is released while `velocity.y < 0`, multiply
`velocity.y` by ~0.5 (a tuning value).

## 4. HUD through the registry, not scene references (verified)

```ts
import Phaser from 'phaser';

export class Hud extends Phaser.Scene {
  constructor() { super('Hud'); }

  create(): void {
    const label = this.add.text(4, 4, `Score ${this.registry.get('score') ?? 0}`,
      { fontFamily: 'monospace', fontSize: '10px', color: '#ffffff' }).setResolution(2);
    const onScore = (_parent: unknown, value: number) => label.setText(`Score ${value}`);
    this.registry.events.on('changedata-score', onScore);
    this.events.once(Phaser.Scenes.Events.SHUTDOWN, () => this.registry.events.off('changedata-score', onScore));
  }
}

// anywhere in Game: this.registry.inc('score', 10);
```

## 5. Scene flow helpers (verified)

```ts
/** Fade between scenes; input off so a double tap cannot start two transitions. */
export function fadeTo(scene: Phaser.Scene, key: string, data?: object): void {
  scene.input.enabled = false;
  scene.cameras.main.fadeOut(250, 0, 0, 0);
  scene.cameras.main.once(Phaser.Cameras.Scene2D.Events.FADE_OUT_COMPLETE, () => scene.scene.start(key, data));
}

/** Pause: freeze the simulation scene, launch a UI scene on top. */
export function pauseGame(scene: Phaser.Scene): void {
  scene.scene.pause('Game');
  scene.sound.pauseAll();
  scene.scene.launch('Pause');
}
export function resumeGame(scene: Phaser.Scene): void {
  scene.scene.stop('Pause');
  scene.sound.resumeAll();
  scene.scene.resume('Game');
}
```

Data in: `this.scene.start('Game', { level: 2 })` then `init(data: { level: number })`. Pause on
`document.visibilitychange` and on portal ad callbacks with the same two functions.

## 6. Object pools (verified)

```ts
export class Bullet extends Phaser.Physics.Arcade.Sprite {
  private lifeMs = 0;

  fire(x: number, y: number, vx: number): void {
    this.enableBody(true, x, y, true, true); // reset, activate, show
    this.setVelocity(vx, 0);
    (this.body as Phaser.Physics.Arcade.Body).allowGravity = false;
    this.lifeMs = 1200;
  }

  override preUpdate(time: number, delta: number): void {
    super.preUpdate(time, delta);
    this.lifeMs -= delta;
    if (this.lifeMs <= 0) this.disableBody(true, true); // back to the pool
  }
}

export function createBulletPool(scene: Phaser.Scene) {
  // get() reuses an inactive member or returns null when all 64 are in flight
  const pool = scene.physics.add.group({ classType: Bullet, maxSize: 64, runChildUpdate: false, defaultKey: 'bullet' });
  return { pool, fire(x: number, y: number, vx: number) { (pool.get(x, y) as Bullet | null)?.fire(x, y, vx); } };
}
```

Collide pools with groups (`this.physics.add.overlap(bulletPool.pool, enemies, onHit)`), not
object by object.

## 7. Enemy state machine (verified at runtime)

```ts
export interface State<C> { enter?(ctx: C): void; update?(ctx: C, dt: number): void; exit?(ctx: C): void }

export class StateMachine<C, K extends string> {
  private current: K | null = null;
  constructor(private readonly ctx: C, private readonly states: Record<K, State<C>>) {}
  get state(): K | null { return this.current; }
  go(next: K): void {
    if (next === this.current) return;
    if (import.meta.env.DEV) console.debug(`[fsm] ${this.current} -> ${next}`);
    if (this.current) this.states[this.current].exit?.(this.ctx);
    this.current = next;
    this.states[next].enter?.(this.ctx);
  }
  update(dt: number): void { if (this.current) this.states[this.current].update?.(this.ctx, dt); }
}

type EnemyState = 'patrol' | 'chase' | 'stunned';

export class Slime extends Phaser.Physics.Arcade.Sprite {
  target?: Phaser.GameObjects.Components.Transform;
  private stunMs = 0;
  readonly fsm = new StateMachine<Slime, EnemyState>(this, {
    patrol: { enter: (s) => s.setVelocityX(-40), update: (s) => { if (s.target && Math.abs(s.target.x - s.x) < 80) s.fsm.go('chase'); } },
    chase: { update: (s) => s.setVelocityX(Math.sign((s.target?.x ?? s.x) - s.x) * 70) },
    stunned: { enter: (s) => { s.setVelocityX(0); s.stunMs = 600; }, update: (s, dt) => { if ((s.stunMs -= dt) <= 0) s.fsm.go('patrol'); } },
  });

  override preUpdate(time: number, delta: number): void {
    super.preUpdate(time, delta);
    if (!this.fsm.state) this.fsm.go('patrol'); // start lazily: the physics body does not exist in the constructor
    this.fsm.update(delta);
  }
}
// scene: const slimes = this.physics.add.group({ classType: Slime }); (slimes.create(x, y, 'enemy') as Slime).target = this.player;
```

The literal speeds keep the example short; in a real project read them from `TUNING.enemy`.
The lazy start matters: calling `setVelocityX` from the constructor crashes because Arcade adds
the body after construction.

## 8. Arcade physics notes

- `fixedStep: true` (default) with `fps: 60` decouples physics from display refresh; keep it on.
- Static level geometry: `physics.add.staticGroup()` or tilemap collision. Moving platforms:
  immovable dynamic bodies with `allowGravity = false`.
- `body.blocked.down` for ground checks against tiles and static bodies; `body.touching.down` for
  dynamic bodies.
- Fast bullets can tunnel through thin tiles: thicken colliders, cap speed, or raycast per step.
- `physics.world.setBounds()` to the map size; `setCollideWorldBounds(true)` on the player.
- Debug: `arcade: { debug: true }` in dev, never in builds.

## 9. Matter (verified)

```ts
export const matterPhysics: Phaser.Types.Core.PhysicsConfig = {
  default: 'matter',
  matter: { gravity: { x: 0, y: 1 }, debug: false },
};

export class CrateScene extends Phaser.Scene {
  create(): void {
    this.matter.world.setBounds(0, 0, 480, 270);
    for (let i = 0; i < 10; i++) {
      this.matter.add.image(100 + i * 24, 40 - i * 30, 'crate', undefined, { restitution: 0.1, friction: 0.6 });
    }
    const ball = this.matter.add.circle(240, 20, 10, { restitution: 0.8 });
    this.matter.world.on('collisionstart', (_e: unknown, a: MatterJS.BodyType, b: MatterJS.BodyType) => {
      if (a === ball || b === ball) this.cameras.main.shake(80, 0.004);
    });
  }
}
```

Matter suits physics puzzles and rotating bodies. As a rule of thumb keep active bodies in the
low hundreds on mobile, then profile on a real phone. For a platformer, Arcade with tuned feel beats Matter almost every time.

## 10. External physics

| Library | Version | When |
|---|---|---|
| `planck` (renamed from `planck-js`) | 1.5.1 | Box2D semantics, joints, deterministic stepping for replays |
| `@dimforge/rapier2d-compat` | 0.21.0 | Many bodies, CCD, character controller; base64 WASM adds weight (the 3D build measured 1.66 MB gzip) |
| `matter-js` standalone | 0.20.0 (2024) | Not for new work outside Phaser's bundled copy |

Wire external physics like the Three.js pattern: step it in a fixed accumulator inside
`update(time, delta)`, then copy body positions to sprites.

## 11. Input details

- Gamepad: `input: { gamepad: true }` in the config; `this.input.gamepad?.once('connected', (pad) => ...)`;
  read `pad.leftStick`, `pad.A`, with a dead zone from `TUNING`.
- Pointer: `this.input.on('pointerdown', (p: Phaser.Input.Pointer) => ...)`;
  `this.input.addPointer(1)` for two-finger touch.
- Rebinding: keep key names in data (`addKeys(bindings.join(','))`), store bindings in the save.
- Do not hijack browser shortcuts (Ctrl+W, F5, Cmd+R) or call `preventDefault()` on every key.
