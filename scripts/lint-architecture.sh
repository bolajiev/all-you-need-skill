#!/usr/bin/env bash
# lint-architecture.sh — validate the skill tree and the repo docs against the
# skill's own rules:
#
#   1. Every core/ and references/ markdown file follows the 8-section
#      template (templates/skill-file-template.md).
#   2. Every file has a Section 7 ("If a shortcut is genuinely necessary").
#   3. Every "See also" / "Escalates to" cross-reference points at a file that
#      actually exists in the skill tree.
#   4. No file in core/ or references/ exceeds the ~150-line budget.
#   5. ADR files (docs/adr/*.md) follow templates/adr-template.md and carry a
#      Deliberate Debt field.
#
# Usage: scripts/lint-architecture.sh [skill-root]
#
# Exit codes: 0 = clean, 1 = one or more violations found.

set -u

ROOT="${1:-.}"
SKILL_ROOT="${ROOT}/all-you-need-skill"
LINE_BUDGET=150
status=0

# Repo-level docs referenced conditionally (e.g. "read any CONTRIBUTING.md").
# These live in the consumer repo, not the skill tree, so a missing skill file
# is not an error. Extend only for files the skill means to read from the repo.
ALLOW_REPO_DOCS='CONTRIBUTING.md|README.md'

say() { printf 'lint-architecture: %s\n' "$*"; }

fail() { say "FAIL: $*"; status=1; }

# -- 1/2. structural check on core/ and references/ ---------------------------
for f in $(find "$SKILL_ROOT/core" "$SKILL_ROOT/references" -name '*.md' 2>/dev/null | sort); do
  rel="${f#"$SKILL_ROOT"/}"
  # Required section headers in order.
  for sec in '### 1. Rule' '### 2. Why this matters' '### 3. Decision checklist' \
             '### 4. Default pattern' '### 5. When the default' \
             '### 6. Red flags' '### 7. If a shortcut' '### 8. Cross-references'; do
    grep -qF "$sec" "$f" || fail "$rel is missing section: $sec"
  done
  grep -q '^\*\*Tier:\*\*' "$f" || fail "$rel is missing **Tier:** line"
  grep -q '^\*\*Applies to:\*\*' "$f" || fail "$rel is missing **Applies to:** line"

  # 4. line budget (only the longest relevant body matters; skip the budget
  # check if the file legitimately declares a larger one).
  lines=$(wc -l < "$f")
  if [ "$lines" -gt "$LINE_BUDGET" ]; then
    if ! grep -q "max-lines: *[0-9][0-9]*" "$f"; then
      fail "$rel is $lines lines (budget $LINE_BUDGET) — split it or declare max-lines:"
    fi
  fi
done

# -- 3. cross-reference integrity ---------------------------------------------
# Resolves a backticked `.md` reference against the skill tree. Files may use
# several conventions, all of which are valid skill-internal references:
#   core/xxx.md            -> all-you-need-skill/core/xxx.md
#   templates/, scripts/   -> direct under skill root
#   references/xxx.md      -> direct under skill root
#   architecture/xxx.md    -> shorthand for references/architecture/xxx.md
#   bare file.md           -> unique basename anywhere in the skill tree
# Any other reference (prose like CONTRIBUTING.md, http links, repo-level docs)
# is left to the human reader and not treated as a dangling skill reference.
resolve_ref() {
  local ref="$1" cand basename_glob hits
  for cand in "$SKILL_ROOT/$ref"; do
    [ -f "$cand" ] && return 0
  done
  case "$ref" in
    architecture/*|planning/*|build/*|quality/*|operations/*|agent-state/*|product/*|design/*)
      [ -f "$SKILL_ROOT/references/$ref" ] && return 0 ;;
  esac
  basename_glob="${ref##*/}"
  hits=$(find "$SKILL_ROOT" -name "$basename_glob" -not -path '*/templates/*' 2>/dev/null | wc -l)
  [ "$hits" -eq 1 ] && return 0
  return 1
}

for f in $(find "$SKILL_ROOT" -name '*.md' -not -path '*/templates/*' 2>/dev/null | sort); do
  rel="${f#"$SKILL_ROOT"/}"
  while IFS= read -r ref; do
    case "$ref" in
      '#'*|'http'*|'' ) continue ;;
      *'/'*[^0-9a-zA-Z_/.-]*|*'('*|*')'* ) continue ;;  # prose placeholders
    esac
    if printf '%s' "$ref" | grep -qE "$ALLOW_REPO_DOCS"; then continue; fi
    resolve_ref "$ref" || fail "$rel: dangling reference -> $ref"
  done < <(grep -oE '`[a-zA-Z0-9_/.-]+\.md[a-z-]*`' "$f" | tr -d '`' | sort -u)
done

# -- 5. ADR files --------------------------------------------------------------
if [ -d "$ROOT/docs/adr" ]; then
  for f in "$ROOT"/docs/adr/*.md; do
    [ -f "$f" ] || continue
    grep -qE '^- \*\*Status:\*\*' "$f" || fail "ADR $(basename "$f") missing Status"
    grep -qE '^## Why NOT' "$f"       || fail "ADR $(basename "$f") missing 'Why NOT' section"
    grep -qE 'Deliberate Debt' "$f"   || fail "ADR $(basename "$f") missing Deliberate Debt field"
  done
fi

if [ "$status" -eq 0 ]; then
  say "OK — architecture lint passed."
fi
exit "$status"
