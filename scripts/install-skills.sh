#!/usr/bin/env bash
# install-skills.sh — Copies the bundled skills into your skills folder.
# Usage: bash install-skills.sh [target-dir]   (default: ~/.claude/skills)
# Skills that already exist in the target are left untouched.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="$SCRIPT_DIR/../skills"
TARGET="${1:-$HOME/.claude/skills}"

mkdir -p "$TARGET"
installed=0; skipped=0

for skill in "$BUNDLE"/*/*/; do
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"
  source_dir="$(dirname "$skill")"
  if [ -e "$TARGET/$name" ]; then
    skipped=$((skipped + 1))
    continue
  fi
  cp -R "$skill" "$TARGET/$name"
  # keep the original license and source note with every installed skill
  for f in "$source_dir"/LICENSE* "$source_dir"/NOTICE* "$source_dir"/SOURCE.md; do
    [ -f "$f" ] && [ ! -e "$TARGET/$name/$(basename "$f")" ] && cp "$f" "$TARGET/$name/"
  done
  installed=$((installed + 1))
done

echo "Installed: $installed   Already present (skipped): $skipped   Target: $TARGET"
