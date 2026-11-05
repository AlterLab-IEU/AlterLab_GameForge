# MCP Integrations for Game Development

Model Context Protocol (MCP) servers give a coding agent tools beyond your files and shell. With them it can read the Unity console, spawn actors in Unreal, run a Godot project, drive Blender, or click through a web build. This doc covers the servers that matter for indie game development as of **2026-11-05**: who maintains each one, how mature it is, how to install it (only where the command is verified), what it can do, and what it can break.

For when to use AI at all, see [AI-native game development](ai-native-gamedev.md). For engine choice, see [engine comparison](engine-comparison.md).

---

## When You Need MCP and When You Don't

- **You need an editor bridge** when the source of truth lives inside a running editor:
  - Unity scenes and prefabs with their `.meta` GUIDs.
  - Unreal `.uasset` files and Blueprints, which are binary.
  - Blender scenes.
  - The browser-hosted PlayCanvas Editor.
- **You often don't** for Godot and code-first web games.
  - Godot's `.tscn`, `.tres` and `.gd` files are plain text an agent can edit directly. `godot --headless` runs scripts and tests from the shell.
  - A Three.js or Phaser project is just code plus a browser, so a Playwright loop covers verification.
- **MCP costs context.** Every tool definition is loaded into the session. PlayCanvas notes its 130 tool definitions take about 43,000 tokens [11]. Enable only the servers the current task needs.

---

## At a Glance

| Target | Official option | Leading community option | Maturity | Binding / auth |
|---|---|---|---|---|
| **Unity** | Unity MCP server (Unity AI) and the Unity plugin for Claude Code [1][2][3] | CoplayDev/unity-mcp (MIT, ~15.7k stars) [4] | Official: beta. CoplayDev: mature community | Editor approves each new client connection [3] |
| **Unreal** | Unreal MCP plugin, UE 5.8 [6] | chongdashu/unreal-mcp (MIT, ~2.1k stars) [7] | Experimental | `127.0.0.1:8000`, **no auth** [6] |
| **Godot** | None | Coding-Solo/godot-mcp (MIT, ~6.5k stars) [8] | Community, fragmented | Local process |
| **Blender** | None confirmed | ahujasid/mcp-for-blender (MIT, ~33k stars) [10] | Community, popular | Socket on `localhost:9876`, **no auth, no encryption** [10] |
| **PlayCanvas** | PlayCanvas Editor MCP server [11] | — | New, actively developed | `127.0.0.1:52000` [11] |
| **Web builds (any engine)** | Playwright MCP (Microsoft) [12] | — | Mature | Local browser |
| **Figma** | Remote server `https://mcp.figma.com/mcp` [13] | — | Official; write-to-canvas in beta | OAuth |
| **Aseprite / Tiled / LDtk** | None | pixel-mcp, aseprite-mcp, tiled-ai; no LDtk server found [15][16] | Early, single maintainers | Local |
| **Cascadeur** | Simple MCP server in 2026.2 [17] | — | New | — |
| **ElevenLabs** | Hosted server `https://api.elevenlabs.io/v1/mcp` [18] | — | Official; local server deprecated | OAuth; uses credits |

---

## Claude Code Configuration

These forms are from the Claude Code MCP docs [19]. The `--` separates Claude's own flags from the server's command.

```bash
# Local (stdio) server, available to you in this project only (default scope: local)
claude mcp add godot -- npx @coding-solo/godot-mcp

# Pass environment variables to a stdio server
claude mcp add godot -e GODOT_PATH=/path/to/godot -- npx @coding-solo/godot-mcp

# Remote HTTP server, shared with the team via .mcp.json (scope: project)
claude mcp add --transport http --scope project figma https://mcp.figma.com/mcp

# Inspect and clean up
claude mcp list
claude mcp get godot
claude mcp remove godot
```

**Scopes**
- `local` is the default and applies to you in this project.
- `project` writes the project's `.mcp.json` and is shared through git.
- `user` applies across all your projects.

