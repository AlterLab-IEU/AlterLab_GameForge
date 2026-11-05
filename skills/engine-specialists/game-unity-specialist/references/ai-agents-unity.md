# Driving Unity with AI Coding Agents (late 2026)

Read this before setting up Claude Code (or another agent) against a Unity project, choosing an MCP
server, or reviewing a batch of agent-written Unity code.

Unless noted, sources are GameForge's AI-tooling research brief (2026-11-05) and Unity's own docs
pages, fetched 2026-11-05.

---

## 1. The options

| Option | What it is | Cost / licence | Talks to the Editor via | Notes |
|---|---|---|---|---|
| **Unity AI (Assistant)** | In-Editor agent with Ask, Agent and Plan modes, Skills, rollback, and asset Generators | Open beta since 2026-05-04. Uses Unity credits; included in Pro and above; Personal pays US$10/month | Built in | Successor to Muse (retired in 6.2). Now uses third-party models. **AI Gateway** lets you bring an agent subscription you already pay for, without spending Unity credits |
| **Unity's agent plugin** (`Unity-Technologies/unity-agent-plugin`) | Skills for Claude Code, Codex, Grok, Antigravity and Copilot CLI | Free; Unity Companion License; Unity 6.0+ | **Unity CLI** commands, not MCP | Unity's docs call it a third-party integration that Unity does not operate or warrant |
| **Unity MCP server** | Official MCP bridge (Project Settings > AI > Unity MCP Server) | Free, part of Unity AI; Unity 6.0+ | Relay binary + Editor bridge | Optional alongside the plugin: `unity mcp configure` |
| **CoplayDev/unity-mcp** ("MCP for Unity") | Community MCP, about 50 tools: scenes, scripts, assets, tests, profiling, builds | MIT; v10.3.0 (2026-10-04); Unity 2021.3–6.x; Python 3.10+ / uv | Editor package + local server | Install with UPM git URL `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity` or `openupm add com.coplaydev.unity-mcp` |
| **IvanMurzak/Unity-MCP** | Community MCP + CLI; exposes C# methods as tools | Apache-2.0 | Editor plugin; **can also run inside built games** | Make sure it is stripped from release builds |

**Default recommendation:**
1. On Unity 6 with the Editor open, install Unity's plugin first.
2. Add the official Unity MCP server only if a workflow needs MCP tools.
3. Use CoplayDev when the project is on 2021.3/2022 LTS or the user prefers an open-source MCP.

Unity's docs note that the plugin "mainly improves correctness" on some models, because they default
to older approaches. That is exactly the deprecated-API problem in §4.

---

## 2. Setting up Claude Code

Prerequisites (per Unity's "Unity's plugin for Claude Code" page):
- Unity CLI installed.
- The Pipeline package added to the project with `unity pipeline install`.
- The Editor open.

```text
/plugin marketplace add Unity-Technologies/unity-agent-plugin
/plugin install unity@unity-agent-plugin
```

- **Scopes:** user is the default. Project scope shares the plugin with the repo; local is you in
  this repo only. From a shell, use `claude plugin install unity@unity-agent-plugin --scope project`.
- **Verify:** type `/unity:` to list Unity's skills, and run `unity status` to check the Editor link.
- **Updates:** third-party marketplaces do not auto-update by default. Run
  `/plugin marketplace update unity-agent-plugin`, then `/reload-plugins`.

GameForge and Unity's plugin coexist. Unity's skills know Unity's own packages (UI Toolkit,
2D/tilemaps, localization, multiplayer, IAP, LevelPlay). GameForge supplies game design, production
and cross-engine judgement. For Unity package specifics, prefer Unity's skill.

**Docs for agents:**
- Unity publishes `https://docs.unity.com/llms.txt` with per-product files, and `.md` versions of
  docs pages.
- Old `docs.unity3d.com/<version>/Documentation/...` links now redirect to
  `docs.unity.com/en-us/engine/<version>/...`.
- Always open the page for the project's version (`6000.3` vs `6000.6`). APIs differ between them
  (see §4).

---

## 3. Security guardrails

- **Arbitrary code execution:**
  - Unity's plugin skills can run C# in the open Editor.
  - MCP servers that execute code or menu items are arbitrary code execution on the developer's
    machine. Treat them that way.
- **Localhost only.** Never expose an MCP bridge on a LAN or public interface.
- **Auto-approve:** the official MCP server has an "Auto-approve in Batch Mode" setting. Leave it off
  unless the machine is a dedicated, isolated CI runner.
- **Secrets:** Unity AI's MCP client config stores tokens in plain text in `UserSettings/mcp.json`.
  `UserSettings/` must stay gitignored.
- **Version control first:** Unity's plugin README warns that not every change is logged or
  reversible from the Editor. Commit (or stash) before asking an agent for a large change.
- **In-game MCP servers** (IvanMurzak) are a remote-control surface. Exclude them from release
  builds with asmdef platform or define constraints.

---

## 4. What agents get wrong in Unity 6 (verify, then fix)

Each row was checked against the Unity scripting reference for the version named.

