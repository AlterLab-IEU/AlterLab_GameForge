# Agent Setup per Engine

How to connect Claude Code (or a similar coding agent) to the engine so it can inspect the project,
run it, and check its own work. Facts checked on 2026-11-05; integrations move fast, so re-check an
install command against its source before running it.

## Security rules (apply to every option)

1. **Localhost only.** An MCP server or editor bridge listens on `127.0.0.1`, never `0.0.0.0`, and
   is never port-forwarded or exposed through a tunnel.
2. **Code execution is code execution.** Servers that run engine scripts, Python or shell commands
   (Blender MCP, editor bridges, "execute script" tools) can do anything your user account can.
   Treat their tool calls like Bash: read what will run before approving.
3. **Review community servers** before installing: maintainer activity, open security issues,
   whether telemetry is on by default, and what the tool list can do. Pin a version.
4. **No secrets in agent context.** API keys go in environment variables or the OS keychain, never
   in `CLAUDE.md`, `.mcp.json` or committed settings. The GameForge settings starter denies reading
   `.env` and keystores.
5. **Show, then run.** Present the install command; run it only after the user approves. Project-scope
   MCP config (`.mcp.json`) is shared with everyone who clones the repo, so agree on it as a team.

## Unity

| Option | Install | Notes |
|---|---|---|
| **Unity's plugin for Claude Code** (official) | Inside Claude Code: `/plugin marketplace add Unity-Technologies/unity-agent-plugin`, then `/plugin install unity@unity-agent-plugin` | Ships skills that drive the editor through the **Unity CLI** (`unity status` checks the connection). Requires the Unity CLI and the pipeline package (`unity pipeline install`). The editor must be open for editor-controlling skills. |
| **Unity MCP server** (official) | `unity mcp configure` (Unity CLI) | Separate from the plugin. Part of Unity AI, in open beta since 2026-05-04. |
| **Unity AI in-editor agent** | Unity Hub / editor | Ask, Agent and Plan modes; uses Unity credits. The AI Gateway lets you bring an agent you already pay for. |
| **CoplayDev/unity-mcp** ("MCP for Unity", community, MIT) | UPM git URL `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity` or `openupm add com.coplaydev.unity-mcp` | About 50 tools: scenes, scripts, assets, tests, profiling, builds. Unity 2021.3 to 6.x; needs Python 3.10+ and `uv`. |
| **IvanMurzak/Unity-MCP** (community, Apache-2.0) | See its README | Can also run inside built games; has a CLI. |

Docs for agents: `https://docs.unity.com/llms.txt` (per-product files and `.md` versions of pages).

Check command for `CLAUDE.md` (edit-mode tests in batch mode; replace the editor path):

```bash
"<Unity editor path>" -batchmode -projectPath . -runTests -testPlatform EditMode -testResults results.xml
```

Unity 6.6 traps to put in `CLAUDE.md`: Fast Enter Play Mode is on by default, so static fields no
longer reset between play sessions; Cinemachine 2 is deprecated.

## Unreal Engine 5.8

| Option | Install | Notes |
|---|---|---|
| **Unreal MCP** (official, experimental) | Enable the *Unreal MCP* and *All Toolsets* plugins, restart the editor, run the console command `ModelContextProtocol.GenerateClientConfig` to write `.mcp.json` | Endpoint `127.0.0.1:8000/mcp`, HTTP + SSE (no stdio). **Loopback only, no authentication, editor-only.** Can run automation tests. Not a CI service. |
| **In-editor AI Assistant** (UE 5.7+, experimental) | Built in; press F1 on a UI element | Answers questions about the editor and can generate C++. |
| **chongdashu/unreal-mcp** (community, MIT) | See its README | Self-described experimental; UE 5.5+; Blueprints and actors. |

Docs for agents: Epic's docs did not return an `llms.txt` (HTTP 403 when checked), so status is
unknown. Point the agent at the specific documentation pages it needs instead.

Check command (adjust paths and test filter):

```bash
"<UE>/Engine/Binaries/<Platform>/UnrealEditor-Cmd" "$PWD/MyGame.uproject" -ExecCmds="Automation RunTests MyGame;Quit" -unattended -nopause -NullRHI -log
```

Forward-looking note for `CLAUDE.md`: UE 5.8 is the last planned UE5 major; UE6 (early access
targeted for late 2027) is built around Verse and Scene Graph. Keep gameplay logic modular so a
future port is a migration, not a rewrite.

## Godot 4.7

There is no official Godot MCP server and no official `llms.txt` (the docs site returned 404 when
checked). Godot's plain-text `.tscn`, `.tres` and `.gd` files are easy for agents to read and edit
directly, which covers most needs without a server.

