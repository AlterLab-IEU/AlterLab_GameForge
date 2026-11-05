# Game Loop, Physics and Entity Architecture

All code here was type-checked against `three@0.187.0`, `@dimforge/rapier3d-compat@0.21.0`,
`koota@0.6.6` and `bitecs@0.4.0` with TypeScript 7.0.2 (`strict`, `noUncheckedIndexedAccess`).
The boot file below also ran under Playwright 1.64.1 and produced pixel-identical screenshots on
three consecutive runs.

## 1. Files that every project gets

```ts
// src/core/tuning.ts -- every gameplay number in one place.
// Mutable on purpose: the ?debug panel (testing-verification.md) edits it live.
export const TUNING = {
  physics: { fixedDt: 1 / 60, maxFrameTime: 0.25, gravity: -9.81 },
  player: { moveSpeed: 6, jumpImpulse: 5.5, coyoteTimeMs: 120 },
  render: { maxPixelRatio: 2, maxPixelRatioMobile: 1.5 },
};
```

```ts
// src/core/rng.ts -- seeded PRNG (mulberry32); all gameplay randomness goes through it
export function createRng(seed: number) {
  let a = seed >>> 0;
  return function next(): number {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
export const seedFromUrl = (fallback = 1): number =>
  Number(new URLSearchParams(location.search).get('seed') ?? fallback) || fallback;
```

The loop (`src/core/loop.ts`) is in SKILL.md. Its contract: `frame(timestamp)` for
`setAnimationLoop`, `advance(ms)` for tests, `setPaused(bool)`.

## 2. Interpolated physics bodies

```ts
// src/core/physicsBody.ts
import * as THREE from 'three';
import type RAPIER from '@dimforge/rapier3d-compat';

export class InterpolatedBody {
  private readonly prevPos = new THREE.Vector3();
  private readonly currPos = new THREE.Vector3();
  private readonly prevRot = new THREE.Quaternion();
  private readonly currRot = new THREE.Quaternion();

  constructor(readonly body: RAPIER.RigidBody, readonly view: THREE.Object3D) {
    this.capture();
    this.capture(); // prev == curr on spawn, so the first frame does not lerp from the origin
  }

  capture(): void { // once after every world.step()
    this.prevPos.copy(this.currPos);
    this.prevRot.copy(this.currRot);
    const t = this.body.translation();
    const r = this.body.rotation();
    this.currPos.set(t.x, t.y, t.z);
    this.currRot.set(r.x, r.y, r.z, r.w);
  }

  interpolate(alpha: number): void { // once per rendered frame
    this.view.position.lerpVectors(this.prevPos, this.currPos, alpha);
    this.view.quaternion.slerpQuaternions(this.prevRot, this.currRot, alpha);
  }
}
```

Teleports (respawn, level load): call `capture()` twice after `setTranslation` so the view does
not streak across the map.

## 3. Boot file (verified)

```ts
// src/main.ts
import * as THREE from 'three';
import RAPIER from '@dimforge/rapier3d-compat';
import { createLoop } from './core/loop';
import { InterpolatedBody } from './core/physicsBody';
import { TUNING } from './core/tuning';
import { createRng, seedFromUrl } from './core/rng';
import { installTestHooks } from './core/testHooks';

await RAPIER.init(); // WASM must be ready before any Rapier call

const isMobile = matchMedia('(pointer: coarse)').matches;
const renderer = new THREE.WebGLRenderer({ antialias: !isMobile, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio,
  isMobile ? TUNING.render.maxPixelRatioMobile : TUNING.render.maxPixelRatio));
renderer.setSize(innerWidth, innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFShadowMap;
document.querySelector<HTMLDivElement>('#app')!.appendChild(renderer.domElement);

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x87a8c9);
const camera = new THREE.PerspectiveCamera(60, innerWidth / innerHeight, 0.1, 500);
camera.position.set(0, 6, 12);
camera.lookAt(0, 0, 0);
scene.add(new THREE.HemisphereLight(0xffffff, 0x445566, 1.5));
const sun = new THREE.DirectionalLight(0xffffff, 2);
sun.position.set(5, 10, 4);
sun.castShadow = true;
scene.add(sun);

const world = new RAPIER.World({ x: 0, y: TUNING.physics.gravity, z: 0 });
world.timestep = TUNING.physics.fixedDt;
world.createCollider(RAPIER.ColliderDesc.cuboid(20, 0.5, 20).setTranslation(0, -0.5, 0));

const rng = createRng(seedFromUrl());
const boxGeo = new THREE.BoxGeometry(1, 1, 1);
const boxMat = new THREE.MeshStandardMaterial({ color: 0xe0a040 });
const bodies: InterpolatedBody[] = [];
for (let i = 0; i < 20; i++) {
  const body = world.createRigidBody(
    RAPIER.RigidBodyDesc.dynamic().setTranslation(rng() * 6 - 3, 3 + i * 1.2, rng() * 6 - 3));
  world.createCollider(RAPIER.ColliderDesc.cuboid(0.5, 0.5, 0.5), body);
  const mesh = new THREE.Mesh(boxGeo, boxMat); // shared geometry + material: cheap
  mesh.castShadow = true;
  scene.add(mesh);
  bodies.push(new InterpolatedBody(body, mesh));
}

let tick = 0;
const loop = createLoop({
  step() {
    world.step();
    for (const b of bodies) b.capture();
    tick++;
  },
  render(alpha) {
    for (const b of bodies) b.interpolate(alpha);
    renderer.render(scene, camera);
  },
});

installTestHooks({
  advance: (ms) => loop.advance(ms),
  snapshot: () => ({
    tick,
    bodies: bodies.length,
    lowestY: Math.min(...bodies.map((b) => b.body.translation().y)),
    drawCalls: renderer.info.render.calls,
  }),
  pause: (p) => loop.setPaused(p),
});

addEventListener('resize', () => {
  camera.aspect = innerWidth / innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(innerWidth, innerHeight);
});

loop.setPaused(new URLSearchParams(location.search).has('test')); // tests drive time
renderer.setAnimationLoop((t) => loop.frame(t));
```

