# Rendering and Shaders (Godot 4.7)

Reference for `game-godot-specialist`. Art direction and asset budgets belong to
`/gameforge:game-art-director`; this file covers how Godot renders and how to write shaders for it.

## 1. Pick the renderer first

| Renderer | Backends | Targets | Choose it for |
|---|---|---|---|
| Forward+ | Vulkan, Direct3D 12, Metal | Desktop | 3D with many lights, SSR, SDFGI, volumetric fog |
| Mobile | Vulkan, Direct3D 12, Metal | Phones, tablets, standalone XR, lower-end desktop | Simpler 3D on tile-based GPUs |
| Compatibility | OpenGL 3.3, OpenGL ES 3.0, WebGL 2 | Web, old hardware, most 2D games | Web builds (the only option there), widest hardware reach |

Switching renderer late means retuning lights, materials and post-processing. Decide in the first
week, record it in an ADR (`/gameforge:game-technical-director`), and test on the weakest target early.

Rendering features by version (from the release notes):

| Version | Feature | Note |
|---|---|---|
| 4.5 | Shader baker | Precompiles shaders at export; enable it in every desktop and mobile preset |
| 4.5 | Stencil buffer | Meshes write and compare stencil values: x-ray silhouettes, portals, cut-outs |
| 4.6 | SSR overhaul | More stable, faster reflections; full- or half-resolution mode |
| 4.7 | HDR output | Windows, macOS, iOS, visionOS, Linux (Wayland). Test on both HDR and SDR displays |
| 4.7 | `AreaLight3D` | Real-time rectangular lights with softer shadows than emissive surfaces plus GI |
| 4.7 | `DrawableTexture2D` | Draw into textures without Viewport or RenderingDevice workarounds (paint, decals, fog of war) |
| 4.8 beta | Contact shadows | Screen-space contact shadows, an option on Environment and DirectionalLight3D |
| 4.8 beta | Texture streaming | Loads only the mip levels needed; large VRAM savings for big worlds |
| 4.8 beta | `Trail3D` | Native 3D trails for swords, projectiles and vehicles |

Global illumination, cheapest first: `LightmapGI` (baked, static scenes, best performance), then
`VoxelGI` (semi-dynamic, bounded areas), then SDFGI (Forward+ only, large open scenes).
`ReflectionProbe`s are cheap and fix most "metal looks flat" complaints.

## 2. 2D rendering notes

- Pixel art: set the default canvas texture filter to *Nearest*, use the `viewport` or
  `canvas_items` stretch mode, and integer scaling when the art must stay crisp.
- HUD and menus live on a `CanvasLayer` so the camera does not move them.
- Use `TileMapLayer` nodes (4.3+); the old multi-layer `TileMap` node is deprecated.
- `y_sort_enabled` on a parent sorts top-down sprites by Y without manual `z_index` juggling.
- 2D lights and shadows cost fill rate per light; budget them on mobile and web.

## 3. Shader rules that prevent surprises

- Shader types: `spatial` (3D), `canvas_item` (2D and UI), `particles`, `sky`, `fog`.
- Color textures need `source_color` (sRGB); data textures (normal, ORM, noise) must not have it.
- **Writing `ALPHA` in a spatial shader moves the material to the transparent pipeline**: sorting
  problems, no depth pre-pass. For cut-outs (foliage, fences, dissolves) use `discard` or
  `ALPHA_SCISSOR_THRESHOLD` instead.
- Materials are shared Resources. Animating a uniform on one enemy animates all of them unless you
  duplicate the material, enable *Local to Scene* on it, or use an `instance uniform` (spatial
  shaders; set with `GeometryInstance3D.set_instance_shader_parameter()`).
- Set uniforms with `material.set_shader_parameter(&"name", value)`; tween them through the property
  path `"shader_parameter/name"`.
- Shader compilation stutter on first use is the most common "it hitches the first time" report:
  enable the shader baker and warm up effects behind a loading screen.
- Visual Shaders are a good fit for artists; code shaders are easier to review, diff and test.

## 4. Shader samples

**2D hit flash** (`canvas_item`):

```glsl
shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV) * COLOR;   // keep modulate and vertex color
	COLOR = vec4(mix(tex.rgb, flash_color.rgb, flash_amount), tex.a);
}
```

```gdscript
# On the character; the sprite's ShaderMaterial has Local to Scene enabled.
func flash() -> void:
	var mat := _sprite.material as ShaderMaterial
	mat.set_shader_parameter(&"flash_amount", 1.0)
	create_tween().tween_property(mat, "shader_parameter/flash_amount", 0.0, 0.12)
```

**Inverted-hull outline** (`spatial`, assign as the `next_pass` of the main material):

```glsl
shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 0.1) = 0.02;   // model units

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
```

Hard edges with split normals open gaps in the hull; export smoothed normals for the outline mesh
or use a stencil-based outline (4.5+) instead.

**Dissolve with glowing edge** (`spatial`):

```glsl
shader_type spatial;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform sampler2D noise_texture : hint_default_white;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.2) = 0.04;
uniform vec4 edge_color : source_color = vec4(1.0, 0.45, 0.1, 1.0);
uniform float edge_energy : hint_range(0.0, 16.0) = 4.0;

void fragment() {
	float n = texture(noise_texture, UV).r;
	if (n < dissolve) {
		discard;
	}
	ALBEDO = texture(albedo_texture, UV).rgb;
	float edge = 1.0 - smoothstep(dissolve, dissolve + edge_width, n);
	EMISSION = edge_color.rgb * edge * edge_energy * step(0.0001, dissolve);
}
```

```gdscript
func play_death() -> void:
	var mat := (_mesh.get_active_material(0) as ShaderMaterial).duplicate() as ShaderMaterial
	_mesh.material_override = mat
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/dissolve", 1.0, 0.6)
	await tween.finished
	queue_free()
```

**PBR surface with packed ORM** (`spatial`; R = occlusion, G = roughness, B = metallic):

```glsl
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_strength : hint_range(-16.0, 16.0) = 1.0;
uniform sampler2D orm_texture : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float roughness_scale : hint_range(0.0, 1.0) = 1.0;
uniform float metallic_scale : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D emission_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float emission_energy : hint_range(0.0, 16.0) = 0.0;

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * albedo_tint.rgb;
	vec3 orm = texture(orm_texture, UV).rgb;
	AO = orm.r;
	ROUGHNESS = orm.g * roughness_scale;
	METALLIC = orm.b * metallic_scale;
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
	EMISSION = texture(emission_texture, UV).rgb * emission_energy;
}
```

No `ALPHA` write, so the material stays in the opaque pipeline. Most surfaces do not need a custom
shader at all: `StandardMaterial3D` covers ORM packing and is cheaper to maintain. Write a custom
shader when you need behavior the standard material lacks.
