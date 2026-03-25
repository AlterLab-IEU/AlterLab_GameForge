#!/bin/bash
# GameForge Gap Detection Hook

# Fresh project detection
if [ ! -d "design" ] && [ ! -d "src" ]; then
  echo "💡 Fresh project detected. Run /game-start to begin."
  exit 0
fi

# Code exists but no design docs
if [ -d "src" ] && [ ! -d "design/gdd" ]; then
  echo "💡 Code exists but no design docs found. Consider /game-design-review"
fi

# Design docs exist but no tests
if [ -d "design" ] && [ ! -d "tests" ]; then
  echo "💡 Design docs exist but no test directory. Consider setting up testing."
fi

exit 0
