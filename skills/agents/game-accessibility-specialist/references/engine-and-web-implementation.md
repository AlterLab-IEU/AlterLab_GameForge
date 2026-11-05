# Engine and Web Implementation Patterns (Accessibility Specialist reference)

Sketches for the technical director, engine specialist, or coding agent. Verify API names against
the engine version in `.gameforge/project.json`; experimental features change between minor releases.

---

## 1. Architecture that keeps accessibility cheap

| System | Build it as | Unlocks |
|---|---|---|
| Input | Actions, not keys: gameplay reads `jump`, never `Space` | Remapping, one-handed presets, toggles, switch devices |
| Text | One text component with global scale, font, spacing, and contrast plate | Text scaling, dyslexia-friendly fonts, high contrast |
| Audio events | A registry: event id -> sound, caption string, direction flag, visual cue id | Captions, visual cues, mono and dynamic range |
| Difficulty | Named, independent parameters (damage taken, timing windows, game speed) | Assists without a separate "easy mode" code path |
| UI navigation | A focus graph independent of mouse hover | Controller, keyboard, switch, and screen-reader navigation |
| Settings | Data-driven schema persisted on change | Presets, platform defaults, no loss on patch |

---

## 2. Godot (4.5 and later; current stable 4.7)

**Remapping with InputMap and ConfigFile**
```gdscript
const SAVE_PATH := "user://input.cfg"

func rebind(action: StringName, event: InputEvent) -> void:
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, event)
    var cfg := ConfigFile.new()
    cfg.load(SAVE_PATH)                      # ignore error on first run
    cfg.set_value("input", action, event)
    cfg.save(SAVE_PATH)

func load_bindings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) != OK:
        return
    for action in cfg.get_section_keys("input"):
        InputMap.action_erase_events(action)
        InputMap.action_add_event(action, cfg.get_value("input", action))
```

**Screen readers (AccessKit, experimental since 4.5)**
- Control nodes expose `accessibility_name`, `accessibility_description`, and `accessibility_live`
  (live-region update mode), plus relationship properties such as `accessibility_labeled_by_nodes`
  and `accessibility_described_by_nodes`.
- Set `accessibility_name` on icon-only buttons; set `accessibility_live` on labels that update while
  focus is elsewhere (objective text, toasts) so they are announced.
- Use standard Control nodes for menus; custom-drawn UI needs explicit names and focus handling.
- The editor's support (Project Manager, standard UI nodes, inspector) is partial; blind team members
  may still need workarounds for scene editing.
- Web exports use the Compatibility renderer and a canvas: test screen-reader behavior in the browser
  separately rather than assuming desktop behavior carries over.

**Text scaling**: drive a project-wide Theme's default font size from the setting, and design
containers with `size_flags` and minimum sizes so 200% text reflows instead of clipping.

---

## 3. Unity (6.3 LTS / 6.6)

**Remapping with the Input System**
```csharp
using UnityEngine.InputSystem;

public void Rebind(InputActionReference action, int bindingIndex)
{
    action.action.Disable();
    action.action.PerformInteractiveRebinding(bindingIndex)
        .WithCancelingThrough("<Keyboard>/escape")
        .OnComplete(op =>
        {
            op.Dispose();
            action.action.Enable();
            PlayerPrefs.SetString("bindings", action.action.actionMap.asset.SaveBindingOverridesAsJson());
        })
        .Start();
}
// On startup: asset.LoadBindingOverridesFromJson(PlayerPrefs.GetString("bindings"));
```

**Screen readers**: the `UnityEngine.Accessibility` module builds an `AccessibilityHierarchy` of
`AccessibilityNode`s (label, role, state) assigned to `AssistiveSupport.activeHierarchy`. The
hierarchy is separate from the UI tree and is walked depth-first; reassign it whenever the screen
reader turns on, and send layout or screen-changed notifications through
`AssistiveSupport.notificationDispatcher` after changes. `AssistiveSupport.isScreenReaderEnabled` and
the `screenReaderStatusChanged` event tell you when to build or drop the hierarchy. The Unity 6.6
docs list Android (8.0 / API 26 and later), iOS, macOS, and Windows players as supported; web and
console builds need another route (DOM UI for web, platform TTS for consoles). Re-check the list for
your exact version before promising a platform.

