# Sound Bible

> **Project:** [Working title]
> **Version:** [Document version]
> **Last Updated:** [Date]
> **Audio Lead:** [Name]
> **Status:** [Draft / In Review / Approved]

---

## 1. Sonic Identity

[Describe the overall sound of the game in 2-3 sentences. What does this game *sound* like? Close your eyes and imagine the player's experience through audio alone.]

### Sonic Keywords
[5-7 descriptive words that capture the audio tone, e.g., "organic, layered, warm, percussive, mysterious, intimate"]

### Texture Palette
[What textures dominate the soundscape?]
- **Primary textures:** [e.g., "Wooden creaks, cloth rustles, stone scrapes"]
- **Secondary textures:** [e.g., "Metallic chimes, water drips, wind gusts"]
- **Avoided textures:** [e.g., "Synthetic beeps, harsh digital noise, orchestral bombast"]

### Frequency Range Focus
- **Low end (sub-bass, bass):** [Role — e.g., "Grounding, weight, impact. Used sparingly for emphasis."]
- **Midrange:** [Role — e.g., "Primary space for dialogue, UI, and core gameplay sounds."]
- **High end (presence, air):** [Role — e.g., "Ambience, sparkle, feedback clarity."]

---

## 2. Music Direction

### Themes

| Theme | Usage | Mood | Key Instruments |
|-------|-------|------|----------------|
| Main theme | Title screen, trailer, victory | [Mood description] | [Instruments list] |
| Exploration | Overworld, safe areas | [Mood description] | [Instruments list] |
| Combat | Encounters, boss fights | [Mood description] | [Instruments list] |
| Tension | Stealth, puzzles, danger | [Mood description] | [Instruments list] |
| Emotional | Story beats, character moments | [Mood description] | [Instruments list] |

### Adaptive Music System

[How does music respond to gameplay?]

- **Layers:** [Which instruments/stems add or remove based on intensity?]
- **Transitions:** [Crossfade duration, musical transition points, stingers]
- **Intensity levels:** [e.g., "Level 1: ambient pad only. Level 2: add rhythm. Level 3: full orchestration."]
- **Trigger conditions:** [What gameplay events change music state?]

### Instrumentation Palette
- **Core instruments:** [e.g., "Acoustic guitar, cello, hand percussion, woodwinds"]
- **Accent instruments:** [e.g., "Music box, dulcimer, bowed vibraphone"]
- **Prohibited instruments:** [e.g., "Electric guitar, drum kit, EDM synths"]

### Tempo & Key Guidelines
- **Default BPM range:** [e.g., "70-90 BPM for exploration, 120-140 for combat"]
- **Key preferences:** [e.g., "Minor keys for exploration, relative major for victories"]

---

## 3. SFX Categories

### UI Sounds

| Action | Description | Character |
|--------|------------|-----------|
| Button hover | [Brief, light] | [e.g., "Soft wooden tap"] |
| Button press | [Confirmation feel] | [e.g., "Satisfying click with resonance"] |
| Menu open | [Transition in] | [e.g., "Page unfold, slight reverb"] |
| Menu close | [Transition out] | [e.g., "Soft close, inverse of open"] |
| Error/invalid | [Gentle rejection] | [e.g., "Muted thud, not harsh"] |
| Notification | [Attention grab] | [e.g., "Chime, warm, not alarming"] |
| Item acquired | [Reward] | [e.g., "Crystalline sparkle, ascending pitch"] |

### Combat Sounds

| Action | Description | Variation Notes |
|--------|------------|----------------|
| Melee hit (light) | [Impact feel] | [Minimum 3 variations to avoid repetition] |
| Melee hit (heavy) | [Weightier impact] | [Minimum 3 variations] |
| Ranged fire | [Projectile launch] | [Per-weapon type variation] |
| Ranged impact | [Projectile hit] | [Surface-dependent: flesh, stone, metal, wood] |
| Block/parry | [Deflection] | [Must feel rewarding] |
| Critical hit | [Emphasis impact] | [Layered: base hit + special accent] |
| Death/defeat | [Finality] | [Player death vs enemy death differentiation] |

### Environment Sounds

| Biome/Area | Ambient Loop | One-Shots | Notes |
|-----------|-------------|-----------|-------|
| [Forest] | [Birds, rustling leaves, distant stream] | [Branch snap, animal call, wind gust] | [Layered, time-of-day variation] |
| [Desert] | [Wind, sand shift, distant heat hum] | [Rock crumble, insect buzz] | [Sparse, emphasizing silence] |
| [Interior] | [Room tone, echo, creaks] | [Drip, distant voice, door] | [Reverb reflects room size] |

### Character Sounds

| Action | Description | Notes |
|--------|------------|-------|
| Footsteps | [Surface-reactive] | [Grass, stone, wood, metal, water — per-surface variation] |
| Jump | [Takeoff effort] | [Fabric rustle + vocal effort] |
| Land | [Impact, weight] | [Light landing vs heavy, surface-dependent] |
| Hurt/damage | [Pain expression] | [Gendered and severity variation, not gratuitous] |
| Idle | [Subtle presence] | [Breathing, weight shift, equipment rattle] |

---

## 4. Spatial Audio Rules

- **3D falloff model:** [Linear / Logarithmic / Custom curve]
- **Max audible distance:** [Default range for gameplay sounds, e.g., 30 meters]
- **Occlusion:** [How do walls and obstacles affect sound? Low-pass filter? Volume reduction?]
- **Reverb zones:** [Per-area reverb presets — cave, forest, cathedral, small room]
- **Priority system:** [Which sounds take priority when the channel limit is reached?]
  1. [Player actions — always heard]
  2. [Combat — high priority]
  3. [NPC dialogue — high priority]
  4. [Environment — medium priority]
  5. [Ambient detail — low priority, first to be culled]

---

## 5. Silence Design

[Silence is a sound design tool. Define where and how silence is used intentionally.]

- **Before boss fights:** [Music fades, ambience reduces to near-silence before the encounter begins]
- **After major events:** [Brief silence after an explosion, death, or revelation for emotional weight]
- **Safe spaces:** [Reduced ambient density, gentle room tone, no music — a sonic "rest"]
- **Horror/tension:** [Remove familiar sounds to create unease]

---

## 6. Implementation Notes

### Middleware
- **Audio engine:** [FMOD / Wwise / Native engine audio / other]
- **Integration plugin version:** [e.g., "FMOD for Unity 2.02.xx"]

### RTPC Parameters (Real-Time Parameter Control)

| Parameter | Range | Controls | Driven By |
|-----------|-------|----------|-----------|
| [Player_Health] | [0.0 - 1.0] | [Heartbeat intensity, music tension layer] | [Health system] |
| [Combat_Intensity] | [0.0 - 1.0] | [Music layer activation, SFX density] | [Enemies in range, damage dealt/taken] |
| [Time_of_Day] | [0.0 - 24.0] | [Ambient loop crossfade, bird density] | [Day/night cycle] |
| [Environment_Type] | [Enum] | [Reverb preset, ambient source selection] | [Current biome/area] |

### Mix Targets

| Bus/Category | Target Level (dB) | Notes |
|-------------|-------------------|-------|
| Music | [-12 to -6] | [Ducks under dialogue] |
| SFX | [-6 to 0] | [Primary gameplay feedback] |
| Dialogue | [0 to -3] | [Always audible, highest priority] |
| Ambience | [-18 to -12] | [Background layer, never competes] |
| UI | [-9 to -3] | [Clear but not dominant] |

### File Specifications
- **Format:** [WAV for source, OGG/OPUS for runtime, platform-specific compression]
- **Sample rate:** [44.1kHz / 48kHz]
- **Bit depth:** [16-bit / 24-bit for source]
- **Naming convention:** [e.g., `sfx_combat_sword_hit_01.wav`, `mus_exploration_forest_layer_strings.wav`]

---

## 7. Reference Tracks

| Reference | Usage | What to Emulate |
|-----------|-------|----------------|
| [Game/Film/Album 1] | [Music reference] | [Specific quality — e.g., "Instrument palette and intimacy"] |
| [Game/Film/Album 2] | [SFX reference] | [Specific quality — e.g., "Impact weight and crunch"] |
| [Game/Film/Album 3] | [Ambience reference] | [Specific quality — e.g., "Layered natural soundscapes"] |
| [Game/Film/Album 4] | [Anti-reference] | [What to AVOID — e.g., "Too cinematic, overwhelming the gameplay"] |
