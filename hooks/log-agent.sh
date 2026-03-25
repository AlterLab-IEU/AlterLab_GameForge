#!/bin/bash
# GameForge Agent Logging Hook
# Log subagent invocations for audit trail
mkdir -p production/session-logs
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Agent invoked: $1" >> production/session-logs/agent-log.txt 2>/dev/null

exit 0
