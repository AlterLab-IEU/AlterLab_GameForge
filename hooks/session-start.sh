#!/bin/sh
# GameForge Session Start Hook
# Loads sprint context, recent git history, session state recovery, project health

echo "=== GameForge Session Start ==="

# Find source directories (engine-aware)
find_source_dirs() {
  DIRS=""
  for d in src scripts Scripts Source Assets/Scripts lib; do
    if [ -d "$d" ]; then
      DIRS="$DIRS $d"
    fi
  done
  echo "$DIRS"
}

# Check for active session state
if [ -f "production/session-state/active.md" ]; then
  echo "Resuming previous session:"
  head -20 production/session-state/active.md
fi

# Recent git activity
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo ""
  echo "Recent changes:"
  git log --oneline -5 2>/dev/null
fi

# Project health
echo ""
echo "Project Health:"
SRC_DIRS=$(find_source_dirs)
TODO_COUNT=0
FIXME_COUNT=0
if [ -n "$SRC_DIRS" ]; then
  for d in $SRC_DIRS; do
    T=$(grep -r "TODO" "$d" 2>/dev/null | wc -l)
    F=$(grep -r "FIXME" "$d" 2>/dev/null | wc -l)
    TODO_COUNT=$((TODO_COUNT + T))
    FIXME_COUNT=$((FIXME_COUNT + F))
  done
fi
echo "  TODOs: $TODO_COUNT | FIXMEs: $FIXME_COUNT"

# Check for open bugs
if [ -d "production" ]; then
  BUG_COUNT=$(grep -r "\[ \].*bug\|BUG" production/ 2>/dev/null | wc -l)
  echo "  Open bugs: $BUG_COUNT"
fi

echo ""
echo "=== Ready to forge ==="

exit 0