---

## 4. Unreal Engine 5.x (current 5.8)

- Enable accessibility with `Accessibility.Enable=1` in the project (or engine) config, then enable
  the **Screen Reader** and **Slate Screen Reader** plugins (Text To Speech comes with them).
- UMG widgets: set accessible behavior in the Details panel's Accessibility section (Auto, Summary,
  Custom, Tool Tip, Not Accessible) and provide custom text where the default is unclear.
- Custom Slate widgets: override `SWidget::CreateAccessibleWidget()` and return an accessible widget
  (see `FSlateAccessibleButton` in `SlateAccessibleWidgets.h`).
- Remapping: Enhanced Input with player-mappable key settings; persist through the user settings save.

---

## 5. Web (Three.js, React Three Fiber, Phaser, PixiJS, Kaplay)

A `<canvas>` exposes nothing to assistive technology. Put everything that is text or a control in
the DOM.

**Pattern: semantic HTML UI over the canvas**
```html
<div id="game-root">
  <canvas id="game" aria-hidden="true"></canvas>
  <nav id="menu" aria-label="Main menu">
    <button type="button" data-action="play">Play</button>
    <button type="button" data-action="settings">Settings</button>
  </nav>
  <div id="announcer" class="visually-hidden" aria-live="polite"></div>
</div>
```
```ts
// Announce game events that sighted players see on screen
export function announce(text: string) {
  const el = document.getElementById('announcer')!;
  el.textContent = '';                       // clear so repeated messages re-announce
  requestAnimationFrame(() => { el.textContent = text; });
}
// announce('Checkpoint reached. Objective: reach the lighthouse.');

// Respect OS motion preferences
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
settings.screenShake = reduceMotion ? 0 : settings.screenShake;
```
- Use native `<button>`, `<input type="range">`, `<select>` for settings; they bring focus,
  keyboard, and screen-reader semantics for free.
- Visible focus with `:focus-visible`; never `outline: none` without a replacement.
- Keep game keyboard handlers from swallowing Tab and Escape while menus are open.
- Subtitles as DOM text over the canvas scale with browser zoom and user CSS; canvas-drawn
  subtitles do not.
- Gamepad navigation of DOM menus: map D-pad to focus movement between focusable elements.
- Touch: 44-48 px minimum targets; no hover-only information.

**Automated check (HTML layer only)**
```ts
// tests/a11y.spec.ts -- requires @playwright/test and @axe-core/playwright
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('menus have no WCAG A/AA violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'])
    .analyze();
  expect(results.violations).toEqual([]);
});
```
Axe cannot evaluate the canvas, gameplay cues, or subtitle timing; keep those in the manual test plan.

---

## 6. Subtitle system data model (any engine)

```json
{
  "id": "vo_mara_014",
  "speaker": "Mara",
  "text": "The lighthouse is still lit. Someone's up there.",
  "category": "dialogue",
  "direction": "left",
  "start_ms": 0,
  "duration_ms": 3200,
  "lines": ["The lighthouse is still lit.", "Someone's up there."]
}
```
- `category` (dialogue, bark, caption, music) drives independent toggles (XAG 104).
- `lines` are authored breaks at editorially sensible points; about 40 characters per line, two lines.
- `direction` renders "<" or ">" markers for off-screen speakers and sounds.
- Duration from the audio clip, with a minimum display time and reading-speed check per language.

---

## 7. Manual test matrix (minimum)

| Check | Tool / setup | Platforms |
|---|---|---|
| Screen narration of menus and settings | NVDA or Narrator (Windows), VoiceOver (macOS, iOS), TalkBack (Android) | Each shipped platform |
| Keyboard-only and controller-only play of all menus | No mouse connected | PC, web |
| Text at 200% and largest subtitles | Busiest scene, smallest supported screen | All |
| Colorblind simulation of HUD states | Simulation tool or OS filter | All |
| Flash and motion settings | Most intense sequence | All |
| Remap persistence | Remap, restart, patch | All |
| Switch-style play | Two-button setup via remapping and toggles | PC, console |
