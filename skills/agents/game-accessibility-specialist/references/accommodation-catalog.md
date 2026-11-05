# Accommodation Catalog (Accessibility Specialist reference)

Per-category specifications with the guideline each one maps to. XAG numbers refer to the Xbox
Accessibility Guidelines v3.2; "GAG" means the Game Accessibility Guidelines (basic, intermediate,
advanced). Example games are cited only for publicly documented, shipped features.

---

## 1. Motor

| Accommodation | Spec | Guideline |
|---|---|---|
| Full remapping | Every action, every device (keyboard, mouse, gamepad, touch), separate menu and gameplay maps, multiple saved profiles, no unbindable keys | XAG 107; GAG basic |
| Multi-binding | Same input on two non-conflicting actions; two inputs on one action | XAG 107 |
| Hold / toggle | Per-action choice for sprint, aim, crouch, block, charge | XAG 107; GAG basic |
| No mashing | Replace repeated presses with hold or auto-complete option | GAG basic |
| Dead zones and sensitivity | Per stick, per axis; invert per axis | XAG 107 |
| Input buffering | Accept inputs slightly early or late; adjustable window | -- |
| One-handed presets | Left-only and right-only gamepad layouts; one-hand keyboard zone | XAG 107 |
| Aim assist | Off / low / medium / high, per context (combat, interaction); lock-on option | XAG 108 |
| Timing | QTE extend / auto-complete / skip; parry window widen; game-speed slider | XAG 116 |
| Navigation assist | Auto-run, path guidance, optional skip of traversal challenges | XAG 108 |
| Touch targets | 44-48 pt/dp minimum; adjustable layout and size of on-screen controls | XAG 107 |
| Switch and adaptive devices | Everything playable with few buttons via remapping + toggles; test with Xbox Adaptive Controller-style setups | XAG 107 |

Benchmarks: Celeste's Assist Mode (game speed 50-100%, extra dashes, invincibility) framed in
the game as a legitimate way to play; The Last of Us Part II shipped with more than 60 accessibility
settings (Naughty Dog), including combat and navigation assists.

---

## 2. Visual

| Accommodation | Spec | Guideline |
|---|---|---|
| Text size | Console 26 px at 1080p / 52 px at 4K; PC 18 px / 36 px; mobile 18 px at 100 DPI linearly; measured ascender-to-descender | XAG 101 |
| Text scaling | Up to 200% of default without loss of content; at most one scroll direction per UI | XAG 101 |
| Text style | At least one sans-serif option; non-stylized alternative to decorative fonts; sentence case | XAG 101 |
| Contrast | Text and essential UI meet contrast targets against real backgrounds; outline or plate behind text | XAG 102 |
| Color redundancy | Shape, icon, pattern, or label on every color-coded element (teams, rarity, health, minimap) | XAG 103; GAG basic |
| Colorblind options | Palette presets for protan, deutan, tritan types, applied to gameplay elements (not a full-screen filter) | GAG intermediate |
| High contrast | Desaturated world; customizable highlight colors for player, allies, enemies, interactables, hazards | GAG intermediate |
| Screen narration | Menus, settings, dialogue, tooltips: name, role, value, position; platform TTS where available | XAG 106 |
| Audio description | Narration of key visual events in cinematics | XAG 111 |
| Motion | Sliders: screen shake, camera bob, motion blur, film grain, chromatic aberration, FOV | XAG 117 |
| Photosensitivity | No more than three flashes per second; avoid saturated red flashing; reduce-flash option; warning | XAG 118; WCAG 2.3.1 |
| Focus visibility | Unmistakable focus indicator on every interactive element | XAG 113 |

Prevalence (US National Eye Institute): red-green color vision deficiency is most common among
people of Northern European descent, up to about 1 in 12 men and 1 in 200 women; most cases are the
milder "anomalous" forms (protanomaly, deuteranomaly). Tritan types are rare.

Benchmarks: Ratchet & Clank: Rift Apart's high-contrast mode; Forza Horizon 5's screen narration.

---

## 3. Auditory

| Accommodation | Spec | Guideline |
|---|---|---|
| Subtitles | All spoken content; speaker named on change; direction marker for off-screen speakers | XAG 104 |
| Subtitle defaults | On by default, or configurable before the first sound plays | XAG 104 |
| Subtitle layout | At most two lines (three in exceptional cases), about 40 characters per line, manual line breaks, mixed case | XAG 104 |
| Subtitle style | Size from the XAG 101 minimum up to 200%; background color selectable; opacity 0-100%; preview in context | XAG 104 |
| Captions | Important non-speech sounds ("[music intensifies]", "<footsteps"), independently toggleable categories | XAG 104 |
| Visual cues | Every gameplay-relevant sound has a visual signal with equivalent warning time and direction | XAG 103 |
| Volume | Independent master, music, SFX, dialogue, ambience, UI | XAG 105 |
| Mono and dynamic range | Mono downmix; reduced dynamic range mode | XAG 105 |
| Haptics | Supplement for key cues; adjustable intensity; never the only channel | XAG 110 |
| Sign language | Interpreter overlay for cinematics, localized per sign language | XAG 104 |
| Communication | Speech-to-text and text-to-speech for voice and text chat | XAG 119, 120; CVAA |

Benchmarks: Forza Horizon 5's ASL and BSL interpreter overlays; Gears 5 enables subtitles on first
launch before the opening video and then presents accessibility settings (both cited in XAG 104).

---

## 4. Cognitive

| Accommodation | Spec | Guideline |
|---|---|---|
| Difficulty | Multiple axes (damage, enemy count, timing, hints) instead of one slider; change anytime; no content gated | XAG 108 |
| Respectful language | Name modes by experience ("Story") rather than judgment | XAG 108 |
| Objectives | Current objective on demand; history log; recap after absence | XAG 109 |
| Tutorials | Replayable; skippable; reference available from the pause menu | GAG basic |
| Simplification | Auto-sort, auto-equip, recommended builds, simplified crafting | GAG intermediate |
| Time limits | Adjustable, pausable, or removable | XAG 116 |
| Errors | Explain what happened and how to recover; confirm destructive actions | XAG 115 |
| Content warnings | Specific, before the scene, with skip or modify options | XAG 123 |
| Save anytime / pause anywhere | Especially in single player | GAG basic |
| Reading support | Adjustable text speed, re-read dialogue, line width and spacing options | XAG 101 |

Benchmarks: Hades' God Mode (damage resistance that grows with each death, available anytime,
no penalty to progress); Grounded's arachnophobia mode (spiders can be reduced to abstract shapes).

---

## 5. Settings architecture

- **First launch**: present text size, subtitles, and a short accessibility screen before the first
  cinematic or sound (Gears 5 pattern from XAG 104).
- **Presets**: "Standard", "Low vision", "Motor", "Deaf / hard of hearing", "Custom" -- presets set
  individual options that the player can then adjust.
- **Platform settings**: read system-level caption, text-size, reduced-motion, and high-contrast
  preferences where the platform exposes them, and use them as defaults.
- **Persistence**: settings and remaps persist across sessions, devices (if cloud saves exist),
  and patches. A patch that resets accessibility settings is a Critical bug.

---

## 6. Severity definitions for audits

| Severity | Definition | Example |
|---|---|---|
| Critical | A player in a disability group cannot progress or cannot use a purchase or chat feature | Unremappable required input; checkout not keyboard-operable |
| Major | Progress possible only with significant difficulty or outside help | Subtitles exist but cannot be resized |
| Minor | Friction or inconsistency | Focus ring missing on one settings page |
