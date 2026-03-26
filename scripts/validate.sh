#!/usr/bin/env bash
# AlterLab GameForge — Skill Validation Suite
# Runs all validation checks. Exit 0 = all pass, Exit 1 = failures found.
# Usage: bash scripts/validate.sh [--verbose]

set -o pipefail

VERBOSE=false
[[ "$1" == "--verbose" ]] && VERBOSE=true

# Resolve repo root — handle both direct invocation and script-relative paths
if [[ -f "marketplace.json" ]]; then
  REPO_ROOT="$(pwd)"
elif [[ -n "${BASH_SOURCE[0]}" ]]; then
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  REPO_ROOT="$(pwd)"
fi
cd "$REPO_ROOT" || { echo "Cannot cd to $REPO_ROOT"; exit 1; }

ERRORS=0
WARNINGS=0
CHECKS=0

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''; BOLD=''
fi

pass() { ((CHECKS++)); $VERBOSE && echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { ((CHECKS++)); ((ERRORS++)); echo -e "  ${RED}FAIL${NC} $1"; }
warn() { ((WARNINGS++)); echo -e "  ${YELLOW}WARN${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}[$1]${NC}"; }

# ─────────────────────────────────────────────
# 1. FRONTMATTER VALIDATION
# ─────────────────────────────────────────────
section "Frontmatter Validation"

SKILL_FILES=$(find skills/ -name "SKILL.md" 2>/dev/null)
SKILL_COUNT=$(echo "$SKILL_FILES" | wc -l)

for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")

  # Extract frontmatter (between first two --- lines)
  frontmatter=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$skill_file")

  # Check required fields
  for field in "name" "description" "argument-hint" "allowed-tools"; do
    value=$(echo "$frontmatter" | grep -E "^${field}:" | head -1)
    if [[ -z "$value" ]]; then
      fail "$skill_name: missing frontmatter field '$field'"
    else
      # Check field is not empty
      field_value=$(echo "$value" | sed "s/^${field}:[[:space:]]*//" | sed 's/^["'"'"']//' | sed 's/["'"'"']$//')
      if [[ -z "$field_value" ]]; then
        fail "$skill_name: frontmatter field '$field' is empty"
      else
        pass "$skill_name: has '$field'"
      fi
    fi
  done

  # Check version field exists
  version=$(echo "$frontmatter" | grep -E "^version:" | head -1)
  if [[ -z "$version" ]]; then
    warn "$skill_name: missing 'version' field in frontmatter"
  else
    pass "$skill_name: has 'version'"
  fi
done

# ─────────────────────────────────────────────
# 2. LINE COUNT VALIDATION
# ─────────────────────────────────────────────
section "Line Count Validation"

for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")
  skill_dir=$(echo "$skill_file" | cut -d'/' -f2)
  line_count=$(wc -l < "$skill_file")

  case "$skill_dir" in
    agents)
      if [[ $line_count -ge 200 ]]; then
        pass "$skill_name: $line_count lines (agent min: 200)"
      else
        fail "$skill_name: $line_count lines (agent min: 200)"
      fi
      ;;
    workflows)
      if [[ $line_count -ge 150 ]]; then
        pass "$skill_name: $line_count lines (workflow min: 150)"
      else
        fail "$skill_name: $line_count lines (workflow min: 150)"
      fi
      ;;
    engine-specialists)
      if [[ $line_count -ge 200 ]]; then
        pass "$skill_name: $line_count lines (engine min: 200)"
      else
        fail "$skill_name: $line_count lines (engine min: 200)"
      fi
      ;;
    *)
      warn "$skill_name: unknown category '$skill_dir'"
      ;;
  esac
done

# ─────────────────────────────────────────────
# 3. JSON VALIDATION
# ─────────────────────────────────────────────
section "JSON Validation"

