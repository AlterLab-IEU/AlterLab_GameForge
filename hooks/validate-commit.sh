#!/bin/sh
# GameForge -- PreToolUse (matcher: Bash)
#
# Acts only on `git commit` commands; every other Bash call exits immediately.
#
# 1. Large-binary guard (any game project): blocks a commit that would add files at or
#    above the LFS threshold (default 20 MB, `.gameforge/project.json` "lfs_threshold_mb")
#    that Git LFS is not tracking. Large binaries in history are painful to remove.
#    Override for one command with GAMEFORGE_ALLOW_LARGE_FILES=1.
# 2. Commit-message convention (opted-in projects only): checks the subject line.
#    Convention comes from GAMEFORGE_COMMIT_CONVENTION or `.gameforge/project.json`
#    "commit_convention": conventional (default) | gameforge | off.
#
# Blocking uses the documented PreToolUse JSON decision with a reason Claude can act on.

. "${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}/hooks/lib/common.sh"
gf_read_input

CMD=$(gf_json_get .tool_input.command)
printf '%s' "$CMD" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]+-c[[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' || exit 0

gf_require_game_project
gf_in_git || exit 0

# --- 1. Large binaries without LFS ------------------------------------------------
if [ "${GAMEFORGE_ALLOW_LARGE_FILES:-0}" != 1 ]; then
  LIMIT_MB=$(gf_config lfs_threshold_mb)
  case "$LIMIT_MB" in ''|*[!0-9]*) LIMIT_MB=20 ;; esac
  LIMIT=$((LIMIT_MB * 1024 * 1024))
  BIG=""
  TMP_LIST=$(gf_git diff --cached --name-only --diff-filter=AM)
  if [ -n "$TMP_LIST" ]; then
    BIG=$(printf '%s\n' "$TMP_LIST" | while IFS= read -r f; do
      [ -f "$f" ] || continue
      size=$(wc -c < "$f" 2>/dev/null | tr -d ' ')
      [ -n "$size" ] && [ "$size" -ge "$LIMIT" ] || continue
      git check-attr filter -- "$f" 2>/dev/null | grep -q 'filter: lfs$' && continue
      printf '%s (%s MB)\n' "$f" "$((size / 1024 / 1024))"
    done)
  fi
  if [ -n "$BIG" ]; then
    gf_pretool_decision deny "GameForge: this commit adds files of ${LIMIT_MB} MB or more that Git LFS is not tracking:
$BIG
Track them first (for example: git lfs track \"*.psd\" && git add .gitattributes), unstage them, or re-run with GAMEFORGE_ALLOW_LARGE_FILES=1 if the user explicitly wants them in plain git."
  fi
fi

# --- 2. Commit message convention -------------------------------------------------
gf_opted_in || exit 0
CONVENTION=${GAMEFORGE_COMMIT_CONVENTION:-$(gf_config commit_convention)}
[ -n "$CONVENTION" ] || CONVENTION=conventional
[ "$CONVENTION" = off ] && exit 0

# Only look at what follows `commit`, so global options such as `git -C dir` or
# `git -c key=value` are not mistaken for commit flags.
ARGS=$(printf '%s\n' "$CMD" | awk '
  found { print; next }
  { i = index($0, " commit"); if (i) { found = 1; print substr($0, i + 7) } }
')
FIRST_LINE=$(printf '%s\n' "$ARGS" | head -n 1)

# Messages we cannot or should not judge.
printf '%s' "$FIRST_LINE" | grep -Eq -- '--no-edit|(^|[[:space:]])(-F|--file|-C|-c|--reuse-message|--reedit-message|--fixup|--squash)([[:space:]=]|$)' && exit 0

# Subject: first line of a heredoc body, else the first -m/--message argument.
SUBJECT=$(printf '%s\n' "$ARGS" | awk '
  heredoc && NF { sub(/^[ \t]+/, ""); print; exit }
  /<</ { heredoc = 1; next }
')
if [ -z "$SUBJECT" ]; then
  SUBJECT=$(printf '%s\n' "$FIRST_LINE" | awk '
    {
      if (!match($0, /(^|[ \t])(-[a-zA-Z]*m|--message)([ \t=]|$)/)) next
      s = substr($0, RSTART + RLENGTH)
      sub(/^[ \t=]+/, "", s)
      q = substr(s, 1, 1)
      if (q == "\"" || q == "'\''") {
        s = substr(s, 2); out = ""
        for (i = 1; i <= length(s); i++) {
          c = substr(s, i, 1)
          if (c == "\\" && q == "\"") { i++; out = out substr(s, i, 1); continue }
          if (c == q) break
          out = out c
        }
        print out
      } else {
        split(s, parts, /[ \t]/); print parts[1]
      }
      exit
    }' | head -n 1)
fi
[ -n "$SUBJECT" ] || exit 0

case "$SUBJECT" in Merge\ *|Revert\ *|fixup!*|squash!*) exit 0 ;; esac

if [ "$CONVENTION" = gameforge ]; then
  PATTERN='^(feat|improve|fix|docs|chore): [^[:space:]]'
  TYPES="feat, improve, fix, docs, chore"
  EXAMPLE="improve: tighten dash cooldown curve"
else
  PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|art|audio|design|level|balance|narrative|loc|ui)(\([[:alnum:]._/-]+\))?!?: [^[:space:]]'
  TYPES="feat, fix, refactor, perf, test, build, ci, docs, chore, revert, and game types art, audio, design, level, balance, narrative, loc, ui"
  EXAMPLE="balance(combat): lower parry window from 12 to 9 frames"
fi

if ! printf '%s' "$SUBJECT" | grep -Eq "$PATTERN"; then
  gf_pretool_decision deny "GameForge: commit subject \"$SUBJECT\" does not follow the project's $CONVENTION commit convention. Use <type>(<optional scope>): <summary> with type one of: $TYPES. Example: $EXAMPLE. (Set commit_convention to \"off\" in .gameforge/project.json to disable this check.)"
fi

LEN=$(printf '%s' "$SUBJECT" | wc -c | tr -d ' ')
if [ "$LEN" -gt 100 ]; then
  gf_pretool_decision deny "GameForge: commit subject is $LEN characters; keep it under 72 (hard limit 100) and move detail into the body."
fi

exit 0