**Other notes**
- Inside a session, `/mcp` shows server status and handles authentication.
- The SSE transport is deprecated; prefer HTTP where a server offers it [19].

A project-scoped `.mcp.json` looks like this. An entry without `type` is read as stdio:

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["@coding-solo/godot-mcp"],
      "env": { "GODOT_PATH": "${GODOT_PATH:-/usr/local/bin/godot}" }
    },
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

**`.mcp.json` behavior to rely on [19]**
- `${VAR}` and `${VAR:-default}` expand in `command`, `args`, `env`, `url` and `headers`. Keep secrets in your environment, not in the committed file.
- In interactive sessions, Claude Code asks for approval before it uses a project-scoped server from `.mcp.json`. `claude mcp reset-project-choices` resets those approvals.
- **Non-interactive runs skip that prompt.** `claude -p`, Agent SDK sessions and some cloud sessions load project servers without asking. Review `.mcp.json` changes in pull requests the same way you review code.

---

## Unity

**Official Unity MCP server** (part of Unity AI; open beta since 2026-05-04) [1][3]
- **Requirements:** Unity 6.0 or later. Unity's AI page says the MCP server, Unity CLI and plugin are free, with no concurrency limits and no credits needed [1]. Unity's May 2026 setup post also listed the AI Assistant package, a Unity Cloud-connected project and an AI-tools trial or subscription [3]. Check the current terms.
- **Setup in the editor:**
  1. Open **Edit > Project Settings > AI > Unity MCP** and confirm Unity Bridge is running.
  2. Under **Integrations**, pick your client and select **Configure**.
  3. The first time an agent connects, a **Pending Connection** appears. Review the client and **Accept** it. Approved clients reconnect automatically [3].
- **Unity CLI route:** `unity mcp configure` sets up the separate MCP server [2].
- **Tools:** scene hierarchy and GameObjects, C# script create/read/modify, console logs, component values, build settings. Custom tools can be registered in C# [3].

**Unity plugin for Claude Code** [2]
- **Install:**
  ```text
  /plugin marketplace add Unity-Technologies/unity-agent-plugin
  /plugin install unity@unity-agent-plugin
  ```
- **Prerequisites:** the Unity CLI is installed, the Pipeline package is added with `unity pipeline install`, and the editor is open. `unity status` confirms the CLI can reach the editor.
- **What it adds:** Unity skills under `/unity:`. Unity's Claude Code page says the plugin itself ships skills that drive the editor through Unity CLI commands, not through MCP [2].

**CoplayDev/unity-mcp ("MCP for Unity")** [4]
- **Basics:** MIT licence, about 15.7k stars, v10.3.0 (2026-10-04). Supports Unity 2021.3 LTS through 6.x and needs Python 3.10+ with `uv`.
- **Install:**
  - UPM git URL: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
  - OpenUPM: `openupm add com.coplaydev.unity-mcp`
  - Then use **Window > MCP for Unity > Configure All Detected Clients**.
- **Tools:** about 50 entry points covering scenes, GameObjects, scripts, assets, tests, profiling and builds. Use it on pre-Unity 6 projects or when you want no Unity AI dependency.

**IvanMurzak/Unity-MCP** (Apache-2.0, about 4.6k stars) can also run **inside built games** [5]. That is useful for automated testing, but **never leave an MCP bridge in a release build**.

**Security notes**
- Agents write C# and change serialized assets. Commit before each session.
- Never hand-edit `.meta` files. GameForge's PreToolUse hook asks before `.meta` edits; see [hooks](hooks.md).
- Unity 6.6 enables Fast Enter Play Mode by default, so static fields no longer reset between play sessions. Agent-written code that assumes a reset will misbehave.

---

## Unreal Engine

**Unreal MCP (UE 5.8, Experimental)** [6]
- **Enable:**
  - Required: the **Unreal MCP** (`ModelContextProtocol`) and **All Toolsets** plugins.
  - Automatic: Toolset Registry turns on as a dependency.
  - Optional: the **Terminal** plugin.
