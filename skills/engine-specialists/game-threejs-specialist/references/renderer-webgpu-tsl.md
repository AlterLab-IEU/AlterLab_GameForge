# Renderers, WebGPU, TSL and Post-Processing (three r187)

Facts below come from the three.js r181-r187 release notes, the official Migration Guide, the r187
source, and the npm registry (checked 2026-11-05). Snippets were type-checked against
`three@0.187.0` + `@types/three@0.187.0` and run in headless Chromium (which exercises the WebGL 2
fallback of `WebGPURenderer`).

## 1. Which renderer

| Question | WebGLRenderer | WebGPURenderer (`three/webgpu`) |
|---|---|---|
| Maturity | Default, mature (official `llms.txt`) | Production-usable, still moving every release |
| Reach | Every browser with WebGL 2 | WebGPU where available, automatic WebGL 2 fallback |
| Materials | Classic materials, GLSL `ShaderMaterial`, node materials via the r184 compatibility layer | Classic materials (converted to nodes), TSL node materials. No GLSL `ShaderMaterial` |
| Compute | No (GPGPU via render targets) | `renderer.compute()` with TSL `Fn().compute(n)` |
| Post-processing | `EffectComposer` (addons), pmndrs `postprocessing` 6.x | `RenderPipeline` + `three/addons/tsl/display/*` |
| WebXR | Yes | Yes since r185 |
| Bundle (minimal scene, Vite 8.3.6) | 528 KB min / 130 KB gzip | 812 KB min / 220 KB gzip |
| Pick it when | Jams, mobile-first, GLSL shaders you already have, WebGL-only libraries | You need compute, TSL, the r183+ post stack, or Forward+ `ClusteredLighting` |

Do not mix: a project is either "classic + GLSL on WebGLRenderer" or "TSL on WebGPURenderer".
Mixing makes every shader a two-backend problem.

## 2. WebGLRenderer boot (verified)

```ts
import * as THREE from 'three';

const isMobile = matchMedia('(pointer: coarse)').matches;
const renderer = new THREE.WebGLRenderer({ antialias: !isMobile, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, isMobile ? 1.5 : 2));
renderer.setSize(innerWidth, innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFShadowMap; // soft since r182; PCFSoftShadowMap is deprecated
document.querySelector<HTMLDivElement>('#app')!.appendChild(renderer.domElement);
renderer.setAnimationLoop((t) => loop.frame(t));
```

## 3. WebGPURenderer boot with fallback detection (verified)

```ts
import * as THREE from 'three/webgpu';
import { Inspector } from 'three/addons/inspector/Inspector.js';

export async function createRenderer(parent: HTMLElement) {
  const forceWebGL = new URLSearchParams(location.search).has('webgl');
  const renderer = new THREE.WebGPURenderer({ antialias: true, forceWebGL });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setSize(innerWidth, innerHeight);
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  await renderer.init();
  parent.appendChild(renderer.domElement);

  const backend = (renderer.backend as { isWebGPUBackend?: boolean }).isWebGPUBackend ? 'webgpu' : 'webgl2';
  console.info(`[render] backend=${backend}`); // also expose it in render_game_to_text
  if (import.meta.env.DEV) renderer.inspector = new Inspector(); // r187 profiler/inspector overlay
  return { renderer, backend };
}
```

Fallback QA checklist:

- Load with `?webgl` on a WebGPU-capable desktop and compare screenshots with the default path.
- Run CI in headless Chromium: it reports "No available adapters" and runs the WebGL 2 backend,
  which is exactly the path Firefox on Linux/Android and older devices take.
- Expose `backend` in `render_game_to_text()` so test logs show which path ran.
- Features that differ: shadow bias (r183 notes WebGPU may need smaller bias), premultiplied
  alpha (reimplemented in r185), anything that reads render-target pixels.

## 4. WebGPU support (MDN browser-compat-data 8.1.8 and the gpuweb status page)

| Browser | WebGPU |
|---|---|
| Chrome / Edge | 113+ on Windows, macOS, ChromeOS. Android 12+ from 121. Linux: Intel Gen12+ from 144, NVIDIA on Wayland from 147. Windows on ARM64 behind a flag |
| Firefox | Windows 141+. macOS 26 on Apple Silicon 145+, all Apple Silicon macOS 147+. None on Intel Macs, Linux (Nightly only) or Android (flag) |
| Safari | 26+ on macOS, iOS, iPadOS, visionOS |
| Samsung Internet | 25+ |

