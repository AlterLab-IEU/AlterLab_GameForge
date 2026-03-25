#!/bin/sh
# GameForge Gap Detection Hook

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

# Find design directories
find_design_dirs() {
  DIRS=""
  for d in design design/gdd docs/design Documentation; do
    if [ -d "$d" ]; then
      DIRS="$DIRS $d"
    fi
  done
  echo "$DIRS"
}

# Find test directories
find_test_dirs() {
  DIRS=""
  for d in tests test Tests; do
    if [ -d "$d" ]; then
      DIRS="$DIRS $d"
    fi
  done
  echo "$DIRS"
}

SRC_DIRS=$(find_source_dirs)
DESIGN_DIRS=$(find_design_dirs)
TEST_DIRS=$(find_test_dirs)

# Fresh project detection -- no source AND no design directories
if [ -z "$SRC_DIRS" ] && [ -z "$DESIGN_DIRS" ]; then
  echo "Fresh project detected. Run /game-start to begin."
  exit 0
fi

# Code exists but no design docs
if [ -n "$SRC_DIRS" ] && [ -z "$DESIGN_DIRS" ]; then
  echo "Code exists but no design docs found. Consider /game-design-review"
fi

# Design docs exist but no tests
if [ -n "$DESIGN_DIRS" ] && [ -z "$TEST_DIRS" ]; then
  echo "Design docs exist but no test directory. Consider setting up testing."
fi

exit 0
