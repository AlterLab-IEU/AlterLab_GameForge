# GameForge Hooks Reference

GameForge ships seven lifecycle hooks, wired in [`hooks/hooks.json`](../hooks/hooks.json) and loaded
automatically when the plugin is enabled. They are written for POSIX `sh` (no bash, no required `jq`)
and covered by [`tests/hooks.test.sh`](../tests/hooks.test.sh).

## Design rules

1. **Silent outside game projects.** Every hook first detects an engine (Godot, Unity, Unreal,
   Three.js / R3F, Babylon.js, PlayCanvas, Phaser, PixiJS, Kaplay (and legacy Kaboom), Excalibur, LittleJS, Bevy, GameMaker,
   Defold, LOVE) or a GameForge marker. In any other repository they exit immediately with no output.
2. **No files without opt-in.** Hooks that write state (`pre-compact`, `session-end`,
   `subagent-track`, `stop-failure`) only run once `production/session-state/` or `.gameforge/` exists,
   which `/gameforge:game-start` creates. GameForge never scatters folders into a repo uninvited.
3. **Documented I/O only.** Hooks read the JSON event from stdin, put context in front of Claude only
   through `SessionStart` stdout, and block tools only through the documented `PreToolUse`
   `permissionDecision` JSON, always with a reason Claude can act on.
4. **Cheap.** The Bash hook returns immediately for anything that is not `git commit`.

## The hooks

| Script | Event (matcher) | Runs in | What it does |
|---|---|---|---|
| `session-start.sh` | `SessionStart` (startup, resume, clear, compact, fork) | game projects | Prints a briefing that Claude receives as context: engine and version, routed specialist skill, phase, git branch / last commit / dirty files, the head of `production/session-state/active.md`, a recovery note after an API failure, and gaps with the skill that closes each. On `compact` it also restores the pre-compaction snapshot. |
| `pre-compact.sh` | `PreCompact` (manual, auto) | opted-in | Writes `production/session-state/compact-snapshot.md`: branch, last five commits, uncommitted files, active pipelines. |
| `validate-commit.sh` | `PreToolUse` (`Bash`) | game projects | On `git commit` only. **Large-binary guard:** denies commits that add files at or above the LFS threshold (default 20 MB) that Git LFS is not tracking. **Message convention** (opted-in projects): denies subjects that do not match the configured convention, explaining the expected format. |
| `protect-generated.sh` | `PreToolUse` (`Write\|Edit\|MultiEdit\|NotebookEdit`) | game projects | Denies edits to engine-generated or binary files; asks before editing files that are engine-managed but occasionally edited on purpose (table below). |
| `subagent-track.sh` | `SubagentStart`, `SubagentStop` | opted-in | Logs delegation to `production/session-logs/agents.log` with a per-session live count; shows the user a warning when more than six subagents run at once. |
| `stop-failure.sh` | `StopFailure` | opted-in | Writes `production/session-state/recovery.json` (valid, escaped JSON) so the next session offers to resume. |
| `session-end.sh` | `SessionEnd` | opted-in | Appends one line per session to `production/session-logs/sessions.log` (stays inside the 1.5 s SessionEnd budget). |

## Commit conventions

Configured by `commit_convention` in `.gameforge/project.json` or the `GAMEFORGE_COMMIT_CONVENTION`
environment variable.

| Value | Accepted subject |
|---|---|
| `conventional` (default) | `<type>(<optional scope>)!: <summary>` with type one of `feat`, `fix`, `refactor`, `perf`, `test`, `build`, `ci`, `docs`, `style`, `chore`, `revert`, plus game types `art`, `audio`, `design`, `level`, `balance`, `narrative`, `loc`, `ui` |
| `gameforge` | `feat:`, `improve:`, `fix:`, `docs:`, `chore:` (the convention this repository uses) |
| `off` | anything |

Subjects longer than 100 characters are rejected. `Merge ...`, `Revert ...`, `fixup!` and `squash!`
subjects, `--amend --no-edit`, and messages taken from a file (`-F`) are never blocked.

Examples that pass: `feat(player): add air dash`, `balance(combat): lower parry window from 12 to 9
frames`, `art: forest tileset pass 2`.

## Protected paths

| Engine | Denied | Ask first |
|---|---|---|
| Godot | `.godot/**`, `*.uid` | `*.import` |
| Unity | `Library/`, `Temp/`, `Obj/`, `Logs/`, `UserSettings/`, `Build(s)/`, `*.csproj`, `*.sln` | `*.meta` |
| Unreal | `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`, `.vs/`, `*.uasset`, `*.umap` | |
| Web engines | `node_modules/`, `dist/`, `build/`, `.vite/`, `.next/`, `.parcel-cache/` | |

## Configuration and opt-outs

| Setting | Effect |
|---|---|
| `GAMEFORGE_HOOKS=off` | Disables every GameForge hook |
| `GAMEFORGE_PROTECT=off` | Disables the generated-file guard |
| `GAMEFORGE_COMMIT_CONVENTION=off` or `"commit_convention": "off"` | Disables the commit-message check |
| `GAMEFORGE_ALLOW_LARGE_FILES=1` | Allows one commit with large non-LFS files |
| `"lfs_threshold_mb": 50` in `.gameforge/project.json` | Changes the large-file threshold |
| `GAMEFORGE_MAX_PARALLEL_AGENTS=8` | Changes the parallel-subagent warning threshold |
| `"phase": "production"` in `.gameforge/project.json` | Overrides the phase heuristic in the session briefing |

Environment variables can be set in your shell or in the `env` block of `.claude/settings.json`.

## Files the hooks read and write

```
.gameforge/project.json                      read   (engine, phase, conventions)
production/session-state/active.md           read   (your current focus; skills update it)
production/session-state/compact-snapshot.md write  (pre-compact) / read (session-start)
production/session-state/recovery.json       write  (stop-failure) / read + archive (session-start)
production/session-state/agents/<session>/   write  (subagent-track live markers)
production/session-logs/sessions.log         append (session-end, stop-failure)
production/session-logs/agents.log           append (subagent-track)
```

Add `production/session-state/` and `production/session-logs/` to your game's `.gitignore`;
`/gameforge:game-start` does this for you.

## Testing

```bash
bash tests/hooks.test.sh -v
```

The suite builds fixture projects for each engine and runs every hook twice: with `jq`/`python3`
available and with only the POSIX fallback parser, to prove the plugin works on minimal machines.
