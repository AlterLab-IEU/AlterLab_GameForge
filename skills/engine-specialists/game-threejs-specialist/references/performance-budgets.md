# Performance Budgets, Batching and Profiling

Every number in this file is either sourced (portal docs, MDN, npm), measured by GameForge on
2026-11-05 (labelled "measured"), or a rule of thumb (labelled). Measure your own game on the
weakest device you intend to support; budgets are starting points, not guarantees.

## 1. Budgets

### Hard limits (sourced)

| Channel | Limit |
|---|---|
| CrazyGames | Initial download <= 50 MB to gameplay start; **<= 20 MB for the mobile homepage**; <= 250 MB and <= 1,500 files total; external hosts must reach gameplay within 20 s; DPR forced to 1 on iOS; games not smooth on 4 GB Chromebooks get disabled |
| Poki | No numeric cap on the current page, but players leave after ~10 s of loading; `gameplayStart()` on first input; no external requests |
| YouTube Playables | Initial < 30 MiB (SHOULD < 15); total < 250 MiB; each file < 30 MiB; saves < 3 MiB; JS heap capped at 512 MB |

Route the full portal checklist to `game-web-publish`.

### Frame budgets (rules of thumb, not standards)

| Metric | Desktop (integrated GPU or better) | Mobile web (mid-range Android, recent iPhone) |
|---|---|---|
| Frame time | 16.6 ms (60 fps) | 16.6 ms target, 33 ms floor |
| Draw calls | Low hundreds comfortable | ~100-200 (common heuristic) |
| Triangles on screen | 1-3 M | 100-500 k |
| Pixel ratio | <= 2 | <= 1.5 |
| Texture memory | <= 512 MiB | <= 128-256 MiB, KTX2 |
| Shadow maps | 1-2 casters, 2048 | 1 caster, 1024, tight frustum |
| Post-processing | Bloom + AA | AA only, or none |
| JS heap | Stable after load (no sawtooth during play) | Same; well under 512 MB |

### Download weight (measured, Vite 8.3.6 production build, minimal scene)

| Module | Minified | Gzip |
|---|---|---|
| `three` r187, WebGLRenderer + MeshStandardMaterial | 528 KB | 130 KB |
| `three/webgpu` r187, WebGPURenderer | 812 KB | 220 KB |
| `@dimforge/rapier3d-compat` 0.21.0 module (base64 WASM) | 4.3 MB | 1.66 MB |

Code-split physics, editors and debug tools behind dynamic `import()`. Serve with Brotli or gzip
(itch.io and most static hosts do). Set `build.assetsInlineLimit: 0` so binaries cache as files.

## 2. Cutting draw calls

Order of operations: share materials, then instance, then batch, then merge, then LOD.

### InstancedMesh: many copies of one mesh (verified)

```ts
export function createRocks(geo: THREE.BufferGeometry, mat: THREE.Material, count: number, rng: () => number) {
  const rocks = new THREE.InstancedMesh(geo, mat, count);
  const m = new THREE.Matrix4(), q = new THREE.Quaternion(), p = new THREE.Vector3(), s = new THREE.Vector3();
  for (let i = 0; i < count; i++) {
    p.set(rng() * 100 - 50, 0, rng() * 100 - 50);
    q.setFromAxisAngle(THREE.Object3D.DEFAULT_UP, rng() * Math.PI * 2);
    const k = 0.5 + rng();
    rocks.setMatrixAt(i, m.compose(p, q, s.set(k, k, k)));
  }
  rocks.instanceMatrix.needsUpdate = true;
  rocks.computeBoundingSphere(); // culling must see all instances, not just the source geometry
  return rocks;
}
```

Moving instances: write matrices in the render-side sync and set `needsUpdate` once per frame,
not per instance. Hide an instance by scaling it to zero or swapping it with the last and
lowering `rocks.count`.

### BatchedMesh: many different geometries, one material (verified)

```ts
export function createProps(geos: THREE.BufferGeometry[], mat: THREE.Material, perGeo: number) {
  let verts = 0, indices = 0;
  for (const g of geos) { verts += g.getAttribute('position').count; indices += g.index?.count ?? 0; }
  const batch = new THREE.BatchedMesh(geos.length * perGeo, verts, indices, mat);
  const m = new THREE.Matrix4();
  geos.forEach((g, gi) => {
    const id = batch.addGeometry(g);
    for (let i = 0; i < perGeo; i++) batch.setMatrixAt(batch.addInstance(id), m.makeTranslation(gi * 3, 0, i * 3));
  });
  return batch;
}
```

Recent BatchedMesh changes: per-instance opacity (r183, secondary source), deprecated
instancing paths removed and `getColorAt` fixed (r184), batching color switched to RGBA (r185).
`perObjectFrustumCulled` and `sortObjects` are on by default; turn sorting off for opaque-only
batches if CPU time matters more than overdraw.

