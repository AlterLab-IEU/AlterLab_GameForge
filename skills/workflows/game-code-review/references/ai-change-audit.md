# AI-Change Audit: Patterns and Recipes

Read this before Step 2 of the review. Each check lists what to look for, how to find it with
Glob/Grep/git, and what a good fix looks like. The grep patterns are starting points: confirm every
hit by reading the surrounding code before reporting it.

## Spotting agent-authored changes

| Signal | How to see it |
|---|---|
| Commit trailers | `git log --format='%h %an%n%b' <range>` and look for `Co-Authored-By:` lines naming an AI tool |
| Agent branches | Branch names such as `claude/...`, `agent/...`, `copilot/...` |
| Session artifacts | `progress.md`, `SPEC.md`, `production/session-state/active.md`, an AI-use log |
| Style tells | Very long single commits, uniform comment style ("// Initialize the..."), defensive null checks everywhere, unused helper functions |
| MCP edits | Scene, prefab or settings files changed with no matching script change; editor-generated noise in `.tscn`/`.unity` diffs |

Treat the signals as a reason to apply the full audit, not as a finding. Never report "this was
written by AI" as a defect.

## A1. Outdated APIs

Agents learn from years of tutorials, so they default to the most-documented version, which is
rarely the one you run. Compare every engine or library call against the version pinned in the
project (see the engine checklists for the current lists).

Recipe:
1. Read the pinned version (Step 0).
2. Grep the diff for the "stop using" names in the engine checklist for that engine.
3. For each hit, confirm whether the pinned version still accepts it (deprecated but working is
   MAJOR; removed or no-op is CRITICAL).

## A2. Hallucinated APIs

Plausible names that never existed: `Input.get_action_vector()` (the real one is
`Input.get_vector()`), extra parameters on real methods, enum members borrowed from another engine.

