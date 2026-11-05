#!/usr/bin/env bash
# GameForge hook test suite.
# Runs every hook under POSIX sh against fixture projects and checks its output.
# Each case runs twice: once with jq/python3 available, once with the sed-only fallback.
#
# Usage: bash tests/hooks.test.sh [-v]

set -u
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOKS="$REPO/hooks"
VERBOSE=${1:-}
PASS=0; FAIL=0
WORK=$(mktemp -d "${TMPDIR:-/tmp}/gameforge-hooks.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

# A PATH without jq or python3, to exercise the sed fallback in lib/common.sh.
FALLBACK_BIN="$WORK/fallback-bin"
mkdir -p "$FALLBACK_BIN"
for tool in sh dash bash cat sed awk grep tr head tail wc date ls mkdir mv rm find dirname basename git printf env sort cut uniq touch; do
  p=$(command -v "$tool" 2>/dev/null) && ln -sf "$p" "$FALLBACK_BIN/$tool"
done

ok()   { PASS=$((PASS + 1)); [ -n "$VERBOSE" ] && echo "  ok   $1"; return 0; }
bad()  { FAIL=$((FAIL + 1)); echo "  FAIL $1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; return 0; }

# run_hook <mode> <hook> <dir> <json>  -> stdout of the hook
run_hook() {
  local mode=$1 hook=$2 dir=$3 json=$4
  if [ "$mode" = fallback ]; then
    (cd "$dir" && printf '%s' "$json" | env -i HOME="$HOME" PATH="$FALLBACK_BIN" CLAUDE_PLUGIN_ROOT="$REPO" CLAUDE_PROJECT_DIR="$dir" ${EXTRA_ENV:-} sh "$HOOKS/$hook" 2>&1)
  else
    (cd "$dir" && printf '%s' "$json" | env CLAUDE_PLUGIN_ROOT="$REPO" CLAUDE_PROJECT_DIR="$dir" ${EXTRA_ENV:-} sh "$HOOKS/$hook" 2>&1)
  fi
}

expect_empty()    { [ -z "$2" ] && ok "$1" || bad "$1" "expected no output, got: $(printf '%s' "$2" | head -c 300)"; }
expect_contains() { case "$2" in *"$3"*) ok "$1" ;; *) bad "$1" "expected to contain [$3], got: $(printf '%s' "$2" | head -c 400)" ;; esac; }
expect_json()     { printf '%s' "$2" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null && ok "$1" || bad "$1" "invalid JSON: $(printf '%s' "$2" | head -c 300)"; }
expect_decision() {
  local got
  got=$(printf '%s' "$2" | python3 -c 'import json,sys; print(json.load(sys.stdin)["hookSpecificOutput"]["permissionDecision"])' 2>/dev/null)
  [ "$got" = "$3" ] && ok "$1" || bad "$1" "expected decision $3, got [${got:-none}] from: $(printf '%s' "$2" | head -c 300)"
}

new_dir() { local d="$WORK/$1-$RANDOM$RANDOM"; mkdir -p "$d"; printf '%s' "$d"; }
git_init() { git -C "$1" init -q && git -C "$1" config user.email t@t && git -C "$1" config user.name t && git -C "$1" commit -q --allow-empty -m "chore: init"; }

fixture() {
  local kind=$1 d
  d=$(new_dir "$kind")
  case "$kind" in
    empty) ;;
    godot) printf 'config_version=5\n[application]\nconfig/features=PackedStringArray("4.5", "Forward Plus")\n' > "$d/project.godot" ;;
    unity) mkdir -p "$d/ProjectSettings" "$d/Assets/Scripts"; printf 'm_EditorVersion: 6000.2.6f1\nm_EditorVersionWithRevision: x\n' > "$d/ProjectSettings/ProjectVersion.txt" ;;
    unreal) printf '{\n  "FileVersion": 3,\n  "EngineAssociation": "5.6",\n  "Modules": []\n}\n' > "$d/Shooter.uproject" ;;
    threejs) printf '{\n  "dependencies": {\n    "three": "^0.181.0"\n  }\n}\n' > "$d/package.json" ;;
    r3f) printf '{\n  "dependencies": {\n    "@react-three/fiber": "^9.4.0",\n    "three": "^0.181.0"\n  }\n}\n' > "$d/package.json" ;;
    phaser) printf '{ "dependencies": { "phaser": "^4.0.0" } }\n' > "$d/package.json" ;;
    littlejs) printf '{ "dependencies": { "littlejsengine": "^1.29.1" } }\n' > "$d/package.json" ;;
    kaboom) printf '{ "dependencies": { "kaboom": "^3000.1.17" } }\n' > "$d/package.json" ;;
    plainweb) printf '{ "dependencies": { "react": "^19.0.0" } }\n' > "$d/package.json" ;;
  esac
  printf '%s' "$d"
}