## 4. Rapier 0.21 essentials

- `@dimforge/rapier3d-compat` inlines its WASM as base64 so it works in any bundler. Measured:
  the 0.21.0 module is 4.3 MB raw / 1.66 MB gzip. Load it behind a dynamic import if the menu does
  not need physics: `const RAPIER = (await import('@dimforge/rapier3d-compat')).default;`
- Call `world.step()` exactly once per fixed step, with `world.timestep = fixedDt`.
- Fast projectiles: `RigidBodyDesc.dynamic().setCcdEnabled(true)`.
- Static level geometry: one `fixed()` body with many colliders, or trimesh colliders for
  complex static meshes; keep dynamic bodies as primitives (cuboid, ball, capsule).
- Rapier's official changelog stops at 0.19.3; specific 0.20/0.21 behavior changes are not
  documented there. Pin the exact version and re-test feel after any bump.
- The three.js `RapierPhysics` addon loads Rapier 0.21 from jsDelivr at runtime. Poki forbids
  external requests and offline builds break: install the npm package instead.

Kinematic character controller (verified types):

```ts
import RAPIER from '@dimforge/rapier3d-compat';
import { TUNING } from './tuning';

export function createPlayer(world: RAPIER.World) {
  const body = world.createRigidBody(RAPIER.RigidBodyDesc.kinematicPositionBased().setTranslation(0, 2, 0));
  const collider = world.createCollider(RAPIER.ColliderDesc.capsule(0.5, 0.35), body);
  const controller = world.createCharacterController(0.02); // skin offset
  controller.enableAutostep(0.35, 0.2, false);
  controller.enableSnapToGround(0.3);
  controller.setSlideEnabled(true);

  let vy = 0;
  return {
    body,
    step(dt: number, moveX: number, moveZ: number, jump: boolean) { // before world.step()
      const grounded = controller.computedGrounded();
      vy = grounded ? (jump ? TUNING.player.jumpImpulse : 0) : vy + TUNING.physics.gravity * dt;
      controller.computeColliderMovement(collider, {
        x: moveX * TUNING.player.moveSpeed * dt, y: vy * dt, z: moveZ * TUNING.player.moveSpeed * dt,
      });
      const m = controller.computedMovement();
      const p = body.translation();
      body.setNextKinematicTranslation({ x: p.x + m.x, y: p.y + m.y, z: p.z + m.z });
    },
  };
}
```

Collision events (opt in per collider, drain once per step):

```ts
const queue = new RAPIER.EventQueue(true);
const pickup = RAPIER.ColliderDesc.ball(0.5).setSensor(true)
  .setActiveEvents(RAPIER.ActiveEvents.COLLISION_EVENTS);
// in step():
world.step(queue);
queue.drainCollisionEvents((h1, h2, started) => { if (started) onContact(h1, h2); });
```

Map collider handles to entities with a `Map<number, EntityId>` filled at spawn time.

### Alternatives

| Library | Version | Use when | Caveat |
|---|---|---|---|
| Jolt (`jolt-physics`) | 1.1.1 | Large worlds, vehicles, many bodies; seven builds incl. multithreaded WASM | Manual memory: `Jolt.destroy()`; multithreaded build needs cross-origin isolation (COOP/COEP) for SharedArrayBuffer |
| `@react-three/rapier` | 2.2.0 | R3F projects | Bundles Rapier 0.19.2, not 0.21 |
| Havok (`@babylonjs/havok`) | 1.3.14 | Inside Babylon.js | Use outside Babylon is unverified |
| `cannon-es` | 0.20.0 (2022) | Never for new work | Unmaintained |

