# Middleware, Platforms, and Audio Budgets (Audio Director reference)

Snapshot: November 2026. License thresholds and prices are deliberately not quoted as fact: both
vendors change them, and the figures found in third-party summaries conflict. Check the vendor page
on the day you budget and record what you saw.

---

## 1. Choosing a toolchain

| Question | If yes | If no |
|---|---|---|
| Does a non-programmer need to iterate on music transitions and event behavior? | FMOD or Wwise | Engine-native is enough |
| Is the game web-first (portals, itch.io, Discord Activities)? | Engine-native or framework sound over Web Audio; middleware web support adds size and setup | Any |
| More than ~100 simultaneous voices, heavy profiling needs, large VO set with localization? | Wwise is the usual pick | FMOD or native |
| Two-person team, jam or first commercial game? | FMOD or native | -- |
| Console certification with audio requirements? | Middleware platform support saves time | -- |

**FMOD Studio** (Firelight Technologies)
- Strengths: designer-friendly timeline and parameter model, fast iteration, live update to a
  running game, integrations for Unity and Unreal, community integrations for Godot.
- License: a free Indie tier exists for small developers under revenue and budget caps; paid tiers
  above that. Third-party summaries disagree on the current budget cap, so read
  https://www.fmod.com/licensing before relying on a number.

**Wwise** (Audiokinetic)
- Strengths: interactive music hierarchy, States/Switches/RTPCs, profiler, large-project tooling,
  official Unity and Unreal integrations.
- License: an Indie tier free below a production-budget cap, paid tiers by budget, a license per
  platform. Audiokinetic also checks project budgets periodically after launch. Confirm on
  https://www.audiokinetic.com/pricing/ before budgeting.

**Engine-native**
| Engine | Native strengths | Gaps to plan for |
|---|---|---|
| Godot 4.7 | Buses with effects, AudioStreamInteractive / Synchronized / Playlist (since 4.3), 3D audio with doppler and area reverb | No designer-facing timeline; web exports default to "Sample" playback without effects |
| Unity 6.3 LTS / 6.6 | AudioMixer with snapshots and exposed parameters, `PlayScheduled` for sync | Adaptive music logic is code you write |
| Unreal 5.8 | MetaSounds (procedural graphs), Quartz (quantized timing), submixes, Audio Modulation | Steeper learning curve; plan a MetaSound template library early |
| Web (Three.js, Phaser, PixiJS) | Web Audio graph: gain, filters, convolution reverb, panner | Unlock rules, iOS quirks, PCM memory, no streaming for decoded buffers |

---

## 2. Web audio rules (all web stacks)

**Unlocking**
- An `AudioContext` must be resumed from a user gesture. Activation-triggering events: `keydown`,
  `click`, `pointerup`, `touchend`, and mouse `pointerdown`; touch `pointerdown` alone does not unlock.
- Firefox blocks Web Audio until the page has sticky activation. `navigator.getAutoplayPolicy()`
  exists only in Firefox 112+, so do not build logic on it.
- iOS Safari: resume after returning from the background; Safari can report a non-standard
  `interrupted` state, so test `state !== 'running'`.
- Design the first screen so the first tap is meaningful (Play), and start audio there.

**Formats and delivery**
| Use | Format | Fallback |
|---|---|---|
| SFX (decoded) | Ogg Opus or WebM Opus, mono where possible, 48 kHz | MP3 or AAC |
| Music (streamed via media element) | Opus or AAC at 96-128 kbps stereo (rule of thumb) | MP3 |
| Voice | Opus mono 32-64 kbps (rule of thumb) | AAC |

WebM/Opus has worked consistently in Safari since 17.4; Safari 18.4 added Ogg Opus and Ogg Vorbis.
Reported Blob-URL WebM edge cases are a reason to serve audio files by URL rather than from blobs.

**Memory**
- Decoded PCM is float32: seconds x sample rate x channels x 4 bytes. 60 s stereo at 48 kHz is
  about 23 MB. A dozen decoded music stems can exhaust a phone tab.
- Keep decoded buffers for short, frequently triggered sounds; stream everything long.
- YouTube Playables caps the JS heap at 512 MB, and CrazyGames disables games that stutter on
  4 GB Chromebooks: audio memory counts against both.

**Portals**
- No sound before the first input (Poki fires `gameplayStart()` on the first input).
- Pause and mute during SDK ad breaks and on `visibilitychange`; resume only when the SDK signals
  the break ended.
- No external requests on Poki: bundle audio, do not hotlink.

**Libraries**
- Howler.js 2.2.4 (2023-09-19): works, but no npm release in three years; treat as maintenance mode.
- `@pixi/sound` 6.0.2 for PixiJS 8; Phaser 4's sound manager; Kaplay's `play()`. All sit on Web Audio.

---

## 3. Budgets (rules of thumb -- measure on the weakest device)

| Budget | Desktop/console | Mobile/web |
|---|---|---|
| Simultaneous voices (real) | 64-128 | 24-48 |
| Audio CPU share of frame | 5-10% | 5% or less |
| Resident SFX memory | 50-150 MB | 10-30 MB |
| Initial audio download (web) | n/a | Keep audio under about a quarter of the portal's initial-download cap; lazy-load later levels |

Voice-stealing policy per category: priority score (0-100), steal oldest or quietest, never steal
dialogue or critical feedback sounds.

---

## 4. Loudness targets

- Measure integrated loudness (LUFS) and true peak on the full mix during representative play, not
  on individual files.
- A widely used reference is Sony's ASWG-R001 recommendation: about -24 LUFS integrated for home
  console and about -18 LUFS for portable devices, with a true-peak ceiling around -1 dBTP. Web and
  mobile games often sit louder; match the platform's norm and keep the true-peak ceiling.
- Normalize assets consistently before mixing so the mix is about balance, not repair.

```bash
# Integrated loudness, range, and true peak of a file or a captured gameplay mix
ffmpeg -hide_banner -i capture.wav -af loudnorm=print_format=json -f null -
# Format, sample rate, channels, duration
ffprobe -hide_banner sfx_hit_metal_03.ogg
```

---

## 5. Bus architecture template

```
Master (limiter, true-peak ceiling)
  Music (duck from Dialogue, side-chain)
  SFX
    Combat   Footsteps   Environment   Magic
  Dialogue (always on top; never stolen)
  Ambience (duck from Combat 2-4 dB)
  UI (unaffected by pause filters)
Player-facing sliders: Master, Music, SFX, Dialogue, Ambience, UI; Mono toggle; Dynamic range (wide/night)
```
