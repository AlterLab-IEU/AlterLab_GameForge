# Game-Runtime Checks: Full Audits

Read this during Step 3 for any file that runs per frame, per physics step, or per network tick.
Each audit lists what to find, how it looks in each engine, the fix, and severity guidance.

Per-frame entry points to locate first:

| Stack | Variable rate | Fixed rate |
|---|---|---|
| Godot | `_process(delta)` | `_physics_process(delta)` |
| Unity | `Update()`, `LateUpdate()` | `FixedUpdate()` |
| Unreal | `Tick(float DeltaTime)` | physics substeps, `AsyncPhysicsTickComponent` |
| Three.js / R3F | `renderer.setAnimationLoop(cb)`, `requestAnimationFrame`, `useFrame` | your own accumulator (R3F v10 alpha adds a `physics` phase) |
| Phaser 4 | `update(time, delta)` | Arcade/Matter physics step |
| PixiJS 8 | `app.ticker.add(ticker => ...)` (`ticker.deltaTime`, `ticker.deltaMS`) | your own accumulator |

## G1. Delta time

```
FIND: += / -= on position, rotation, timers, cooldowns inside variable-rate callbacks without delta
FLAG: position.x += speed                 (frame-rate dependent)
FIX:  position.x += speed * delta         (Godot/Phaser delta in s or ms -- check units)
ALSO: timers that count frames; animation speed tied to frame count; lerp(a, b, 0.1) per frame
      (use an exponential decay with delta: a = lerp(a, b, 1 - exp(-k * delta)))
UNITS: Phaser update delta is milliseconds; Godot delta is seconds; Unity Time.deltaTime seconds;
       PixiJS ticker.deltaTime is a frame-scaled multiplier, ticker.deltaMS is milliseconds.
SEVERITY: CRITICAL in gameplay; MINOR in cosmetic-only effects
```

## G2. Hot-path allocations

```
FIND in per-frame code:
  C#:      new List<>/arrays, LINQ, string concatenation/interpolation, boxing, lambdas capturing
           locals, GetComponent<T>(), FindObjectOfType/FindFirstObjectByType, Camera.main in old Unity
  GDScript: Array/Dictionary literals, str() + concatenation, get_node("long/path") each frame,
           instantiate() without pooling, signals connected per frame
  C++ UE:  FString formatting in Tick, TArray growth without Reserve, NewObject in Tick,
           TActorIterator scans per frame
  JS/TS:   object/array literals ({x, y}, [a, b]), new THREE.Vector3() per frame, closures in
           loops, .map/.filter/.reduce chains, spread copies, template strings for debug text
FIX: cache references in _ready/Awake/BeginPlay/constructor; reuse scratch vectors; object pools;
     pre-sized arrays; move debug formatting behind a flag
SEVERITY: CRITICAL in physics/render loops at scale; MAJOR in gameplay update; MINOR elsewhere.
          Label "profile first" unless a profiler capture shows GC spikes.
```

## G3. State integrity

```
FIND: clusters of booleans (is_jumping, is_attacking, can_move, is_dead) driving behavior
FLAG: combinations that should be impossible but are reachable (dead AND attacking)
PREFER: explicit enum or state objects with enter/exit/update; guarded transitions;
        hierarchical state machines for complex characters
CHECK: exit cleanup (stop animation/audio/particles on exit); re-entrancy (state changed inside
       its own enter); state visible in a debug overlay or inspector
SEVERITY: CRITICAL when it breaks gameplay; MAJOR for visual glitches; MINOR for extensibility
```

## G4. Fixed-step physics

```
FIND: forces, movement integration, collision response in variable-rate callbacks
FLAG: Unity Rigidbody forces in Update; Godot body movement in _process; JS physics stepped once
      per requestAnimationFrame with the frame delta
FIX: fixed timestep with an accumulator, render interpolation between steps, input sampled per
     frame but consumed per step
JS pattern:
  acc += Math.min(frameDt, 0.25);
  while (acc >= STEP) { world.step(STEP); acc -= STEP; }
  render(alpha = acc / STEP);
ALSO: high-refresh displays (120/144/240 Hz) exposing tunneling -> enable CCD for fast bodies;
      test at 30, 60 and 144 fps
SEVERITY: CRITICAL
```

