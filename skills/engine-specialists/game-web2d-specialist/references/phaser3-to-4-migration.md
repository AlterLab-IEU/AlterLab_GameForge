# Phaser 3 to Phaser 4 Migration

Source: the official guide shipped inside the package at
`node_modules/phaser/changelog/v4/4.0/MIGRATION-GUIDE.md` (read from `phaser@4.2.1`), the Phaser
4 release notes, and the Phaser 4.2.1 source (FilterList factory names). The same package ships
an agent-readable skill at `node_modules/phaser/skills/v3-to-v4-migration/`. Point coding agents
at those two files: they match the installed version exactly.

## 1. Does the project need migrating?

- Uses only Sprites, Text, Tilemaps, Arcade, Tweens, Cameras (scroll/zoom/rotation): the new
  renderer "should work transparently". Upgrade, run the checklist, fix what breaks.
- Uses custom pipelines, FX, BitmapMask, Mesh/Plane, raw WebGL, camera matrices, compressed
  textures or `Math.TAU`: budget real migration time and do it on a branch.
- A finished Phaser 3 game near launch: ship on 3, migrate the next project.

## 2. Highest-impact changes

| Area | Phaser 3 | Phaser 4 |
|---|---|---|
| Renderer | Pipelines (`WebGLPipeline`, `PostFXPipeline`, `setPipeline`) | **RenderNodes**, one task per node, registered via `RenderConfig#renderNodes` |
| Raw WebGL | Direct `gl` calls in pipelines | Do not call `gl` directly; use an `Extern` game object (resets state afterwards) |
| Canvas renderer | Supported | **Deprecated**; use WebGL for all new projects. Canvas keeps 27 blend modes; WebGL's `Blend` filter can recreate them |
| FX | `preFX` / `postFX` on supported objects | **Filters**: `filters.internal` (object space) and `filters.external` (screen space) on any game object or camera |
| Enabling | Automatic on supported objects | Game objects call `enableFilters()` first; cameras have filters by default |
| Masks | `BitmapMask`, `GeometryMask` | `filters.internal.addMask(maskObject)`; `GeometryMask` remains Canvas-only |
| Derived FX | `Bloom`, `Shine`, `Circle`, `Gradient` FX | `Phaser.Actions.AddEffectBloom()`, `AddEffectShine()`, `AddMaskShape()`, `Gradient` game object |
| ColorMatrix | `colorMatrix.sepia()` | `colorMatrix.colorMatrix.sepia()` |
| Tint | `setTintFill(c)`, `tintFill` | `setTint(c).setTintMode(Phaser.TintModes.FILL)`; modes `MULTIPLY`, `FILL`, `ADD`, `SCREEN`, `OVERLAY`, `HARD_LIGHT` |
| Lighting | `setPipeline('Light2D')` | `setLighting(true)`; lights get an explicit `z`; optional self-shadows; lighting breaks batches |

Filter factory methods in 4.2.1 (`FilterList`): `addBarrel`, `addBlend`, `addBlocky`, `addBlur`,
`addBokeh`, `addColorMatrix`, `addCombineColorMatrix`, `addDisplacement`, `addGlow`,
`addGradientMap`, `addImageLight`, `addKey`, `addMask`, `addNormalTools`, `addPanoramaBlur`,
`addPixelate`, `addQuantize`, `addSampler`, `addShadow`, `addThreshold`, `addTiltShift`,
`addVignette`, `addWipe`.

```ts
// v3
sprite.preFX!.addGlow(0xff00ff, 4);
sprite.postFX!.addBlur(0, 2, 2, 1);
sprite.setMask(new Phaser.Display.Masks.BitmapMask(scene, maskImage));

// v4 (type-checked against phaser@4.2.1)
sprite.enableFilters();
sprite.filters!.internal.addGlow(0xff00ff, 4, 0, 1);
sprite.filters!.external.addBlur(0, 2, 2, 1);
sprite.filters!.internal.addMask(maskImage);
this.cameras.main.filters.internal.addBlur(0, 2, 2, 1); // cameras: no enableFilters() needed
```

## 3. Rendering details

| Area | Change |
|---|---|
| Texture orientation | GL convention, Y=0 at the bottom. PNG/JPG are handled automatically; **compressed textures must be re-exported with Y flipped**; custom shaders see GL texture coordinates |
| Camera matrices | `Camera#matrix` = rotation + zoom + scroll (no position); new `matrixExternal` (position) and `matrixCombined`. Only matters if you read matrices directly |
| DynamicTexture / RenderTexture | Drawing is buffered: **call `render()`**; `preserve()`, `callback()`, `capture()`; `RenderTexture.renderMode` (`render`, `redraw`, `all`) |
| Shader game object | New `ShaderQuadConfig` constructor; Shadertoy-style uniforms no longer automatic; `setUniform(name, value)`; `renderImmediate` |
| GLSL loading | No fragment/vertex classification; `#pragma` directives replace custom templates |
| TileSprite | No texture cropping; supports atlas frames; `tileRotation` |
| Graphics / Shape | `pathDetailThreshold`; `Grid` uses `stroke` not `outline`; rounded `Rectangle` |
| roundPixels | Default **false** (was true); only applies to axis-aligned, unscaled objects; per object `vertexRoundMode` |
| Removed objects | `Mesh`, `Plane`; Camera3D and Layer3D plugins. Use three.js for 3D (`game-threejs-specialist`) |
| Spine | Bundled Spine 3/4 plugins no longer updated; use the official Phaser Spine plugin from Esoteric Software (4.2 added a new Spine backend) |

