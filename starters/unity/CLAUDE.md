# Unity 6.x Engine Configuration

This section configures Claude Code for a Unity 6.x project. Append to your project's CLAUDE.md or use standalone.

## Engine Details

- **Engine**: Unity 6 (6000.x)
- **Primary Language**: C#
- **Render Pipeline**: URP (or HDRP -- specify yours)
- **Engine Specialist**: `/game-unity-specialist`

When asking engine-specific questions, use `/game-unity-specialist`. For architecture questions that are engine-agnostic, use `/game-technical-director`.

## Project Structure

```
Assets/
  Scripts/
    Runtime/              -- Game code (assemblies: Game.Runtime)
      Components/         -- MonoBehaviour components
      Systems/            -- Core game systems (combat, inventory, etc.)
      StateMachines/      -- State machine implementations
      Data/               -- ScriptableObject definitions
      UI/                 -- UI scripts (UI Toolkit or UGUI)
      Utils/              -- Shared utilities
    Editor/               -- Editor scripts (assembly: Game.Editor)
    Tests/
      EditMode/           -- Edit-mode unit tests
      PlayMode/           -- Play-mode integration tests
  Prefabs/                -- Reusable prefab assets
    Characters/
    Environment/
    UI/
    VFX/
  Scenes/
    Levels/               -- Gameplay scenes
    UI/                   -- UI-only scenes (menus, loading)
    _Boot.unity           -- Bootstrap scene (loaded first)
  Resources/              -- ONLY for assets that MUST load by name at runtime
  ScriptableObjects/      -- SO asset instances (data containers)
    Config/               -- Game configuration data
    Events/               -- SO event channels
  Art/
    Sprites/
    Textures/
    Models/
    Animations/
    Materials/
  Audio/
    Music/
    SFX/
  Fonts/
  Shaders/
  AddressableAssetsData/  -- Addressables config (if using Addressables)
Packages/
  manifest.json           -- Package dependencies
ProjectSettings/          -- Unity project settings
```

## C# Coding Standards

### Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | PascalCase.cs | `PlayerController.cs` |
| Classes | PascalCase | `public class PlayerController : MonoBehaviour` |
| Interfaces | IPascalCase | `public interface IDamageable` |
| Public methods | PascalCase | `public void TakeDamage(float amount)` |
| Private methods | PascalCase | `private void CalculateMovement()` |
| Public fields | camelCase | `public float moveSpeed;` |
| Private fields | _camelCase | `private float _currentHealth;` |
| Properties | PascalCase | `public float Health { get; private set; }` |
| Constants | PascalCase | `public const float MaxSpeed = 400f;` |
| Static readonly | PascalCase | `public static readonly Vector3 SpawnOffset = ...;` |
| Enums | PascalCase name, PascalCase entries | `enum PlayerState { Idle, Running, Jumping }` |
| Events | PascalCase with Event suffix | `public event Action<float> HealthChangedEvent;` |
| Serialized fields | _camelCase with [SerializeField] | `[SerializeField] private float _jumpForce = 10f;` |

### Access Modifiers Are Mandatory

Always specify access modifiers explicitly. No implicit `private`.

```csharp
// Correct
private int _health;
[SerializeField] private float _moveSpeed = 5f;
public void TakeDamage(float amount) { }

// Wrong -- implicit access modifier
int _health;
float _moveSpeed = 5f;
void TakeDamage(float amount) { }
```

### MonoBehaviour Lifecycle

- Use `Awake()` for self-initialization and caching component references.
- Use `Start()` for initialization that depends on other objects being ready.
- Use `OnEnable()`/`OnDisable()` for event subscriptions.
- Never call `GetComponent<T>()` in `Update()`. Cache in `Awake()`.
- Use `FixedUpdate()` for physics. Use `Update()` for input and rendering logic. Use `LateUpdate()` for camera follow.

