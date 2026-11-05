# Engine Import Notes for Generated Assets

What changes when a cleaned asset enters each engine. Doc versions and access dates are given
per section. For deeper engine work, route to the engine specialist named in each section.

**General rule:** engines compress textures and audio for each platform on import. Feed them
clean, lossless sources (PNG textures, WAV audio, uncompressed glTF) and let the importer do its
job. Pre-compressed KTX2 or Meshopt files belong to web runtimes.

---

## 1. Godot 4.7 (`game-godot-specialist`)

Source: Godot 4.7 stable docs, "Available 3D formats", "Importing images" and "Importing audio
samples", fetched 2026-11-05. Godot 4.7.2 is the current stable release; 4.8 is in beta.

**3D**
- **glTF 2.0 is the recommended format.** `.glb` (binary) embeds textures. Use `.gltf` with
  separate files when you want text diffs or need the textures kept separate.
- FBX imports through **ufbx** by default (Godot 4.3+). Files first imported in older versions keep
  FBX2glTF until you switch their importer.
- `.blend` import needs Blender 3.0+ (3.5+ recommended) installed on **every team member's**
  machine, preferably an official blender.org build. It does not work in the Android or web
  editors. For generated assets, export `.glb` from Blender instead, which keeps the pipeline
  reproducible.
- Keep raw generations out of `res://` import: put an empty `.gdignore` file in `art-source/` so
  the editor skips the folder.
- Engine-generated `.godot/` and `*.uid` files are protected by GameForge's hooks. Edit source
  assets and import settings, not generated files.

**Textures**
- **Lossless** is the default for 2D and the recommended setting for **pixel art**.
- **VRAM Compressed** is the default for 3D. Avoid it for 2D: it causes visible artifacts on
  low-resolution textures. Even in 3D, pixel-art textures should have VRAM compression disabled.
- **Basis Universal** is a compress mode, smaller but lower quality than VRAM Compressed.
- `.ktx` imports as a 2D image through libktx (no cubemaps or arrays). The docs do not mention
  KTX2, so do not plan a Godot pipeline around pre-made KTX2 files.
- Mipmaps in 2D: enable them only if the project visibly benefits.

**Audio**
- Use **WAV for short, repetitive SFX** and **Ogg Vorbis for music, speech and long SFX**. MP3
  suits CPU-limited mobile and web projects, but at Ogg-equivalent quality it is significantly larger.
- WAV loop modes: Forward, Ping-Pong, Backward, with loop begin and end **in samples**.
- Ogg and MP3 support only a **loop offset in seconds**, with no loop end and forward looping only.
  Bake the loop end into the file.

---

## 2. Unity 6.3 LTS / 6.6 (`game-unity-specialist`)

Source: Unity glTFast package docs (versions 6.0–6.10) and the Unity 6.3 Manual "Sprite (2D and
UI) texture type", fetched 2026-11-05. The Manual now lives at `docs.unity.com`.

**3D**
- glTF and GLB import through **Unity glTFast**, installed as `com.unity.cloud.gltfast` from the
  Package Manager. It loads in the editor and at runtime (`GltfAsset` component or script) and
  supports the Built-in, URP and HDRP render pipelines.
