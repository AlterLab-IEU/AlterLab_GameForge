# Agent and MCP Architecture

Read this before installing, recommending or approving an MCP server, engine agent plugin, or
runtime AI feature. Facts as of 2026-11-05; most of these servers are beta or community-maintained,
so pin versions and re-read their READMEs before upgrading.

## 1. Setup by target

### Unity
- **Official** [1][2]: Unity MCP server through the Unity CLI, plus Unity's agent plugin for Claude
  Code (also Codex, Grok, Antigravity). Unity 6.0+. In Claude Code:
  ```
  /plugin marketplace add Unity-Technologies/unity-agent-plugin
  /plugin install unity@unity-agent-plugin
  ```
- **Community**: CoplayDev/unity-mcp ("MCP for Unity", MIT, v10.3.0 on 2026-10-04): about 50 tools
  for scenes, scripts, assets, tests, profiling and builds; Unity 2021.3-6.x, Python 3.10+ with
  `uv`; install via UPM git URL `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity` or
  `openupm add com.coplaydev.unity-mcp` [3]. IvanMurzak/Unity-MCP (Apache-2.0) also runs inside
  built games, which makes the release-build check in section 4 mandatory [4].
- Unity publishes `docs.unity.com/llms.txt` with per-product files and `.md` page versions [5].

### Unreal Engine 5.8
- **Official, experimental** [6]: enable the *Unreal MCP* and *All Toolsets* plugins, then run the
  console command `ModelContextProtocol.GenerateClientConfig` to write `.mcp.json`. Endpoint
  `127.0.0.1:8000/mcp` over HTTP+SSE (no stdio). **Loopback only, no authentication, editor-only.**
  It can run automation tests, but it is not a CI service.
- **Community**: chongdashu/unreal-mcp (MIT, UE 5.5+, self-described experimental) for Blueprints
  and actors [7].
- The 5.7 in-editor AI Assistant (F1 on any UI element) is separate from MCP [8].

