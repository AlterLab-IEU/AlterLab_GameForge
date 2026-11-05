# Unity Input, UI and Tooling Patterns (Unity 6.3 LTS / 6.6)

Compilable samples for player input, runtime UI, pooling, animation, camera and editor tooling.
Architecture foundations (asmdefs, ScriptableObjects, statics, async, Addressables) are in
`architecture-patterns.md`.

---

## 1. Input System

Unity 6 projects use project-wide actions (the `InputSystem_Actions` asset). The Unity 6 manual says
the legacy Input Manager will be removed in a future version, and 6.3 warns when it is enabled.

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

namespace Game.Gameplay
{
    public sealed class PlayerMotor : MonoBehaviour
    {
        [SerializeField, Min(0f)] private float _speed = 6f;
        [SerializeField, Min(0f)] private float _jumpSpeed = 5f;
        [SerializeField] private Rigidbody _body;

        private InputAction _move;
        private InputAction _jump;

        private void Awake()
        {
            _move = InputSystem.actions.FindAction("Player/Move", throwIfNotFound: true);
            _jump = InputSystem.actions.FindAction("Player/Jump", throwIfNotFound: true);
        }

        private void OnEnable() => _jump.performed += OnJump;
        private void OnDisable() => _jump.performed -= OnJump;

        private void FixedUpdate()
        {
            Vector2 input = _move.ReadValue<Vector2>();
            Vector3 velocity = _body.linearVelocity;          // Unity 6 name; not .velocity
            _body.linearVelocity = new Vector3(input.x * _speed, velocity.y, input.y * _speed);
        }

        private void OnJump(InputAction.CallbackContext context) =>
            _body.AddForce(Vector3.up * _jumpSpeed, ForceMode.VelocityChange);
    }
}
```

- **Rebinding:** use `action.PerformInteractiveRebinding()` and persist the result with
  `actions.SaveBindingOverridesAsJson()` / `LoadBindingOverridesFromJson()`. Rebindable controls are
  an accessibility baseline (route to `game-accessibility-specialist`).
- **Action maps** separate Player, UI and Vehicle contexts. Disable the maps that should not hear
  input instead of adding `if (paused)` checks.

---

## 2. UI Toolkit vs UGUI

| Need | Pick |
|---|---|
| Editor tools, inspectors | UI Toolkit (always) |
| New runtime menus, HUD, settings screens | UI Toolkit: USS styling, runtime data binding (Unity 6), native SVG (6.3) |
| Heavy world-space UI, existing UGUI project, Asset Store UI kits | UGUI + TextMeshPro |
| Screen-reader support | Check 6.3's native screen reader APIs with `game-accessibility-specialist` |

Runtime data binding (Unity 6+):

```csharp
using Unity.Properties;
using UnityEngine;
using UnityEngine.UIElements;

namespace Game.UI
{
    public sealed class PlayerHud : MonoBehaviour
    {
        public sealed class HudModel
        {
            [CreateProperty] public float Health { get; set; } = 100f;
        }

        [SerializeField] private UIDocument _document;
        private readonly HudModel _model = new();

        private void OnEnable()
        {
            ProgressBar bar = _document.rootVisualElement.Q<ProgressBar>("health-bar");
            bar.dataSource = _model;
            bar.SetBinding("value", new DataBinding
            {
                dataSourcePath = new PropertyPath(nameof(HudModel.Health)),
                bindingMode = BindingMode.ToTarget
            });
        }

        public void SetHealth(float value) => _model.Health = value;
    }
}
```

Unity 6.6 adds USS `backdrop-filter` and a `drop-shadow` filter function. Do not use them in
projects pinned to 6.3 LTS.

---

## 3. Pooling, animation and camera

```csharp
using UnityEngine;
using UnityEngine.Pool;

namespace Game.Gameplay
{
    public sealed class BulletPool : MonoBehaviour
    {
        [SerializeField] private Bullet _prefab;
        private ObjectPool<Bullet> _pool;

        private void Awake() => _pool = new ObjectPool<Bullet>(
            createFunc: () => Instantiate(_prefab),
            actionOnGet: b => b.gameObject.SetActive(true),
            actionOnRelease: b => b.gameObject.SetActive(false),
            actionOnDestroy: b => Destroy(b.gameObject),
            collectionCheck: false, defaultCapacity: 64, maxSize: 512);

        public Bullet Get() => _pool.Get();
        public void Release(Bullet bullet) => _pool.Release(bullet);
    }
    // Bullet is a MonoBehaviour in its own Bullet.cs (component class name must match the file name).
}
```

- **Animator:** cache parameter IDs with `static readonly int SpeedId = Animator.StringToHash("Speed");`.
  Drive hit windows with Animation Events, not polling.
- **Cinemachine 3** (a core package in 6.6): use `CinemachineCamera`, `CinemachineFollow`,
  `CinemachinePositionComposer`, `CinemachineConfiner2D` and `CinemachineImpulseSource`. Agents often
  emit Cinemachine 2 names (`CinemachineVirtualCamera`, `CinemachineFramingTransposer`). Those belong to
  the old API.

---

## 4. Editor tooling

Write custom inspectors in UI Toolkit (`CreateInspectorGUI`), not IMGUI, for new tools. Always
record undo.

```csharp
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;

namespace Game.Editor
{
    [CustomEditor(typeof(Game.Gameplay.EnemySpawner))]
    public sealed class EnemySpawnerEditor : UnityEditor.Editor
    {
        public override VisualElement CreateInspectorGUI()
        {
            var root = new VisualElement();
            InspectorElement.FillDefaultInspector(root, serializedObject, this);
            root.Add(new Button(() =>
            {
                var spawner = (Game.Gameplay.EnemySpawner)target;
                Undo.RecordObject(spawner.transform, "Snap Spawner");
                spawner.transform.position = UnityEngine.Vector3Int.RoundToInt(spawner.transform.position);
            }) { text = "Snap to grid" });
            return root;
        }
    }
}
```

Place editor code in an Editor-only asmdef so it never reaches player builds.
