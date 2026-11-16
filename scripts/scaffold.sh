#!/usr/bin/env bash
# scaffold.sh — Creates a workshop workspace with role folders
# Usage: bash scaffold.sh <workspace-path> <comma-separated-slugs>

set -euo pipefail

WORKSPACE="$1"
SLUGS="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$SCRIPT_DIR/../roles/registry.json"

if [ -z "$WORKSPACE" ] || [ -z "$SLUGS" ]; then
  echo "Usage: bash scaffold.sh <workspace-path> <comma-separated-slugs>" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

if [ ! -f "$REGISTRY" ]; then
  echo "Error: registry.json not found at $REGISTRY" >&2
  exit 1
fi

mkdir -p "$WORKSPACE"

IFS=',' read -ra SLUG_ARRAY <<< "$SLUGS"

for slug in "${SLUG_ARRAY[@]}"; do
  slug="$(echo "$slug" | xargs)"  # trim whitespace
  folder=$(jq -r --arg s "$slug" '.[] | select(.slug == $s) | .folder' "$REGISTRY")

  if [ -z "$folder" ] || [ "$folder" = "null" ]; then
    echo "Warning: slug '$slug' not found in registry, skipping." >&2
    continue
  fi

  mkdir -p "$WORKSPACE/$folder/templates"
  mkdir -p "$WORKSPACE/$folder/scripts"
done

echo "Workspace created at: $WORKSPACE"
exit 0