### Merge static geometry

`mergeGeometries()` from `three/addons/utils/BufferGeometryUtils.js` for level chunks that never
move individually. Merge per material and per spatial chunk so frustum culling still works.

### LOD (verified)

```ts
const lod = new THREE.LOD();
lod.addLevel(high, 0);
lod.addLevel(mid, 20);
lod.addLevel(low, 60); // generate mid/low with gltf-transform simplify --ratio
```

LOD swaps objects, so it does not combine with InstancedMesh directly; for crowds of instances,
keep one InstancedMesh per LOD level and reassign instances by distance every few frames.

## 3. Fill rate and GPU cost

- Pixel ratio is the biggest single lever on phones. Cap it, and drop it further at runtime when
  frame time stays above budget for ~2 s (adaptive resolution).
- Transparent overdraw (particles, foliage cards, UI-in-world) is expensive on mobile GPUs. Prefer
  alpha-tested (`alphaTest`) over blended where it looks acceptable.
- Post-processing passes each cost roughly a full-screen draw; run bloom at reduced resolution.
- Shadows render the scene again from the light. Limit casters, shrink the shadow camera, and
  update static shadows on demand (`renderer.shadowMap.autoUpdate = false; needsUpdate = true`).

## 4. CPU and garbage

- No allocation in the fixed step or render loop: reuse `Vector3`/`Matrix4` scratch objects at
  module scope.
- Static objects: `object.matrixAutoUpdate = false` after placing them, then
  `object.updateMatrix()` once.
- Raycasts against big meshes: `three-mesh-bvh` 0.9.18.
- Physics: fewer, simpler colliders; sleep bodies; trimesh only for static level geometry.

## 5. Profiling tools

| Tool | Use |
|---|---|
| `renderer.info.render.calls` / `.triangles`, `renderer.info.memory.geometries` / `.textures` | Per-frame counts; expose them in `render_game_to_text` and assert in Playwright |
| `stats-gl` 4.2.3 | FPS, CPU and GPU timing overlay; `new Stats({ trackGPU: true })`, `await stats.init(renderer)`, `stats.update()` per frame. Its bundled `llms.txt` still shows `await renderer.renderAsync()` for WebGPU: use `renderer.render()` |
| `Inspector` addon (r187, WebGPURenderer) | `renderer.inspector = new Inspector()`: performance, memory, timeline and parameters tabs |
| Chrome DevTools Performance | Main-thread flame chart, GC, long tasks; enable CPU throttling to approximate phones |
| Spector.js (browser extension) | Capture one WebGL frame and inspect every draw call and state change |
| Safari Web Inspector (Mac + iPhone over cable) | Real iOS timelines and memory |
| A real mid-range Android phone | The only reliable mobile number. A game can be smooth on an iPhone and stutter on mid-range Android |

Probe for dev builds (verified):

```ts
export function perfProbe(renderer: THREE.WebGLRenderer) {
  let last = 0;
  return (now: number) => {
    if (now - last < 1000) return;
    last = now;
    const { render, memory } = renderer.info;
    console.debug(`[perf] calls=${render.calls} tris=${render.triangles} geos=${memory.geometries} tex=${memory.textures}`);
  };
}
```

## 6. Audit procedure (fills the Performance Audit Report template)

1. `npm run build && npx vite preview`; never profile the dev server (unminified, HMR overhead).
2. Pick the worst scene (most entities, most effects). Add `?seed=` so every run is the same.
3. Desktop: record 10 s in DevTools Performance; note average and worst frame, GC events.
4. Phone: play 60 s; note fps (stats-gl), heat/throttling, and whether audio started.
5. Record `renderer.info` counts and the backend in use (`webgpu` or `webgl2`).
6. Network tab with cache disabled: bytes to first input; list the five heaviest files.
7. Rank findings by expected fps gain per hour of work; fix the top one, re-measure, repeat.
8. Lock the win in: a Playwright assertion on draw calls or memory for that scene.

## 7. Common findings and fixes

| Symptom | Likely cause | Fix |
|---|---|---|
| Draw calls scale with enemy count | One mesh + material per enemy | InstancedMesh per type, shared materials |
| Mobile crash after a few levels | Textures never disposed; WebP/PNG decoded to RGBA8 | `disposeDeep` on unload; KTX2 |
| Hitch when a new effect appears | Shader compiled on first use | Warm up: render once off-screen during loading (`renderer.compile(scene, camera)`), or `compileComputeAsync()` for compute (r186) |
| Smooth on desktop, 20 fps on phone | DPR 3, shadows, post | Cap DPR, one shadow caster, drop post |
| Sawtooth heap graph | Allocations in the loop | Scratch objects; pools |
| Slow first load | Rapier + models on the critical path | Lazy-load physics; load level 1 first, stream the rest |
