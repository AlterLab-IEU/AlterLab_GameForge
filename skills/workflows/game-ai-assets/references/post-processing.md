# Post-Processing Generated Assets

Raw generator output is a draft. This file holds the cleanup recipes per asset type: checks,
commands and failure signs. Run commands from the project root. Raw files stay in
`art-source/ai/<asset-id>/`, and processed files go to the engine's asset folder. Never overwrite
the raw file; the provenance log points at it.

Tool versions referenced: glTF Transform CLI **4.5.1** (npm, 2026-09-28), KTX-Software **4.4.0+**
(the minimum gltf-transform 4.5.1 checks for), ffmpeg (any current release), ImageMagick 7
(`magick`).

---

## 1. 3D meshes

### 1.1 Triage the raw mesh (5 minutes per asset)

| Check | Pass | Common generator failure |
|---|---|---|
| Scale and units | 1 unit = 1 m, standing on the origin, faces +Z or -Z per your engine convention | Arbitrary scale, centered pivot |
| Floaters | One connected piece, or intentional parts only | Small disconnected shards, internal shells |
| Silhouette | Reads as the brief's silhouette at gameplay distance | Mushy, symmetrical, "melted" detail |
| Triangle count | Within the art bible budget for its LOD0 | 10–100× over budget for props |
| Materials | Albedo free of baked lighting and shadows | Shadows painted into the albedo |
| Text and marks | No legible text or logos | Gibberish lettering, brand-like emblems |

Reject early. A mesh that fails silhouette or has lighting baked into the albedo costs more to
fix than to regenerate.

### 1.2 Retopology: decide by tier

- **Hero assets** (player character, bosses, anything deforming close to camera): **manual
  retopology**. Hand-place edge loops around eyes, mouth, shoulders, elbows, knees and fingers.
  Generators, including topology-focused ones, still need cleanup here (research brief, Meshy and
  Tripo reports [S48][S49]).
- **Gameplay props** (pickups, weapons, interactables): an automatic quad remesh such as Meshy
  Remesh or Blender's Remesh modifier, then a manual pass on silhouette edges and hard-surface
  bevels.
- **Background props:** decimate to budget. Topology only matters where it affects shading.
- **Unreal static props:** Nanite can absorb dense static meshes on platforms that support it. It
  does not fix UVs, materials, pivots or skinning.

If you drive Blender through an MCP server, remember that it executes arbitrary Python. Keep it
on localhost and review the scripts it runs.

### 1.3 UVs and baking

1. Unwrap after retopology. Generated UVs are usually fragmented atlases that waste texture space
   and seam badly when you repaint. For a quick automatic unwrap,
   `npx gltf-transform unwrap in.glb out.glb` uses xatlas. It suits lightmaps and background
   props, not hero assets.
2. Keep texel density consistent with the art bible (for example "512 px per meter for props").
   Mismatched density is the fastest way to make AI props look foreign next to hand-made ones.
3. Bake the high-poly generated mesh onto the retopologized low-poly: normal, AO, and curvature if
   your shader uses it.
4. Repaint the albedo where the generator baked in lighting. Flatten values toward the art
   bible's material ranges.

### 1.4 PBR sanity

- Albedo inside the art bible's value range: no pure black, no blown whites unless stylized.
- Metallic is binary-ish (0 or 1) except at transitions. Generators often output gray "half-metal".
- Roughness varies with the material, not with noise.
- The normal map is in the convention your engine expects (glTF uses OpenGL-style +Y).

### 1.5 Rigging checks (skinned meshes)

- Bone names follow your skeleton convention, so retargeting and code references work.
- Rest pose is T or A, matching your animation library.
- Deform test: bend every major joint to 90°. Watch shoulders, hips, wrists and fingers for
  candy-wrapper twists and collapsing volume.
