# Unity Architecture Patterns (Unity 6.3 LTS / 6.6)

Compilable reference implementations for the patterns `game-unity-specialist` recommends. Every
sample targets Unity 6 (6000.x) with the Input System, URP and the Unity Test Framework installed.
Version splits are called out inline.

---

## 1. Project layout and assembly definitions

```
Assets/
  _Project/                      -- everything you own; third-party stays outside
    Core/        Game.Core.asmdef        (no engine-feature dependencies; pure C# + UnityEngine)
    Gameplay/    Game.Gameplay.asmdef    (refs: Game.Core, Unity.InputSystem, Unity.Addressables)
    UI/          Game.UI.asmdef          (refs: Game.Core, Game.Gameplay)
    Editor/      Game.Editor.asmdef      (Editor only; refs: everything it inspects)
    Tests/
      EditMode/  Game.Tests.EditMode.asmdef
      PlayMode/  Game.Tests.PlayMode.asmdef
    Art/ Audio/ Prefabs/ Scenes/ Settings/ Data/
  Plugins/                       -- third-party code
```

Dependency direction is the point: UI may depend on Gameplay, never the reverse. An asmdef graph
that compiles is an architecture that is enforced.

Runtime asmdef. Reference other assemblies **by name**: an agent cannot know GUIDs, and name
references work as long as "Use GUIDs" is unticked in the asmdef inspector.

```json
{
  "name": "Game.Gameplay",
  "rootNamespace": "Game.Gameplay",
  "references": ["Game.Core", "Unity.InputSystem", "Unity.Addressables", "Unity.ResourceManager"],
  "includePlatforms": [],
  "excludePlatforms": [],
  "allowUnsafeCode": false,
  "autoReferenced": true,
  "noEngineReferences": false
}
```

