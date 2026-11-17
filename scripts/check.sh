#!/usr/bin/env bash
# check.sh — Validates the role table and the skill list. Exits 1 on any problem.
# Usage: bash check.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0
fail() { echo "ERROR: $1" >&2; errors=$((errors + 1)); }

roles=0
while IFS='|' read -r slug name dept size manager keywords; do
  slug="$(echo "$slug" | xargs)"; dept="$(echo "$dept" | xargs)"; size="$(echo "$size" | xargs)"
  case "$slug" in ''|\#*) continue ;; esac
  roles=$((roles + 1))
  [ -f "$ROOT/roles/$dept/$slug.md" ] || fail "$slug: missing role file roles/$dept/$slug.md"
  case "$size" in small|medium|large) ;; *) fail "$slug: bad min_size '$size'" ;; esac
  [ -n "$(echo "$keywords" | xargs)" ] || fail "$slug: no keywords"
  grep -q "^${slug}: " "$ROOT/roles/skills.txt" || fail "$slug: no line in roles/skills.txt"
done < "$ROOT/roles/roles.tsv"

grep -q " | manager | " "$ROOT/roles/roles.tsv" || fail "no manager role defined"

echo "Checked $roles roles, $errors error(s)."
[ "$errors" -eq 0 ]
