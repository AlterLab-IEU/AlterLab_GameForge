#!/bin/sh
# GameForge Session Stop Hook
echo "=== GameForge Session End ==="
mkdir -p production/session-logs 2>/dev/null
echo "Session ended: $(date '+%Y-%m-%d %H:%M')" >> production/session-logs/sessions.log 2>/dev/null
echo "=== Session logged ==="

exit 0
