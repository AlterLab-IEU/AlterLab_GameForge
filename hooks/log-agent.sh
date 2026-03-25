#!/bin/sh
# GameForge Agent Logging Hook
# Log subagent invocations for audit trail
if [ ! -d "production/session-logs" ]; then
  mkdir -p production/session-logs 2>/dev/null
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Agent invoked: $1" >> production/session-logs/agent-log.txt 2>/dev/null

exit 0
