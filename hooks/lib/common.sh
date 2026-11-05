# shellcheck shell=sh
# GameForge hook library -- POSIX sh, no bashisms, no hard dependency on jq.
#
# Every hook sources this file, reads its JSON event from stdin with gf_read_input,
# and calls gf_require_game_project (or gf_require_opt_in) before doing anything,
# so the plugin stays completely silent in repositories that are not game projects.
#
# Conventions
#   GF_INPUT        raw JSON event from Claude Code (stdin)
#   GF_ROOT         project root ($CLAUDE_PROJECT_DIR, else event cwd, else $PWD)
#   GF_ENGINE       detected engine id (godot, unity, unreal, threejs, r3f, babylon,
#                   playcanvas, phaser, pixi, kaplay, excalibur, bevy, gamemaker,
#                   defold, love, web, none)
#   GF_ENGINE_LABEL human-readable engine + version, e.g. "Godot 4.5"
#
# Opt-out: GAMEFORGE_HOOKS=off disables every GameForge hook.

gf_read_input() {
  GF_INPUT=$(cat 2>/dev/null || true)
  [ "${GAMEFORGE_HOOKS:-on}" = "off" ] && exit 0
  GF_ROOT=${CLAUDE_PROJECT_DIR:-}
  if [ -z "$GF_ROOT" ]; then
    GF_ROOT=$(gf_json_get .cwd)
  fi
  [ -n "$GF_ROOT" ] || GF_ROOT=$(pwd)
  cd "$GF_ROOT" 2>/dev/null || exit 0
}

