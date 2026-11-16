#!/usr/bin/env bash
# detect-skills.sh — Lists the skills installed on this machine, one name per line.
# Usage: bash detect-skills.sh [extra-dir ...]
# Scans the usual skill folders for SKILL.md files and prints each skill's `name`.

set -euo pipefail

ROOTS=("$HOME/.claude/skills" "$HOME/.claude/plugins" "$HOME/.agents/skills" "$PWD/.claude/skills" "$@")

for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || continue
  find -L "$root" -maxdepth 8 -name SKILL.md 2>/dev/null
done | while IFS= read -r file; do
  name=$(sed -n '2,12s/^name:[[:space:]]*//p' "$file" | head -1 | tr -d '"'"'"'\r')
  [ -n "$name" ] && echo "$name"
done | sort -u
