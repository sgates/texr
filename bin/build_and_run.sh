#!/usr/bin/env bash
# build_and_run.sh — build the disk image and boot it in Virtual ][.
# If a machine is already open, reboot it (it re-reads the updated image);
# otherwise open the disk, which boots a new machine.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

"$PROJECT_DIR/bin/build.sh"

echo "==> booting build/texr.dsk in Virtual ]["
if osascript -e 'tell application "Virtual ]["
  if (count machines) > 0 then
    restart front machine
    return "restarted"
  end if
  error "no machine"
end tell' >/dev/null 2>&1; then
    echo "    rebooted the open machine"
else
    open -a "Virtual ][" "$PROJECT_DIR/build/texr.dsk"
fi
