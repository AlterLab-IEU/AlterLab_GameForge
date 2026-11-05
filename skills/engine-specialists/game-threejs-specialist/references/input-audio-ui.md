# Input, Audio and HTML/CSS UI Overlays

Browser support facts come from MDN browser-compat-data 8.1.8 and the MDN autoplay guide
(checked 2026-11-05). Code was type-checked with TypeScript 7.0.2 and the DOM lib.

## 1. Platform limits that shape your controls

| API | Reality | Design consequence |
|---|---|---|
| Pointer Lock | **Not available in iOS Safari.** Chrome Android from 144. `unadjustedMovement`: Chrome 88+ (not Linux), Firefox 152+, Safari 18.4+ | FPS mouse-look is desktop-only; phones need touch-drag look |
| Fullscreen API | **Not on iPhone.** iPad from 16.4, with an undismissable overlay | Design for the visible viewport; use `100dvh` and safe-area insets |
| `screen.orientation.lock()` | Not in Safari | Show a "rotate your device" overlay instead of locking |
| Gamepad API | Supported everywhere; `vibrationActuator` missing in Firefox and iOS | Rumble is a bonus, never feedback the player needs |
| Wake Lock | iOS 18.4+ | Request it during play for long sessions; handle rejection |
| SharedArrayBuffer | Needs cross-origin isolation (COOP/COEP headers) | Avoid multithreaded WASM unless your host sets the headers |
| `navigator.getAutoplayPolicy()` | Firefox 112+ only | Do not feature-detect audio with it |

## 2. Polled input (verified)

Events write into state; the fixed step reads it once. Gameplay never runs inside an event handler.

```ts
export type Action = 'jump' | 'fire' | 'pause';
type Axis = '+moveX' | '-moveX' | '+moveY' | '-moveY';

const KEYMAP: Record<string, Action | Axis> = {
  KeyW: '+moveY', KeyS: '-moveY', KeyA: '-moveX', KeyD: '+moveX',
  ArrowUp: '+moveY', ArrowDown: '-moveY', ArrowLeft: '-moveX', ArrowRight: '+moveX',
  Space: 'jump', Escape: 'pause',
};

export class Input {
  private readonly down = new Set<string>();
  private readonly pressedThisStep = new Set<Action>();
  private mouse = { dx: 0, dy: 0 };
  readonly axes = { moveX: 0, moveY: 0 };
  lookDelta = { x: 0, y: 0 };

  constructor(private readonly canvas: HTMLCanvasElement) {
    addEventListener('keydown', (e) => {
      if (e.repeat) return;
      this.down.add(e.code); // physical key: WASD works on AZERTY too
      const a = KEYMAP[e.code];
      if (a === 'jump' || a === 'pause') this.pressedThisStep.add(a);
    });
    addEventListener('keyup', (e) => this.down.delete(e.code));
    addEventListener('blur', () => this.down.clear()); // no stuck keys after alt-tab
    canvas.addEventListener('pointerdown', (e) => { if (e.button === 0) this.pressedThisStep.add('fire'); });
    document.addEventListener('pointermove', (e) => {
      if (document.pointerLockElement === canvas) { this.mouse.dx += e.movementX; this.mouse.dy += e.movementY; }
    });
  }

  /** Desktop only. Call from a click handler (user gesture). */
  async lockPointer(): Promise<boolean> {
    try {
      await this.canvas.requestPointerLock({ unadjustedMovement: true }); // raw mouse, no OS accel
    } catch {
      try { await this.canvas.requestPointerLock(); } catch { return false; }
    }
    return document.pointerLockElement === this.canvas;
  }

  /** Start of every fixed step. */
  sample(): void {
    let x = 0, y = 0;
    for (const code of this.down) {
      const a = KEYMAP[code];
      if (a === '+moveX') x += 1; else if (a === '-moveX') x -= 1;
      else if (a === '+moveY') y += 1; else if (a === '-moveY') y -= 1;
    }
    const pad = navigator.getGamepads().find((g) => g?.connected && g.mapping === 'standard');
    if (pad) {
      const dead = (v: number) => (Math.abs(v) < 0.15 ? 0 : v);
      x += dead(pad.axes[0] ?? 0);
      y -= dead(pad.axes[1] ?? 0);
      if (pad.buttons[0]?.pressed) this.pressedThisStep.add('jump'); // edge-detect in production
    }
    const len = Math.hypot(x, y);
    this.axes.moveX = len > 1 ? x / len : x; // no faster diagonals
    this.axes.moveY = len > 1 ? y / len : y;
    this.lookDelta = { x: this.mouse.dx, y: this.mouse.dy };
    this.mouse.dx = this.mouse.dy = 0;
  }

  pressed(a: Action): boolean { return this.pressedThisStep.has(a); }
  endStep(): void { this.pressedThisStep.clear(); } // end of every fixed step
}
```

Notes:

- `pressedThisStep` survives until a fixed step consumes it, so a tap shorter than one frame is
  never lost. If several steps run in one frame, consume in the first and clear in `endStep()`.
- Gamepad: only `mapping === 'standard'` has the documented button layout; poll every step
  (there are no button events). Store the previous button state for edge detection.
- Rebinding: keep `KEYMAP` in data so a settings screen can edit it; save to storage.
- Input buffering and coyote time: store timestamps (in step counts) and allow 100-150 ms windows;
  put the window sizes in `tuning.ts`.

## 3. Touch controls (verified)