## 5. Entity architecture

### Plain classes (default for jams and small games)

```ts
export interface Entity { update(dt: number): void; dispose(): void; alive: boolean }

export class World {
  private readonly entities: Entity[] = [];
  add<T extends Entity>(e: T): T { this.entities.push(e); return e; }
  step(dt: number) {
    for (const e of this.entities) if (e.alive) e.update(dt);
    for (let i = this.entities.length - 1; i >= 0; i--) {
      const e = this.entities[i]!;
      if (!e.alive) { e.dispose(); this.entities.splice(i, 1); }
    }
  }
}
```

Rules: entities never reach into each other's meshes; cross-entity effects go through an event
emitter or the world; removal is deferred to the end of the step.

### koota 0.6 (verified)

```ts
import * as THREE from 'three';
import { createWorld, trait } from 'koota';

export const Position = trait({ x: 0, y: 0, z: 0 });   // SoA store
export const Velocity = trait({ x: 0, y: 0, z: 0 });
export const Health = trait({ hp: 100 });
export const IsEnemy = trait();                         // tag
export const View = trait(() => new THREE.Object3D());  // AoS: holds an object

export const world = createWorld();

export function spawnEnemy(scene: THREE.Scene, mesh: THREE.Object3D, x: number, z: number) {
  scene.add(mesh);
  return world.spawn(Position({ x, y: 0, z }), Velocity({ x: 0, y: 0, z: 1 }), Health, IsEnemy, View(mesh));
}

export function movementSystem(dt: number) {
  world.query(Position, Velocity).updateEach(([p, v]) => {
    p.x += v.x * dt; p.y += v.y * dt; p.z += v.z * dt;
  });
}

export function deathSystem() {
  world.query(Health, View).forEach((e) => {
    if (e.get(Health)!.hp <= 0) { e.get(View)!.removeFromParent(); e.destroy(); }
  });
}

export function syncViewSystem() { // render side
  world.query(Position, View).readEach(([p, view]) => view.position.set(p.x, p.y, p.z));
}
```

koota also offers relations (`relation()`), actions (`createActions`) and React hooks in
`koota/react` (`useQuery`, `useTrait`, `WorldProvider`). An agent skill ships with it:
`npx skills add pmndrs/koota`.

### bitECS 0.4 (verified)

```ts
import { createWorld, addEntity, addComponent, removeEntity, query } from 'bitecs';

const MAX = 10_000;
export const world = createWorld({
  components: {
    Position: { x: new Float32Array(MAX), y: new Float32Array(MAX), z: new Float32Array(MAX) },
    Velocity: { x: new Float32Array(MAX), y: new Float32Array(MAX), z: new Float32Array(MAX) },
  },
});
const { Position, Velocity } = world.components;

export function spawnBullet(x: number, z: number, vz: number): number {
  const eid = addEntity(world);
  addComponent(world, eid, Position);
  addComponent(world, eid, Velocity);
  Position.x[eid] = x; Position.z[eid] = z; Velocity.z[eid] = vz;
  return eid;
}

export function movementSystem(dt: number): void {
  for (const eid of query(world, [Position, Velocity])) {
    Position.x[eid]! += Velocity.x[eid]! * dt;
    Position.z[eid]! += Velocity.z[eid]! * dt;
  }
}

export function cullSystem(limit: number): void {
  for (const eid of query(world, [Position])) if (Math.abs(Position.z[eid]!) > limit) removeEntity(world, eid);
}
```

bitECS 0.4 is a full TypeScript rewrite: components are plain objects you define, `query(world,
[...])` replaces `defineQuery`, and `bitecs/legacy` keeps the 0.3 API for old code. Pair SoA
positions with one `InstancedMesh` per entity type and write matrices in a render-side system.

### System order (both ECS styles)

`input -> AI/intent -> movement/physics step -> collision response -> damage/death -> spawn
queue -> scoring/UI events` inside the fixed step, then `interpolate -> sync views -> render`
per frame. Write the order down in one `systems/index.ts`; agents reorder it silently otherwise.

## 6. Determinism notes

- Rapier is built for deterministic stepping given identical inputs and step order; in the
  verified run above, the same seed produced identical screenshots three times in one browser.
  Prove it for your game with a replay test before you build netcode on it, and keep the step
  count, not wall-clock time, as the source of truth.
- All randomness through the seeded RNG; never `Math.random()` in systems.
- For lockstep multiplayer or cross-browser replays, avoid relying on `Math.sin`/`Math.cos`
  results being bit-identical across browsers (Simon Willison's Battle Drones write-up reports
  Chrome/Safari desync fixed with custom functions). Route netcode questions to `game-multiplayer`.
- Object pools for bullets and particles: allocate at load, toggle `visible` and the ECS tag;
  zero allocations in the fixed step.
