#!/usr/bin/env bash
# GameForge Post-Compact Hook
# Event: PostCompact
# Purpose: Restore essential game dev context after context compaction.
#
# When Claude Code compacts context to free up the context window, critical project
# state can be lost. This hook re-injects the most important context reminders so
# the session continues without amnesia about the project's engine, phase, and
# active sprint.
#
# Input: JSON via stdin with compaction details
# Output: JSON to stdout with systemMessage containing context reminders
# Exit 0: success, Exit 2: blocking error

set -euo pipefail

# Read input from stdin (compaction event data)
INPUT=$(cat)

# Ensure session state directories exist
mkdir -p production/session-state 2>/dev/null || true
mkdir -p production/session-logs 2>/dev/null || true

# Collect project context pieces
ENGINE="unknown"
PHASE="unknown"
SPRINT_GOAL=""
TEAM_SIZE=""

# Detect engine from project files
if [ -f "project.godot" ]; then
  ENGINE="Godot"
elif ls *.unity 2>/dev/null | head -1 > /dev/null 2>&1; then
  ENGINE="Unity"
elif ls *.uproject 2>/dev/null | head -1 > /dev/null 2>&1; then
  ENGINE="Unreal Engine"
elif [ -f "package.json" ] && grep -q "phaser\|pixi\|playcanvas" package.json 2>/dev/null; then
  ENGINE="Web (JS)"
elif [ -f "Cargo.toml" ] && grep -q "bevy\|macroquad" Cargo.toml 2>/dev/null; then
  ENGINE="Rust"
fi

# Detect project phase from directory structure
if [ ! -d "src" ] && [ ! -d "design" ]; then
  PHASE="empty-project"
elif [ -d "design" ] && [ ! -d "src" ]; then
  PHASE="concept"
elif [ -d "src" ] && [ -d "design" ]; then
  PHASE="in-progress"
fi

# Read active sprint info if available
if [ -f "production/session-state/last-sprint.json" ]; then
  SPRINT_GOAL=$(cat production/session-state/last-sprint.json 2>/dev/null | head -5)
fi

# Read active session state if available
ACTIVE_STATE=""
if [ -f "production/session-state/active.md" ]; then
  ACTIVE_STATE=$(head -10 production/session-state/active.md 2>/dev/null)
fi

# Log the compaction event
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$TIMESTAMP] PostCompact: context restored (engine=$ENGINE, phase=$PHASE)" \
  >> production/session-logs/sessions.log 2>/dev/null || true

# Build the context reminder message
CONTEXT_MSG="[GameForge Context Restored After Compaction]"
CONTEXT_MSG="$CONTEXT_MSG Engine: $ENGINE."
CONTEXT_MSG="$CONTEXT_MSG Project phase: $PHASE."

if [ -n "$SPRINT_GOAL" ] && [ "$SPRINT_GOAL" != "" ]; then
  CONTEXT_MSG="$CONTEXT_MSG Active sprint data available in production/session-state/last-sprint.json."
fi

if [ -n "$ACTIVE_STATE" ] && [ "$ACTIVE_STATE" != "" ]; then
  CONTEXT_MSG="$CONTEXT_MSG Previous session state available in production/session-state/active.md."
fi

CONTEXT_MSG="$CONTEXT_MSG Shared docs: @docs/collaboration-protocol.md, @docs/game-design-theory.md, @docs/coordination-rules.md. Refer to CLAUDE.md for full skill routing rules."

# Output JSON response
cat <<EOF
{
  "continue": true,
  "systemMessage": "$CONTEXT_MSG"
}
EOF

exit 0
