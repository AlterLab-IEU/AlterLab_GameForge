#!/bin/sh
# GameForge -- StopFailure
#
# When a turn ends on an API error (rate_limit, overloaded, billing_error, ...), record a
# recovery note so the next SessionStart can offer to resume. Writes valid JSON with
# escaped fields. Only runs in opted-in projects.

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input
gf_require_opt_in

ERR=$(gf_json_get .error_type)
[ -n "$ERR" ] || ERR=$(gf_json_get .error)
[ -n "$ERR" ] || ERR=$(gf_json_get .reason)
[ -n "$ERR" ] || ERR=unknown

BRANCH=""; LAST=""
if gf_in_git; then
  BRANCH=$(gf_git rev-parse --abbrev-ref HEAD)
  LAST=$(gf_git log -1 --pretty='%h %s')
fi

mkdir -p production/session-state production/session-logs 2>/dev/null || exit 0
cat > production/session-state/recovery.json <<EOF
{
  "timestamp": "$(gf_now)",
  "error": "$(gf_json_escape "$ERR")",
  "session_id": "$(gf_json_escape "$(gf_json_get .session_id)")",
  "engine": "$(gf_json_escape "$GF_ENGINE_LABEL")",
  "branch": "$(gf_json_escape "$BRANCH")",
  "last_commit": "$(gf_json_escape "$LAST")"
}
EOF
printf '%s StopFailure error=%s\n' "$(gf_now)" "$ERR" >> production/session-logs/sessions.log 2>/dev/null

exit 0
