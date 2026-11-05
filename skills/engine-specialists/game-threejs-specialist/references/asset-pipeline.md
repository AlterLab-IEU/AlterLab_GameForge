# Asset Pipeline: glTF, Meshopt, KTX2, Loading and Disposal

Tool facts come from the `@gltf-transform/cli@4.5.1` help output and source, `gltfjsx@6.5.3`
help output, `@react-three/drei@10.7.9` source, the three.js `KTX2Loader` docs, and MDN
browser-compat-data 8.1.8 (checked 2026-11-05).

## 1. Pipeline shape

```
assets-src/ (Blender, generator output, purchased packs; Git LFS for files >= 20 MB)
   |  gltf-transform inspect            -> know what you have
   |  gltf-transform optimize <flags>   -> meshopt geometry, resized/compressed textures
   |  gltf-transform validate           -> spec errors before the browser finds them
   v
public/models/*.glb  (committed, small, loaded at runtime)
```

Keep the source and the optimized output separate so you can re-run the pipeline with new flags.
Put the commands in `package.json` (`"assets": "node scripts/optimize-assets.mjs"`) so an agent
runs the same thing every time.

## 2. `optimize` defaults and the caveats that bite

| Flag | Default (4.5.1) | Effect | Turn off when |
|---|---|---|---|
| `--compress` | `meshopt` (`draco`, `quantize`, `false`) | Geometry and animation compression | Never off for web; choose `draco` only if wire size beats decode speed |
| `--meshopt-level` | `high` | | |
| `--texture-compress` | `auto` (re-encode in original format); `ktx2`, `webp`, `avif` | | |
| `--texture-size` | `2048` | Max texture dimension | Hero textures that truly need 4096 on desktop |
| `--flatten` | `true` | Removes node hierarchy | Skinned or animated models; code that finds nodes by name |
| `--join` (+ `--join-named`) | `true` | Merges meshes to cut draw calls, including named ones | Same as flatten; anything you toggle, swap or hit-test per part |
| `--palette` | `true` | Merges materials into palette textures | You swap or tint materials per part |
| `--simplify` | `true` (error 0.0001) | Simplifies meshes | Hand-made low-poly art; skinned meshes; check silhouettes |
| `--instance` | `true` (min 5) | GPU instancing for repeated meshes | Rarely |
| `--prune`, `--weld`, `--resample`, `--sparse` | `true` | Cleanup | Rarely |

Demonstrated on a three-node test file: default `optimize` collapsed `Node0, Node1, Node2` into a
single `Node0`; with `--flatten false --join false` all three node names survived. Code that calls
`getObjectByName('Node2')` breaks silently with the defaults.

Recipes:

```bash
# Static environment kit: maximum batching
npx gltf-transform optimize assets-src/dungeon.glb public/models/dungeon.glb --texture-compress webp

# Character: keep hierarchy, materials, and topology; compress textures to KTX2
npx gltf-transform optimize assets-src/hero.glb public/models/hero.glb \
  --texture-compress ktx2 --flatten false --join false --palette false --simplify false

# Mobile variant at 1024 px
npx gltf-transform optimize assets-src/hero.glb public/models/hero.mobile.glb \
  --texture-compress ktx2 --texture-size 1024 --flatten false --join false --palette false --simplify false

npx gltf-transform inspect public/models/hero.glb
npx gltf-transform validate public/models/hero.glb
```

## 3. Meshopt vs Draco

- Draco is usually slightly smaller on the wire; Meshopt decodes much faster and is designed to be
  paired with gzip or Brotli on the server.
- Meshopt also covers animation, morph targets and instance data; Draco handles triangle meshes only.
- Default to Meshopt. three r185 deprecated `DRACOLoader.setDecoderConfig`; Draco always uses WASM.
- The Meshopt decoder ships inside three (`three/addons/libs/meshopt_decoder.module.js`) and is
  bundled by Vite; Draco needs decoder files served from your origin
  (`three/examples/jsm/libs/draco/`).

## 4. KTX2 / Basis Universal

- Encoding needs KTX-Software's `ktx` binary, **version 4.4.0 or newer, on PATH**: the CLI spawns
  `ktx` and checks the version. Install it in CI too, or KTX2 steps fail.
- Per-slot control: `gltf-transform uastc in.glb out.glb --slots "{normalTexture,occlusionTexture,metallicRoughnessTexture}"`
  then `gltf-transform etc1s out.glb out.glb --slots "{baseColorTexture,emissiveTexture}"`.
  Common practice (secondary source): UASTC for normal, occlusion and metallic-roughness maps;
  ETC1S for color. ETC1S is far smaller; UASTC keeps quality on data maps.
- Runtime: `KTX2Loader` transcodes to whatever the GPU supports.

| GPU format (WebGL) | Support |
|---|---|
| ASTC | Safari iOS 12+, Chrome Android 47+ |
| ETC | Chrome Android 63+, Safari iOS 13.4+ |
| BPTC / BC7 | Desktop Chrome 93+, Firefox, Safari 16+; **not** Chrome Android |
| S3TC | Not on Chrome Android |

### Texture memory math

