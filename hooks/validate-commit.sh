#!/bin/bash
# GameForge Commit Validation Hook
ERRORS=0

# Check for hardcoded gameplay values in source
HARDCODED=$(grep -rn "= [0-9]\+\.\?[0-9]*" src/ --include="*.gd" --include="*.cs" --include="*.cpp" 2>/dev/null | grep -v "const\|Config\|export\|EXPORT\|SerializeField\|UPROPERTY" | head -5)
if [ -n "$HARDCODED" ]; then
  echo "⚠️ Possible hardcoded gameplay values (should be in config):"
  echo "$HARDCODED"
fi

# Check TODO format
BAD_TODOS=$(grep -rn "TODO[^(]" src/ 2>/dev/null | grep -v "TODO(" | head -3)
if [ -n "$BAD_TODOS" ]; then
  echo "⚠️ TODOs should include owner: TODO(name): description"
  echo "$BAD_TODOS"
fi

# Validate JSON files
for f in $(find . -name "*.json" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null); do
  python -c "import json; json.load(open('$f'))" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Invalid JSON: $f"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo "Commit validation found $ERRORS error(s)"
fi

exit 0