## 5. TSL node materials (verified)

TSL functions come from `three/tsl`; node materials from `three/webgpu`.

```ts
import * as THREE from 'three/webgpu';
import { color, mix, sin, time, uniform, positionLocal, normalLocal } from 'three/tsl';

const pulse = uniform(1.0);                       // update from JS: pulse.value = 0.5
const mat = new THREE.MeshStandardNodeMaterial({ roughness: 0.4 });
mat.colorNode = mix(color(0x2266ff), color(0xff3366), sin(time.mul(2)).mul(0.5).add(0.5));
mat.emissiveNode = color(0xff3366).mul(pulse);
mat.positionNode = positionLocal.add(normalLocal.mul(sin(time.mul(3)).mul(0.05))); // vertex wobble
```

Version notes:

- r183 added the TSL specification document (`TSL.md` in the repo); r184 made TSL compilation
  about 3x faster and added the WebGLRenderer node-material compatibility layer.
- r185: `positionLocal` no longer includes skinning. Use `positionGeometry` for skinned meshes.
- r187: TSL math operands are coerced implicitly; struct storage buffers are always arrays.
- `threejs.org/docs/llms-full.txt` includes TSL and is the best single document to give an agent.

## 6. Compute (verified on the WebGL 2 fallback)

```ts
import * as THREE from 'three/webgpu';
import { Fn, instancedArray, instanceIndex, uniform, vec3, hash, deltaTime, min } from 'three/tsl';

export function createSparks(renderer: THREE.WebGPURenderer, count = 50_000) {
  const positions = instancedArray(count, 'vec3');
  const velocities = instancedArray(count, 'vec3');
  const gravity = uniform(-9.8);

  const init = Fn(() => {
    positions.element(instanceIndex).assign(vec3(0, 0, 0));
    velocities.element(instanceIndex).assign(vec3(
      hash(instanceIndex).sub(0.5).mul(4), hash(instanceIndex.add(7)).mul(8), hash(instanceIndex.add(13)).sub(0.5).mul(4)));
  })().compute(count);

  const update = Fn(() => {
    const p = positions.element(instanceIndex);
    const v = velocities.element(instanceIndex);
    const dt = min(deltaTime, 1 / 30); // a slow frame must not launch particles off-screen
    v.y.addAssign(gravity.mul(dt));
    p.addAssign(v.mul(dt));
  })().compute(count);

  const material = new THREE.SpriteNodeMaterial({ color: 0xffaa33 });
  material.positionNode = positions.toAttribute();
  material.scaleNode = uniform(0.1);
  const sprites = new THREE.Sprite(material);
  sprites.count = count;

  renderer.compute(init); // after await renderer.init()
  return { sprites, update: () => renderer.compute(update) };
}
```

GPU particles are cosmetic: the simulation (hits, scores) stays on the CPU in the fixed step.
r186 added `compileComputeAsync()` to pre-compile compute pipelines during loading.

## 7. Post-processing

### WebGPU: RenderPipeline (r183+, verified)

```ts
import * as THREE from 'three/webgpu';
import { pass, renderOutput } from 'three/tsl';
import { fxaa } from 'three/addons/tsl/display/FXAANode.js';
import { bloom } from 'three/addons/tsl/display/BloomNode.js';

export function createPost(renderer: THREE.WebGPURenderer, scene: THREE.Scene, camera: THREE.Camera, mobile: boolean) {
  const pipeline = new THREE.RenderPipeline(renderer);
  const color = pass(scene, camera).getTextureNode('output');
  const graded = mobile ? color : color.add(bloom(color, 0.6, 0.2, 0.8)); // strength, radius, threshold
  // FXAA requires sRGB input: tone map + convert first, then disable the automatic output transform.
  pipeline.outputColorTransform = false;
  pipeline.outputNode = fxaa(renderOutput(graded));
  return pipeline; // loop: pipeline.render() instead of renderer.render()
}
```

