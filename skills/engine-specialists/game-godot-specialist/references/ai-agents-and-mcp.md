# Working with AI Coding Agents in Godot

Reference for `game-godot-specialist`. MCP facts are from the project pages and GameForge's AI-tooling
research (checked Nov 2026). The build loop itself is `/gameforge:game-vibe-code`; this file covers
what is specific to Godot.

## 1. Ground the agent in the right engine version

- Godot has **no official MCP server** and its docs publish **no `llms.txt`** (it returned 404 when
  checked on 2026-11-05). Agents fall back on training data, which is dominated by Godot 3.
- State the version in `CLAUDE.md` ("Godot 4.7.2, GDScript, typed") and have the agent confirm it
  with `godot --version` at the start of a session.
- Look up APIs in the versioned class reference, e.g.
  `https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html` (class name lowercased).
  `/en/stable/` currently serves 4.7; `/en/latest/` tracks the development branch (4.8).
- Offline ground truth for the exact binary: `godot --headless --doctool /tmp/godot-api` dumps the full API
  reference as XML that the agent can search.

## 2. MCP options (Nov 2026)

| Option | Kind | What it gives the agent | Notes |
|---|---|---|---|
| **Coding-Solo/godot-mcp** | External server (Node 18+, npm `@coding-solo/godot-mcp`) | Launch the editor, run and stop the project, read debug output, get version and project info, create scenes, add nodes, load sprites, export a MeshLibrary, save scenes, UID tools (Godot 4.4+) | MIT, about 6.5k stars. Scene operations run through one bundled GDScript file. The main community option |
| **IvanMurzak/Godot-MCP** | In-editor C# addon | Editor operations as agent tools; also a runtime mode inside built games | Requires the .NET build of Godot (4.3+) and the .NET 8 SDK. Apache-2.0. Its default *Cloud* mode connects to a hosted backend; choose the local (*Custom*) server, which listens on `localhost:8080` |
| **Godot .NET MCP** (Asset Library) | In-editor plugin | Editor control from inside Godot | Targets 4.6. Evaluate before relying on it |
| **No MCP** | Files plus the headless CLI | The agent edits `.gd`, `.tscn`, `.tres` and runs the verification loop | Often enough: Godot's text formats are easy for agents to read and diff |

Claude Code setup for the most common option:

```bash
claude mcp add godot -- npx @coding-solo/godot-mcp
```

Or commit a project-scoped `.mcp.json` so the team shares one reviewed configuration:

```json
{
  "mcpServers": {
    "godot": {
      "command": "npx",
      "args": ["@coding-solo/godot-mcp"],
      "env": { "GODOT_PATH": "/opt/godot/godot" }
    }
  }
}
```

Pin the package to a version you have reviewed once the setup works.

Security rules:

- Keep every MCP server on **localhost**. Never expose one on a network interface.
- "Run the project" and "launch the editor" execute code: your scripts, every `@tool` script and
  every enabled editor plugin run with your user's permissions. Treat these tools as arbitrary code
  execution and review addons before enabling them.
- An agent-written `@tool` script runs as soon as the editor loads it. Review `@tool` diffs like
  build scripts.
- Never let an agent read or print `.godot/export_credentials.cfg`, keystores or `.env` files.

## 3. What agents get wrong in Godot 4

1. **Godot 3 APIs** (`yield`, `export var`, `onready var`, `KinematicBody`, `instance()`, `setget`,
   string `connect(..., self, ...)`). Full table in `gdscript-patterns.md` section 6. Search for them
   with the Grep tool after every agent session:
   `yield\(|^\s*(export|onready) var|KinematicBody|\.instance\(\)|setget|connect\("\w+",\s*self`
2. **Invented methods and properties.** Check anything unfamiliar against the class reference or the
   `--doctool` dump before accepting it.
3. **Untyped code** and `Variant` everywhere. Make untyped declarations an error (GDScript reference).
4. **Mixed tabs and spaces** in one file, which is a parse error. Godot's default is tabs.
5. **`class_name` equal to an autoload name**, which is a parse error.
6. **Autoloads for everything.** Push back on any new autoload without a stated reason.
7. **Hand-written `project.godot` input maps.** Input events serialize as long `Object(...)` lines.
   Add actions in the editor, or from a tool script with `ProjectSettings.set_setting()` followed by
   `ProjectSettings.save()`.
8. **Scenes built in code without `owner`.** Nodes without an `owner` are not saved into a
   `PackedScene` (section 5).
9. **Long relative node paths** (`get_node("../../UI/HUD")`) instead of exports, `%UniqueName` or signals.
10. **Mutating shared Resources** loaded from `.tres` at runtime.

## 4. Files the agent must not hand-edit

GameForge's PreToolUse hook enforces these in Godot projects:

| Path | Hook | Why | Do instead |
|---|---|---|---|
| `.godot/` | Blocked | Regenerated editor cache and import output | Change the source asset or project settings; run `--import` |
| `*.uid` | Blocked | Godot owns these sidecar IDs (scripts and shaders, 4.4+); editing breaks references | Commit them. Move a script with its `.uid`: in the FileSystem dock, or `git mv a.gd b.gd` plus `git mv a.gd.uid b.gd.uid` |
| `*.import` | Asks first | Per-asset import settings | Change them in the Import dock; edit by hand only when the user asked |

