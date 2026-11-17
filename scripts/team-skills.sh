#!/usr/bin/env bash
# team-skills.sh — Prints the skills for the given roles, and where each bundled copy lives.
# Usage: bash team-skills.sh <role-slug> [role-slug ...]
# Output, one line per role:  slug: skill [bundled: path under the skill folder], ...
# Only the first MAX_SKILLS skills per role are printed (default 4), in priority order.

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: bash team-skills.sh <role-slug> [role-slug ...]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAX="${MAX_SKILLS:-4}"

for slug in "$@"; do
  line=$(grep -E "^${slug}: " "$ROOT/roles/skills.txt" || true)
  if [ -z "$line" ]; then
    echo "$slug: (unknown role)" >&2
    continue
  fi
  out=""
  IFS=',' read -ra names <<< "${line#*: }"
  for name in "${names[@]:0:$MAX}"; do
    name="$(echo "$name" | xargs)"
    bare="${name##*:}"
    bundled=$(ls -d "$ROOT"/skills/*/"$bare" 2>/dev/null | head -1 || true)
    if [ -n "$bundled" ]; then
      out+="$name [bundled: ${bundled#"$ROOT"/}/SKILL.md], "
    else
      out+="$name, "
    fi
  done
  echo "$slug: ${out%, }"
done
