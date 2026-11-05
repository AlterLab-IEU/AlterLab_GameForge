# Web and Portal UX (UX Designer reference)

Snapshot: November 2026. Platform limits are quoted from platform documentation and browser
compatibility data; everything else is labeled as practice or rule of thumb. For SDK integration
and submission, hand off to `/gameforge:game-web-publish`.

---

## 1. What short-session web games have in common

- **Scope to the hook**: Vibe Jam 2026's Gold winner described about 5-10 minutes of play built
  around one idea; vendor guides advise a hook a player understands in about five seconds, one
  mechanic per prompt, a near-instant load, and testing in a fresh browser.
- **Instant play**: Vibe Jam's rule -- "instantly playable on web -- no logins, signups or loading
  screens" (a username prompt is allowed) -- is a sound default well beyond jams.
- **Static hosting survives**: an analysis of Vibe Jam entries found 42% of 2025 entries already
  offline, with backend-dependent games dying fastest. Make any backend optional for the core loop.

---

## 2. Platform constraints that shape UX

**Portals**
| Platform | UX-relevant requirement |
|---|---|
| Poki | Players leave after about 10 s of loading; `gameplayStart()` fires on the first input; storage must work in incognito; no external requests; must work with ad blockers; 16:9 desktop, mobile, and tablet |
| CrazyGames | Initial download 50 MB or less, **20 MB or less for the mobile homepage**; `gameplayStart` SDK event; must run smoothly on 4 GB Chromebooks; DPR forced to 1 on iOS |
| YouTube Playables | Initial bundle under 30 MiB (under 15 MiB recommended); JS heap capped at 512 MB; saves under 3 MiB |
| Discord Activities | Runs in an iframe through the Embedded App SDK; your own server; purchases verified server-side |
| itch.io | ZIP with `index.html`; generative-AI disclosure feeds its "no AI" filter |

**Mobile browsers (MDN browser-compat-data, late 2026)**
| API | Status | UX consequence |
|---|---|---|
| Pointer Lock | Not in iOS Safari; Chrome Android from 144 | Drag-to-look camera; no mouse-look assumptions |
| Fullscreen | Not on iPhone; iPad only from 16.4 with an undismissable overlay | Layout must fit browser chrome; offer "Add to Home Screen" only as a hint |
| `screen.orientation.lock` | Not in Safari | Show a rotate-device prompt; support both orientations if you can |
| Gamepad | Supported everywhere; `vibrationActuator` missing in Firefox and iOS | Never put essential feedback in vibration alone |
| Wake Lock | iOS 18.4+ | Request it during active play only; idle-dimming otherwise |
| Web Audio | Must be resumed by a user gesture; Firefox needs sticky activation | First tap = Play = audio unlock |
| SharedArrayBuffer | Requires cross-origin isolation | Engine choice (threads) can conflict with portal hosting |

---

## 3. The first 60 seconds (spec checklist)

- [ ] **Load**: only first-level assets before interaction; progress shown if over about 2 s; total
      under the strictest portal cap you target
- [ ] **Title screen**: one primary action ("Play"), large, focused by default; secondary items small
- [ ] **First tap**: unlocks audio, fires the portal gameplay-start event, starts play
- [ ] **Teach by doing**: the first room allows only the core verb; a ghost-input hint appears after
      about 8 s of idle (rule of thumb), not before
- [ ] **No text walls**: if text is unavoidable, one line, at XAG 101 sizes for the device
- [ ] **Input detection**: show touch, keyboard, or gamepad prompts based on the first input received
- [ ] **Fail fast and cheap**: first failure within the first minute costs seconds, not progress
- [ ] **Sound**: visible mute toggle; no sound before the first input
- [ ] **Interruptions**: tab hidden or ad break -> pause and mute; resume to a paused state, not live play

---

## 4. Session end and return

- End screen: result, best score, **Play again** as default focus, then share, then menu.
- Do not gate "Play again" behind an ad where the portal does not require it; where ads are shown,
  show them at natural breaks the portal SDK defines.
- Persist settings and best score in `localStorage` inside `try/catch`; the game must still run if
  storage is blocked (incognito, strict privacy modes).
- Returning players: skip the tutorial automatically if the first-session flag is set, with a
  "How to play" entry in the pause menu.

---

## 5. Touch-first control layouts

| Genre | Left thumb | Right thumb | Notes |
|---|---|---|---|
| Top-down action | Floating stick (move) | Auto-aim fire button + 1 ability | Auto-aim replaces precise aiming on touch |
| Platformer | Left/right buttons or stick | Jump (large) + action | Buffer jump input; coyote time hides touch latency |
| Third-person 3D | Floating stick | Drag-to-look + action buttons | No pointer lock; keep camera assist on |
| One-button / hyper-casual | Tap anywhere | -- | Best fit for portal mobile traffic |
| Puzzle / card | Direct manipulation | -- | Drag with a tap-to-select alternative |

---

## 6. Loading and performance as UX

- Players perceive load time before anything else; measure time-to-first-input on a mid-range
  Android phone over a throttled connection, not on a dev laptop.
- Show something interactive early (title screen while level 1 streams).
- Cap device pixel ratio on mobile (rule of thumb 1.5-2) for frame rate; a smooth 30-60 fps at lower
  resolution beats a sharp stutter.
- Test the iPhone-smooth, Android-stutters failure mode reported by vibe-coded projects: always keep
  a mid-range Android in the test matrix.

---

## 7. AI-driven characters in web games

The disclosure pattern from the main skill applies unchanged on the web. Additional web points:
- Never put API keys for the model provider in client code; route requests through your server.
- Show a typing or thinking indicator within about 300 ms (rule of thumb) so latency reads as
  character, then fall back to a scripted line after a timeout.
- The Report action must work on touch and keyboard and be reachable inside the dialogue UI.
