# Asset Budgets and Formats (Art Director reference)

Snapshot: November 2026. Hard limits below are quoted from platform documentation and marked as
such. Every other number is a **rule of thumb** to start a budget conversation with the technical
director, not a standard. Measure on the weakest target device and adjust.

---

## 1. Naming convention

```
[category]_[subcategory]_[name]_[variant]_[LODn|type].[ext]
char_player_ranger_base_LOD0.glb
env_ruins_pillar_broken_LOD2.glb
prop_crate_wood_02_albedo.ktx2
ui_btn_primary_hover.png
fx_fire_loop_sheet.png
```

Rules: lowercase, underscores only, no spaces, version numbers in git rather than file names, and the
same stem across mesh, textures, and source files so tools and agents can match them with one glob.

---

## 2. Budget table template

Fill one table per target platform. Example values are rules of thumb for a stylized indie game.

| Asset class | Triangles (LOD0) | Texture size | Materials | LODs | Notes |
|---|---|---|---|---|---|
| Player character | 10k-20k (PC/console), 3k-8k (web/mobile) | 2048 (PC), 1024 (web) | 1-2 | 3 | Hand topology, see retopology checklist |
| Key NPC | 5k-15k / 2k-5k | 1024-2048 / 1024 | 1-2 | 2-3 | |
| Environment prop | 500-5k / 200-2k | 512-1024 | 1 (atlas) | 2 | Share atlases per biome |
| Foliage | 100-2k | 512-1024 | 1 | 2 | Alpha-tested; watch overdraw on mobile |
| UI element | n/a | Varies, 2x for high-DPI | n/a | n/a | 9-slice where possible |
| 2D sprite sheet | n/a | Max 2048x2048 per sheet (web) | n/a | n/a | Pack per scene, not per character |

Scene-level budgets (agree with the technical director): draw calls per frame (mobile web heuristic:
about 100-200), texture memory, material count, and transparent overdraw.

---

## 3. Web 3D (Three.js, React Three Fiber, Babylon.js, PlayCanvas)

**Format**: glTF 2.0 binary (`.glb`). Optimize every model before it lands in `public/assets/`.

**Geometry compression**: default to **Meshopt**. It decodes much faster than Draco, pairs with gzip
or Brotli on the server, and also covers animation, morph targets, and instance data. Draco is
usually slightly smaller on the wire but handles triangle meshes only.

**Textures**: **KTX2 / Basis Universal**. UASTC for normal, occlusion, and metallic-roughness maps;
ETC1S for albedo and everything else. The loader transcodes to whatever compressed format the GPU
supports.

| GPU compressed format | Where it works (WebGL) |
|---|---|
| ASTC | Safari iOS 12+, Chrome Android 47+ |
| ETC | Chrome Android 63+, Safari iOS 13.4+ |
| BPTC / BC7 | Desktop Chrome 93+, Firefox, Safari 16+ -- not Chrome Android |
| S3TC | Desktop -- not Chrome Android |

This is why KTX2 beats shipping PNG/JPG: one file, the right GPU format everywhere, a fraction of
the VRAM of an uncompressed texture.

**gltf-transform** (CLI 4.5.x) `optimize` defaults: meshopt compression, texture size 2048,
simplify, instance, palette, flatten, join, and prune all on.

```bash
# Static props: defaults are fine, cap textures at 1024 for web
npx @gltf-transform/cli optimize in.glb out.glb --texture-compress ktx2 --texture-size 1024

# Skinned or animated models, or anything code references by node name:
npx @gltf-transform/cli optimize in.glb out.glb --texture-compress ktx2 --flatten false --join false

# Inspect before and after; paste the numbers into the asset review
npx @gltf-transform/cli inspect out.glb
```

KTX2 output depends on KTX-Software's `ktx` tool (4.4 or later) being installed. In three.js r187,
set `KTX2Loader.setTranscoderPath(...)` and call `.detectSupport(renderer)` after `renderer.init()`
(the async `detectSupportAsync()` is deprecated).

**Portal caps (hard limits from platform docs, Nov 2026)**

| Portal | Limit |
|---|---|
| CrazyGames | Initial download 50 MB or less (measured up to the gameplay-start event); **20 MB or less for the mobile homepage**; 250 MB and 1,500 files total; DPR forced to 1 on iOS |
| Poki | No numeric cap on the current page; warns players leave after about 10 s of loading; no external requests |
| YouTube Playables | Initial bundle under 30 MiB (under 15 MiB recommended); total under 250 MiB; each file under 30 MiB |

**Web rules of thumb (not official)**: textures 2048 px maximum, 1024 px for most props; cap device
pixel ratio at 1.5-2; instancing or batching for repeated props; load only the first level's assets
before `gameplayStart`, stream the rest.

---

## 4. Web 2D (Phaser 4, PixiJS 8, Kaplay, Excalibur)

- **Atlases over loose files**: pack sprites per scene into texture atlases (2048x2048 maximum on
  mobile web as a rule of thumb). Loose PNGs cost requests and draw-call batching.
- **Phaser 4**: textures follow GL conventions (Y=0 at the bottom), so compressed textures made for
  Phaser 3 must be re-exported. `roundPixels` now defaults to `false`; turn it on for pixel art.
  The Canvas renderer is deprecated, so art that relied on Canvas-only blend behavior needs a check.
- **Pixel art**: integer scaling only, nearest-neighbor filtering, no mipmaps on sprite sheets,
  a fixed internal resolution (for example 320x180 or 480x270) scaled to the screen.
- **Formats**: PNG for pixel art (lossless); WebP or AVIF for painted 2D; KTX2 where the framework's
  loader supports it.

---

## 5. Engine notes (verify against the engine specialist)

| Engine | Art-side notes |
|---|---|
| Godot 4.7 | VRAM-compressed import for 3D textures; Basis Universal available; web export uses the Compatibility renderer (WebGL 2) only, so check shader-heavy looks there early |
| Unity 6.3 LTS / 6.6 | Per-platform texture overrides (ASTC on mobile); WebGPU is opt-in for web builds in 6.6 with WebGL 2 kept as fallback |
| Unreal 5.8 | Nanite and Lumen change triangle budgets on high-end targets, not on mobile or web; keep a separate budget table per target |

---

## 6. LOD and texel density

- **LOD trigger distances**: set by screen-size percentage, not world distance, so they hold across
  resolutions.
- **LOD quality**: each LOD keeps the LOD0 silhouette; check it as a black shape at its trigger size.
- **Texel density**: pick one target per class (for example, 512 px per meter for props in a
  third-person game) and check it with a checker texture; mismatched density reads as "these assets
  came from different places" faster than mismatched color.
- **Generated meshes**: decimate after retopology, never instead of it.

---

## 7. Review-gate measurements to record

| Gate | Record |
|---|---|
| Blockout | Silhouette capture at gameplay distance; scale against a 1.8 m reference figure |
| High-poly or paintover | Material and color compliance against the bible |
| Final | Triangles per LOD, texture sizes and formats, material count, `inspect` output, provenance entry ID |
| In-engine | Screenshot beside neighbors; grayscale capture; colorblind-simulated capture; frame-time impact if it is a hero or VFX asset |