- glTFast can use KTX/Basis Universal, Draco and meshoptimizer through companion packages ("KTX
  for Unity" for KTX). That matters for runtime-downloaded content. For assets baked into the
  build, import uncompressed glTF and let Unity's texture importer compress per platform.
- FBX remains Unity's native model import path. If your generator exports FBX, check the scale
  factor and axis conversion on the first import, then save it as an import preset.
- `.meta` files carry import settings. GameForge's hooks ask before editing them, and the
  `Library/` folder is protected.

**Sprites and UI**
- **Filter Mode:** Point (no filter) keeps pixel art blocky up close. Bilinear and Trilinear blur.
- **Pixels Per Unit** maps sprite pixels to world units. Pick one value per art scale and keep it
  consistent across all generated sprites.
- Set compression in **platform-specific overrides**. For pixel art, test without lossy
  compression, which smears pixel edges (common practice, not stated on that Manual page).
- Leave **Generate Mipmap** off for pixel-art sprites drawn near 1:1 (common practice).

**Audio:** import WAV. Choose compression format and load type per clip in the AudioClip import
settings. Long music streams; short SFX decompress on load.

---

## 3. Unreal Engine 5.8 (`game-unreal-specialist`)

Source: Epic docs, "Importing glTF files into Unreal Engine", fetched 2026-11-05. UE 5.8
(2026-06-17) is the last planned UE5 major release.

- glTF import runs through **Interchange**. Use Content Browser **Add** or drag the file in, set
  options in the **Interchange Pipeline Configuration** dialog, then import. Whole scenes go
  through **File > Import Into Level**.
- `.glb` is self-contained. `.gltf` keeps its parts in a directory you choose.
- Save your Interchange pipeline settings as a project preset, so every generated asset imports
  with the same scale, axis, material and collision settings.
- **Nanite** can take dense static background meshes on supported platforms, which reduces how
  much you need to decimate them. It does not fix UVs, materials, pivots or skinning.
- Textures: import PNG sources and assign texture groups and compression settings (normal maps
  as normal maps, masks without sRGB).
- `*.uasset` and `Intermediate/` are protected by GameForge hooks. Re-import from source instead
  of editing them.

---

## 4. Three.js r187 (`game-threejs-specialist`)

Source: three@0.187.0 (`GLTFLoader.js`, `KTX2Loader.js`) checked locally on 2026-11-05, and the
research brief `web-game-stack.md` §1 and §6.

```ts
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js';
import { MeshoptDecoder } from 'three/addons/libs/meshopt_decoder.module.js';

// After the renderer exists (and after `await renderer.init()` for WebGPURenderer):
const ktx2 = new KTX2Loader()
  .setTranscoderPath(`${import.meta.env.BASE_URL}basis/`) // copy three/examples/jsm/libs/basis/ to public/basis/
  .detectSupport(renderer);
const gltf = new GLTFLoader().setKTX2Loader(ktx2).setMeshoptDecoder(MeshoptDecoder);
const { scene } = await gltf.loadAsync('/models/crate_wood_a.glb');
```

- GLTFLoader throws if a file uses KTX2 or Meshopt and the matching loader is not set. Match the
  loaders to the `gltf-transform optimize` flags you used.
- `detectSupportAsync()` is deprecated (r181). Call `detectSupport()` after `await renderer.init()`.
- Draco always uses WASM; `DRACOLoader.setDecoderConfig` was deprecated in r185. Prefer Meshopt.
- Compressed-format support differs by GPU. ASTC covers iOS Safari 12+ and Chrome Android 47+.
  BC7 covers desktop Chrome 93+, Firefox and Safari 16+, but **not Chrome Android**. KTX2/Basis
  transcodes to whatever the device supports, which is why it is the web default.
- If code looks nodes up by name (`getObjectByName`, gltfjsx output), optimize with
  `--flatten false --join false`.

---

## 5. 2D web: Phaser 4, PixiJS 8, Kaplay (`game-web2d-specialist`)

- Pack sprites into atlases. One texture per animation set beats hundreds of loose PNGs on load
  time and draw calls.
- Pixel art needs nearest-neighbor sampling and integer scaling. Set it in the framework config
  and on the canvas. The exact API differs between Phaser 4 and PixiJS 8, so get the call from
  the specialist rather than guessing.
- Audio: ship WebM/Opus with an MP3 or AAC fallback, and resume the `AudioContext` from the first
  user gesture. Firefox blocks Web Audio until the page has sticky activation (MDN, via
  `web-game-stack.md` §6). Howler 2.2.4 still works but has had no npm release in three years.

---

## 6. Size budgets that shape asset decisions (web portals)

From the research brief `vibe-coded-games.md` §6 (accessed 2026-11-05). Confirm the current
numbers with `/gameforge:game-web-publish` before you build to them.

| Portal | Initial download | Total |
|---|---|---|
| Poki | Small. An older page says under 8 MB; players leave after about 10 s. | — |
| CrazyGames | ≤ 50 MB (≤ 20 MB for the mobile homepage) | ≤ 250 MB, ≤ 1,500 files |
| YouTube Playables | < 30 MiB (SHOULD be < 15 MiB) | < 250 MiB, < 30 MiB per file |

Generated assets are where budgets go to die: 2048² default texture sizes, uncompressed WAV
music and 200k-triangle props. Set per-asset budgets in the asset brief before generating.
