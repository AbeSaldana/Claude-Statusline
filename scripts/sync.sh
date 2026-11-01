#!/bin/bash
# Copy the live ~/.claude/statusline.sh back into the repo (after editing it in place).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIVE="$HOME/.claude/statusline.sh"

[ -f "$LIVE" ] || { echo "Error: $LIVE not found" >&2; exit 1; }
if cmp -s "$LIVE" "$REPO_DIR/statusline.sh"; then
  echo "Already in sync"
else
  diff -u "$REPO_DIR/statusline.sh" "$LIVE" || true
  cp "$LIVE" "$REPO_DIR/statusline.sh"
  echo "Copied $LIVE -> statusline.sh"
fi