| Texture | Bytes per pixel | 2048 x 2048 | With mipmaps (+1/3) |
|---|---|---|---|
| PNG/JPEG/WebP decoded to RGBA8 | 4 | 16 MiB | ~21.3 MiB |
| BC7 / ASTC 4x4 / ETC2 RGBA (from UASTC) | 1 | 4 MiB | ~5.3 MiB |
| BC1 / ETC2 RGB (from ETC1S, opaque) | 0.5 | 2 MiB | ~2.7 MiB |

WebP and AVIF shrink downloads but decode to full RGBA8 in VRAM. Twenty 2048 px WebP textures
cost about 430 MiB of GPU memory with mips, which is where low-end phones crash. KTX2 is the fix.

## 5. Loader setup (verified)

```ts
// src/core/assets.ts
import * as THREE from 'three';
import { GLTFLoader, type GLTF } from 'three/addons/loaders/GLTFLoader.js';
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';
import { MeshoptDecoder } from 'three/addons/libs/meshopt_decoder.module.js';

export function createAssetLoader(renderer: THREE.WebGLRenderer, manager = new THREE.LoadingManager()) {
  const ktx2 = new KTX2Loader(manager)
    .setTranscoderPath(`${import.meta.env.BASE_URL}basis/`) // copy of three/examples/jsm/libs/basis/
    .detectSupport(renderer); // WebGPU: only after await renderer.init()
  const gltf = new GLTFLoader(manager).setKTX2Loader(ktx2).setMeshoptDecoder(MeshoptDecoder);
  const cache = new Map<string, Promise<GLTF>>();
  return {
    manager, // manager.onProgress drives the loading bar
    load(url: string): Promise<GLTF> {
      let p = cache.get(url);
      if (!p) { p = gltf.loadAsync(url); cache.set(url, p); }
      return p;
    },
    dispose() { ktx2.dispose(); cache.clear(); },
  };
}
```

Copy the Basis transcoder into `public/` once (add to `postinstall` so it tracks the three version):

```json
"postinstall": "node -e \"require('fs').cpSync('node_modules/three/examples/jsm/libs/basis','public/basis',{recursive:true})\""
```

Instancing loaded models: clone with `SkeletonUtils.clone()` (`three/addons/utils/SkeletonUtils.js`)
for skinned meshes; for static props reuse `geometry` and `material` in an `InstancedMesh`.

## 6. R3F specifics

- drei 10.7.9 `useGLTF(path, useDraco = true, useMeshopt = true)` sets the Draco decoder to
  `https://www.gstatic.com/draco/versioned/decoders/1.5.5/` by default. That is a third-party
  runtime request (Poki forbids external requests; offline builds break). For Meshopt assets call
  `useGLTF(url, false)`; if you need Draco, self-host the decoder and call
  `useGLTF.setDecoderPath('/draco/')`.
- KTX2 with drei: pass `extendLoader` and use `KTX2Loader` from `three-stdlib` (drei's
  `GLTFLoader` is the three-stdlib one, so the types match). See `r3f.md`.
- `gltfjsx` 6.5.3 (no release in about two years) generates typed JSX components:
  `npx gltfjsx public/models/hero.glb --types --keepnames --shadows -o src/models/Hero.tsx`.
  Its `--transform` flag runs its own optimization with **Draco**, 1024 px textures, WebP, mesh
  joining and material palettes unless you pass `--keepmeshes` / `--keepmaterials`. Prefer running
  `gltf-transform` yourself, then gltfjsx without `--transform`.

## 7. Disposal (verified)

```ts
/** Free GPU memory for a subtree you will never show again (level unload). Skip shared assets. */
export function disposeDeep(root: THREE.Object3D): void {
  root.traverse((obj) => {
    const mesh = obj as THREE.Mesh;
    if (!mesh.isMesh) return;
    mesh.geometry.dispose();
    const mats = Array.isArray(mesh.material) ? mesh.material : [mesh.material];
    for (const m of mats) {
      for (const value of Object.values(m)) if (value instanceof THREE.Texture) value.dispose();
      m.dispose();
    }
  });
  root.removeFromParent();
}
```

- r186 added `Object3D.dispose()`; geometries, materials and textures may be shared and must still
  be disposed separately. Custom `Object3D` subclasses that override `dispose()` must call
  `super.dispose()`.
- Track shared assets in the loader cache and dispose them only when no level references them.
- Verify with `renderer.info.memory.geometries` / `.textures` before and after a level change in a
  Playwright test: the numbers must return to the baseline.

## 8. Intake checklist for any model (hand-made, purchased, or AI-generated)

- [ ] License and provenance recorded (AI-generated: tool, date, prompt; see `game-ai-assets`).
- [ ] Scale: 1 unit = 1 meter; origin at the feet or pivot; facing -Z or documented.
- [ ] Y-up (three r184's `FBXLoader` converts Z-up to Y-up; prefer exporting glTF directly).
- [ ] Triangle count within the per-asset budget; generator output usually needs `simplify` or a
      manual retopo for anything animated.
- [ ] PBR maps present and named; texture sizes <= 2048 (1024 for props on mobile).
- [ ] No embedded cameras or lights unless intended; animations named consistently.
- [ ] `gltf-transform validate` passes; `inspect` output pasted into the PR description.

## 9. Audio files

Ship WebM/Opus (consistent in Safari since 17.4) with an MP3 or AAC fallback; Safari 18.4 also
added Ogg Opus and Ogg Vorbis. Loop music as one stream; short SFX as decoded `AudioBuffer`s. See
`input-audio-ui.md` for the audio bus.
