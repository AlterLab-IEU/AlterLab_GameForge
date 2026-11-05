#!/bin/sh
# GameForge -- PreCompact (manual | auto)
#
# Writes a small, deterministic snapshot of where the work stands so that
# session-start.sh can re-inject it when the session resumes after compaction.
# Only runs in projects that opted in (production/session-state or .gameforge exists).

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input
gf_require_opt_in

TRIGGER=$(gf_json_get .trigger)
STATE=production/session-state
mkdir -p "$STATE" 2>/dev/null || exit 0
OUT="$STATE/compact-snapshot.md"

{
  echo "Snapshot taken $(gf_now) before ${TRIGGER:-unknown} compaction."
  [ -n "$GF_ENGINE_LABEL" ] && echo "Engine: $GF_ENGINE_LABEL"
  if gf_in_git; then
    echo "Branch: $(gf_git rev-parse --abbrev-ref HEAD)"
    echo "Recent commits:"
    gf_git log -5 --pretty='  %h %s'
    echo "Uncommitted changes:"
    gf_git status --porcelain | head -n 15 | sed 's/^/  /'
  fi
  for f in "$STATE"/pipeline-*.json; do
    [ -f "$f" ] || continue
    # Top-level status. Without jq/python3, take the first "status" line: the orchestrator
    # writes the pipeline status before its steps, and step statuses must not win.
    if command -v jq >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
      _status=$(gf_json_get .status "$(cat "$f")")
    else
      _status=$(sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$f" | head -n 1)
    fi
    case "$_status" in completed|abandoned) continue ;; esac
    echo "Active pipeline: $(basename "$f" .json) (${_status:-unknown status})"
  done
} > "$OUT" 2>/dev/null

exit 0
