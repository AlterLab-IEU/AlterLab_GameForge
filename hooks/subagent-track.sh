#!/bin/sh
# GameForge -- SubagentStart / SubagentStop
#
# Logs delegation for orchestration debugging (production/session-logs/agents.log)
# and tracks how many subagents are live in *this* session. When more than
# GAMEFORGE_MAX_PARALLEL_AGENTS (default 6) run at once it shows the user a warning,
# because parallel agents multiply token spend. Only runs in opted-in projects.

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input
gf_opted_in || exit 0

EVENT=$(gf_json_get .hook_event_name)
SID=$(gf_json_get .session_id)
AID=$(gf_json_get .agent_id)
ATYPE=$(gf_json_get .agent_type)
[ -n "$SID" ] || SID=unknown
[ -n "$AID" ] || AID="anon-$$"

LIVE_DIR="production/session-state/agents/$(printf '%s' "$SID" | tr -c 'A-Za-z0-9_.-' '_')"
mkdir -p production/session-logs "$LIVE_DIR" 2>/dev/null || exit 0
KEY=$(printf '%s' "$AID" | tr -c 'A-Za-z0-9_.-' '_')

case "$EVENT" in
  SubagentStart) : > "$LIVE_DIR/$KEY"; TAG=START ;;
  SubagentStop) rm -f "$LIVE_DIR/$KEY"; TAG=STOP ;;
  *) exit 0 ;;
esac

LIVE=$(find "$LIVE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
printf '%s %s session=%s agent=%s type=%s live=%s\n' "$(gf_now)" "$TAG" "$SID" "$AID" "${ATYPE:-unknown}" "$LIVE" \
  >> production/session-logs/agents.log 2>/dev/null

MAX=${GAMEFORGE_MAX_PARALLEL_AGENTS:-6}
case "$MAX" in ''|*[!0-9]*) MAX=6 ;; esac
if [ "$TAG" = START ] && [ "$LIVE" -gt "$MAX" ]; then
  printf '{"systemMessage":"%s"}\n' "$(gf_json_escape "[GameForge] $LIVE subagents are running at once in this session (limit $MAX). Parallel agents multiply token use; consider sequencing non-critical work.")"
fi

exit 0
