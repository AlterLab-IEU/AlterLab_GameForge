# Unity 6 Engine Configuration (AlterLab GameForge)

Engine section for a Unity 6 project worked on with Claude Code and GameForge. Append it to your
project's CLAUDE.md (or use it standalone), then fill in the `[BRACKETS]`.

## Engine Details

- **Unity version:** [6000.3.x LTS]. `ProjectSettings/ProjectVersion.txt` is the source of truth.
  6.3 LTS is supported to Dec 2027, 6.6 is the current Update release, and 6.0 LTS left standard
  support on 2026-10-16.
- **Render pipeline:** [URP]. URP for new projects. HDRP gets no new features. Built-in is
  deprecated from 6.5.
- **Input:** Input System with project-wide actions. The legacy Input Manager is off.
- **UI:** [UI Toolkit | UGUI + TextMeshPro]
- **Scripting backend / targets:** [IL2CPP] / [Windows, macOS, Web]
- **GameForge skills:** engine questions `/gameforge:game-unity-specialist`; engine-agnostic
  architecture `/gameforge:game-technical-director`; netcode `/gameforge:game-multiplayer`; CI
  `/gameforge:game-ci-pipeline`; web release `/gameforge:game-web-publish`; unsure `/gameforge:game-help`.

## Required Editor Settings (confirm before the first commit; upgraded projects can differ)

- **Version Control mode: Visible Meta Files.** `ProjectSettings/VersionControlSettings.asset`
  shows `m_Mode: Visible Meta Files`.
- **Asset Serialization: Force Text.** `ProjectSettings/EditorSettings.asset` shows
  `m_SerializationMode: 2`. Scenes, prefabs and assets then diff and merge as YAML.
- **Enter Play Mode without domain reload** (the default for new 6.6 projects). Code must reset
  static state explicitly.

## Project Layout

```
Assets/_Project/                 -- our code and content (third-party stays outside)
  Core/       Game.Core.asmdef       -- pure rules, no scene dependencies
  Gameplay/   Game.Gameplay.asmdef   -- MonoBehaviours, refs Core
  UI/         Game.UI.asmdef         -- refs Core, Gameplay
  Editor/     Game.Editor.asmdef     -- Editor-only tools
  Tests/EditMode/  Tests/PlayMode/   -- test asmdefs
  Data/       -- ScriptableObject assets (config, event channels)
  Art/ Audio/ Prefabs/ Scenes/ Settings/
Packages/manifest.json           -- package versions (commit it, with packages-lock.json)
design/  docs/architecture/  production/   -- GameForge docs, ADRs, sprint and session files
```

## Rules for Claude

1. **Never hand-edit Unity-owned files.** That means `.meta` files (their GUIDs link every
   reference), `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Build*/` and generated `*.csproj` /
   `*.sln`. GameForge's hook blocks the folders and project files, and asks before `.meta` edits.
2. **Do not edit scene or prefab YAML structurally.** Use the Editor, Unity's agent plugin or an MCP
   tool, or list the exact Inspector steps for a human.
3. **Do not invent package versions.** Add packages through the Package Manager, or with versions
   confirmed there.
4. **Read `ProjectSettings/ProjectVersion.txt` before using an API.** Check uncertain APIs on
   `docs.unity.com/en-us/engine/<6000.x>/` for this version.
5. **Use current Unity 6 APIs:**

| Do not write | Write |
|---|---|
| `FindObjectOfType<T>()` | A serialized reference, or `FindFirstObjectByType<T>()` / `FindAnyObjectByType<T>()` at startup only |
| `rb.velocity`, `rb.drag` | `rb.linearVelocity`, `rb.linearDamping` |
| `Input.GetKeyDown(...)` | Input System actions |
| URP pass `Execute(...)` | `RecordRenderGraph(...)` (Compatibility Mode was removed in 6.4) |
| `Entities.ForEach`, `IAspect` | `IJobEntity`, `SystemAPI.Query` |
| `CinemachineVirtualCamera` | `CinemachineCamera` (Cinemachine 3) |
| `BinaryFormatter` saves | JSON or our own binary format |

## C# Conventions

| Element | Convention | Example |
|---|---|---|
| Classes, methods, properties | PascalCase | `public float Health { get; private set; }` |
| Private / serialized fields | `_camelCase` | `[SerializeField] private float _jumpForce = 10f;` |
| Interfaces | `IPascalCase` | `IDamageable` |
| Events | PascalCase | `public event Action<int> HealthChanged;` |
| Namespaces | Match the assembly | `namespace Game.Gameplay` |

- Write access modifiers explicitly. Prefer `[SerializeField] private` over public fields.
- Tunables live in ScriptableObjects or serialized fields, not literals.
- Cache components in `Awake`. Subscribe in `OnEnable` and unsubscribe in `OnDisable`.
- No per-frame allocations: no LINQ or string building in `Update`. Pool spawned objects.
- Use `Awaitable` + `destroyCancellationToken` for async code, and `async void` only at Unity entry
  points.
- No runtime `Find`, no `SendMessage`, and no game content in `Resources/`. Use Addressables.

## Agent Verification Loop (run before saying "done")

1. **Compile.** Refresh through Unity's plugin or MCP if the Editor is open, otherwise run the
   batchmode compile below. Zero `error CS`, and review every `warning CS0618` (obsolete API).
2. **Read the console and logs** for missing references and serialization errors.
3. **Run Edit Mode tests,** then the Play Mode smoke tests for the touched scenes.
4. **Review `git status` and `git diff`:** exactly one new `.meta` per new asset, no changed GUIDs,
   no `Library/` or `*.csproj` files, and only intended scene and prefab changes.
