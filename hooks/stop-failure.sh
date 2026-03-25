#!/usr/bin/env bash
# GameForge Stop Failure Hook
# Event: StopFailure
# Purpose: Graceful handling of API errors that end a turn mid-session.
#
# When Claude Code encounters an API error (rate limit, authentication failure,
# billing error, or server error), this hook logs the failure, saves current
# session state for recovery, and outputs guidance for the user on how to proceed.
#
# This prevents the frustrating pattern of losing work context when an API error
# occurs during a long multi-agent orchestration or complex skill execution.
#
# Input: JSON via stdin with error type details
# Output: JSON to stdout with systemMessage containing recovery guidance
# Exit 0: success, Exit 2: blocking error

set -euo pipefail

# Read input from stdin
INPUT=$(cat)

# Ensure state directories exist
mkdir -p production/session-state 2>/dev/null || true
mkdir -p production/session-logs 2>/dev/null || true

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Try to extract the error type from input
ERROR_TYPE="unknown"
if echo "$INPUT" | grep -q '"error_type"'; then
  ERROR_TYPE=$(echo "$INPUT" | sed -n 's/.*"error_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi
if [ "$ERROR_TYPE" = "unknown" ] && echo "$INPUT" | grep -q '"matcher"'; then
  ERROR_TYPE=$(echo "$INPUT" | sed -n 's/.*"matcher"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

# Log the error event
echo "[$TIMESTAMP] StopFailure: error_type=$ERROR_TYPE" \
  >> production/session-logs/sessions.log 2>/dev/null || true

# Save recovery state
# Capture what we can about the current project state for session recovery
RECOVERY_FILE="production/session-state/recovery.json"

# Detect engine
ENGINE="unknown"
if [ -f "project.godot" ]; then
  ENGINE="Godot"
elif ls *.unity 2>/dev/null | head -1 > /dev/null 2>&1; then
  ENGINE="Unity"
elif ls *.uproject 2>/dev/null | head -1 > /dev/null 2>&1; then
  ENGINE="Unreal"
fi

# Get recent git state for context
LAST_COMMIT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "none")
fi

# Check for active pipeline state
ACTIVE_PIPELINE="none"
for pipeline_file in production/session-state/pipeline-*.json; do
  if [ -f "$pipeline_file" ]; then
    ACTIVE_PIPELINE=$(basename "$pipeline_file" .json)
    break
  fi
done

# Write recovery JSON
cat > "$RECOVERY_FILE" <<RECOVERY
{
  "timestamp": "$TIMESTAMP",
  "error_type": "$ERROR_TYPE",
  "engine": "$ENGINE",
  "last_commit": "$LAST_COMMIT",
  "active_pipeline": "$ACTIVE_PIPELINE",
  "recovery_hint": "Resume session and check production/session-state/ for prior context."
}
RECOVERY

# Build user-facing guidance based on error type
case "$ERROR_TYPE" in
  rate_limit)
    GUIDANCE="API rate limit reached. Wait 1-2 minutes before retrying. Your session state has been saved to $RECOVERY_FILE. When you resume, the session-start hook will detect the recovery file."
    ;;
  authentication_failed)
    GUIDANCE="Authentication error. Check your API key configuration. Session state saved to $RECOVERY_FILE. Re-authenticate and resume -- your project context will be restored."
    ;;
  billing_error)
    GUIDANCE="Billing error encountered. Check your account billing status. Session state saved to $RECOVERY_FILE."
    ;;
  server_error)
    GUIDANCE="Server error from the API. This is typically transient. Wait 30 seconds and retry. Session state saved to $RECOVERY_FILE."
    ;;
  *)
    GUIDANCE="Unexpected API error ($ERROR_TYPE). Session state saved to $RECOVERY_FILE. Try restarting the session -- the recovery file will help restore context."
    ;;
esac

# Output JSON response with recovery guidance
cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] $GUIDANCE"
}
EOF

exit 0