if [[ -f marketplace.json ]]; then
  if python -m json.tool marketplace.json > /dev/null 2>&1; then
    pass "marketplace.json: valid JSON"
  else
    fail "marketplace.json: invalid JSON"
  fi

  # Check all skills are listed
  for skill_file in $SKILL_FILES; do
    skill_name=$(basename "$(dirname "$skill_file")")
    if grep -q "\"$skill_name\"" marketplace.json; then
      pass "marketplace.json: lists '$skill_name'"
    else
      fail "marketplace.json: missing skill '$skill_name'"
    fi
  done

  # Check all listed skill paths exist
  skill_paths=$(python -c "
import json, sys
with open('marketplace.json') as f:
    data = json.load(f)
for s in data.get('skills', []):
    print(s.get('path', ''))
" 2>/dev/null | tr -d '\r')

  if [[ -n "$skill_paths" ]]; then
    while IFS= read -r spath; do
      if [[ -n "$spath" && -f "$spath" ]]; then
        pass "marketplace.json: path exists '$spath'"
      elif [[ -n "$spath" ]]; then
        fail "marketplace.json: path not found '$spath'"
      fi
    done <<< "$skill_paths"
  fi

  # Check all listed doc paths exist
  doc_paths=$(python -c "
import json, sys
with open('marketplace.json') as f:
    data = json.load(f)
for d in data.get('docs', []):
    print(d.get('path', ''))
" 2>/dev/null | tr -d '\r')

  if [[ -n "$doc_paths" ]]; then
    while IFS= read -r dpath; do
      if [[ -n "$dpath" && -f "$dpath" ]]; then
        pass "marketplace.json: doc path exists '$dpath'"
      elif [[ -n "$dpath" ]]; then
        fail "marketplace.json: doc path not found '$dpath'"
      fi
    done <<< "$doc_paths"
  fi

  # Check all listed template paths exist
  tmpl_paths=$(python -c "
import json, sys
with open('marketplace.json') as f:
    data = json.load(f)
for t in data.get('templates', []):
    print(t.get('path', ''))
" 2>/dev/null | tr -d '\r')

  if [[ -n "$tmpl_paths" ]]; then
    while IFS= read -r tpath; do
      if [[ -n "$tpath" && -f "$tpath" ]]; then
        pass "marketplace.json: template path exists '$tpath'"
      elif [[ -n "$tpath" ]]; then
        fail "marketplace.json: template path not found '$tpath'"
      fi
    done <<< "$tmpl_paths"
  fi

  # Check all listed hook paths exist
  hook_paths=$(python -c "
import json, sys
with open('marketplace.json') as f:
    data = json.load(f)
for h in data.get('hooks', []):
    print(h.get('path', ''))
" 2>/dev/null | tr -d '\r')

  if [[ -n "$hook_paths" ]]; then
    while IFS= read -r hpath; do
      if [[ -n "$hpath" && -f "$hpath" ]]; then
        pass "marketplace.json: hook path exists '$hpath'"
      elif [[ -n "$hpath" ]]; then
        fail "marketplace.json: hook path not found '$hpath'"
      fi
    done <<< "$hook_paths"
  fi
else
  fail "marketplace.json: file not found"
fi

# Check package.json
if [[ -f package.json ]]; then
  if python -m json.tool package.json > /dev/null 2>&1; then
    pass "package.json: valid JSON"
  else
    fail "package.json: invalid JSON"
  fi
else
  warn "package.json: file not found"
fi

# ─────────────────────────────────────────────
# 4. HOOK VALIDATION
# ─────────────────────────────────────────────
section "Hook Validation"

HOOK_FILES=$(find hooks/ -name "*.sh" 2>/dev/null)

for hook_file in $HOOK_FILES; do
  hook_name=$(basename "$hook_file")

  # Check shebang
  first_line=$(head -1 "$hook_file")
  if [[ "$first_line" == "#!/"* ]]; then
    pass "$hook_name: has shebang"
  else
    fail "$hook_name: missing shebang (first line: '$first_line')"
  fi

  # Check ends with exit 0
  last_nonblank=$(grep -v '^[[:space:]]*$' "$hook_file" | tail -1)
  if [[ "$last_nonblank" == "exit 0" ]]; then
    pass "$hook_name: ends with 'exit 0'"
  else
    fail "$hook_name: does not end with 'exit 0' (last line: '$last_nonblank')"
  fi

  # Syntax check with bash -n
  if bash -n "$hook_file" 2>/dev/null; then
    pass "$hook_name: passes bash -n syntax check"
  else
    fail "$hook_name: fails bash -n syntax check"
  fi

  # Check for bash-only syntax (arrays) that breaks POSIX
  if grep -qE '\[\[' "$hook_file" 2>/dev/null; then
    warn "$hook_name: uses [[ ]] (bash-specific, not POSIX)"
  fi
done

# ─────────────────────────────────────────────
# 5. CROSS-REFERENCE VALIDATION
# ─────────────────────────────────────────────
section "Cross-Reference Validation"

# Check @docs/ references in skills
for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")
  doc_refs=$(grep -oE '@docs/[a-zA-Z0-9_-]+\.md' "$skill_file" 2>/dev/null | sort -u)

  if [[ -n "$doc_refs" ]]; then
    while IFS= read -r ref; do
      doc_path=$(echo "$ref" | sed 's/@//')
      if [[ -f "$doc_path" ]]; then
        pass "$skill_name: ref $ref exists"
      else
        fail "$skill_name: ref $ref not found"
      fi
    done <<< "$doc_refs"
  fi
done

# Check @templates/ references in skills
for skill_file in $SKILL_FILES; do
  skill_name=$(basename "$(dirname "$skill_file")")
  tmpl_refs=$(grep -oE '@templates/[a-zA-Z0-9_-]+\.md' "$skill_file" 2>/dev/null | sort -u)

  if [[ -n "$tmpl_refs" ]]; then
    while IFS= read -r ref; do
      tmpl_path=$(echo "$ref" | sed 's/@//')
      if [[ -f "$tmpl_path" ]]; then
        pass "$skill_name: ref $ref exists"
      else
        fail "$skill_name: ref $ref not found"
      fi
    done <<< "$tmpl_refs"
  fi
done

# ─────────────────────────────────────────────
# 6. ORPHAN DETECTION
# ─────────────────────────────────────────────
section "Orphan Detection"

# Check each template is referenced by at least one skill
TEMPLATE_FILES=$(find templates/ -name "*.md" 2>/dev/null)

for tmpl_file in $TEMPLATE_FILES; do
  tmpl_name=$(basename "$tmpl_file")
  # Search for reference in any skill file or doc
  if grep -rl "$tmpl_name" skills/ docs/ CLAUDE.md 2>/dev/null | head -1 > /dev/null 2>&1; then
    ref_count=$(grep -rl "$tmpl_name" skills/ docs/ CLAUDE.md 2>/dev/null | wc -l)
    if [[ $ref_count -gt 0 ]]; then
      pass "templates/$tmpl_name: referenced by $ref_count file(s)"
    else
      warn "templates/$tmpl_name: orphan template (no references found)"
    fi
  else
    warn "templates/$tmpl_name: orphan template (no references found)"
  fi
done

# ─────────────────────────────────────────────
# 7. VERSION CONSISTENCY
# ─────────────────────────────────────────────
section "Version Consistency"

# Check marketplace.json version matches package.json
if [[ -f marketplace.json && -f package.json ]]; then
  mp_version=$(python -c "import json; print(json.load(open('marketplace.json'))['version'])" 2>/dev/null | tr -d '\r')
  pkg_version=$(python -c "import json; print(json.load(open('package.json'))['version'])" 2>/dev/null | tr -d '\r')

  if [[ "$mp_version" == "$pkg_version" ]]; then
    pass "marketplace.json ($mp_version) matches package.json ($pkg_version)"
  else
    fail "marketplace.json ($mp_version) does not match package.json ($pkg_version)"
  fi
fi

# Check engine version strings are consistent across skills
godot_versions=$(grep -h "Godot [0-9]" skills/engine-specialists/game-godot-specialist/SKILL.md 2>/dev/null | grep -oE "Godot [0-9]+\.[0-9]+" | sort -u)
unity_versions=$(grep -h "Unity [0-9]" skills/engine-specialists/game-unity-specialist/SKILL.md 2>/dev/null | grep -oE "Unity [0-9]+\.[0-9]+" | sort -u | head -3)
unreal_versions=$(grep -h "UE[[:space:]]*5\.[0-9]" skills/engine-specialists/game-unreal-specialist/SKILL.md 2>/dev/null | grep -oE "UE[[:space:]]*5\.[0-9]+" | sort -u | head -3)

$VERBOSE && echo -e "  ${CYAN}INFO${NC} Godot versions found: $(echo $godot_versions | tr '\n' ', ')"
$VERBOSE && echo -e "  ${CYAN}INFO${NC} Unity versions found: $(echo $unity_versions | tr '\n' ', ')"
$VERBOSE && echo -e "  ${CYAN}INFO${NC} Unreal versions found: $(echo $unreal_versions | tr '\n' ', ')"

# ─────────────────────────────────────────────
# 8. STRUCTURE VALIDATION
# ─────────────────────────────────────────────
section "Structure Validation"

# Check required top-level files exist
for required_file in "README.md" "CLAUDE.md" "CONTRIBUTING.md" "CODE_OF_CONDUCT.md" "SECURITY.md" "LICENSE" "ROADMAP.md" "marketplace.json" "package.json"; do
  if [[ -f "$required_file" ]]; then
    pass "Required file: $required_file"
  else
    fail "Required file missing: $required_file"
  fi
done

# Check required directories exist
for required_dir in "skills/agents" "skills/workflows" "skills/engine-specialists" "docs" "hooks" "templates" "starters"; do
  if [[ -d "$required_dir" ]]; then
    pass "Required directory: $required_dir/"
  else
    fail "Required directory missing: $required_dir/"
  fi
done

# Check each skill has its own directory with SKILL.md
for skill_dir in skills/agents/* skills/workflows/* skills/engine-specialists/*; do
  if [[ -d "$skill_dir" ]]; then
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      pass "$(basename "$skill_dir")/SKILL.md exists"
    else
      fail "$(basename "$skill_dir"): missing SKILL.md"
    fi
  fi
done

# ─────────────────────────────────────────────
# 9. GENRE PACK VALIDATION (if present)
# ─────────────────────────────────────────────
if [[ -d "genre-packs" ]]; then
  section "Genre Pack Validation"

  for pack_dir in genre-packs/*/; do
    pack_name=$(basename "$pack_dir")

    # Check required files
    if [[ -f "${pack_dir}PATTERNS.md" ]]; then
      pass "$pack_name: has PATTERNS.md"
      # Check minimum line count
      pattern_lines=$(wc -l < "${pack_dir}PATTERNS.md")
      if [[ $pattern_lines -ge 100 ]]; then
        pass "$pack_name: PATTERNS.md has $pattern_lines lines (min: 100)"
      else
        fail "$pack_name: PATTERNS.md has $pattern_lines lines (min: 100)"
      fi
    else
      fail "$pack_name: missing PATTERNS.md"
    fi

    if [[ -f "${pack_dir}README.md" ]]; then
      pass "$pack_name: has README.md"
    else
      warn "$pack_name: missing README.md"
    fi
  done
fi

# ─────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo -e "${BOLD} Validation Summary${NC}"
echo -e "${BOLD}══════════════════════════════════════════${NC}"
echo -e "  Skills found:  $SKILL_COUNT"
echo -e "  Checks run:    $CHECKS"
echo -e "  ${GREEN}Passed:${NC}        $((CHECKS - ERRORS))"
echo -e "  ${RED}Failed:${NC}        $ERRORS"
echo -e "  ${YELLOW}Warnings:${NC}      $WARNINGS"
echo -e "${BOLD}══════════════════════════════════════════${NC}"

if [[ $ERRORS -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}VALIDATION FAILED${NC} — $ERRORS error(s) must be fixed before release.\n"
  exit 1
else
  echo -e "\n${GREEN}${BOLD}VALIDATION PASSED${NC} — All $CHECKS checks passed.\n"
  exit 0
fi