Godot's guidance on `.uid` files: commit them, never add `*.uid` to `.gitignore`, and move them along
with their source file when moving files outside the editor.

## 5. Editing `.tscn` and `.tres` as text

Anatomy of a small scene (the header gains a `uid=` attribute when the editor saves it):

```
[gd_scene format=3]

[ext_resource type="Script" path="res://enemies/slime.gd" id="1_slime"]
[ext_resource type="PackedScene" path="res://components/health_component.tscn" id="2_health"]

[sub_resource type="CircleShape2D" id="CircleShape2D_body"]
radius = 12.0

[node name="Slime" type="CharacterBody2D"]
collision_layer = 4
collision_mask = 1
script = ExtResource("1_slime")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D_body")

[node name="HealthComponent" parent="." instance=ExtResource("2_health")]
max_health = 30
```

Collision layers are stored as bitmasks: `collision_layer = 4` is layer 3.

| Usually safe by hand | Avoid by hand |
|---|---|
| Changing property values on existing nodes | Inventing `uid://` values. An invalid UID makes Godot warn and fall back to the path; a valid but wrong one silently loads a different resource. Omit `uid=` on new `ext_resource` lines |
| Adding a simple child node with a correct `parent=` path | Overrides inside inherited or instanced scenes and editable children |
| Adding an `ext_resource` by `path` with a new unique `id` | Large serialized data: `TileMapLayer` tile data, navigation meshes, animation tracks |
| Renaming a node consistently within one file | Duplicating node blocks wholesale. Since 4.6 scenes store a per-node unique ID; remove the copied ID so two nodes do not share one, then re-save in the editor |

After any text edit: run `--import` and a scene smoke test, then have a human open and re-save the
scene in the editor before committing, which normalizes formatting. Keep one editor version per
branch. Saving the same scenes from different versions churns diffs, and 4.8 changes object
serialization to shrink text-scene diffs. After upgrading to 4.6 or later, use Project > Tools >
Upgrade Project Files so the new per-node IDs are written.

**Prefer generating scenes with a tool script** when an agent needs a new scene. The engine writes
valid files:

```gdscript
# tools/make_pickup_scene.gd
# Run: godot --headless --path . --script res://tools/make_pickup_scene.gd
extends SceneTree

func _initialize() -> void:
	var root := Area2D.new()
	root.set_script(load("res://pickups/pickup.gd"))
	root.name = "Pickup"
	root.collision_layer = 1 << 5            # layer 6: pickups
	root.collision_mask = 0

	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	root.add_child(shape)
	shape.owner = root                        # without an owner the child is not saved

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, "res://pickups/pickup.tscn")
	print("make_pickup_scene: ", error_string(err))
	root.free()
	quit(0 if err == OK else 1)
```

Run `--import` first if the scripts it loads use `class_name` types that are new since the last import.

## 6. What to delegate

| Delegate freely | Delegate, then review closely | Keep human-owned |
|---|---|---|
| Typed boilerplate and component scripts from a written spec | Scene structure and physics layer changes | Game feel and tuning by playtest |
| Unit, data and scene smoke tests | Shaders and rendering settings | Art direction and final UI layout |
| Tool scripts that generate scenes or `.tres` data from a table | Save systems and save migration | Signing keys, store credentials, release uploads |
| Godot 3 to 4 syntax migration | Networking and anything with `@rpc` | What to cut when scope slips |
| CI scripts and export preset documentation | Performance fixes (require profiler evidence before and after) | Accepting generated assets (`/gameforge:game-ai-assets`) |

## 7. Prompt and review templates

```text
Context: Godot 4.7.2, typed GDScript. Read CLAUDE.md and docs/architecture.md first.
Task: add a dash as a new state (res://player/states/dash.gd) wired into the player's StateMachine.
Constraints: tunables live in res://data/player_stats.tres (dash_speed, dash_time, dash_cooldown);
no new autoloads; no edits under .godot/ or to .uid files; no Godot 3 APIs; tabs for indentation.
Done when: --check-only passes for every changed script, tests/unit/test_dash.gd passes under GUT,
the headless smoke run log has no SCRIPT ERROR lines, and you list exactly what I should playtest.
```

Review checklist for an agent's diff:

```markdown
- [ ] Typed GDScript only; the Godot 3 grep finds nothing
- [ ] No new autoload, or a one-line reason in the PR description
- [ ] Gameplay numbers in Resources or exports, not literals
- [ ] No hand edits to .godot/ or .uid; renamed scripts moved with their .uid
- [ ] .tscn diffs small and explainable; no invented uid:// values
- [ ] Verification loop output pasted (import, check-only, tests, smoke run)
- [ ] Human playtest notes recorded; production/session-state/active.md updated
```

## 8. Assets, disclosure and contributing upstream

- Generated art, audio and voice go through `/gameforge:game-ai-assets` and are logged in
  `design/ai-asset-log.md`. Steam's disclosure rules (rewritten 2026-01-16) cover shipped,
  player-facing content and marketing; code-assistant use is exempt.
- **The Godot Foundation's AI policy applies to the engine, not your game.** Since 2026-06-30 the
  Godot project rejects substantial AI-authored code contributions and bans agent or vibe-coded pull
  requests to the engine; minor assistance is allowed if disclosed. Games made with Godot are not
  affected. If you hit an engine bug, build the minimal reproduction project and write the issue
  yourself; if you send a fix upstream, write it yourself and disclose any minor AI help.
