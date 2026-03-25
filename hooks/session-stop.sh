#!/bin/bash
# GameForge Session Stop Hook
echo "=== GameForge Session End ==="
echo "Session ended: $(date '+%Y-%m-%d %H:%M')" >> production/session-logs/sessions.log 2>/dev/null
echo "=== Session logged ==="

exit 0
