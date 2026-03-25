#!/usr/bin/env bash
# GameForge Subagent Tracking Hook
# Events: SubagentStart, SubagentStop
# Purpose: Log which agents are delegated to for orchestration tracking.
#
# When the team orchestrator or any skill spawns subagents, this hook records
# the agent type, timestamp, and start/stop events. This creates an audit trail
# for orchestration debugging and helps identify which agents are used most
# frequently, enabling optimization of the agent hierarchy.
#
# Input: JSON via stdin with agent event details
# Output: JSON to stdout (minimal, non-blocking)
# Exit 0: success, Exit 2: blocking error

# Read input from stdin
INPUT=$(cat)

# Ensure log directory exists
LOG_DIR="production/session-logs"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" 2>/dev/null || true
fi

LOG_FILE="$LOG_DIR/agents.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Extract event details from input JSON
# The hook receives different fields depending on SubagentStart vs SubagentStop
# We parse what we can and log it

# Try to extract agent type from input (best-effort parsing without jq dependency)
AGENT_TYPE="unknown"
if echo "$INPUT" | grep -q '"agent_type"'; then
  AGENT_TYPE=$(echo "$INPUT" | sed -n 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi
if [ "$AGENT_TYPE" = "unknown" ] && echo "$INPUT" | grep -q '"type"'; then
  AGENT_TYPE=$(echo "$INPUT" | sed -n 's/.*"type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi
if [ "$AGENT_TYPE" = "unknown" ] && echo "$INPUT" | grep -q '"matcher"'; then
  AGENT_TYPE=$(echo "$INPUT" | sed -n 's/.*"matcher"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

# Determine if this is a start or stop event
EVENT_TYPE="unknown"
if echo "$INPUT" | grep -q '"event"[[:space:]]*:[[:space:]]*"SubagentStart"'; then
  EVENT_TYPE="START"
elif echo "$INPUT" | grep -q '"event"[[:space:]]*:[[:space:]]*"SubagentStop"'; then
  EVENT_TYPE="STOP"
elif echo "$INPUT" | grep -q 'SubagentStart'; then
  EVENT_TYPE="START"
elif echo "$INPUT" | grep -q 'SubagentStop'; then
  EVENT_TYPE="STOP"
fi

# Log the event
echo "[$TIMESTAMP] $EVENT_TYPE agent=$AGENT_TYPE" >> "$LOG_FILE" 2>/dev/null || true

# Track parallel agent count for SubagentStart events
if [ "$EVENT_TYPE" = "START" ] && [ -f "$LOG_FILE" ]; then
  # Count currently active agents (START entries minus STOP entries)
  START_COUNT=$(grep -c " START " "$LOG_FILE" 2>/dev/null || echo "0")
  STOP_COUNT=$(grep -c " STOP " "$LOG_FILE" 2>/dev/null || echo "0")
  ACTIVE_COUNT=$((START_COUNT - STOP_COUNT))

  # Log the active count
  echo "[$TIMESTAMP] ACTIVE_AGENTS count=$ACTIVE_COUNT" >> "$LOG_FILE" 2>/dev/null || true

  # Warn if too many agents are running in parallel (potential resource concern)
  if [ "$ACTIVE_COUNT" -gt 5 ]; then
    cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Warning: $ACTIVE_COUNT agents currently active in parallel. High agent concurrency increases token usage. Consider sequential execution for non-critical paths."
}
EOF
    exit 0
  fi
fi

# Standard success response (no message needed for normal tracking)
cat <<EOF
{
  "continue": true
}
EOF

exit 0