for MODE in full fallback; do
  echo "[$MODE parser]"
  EXTRA_ENV=""

  # --- session-start -------------------------------------------------------------
  d=$(fixture empty);    expect_empty    "session-start: silent in empty non-game dir" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')"
  d=$(fixture plainweb); expect_empty    "session-start: silent in non-game web app" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')"
  d=$(fixture godot);    out=$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')
  expect_contains "session-start: detects Godot version" "$out" "Engine: Godot 4.5"
  expect_contains "session-start: routes Godot specialist" "$out" "/gameforge:game-godot-specialist"
  d=$(fixture unity);    expect_contains "session-start: detects Unity version" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "Unity 6000.2.6f1"
  d=$(fixture unreal);   expect_contains "session-start: detects Unreal version" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "Unreal Engine 5.6"
  d=$(fixture threejs);  out=$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')
  expect_contains "session-start: detects Three.js version" "$out" "Three.js 0.181.0"
  expect_contains "session-start: routes Three.js specialist" "$out" "game-threejs-specialist"
  d=$(fixture r3f);      expect_contains "session-start: detects R3F" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "React Three Fiber 9.4.0 / three 0.181.0"
  d=$(fixture phaser);   expect_contains "session-start: routes 2D web specialist" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "game-web2d-specialist"
  d=$(fixture littlejs); expect_contains "session-start: detects LittleJS" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "LittleJS 1.29.1 -> route engine questions to /gameforge:game-web2d-specialist"
  d=$(fixture kaboom);   expect_contains "session-start: flags legacy Kaboom" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')" "Kaplay is the maintained successor"

  d=$(fixture godot); mkdir -p "$d/production/session-state"
  printf 'Snapshot taken earlier.\nBranch: feature/dash\n' > "$d/production/session-state/compact-snapshot.md"
  printf 'Working on: dash ability\n' > "$d/production/session-state/active.md"
  out=$(run_hook $MODE session-start.sh "$d" '{"source":"compact"}')
  expect_contains "session-start(compact): announces restore" "$out" "Context restored after compaction"
  expect_contains "session-start(compact): injects snapshot" "$out" "Branch: feature/dash"
  expect_contains "session-start: injects active.md" "$out" "Working on: dash ability"
  printf '{"timestamp":"t0","error":"rate_limit"}\n' > "$d/production/session-state/recovery.json"
  out=$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')
  expect_contains "session-start: reports recovery note" "$out" "rate_limit"
  [ -f "$d/production/session-state/recovery.last.json" ] && ok "session-start: archives recovery note" || bad "session-start: archives recovery note"
  d=$(fixture godot); EXTRA_ENV="GAMEFORGE_HOOKS=off"
  expect_empty "session-start: GAMEFORGE_HOOKS=off disables" "$(run_hook $MODE session-start.sh "$d" '{"source":"startup"}')"
  EXTRA_ENV=""

  # --- validate-commit -------------------------------------------------------------
  d=$(fixture godot); git_init "$d"; mkdir -p "$d/.gameforge"
  bash_ev() { python3 -c 'import json,sys; print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1"; }
  expect_empty    "validate-commit: ignores non-commit commands" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'ls -la')")"
  out=$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git commit -m "added stuff"')")
  expect_json     "validate-commit: deny output is valid JSON" "$out"
  expect_decision "validate-commit: denies non-conventional subject" "$out" deny
  expect_empty    "validate-commit: allows conventional subject" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git commit -m "feat(player): add air dash"')")"
  expect_empty    "validate-commit: allows game type" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git add -A && git commit -m "balance(combat): lower parry window"')")"
  expect_empty    "validate-commit: ignores git -C global option" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git -C . commit -m "fix: clamp fall speed"')")"
  expect_empty    "validate-commit: skips --amend --no-edit" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git commit --amend --no-edit')")"
  heredoc_bad=$'git commit -m "$(cat <<\'EOF\'\nUpdated the player\n\nLonger body here.\nEOF\n)"'
  heredoc_ok=$'git commit -m "$(cat <<\'EOF\'\nrefactor(input): move bindings to InputMap\n\nBody.\nEOF\n)"'
  expect_decision "validate-commit: denies bad heredoc subject" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev "$heredoc_bad")")" deny
  expect_empty    "validate-commit: allows good heredoc subject" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev "$heredoc_ok")")"
  EXTRA_ENV="GAMEFORGE_COMMIT_CONVENTION=gameforge"
  expect_empty    "validate-commit: gameforge convention accepts improve:" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git commit -m "improve: sharpen dash feel"')")"
  expect_decision "validate-commit: gameforge convention rejects refactor:" "$(run_hook $MODE validate-commit.sh "$d" "$(bash_ev 'git commit -m "refactor: x"')")" deny
  EXTRA_ENV=""
  d2=$(fixture godot); git_init "$d2"
  expect_empty    "validate-commit: no message policy without opt-in" "$(run_hook $MODE validate-commit.sh "$d2" "$(bash_ev 'git commit -m "whatever"')")"
  head -c $((21 * 1024 * 1024)) /dev/zero > "$d2/cinematic.bin"; git -C "$d2" add cinematic.bin
  expect_decision "validate-commit: blocks large non-LFS file" "$(run_hook $MODE validate-commit.sh "$d2" "$(bash_ev 'git commit -m "feat: add cinematic"')")" deny
  printf '*.bin filter=lfs diff=lfs merge=lfs -text\n' > "$d2/.gitattributes"
  expect_empty    "validate-commit: allows large LFS-tracked file" "$(run_hook $MODE validate-commit.sh "$d2" "$(bash_ev 'git commit -m "feat: add cinematic"')")"
  d3=$(fixture plainweb); git_init "$d3"
  expect_empty    "validate-commit: silent in non-game repo" "$(run_hook $MODE validate-commit.sh "$d3" "$(bash_ev 'git commit -m "whatever"')")"

  # --- protect-generated -------------------------------------------------------------
  file_ev() { python3 -c 'import json,sys; print(json.dumps({"tool_name":"Edit","tool_input":{"file_path":sys.argv[1],"old_string":"a","new_string":"b"}}))' "$1"; }
  d=$(fixture godot)
  expect_decision "protect-generated: denies .godot/ cache" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/.godot/editor/state.cfg")")" deny
  expect_decision "protect-generated: denies Godot .uid" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/player.gd.uid")")" deny
  expect_empty    "protect-generated: allows GDScript" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/player.gd")")"
  d=$(fixture unity)
  expect_decision "protect-generated: denies Unity Library/" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/Library/ScriptAssemblies/x.json")")" deny
  expect_decision "protect-generated: asks before .meta edits" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/Assets/Scripts/Player.cs.meta")")" ask
  expect_empty    "protect-generated: allows C# scripts" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/Assets/Scripts/Player.cs")")"
  d=$(fixture unreal)
  expect_decision "protect-generated: denies .uasset" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/Content/Hero.uasset")")" deny
  d=$(fixture threejs)
  expect_decision "protect-generated: denies web build output" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/dist/index.js")")" deny
  d=$(fixture empty)
  expect_empty    "protect-generated: silent outside game projects" "$(run_hook $MODE protect-generated.sh "$d" "$(file_ev "$d/Library/x.txt")")"

  # --- subagent-track ----------------------------------------------------------------
  d=$(fixture godot); mkdir -p "$d/production/session-state"
  sa_ev() { printf '{"hook_event_name":"%s","session_id":"s1","agent_id":"%s","agent_type":"gameforge:game-designer"}' "$1" "$2"; }
  out=""
  for i in 1 2 3 4 5 6 7; do out=$(run_hook $MODE subagent-track.sh "$d" "$(sa_ev SubagentStart "a$i")"); done
  expect_contains "subagent-track: warns above parallel limit" "$out" "7 subagents are running"
  expect_json     "subagent-track: warning is valid JSON" "$out"
  expect_empty    "subagent-track: stop is silent" "$(run_hook $MODE subagent-track.sh "$d" "$(sa_ev SubagentStop a7)")"
  expect_empty    "subagent-track: back under limit after stop" "$(run_hook $MODE subagent-track.sh "$d" "$(sa_ev SubagentStart a8)" | grep -v '^$' | grep -v 'running' || true)"
  grep -q 'START session=s1 agent=a1 type=gameforge:game-designer live=1' "$d/production/session-logs/agents.log" && ok "subagent-track: logs per-session live count" || bad "subagent-track: logs per-session live count"
  d=$(fixture godot); run_hook $MODE subagent-track.sh "$d" "$(sa_ev SubagentStart x)" >/dev/null
  [ ! -e "$d/production" ] && ok "subagent-track: writes nothing without opt-in" || bad "subagent-track: writes nothing without opt-in"

  # --- stop-failure / pre-compact / session-end ---------------------------------------
  d=$(fixture godot); git_init "$d"; mkdir -p "$d/production/session-state"
  git -C "$d" commit -q --allow-empty -m 'fix: handle "quoted" \ backslash'
  run_hook $MODE stop-failure.sh "$d" '{"session_id":"s9","error_type":"rate_limit"}' >/dev/null
  expect_json     "stop-failure: recovery.json is valid JSON with tricky commit" "$(cat "$d/production/session-state/recovery.json" 2>/dev/null)"
  expect_contains "stop-failure: records error type" "$(cat "$d/production/session-state/recovery.json" 2>/dev/null)" '"error": "rate_limit"'
  printf '{\n  "pipeline": "sprint",\n  "status": "in_progress",\n  "steps": [\n    { "skill": "game-sprint-plan", "status": "completed" }\n  ]\n}\n' > "$d/production/session-state/pipeline-sprint.json"
  printf '{\n  "pipeline": "release",\n  "status": "completed"\n}\n' > "$d/production/session-state/pipeline-release.json"
  run_hook $MODE pre-compact.sh "$d" '{"trigger":"auto"}' >/dev/null
  snap=$(cat "$d/production/session-state/compact-snapshot.md" 2>/dev/null)
  expect_contains "pre-compact: writes snapshot" "$snap" "before auto compaction"
  expect_contains "pre-compact: lists active pipeline" "$snap" "Active pipeline: pipeline-sprint (in_progress)"
  case "$snap" in *pipeline-release*) bad "pre-compact: skips completed pipeline" ;; *) ok "pre-compact: skips completed pipeline" ;; esac
  run_hook $MODE session-end.sh "$d" '{"session_id":"s9","reason":"logout"}' >/dev/null
  expect_contains "session-end: logs reason" "$(cat "$d/production/session-logs/sessions.log" 2>/dev/null)" "reason=logout"
  d=$(fixture empty)
  run_hook $MODE pre-compact.sh "$d" '{"trigger":"auto"}' >/dev/null; run_hook $MODE session-end.sh "$d" '{}' >/dev/null; run_hook $MODE stop-failure.sh "$d" '{}' >/dev/null
  [ -z "$(ls -A "$d")" ] && ok "state hooks: create nothing in non-opted-in dir" || bad "state hooks: create nothing in non-opted-in dir" "$(ls -A "$d")"
done

# --- hooks.json wiring -------------------------------------------------------------
python3 - "$REPO" <<'PY' && ok "hooks.json: valid and every command points at an existing script" || bad "hooks.json wiring"
import json, os, re, sys
repo = sys.argv[1]
cfg = json.load(open(os.path.join(repo, "hooks", "hooks.json")))
for event, groups in cfg["hooks"].items():
    for g in groups:
        for h in g["hooks"]:
            m = re.search(r'\$\{CLAUDE_PLUGIN_ROOT\}/(hooks/[\w.-]+\.sh)', h["command"])
            assert m and os.path.isfile(os.path.join(repo, m.group(1))), (event, h)
PY

# --- No bashisms: every hook must run under dash -------------------------------------
if command -v dash >/dev/null 2>&1; then
  for f in "$HOOKS"/*.sh "$HOOKS"/lib/*.sh; do
    dash -n "$f" 2>/dev/null && ok "posix: $(basename "$f") parses under dash" || bad "posix: $(basename "$f") parses under dash"
  done
fi

echo
echo "hooks: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
