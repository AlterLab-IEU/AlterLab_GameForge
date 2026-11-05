# HUD, Menu, and Input Patterns (UX Designer reference)

The catalog behind the UX Designer skill. Use it while designing; cite the pattern name in specs so
the art director and coding agents share vocabulary.

---

## 1. Information hierarchy during gameplay

| Tier | Content | Visibility | Rules |
|---|---|---|---|
| 1 Survival | Health, shields, ammo, immediate threats | Always | 3-4 elements maximum; peripheral; high contrast; readable in under a second |
| 2 Tactical | Minimap, cooldowns, objective marker, teammates | Contextual | Appears when relevant, fades in calm moments |
| 3 Strategic | Full map, inventory, quest log, stats, settings | On demand (pause/overlay) | Can be dense; supports search and sorting |
| 4 Meta | Leaderboards, achievements, social, store | Outside gameplay | Never overlays play; never interrupts a run |

Test: freeze a frame mid-combat and ask a tester what each element means and which one matters
right now. If they need more than a glance for Tier 1, it is too small, too far, or too busy.

---

## 2. HUD paradigms

| Paradigm | Example | Strength | Cost |
|---|---|---|---|
| Diegetic | Dead Space's spine-mounted health bar; in-car dashboards | Immersion, zero clutter | Harder to read; needs art integration; fails for dense data |
| Non-diegetic | Health bars, ammo counters | Clear, customizable | Breaks immersion; can clutter |
| Spatial | Floating damage numbers, waypoints, name tags | Contextual position | Occludes play; scaling with distance |
| Meta | Achievement toasts, connection status | System communication | Breaks the fourth wall; use sparingly |

Pick a primary paradigm per game and justify each exception. Coordinate the visual treatment with
the art director and the information priority with the game designer.

---

## 3. Menu navigation patterns

| Pattern | Use for | Controller mapping | Limits |
|---|---|---|---|
| List / grid | Settings, equipment, level select | D-pad/stick steps; bumpers switch pages | Long lists need jump-to or filters |
| Tabs + list | Character, inventory, map, journal | Bumpers or triggers switch tabs | Keep tab count under about seven |
| Radial / wheel | Weapon or emote quick-select | Stick direction selects; release confirms | Under about 12 items; hard for some motor disabilities -- offer a list alternative |
| Cursor | Strategy, management, inventory grids with spatial meaning | Mouse; stick-cursor only when spatial precision matters | Slow on controller; add snapping |

**Controller-first rules**
- Fully navigable with directional input plus confirm/cancel.
- Default focus on the most likely action; destructive actions never default.
- Focus is unmistakable: border plus scale or glow, never a subtle tint alone.
- Menu depth of three levels or fewer; flatten with tabs and spatial layouts.
- One-press shortcuts for frequent screens (map, inventory).
- Back always works and never loses unsaved changes without asking.

**Mouse and keyboard on top of controller-first**: hover tooltips (with a non-hover equivalent),
right-click context menus, drag with a non-drag alternative, full keyboard navigation.

---

## 4. Touch controls (mobile web and mobile apps)

| Control | Pattern | Notes |
|---|---|---|
| Movement | Floating virtual stick (spawns where the thumb lands, left half) | Fixed sticks fail for different hand sizes |
| Camera | Drag on the right half; optional gyro | No pointer lock on iPhone Safari: drag-to-look is the default |
| Actions | 1-3 large buttons in the right thumb arc | 44-48 pt/dp minimum; spaced to avoid mis-taps |
| Menus | Bottom-anchored lists, large rows | Top corners are hard to reach one-handed |
| Pause | Visible on-screen button inside the safe area | There is no Start button on a phone |

- Respect safe-area insets (notches, home indicator): `env(safe-area-inset-*)` in CSS overlays.
- No information only on hover; no essential long-press without an alternative.
- Let players resize and move on-screen controls if the game is input-heavy.
- Show touch prompts on touch devices, keyboard prompts on keyboards, and switch when the last input
  changes.

---

## 5. Input prompts and remapping

- Prompts render from the current binding, never hard-coded glyph images.
- Glyph set follows the last-used device family (Xbox, PlayStation, Switch, keyboard, touch).
- Remaps apply in tutorials, loading tips, and contextual prompts.
- Glyph text inside icons meets the same minimum size as body text (XAG 101) and scales with it.

---

## 6. Feedback language

| Event | Visual | Audio | Haptic | Timing |
|---|---|---|---|---|
| Input accepted | Button depress, animation start | Click/tick | Optional light pulse | Within about 50 ms (rule of thumb) |
| Damage taken | Directional indicator + health change | Hit sound + vocal | Pulse scaled to damage | Immediate |
| Resource gained | Counter tick + fly-to-HUD | Pickup sound by rarity | none | Under 300 ms to reach HUD |
| Error / not allowed | Shake + short label why | Gentle denial | none | Immediate; never a buzzer loop |
| Irreversible action | Modal with what is lost | Low tone | Short pulse | Requires deliberate confirm |

Probability honesty: if a 5% roll looks like a coin flip, players stop trusting the system.

---

## 7. Settings menu structure (default)

```
Settings
  Accessibility   (first tab, also offered on first launch)
  Controls        (remap per device, sensitivity, hold/toggle, vibration)
  Display         (text size, subtitles, contrast, motion, brightness, safe area)
  Audio           (master, music, SFX, dialogue, ambience, UI, mono, dynamic range)
  Gameplay        (difficulty and assists, language, AI features disclosure if any)
```

Every setting shows a one-line description of its effect and a live preview where possible
(subtitle preview in a real game context, per XAG 104).

---

## 8. Responsive layouts

| Target | Rule |
|---|---|
| 16:9 reference (1920x1080) | Design here first, with a 5% title-safe margin for TVs |
| 4K | Scale by resolution; do not just add empty space |
| 1280x720 / Steam Deck class | Check Tier 1 legibility; simplify Tier 2 |
| 21:9 ultrawide | Keep HUD inside a centered 16:9 frame or offer a HUD-width setting |
| Phone portrait / landscape | Separate layouts, not scaled desktop; thumb zones drive placement |
| Browser windows of arbitrary size | Letterbox the game canvas; keep HTML UI responsive |
