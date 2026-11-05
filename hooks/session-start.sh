#!/bin/sh
# GameForge -- SessionStart (startup | resume | clear | compact | fork)
#
# Injects a short project briefing into Claude's context: engine + version, phase,
# git position, saved session state, recovery notes after an API failure, and
# coverage gaps with the skill that closes each one. On `compact` it also restores
# the snapshot written by pre-compact.sh.
#
# SessionStart stdout on exit 0 is added to Claude's context, so this hook prints
# plain text. It prints nothing at all outside game projects.

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input
gf_require_game_project

SOURCE=$(gf_json_get .source)
[ -n "$SOURCE" ] || SOURCE=startup

# --- Phase heuristic (overridable via .gameforge/project.json "phase") -----------
has_dir() { for _d in "$@"; do [ -d "$_d" ] && return 0; done; return 1; }
HAS_DESIGN=no; HAS_SRC=no; HAS_TESTS=no
has_dir design docs/design Documentation production/gdd && HAS_DESIGN=yes
has_dir src scripts Scripts Source Assets/Scripts lib game && HAS_SRC=yes
has_dir tests test Tests Assets/Tests && HAS_TESTS=yes
case "$GF_ENGINE" in godot|unity|unreal|bevy|gamemaker|defold|love) HAS_SRC=yes ;; esac
[ -f package.json ] && HAS_SRC=yes

PHASE=$(gf_config phase)
if [ -z "$PHASE" ]; then
  if [ "$HAS_SRC" = no ] && [ "$HAS_DESIGN" = no ]; then PHASE="concept (empty project)"
  elif [ "$HAS_SRC" = no ]; then PHASE="pre-production (design only)"
  elif [ "$HAS_DESIGN" = no ]; then PHASE="prototype (code, no design docs)"
  else PHASE="production"
  fi
fi

# --- Specialist routing -----------------------------------------------------------
case "$GF_ENGINE" in
  godot) SPECIALIST=game-godot-specialist ;;
  unity) SPECIALIST=game-unity-specialist ;;
  unreal) SPECIALIST=game-unreal-specialist ;;
  threejs|r3f|babylon|playcanvas) SPECIALIST=game-threejs-specialist ;;
  phaser|pixi|kaplay|excalibur) SPECIALIST=game-web2d-specialist ;;
  *) SPECIALIST="" ;;
esac

# --- Briefing ---------------------------------------------------------------------
if [ "$SOURCE" = compact ]; then
  echo "[GameForge] Context restored after compaction."
else
  echo "[GameForge] Project briefing ($SOURCE)."
fi
[ -n "$GF_ENGINE_LABEL" ] && echo "- Engine: $GF_ENGINE_LABEL${SPECIALIST:+ -> route engine questions to /gameforge:$SPECIALIST}"
echo "- Phase: $PHASE"

if gf_in_git; then
  BRANCH=$(gf_git rev-parse --abbrev-ref HEAD)
  LAST=$(gf_git log -1 --pretty='%h %s (%cr)')
  DIRTY=$(gf_git status --porcelain | wc -l | tr -d ' ')
  echo "- Git: ${BRANCH:-detached} | last: ${LAST:-no commits} | uncommitted files: $DIRTY"
fi

STATE=production/session-state
if [ -f "$STATE/active.md" ]; then
  echo "- Saved session state ($STATE/active.md):"
  head -n 12 "$STATE/active.md" | sed 's/^/    /'
fi

if [ "$SOURCE" = compact ] && [ -f "$STATE/compact-snapshot.md" ]; then
  echo "- Pre-compaction snapshot ($STATE/compact-snapshot.md):"
  head -n 25 "$STATE/compact-snapshot.md" | sed 's/^/    /'
fi

if [ -f "$STATE/recovery.json" ]; then
  ERR=$(gf_json_get .error "$(cat "$STATE/recovery.json")")
  WHEN=$(gf_json_get .timestamp "$(cat "$STATE/recovery.json")")
  echo "- The previous session ended on an API error (${ERR:-unknown} at ${WHEN:-unknown time}). Offer to resume from $STATE/ before starting new work."
  mv "$STATE/recovery.json" "$STATE/recovery.last.json" 2>/dev/null || true
fi

# --- Gaps -> the skill that closes them -------------------------------------------
GAPS=""
[ "$HAS_SRC" = no ] && [ "$HAS_DESIGN" = no ] && GAPS="$GAPS
    - Nothing here yet: /gameforge:game-start (or /gameforge:game-vibe-code for a fast playable)"
[ "$HAS_SRC" = yes ] && [ "$HAS_DESIGN" = no ] && GAPS="$GAPS
    - Code without design docs: /gameforge:game-reverse-document"
[ "$HAS_SRC" = yes ] && [ "$HAS_TESTS" = no ] && GAPS="$GAPS
    - No test directory: /gameforge:game-qa-lead can set up a test harness"
if [ -n "$GAPS" ]; then
  echo "- Gaps:$GAPS"
fi

exit 0