### Godot 4.7
- **No official server and no `llms.txt`** [5].
- **Community**: Coding-Solo/godot-mcp (MIT): launches and runs the project, reads debug output,
  makes basic scene edits [9]:
  ```
  claude mcp add godot -- npx @coding-solo/godot-mcp@<pinned-version>
  ```
  In-editor alternatives: IvanMurzak/Godot-MCP (C#) and "Godot .NET MCP" on the Asset Library [10].
  The ecosystem is fragmented; prefer direct text edits of `.gd`/`.tscn` plus a headless run
  (`godot --headless`) as the check.

### Blender
- **Community**: ahujasid/mcp-for-blender (renamed from blender-mcp, MIT): `uvx mcp-for-blender`
  plus an add-on; integrates Poly Haven, Sketchfab, Hyper3D Rodin, Hunyuan3D and others [11].
- **It runs arbitrary Python over an unauthenticated socket, and telemetry is on by default.** An
  optional safe mode exists. Turn telemetry off, start it only while you use it, and remember the
  Hunyuan3D license excludes the EU, UK and South Korea, outputs included (route license checks to
  `/gameforge:game-ai-assets`).

### Web games
- No official three.js or Phaser MCP. Use the official docs-for-agents files instead:
  `threejs.org/llms.txt`, `threejs.org/docs/llms-full.txt` (includes TSL), `r3f.docs.pmnd.rs/llms.txt`,
  `doc.babylonjs.com/llms.txt`, `developer.playcanvas.com/llms.txt` [12].
- PlayCanvas ships an official Editor MCP server: `npx -y @playcanvas/editor-mcp-server` [12].
- The test loop is a headless browser: Playwright screenshots plus `window.render_game_to_text()`
  and `window.advanceTime(ms)` hooks for deterministic state checks [13].

### Other creative tools
- Figma: official remote MCP at `https://mcp.figma.com/mcp`; write-to-canvas is remote-only and
  beta [14]. Cascadeur 2026.2 ships a simple MCP server [15]. Aseprite and Tiled have single-
  maintainer community servers only [16].

## 2. Threat model

| Threat | How it happens | Control |
|---|---|---|
| Arbitrary code execution | "Execute script/Python/C#" tools run with your user's rights | Deny by default; allow per task; read what runs |
| Unauthenticated local ports | Any local process, and potentially a malicious web page via DNS rebinding, can reach a localhost HTTP server | Run servers only while needed; never bind beyond loopback; never tunnel |
| Prompt injection | Instructions hidden in downloaded assets, READMEs, level files, store pages or player text the agent reads | Treat downloaded content as data; isolate asset downloads; review agent plans |
| Supply chain | `npx`/`uvx` without a version pulls whatever is latest | Pin versions; review changelogs before upgrades |
| Telemetry and data leakage | Servers that phone home, cloud generators receiving unreleased art | Disable telemetry; check each tool's data terms |
| Shipped agent surface | MCP bridges or debug endpoints left in release builds | CI check (section 4) |
| Silent breakage | Agent edits to binary or generated files | Edit through the editor; GameForge's hook blocks direct writes |

## 3. Least-privilege configuration

Project-scoped servers go in `.mcp.json` (committed, no secrets; reference environment variables).
Permissions go in `.claude/settings.json`. A starting point:

```json
{
  "enabledMcpjsonServers": ["godot"],
  "permissions": {
    "allow": ["mcp__godot"],
    "deny": ["mcp__blender"]
  }
}
```

- `mcp__<server>` matches every tool of that server; `mcp__<server>__<tool>` matches one tool.
  List the server's tools (`/mcp`) and deny its code-execution tool by name when the server mixes
  safe and dangerous tools.
- Keep write-capable servers disabled until a task needs them; prefer separate read-only and
  write sessions for big refactors.
- Record which servers are approved, by whom and at which version in the ADR "Agent tooling and
  MCP servers".

## 4. Release-build check

Fail CI if any agent bridge can run in a shipped build. Adapt the checks to the servers you use:

- **Unity**: editor-only assemblies never reach player builds, so editor MCP packages are safe.
  Any package with a runtime part (IvanMurzak/Unity-MCP can run inside built games) must sit behind
  a scripting define, for example `AGENT_BRIDGE`, that only development build profiles set. CI
  fails if a release profile defines it.
- **Godot**: editor plugins do not run in exports, but an autoload does. Fail if an MCP addon is
  registered as an autoload:
  ```
  sed -n '/^\[autoload\]/,/^\[/p' project.godot | grep -i mcp && exit 1
  ```
- **Web**: gate test hooks behind a dev-only flag (for example `import.meta.env.DEV` in Vite) and
  fail if they reach the production bundle:
  ```
  grep -l "render_game_to_text\|advanceTime" dist/assets/*.js && exit 1
  ```

## 5. Review gates for agent changes

1. The change has a passing check (test, build exit code, screenshot comparison).
2. The diff touches only the systems the task named. Unexplained edits elsewhere are rejected.
3. APIs exist in the pinned engine version (no Phaser 3 calls in Phaser 4, no `THREE.Clock` in
   r187, no Mono-only tricks headed for CoreCLR).
4. New dependencies have an ADR and a license check.
5. Hot-path changes have a profile on minimum-spec hardware.
6. Load-bearing systems go through `/gameforge:game-code-review`.

## 6. AI tool evaluation matrix

Score any AI tool (asset generator, voice, runtime model, test agent) before adoption, using the
project's real inputs, not vendor demos.

| Criterion | Weight | Questions |
|---|---|---|
| Output quality | High | Meets the quality bar set by the owning director, on our inputs? |
| License and data terms | Critical | Commercial use of outputs? Regional exclusions? Indemnity? Training data disputes? |
| Disclosure impact | High | Does it create Steam pre-generated or live-generated content, or EU Art. 50 duties? |
| Latency | High (runtime) / Low (pipeline) | Fits the frame or turn budget? |
| Cost | Medium | Per unit at projected volume; caps and alerts possible? |
| Integration | Medium | API, SDK or MCP for our engine? Effort in days? |
| Reliability | High | Uptime, offline fallback, behavior when the service is down |
| Vendor risk | Medium | Funding, bus factor, open alternative as escape hatch |

## 7. Runtime AI features

- **On-device** is the most production-ready route: NVIDIA ACE's Game Agent SDK and UE5 plugins
  run local speech recognition, a small language model and TTS with function calling, and are live
  in *inZOI* and *NARAKA: BLADEPOINT* [17]. No per-call cost, but VRAM is limited.
- **Cloud** means ongoing cost and latency. Inworld TTS-1.5 is listed at about US$5-10 per million
  characters (third-party pricing page, Oct 2026) [18]. Valve suggests covering live-AI costs through
  price, microtransactions, a subscription or DLC [19].
- **Architecture**: the model proposes, deterministic systems decide. Route model output through
  function calls into game rules; never let free text mutate state, prices or inventory directly.
  Players quickly exploited *Where Winds Meet*'s AI chat NPCs [20]; plan for prompt injection.
- **Obligations**: Steam requires described guardrails for live-generated content; Microsoft Store
  policy 11.16 requires disclosure and a report path; the EU AI Act Art. 50(1) requires telling
  players an NPC is AI unless obvious [19][21][22]. Hand the disclosure design to the Creative
  Director and UX.

## Sources

All accessed 2026-11-05.
1. Unity AI tools page: https://unity.com/features/ai
2. Unity docs, plugin for Claude Code: https://docs.unity.com/en-us/ai/unity-plugin/claude-code
3. CoplayDev/unity-mcp: https://github.com/CoplayDev/unity-mcp
4. IvanMurzak/Unity-MCP: https://github.com/IvanMurzak/Unity-MCP
5. Direct `llms.txt` checks: https://docs.unity.com/llms.txt (200), https://docs.godotengine.org/llms.txt (404)
6. Epic docs, Unreal MCP in Unreal Editor: https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor?lang=en-US
7. chongdashu/unreal-mcp: https://github.com/chongdashu/unreal-mcp
8. Digital Production, UE 5.7: https://digitalproduction.com/2025/11/12/unreal-engine-5-7-foliage-pcg-and-in-editor-ai/
9. Coding-Solo/godot-mcp: https://github.com/Coding-Solo/godot-mcp
10. IvanMurzak/Godot-MCP: https://github.com/IvanMurzak/Godot-MCP
11. ahujasid/mcp-for-blender: https://github.com/ahujasid/mcp-for-blender
12. three.js `llms.txt`: https://threejs.org/llms.txt ; PlayCanvas `llms.txt`: https://developer.playcanvas.com/llms.txt
13. OpenAI `develop-web-game` skill: https://github.com/openai/skills/tree/main/skills/.curated/develop-web-game
14. Figma MCP server guide: https://github.com/figma/mcp-server-guide
15. CG Channel, Cascadeur 2026.2: https://www.cgchannel.com/2026/08/nekki-releases-cascadeur-2026-2-with-animation-layers/
16. giangdvdotdev/aseprite-mcp: https://github.com/giangdvdotdev/aseprite-mcp ; rpgjs/tiled-ai: https://github.com/rpgjs/tiled-ai
17. NVIDIA, ACE Game Agent SDK: https://developer.nvidia.com/blog/build-on-device-ai-companions-with-the-nvidia-ace-game-agent-sdk-and-unreal-engine-5-plugins/
18. Toolradar, Inworld pricing: https://toolradar.com/tools/inworld-ai/pricing
19. Steamworks Content Survey: https://partner.steamgames.com/doc/gettingstarted/contentsurvey
20. AOL, *Where Winds Meet* AI NPC exploits: https://www.aol.com/news/where-winds-meet-players-using-115622558.html
21. Microsoft Store Policies 11.16: https://learn.microsoft.com/en-us/windows/apps/publish/store-policies
22. European Commission, Article 50 FAQ: https://digital-strategy.ec.europa.eu/en/faqs/transparency-obligations-under-article-50-ai-act