Recipe, by stack:
- **Web:** for each imported symbol, Grep `node_modules/<pkg>/**/*.d.ts` (or the package's `src/`)
  for the exported name. Check the installed version in `node_modules/<pkg>/package.json`, not
  `package.json` ranges.
- **Unity:** Grep `Library/PackageCache/<package>@*/` for package APIs. For engine APIs
  (`UnityEngine.*`) you cannot confirm locally: mark Verify and name the Scripting API page to check
  for the pinned version.
- **Godot:** no local API dump in a normal project. Check method names against the class reference
  for the pinned 4.x version; mark Verify if unsure. GDScript's static checker catches many of these:
  recommend `godot --headless --check-only --script <file>` in "Verify by hand".
- **Unreal:** Grep the project's `Source/` and enabled plugins for the symbol; engine symbols need
  the engine source or docs, so mark Verify and name the header to check.

Severity is CRITICAL when the hallucinated call sits on a live path (it will fail to compile, throw,
or silently return a default), MAJOR when it is behind an unused branch.

## A3. Invented or wrong packages

Agents sometimes name packages that do not exist, and attackers register likely hallucinated names
("slopsquatting"). Also common: deprecated packages (`kaboom` instead of `kaplay`, `colyseus.js`
instead of `@colyseus/sdk`, `cannon-es` for new physics work) and unpinned git dependencies.

Where to look:
- `package.json` / lockfile: new entries in `dependencies`; packages with very few files in
  `node_modules`; `postinstall` scripts in new packages (`node_modules/<pkg>/package.json`).
- `Packages/manifest.json` (Unity): new registries, git URLs without a tag or commit hash.
- `addons/` (Godot): new plugins without a `plugin.cfg` source or license file.
- `*.Build.cs` / `.uplugin` (Unreal): new module dependencies and marketplace plugins.

Report each new dependency with: name, version, publisher if visible, why it was added (from the
commit message), and whether an existing dependency already covers it.

## A4. Duplicated systems

The single most expensive agent habit: a fresh session does not know the project already has an
`AudioManager`, so it writes `SoundService`. Two of anything that should be one is a bug factory.

Recipe:
1. List new files and new classes/autoloads/singletons in the diff.
2. For each, Grep the rest of the project for its responsibility words: `save`, `load`, `audio`,
   `sound`, `input`, `event`, `bus`, `signal`, `store`, `state`, `pool`, `spawn`, `config`,
   `settings`, `localization`, `analytics`.
3. Check engine-level registration: Godot `[autoload]` in `project.godot`; Unity
   `[RuntimeInitializeOnLoadMethod]`, `DontDestroyOnLoad`, static `Instance`; Unreal subsystems
   (`UGameInstanceSubsystem`, `UWorldSubsystem`); web stores (`create(` from zustand, `createWorld`).
4. If two systems own the same data, report which one the rest of the code actually uses.

## A5. Dead and orphaned code

- Functions and classes defined in the diff but never referenced: Grep each new symbol name across
  the project; one hit (its definition) means dead.
- Files nothing imports, preloads, or places in a scene.
- Commented-out blocks longer than five lines.
- Debug code that ships: FPS overlays, god-mode keys, `console.log` in loops, `print()` in
  `_process`, `Debug.Log` in `Update`, `UE_LOG` with `Warning` spam per tick, `?debug=1` paths in web
  builds, `window.game = game` exposures.

Severity rises to MAJOR when the dead path is a cheat or debug entry point reachable in release.

## A6. Client-trusted state

The defining failure of vibe-coded multiplayer: game logic lives in page globals, the server echoes
whatever the client sends. Validate state, scores and purchases on the server; keep keys off the
client.

Grep starting points:
- Web: `window\.` assignments of game objects; `fetch\(.*score`, `submitScore`, `leaderboard`;
  WebSocket `send(JSON.stringify({ ... score|hp|coins|damage ...`; `localStorage` holding currency or
  unlocks that a server later trusts.
- Godot: `@rpc("any_peer"` functions that change authoritative state without checking
  `multiplayer.get_remote_sender_id()`; `call_local` on damage or scoring.
- Unity: Netcode for GameObjects `[ServerRpc]`/`[Rpc(SendTo.Server)]` that apply client-provided
  values directly; `NetworkVariable` with owner write permission for gameplay-critical values.
- Unreal: `Server` RPCs without `WithValidation` or without server-side recomputation; replicated
  properties set on clients.
- Purchases and entitlements: any unlock granted from a client callback without a server-side
  receipt or entitlement check (Steam, mobile stores, Discord SKUs).

Fix pattern: the client sends inputs or intents; the server simulates or validates and owns the
result. Route deep netcode work to `game-multiplayer`.

## A7. Secrets in shipped code

Anything in a web bundle is public. Anything in an exported game can be extracted.

| Look for | Where |
|---|---|
| `sk-`, `sk-ant-`, `AKIA`, `AIza`, `ghp_`, `xoxb-`, `-----BEGIN` private keys | all source, `public/`, `assets/`, config |
| `VITE_` variables holding secrets | `.env*`, `vite.config.*`, `import.meta.env.VITE_` uses. Vite exposes every `VITE_`-prefixed variable to client code by design |
| LLM or TTS calls from the client | `fetch("https://api.` to model providers from browser code; AI NPC features that embed a key |
| Store and platform credentials | `config.vdf`, `butler_creds`, keystores, `.p12`, `GoogleService-Info.plist` with secrets added by hand |
| Engine export settings | Godot `export_presets.cfg` (should hold no passwords; Godot reads Android keystore credentials from `GODOT_ANDROID_KEYSTORE_RELEASE_*` env vars in CI), Unity `ProjectSettings/` keystore passwords |
| Committed `.env` files | `git ls-files` equivalents: Glob for `.env`, `.env.local`, `*.pem` |

Every hit is CRITICAL until shown to be a public identifier (for example a Firebase web config or a
publishable analytics key, which are meant to be public but should be restricted by domain).
Recommended fix: move the call behind a server or edge function, rotate the exposed key, and add a
secret scan to CI.

## A8. Engine-generated files

GameForge's hooks block agents from editing these by hand, but MCP tools and editors still change
them. Check the diff for:

| Engine | Should be committed | Should never be committed or hand-edited |
|---|---|---|
| Godot 4.4+ | `*.uid` files next to their scripts/resources (moved together on renames) | `.godot/` (import cache, editor state) |
| Unity | `.meta` for every asset, stable GUIDs | `Library/`, `Temp/`, `Logs/`, `UserSettings/`; mass `.meta` regeneration (GUID churn breaks references) |
| Unreal | `.uasset`/`.umap` via LFS | `Intermediate/`, `Saved/`, `Binaries/` (unless you ship prebuilt plugins), `DerivedDataCache/` |
| Web | lockfile | `dist/`, `node_modules/` |

A missing `.uid` or `.meta` next to a new file is MAJOR: references break on the next machine.

## A9. Silent failure

- Empty or log-only `catch`/`except` around gameplay or save code.
- `if node == null: return` guards that hide a broken scene path instead of failing loudly in debug.
- `try { JSON.parse(save) } catch {}` that resets player progress on a parse error.
- Promises without `await` or `.catch` in load paths.

Fix: fail loudly in debug builds (asserts), degrade gracefully with a visible error in release, and
never overwrite save data after a failed read.

## A10. Test theater

- New tests with no assertions, or assertions on mocks only.
- Tests changed in the same commit as the code they cover, with expectations loosened.
- Snapshot tests regenerated wholesale.
- Skipped tests (`skip`, `xit`, `[Ignore]`, `pending()`) added by the change.

Report as MAJOR and name the behavior that is now untested.

## A11 and A12. Scope creep, originality, licensing

- Diffs that reformat untouched files, rename public APIs, or flip project settings (physics tick,
  renderer, color space, input backend) without being asked.
- Assets or code that appear copied from a specific existing game (names, level layouts, ripped
  sprites), decompiled sources, or verbatim GPL/AGPL code in a proprietary project. Claude Code
  itself declines to recreate specific existing games; steer toward original designs and the team's
  own assets, and escalate rights questions to `game-producer`.
- AI-generated assets without an entry in the project's asset provenance log; route to
  `game-ai-assets`.
