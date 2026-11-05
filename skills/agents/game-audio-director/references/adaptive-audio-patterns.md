# Adaptive Audio Patterns and Implementations (Audio Director reference)

Patterns first, then how each toolchain expresses them. Code is a starting sketch for the audio
programmer or coding agent; verify API details against the engine version in
`.gameforge/project.json`.

---

## 1. Pattern catalog

| Pattern | What changes | Best for | Transition rule |
|---|---|---|---|
| **Vertical layering** | Stems of one piece fade in/out by intensity | Exploration -> tension -> combat in one musical world | Gain ramps of 1-4 s; all stems start on the same sample |
| **Horizontal re-sequencing** | Which section plays next | Boss phases, level progression, branching narrative | Switch at bar or beat boundaries; pre-composed transition segments |
| **Stinger** | A short one-shot over the bed | Discovery, detection, level-up | Quantize to the next beat; duck the bed briefly |
| **Bridge / transition segment** | A composed connector | Big state changes (calm -> combat) | Exit cue at musical boundary -> bridge -> new state at downbeat |
| **Parameter mix (RTPC)** | Filter cutoff, send levels, layer gain from a game value | Health, threat, speed, underwater | Smooth the parameter (200-800 ms) to avoid zipper noise |
| **Generative / procedural** | Note-level or grain-level variation | Ambience, long sessions, idle music | Constrain to a scale and tempo; seed per area for consistency |
| **Diegetic sources** | Music emitted by world objects | Radios, bands, campfires, navigation by ear | 3D attenuation; may hand off to non-diegetic score |

**State model checklist**
- [ ] Every audio state named, with its active layers and mood target
- [ ] Every transition: trigger condition, quantization (immediate / beat / bar / end of segment), duration
- [ ] Hysteresis on intensity thresholds (enter combat at 0.7, leave at 0.4) so states do not flicker
- [ ] A "cooldown" before de-escalating (combat -> calm only after N seconds without threat)
- [ ] Pause, menu, and death behavior defined (duck, filter, or stop)
- [ ] Every state change also has a visual signal if it carries gameplay meaning

---

## 2. FMOD Studio

- **Event with parameters**: one music event; a continuous `Intensity` parameter (0-1) drives stem
  volumes via automation curves; a labeled parameter (`State`: Explore/Combat) drives transition
  regions.
