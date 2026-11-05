# React Three Fiber 9.8 for Games

Versions from the npm registry on 2026-11-05. Every snippet compiled against
`@react-three/fiber@9.8.2`, `@react-three/drei@10.7.9`, `@react-three/rapier@2.2.0`,
`react@19.3.1`, `three@0.187.0`, and ran in headless Chromium (WebGL, and `WebGPURenderer` on its
WebGL 2 fallback).

## 1. Version matrix

| Package | Pin | Notes |
|---|---|---|
| `@react-three/fiber` | 9.8.2 | Peers `react >=19 <19.4`, `three >=0.156`. v10 is `10.0.0-alpha.6`: do not ship |
| `react` / `react-dom` | 19.3.1 | |
| `@react-three/drei` | 10.7.9 | Peer fiber ^9. drei 11 alpha targets v10 |
| `@react-three/rapier` | 2.2.0 | Depends on `@dimforge/rapier3d-compat` **0.19.2** (pinned). A 3.0 tracking issue covers R3F v10, WebGPU and Rapier 0.21 |
| `@react-three/postprocessing` | 3.2.2 | Wraps pmndrs `postprocessing` ^6.36: **WebGL only** |
| `zustand` | 5.0.16 | UI-rate state |
| `koota` | 0.6.6 | ECS with `koota/react` hooks |
| `@react-three/xr` | 6.6.32 | WebXR |
| `@react-three/uikit` | 1.0.78 | In-canvas UI |
| `ecctrl` | 2.0.2 | Character controller; peers `three >=0.184`, `react >=19.2.7`, `@react-three/rapier >=2.2` |
| `leva` | 0.10.1 | Debug GUI; slow release cadence |
| `@vitejs/plugin-react` | 6.2.1 | Uses Oxc, not Babel, in v6 |

Do not add `@dimforge/rapier3d-compat@0.21` next to `@react-three/rapier`: you would ship two
physics engines (two base64 WASM payloads) and the components would still use 0.19.2.

## 2. Canvas and physics (verified)

```tsx
import { Suspense, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { KeyboardControls, useKeyboardControls } from '@react-three/drei';
import { Physics, RigidBody, CuboidCollider, type RapierRigidBody } from '@react-three/rapier';
import { useGame } from './store';

const TUNING = { moveForce: 12, maxSpeed: 6 } as const;
type Controls = 'forward' | 'back' | 'left' | 'right' | 'jump';
const keyMap = [
  { name: 'forward', keys: ['KeyW', 'ArrowUp'] }, { name: 'back', keys: ['KeyS', 'ArrowDown'] },
  { name: 'left', keys: ['KeyA', 'ArrowLeft'] }, { name: 'right', keys: ['KeyD', 'ArrowRight'] },
  { name: 'jump', keys: ['Space'] },
];

function Player() {
  const body = useRef<RapierRigidBody>(null);
  const [, get] = useKeyboardControls<Controls>();
  useFrame((_state, delta) => {
    const rb = body.current;
    if (!rb) return;
    const { forward, back, left, right } = get();
    const v = rb.linvel();
    const ix = (Number(right) - Number(left)) * TUNING.moveForce * delta;
    const iz = (Number(back) - Number(forward)) * TUNING.moveForce * delta;
    if (Math.hypot(v.x, v.z) < TUNING.maxSpeed) rb.applyImpulse({ x: ix, y: 0, z: iz }, true);
  });
  return (
    <RigidBody ref={body} colliders="ball" position={[0, 2, 0]} ccd>
      <mesh castShadow><sphereGeometry args={[0.5, 32, 16]} /><meshStandardMaterial color="orange" /></mesh>
    </RigidBody>
  );
}

export function App() {
  const score = useGame((s) => s.score); // re-renders only when score changes
  return (
    <KeyboardControls map={keyMap}>
      {/* shadows="percentage": boolean `shadows` selects PCFSoftShadowMap, which r187 warns about */}
      <Canvas shadows="percentage" dpr={[1, 2]} camera={{ position: [0, 6, 10], fov: 60 }}>
        <hemisphereLight args={[0xffffff, 0x334455, 1.5]} />
        <directionalLight position={[5, 10, 4]} intensity={2} castShadow />
        <Suspense fallback={null}>
          <Physics timeStep={1 / 60} interpolate>
            <Player />
            <RigidBody type="fixed"><CuboidCollider args={[20, 0.5, 20]} position={[0, -0.5, 0]} /></RigidBody>
          </Physics>
        </Suspense>
      </Canvas>
      <div className="hud">Score {score}</div>
    </KeyboardControls>
  );
}
```

