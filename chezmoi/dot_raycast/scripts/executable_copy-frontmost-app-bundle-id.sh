#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Frontmost App Bundle ID
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📦
# @raycast.packageName macOS Utilities

# Documentation:
# @raycast.description Copy the frontmost application's Bundle ID to clipboard

bundle_id=$(
  osascript <<'APPLESCRIPT'
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  return bundle identifier of frontApp
end tell
APPLESCRIPT
)

if [ -z "$bundle_id" ]; then
  echo "Unable to get Bundle ID"
  exit 1
fi

printf '%s' "$bundle_id" | pbcopy

echo "Copied: $bundle_id"
