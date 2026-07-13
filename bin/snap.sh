#!/usr/bin/env bash
# snap.sh — save a PNG screenshot of the frontmost Virtual ][ machine.
# Usage: bin/snap.sh [output.png]   (default: build/screen.png)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$PROJECT_DIR/build/screen.png}"
mkdir -p "$(dirname "$OUT")"

osascript -e "tell application \"Virtual ][\"
  snap screen picture of machine 1 to \"$OUT\"
end tell"
echo "$OUT"