```ts
// store.ts -- UI-rate state only (score, phase, settings); per-frame data lives in refs
import { create } from 'zustand';
type Phase = 'menu' | 'playing' | 'gameover';
interface GameState { phase: Phase; score: number; addScore: (n: number) => void; setPhase: (p: Phase) => void }
export const useGame = create<GameState>()((set) => ({
  phase: 'menu', score: 0,
  addScore: (n) => set((s) => ({ score: s.score + n })),
  setPhase: (phase) => set({ phase }),
}));
```

## 3. Frame-loop rules

- `useFrame((state, delta) => ...)` runs every rendered frame. Mutate refs there; never call
  `setState` or a store setter that re-renders React components each frame.
- Read stores inside `useFrame` with `useGame.getState()`, not the hook.
- Gameplay that must be frame-rate independent goes in the physics step: `@react-three/rapier`
  with `timeStep={1/60}` steps at a fixed rate and `interpolate` smooths rendering.
  `useBeforePhysicsStep` / `useAfterPhysicsStep` run your code once per physics step:

```tsx
import { useRef } from 'react';
import { RigidBody, useBeforePhysicsStep, type RapierRigidBody } from '@react-three/rapier';

export function Ship({ input }: { input: { current: { x: number; z: number } } }) {
  const body = useRef<RapierRigidBody>(null);
  useBeforePhysicsStep(() => { // once per 1/60 s step, not per rendered frame
    const { x, z } = input.current;
    body.current?.applyImpulse({ x: x * 0.4, y: 0, z: z * 0.4 }, true);
  });
  return <RigidBody ref={body} colliders="cuboid" ccd><mesh><boxGeometry args={[1, 0.4, 2]} /><meshStandardMaterial /></mesh></RigidBody>;
}
```

- Menus and pause screens: `<Canvas frameloop="demand">` (render on change) or stop the game
  simulation with `<Physics paused>` while R3F keeps rendering the background.
- `useFrame(cb, 1)` with a positive priority takes over rendering from R3F (used for custom
  pipelines below).

## 4. Assets in R3F

```tsx
import { useThree } from '@react-three/fiber';
import { useGLTF } from '@react-three/drei';
import { KTX2Loader } from 'three-stdlib'; // drei's GLTFLoader is three-stdlib's: match it

let ktx2: KTX2Loader | null = null;

function Ship() {
  const gl = useThree((s) => s.gl);
  // useDraco = false: drei's default Draco decoder is fetched from www.gstatic.com at runtime
  const { scene } = useGLTF('/models/ship.glb', false, true, (loader) => {
    ktx2 ??= new KTX2Loader().setTranscoderPath('/basis/').detectSupport(gl);
    loader.setKTX2Loader(ktx2);
  });
  return <primitive object={scene} />;
}
useGLTF.preload('/models/ship.glb', false, true);
```

- Add `three-stdlib` to `package.json` explicitly if you import it (it is a drei dependency).
- `<primitive object={scene} />` mounts the cached scene once; for multiple copies use
  `scene.clone()` (static) or `SkeletonUtils.clone` (skinned), or generate a component with
  `gltfjsx --types --keepnames` and reuse its geometry and materials.
- Instancing: drei `<Instances>` / `<Merged>`, or raw `<instancedMesh args={[geo, mat, count]}>`
  with matrices written in `useFrame`.

## 5. WebGPU in R3F 9 (verified)

```tsx
import * as THREE from 'three/webgpu';
import { Canvas, extend, type ThreeElement } from '@react-three/fiber';
import type { ReactNode } from 'react';

// Register the node materials you use. Extending the whole three/webgpu namespace type
// (ThreeToJSXElements<typeof THREE>) fails to compile with @types/three 0.187 (PMREMGenerator clash).
extend({ MeshStandardNodeMaterial: THREE.MeshStandardNodeMaterial, MeshBasicNodeMaterial: THREE.MeshBasicNodeMaterial });
declare module '@react-three/fiber' {
  interface ThreeElements {
    meshStandardNodeMaterial: ThreeElement<typeof THREE.MeshStandardNodeMaterial>;
    meshBasicNodeMaterial: ThreeElement<typeof THREE.MeshBasicNodeMaterial>;
  }
}

export function WebGPUCanvas({ children }: { children: ReactNode }) {
  return (
    <Canvas dpr={[1, 2]} gl={async (props) => {
      const renderer = new THREE.WebGPURenderer(props as THREE.WebGPURendererParameters);
      await renderer.init(); // falls back to WebGL 2 when WebGPU is unavailable
      return renderer;
    }}>
      {children}
    </Canvas>
  );
}
```

