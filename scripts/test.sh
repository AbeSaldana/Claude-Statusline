#!/bin/bash
# Render the status line for every JSON file in examples/ (or the files given as arguments).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_DIR/statusline.sh"

files=("$@")
[ ${#files[@]} -eq 0 ] && files=("$REPO_DIR"/examples/*.json)

for f in "${files[@]}"; do
  printf '\033[90m%s\033[0m\n' "$(basename "$f")"
  bash "$SCRIPT" < "$f"
  printf '\n\n'
done