| Agents write | Use instead | Evidence |
|---|---|---|
| `FindObjectOfType<T>()` | `FindFirstObjectByType<T>()` (direct replacement) or the faster `FindAnyObjectByType<T>()` | 6.3 Scripting API marks it **Deprecated** |
| `FindObjectsOfType<T>()` | `FindObjectsByType<T>(FindObjectsSortMode.None)` | Same deprecation family |
| `rb.velocity`, `rb.drag`, `rb.angularDrag` | `rb.linearVelocity`, `rb.linearDamping`, `rb.angularDamping` (also on `Rigidbody2D`) | Unity 6 rename; the 6.3 API lists only the new names |
| `Input.GetKeyDown(KeyCode.Space)` | Input System actions (`InputSystem.actions.FindAction(...)`) | Unity 6 manual: Input Manager "will be removed in future versions"; 6.3 warns |
| `obj.GetInstanceID()` as an ID | `obj.GetEntityId()` on 6.4+; `GetInstanceID()` is still current on 6.3 LTS | 6.6 Scripting API marks `GetInstanceID` **Removed** |
| `ScriptableRenderPass.Execute` / `OnCameraSetup`, `cmd.Blit` | `RecordRenderGraph` + `AddBlitPass` | URP Compatibility Mode removed in 6.4 |
| `Entities.ForEach`, `IAspect`, class `IComponentData` | `IJobEntity` / `SystemAPI.Query`, plain components, `UnityObjectRef<T>` | Entities 1.4 obsolete list; 6.6 deprecates managed components |
| `CinemachineVirtualCamera`, `CinemachineFramingTransposer` | `CinemachineCamera`, `CinemachinePositionComposer` (Cinemachine 3) | Cinemachine 3 API |
| `[ServerRpc]` / `[ClientRpc]` in new NGO code | `[Rpc(SendTo.Server)]` and similar universal RPCs | NGO docs: universal `Rpc` supersedes the legacy attributes |
| Enabling dynamic batching for performance | SRP Batcher, GPU Resident Drawer, static batching | Dynamic batching is obsolete in 6.6 |
| Statics that "reset on Play" | Explicit reset via `RuntimeInitializeOnLoadMethod(SubsystemRegistration)` | New 6.6 projects default to no domain reload |
| Custom `ISerializationCallbackReceiver` just to serialize a dictionary | Serialize `Dictionary<TKey,TValue>` directly (**6.6 only**) | What's new in 6.6. Keep the callback approach on 6.3 LTS |
| `BinaryFormatter` saves | JSON (`JsonUtility`, Newtonsoft via `com.unity.nuget.newtonsoft-json`) or a binary format you own | Insecure; removed in modern .NET, so it blocks the CoreCLR move |
| `async void` everywhere, `Task.Delay` | `Awaitable` + `destroyCancellationToken`; `async void` only at Unity entry points | Awaitable scripting reference |

Agents also:
- hand-write `.meta` files or reuse GUIDs from other projects;
- edit scene and prefab YAML directly and break `fileID` links;
- add packages by editing `Packages/manifest.json` with invented version numbers;
- write `public` fields instead of `[SerializeField] private`.

Before trusting a package version, check the Package Manager or the package's changelog.

---

## 5. Forward compatibility: Unity 7 and CoreCLR

**Where things stand:**
- Per Unity's "CoreCLR, Scripting, and .NET Update, October 2026":
  - The **Unity 7.0 alpha** (2026-10-05) is the first CoreCLR Editor, without Mono. It is not
    recommended for production.
  - It still targets **C# 9 and .NET Standard 2.1**. There is no date for C# 14 / .NET 10.
  - Domain reload is replaced by AssemblyLoadContext-based code reload.
- **6.7** carries an experimental CoreCLR desktop player (macOS, Windows, Linux build profiles only).

**What to do now** (so the eventual migration is a recompile, not a rewrite):
1. **Run with domain reload off.** Make every static reset explicit (§4). Unity's 6.6 notes
   recommend this specifically to prepare for removing Mono and domain reload.
2. **Move identity code off instance IDs.** Use `EntityId` / `GetEntityId()` on 6.4+, and never
   persist an instance ID in save data.
3. **Stay within C# 9 / .NET Standard 2.1.** Do not adopt newer language features through compiler
   hacks or `csc.rsp` tricks.
4. **Remove `BinaryFormatter`** (and `SoapFormatter`) from saves and networking.
5. **Audit third-party DLLs and native plugins.** Unity's 6.7 CoreCLR troubleshooting page lists:
   - "Reliance on unsupported runtime behavior",
   - "Dynamic code generation assumptions",
   - "Unsupported native interop edge cases".

   Prefer source packages, or DLLs that target a compatible .NET profile.
6. **Do not use AppDomain APIs** (`AppDomain.CreateDomain` and similar). Modern .NET has no multiple
   AppDomains; CoreCLR uses AssemblyLoadContext.
7. **Trial the move on a branch:** the 6.7 experimental CoreCLR desktop player, or the 7.0 alpha.
   Read Unity's "Path to CoreCLR, 2026: Upgrade Guide" thread for the current breaking-change list.

---

## 6. Prompts that work

```text
Read ProjectSettings/ProjectVersion.txt and Packages/manifest.json first. Target that exact Unity
version. Before using any Unity API you are unsure of, open its page under
docs.unity.com/en-us/engine/<version>/script-reference/ and confirm it is not deprecated.
```

```text
Implement <feature> as plain C# in Game.Core with Edit Mode tests first, then a thin MonoBehaviour
adapter in Game.Gameplay. Do not create or edit .meta files, scenes or prefabs; list the
Inspector wiring I need to do by hand.
```

```text
Review this diff for Unity 6 deprecations (FindObjectOfType, Rigidbody.velocity, legacy Input,
Execute-based render passes, Entities.ForEach), missing unsubscribes in OnDisable, per-frame
allocations, and statics that assume domain reload. Report file:line and the fix.
```

For a full AI-driven build loop, use `/gameforge:game-vibe-code`. For AI-generated art, audio and
their provenance logs, use `/gameforge:game-ai-assets`.
