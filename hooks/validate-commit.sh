#!/bin/sh
# GameForge Commit Validation Hook

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

ERRORS=0
SRC_DIRS=$(find_source_dirs)

# Check for hardcoded gameplay values in source
if [ -n "$SRC_DIRS" ]; then
  HARDCODED=""
  for d in $SRC_DIRS; do
    FOUND=$(grep -rn "= [0-9]\+\.\?[0-9]*" "$d" \
      --include="*.gd" --include="*.cs" --include="*.cpp" --include="*.h" \
      --include="*.rs" --include="*.js" --include="*.ts" \
      2>/dev/null | grep -v "const\|Config\|export\|EXPORT\|SerializeField\|UPROPERTY" | head -5)
    if [ -n "$FOUND" ]; then
      HARDCODED="$HARDCODED
$FOUND"
    fi
  done
  if [ -n "$HARDCODED" ]; then
    echo "Possible hardcoded gameplay values (should be in config):"
    echo "$HARDCODED"
  fi

  # Check TODO format
  BAD_TODOS=""
  for d in $SRC_DIRS; do
    FOUND=$(grep -rn "TODO[^(]" "$d" 2>/dev/null | grep -v "TODO(" | head -3)
    if [ -n "$FOUND" ]; then
      BAD_TODOS="$BAD_TODOS
$FOUND"
    fi
  done
  if [ -n "$BAD_TODOS" ]; then
    echo "TODOs should include owner: TODO(name): description"
    echo "$BAD_TODOS"
  fi
fi

# Validate JSON files
for f in $(find . -name "*.json" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null); do
  if [ -f "$f" ]; then
    python -c "import json; json.load(open('$f'))" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "Invalid JSON: $f"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo "Commit validation found $ERRORS error(s)"
fi

exit 0