- `PostProcessing` still exists as a deprecated wrapper that warns once. Replace it.
- `DirectRenderPipeline` (r186) skips the output pass; it is incompatible with transmission.
- Effects available as TSL nodes in `three/addons/tsl/display/`: `bloom`, `fxaa`, `smaa`, `traa`,
  `ao` (GTAO), `outline`, SSR, SSGI, depth of field, film, pixelation, and more.

### WebGL: EffectComposer (verified)

```ts
import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

export function createComposer(renderer: THREE.WebGLRenderer, scene: THREE.Scene, camera: THREE.Camera) {
  const composer = new EffectComposer(renderer);
  composer.addPass(new RenderPass(scene, camera));
  composer.addPass(new UnrealBloomPass(new THREE.Vector2(innerWidth, innerHeight), 0.6, 0.4, 0.85));
  composer.addPass(new OutputPass()); // tone mapping + color space last
  composer.setPixelRatio(Math.min(devicePixelRatio, 1.5));
  return composer; // loop: composer.render()
}
```

pmndrs `postprocessing` is at 6.39.6 with peer `three >=0.168 <0.188` (so it will lag the next
three release); its 7.x line is beta. Its docs show only `WebGLRenderer`: treat it as WebGL-only.

## 8. Lighting and shadows

- r182: `PCFShadowMap` is soft; `PCFSoftShadowMap` deprecated on WebGL. r186 removed it on WebGPU.
- r183: WebGPU shadow bias values may need to be reduced.
- r185: `ClusteredLighting` (Forward+) replaces `TiledLighting`.
- r186: `SunLight` with cascaded shadow maps.
- r187: custom lights register with `CustomLight.registerNode()`.
- r181: reworked PBR indirect specular makes rough materials look brighter; re-check art after
  upgrading across r181.
- r184: environment and background rotation now match object rotation.
- r187: PMREM is cube-based (`CubeUVReflectionMapping` removed); `setViewport()`/`setScissor()`
  are no longer scaled by DPR when a render target is bound.

Mobile shadow policy: one directional shadow caster, a small map (1024), a tight shadow camera
frustum that follows the player, `castShadow` only on hero objects, baked or blob shadows for the rest.

## 9. Other r181-r187 additions worth knowing

| Feature | Release |
|---|---|
| `HTMLTexture` (HTML rendered into a texture) | r184 |
| WebXR on WebGPURenderer | r185 |
| `ClusteredLighting` | r185 |
| `SunLight` with CSM | r186 |
| `Object3D.dispose()` (subclasses must call `super.dispose()`) | r186 |
| Gaussian-splat addon (`objects/GaussianSplat.js`) | present in r187 |
| `Inspector` addon | r187 |

LOD: no notable LOD changes appear in the r181-r187 notes reviewed (absence not verified).

## 10. When another engine fits better

| Engine | Current | Why pick it | Agent docs |
|---|---|---|---|
| Babylon.js | 9.0 announced 2026-03-26; 9.33.3 current; Apache-2.0 | Batteries included: Havok physics (`@babylonjs/havok` 1.3.14), Frame Graph v1, Node Render Graph and Node Particle editors, clustered lighting on WebGPU and WebGL 2, animation retargeting, inspector | `doc.babylonjs.com/llms.txt` |
| PlayCanvas | 2.23.3 (2.24 beta); WebGL 2 or WebGPU | Editor-first teams; Gaussian splats; `npm create playcanvas@latest` (Vite + TS); `@playcanvas/react` 0.11.7; Web Components | `developer.playcanvas.com/llms.txt`; `npx skills add playcanvas/skills`; Editor MCP: `npx -y @playcanvas/editor-mcp-server` |
| Needle Engine | 5.1.16 stable | Three.js + glTF with Unity and Blender authoring | npm `latest` is 6.0.0-alpha.7: pin 5.x |
| Threlte / TresJS | 8.7.0 / 5.10.1 | Svelte 5 / Vue 3 declarative three.js | Both publish `llms.txt` |

Stay on Three.js when the team wants a library and a custom loop, the game is small, or the agent
needs the largest pool of examples. Move to Babylon.js when you would otherwise rebuild an editor,
physics integration and inspector yourself.
