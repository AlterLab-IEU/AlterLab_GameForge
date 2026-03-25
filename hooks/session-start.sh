#!/bin/bash
# GameForge Session Start Hook
# Loads sprint context, recent git history, session state recovery, project health

echo "=== GameForge Session Start ==="

# Check for active session state
if [ -f "production/session-state/active.md" ]; then
  echo "📋 Resuming previous session:"
  head -20 production/session-state/active.md
fi

# Recent git activity
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo ""
  echo "📝 Recent changes:"
  git log --oneline -5 2>/dev/null
fi

# Project health
echo ""
echo "🔍 Project Health:"
TODO_COUNT=$(grep -r "TODO" src/ 2>/dev/null | wc -l)
FIXME_COUNT=$(grep -r "FIXME" src/ 2>/dev/null | wc -l)
echo "  TODOs: $TODO_COUNT | FIXMEs: $FIXME_COUNT"

# Check for open bugs
if [ -d "production" ]; then
  BUG_COUNT=$(grep -r "\[ \].*bug\|BUG" production/ 2>/dev/null | wc -l)
  echo "  Open bugs: $BUG_COUNT"
fi

echo ""
echo "=== Ready to forge ==="
