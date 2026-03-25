#!/usr/bin/env bash
# GameForge Instructions Validation Hook
# Event: InstructionsLoaded
# Purpose: Validate that required documentation files exist when CLAUDE.md is loaded.
#
# When Claude Code loads CLAUDE.md (at session start, after compaction, or when
# traversing nested directories), this hook checks that the shared documentation
# files referenced by skills actually exist. Missing docs cause skills to produce
# incomplete or incorrect output because they reference knowledge that is not there.
#
# Input: JSON via stdin with load event details
# Output: JSON to stdout with systemMessage if docs are missing
# Exit 0: success, Exit 2: blocking error

set -euo pipefail

# Read input from stdin
INPUT=$(cat)

# Define required documentation files
# These are the files referenced in CLAUDE.md "Shared Documentation" section
REQUIRED_DOCS=(
  "docs/collaboration-protocol.md"
  "docs/game-design-theory.md"
  "docs/coordination-rules.md"
  "docs/agent-hierarchy.md"
  "docs/coding-standards.md"
  "docs/workflow-guide.md"
  "docs/monetization-ethics.md"
  "docs/engine-comparison.md"
)

# Track missing files
MISSING=""
MISSING_COUNT=0

# Check each required doc
for doc in "${REQUIRED_DOCS[@]}"; do
  if [ ! -f "$doc" ]; then
    MISSING="$MISSING $doc"
    MISSING_COUNT=$((MISSING_COUNT + 1))
  fi
done

# Check if docs directory exists at all
if [ ! -d "docs" ]; then
  cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Warning: docs/ directory not found. This project may not be a GameForge-enabled game project, or the docs directory has not been created yet. Run /game-start to initialize project structure."
}
EOF
  exit 0
fi

# Check if templates directory exists
TEMPLATE_WARNING=""
if [ ! -d "templates" ]; then
  TEMPLATE_WARNING=" Templates directory (templates/) is also missing."
fi

# Report findings
if [ "$MISSING_COUNT" -gt 0 ]; then
  cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Warning: $MISSING_COUNT required documentation file(s) missing:$MISSING.$TEMPLATE_WARNING Skills that reference these docs will produce incomplete output. Run /game-start to scaffold missing files, or create them manually."
}
EOF
else
  # All docs present, no message needed
  cat <<EOF
{
  "continue": true
}
EOF
fi

exit 0