Edit Mode test asmdef (the shape Unity's "Create > Testing > Tests Assembly Folder" produces):

```json
{
  "name": "Game.Tests.EditMode",
  "rootNamespace": "Game.Tests",
  "references": ["Game.Core", "Game.Gameplay", "UnityEngine.TestRunner", "UnityEditor.TestRunner"],
  "includePlatforms": ["Editor"],
  "overrideReferences": true,
  "precompiledReferences": ["nunit.framework.dll"],
  "autoReferenced": false,
  "defineConstraints": ["UNITY_INCLUDE_TESTS"]
}
```

For Play Mode tests, use the same file with `"includePlatforms": []`.

Let Unity create the `.meta` file for every new asmdef. Never write one by hand.

---

## 2. ScriptableObject architecture

ScriptableObject event channels and variable assets were popularised by Ryan Hipple's Unite Austin
2017 talk "Game Architecture with Scriptable Objects". Unity's own guide, "Architect game code with
ScriptableObjects", draws on it. Use them to decouple systems, not as a religion.

### Data asset

```csharp
using UnityEngine;

namespace Game.Core
{
    [CreateAssetMenu(fileName = "WeaponData", menuName = "Game/Weapon Data")]
    public sealed class WeaponData : ScriptableObject
    {
        [field: SerializeField] public string DisplayName { get; private set; } = "Blaster";
        [field: SerializeField, Min(0f)] public float Damage { get; private set; } = 10f;
        [field: SerializeField, Min(0.01f)] public float FireRate { get; private set; } = 4f;
        [field: SerializeField] public AudioClip[] FireSounds { get; private set; }
    }
}
```

### Event channel + listener

```csharp
using System;
using UnityEngine;

namespace Game.Core
{
    [CreateAssetMenu(fileName = "IntEventChannel", menuName = "Game/Events/Int Event Channel")]
    public sealed class IntEventChannel : ScriptableObject
    {
        public event Action<int> Raised;

        public void Raise(int value) => Raised?.Invoke(value);
    }
}
```

```csharp
using Game.Core;
using UnityEngine;
using UnityEngine.UIElements;

namespace Game.UI
{
    public sealed class HealthLabel : MonoBehaviour
    {
        [SerializeField] private IntEventChannel _healthChanged;
        [SerializeField] private UIDocument _document;

        private Label _label;

        private void OnEnable()
        {
            // UIDocument builds its visual tree in its own OnEnable; query here, not in Awake.
            _label = _document.rootVisualElement.Q<Label>("health-label");
            _healthChanged.Raised += OnHealthChanged;
        }

        private void OnDisable() => _healthChanged.Raised -= OnHealthChanged;

        private void OnHealthChanged(int value) => _label.text = value.ToString();
    }
}
```

### Runtime set (no `Find` calls)

```csharp
using System.Collections.Generic;
using UnityEngine;

namespace Game.Core
{
    public abstract class RuntimeSet<T> : ScriptableObject
    {
        private readonly List<T> _items = new();
        public IReadOnlyList<T> Items => _items;

        public void Add(T item) { if (!_items.Contains(item)) _items.Add(item); }
        public void Remove(T item) => _items.Remove(item);

        // ScriptableObject state survives between Play sessions in the Editor
        // (and domain reload is off by default in new 6.6 projects). Clear it explicitly.
        private void OnEnable() => _items.Clear();
    }
}
```

**Gotcha:** values you change on a ScriptableObject asset at runtime in the Editor are written to
the asset. Keep runtime state in plain C# objects or reset it, as above.

---

## 3. Static state without domain reload

New Unity 6.6 projects default Enter Play Mode to "Reload Scene only", so static fields keep their
values between Play sessions. Unity recommends keeping domain reload off to prepare for the removal
of Mono and domain reload in future versions (per "What's new in Unity 6.6"). Reset statics yourself:

```csharp
using UnityEngine;

namespace Game.Core
{
    public static class ScoreTracker
    {
        public static int Score { get; private set; }

        public static void Add(int points) => Score += points;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        private static void ResetStatics() => Score = 0;
    }
}
```

In Unity 6.6, Project Auditor ships a Roslyn analyzer that flags statics needing a reset. It
resolves most cases with the `AutoStaticsCleanup` / `NoAutoStaticsCleanup` attributes. On 6.3 LTS,
use the `RuntimeInitializeOnLoadMethod` pattern above.

---

## 4. Async with `Awaitable`

Prefer `Awaitable` over coroutines for new code, and over `Task` on the main thread. Rules, per the
Awaitable scripting reference:

- Await each `Awaitable` **once**. Instances are pooled, so awaiting the same one twice is undefined.
- Pass `destroyCancellationToken` so the work stops when the object is destroyed.
- `async void` only for Unity event entry points. Wrap the body in try/catch, or exceptions are
  logged late or lost.

```csharp
using System;
using System.Threading;
using UnityEngine;

namespace Game.Gameplay
{
    public sealed class DelayedExplosion : MonoBehaviour
    {
        [SerializeField, Min(0f)] private float _fuseSeconds = 2f;

        private async void Start()
        {
            try
            {
                await Awaitable.WaitForSecondsAsync(_fuseSeconds, destroyCancellationToken);
                Explode();
            }
            catch (OperationCanceledException)
            {
                // Destroyed before the fuse ran out: expected, not an error.
            }
        }

        private void Explode() { /* spawn VFX, apply damage */ }
    }
}
```

The available helpers are `NextFrameAsync`, `EndOfFrameAsync`, `FixedUpdateAsync`,
`WaitForSecondsAsync`, `FromAsyncOperation`, `BackgroundThreadAsync` and `MainThreadAsync`. Do not
rely on background threads in Web builds (see `rendering-performance-web.md`).

---

## 5. Addressables loading

```csharp
using System;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace Game.Gameplay
{
    public sealed class EnemySpawner : MonoBehaviour
    {
        [SerializeField] private AssetReferenceGameObject _enemyPrefab;

        private AsyncOperationHandle<GameObject> _prefabHandle;

        private async void Start()
        {
            try
            {
                _prefabHandle = _enemyPrefab.LoadAssetAsync<GameObject>();
                GameObject prefab = await _prefabHandle.Task;
                if (destroyCancellationToken.IsCancellationRequested) return;
                Instantiate(prefab, transform.position, Quaternion.identity);
            }
            catch (Exception e)
            {
                Debug.LogException(e, this);
            }
        }

        private void OnDestroy()
        {
            if (_prefabHandle.IsValid()) Addressables.Release(_prefabHandle);
        }
    }
}
```

- **One load, one release.** Leaked handles are the most common Addressables memory bug.
- **Labels** let you preload a level's assets behind a loading screen with `LoadAssetsAsync<T>`.
- **`Resources/`** is acceptable only for a handful of tiny always-needed assets. Everything in it is
  in the build and cannot be unloaded individually.
- **Unity 6.6 Content Directories** are Unity's replacement for AssetBundle builds. Assets load
  through the `Loadable` API and build with `BuildPipeline.BuildContentDirectory`, and Addressables
  gains a Content Directory schema. On 6.3 LTS, stay on standard Addressables.

---

Input System, UI Toolkit, pooling, animation, camera and editor tooling samples live in
`input-ui-tooling.md`.