- **Transition markers and regions** quantized to beat or bar handle horizontal re-sequencing.
- **Snapshots** for global mix states (pause, underwater, low health).
- Game side (Unity integration, C#):

```csharp
// Requires the FMOD for Unity integration package.
var music = FMODUnity.RuntimeManager.CreateInstance("event:/Music/Stealth");
music.start();
// Each frame or on change; FMOD applies the parameter's seek speed for smoothing.
music.setParameterByName("Intensity", threatLevel);
```

## 3. Wwise

- **States** for global music state (Explore, Combat); **Switches** for per-object variants
  (surface type on footsteps); **RTPCs** for continuous values (threat, health).
- **Music Switch Containers** with transition rules (exit at next bar, use transition segment)
  implement horizontal re-sequencing; **Music Segments** with multiple tracks implement layering.
- Game side: set the state when gameplay changes; set the RTPC every frame or on change.

```cpp
AK::SoundEngine::SetState("MusicState", "Combat");
AK::SoundEngine::SetRTPCValue("Threat", threat01 * 100.0f);
```

## 4. Godot (4.3 and later)

Godot 4.3 added interactive music resources:
- **AudioStreamSynchronized**: plays several streams in sync with per-stream volume -- vertical layering.
- **AudioStreamInteractive**: clips plus a transition table (immediate, next beat, next bar, end of
  clip, optional transition clip) -- horizontal re-sequencing.
- **AudioStreamPlaylist**: sequential or shuffled playlists with crossfades.

```gdscript
# Vertical layering with AudioStreamSynchronized assigned to $Music.stream
func set_intensity(t: float) -> void:
    var sync := $Music.stream as AudioStreamSynchronized
    sync.set_sync_stream_volume(1, linear_to_db(clampf(t * 2.0, 0.001, 1.0)))       # pulse stem
    sync.set_sync_stream_volume(2, linear_to_db(clampf(t * 2.0 - 1.0, 0.001, 1.0))) # percussion
```

Smooth `t` before calling (lerp toward the target each frame). On web exports, Godot defaults to
"Sample" playback (low latency, no bus effects); switch the project's web audio playback mode to
"Stream" if the design depends on bus effects, and test latency.

## 5. Unity (6.3 LTS / 6.6)

- **AudioMixer** groups for buses; **snapshots** with `TransitionTo(seconds)` for mix states.
- Sample-accurate starts and stem sync with `AudioSource.PlayScheduled(AudioSettings.dspTime + lead)`;
  schedule all stems for the same DSP time.
- Exposed mixer parameters for RTPC-style control (`mixer.SetFloat("PulseVol", dB)`).
- FMOD and Wwise both ship Unity integrations if the native tools run out.

```csharp
double start = AudioSettings.dspTime + 0.1;
foreach (var stem in stems) stem.PlayScheduled(start); // all layers sample-aligned
```

## 6. Unreal Engine 5.8

- **MetaSounds**: procedural, sample-accurate audio graphs; expose inputs (Intensity) as parameters.
- **Quartz**: clock and quantization for beat- and bar-synced playback and gameplay events.
- **Sound Classes / Submixes** for buses; **Audio Modulation** for parameter-driven mix control.
- Unreal also ships a Harmonix music plugin for music-driven gameplay in recent 5.x versions; check
  its status in the version you target before depending on it.

## 7. Web Audio API (Three.js, Phaser, PixiJS, Kaplay, plain TS)

Unlock, then run all stems from one `AudioContext`, started at the same `when` time.

```ts
const ctx = new AudioContext();
const master = ctx.createGain(); master.connect(ctx.destination);

// Activation-triggering events only; touch pointerdown does not count.
const unlock = () => { if (ctx.state !== 'running') void ctx.resume(); };
for (const ev of ['pointerup', 'click', 'keydown', 'touchend']) {
  window.addEventListener(ev, unlock, { passive: true });
}
document.addEventListener('visibilitychange', () => {
  if (document.hidden) void ctx.suspend(); else unlock();
});

async function loadBuffer(url: string) {
  const res = await fetch(url);
  return ctx.decodeAudioData(await res.arrayBuffer()); // short loops and SFX only
}

type Stem = { gain: GainNode };
async function startStems(urls: string[]): Promise<Stem[]> {
  const buffers = await Promise.all(urls.map(loadBuffer));
  const when = ctx.currentTime + 0.1;               // same start time = sample-aligned
  return buffers.map((buffer, i) => {
    const src = ctx.createBufferSource();
    src.buffer = buffer; src.loop = true;
    const gain = ctx.createGain(); gain.gain.value = i === 0 ? 1 : 0;
    src.connect(gain).connect(master);
    src.start(when);
    return { gain };
  });
}

function rampTo(param: AudioParam, target: number, seconds = 1.5) {
  const t = ctx.currentTime;
  param.cancelScheduledValues(t);
  param.setValueAtTime(param.value, t);
  param.linearRampToValueAtTime(target, t + seconds);
}
// rampTo(stems[2].gain.gain, 1) when intensity crosses the combat threshold
```

Notes:
- Long music beds: use an `<audio>` element with `createMediaElementSource()` to stream instead of
  decoding minutes of PCM. Stems that must stay sample-aligned are the exception: keep them short.
- Beat-quantized transitions: compute the next bar from a known BPM and the stems' start time, then
  schedule the ramp or the stinger's `start(when)` at that time.
- Framework sound layers (Phaser's sound manager, `@pixi/sound`) wrap the same API; the unlock and
  memory rules still apply.

---

## 8. Mix-state recipes

| Situation | Recipe |
|---|---|
| Dialogue over music | Side-chain or scripted duck of music 4-8 dB; carve 1-3 kHz in the music bus |
| Low health | Low-pass the world bus progressively; heartbeat layer; never mask the hit-feedback bus |
| Pause menu | Duck world 10-15 dB and low-pass; UI bus untouched |
| Ad break / tab hidden (web) | Suspend the context; resume only after the SDK says the break ended |
| Death | "Last sound" designed deliberately; cut ambience, let one tail ring |