```ts
/** Left half moves (virtual stick), right half looks (drag). Pointer Events cover touch and pen. */
export class TouchStick {
  readonly move = { x: 0, y: 0 };
  readonly look = { dx: 0, dy: 0 };
  private moveId: number | null = null;
  private lookId: number | null = null;
  private origin = { x: 0, y: 0 };
  private lastLook = { x: 0, y: 0 };

  constructor(el: HTMLElement, private readonly radius = 60) {
    el.style.touchAction = 'none'; // stop scroll and pinch-zoom
    el.addEventListener('pointerdown', (e) => {
      if (e.pointerType === 'mouse') return;
      el.setPointerCapture(e.pointerId);
      if (e.clientX < innerWidth / 2 && this.moveId === null) { this.moveId = e.pointerId; this.origin = { x: e.clientX, y: e.clientY }; }
      else if (this.lookId === null) { this.lookId = e.pointerId; this.lastLook = { x: e.clientX, y: e.clientY }; }
    });
    el.addEventListener('pointermove', (e) => {
      if (e.pointerId === this.moveId) {
        const dx = (e.clientX - this.origin.x) / this.radius, dy = (e.clientY - this.origin.y) / this.radius;
        const len = Math.max(1, Math.hypot(dx, dy));
        this.move.x = dx / len; this.move.y = -dy / len;
      } else if (e.pointerId === this.lookId) {
        this.look.dx += e.clientX - this.lastLook.x; this.look.dy += e.clientY - this.lastLook.y;
        this.lastLook = { x: e.clientX, y: e.clientY };
      }
    });
    const end = (e: PointerEvent) => {
      if (e.pointerId === this.moveId) { this.moveId = null; this.move.x = this.move.y = 0; }
      if (e.pointerId === this.lookId) this.lookId = null;
    };
    el.addEventListener('pointerup', end);
    el.addEventListener('pointercancel', end);
  }

  consumeLook() { const d = { ...this.look }; this.look.dx = this.look.dy = 0; return d; }
}
```

Feed `TouchStick.move` into the same `axes` as keyboard and gamepad. Draw the stick in the HTML
overlay so it scales with CSS, not with the 3D camera. Make touch targets at least ~44 px.

## 4. Audio (verified)

```ts
export class AudioBus {
  readonly ctx = new AudioContext({ latencyHint: 'interactive' });
  readonly master = this.ctx.createGain();
  readonly music = this.ctx.createGain();
  readonly sfx = this.ctx.createGain();
  private readonly buffers = new Map<string, AudioBuffer>();

  constructor() {
    this.music.connect(this.master);
    this.sfx.connect(this.master);
    this.master.connect(this.ctx.destination);
    const unlock = () =>
      this.ctx.resume().then(() => {
        if (this.ctx.state !== 'running') return;
        removeEventListener('pointerdown', unlock);
        removeEventListener('keydown', unlock);
      });
    addEventListener('pointerdown', unlock); // iOS Safari: must resume inside a user gesture
    addEventListener('keydown', unlock);     // Firefox: needs sticky activation
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) void this.ctx.suspend(); else void this.ctx.resume();
    });
  }

  async load(name: string, url: string): Promise<void> {
    const data = await (await fetch(url)).arrayBuffer();
    this.buffers.set(name, await this.ctx.decodeAudioData(data));
  }

  play(name: string, { volume = 1, rate = 1 } = {}): void {
    const buffer = this.buffers.get(name);
    if (!buffer || this.ctx.state !== 'running') return;
    const src = this.ctx.createBufferSource();
    src.buffer = buffer;
    src.playbackRate.value = rate; // +-5% random rate stops repetitive SFX fatigue
    const gain = this.ctx.createGain();
    gain.gain.value = volume;
    src.connect(gain).connect(this.sfx);
    src.start();
  }
}
```

- Positional audio: make three use the same context before creating the listener:
  `THREE.AudioContext.setContext(bus.ctx); camera.add(new THREE.AudioListener());`
- Formats: WebM/Opus first, MP3 or AAC fallback (`canPlayType` to choose). WebM/Opus is consistent
  in Safari since 17.4; Safari 18.4 added Ogg Opus/Vorbis; blob-URL WebM edge cases exist in WebKit.
- Howler.js 2.2.4 (2023) still works but is effectively in maintenance mode; a 60-line bus like
  the one above covers most games.
- Portals pause audio on ads and tab switches; the `visibilitychange` handler covers the latter,
  and the publishing SDK callbacks cover ads (`game-web-publish`).

## 5. HTML/CSS overlays for HUD and menus

```html
<div id="app"></div>
<div id="ui">
  <div class="hud"><span id="score">0</span><div class="hp"><i style="--hp:0.8"></i></div></div>
  <dialog id="pause"><h2>Paused</h2><button data-action="resume">Resume</button></dialog>
</div>
```

```css
html, body { margin: 0; height: 100%; overflow: hidden; background: #000; }
#app { position: fixed; inset: 0; }
#app canvas { display: block; touch-action: none; }
#ui { position: fixed; inset: 0; pointer-events: none; font: 600 16px/1.2 system-ui, sans-serif; color: #fff;
      padding: env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left); }
#ui button, #ui dialog { pointer-events: auto; }
.hp { width: 160px; height: 10px; background: #0006; }
.hp i { display: block; height: 100%; width: calc(var(--hp) * 100%); background: #e05a47; }
```

Rules:

- HTML for text, menus, settings, and anything a screen reader or translator touches. WebGL text
  only for diegetic labels in the world.
- Update the DOM from game events or at most a few times per second; never write `textContent`
  60 times a second for a value that did not change.
- Pause on `visibilitychange` and on `blur`; resume behind an explicit "Resume" button so audio
  unlock and pointer lock happen inside a gesture.
- For world-anchored labels, project with `vector.project(camera)` and set a CSS transform;
  `CSS2DRenderer` (addons) does this for you.
- Accessibility (remappable controls, subtitles, reduced motion via `prefers-reduced-motion`):
  route audits to `game-accessibility-specialist`.