```tsx
import { useMemo } from 'react';
import { color, mix, sin, time } from 'three/tsl';

export function Orb() {
  const colorNode = useMemo(() => mix(color(0x2266ff), color(0xff3366), sin(time).mul(0.5).add(0.5)), []);
  return <mesh><icosahedronGeometry args={[1, 4]} /><meshStandardNodeMaterial colorNode={colorNode} roughness={0.4} /></mesh>;
}
```

Post-processing on WebGPU in R3F 9: `@react-three/postprocessing` is WebGL-only, so drive a
`RenderPipeline` yourself (verified):

```tsx
import { useEffect, useMemo } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import * as THREE from 'three/webgpu';
import { pass } from 'three/tsl';
import { bloom } from 'three/addons/tsl/display/BloomNode.js';

export function Bloom() {
  const { gl, scene, camera } = useThree();
  const pipeline = useMemo(() => {
    const p = new THREE.RenderPipeline(gl as unknown as THREE.WebGPURenderer);
    const c = pass(scene, camera).getTextureNode('output');
    p.outputNode = c.add(bloom(c, 0.6, 0.2, 0.8));
    return p;
  }, [gl, scene, camera]);
  useEffect(() => () => pipeline.dispose(), [pipeline]);
  useFrame(() => pipeline.render(), 1); // positive priority: R3F stops its own render call
  return null;
}
```

## 6. Adaptive quality

```tsx
import { useThree } from '@react-three/fiber';
import { PerformanceMonitor } from '@react-three/drei';

export function AdaptiveQuality() {
  const setDpr = useThree((s) => s.setDpr);
  return <PerformanceMonitor onDecline={() => setDpr(1)} onIncline={() => setDpr(Math.min(devicePixelRatio, 2))} />;
}
```

drei also ships `AdaptiveDpr`, `Detailed` (LOD), `BakeShadows`, `Preload` and `Stats`.

## 7. Known-harmless warnings (observed with the versions above)

| Warning | Source | Action |
|---|---|---|
| `THREE.Clock: This module has been deprecated. Please use THREE.Timer instead.` | R3F 9 creates `state.clock` internally | Ignore; do not downgrade three. Use `delta` in your code, not `state.clock` |
| `using deprecated parameters for the initialization function; pass a single object instead` | Rapier 0.19.2 inside `@react-three/rapier` 2.2.0 | Ignore |
| `THREE.WebGPURenderer: PCFSoftShadowMap has been removed. Using PCFShadowMap instead.` | R3F's shadow-map default applied to `WebGPURenderer` | Ignore, or set the type yourself after creation |
| `WebGPU is not available, running under WebGL2 backend.` | No adapter (headless CI, unsupported browser) | Expected fallback |

## 8. R3F v10 (alpha.6): what changes, how to prepare

Do not ship v10 alpha. Changes announced in the alpha and its migration guide:

- Default entry uses `WebGPURenderer` with WebGL 2 fallback; `@react-three/fiber/legacy` keeps
  `WebGLRenderer` for GLSL and WebGL-only libraries; `@react-three/fiber/webgpu` is deprecated.
- `renderer` (WebGPU) and `gl` (legacy) become separate `<Canvas>` props; `shadows` moves inside them.
- `state.gl` is deprecated for `state.renderer`; `state.clock` is removed.
- `useFrame` gains phases (`input`, `physics` with a fixed 1/60 s step and `state.overstep`,
  `update`, `render`); numeric priorities run in reverse order.
- `<color attach="background">` is deprecated for the `<Canvas background>` prop; `onUpdate` is
  removed; TSL hooks move to `@react-three/tsl`; React Native moves to `@react-three/native`.
- Requires `three >=0.185`, `react >=19.0 <19.4`. `EffectComposer` "needs `/legacy` until it
  supports WebGPU".

Prepare now: use `delta`, never `state.clock`; avoid `onUpdate`; keep renderer creation in one
component; keep custom priorities in one file; keep GLSL out if you plan to go WebGPU.

## 9. Docs for agents

`r3f.docs.pmnd.rs/llms.txt` (R3F), `threejs.org/docs/llms-full.txt` (three + TSL), koota's
agent skill (`npx skills add pmndrs/koota`). Point the agent at the installed version's docs and
this file's warning table before it "fixes" anything.