```csharp
private Rigidbody2D _rb;
private SpriteRenderer _sprite;

private void Awake()
{
    _rb = GetComponent<Rigidbody2D>();
    _sprite = GetComponent<SpriteRenderer>();
}

private void OnEnable()
{
    EventBus.OnPlayerDamaged += HandleDamage;
}

private void OnDisable()
{
    EventBus.OnPlayerDamaged -= HandleDamage;
}
```

### ScriptableObject-Driven Architecture

- Gameplay values live in ScriptableObjects, not hardcoded in MonoBehaviours.
- Use SO event channels for decoupled communication between systems.
- Use SO variables (FloatVariable, IntVariable) for shared state that multiple systems read.

```csharp
[CreateAssetMenu(fileName = "WeaponData", menuName = "Game/Weapon Data")]
public class WeaponData : ScriptableObject
{
    public string weaponName;
    public float baseDamage = 10f;
    public float attackSpeed = 1f;
    public float range = 2f;
    public float knockbackForce = 5f;
}
```

### Assembly Definitions

Use Assembly Definitions (`.asmdef`) for any project beyond a prototype. Minimum structure:

- `Game.Runtime.asmdef` -- core game code
- `Game.Editor.asmdef` -- editor-only code (references Game.Runtime)
- `Game.Tests.EditMode.asmdef` -- edit-mode tests
- `Game.Tests.PlayMode.asmdef` -- play-mode tests

This cuts incremental compile times from minutes to seconds.

## Unity-Specific Code Review Criteria

When reviewing Unity code (`/game-code-review`), check for:

- [ ] No `FindObjectOfType`, `GameObject.Find`, or `FindObjectsOfType` at runtime
- [ ] No assets in the `Resources/` folder (use Addressables for dynamic loading)
- [ ] All access modifiers explicitly stated
- [ ] `GetComponent<T>()` calls cached in `Awake()`, never called in `Update()`
- [ ] ScriptableObjects used for data, not hardcoded values in MonoBehaviours
- [ ] Events subscribed in `OnEnable()` and unsubscribed in `OnDisable()`
- [ ] Coroutines properly managed (stopped on disable/destroy, not leaked)
- [ ] `[SerializeField]` preferred over public fields for Inspector exposure
- [ ] Assembly definitions present for non-prototype projects
- [ ] Input handled via the new Input System, not legacy `Input.GetKey`
- [ ] No string-based method invocation (`SendMessage`, `Invoke` with string)

## Build and Test Commands

```bash
# Run edit-mode tests from command line
unity -batchmode -nographics -projectPath . -runTests -testPlatform EditMode -testResults results.xml

# Run play-mode tests
unity -batchmode -nographics -projectPath . -runTests -testPlatform PlayMode -testResults results.xml

# Build the project (Windows target)
unity -batchmode -nographics -projectPath . -executeMethod BuildScript.BuildWindows -quit

# Build the project (Linux target)
unity -batchmode -nographics -projectPath . -executeMethod BuildScript.BuildLinux -quit

# Note: Replace 'unity' with the full path to your Unity Editor executable
# Windows: "C:/Program Files/Unity/Hub/Editor/6000.x.xf1/Editor/Unity.exe"
# macOS: /Applications/Unity/Hub/Editor/6000.x.xf1/Unity.app/Contents/MacOS/Unity
# Linux: ~/Unity/Hub/Editor/6000.x.xf1/Editor/Unity
```

## Unity Anti-Patterns to Flag

These patterns must be caught during code review or refactored on sight:

1. **Runtime Find calls**: `FindObjectOfType<Player>()` in gameplay code -- use references or events
2. **Resources folder abuse**: Assets in `Resources/` load into memory at startup and cannot be individually unloaded
3. **String method invocation**: `SendMessage("OnDamage")` -- use direct calls, interfaces, or events
4. **Missing access modifiers**: `int health;` without `private` -- always be explicit
5. **GetComponent in Update**: Querying components every frame instead of caching
6. **Coroutine leaks**: Starting coroutines without stopping them on object disable or destroy
7. **Hardcoded gameplay values**: `transform.position += Vector3.right * 5f` instead of using SO data
8. **Legacy Input**: `Input.GetKeyDown(KeyCode.Space)` instead of the new Input System