5. **Hand off to a human for Play Mode** whenever the change touches feel, camera or UI.
6. **Update `production/session-state/active.md`** with decisions and next steps.

## Commands

The Editor must be closed for batchmode runs (the project lock blocks them). Set `UNITY_EDITOR` to
this version's Editor binary. Default Hub paths: Windows
`C:\Program Files\Unity\Hub\Editor\<ver>\Editor\Unity.exe`, macOS
`/Applications/Unity/Hub/Editor/<ver>/Unity.app/Contents/MacOS/Unity`, Linux
`~/Unity/Hub/Editor/<ver>/Editor/Unity`.

```bash
# Compile check (exits non-zero on compiler errors)
"$UNITY_EDITOR" -batchmode -nographics -quit -projectPath . -logFile Logs/compile.log

# Tests -- never add -quit to -runTests
"$UNITY_EDITOR" -batchmode -nographics -projectPath . -runTests -testPlatform EditMode \
  -testResults Logs/editmode.xml -logFile Logs/editmode.log
"$UNITY_EDITOR" -batchmode -projectPath . -runTests -testPlatform PlayMode \
  -testResults Logs/playmode.xml -logFile Logs/playmode.log

# Build (one target per process; Game.Editor.BuildScript lives in the Editor asmdef)
"$UNITY_EDITOR" -batchmode -nographics -quit -projectPath . \
  -executeMethod Game.Editor.BuildScript.BuildWindows -buildTarget StandaloneWindows64 \
  -logFile Logs/build.log
```

**AI integrations:** Unity's Claude Code plugin needs the Unity CLI, `unity pipeline install` in this
project, and an open Editor. Check the Editor link with `unity status`.

```text
/plugin marketplace add Unity-Technologies/unity-agent-plugin
/plugin install unity@unity-agent-plugin
```

Keep any MCP server (official Unity MCP via `unity mcp configure`, or CoplayDev/unity-mcp) on
localhost. Commit before asking an agent for a large change.

## Commit Convention

Write subjects as `type(scope): summary`, imperative and at most 72 characters. GameForge's commit
hook enforces this once `.gameforge/` exists (`"commit_convention": "conventional"` in
`.gameforge/project.json`).

| Type | Example |
|---|---|
| `feat` | `feat(combat): add parry window to melee attacks` |
| `fix` | `fix(input): unsubscribe jump action in OnDisable` |
| `balance` | `balance(economy): raise wave 5 gold from 40 to 55` |
| `art` / `audio` | `art(env): add forest tileset` / `audio(ui): add confirm SFX` |
| `design` / `level` | `design(gdd): spec dash mechanic` / `level(w1-3): add secret room` |
| `ui` / `perf` | `ui(hud): move ammo counter` / `perf(spawner): pool projectiles` |
| `refactor` / `test` | `refactor(core): extract DamageMath` / `test(inventory): cover full stacks` |
| `chore` / `docs` | `chore(deps): update Input System` / `docs(adr): record URP choice` |

## .gitignore Essentials

Do **not** ignore `Packages/` (embedded packages live there) or `Assets/StreamingAssets/` (shipped
content). Keep everything in `production/` except session data.

```gitignore
/[Ll]ibrary/
/[Tt]emp/
/[Oo]bj/
/[Ll]ogs/
/[Uu]ser[Ss]ettings/
/[Mm]emoryCaptures/
/[Bb]uild/
/[Bb]uilds/
/[Rr]ecordings/
/ServerData/
/[Aa]ssets/[Ss]treaming[Aa]ssets/aa/
/[Aa]ssets/[Ss]treaming[Aa]ssets/aa.meta
.vs/
.idea/
*.csproj
*.sln
*.user
*.pdb
*.apk
*.aab
.DS_Store
Thumbs.db
production/session-state/
production/session-logs/
```

## .gitattributes (Git LFS + Smart Merge)

Run `git lfs install` once per machine. GameForge's hook blocks commits of non-LFS files of 20 MB or
more (`lfs_threshold_mb`).

```gitattributes
* text=auto
*.cs         text diff=csharp
*.unity      merge=unityyamlmerge eol=lf
*.prefab     merge=unityyamlmerge eol=lf
*.asset      merge=unityyamlmerge eol=lf
*.mat        merge=unityyamlmerge eol=lf
*.anim       merge=unityyamlmerge eol=lf
*.controller merge=unityyamlmerge eol=lf
*.meta       merge=unityyamlmerge eol=lf
**/LightingData.asset filter=lfs diff=lfs merge=lfs -text
*.png  filter=lfs diff=lfs merge=lfs -text
*.jpg  filter=lfs diff=lfs merge=lfs -text
*.psd  filter=lfs diff=lfs merge=lfs -text
*.tga  filter=lfs diff=lfs merge=lfs -text
*.exr  filter=lfs diff=lfs merge=lfs -text
*.fbx  filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text
*.wav  filter=lfs diff=lfs merge=lfs -text
*.ogg  filter=lfs diff=lfs merge=lfs -text
*.mp3  filter=lfs diff=lfs merge=lfs -text
*.mp4  filter=lfs diff=lfs merge=lfs -text
*.ttf  filter=lfs diff=lfs merge=lfs -text
*.otf  filter=lfs diff=lfs merge=lfs -text
*.dll  filter=lfs diff=lfs merge=lfs -text
*.so   filter=lfs diff=lfs merge=lfs -text
*.bank filter=lfs diff=lfs merge=lfs -text
```

Register UnityYAMLMerge, which ships in the Editor's `Tools` folder (Unity Manual: "Smart merge"),
once per clone:

```bash
git config merge.unityyamlmerge.name "UnityYAMLMerge"
git config merge.unityyamlmerge.driver "'<path-to>/UnityYAMLMerge' merge -p %O %B %A %A"
```
