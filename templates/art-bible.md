# Art Bible

> **Project:** [Working title]
> **Version:** [Document version]
> **Last Updated:** [Date]
> **Art Lead:** [Name]
> **Status:** [Draft / In Review / Approved]

---

## 1. Visual Identity

### Art Style
[Describe the overall visual style in 2-3 sentences. Is it realistic, stylized, pixel art, low-poly, painterly, cel-shaded?]

### Style Keywords
[5-7 adjectives that capture the visual tone, e.g., "warm, organic, hand-crafted, slightly exaggerated, nostalgic"]

### Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | [Color name] | [#XXXXXX] | [Main surfaces, dominant color] |
| Secondary | [Color name] | [#XXXXXX] | [Accents, UI highlights] |
| Accent | [Color name] | [#XXXXXX] | [Interactive elements, call-to-action] |
| Danger | [Color name] | [#XXXXXX] | [Damage, hazards, negative states] |
| Safe | [Color name] | [#XXXXXX] | [Healing, safe zones, positive states] |
| Neutral | [Color name] | [#XXXXXX] | [Backgrounds, non-interactive surfaces] |

### Mood & Atmosphere
[What emotional response should the visuals evoke? How does mood shift between areas, times of day, or story beats?]

- **Default mood:** [e.g., "Cozy and inviting with an undercurrent of mystery"]
- **Danger mood:** [e.g., "Colors desaturate, shadows deepen, fog rolls in"]
- **Victory mood:** [e.g., "Warm golden light, particle confetti, bloom increase"]

---

## 2. Character Design

### Proportions
[Define the character proportions for this project. Head-to-body ratio, level of stylization.]
- **Player character:** [e.g., "3.5 heads tall, exaggerated hands for readability"]
- **NPCs:** [e.g., "Similar proportions, distinguished by silhouette and color"]
- **Enemies:** [e.g., "Stockier or taller than player, always visually distinct at a glance"]

### Silhouette Rules
[Every character must be identifiable by silhouette alone at gameplay camera distance.]
- Unique head shape OR accessory for each character class
- Weapon/tool silhouette must differ between types
- Enemy silhouettes must communicate threat level

### Color Coding
| Faction/Role | Primary Color | Secondary Color | Notes |
|-------------|--------------|----------------|-------|
| Player | [Color] | [Color] | [Must stand out against all biome palettes] |
| Allies | [Color] | [Color] | [Warm, inviting tones] |
| Enemies | [Color] | [Color] | [Contrasts with player and environment] |
| Neutral NPCs | [Color] | [Color] | [Muted, non-threatening] |

### Animation Style
[Describe the feel of character animation. Snappy and responsive? Weighty and grounded? Floaty and dreamlike?]

---

## 3. Environment Design

### Biome Identity

| Biome | Color Palette | Key Materials | Mood | Landmark Type |
|-------|--------------|--------------|------|--------------|
| [Biome 1, e.g., Forest] | [Greens, browns, dappled gold] | [Wood, moss, stone] | [Peaceful, natural] | [Ancient trees, ruins] |
| [Biome 2, e.g., Desert] | [Warm oranges, pale sand, deep shadows] | [Sandstone, metal, glass] | [Harsh, vast, lonely] | [Rock formations, oases] |
| [Biome 3, e.g., Ruins] | [Grays, muted purples, teal accents] | [Cracked stone, overgrown vines, faded murals] | [Mysterious, reverent] | [Collapsed arches, statues] |

### Material Palette
[Define the material look for each major surface type.]
- **Stone/Rock:** [Texture quality, wear level, moss coverage]
- **Metal:** [Aged or polished? Rust level? Reflectivity?]
- **Wood:** [Grain visibility, color range, weathering]
- **Organic:** [Stylization level for plants, water, skin]

### Lighting Direction
- **Key light direction:** [e.g., "High angle, warm, slightly left"]
- **Ambient light:** [Color temperature, intensity]
- **Fill light:** [Complementary or contrasting?]
- **Time of day:** [Is there a day/night cycle? Fixed time?]
- **Interior lighting:** [Practical lights, ambient, or dramatic?]

---

## 4. UI Visual Language

### HUD Style
[Describe the HUD philosophy. Diegetic (in-world)? Minimal overlay? Full frame?]
- **Health display:** [Bar, hearts, screen vignette, character animation]
- **Resource display:** [Counters, meters, icons]
- **Minimap/compass:** [Style, information density]
- **Interaction prompts:** [Floating, screen-fixed, contextual]

### Icon Language
- **Style:** [Flat, outlined, glyph-based, illustrated]
- **Grid:** [Icon canvas size, safe area, stroke width]
- **Color rules:** [Monochrome with color accents? Full color? Rarity color borders?]

### Typography
| Usage | Font | Weight | Size Range | Notes |
|-------|------|--------|-----------|-------|
| Headings | [Font name] | [Bold/Regular] | [24-48px] | [Used for menu titles, section headers] |
| Body text | [Font name] | [Regular] | [14-18px] | [Dialogue, descriptions, tooltips] |
| UI labels | [Font name] | [Medium] | [12-16px] | [Button labels, stat names] |
| Numbers | [Font name] | [Bold] | [16-32px] | [Damage numbers, counters, timers] |

### Menu Design
[Navigation pattern, background treatment, transition style between screens.]

---

## 5. Asset Specifications

### Texture Resolutions
| Asset Type | Resolution | Format | Notes |
|-----------|-----------|--------|-------|
| Character textures | [2048x2048] | [PNG / TGA] | [Albedo, Normal, ORM packed] |
| Environment tileable | [1024x1024] | [PNG / TGA] | [Must tile seamlessly] |
| UI elements | [Variable] | [PNG, 9-slice where possible] | [2x for retina/4K] |
| Icons | [128x128] | [PNG with alpha] | [Exported from [icon canvas size] source] |
| Skybox / HDRI | [4096x2048] | [HDR / EXR] | [Per-biome] |

### Model Specifications
| Asset Type | Triangle Budget | LOD Levels | Notes |
|-----------|----------------|-----------|-------|
| Player character | [10k-20k tris] | [3 LODs] | [With skeleton and blend shapes] |
| NPCs | [5k-15k tris] | [2-3 LODs] | [Per-class variation] |
| Environment props | [500-5k tris] | [2 LODs] | [Modular, tileable where possible] |
| Foliage | [100-2k tris] | [2 LODs] | [Alpha-tested, wind animation] |

### Naming Convention
```
[category]_[name]_[variant]_[type].[ext]
Examples:
  char_player_idle_albedo.png
  env_tree_oak_01_mesh.fbx
  ui_btn_primary_normal.png
  fx_fire_loop_spritesheet.png
```

---

## 6. Reference Board

[Link or embed reference images organized by category.]

### Style References
- [Reference 1]: [What to take from it — e.g., "Color grading and lighting mood"]
- [Reference 2]: [What to take from it — e.g., "Character proportions and silhouette style"]
- [Reference 3]: [What to take from it — e.g., "Environment scale and density"]

### Anti-References
- [Reference A]: [What to AVOID — e.g., "Too realistic, uncanny valley risk"]
- [Reference B]: [What to AVOID — e.g., "Too noisy, visual clarity suffers"]

---

## 7. Technical Constraints

- **Render pipeline:** [URP / HDRP / Godot Forward+ / UE5 Nanite+Lumen]
- **Target framerate:** [30 / 60 / 120 fps]
- **Draw call budget:** [Per frame estimate]
- **Memory budget:** [Texture memory, mesh memory]
- **Platform-specific notes:** [Mobile texture compression, console resolution targets]