- **Endpoint:** `http://127.0.0.1:8000/mcp`, configurable. **HTTP and SSE only**; stdio and WebSocket are not supported.
- **Client config:** in the editor console, run `ModelContextProtocol.GenerateClientConfig ClaudeCode`. It writes `.mcp.json` to the project root, pointing at the running server. Other client names: `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`.
- **Capabilities:** spawning and modifying actors, lighting, material instances, inspecting Slate widgets, and running automation tests. Many shipped toolsets are written in Python.
- **Caveats (from Epic's page):**
  - Epic says "many features are incomplete or missing" and APIs may change.
  - Clients should not issue overlapping tool calls.
  - Adding a new `UFUNCTION` tool needs an editor restart.
- **Security:** loopback-only by default and rejects non-loopback `Origin` headers. It has **no authentication layer** and "is not safe to expose beyond the local machine." It is editor-only, so it is **not a CI service**.

**UE 5.7 AI Assistant.** An experimental in-editor helper: press F1 on a UI element to ask about it. It can generate C++ [20].

**Community.** chongdashu/unreal-mcp (MIT, about 2.1k stars) describes itself as experimental. It targets UE 5.5+ and covers Blueprints and actors [7]. Use it on pre-5.8 projects. Unreal MCP inside UEFN is **UNVERIFIED**.

---

## Godot

**Official status:** there is **no official MCP server** and **no `llms.txt`**; `docs.godotengine.org/llms.txt` returns 404 [21]. The community fills the gap.

**Coding-Solo/godot-mcp** (MIT, about 6.5k stars) [8]
- **Install:** `claude mcp add godot -- npx @coding-solo/godot-mcp`. Set `GODOT_PATH` if auto-detection fails.
- **Tools:**
  - Editor and run control: `launch_editor`, `run_project`, `get_debug_output`, `stop_project`.
  - Project info: `get_godot_version`, `list_projects`, `get_project_info`.
  - Scene editing: `create_scene`, `add_node`, `load_sprite`, `export_mesh_library`, `save_scene`.
  - UIDs (Godot 4.4+): `get_uid`, `update_project_uids`.
- **Most useful for:** running the project and reading errors back.

**In-editor plugins** [9]
- IvanMurzak/Godot-MCP (C#).
- "Godot .NET MCP" on the Asset Library (targets 4.6).

The ecosystem is fragmented, with many forks. Check commit activity and read the code before granting write tools.

**Without MCP**
- Agents edit `.gd` and `.tscn` directly.
- Verify with `godot --headless` and your test framework.
- GameForge's hook protects `.godot/` and `*.uid` from accidental edits.

**Contribution policy.** The Godot Foundation's 2026-06-30 policy bans substantial AI-authored code and agent-driven or "vibe-coded" PRs to the *engine*. It does not affect games made with Godot [22].

---

## Blender

**ahujasid/mcp-for-blender** (renamed from `blender-mcp`; MIT; about 33k stars) [10]
- **Install:**
  - Server: `uvx mcp-for-blender setup`.
  - Add-on: `uvx mcp-for-blender install-addon`.
  - Claude Code: `claude mcp add blender -- uvx mcp-for-blender`.
- **Tools:** `execute_blender_code`, `look`, `get_scene_info`, `generate_3d` (Tripo, Hunyuan3D, Hyper3D Rodin or Meshy), `search_assets` and `import_asset` (Poly Haven, Sketchfab, Poly Pizza).
- **Risk: high.**
  - `execute_blender_code` runs **arbitrary Python**, which can read or write anything your user account can.
  - The add-on's socket server (default `localhost:9876`) has **no authentication or encryption**.
- **Mitigations:**
  - Keep `BLENDER_HOST=localhost`.
  - Turn on safe mode (`BLENDER_MCP_SAFE_MODE=1`), which checks scripts before they run.
  - Set `DISABLE_TELEMETRY=true` to turn off all telemetry; content collection is opt-in.
- **Licensing:** `generate_3d` inherits each provider's licence. Hunyuan3D's licence excludes the EU, UK and South Korea. See [AI-native game development](ai-native-gamedev.md#3d).

An official Blender server is **UNVERIFIED**.

---

## Web Engines and Web Builds

**PlayCanvas Editor MCP server** (`playcanvas` GitHub organization; MIT) [11]
- **Install:** `claude mcp add playcanvas -- npx -y @playcanvas/editor-mcp-server`. Needs Node.js 22.18+.
- **Connect:** in the Editor, open the MCP button below Publish and click CONNECT. Chrome's "Apps on device" permission must be allowed.
- **Binding:** listens on `127.0.0.1:52000`. If another process holds that port, the server stops it.
- **Tools:** 130 tools in 15 categories, including entities, scripts, assets, scenes, builds, store, runtime and VCS. Only one agent should own the Editor port at a time.

**Three.js, Babylon.js, Phaser, PixiJS**
- No official MCP servers were found for these. Use their `llms.txt` files (below) and a browser loop.
- Phaser's `llms.txt` tells agents to start with **Phaser AE**, a separate PolyForm Shield-licensed product. Phaser 4 remains the MIT open-source framework [21].

**Playwright MCP** (Microsoft; Apache-2.0; about 39.2k stars) [12]
- **Install:** `claude mcp add playwright -- npx @playwright/mcp@latest`.
- **How it works:** it drives a real browser through the accessibility tree, with no vision model needed. That makes it a natural QA tool for any web build, including Godot and Unity web exports.
- **Useful flags:**
  - `--isolated` keeps the profile in memory.
  - `--headless` runs without a window.
- **Not a security boundary.** `--allowed-origins` is "not a security boundary." `browser_run_code_unsafe` is RCE-equivalent; deny it unless you need it.

Pair it with the `render_game_to_text` / `advanceTime` hooks taught by `/gameforge:game-vibe-code`.

---

## Art, UI, Animation and Audio Tools

- **Figma** [13]
  - The remote server is at `https://mcp.figma.com/mcp`.
  - **Write-to-canvas works only on the remote server** and needs a Full seat to write outside drafts. It is free during the beta and will become usage-based paid.
  - The desktop server runs through the Figma app and needs a Dev or Full seat on a paid plan.
  - Use it for HUD and menu handoff (`/gameforge:game-ux-designer`).
- **Aseprite**
  - willibrandon/pixel-mcp (Go) and giangdvdotdev/aseprite-mcp, both single-maintainer projects [15].
  - PixelLab's MCP is **UNVERIFIED**.
- **Tiled / LDtk**
  - rpgjs/tiled-ai targets Tiled 1.12.2 and has been tested on Linux only [16].
  - **No LDtk MCP server was found.** Both formats are JSON or XML, which agents can edit directly. Validate the result by loading it in the editor.
- **Cascadeur 2026.2** ships a simple MCP server alongside its generative in-betweening [17].
- **ElevenLabs** [18]
  - The local `elevenlabs-mcp` server was **deprecated and its repo archived on 2026-08-20** in favor of a hosted server at `https://api.elevenlabs.io/v1/mcp` (OAuth).
  - Tool calls consume ElevenLabs credits.
  - Log generated voice and SFX in your asset provenance log (`/gameforge:game-ai-assets`).

---

## Docs for Agents (llms.txt)

An `llms.txt` file gives an agent current, curated docs instead of stale training data. Point the agent at it in your project's `CLAUDE.md`. Status as checked on 2026-11-05 [21][23]:

| Engine / framework | `llms.txt` | Notes |
|---|---|---|
| Unity | Yes: `docs.unity.com/llms.txt` | Per-product files; `.md` versions of pages |
| Unreal (Epic docs) | Undetermined (403) | Use Epic's docs pages directly |
| Godot | **No** (404) | Pin the docs version that matches your engine, e.g. `docs.godotengine.org/en/4.7/` |
| Defold | Yes, plus `llms-full.txt` | — |
| Bevy | No (404) | — |
| GameMaker | Undetermined (403) | — |
| Blender | No (404) | — |
| Three.js | Yes: `threejs.org/llms.txt`, `/docs/llms.txt`, `/docs/llms-full.txt` | Recommends an import map pinned to an exact version |
| React Three Fiber, Threlte, TresJS | Yes | — |
| Babylon.js | Yes | — |
| PlayCanvas | Yes | Also agent skills: `npx skills add playcanvas/skills` |
| Phaser | Yes | Steers agents to Phaser AE (see above) |
| Needle Engine | Yes | — |
| Figma | Yes | — |
| Claude Code docs | Yes: `code.claude.com/docs/llms.txt` | — |

---

## Security

Treat every MCP server as code you are running with your own permissions, and every code-execution tool as **arbitrary code execution**.

1. **Bind to localhost and never forward the ports.**
   - Unreal MCP (8000), Blender (9876) and PlayCanvas (52000) all assume a trusted local machine.
   - Unreal and Blender have no authentication.
   - Do not expose them through tunnels, dev containers with published ports, or `0.0.0.0` bindings.
2. **Least privilege.**
   - Enable a server only for the session that needs it, at the narrowest scope (`local` before `project` before `user`).
   - Deny the dangerous tools by name. Permission rules use `mcp__<server>__<tool>`, and deny rules beat allow rules [24]:
     ```json
     {
       "permissions": {
         "deny": ["mcp__blender__execute_blender_code", "mcp__playwright__browser_run_code_unsafe"],
         "allow": ["mcp__godot__run_project", "mcp__godot__get_debug_output"]
       }
     }
     ```
3. **Keep secrets out of config.** Use `${VAR}` expansion in `.mcp.json`. Prefer OAuth-based hosted servers over long-lived API keys in `env`.
4. **Pin and vet.**
   - `npx …@latest` and unpinned `uvx` pull new code every run. Pin versions for anything with write access.
   - Prefer official or well-maintained servers over forks, and read a fork's code before giving it write tools.
5. **Separate untrusted content from code execution.** A session that reads web pages, store listings or player feedback can be prompt-injected. Don't give that same session Blender Python, Playwright `run_code` or shell access unattended.
6. **Review MCP-generated changes like a pull request.**
   - Commit before the session.
   - Work in small batches.
   - Run `git diff` and `git status` afterwards. Editor bridges can touch scenes, prefabs and project settings you never opened.
   - Run tests and the game before accepting anything.
   - `/gameforge:game-code-review` has a pass for agent-generated changes.
7. **Nothing ships.**
   - Remove MCP bridges, debug sockets and test hooks from release builds.
   - Editor-only servers such as Unreal MCP cannot serve CI. Use headless test commands there (`/gameforge:game-ci-pipeline`).
8. **One agent per editor.** PlayCanvas notes that two servers fight over the Editor port. Unreal warns against overlapping tool calls.

---

## Recommended Starting Setups

| Profile | Servers | Notes |
|---|---|---|
| Solo, Godot | Coding-Solo/godot-mcp; Playwright for web exports | Most edits need no MCP. Use the server for run/debug-output loops. |
| Small team, Unity 6 | Official Unity MCP or the Unity plugin; CoplayDev as fallback | Commit each session's changes; review `.meta`/prefab diffs |
| Unreal 5.8 | Unreal MCP (experimental) | Generate `.mcp.json` from the console. Never run it on a shared or remote machine. |
| 3D web (Three.js / R3F) | Playwright; three.js `llms.txt` in `CLAUDE.md` | See `/gameforge:game-threejs-specialist` |
| 2D web (Phaser / PixiJS) | Playwright; Phaser `llms.txt` (with the Phaser AE caveat) | See `/gameforge:game-web2d-specialist` |
| PlayCanvas | PlayCanvas Editor MCP; PlayCanvas agent skills | Budget about 43k tokens of tool definitions |
| Asset work | mcp-for-blender in safe mode; Figma remote | Log every generated asset (`/gameforge:game-ai-assets`) |

---

## Sources

All accessed 2026-11-05. The date in parentheses is the publication or update date where known.

1. Unity, AI tools page: https://unity.com/features/ai
2. Unity docs, "Unity's plugin for Claude Code": https://docs.unity.com/en-us/ai/unity-plugin/claude-code (updated Oct 2026) ; "About Unity's plugin": https://docs.unity.com/en-us/ai/unity-plugin/about-unity-plugin (updated Oct 2026)
3. Unity, "Unity AI MCP: how to get started": https://unity.com/blog/unity-ai-mcp-how-to-get-started (2026-05-11)
4. CoplayDev/unity-mcp: https://github.com/CoplayDev/unity-mcp (v10.3.0, 2026-10-04)
5. IvanMurzak/Unity-MCP: https://github.com/IvanMurzak/Unity-MCP
6. Epic Games, "Unreal MCP in Unreal Editor": https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor?lang=en-US (UE 5.8)
7. chongdashu/unreal-mcp: https://github.com/chongdashu/unreal-mcp
8. Coding-Solo/godot-mcp: https://github.com/Coding-Solo/godot-mcp
9. IvanMurzak/Godot-MCP: https://github.com/IvanMurzak/Godot-MCP ; Godot .NET MCP (Asset Library): https://godotengine.org/asset-library/asset/edit/22867
10. ahujasid/mcp-for-blender: https://github.com/ahujasid/mcp-for-blender
11. playcanvas/editor-mcp-server: https://github.com/playcanvas/editor-mcp-server ; PlayCanvas `llms.txt`: https://developer.playcanvas.com/llms.txt
12. microsoft/playwright-mcp: https://github.com/microsoft/playwright-mcp
13. Figma MCP server docs: https://developers.figma.com/docs/figma-mcp-server/ ; https://github.com/figma/mcp-server-guide
14. Model Context Protocol specification and servers: https://modelcontextprotocol.io/ ; https://github.com/modelcontextprotocol/servers
15. willibrandon/pixel-mcp: https://pkg.go.dev/github.com/willibrandon/pixel-mcp ; giangdvdotdev/aseprite-mcp: https://github.com/giangdvdotdev/aseprite-mcp/releases
16. rpgjs/tiled-ai: https://github.com/rpgjs/tiled-ai
17. CG Channel, Cascadeur 2026.2: https://www.cgchannel.com/2026/08/nekki-releases-cascadeur-2026-2-with-animation-layers/ (2026-08-06)
18. elevenlabs/elevenlabs-mcp (archived 2026-08-20): https://github.com/elevenlabs/elevenlabs-mcp
19. Anthropic, Claude Code MCP docs: https://code.claude.com/docs/en/mcp
20. Digital Production, Unreal Engine 5.7: https://digitalproduction.com/2025/11/12/unreal-engine-5-7-foliage-pcg-and-in-editor-ai/ (2025-11-12)
21. Direct `llms.txt` checks (2026-11-05):
    - Returned 200: https://docs.unity.com/llms.txt , https://defold.com/llms.txt , https://developers.figma.com/llms.txt , https://threejs.org/llms.txt , https://phaser.io/llms.txt , https://doc.babylonjs.com/llms.txt , https://engine.needle.tools/docs/llms.txt
    - Returned 404: https://docs.godotengine.org/llms.txt , https://bevy.org/llms.txt , https://docs.blender.org/llms.txt
    - Returned 403: https://dev.epicgames.com/llms.txt
22. Godot contribution policy: https://godotengine.org/article/contribution-policy-2026/ (2026-06-30) ; The Register: https://www.theregister.com/ai-and-ml/2026/07/01/godot-says-bye-bye-ai-bans-vibe-coded-contributions/5265344 (2026-07-01)
23. R3F, Threlte and TresJS `llms.txt`: https://r3f.docs.pmnd.rs/llms.txt , https://threlte.xyz/llms.txt , https://docs.tresjs.org/llms.txt
24. Anthropic, Claude Code permissions: https://code.claude.com/docs/en/permissions