# gf_json_get <dotted.path> [json]  -> prints the string value (or compact JSON) or nothing.
# Uses jq, then python3, then a sed fallback that handles flat string fields.
gf_json_get() {
  _gf_path=$1
  _gf_json=${2-$GF_INPUT}
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$_gf_json" | jq -r "$_gf_path // empty | if type == \"string\" then . else tojson end" 2>/dev/null
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$_gf_json" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for k in sys.argv[1].lstrip(".").split("."):
    d = d.get(k) if isinstance(d, dict) else None
if d is not None:
    sys.stdout.write(d if isinstance(d, str) else json.dumps(d))
' "$_gf_path" 2>/dev/null
    return 0
  fi
  # Fallback: flat lookup of the last "key": "string" pair, honouring escaped quotes,
  # then decode the JSON string escapes.
  _gf_key=${_gf_path##*.}
  printf '%s' "$_gf_json" | tr '\n' ' ' \
    | sed -E -n 's/.*"'"$_gf_key"'"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n 1 \
    | awk '{
        out = ""
        for (i = 1; i <= length($0); i++) {
          c = substr($0, i, 1)
          if (c != "\\") { out = out c; continue }
          i++; n = substr($0, i, 1)
          if (n == "n") out = out "\n"
          else if (n == "t") out = out "\t"
          else if (n == "r") continue
          else if (n == "u") { out = out "?"; i += 4 }
          else out = out n
        }
        printf "%s", out
      }'
}

# gf_json_escape <string> -> JSON-safe string body (no surrounding quotes).
gf_json_escape() {
  printf '%s' "$1" \
    | tr '\t\r' '  ' \
    | tr -d '\000-\010\013\014\016-\037' \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'BEGIN { ORS = "" } NR > 1 { print "\\n" } { print }'
}

gf_now() { date '+%Y-%m-%dT%H:%M:%S%z'; }

# Extract the version string of an npm dependency from package.json (best effort).
_gf_pkg_version() {
  # '|' delimiter: scoped package names such as @react-three/fiber contain '/'.
  sed -n 's|.*"'"$1"'"[[:space:]]*:[[:space:]]*"[~^>=<]*\([0-9][0-9A-Za-z.+-]*\)".*|\1|p' package.json 2>/dev/null | head -n 1
}

_gf_pkg_has() {
  grep -q "\"$1\"[[:space:]]*:" package.json 2>/dev/null
}

# gf_detect_engine -> sets GF_ENGINE and GF_ENGINE_LABEL.
gf_detect_engine() {
  GF_ENGINE=none
  GF_ENGINE_LABEL=""
  if [ -f project.godot ]; then
    GF_ENGINE=godot
    _v=$(sed -n 's/^config\/features=PackedStringArray("\([0-9][0-9.]*\)".*/\1/p' project.godot | head -n 1)
    GF_ENGINE_LABEL="Godot${_v:+ $_v}"
  elif [ -f ProjectSettings/ProjectVersion.txt ]; then
    GF_ENGINE=unity
    _v=$(sed -n 's/^m_EditorVersion:[[:space:]]*\([^[:space:]]*\).*/\1/p' ProjectSettings/ProjectVersion.txt | head -n 1)
    GF_ENGINE_LABEL="Unity${_v:+ $_v}"
  elif _gf_up=$(ls ./*.uproject 2>/dev/null | head -n 1) && [ -n "$_gf_up" ]; then
    GF_ENGINE=unreal
    _v=$(sed -n 's/.*"EngineAssociation"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$_gf_up" | head -n 1)
    GF_ENGINE_LABEL="Unreal Engine${_v:+ $_v}"
  elif [ -f package.json ]; then
    if _gf_pkg_has "@react-three/fiber"; then
      GF_ENGINE=r3f
      GF_ENGINE_LABEL="React Three Fiber $(_gf_pkg_version @react-three/fiber) / three $(_gf_pkg_version three)"
    elif _gf_pkg_has three; then
      GF_ENGINE=threejs; GF_ENGINE_LABEL="Three.js $(_gf_pkg_version three)"
    elif _gf_pkg_has "@babylonjs/core"; then
      GF_ENGINE=babylon; GF_ENGINE_LABEL="Babylon.js $(_gf_pkg_version @babylonjs/core)"
    elif _gf_pkg_has playcanvas; then
      GF_ENGINE=playcanvas; GF_ENGINE_LABEL="PlayCanvas $(_gf_pkg_version playcanvas)"
    elif _gf_pkg_has phaser; then
      GF_ENGINE=phaser; GF_ENGINE_LABEL="Phaser $(_gf_pkg_version phaser)"
    elif _gf_pkg_has "pixi.js"; then
      GF_ENGINE=pixi; GF_ENGINE_LABEL="PixiJS $(_gf_pkg_version pixi.js)"
    elif _gf_pkg_has kaplay; then
      GF_ENGINE=kaplay; GF_ENGINE_LABEL="Kaplay $(_gf_pkg_version kaplay)"
    elif _gf_pkg_has excalibur; then
      GF_ENGINE=excalibur; GF_ENGINE_LABEL="Excalibur $(_gf_pkg_version excalibur)"
    fi
  fi
  if [ "$GF_ENGINE" = none ]; then
    if [ -f Cargo.toml ] && grep -q '^bevy[[:space:]]*=' Cargo.toml 2>/dev/null; then
      GF_ENGINE=bevy; GF_ENGINE_LABEL="Bevy"
    elif ls ./*.yyp >/dev/null 2>&1; then
      GF_ENGINE=gamemaker; GF_ENGINE_LABEL="GameMaker"
    elif [ -f game.project ]; then
      GF_ENGINE=defold; GF_ENGINE_LABEL="Defold"
    elif [ -f main.lua ] && [ -f conf.lua ]; then
      GF_ENGINE=love; GF_ENGINE_LABEL="LOVE (Lua)"
    fi
  fi
  # Collapse whitespace left by empty version lookups.
  GF_ENGINE_LABEL=$(printf '%s' "$GF_ENGINE_LABEL" | sed -e 's/[[:space:]]\{2,\}/ /g' -e 's/[[:space:]]*$//' -e 's/ \/ three$//')
}

# A directory is "opted in" once GameForge state exists (created by /gameforge:game-start).
gf_opted_in() {
  [ -d .gameforge ] || [ -d production/session-state ]
}

# Exit silently unless this looks like a game project (engine detected or opted in).
gf_require_game_project() {
  gf_detect_engine
  if [ "$GF_ENGINE" = none ] && ! gf_opted_in; then
    exit 0
  fi
}

# Exit silently unless GameForge state directories exist. Used by hooks that write files,
# so the plugin never creates directories in a project that has not opted in.
gf_require_opt_in() {
  gf_opted_in || exit 0
  gf_detect_engine
}

# Read a flat string key from .gameforge/project.json.
gf_config() {
  [ -f .gameforge/project.json ] || return 0
  gf_json_get ".$1" "$(cat .gameforge/project.json 2>/dev/null)"
}

gf_git() { git "$@" 2>/dev/null; }

gf_in_git() { git rev-parse --git-dir >/dev/null 2>&1; }

# Emit a PreToolUse decision: gf_pretool_decision <allow|deny|ask> <reason>
gf_pretool_decision() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' \
    "$1" "$(gf_json_escape "$2")"
  exit 0
}
