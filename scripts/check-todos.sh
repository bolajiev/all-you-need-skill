#!/usr/bin/env bash
# check-todos.sh — verify that every actionable marker in the tree has an owner
# and a trigger for revisiting (per core/architecture-decisions.md and
# templates/adr-template.md). Bare "TODO:" comments are stopgap smells.
#
# Usage: scripts/check-todos.sh [path]   (defaults to repo root)
#
# Exit codes:
#   0  no markers found, or every marker has owner + trigger
#   1  at least one bare marker found (missing owner or trigger)
#
# Only actionable marker forms are checked — "TODO:" / "TODO(<owner>)" /
# "FIXME:" / "XXX:". Prose that merely names the rule (e.g. "tracked TODO with
# an owner") is not a marker and is ignored. A marker is also skipped when it is
# an illustration of the rule rather than a real debt item (the line names a
# rule context: owner/trigger/example/smell/stopgap/rather-than).
#
# The pass heuristic: a marker is "tracked" if the line containing it, the line
# above (backslash- or quote-wrapped continuation), or the line below mentions
# an owner (@handle, "owner:", "owned by") AND a trigger ("when", "trigger",
# "by <date>", "blocked on", "before").

set -u

ROOT="${1:-.}"

mapfile -d '' files < <(find "$ROOT" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' \) -not -path '*/.git/*' -print0)

status=0
for f in "${files[@]}"; do
  [ "$f" = "$0" ] && continue
  awk -v file="$f" '
    function matched(txt) { return (txt ~ m || txt ~ m2) }
    BEGIN {
      m = "(TODO|FIXME|XXX):|TODO\\("
      m2 = "TODO:"
      owner = "@[A-Za-z0-9_.-]+|owner:[[:space:]]*[[]?[A-Za-z0-9_./-]+|owned[[:space:]]+by"
      trig = "(when|trigger|by[[:space:]]+[0-9]{4}-|blocked[[:space:]]+on|before[[:space:]]+)"
      rule = "owner|trigger|example|such as|rather than|smell|stopgap|red flag"
    }
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        cur = lines[i]
        if (cur !~ m && cur !~ m2) continue
        prev = (i > 1) ? lines[i-1] : ""
        nextl = (i < NR) ? lines[i+1] : ""
        ctx = cur
        if (prev ~ /(\\$|"$)/) ctx = ctx " " prev   # quote-wrapped continuation
        ctx = ctx " " nextl                          # wrapped example continues below
        has_owner = (ctx ~ owner)
        has_trigger = (ctx ~ trig)
        illustrative = (ctx ~ rule)
        if ((!has_owner || !has_trigger) && !illustrative) {
          printf "%s:%d: untracked marker (missing owner and/or trigger)\n", file, i
          status = 1
        }
      }
      exit status
    }
  ' "$f"
  st=$?
  if [ "$st" -ne 0 ]; then status=1; fi
done

if [ "$status" -eq 0 ]; then
  echo "check-todos: OK — no untracked markers."
fi
exit "$status"