- Weights are normalized, with at most 4 influences per vertex unless your engine supports more.
- Auto-rigs (such as Meshy's) are fine for background characters. Heroes get a hand-checked rig.

### 1.6 LODs

Make LOD1 to LOD3 from the cleaned mesh, not from the raw generation. Engines can auto-generate
LODs. For the web, `gltf-transform simplify` with a vertex ratio works on static props.

### 1.7 glTF export and optimization

Export glTF 2.0 (`.glb`) with transforms applied, +Y up and meters. Then pick the recipe for the
destination. Install the CLI as a pinned dev dependency, so `npx` runs the version you chose:

```bash
npm install --save-dev @gltf-transform/cli@4.5.1
npx gltf-transform inspect assets/models/crate_wood_a.glb      # sizes, draw calls, texture memory
npx gltf-transform validate assets/models/crate_wood_a.glb     # glTF spec validation
```

**Know the `optimize` defaults before you run it** (verified in the 4.5.1 CLI source):
`--compress meshopt`, `--texture-compress auto` (re-encodes in the original format),
`--texture-size 2048`, `--simplify true`, `--flatten true`, `--join true`, `--palette true`
(creates palette textures and **merges materials**), `--instance true`, `--prune true`.

| Destination | Recipe | Why |
|---|---|---|
| Web, static prop | `npx gltf-transform optimize in.glb out.glb --texture-compress ktx2 --texture-size 1024` | Meshopt geometry plus KTX2 textures for the smallest download and GPU memory |
| Web, skinned or animated, or code references nodes by name | `npx gltf-transform optimize in.glb out.glb --flatten false --join false --palette false --texture-compress ktx2` | Flatten and join break node hierarchies and names. Palette merges materials your code may swap. |
| Web, hero mesh you retopologized by hand | add `--simplify false` | Simplify would undo the topology you paid for |
| Godot, Unity, Unreal | Do **not** pre-compress. Export clean PNG textures. At most run `npx gltf-transform prune in.glb out.glb` and `dedup`. | Engines compress textures for each platform on import. Compression extensions (`EXT_meshopt_compression`, `KHR_draco_mesh_compression`, `KHR_texture_basisu`) are for runtime delivery; use them only if you have confirmed your importer handles them. |

**KTX2 caveats:**
- `--texture-compress ktx2` shells out to KTX-Software's `ktx` binary. Version 4.4.0+ must be on
  `PATH`; check it with `ktx --version`. Without it the command fails with `Command "ktx" not found`.
- In `optimize`, KTX2 uses **UASTC** for `normalTexture`, `occlusionTexture` and
  `metallicRoughnessTexture`, and **ETC1S** for everything else. ETC1S is small but lossy, so
  inspect albedo with fine detail or gradients. If it bands, re-run with `npx gltf-transform uastc`
  on those slots (`--slots "baseColorTexture"`).
- Draco vs Meshopt: Draco is usually slightly smaller on the wire. Meshopt decodes much faster,
  covers animation and morph targets, and pairs with gzip or Brotli. Default to Meshopt
  (research brief `web-game-stack.md` §6).

### 1.8 Embed provenance in the file (optional, recommended for web)

`gltf-transform xmp` writes XMP metadata (`KHR_xmp_json_ld`) for provenance and usage rights.
Run it **last**, after `optimize`:

```bash
npx gltf-transform xmp out.glb out.glb --packet art-source/ai/AI-3D-014/provenance.jsonld
```

A minimal packet:

```json
{
  "@context": { "dc": "http://purl.org/dc/elements/1.1/", "Iptc4xmpExt": "http://iptc.org/std/Iptc4xmpExt/2008-02-29/" },
  "dc:title": "crate_wood_a (AI-3D-014)",
  "dc:creator": { "@list": ["Ember Drift team"] },
  "Iptc4xmpExt:DigitalSourceType": "http://cv.iptc.org/newscodes/digitalsourcetype/compositeWithTrainedAlgorithmicMedia"
}
```

Every prefix you use must be declared in `@context`, or the CLI rejects the packet. Without
`--packet`, `xmp` starts interactive prompts, which fail in a non-interactive agent shell. Always
pass a packet file.

IPTC digital source type codes (verified 2026-11-05): `trainedAlgorithmicMedia` (created using
generative AI), `compositeWithTrainedAlgorithmicMedia` (edited using generative AI),
`compositeSynthetic` (composite including generative AI elements), `humanEdits` (human-edited
with non-generative tools). For images, ExifTool writes the same field:
`exiftool -XMP-iptcExt:DigitalSourceType="http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia" key_art.png`.
ExifTool is not pre-approved by this skill; ask before running it.

---

## 2. 2D sprites, pixel art, UI and textures

### 2.1 Pixel art: get onto the grid and the palette

Generated "pixel art" is often oversampled and slightly off-grid, with more colors than the
palette allows.

```bash
# 1. How many colors does it really use?
magick sprite_raw.png -format "%k\n" info:
# 2. If it was generated at 4x, scale down with nearest-neighbor onto the true grid
magick sprite_raw.png -filter point -resize 25% sprite_grid.png
# 3. Lock to the project palette (palette.png = one pixel per allowed color), no dithering
magick sprite_grid.png +dither -remap design/art/palette.png sprite_pal.png
# 4. Hard alpha: pixel art has no soft edges
magick sprite_pal.png -channel A -threshold 50% +channel sprite_final.png
# 5. Preview at 4x for review, nearest-neighbor
magick sprite_final.png -filter point -resize 400% review/sprite_x4.png
```

Then clean up by hand in Aseprite or similar: stray pixels, anti-aliased outlines, inconsistent
outline color, and light direction that does not match the sheet.

### 2.2 Painted sprites, icons and UI

- Remove halos: generated cut-outs often keep a fringe of the old background. Check them on black,
  white and mid-gray.
- Trim and re-pad consistently: `magick icon.png -trim +repage -gravity center -background none -extent 128x128 icon_128.png`.
- Check icon sets in one lineup at their final display size. Inconsistent line weight is the most
  common giveaway of mixed generations.
- Text in images: regenerate or paint over any lettering. Generators produce gibberish, and
  sometimes near-real brand marks.

### 2.3 Spritesheets

```bash
magick montage frames/run_*.png -tile 8x -geometry +0+0 -background none sheets/run.png
```

Check that every frame has the same canvas size and pivot (feet on the same row). Inconsistent
frame bounds cause jitter even when the art itself is fine.

### 2.4 Tileable textures: prove the tiling

"Seamless" generator output does not always tile (research brief [S55]). Two checks:

```bash
# Offset by half the size (for a 1024x1024 texture): seams now cross the center
magick tex.png -roll +512+512 review/tex_roll.png
# 2x2 repeat: look for visible repetition and seams
magick tex.png \( +clone \) +append \( +clone \) -append review/tex_2x2.png
```

Fix seams by painting over the center cross of the rolled image, then roll it back. Check the
normal map and the albedo separately, because they often seam in different places.

### 2.5 Strip metadata from *reference* uploads, keep it on outputs

`magick photo.jpg -strip photo_clean.jpg` removes EXIF, including GPS. Do this before uploading
reference photos to a cloud generator. Do **not** strip vendor-embedded provenance from outputs
you publish unchanged, such as marketing images. Note that `-strip` also removes the ICC
profile, so convert to sRGB first if color matters.

---

## 3. Audio

### 3.1 Clean-up order

1. **Inspect:** `ffprobe -hide_banner sfx_raw.wav`. Check the sample rate, channels and duration.
2. **Trim leading silence:** `ffmpeg -i in.wav -af silenceremove=start_periods=1:start_threshold=-60dB out.wav`
3. **Fades** against clicks: `-af "afade=t=in:d=0.005,afade=t=out:st=<duration-0.02>:d=0.02"`
4. **Channels:** positional SFX go to mono (`-ac 1`). Ambiences and music stay stereo.
5. **Sample rate:** pick one project rate, commonly 48 kHz, and resample everything to it (`-ar 48000`).
6. **Loudness** (§3.2), then **encode** (§3.4).

### 3.2 Loudness

- **Mix target:** Sony's Audio Standards Working Group recommendation, as described by Garry
  Taylor in 2012, is an average of **-23 LUFS for PS3 and -18 LUFS for PS Vita, ±2 LU**,
  measured over at least 30 minutes of representative gameplay. It is old and platform-specific,
  but it remains the best-documented public reference for home console versus handheld. It
  applies to the **whole game's output**, not to individual files. Check your platform holder's
  current requirements.
- **Per-asset normalization** only gives the mix a sane starting point. Normalize each category
  (music, ambience, dialogue, SFX) to a consistent internal reference that the audio director
  sets. Category numbers are a team choice, not a standard.
- **Two-pass `loudnorm`** (EBU R128) for music, ambience and dialogue:

```bash
# Pass 1: measure
ffmpeg -hide_banner -i music_raw.wav -af loudnorm=I=-23:TP=-1:LRA=11:print_format=json -f null -
# Pass 2: apply linearly with the measured values from pass 1
ffmpeg -i music_raw.wav -af loudnorm=I=-23:TP=-1:LRA=11:measured_I=<..>:measured_TP=<..>:measured_LRA=<..>:measured_thresh=<..>:offset=<..>:linear=true -ar 48000 music_norm.wav
```

  `loudnorm` defaults are `I=-24`, `LRA=7`, `TP=-2`. In dynamic mode it upsamples to 192 kHz, so
  always set `-ar`. If its linear conditions are not met, it falls back to dynamic mode, so check
  the pass-2 output.
- **Short one-shots** (under about a second): integrated loudness is unreliable on very short
  clips (rule of thumb). Normalize to a peak or momentary target and balance by ear in the mix.

### 3.3 Loops

- Cut loop points at zero crossings, on the beat for music. ElevenLabs SFX v2 can generate
  seamless loops (research brief [S59]); verify them anyway.
- **Listen to three cycles** before approving: `ffmpeg -stream_loop 2 -i amb_loop.wav review/amb_loop_x3.wav`
- Avoid MP3 for loops. Encoder padding can leave a gap or click at the seam. Use WAV or Ogg.
- Engine specifics: Godot WAV supports loop begin and end in samples. Godot Ogg and MP3 support
  only a loop offset, with no loop end. See `engine-import.md`.

### 3.4 Encode for the target

| Target | SFX | Music, speech, long ambiences |
|---|---|---|
| Godot | WAV (short, repetitive) | Ogg Vorbis. MP3 where CPU is tight (mobile, web). |
| Unity / Unreal | Import WAV and let the engine compress per platform | Same |
| Web | WebM/Opus (consistent in Safari since 17.4; Safari 18.4 added Ogg Opus and Vorbis) with an MP3 or AAC fallback | Same |

```bash
ffmpeg -i sfx.wav -c:a libvorbis -q:a 5 sfx.ogg
ffmpeg -i music.wav -c:a libopus -b:a 96k music.webm
ffmpeg -i music.wav -c:a libmp3lame -q:a 4 music.mp3
```

Web audio must be unlocked from a user gesture (`AudioContext.resume()`). See `engine-import.md` §4.

---

## 4. Animation from capture or generation

- **Retarget** onto your skeleton. Check that the hips height and foot plants match the character's
  proportions.
- **Foot sliding:** lock contacts. Video-to-motion output often slides.
- **Root motion:** decide whether it is in-place or root motion per clip, to match how the game
  moves characters.
- **Loops:** match the first and last poses. Check velocity continuity, not just the pose.
- **Polish pass:** hero animations (attacks, signature idles) get hand-keyed timing and spacing.
  Cascadeur's physics assistance helps here. Generated motion reads as floaty without it.
- **Log the performer** for capture, and the model for text-to-motion.
