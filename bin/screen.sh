#!/usr/bin/env bash
# screen.sh — print the text contents of the frontmost Virtual ][ machine.
# Note: inverse/flash attributes are lost; inverse blocks read as spaces.
set -euo pipefail

osascript -e 'tell application "Virtual ]["
  return content of screen text of machine 1
end tell'
