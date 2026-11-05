# Unity 6.x Review Checklist

Version anchors (November 2026): **Unity 6.3 LTS** (supported to December 2027) and **Unity 6.6**
(current Update release). Unity 6.0 LTS left standard support on 2026-10-16. Unity 7.0 is an alpha
and the first CoreCLR editor; do not judge 6.x code against it. Read the version from
`ProjectSettings/ProjectVersion.txt`.

## 1. Outdated APIs agents still write (A1)

| Stop | Use (Unity 6) | Grep |
|---|---|---|
| `FindObjectOfType<T>()` | `FindFirstObjectByType<T>()` or `FindAnyObjectByType<T>()` | `FindObjectOfType` |
| `FindObjectsOfType<T>()` | `FindObjectsByType<T>(FindObjectsSortMode.None)` | `FindObjectsOfType` |
| `rigidbody.velocity`, `.drag`, `.angularDrag` | `linearVelocity`, `linearDamping`, `angularDamping` (3D and 2D) | `\.velocity\b\|\.drag\b\|angularDrag` |
| `WWW` | `UnityWebRequest` | `new WWW\(` |
| UNet (`UnityEngine.Networking` HLAPI, `[Command]`, `[SyncVar]`) | Netcode for GameObjects (`NetworkBehaviour`, `[Rpc(...)]`, `NetworkVariable`) or your chosen stack | `SyncVar\|UnityEngine.Networking` |
| Cinemachine 2 (`CinemachineVirtualCamera`, namespace `Cinemachine`) | Cinemachine 3 (`CinemachineCamera`, namespace `Unity.Cinemachine`); Cinemachine 2 is deprecated in 6.6 | `CinemachineVirtualCamera\|using Cinemachine;` |
| Separate `com.unity.textmeshpro` package added by hand | TextMeshPro ships inside `com.unity.ugui` in Unity 6 | `com.unity.textmeshpro` in `Packages/manifest.json` |
| Legacy Input Manager in gameplay (`Input.GetKey`, `Input.GetAxis`) | Input System actions (`InputAction`, `PlayerInput`, generated action classes) | `Input\.Get(Key\|Axis\|Button)` |
| Pre-Render-Graph URP renderer features (`Execute(ScriptableRenderContext...)` only) | Render Graph path (`RecordRenderGraph`); compatibility mode is being phased out, so verify for your version | `ScriptableRenderPass` |
| `Resources.Load` as the asset strategy | Addressables; Unity 6.6 starts replacing AssetBundles with Content Directories | `Resources\.Load` |

Package names in Unity's AI/inference stack have changed (Sentis was renamed Inference Engine,
`com.unity.ai.inference`, in 6.2, though some Unity pages still say Sentis). Check the package in
`Packages/manifest.json` rather than trusting either name.

## 2. Agent mistakes that compile (A2 / G-checks)

- **Fake null.** `?.` and `??` on `UnityEngine.Object` bypass Unity's overloaded `== null`, so a
  destroyed component is treated as alive. Use explicit `if (thing != null)` or `TryGetComponent`.
- **Static state with Fast Enter Play Mode.** Unity 6.6 enables Fast Enter Play Mode by default, so
  static fields no longer reset between play sessions. Singletons, static events and caches need a
  reset in `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`.
- **`GetComponent` / `Camera.main` / `GameObject.Find` in `Update`.** Cache in `Awake`.
- **Physics in `Update`.** Forces and `MovePosition` belong in `FixedUpdate`; read input in `Update`.
- **Allocating coroutines.** `yield return new WaitForSeconds(x)` inside loops; cache the instruction
  or use `Awaitable` (Unity 2023.1+).
- **`async void`** outside event handlers; unobserved exceptions and continuations after the object
  is destroyed. Check `destroyCancellationToken`.
- **Third-party types without the package.** `UniTask`, `DOTween`, `Odin` attributes used without
  the package in `Packages/manifest.json` or `Assets/Plugins/` (A2/A3).
- **`tag == "Enemy"`** string comparison instead of `CompareTag("Enemy")`.
- **`Debug.Log` in per-frame code** shipped to release (strip with `[Conditional]` or a log wrapper).
- **`public` fields for inspector exposure.** Prefer `[SerializeField] private` plus properties.
- **LINQ in hot paths** (G2).

## 3. Netcode for GameObjects (A6)

- `[Rpc(SendTo.Server)]` / `[ServerRpc]` methods that apply client-provided damage, score, currency
  or position without server validation.
- `NetworkVariable` with `NetworkVariableWritePermission.Owner` on gameplay-critical values.
- Logic gated on `IsOwner` where it should be `IsServer`.
- Purchases or entitlements unlocked from a client callback without server-side receipt validation.

## 4. Project and file hygiene (A8)

| Item | Rule |
|---|---|
| `.meta` files | Committed with every asset; GUIDs stable. A diff that regenerates many `.meta` GUIDs breaks references (MAJOR) |
| `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `obj/` | Never committed |
| `ProjectSettings/*.asset` | Review every change: color space, scripting backend, physics timestep, input handling setting, graphics APIs |
| `Packages/manifest.json` | New registries and git URLs pinned to a tag or hash (A3) |
| Scenes and prefabs | YAML diffs: check for broken `m_Script` GUIDs and missing references after MCP edits |
| Assembly definitions | New `.asmdef` files change compile boundaries; check references are intended |

## 5. MCP and Unity AI changes

Unity AI (open beta since 2026-05-04) ships an in-editor agent, an official MCP server via the Unity
CLI, and an official Claude Code plugin; community servers such as CoplayDev/unity-mcp and
IvanMurzak/Unity-MCP are also common. Editor-driven changes land as scene, prefab and
ProjectSettings YAML. In those diffs check:
- components added with default values where the design expects tuned data;
- `m_Script` references to scripts that exist and compile;
- serialized fields renamed in code without `[FormerlySerializedAs]` (silent data loss);
- build settings or player settings flipped (scripting backend, API compatibility level).

## 6. Quick verification commands for the report

```
dotnet build                                    # only if the project has generated .sln/.csproj
Unity -batchmode -nographics -projectPath . -runTests -testPlatform EditMode -testResults results.xml
# -runTests exits on its own; do not add -quit
```
For CI-based checks route to `game-ci-pipeline` (GameCI test runner or the Unity CLI).