## G5. Resource lifecycle

```
CHECK on scene/level change, respawn, and object destruction:
- Signals/events/listeners disconnected (Godot connect without CONNECT_ONE_SHOT or owner cleanup;
  C# event += without -=; UE delegates bound to destroyed objects; DOM/window listeners)
- Pooled objects returned; timers and tweens killed
- Async loads and coroutines/awaits cancelled when the owner is gone (Godot await on freed
  objects; Unity coroutines on disabled objects; JS promises resolving into disposed scenes)
- Web GPU resources: geometry.dispose(), material.dispose(), texture.dispose(),
  renderTarget.dispose(); since three r186 Object3D.dispose() exists and subclasses must call
  super.dispose()
- Audio sources stopped; AudioContext not recreated per scene
SEVERITY: MAJOR; CRITICAL when long sessions crash or WebGL contexts are lost
```

## G6. Dependency direction

```
CHECK: gameplay may depend on engine/rendering; the reverse is a red flag
FLAG: circular imports; god objects (GameManager with dozens of public fields reached from
      everywhere); singletons accessed deep inside gameplay; UI code mutating gameplay state
TEST: can this system be instantiated in a unit test without booting the whole game?
SEVERITY: MAJOR -- coupling compounds
```

## G7. Data-driven values

```
FIND: numeric literals for player-facing tuning (speed = 5.0, damage = 10, cooldown = 0.5)
FIX:  Godot custom Resource (.tres) with @export fields; Unity ScriptableObject; Unreal
      UDataAsset/DataTable; web JSON or a typed config module with a debug panel
EXEMPT: math constants, engine configuration with a comment explaining it
SEVERITY: MAJOR for player-facing values; MINOR for internal buffers and pool sizes
```

## G8. Input abstraction

```
FLAG: raw device checks in gameplay (Input.GetKey(KeyCode.Space), event.keyCode === 32,
      is_key_pressed(KEY_W)); bindings hardcoded; mouse math that assumes one resolution
PREFER: Godot InputMap actions; Unity Input System actions; Unreal Enhanced Input actions and
        mapping contexts; web: an action map over KeyboardEvent.code plus Gamepad API
ALSO: remapping UI path exists (accessibility and EAA-relevant purchase/communication flows);
      input buffering for action games; touch fallback for web builds
SEVERITY: MAJOR for shipping builds; MINOR for prototypes
```

## G9. Concurrency

```
CHECK: Godot WorkerThreadPool/Thread touching scene tree nodes (not thread-safe; use
       call_deferred); Unity Jobs writing shared arrays without NativeContainer rules; async
       continuations touching UnityEngine objects off the main thread; UE game-thread-only
       UObject access from task graph threads; web workers and SharedArrayBuffer without Atomics
FLAG: shared mutable state without ownership; network callbacks mutating state mid-frame
SEVERITY: CRITICAL on crash or corruption; MAJOR on desync or glitches
```

## G10. Determinism

```
CHECK when the game has replays, lockstep multiplayer, seeded runs, or daily challenges:
- RNG seeded and owned (no global Math.random()/randf() in simulation code)
- Iteration order of dictionaries/sets relied on for gameplay
- Transcendental math across browsers: Math.sin/cos results can differ between JS engines;
  lockstep or replays need custom or table-based functions
- Float accumulation in variable-rate code (see G1/G4)
SEVERITY: MAJOR when replays/lockstep exist; otherwise NIT
```

## G11. Magic numbers

```
FLAG: unnamed literals (if velocity.y > 4.5)
GOOD: const TERMINAL_VELOCITY := 4.5  # matches the fall animation length; tuned in playtest 3
The comment carries the reasoning; the name alone is half the fix.
SEVERITY: MINOR individually; MAJOR when a system is unreadable without them explained
```
