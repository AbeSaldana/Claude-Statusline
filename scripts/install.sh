#!/bin/bash
# Install statusline.sh into ~/.claude and point settings.json at it.
# Existing files are backed up with a timestamped .bak suffix.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
TARGET="$CLAUDE_DIR/statusline.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
STAMP=$(date +%Y%m%d-%H%M%S)

command -v jq >/dev/null || { echo "Error: jq is required (brew install jq)" >&2; exit 1; }

mkdir -p "$CLAUDE_DIR"

# 1. Copy the script
if [ -f "$TARGET" ] && ! cmp -s "$REPO_DIR/statusline.sh" "$TARGET"; then
  cp "$TARGET" "$TARGET.$STAMP.bak"
  echo "Backed up existing script -> $TARGET.$STAMP.bak"
fi
cp "$REPO_DIR/statusline.sh" "$TARGET"
chmod +x "$TARGET"
echo "Installed $TARGET"

# 2. Add/replace the statusLine key in settings.json, keeping all other keys
status_line='{"type":"command","command":"bash ~/.claude/statusline.sh"}'
if [ -f "$SETTINGS" ]; then
  current=$(jq -c '.statusLine // empty' "$SETTINGS")
  if [ "$current" = "$(jq -c . <<<"$status_line")" ]; then
    echo "settings.json already configured"
  else
    cp "$SETTINGS" "$SETTINGS.$STAMP.bak"
    echo "Backed up settings -> $SETTINGS.$STAMP.bak"
    tmp=$(mktemp)
    jq --argjson sl "$status_line" '.statusLine = $sl' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    echo "Updated statusLine in $SETTINGS"
  fi
else
  jq -n --argjson sl "$status_line" '{statusLine: $sl}' > "$SETTINGS"
  echo "Created $SETTINGS"
fi

echo "Done. The status line refreshes automatically in Claude Code."