| Option | Install | Notes |
|---|---|---|
| **Coding-Solo/godot-mcp** (community, MIT, the main option) | `claude mcp add godot -- npx @coding-solo/godot-mcp` | Launches and runs the project, reads debug output, makes basic scene edits. |
| **IvanMurzak/Godot-MCP** (community, C#) | Godot addon; see its README | In-editor plugin. |
| **Godot .NET MCP** (Asset Library) | Asset Library | Targets 4.6. |

The ecosystem is fragmented with many forks: choose one, pin it, and note it in `CLAUDE.md`.

Check command: run your test framework headless, for example GUT or gdUnit4 through
`godot --headless --path . <runner arguments>`. Put the exact line in `CLAUDE.md`.

Policy note: on 2026-06-30 the Godot Foundation stopped accepting substantial AI-authored code
contributions to the engine itself. Games made with Godot are unaffected; it matters only if the
team sends patches upstream.

Godot traps for `CLAUDE.md`: never edit `.godot/` or `*.uid` files (the GameForge guard blocks this);
C# projects cannot be exported to the web in 4.6/4.7; the 4.8 beta's .NET build needs .NET 10.

## Web: Three.js, React Three Fiber, Babylon.js, PlayCanvas

| Option | Install | Notes |
|---|---|---|
| **Playwright MCP** (browser control) | `claude mcp add playwright npx @playwright/mcp@latest` | Lets the agent open the game, press keys and take screenshots. The single most useful tool for a web game. |
| **Three.js docs for LLMs** | `https://threejs.org/llms.txt`, `https://threejs.org/docs/llms.txt`, `https://threejs.org/docs/llms-full.txt` | Official. Recommends an import map pinned to an exact version, never the old `three.min.js` CDN pattern. No official Three.js MCP server exists; all found are community projects. |
| **R3F, Threlte, TresJS** | `https://r3f.docs.pmnd.rs/llms.txt`, `https://threlte.xyz/llms.txt`, `https://docs.tresjs.org/llms.txt` | |
| **Babylon.js** | `https://doc.babylonjs.com/llms.txt` | |
| **PlayCanvas** | Editor MCP: `npx -y @playcanvas/editor-mcp-server`; agent skills: `npx skills add playcanvas/skills`; docs: `https://developer.playcanvas.com/llms.txt` | |
| **koota** (pmndrs ECS) | `npx skills add pmndrs/koota` | Ships an agent skill. |

## Web 2D: Phaser, PixiJS, Kaplay, Excalibur

| Option | Install | Notes |
|---|---|---|
| **Playwright MCP** | as above | |
| **Phaser docs for LLMs** | `https://phaser.io/llms.txt` | It tells agents to start with **Phaser AE**, Phaser's separate agent-oriented engine (PolyForm Shield licence, credits and Pro tiers). Treat that as a vendor steer: Phaser 4 is the MIT open-source framework. Tell the agent which one the project uses. |

## Allowing documentation fetches

So the agent can read `llms.txt` without a prompt every time, add domain rules to
`.claude/settings.json`:

```json
{ "permissions": { "allow": ["WebFetch(domain:threejs.org)", "WebFetch(domain:docs.unity.com)"] } }
```

## Blender and other content tools (any engine)

| Tool | Option | Notes |
|---|---|---|
| Blender | **ahujasid/mcp-for-blender** (community, MIT; formerly blender-mcp): `uvx mcp-for-blender` plus its add-on | **Runs arbitrary Python over an unauthenticated socket.** Telemetry is on by default; it has an optional safe mode. Connects to Poly Haven, Sketchfab and several 3D generators. |
| Aseprite | willibrandon/pixel-mcp (Go); giangdvdotdev/aseprite-mcp (`uvx aseprite-mcp`) | Single maintainers. |
| Figma (UI) | Official remote MCP at `https://mcp.figma.com/mcp` | Writing to the canvas is beta and only on the remote server. |
| Cascadeur | 2026.2 ships a simple MCP server | New. |

For AI asset generation and its provenance log, use `/gameforge:game-ai-assets`. For the wider MCP
catalog see `${CLAUDE_PLUGIN_ROOT}/docs/mcp-integrations.md`.

## The `CLAUDE.md` lines that matter most

Whatever the engine, the merged `CLAUDE.md` should open with something like:

```markdown
## Run and check
- Run: `npm run dev` (http://localhost:5173)
- Check (must pass before any commit): `npm run build && npx playwright test`
- Engine: three@0.187.0 (WebGLRenderer). Docs: https://threejs.org/docs/llms.txt
- Never edit: dist/, node_modules/ (generated)
- State: read production/session-state/active.md first; update it when you stop.
```

## Sources

Unity plugin page (docs.unity.com/en-us/ai/unity-plugin/claude-code, read 2026-11-05); Unity AI open
beta (Unity, 2026-05-04); Epic, "Unreal MCP in Unreal Editor" (UE 5.8 docs); Coding-Solo/godot-mcp,
CoplayDev/unity-mcp, chongdashu/unreal-mcp and ahujasid/mcp-for-blender READMEs on GitHub;
microsoft/playwright-mcp README; `llms.txt` availability checked directly on 2026-11-05; Godot
contribution policy (Godot blog, 2026-06-30; PC Gamer and The Register, 2026-07-01).