## 4. API removals and renames

| Phaser 3 | Phaser 4 |
|---|---|
| `Phaser.Geom.Point` and helpers | `Phaser.Math.Vector2` (`Point.GetMagnitude` -> `Vector2.length`, `Point.Interpolate` -> `Math.LinearXY`, `Point.GetRectangleFromPoints` -> `Math.GetVec2Bounds`, `Point.GetCentroid` -> `Math.GetCentroid`) |
| Geometry helpers returning `Point` | Return `Vector2`; update `instanceof Phaser.Geom.Point` checks |
| `Math.TAU` (was pi/2) | `Math.TAU` is now 2*pi; use `Math.PI_OVER_2` for pi/2 |
| `Math.PI2` | Removed; use `Math.TAU` |
| `Phaser.Struct.Set`, `Phaser.Struct.Map` | Native `Set`, `Map` (`iterateLocal`, `contains`, `setAll` gone) |
| `Create.GenerateTexture`, `TextureManager.generate` | Removed; draw with `Graphics` and call `generateTexture()` |
| `Math.SinCosTableGenerator` | Removed |
| `WebGLRenderer.textureIndexes` | `glTextureUnits.unitIndices` |
| `genericVertexBuffer` / `genericVertexData` | Removed (frees ~16 MB RAM/VRAM) |
| Polyfills (`requestAnimationFrame`, `performance.now`, etc.) and `phaser-ie9.js` | Removed |
| Facebook plugin detection | Removed |
| `Shader#setTextures()` adding textures | Replaces the whole array |
| `DOMElement` without a container | Throws; give it a parent container |
| Gamepad `Button` | Accepts `isPressed` to initialize state across scene transitions |

## 5. Packaging (Phaser 4.1+)

- `import Phaser from 'phaser'` works through the ESM default export (from 4.1); the package
  `exports` point at `dist/phaser.esm.js` and types at `types/phaser.d.ts`.
- Do not mix a CDN `<script>` tag with an npm import; pin `phaser@4.2.1` in `package.json`.
- New objects worth adopting during migration: `SpriteGPULayer`, `TilemapGPULayer`,
  `CaptureFrame`, `Gradient`, `Noise`, `Stamp`; 4.2 adds `Mesh2D` and Stencil.

## 6. Migration procedure (agent-friendly)

1. Branch. Record the v3 version and take Playwright screenshots of every scene at fixed seeds
   (see `testing-portal-readiness.md`); these are the visual baseline.
2. `npm install --save-exact phaser@4.2.1`; run `npx tsc --noEmit` and list every type error.
3. Grep for the v3 patterns:
   ```bash
   grep -rnE "preFX|postFX|BitmapMask|setTintFill|tintFill|setPipeline|Pipeline\b|Geom\.Point|Math\.TAU|Math\.PI2|Struct\.(Set|Map)|add\.mesh|Plane\(|GenerateTexture|roundPixels" src/
   ```
4. Fix one category per commit (`refactor(render): replace preFX with filters`), re-running
   type-check and the scene screenshots after each.
5. Re-export compressed textures (flip Y). Re-check pixel art (`roundPixels` default changed).
6. Rewrite custom pipelines last: try a built-in Filter first, then a RenderNode, then `Extern`.
7. Compare screenshots against the v3 baseline; accept intended differences explicitly with
   `--update-snapshots`.

## 7. Official checklist (condensed)

- [ ] `phaser@4` installed; no CDN copy
- [ ] Custom WebGL pipelines replaced with render nodes (or filters / `Extern`)
- [ ] `BitmapMask` replaced with the Mask filter
- [ ] Removed FX (`Bloom`, `Shine`, `Circle`, `Gradient`) replaced with Actions or the `Gradient` object
- [ ] `ColorMatrix` calls moved to `.colorMatrix`
- [ ] `setTintFill()` replaced with `setTint().setTintMode(Phaser.TintModes.FILL)`
- [ ] `Geom.Point` replaced with `Vector2`
- [ ] `Math.TAU` usages audited (now 2*pi); `Math.PI2` replaced
- [ ] `Phaser.Struct.Set/Map` replaced with native `Set/Map`
- [ ] `render()` added to `DynamicTexture` / `RenderTexture` usage
- [ ] Compressed textures re-compressed for the new Y orientation
- [ ] Direct `Camera#matrix` access updated
- [ ] `Shader` objects use `ShaderQuadConfig`; GLSL loading uses `#pragma` directives
- [ ] `setPipeline('Light2D')` replaced with `setLighting(true)`; light heights use `z`
- [ ] `TileSprite` cropping removed; `Grid` `outline` properties renamed to `stroke`
- [ ] `Mesh` / `Plane` removed; bundled Spine plugin replaced with Esoteric's official plugin
- [ ] `Create.GenerateTexture` / `TextureManager.generate` removed
- [ ] `roundPixels` behavior tested (default now `false`)
- [ ] Custom shader texture coordinates verified (Y=0 at bottom)
