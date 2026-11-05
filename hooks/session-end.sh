#!/bin/sh
# GameForge -- SessionEnd
#
# Appends one line per session to production/session-logs/sessions.log.
# SessionEnd hooks share a 1.5 s budget, so this does no expensive work.
# Only runs in projects that opted in.

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input
gf_opted_in || exit 0

REASON=$(gf_json_get .reason)
SID=$(gf_json_get .session_id)
BRANCH=""
gf_in_git && BRANCH=$(gf_git rev-parse --abbrev-ref HEAD)

mkdir -p production/session-logs 2>/dev/null || exit 0
printf '%s session=%s reason=%s branch=%s\n' "$(gf_now)" "${SID:-unknown}" "${REASON:-unknown}" "${BRANCH:-none}" \
  >> production/session-logs/sessions.log 2>/dev/null

exit 0
