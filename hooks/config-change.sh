#!/usr/bin/env bash
# GameForge Config Change Hook
# Event: ConfigChange
# Purpose: Detect when skills or configuration are modified during a session.
#
# When skills, settings, or project configuration change while a session is active,
# Claude may be operating with stale skill definitions. This hook detects the change,
# logs it, and suggests a skill reload so the session picks up the latest content.
#
# This is especially important during GameForge development (editing SKILL.md files)
# and when users modify their .claude/settings.json or project configuration.
#
# Input: JSON via stdin with config change details
# Output: JSON to stdout with systemMessage if skills changed
# Exit 0: success, Exit 2: blocking error

# Read input from stdin
INPUT=$(cat)

# Ensure log directory exists
if [ ! -d "production/session-logs" ]; then
  mkdir -p production/session-logs 2>/dev/null || true
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Try to extract the config source from input
CONFIG_SOURCE="unknown"
if echo "$INPUT" | grep -q '"config_source"'; then
  CONFIG_SOURCE=$(echo "$INPUT" | sed -n 's/.*"config_source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi
if [ "$CONFIG_SOURCE" = "unknown" ] && echo "$INPUT" | grep -q '"matcher"'; then
  CONFIG_SOURCE=$(echo "$INPUT" | sed -n 's/.*"matcher"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi
if [ "$CONFIG_SOURCE" = "unknown" ] && echo "$INPUT" | grep -q '"source"'; then
  CONFIG_SOURCE=$(echo "$INPUT" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

# Log the config change event
echo "[$TIMESTAMP] ConfigChange: source=$CONFIG_SOURCE" \
  >> production/session-logs/sessions.log 2>/dev/null || true

# Determine the appropriate response based on what changed
case "$CONFIG_SOURCE" in
  skills)
    # Skills were modified -- this is the most impactful change
    cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Skill files have been modified during this session. The active skill definitions may be stale. If you are developing or updating GameForge skills, consider reloading the affected skill by invoking it again with /skill-name. If a skill behaves unexpectedly, this config change may be the cause."
}
EOF
    ;;
  user_settings)
    # User-level settings changed (e.g., ~/.claude/settings.json)
    cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] User settings have been modified. If you changed tool permissions, model preferences, or hook configuration, the changes are now active."
}
EOF
    ;;
  project_settings)
    # Project-level settings changed (e.g., .claude/settings.json)
    cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Project settings have been modified. If you changed tool permissions or hook configuration for this project, the changes are now active."
}
EOF
    ;;
  local_settings)
    # Local settings changed (e.g., .claude/settings.local.json)
    cat <<EOF
{
  "continue": true
}
EOF
    ;;
  policy_settings)
    # Managed policy settings changed
    cat <<EOF
{
  "continue": true,
  "systemMessage": "[GameForge] Organization policy settings have been updated. Review any new restrictions that may affect tool usage."
}
EOF
    ;;
  *)
    # Unknown config source -- log but don't alarm the user
    cat <<EOF
{
  "continue": true
}
EOF
    ;;
esac

exit 0
