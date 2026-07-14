#!/usr/bin/env bash
# build_and_run.sh — build the disk image and boot it in Virtual ][.
# If a machine is already open, reboot it (it re-reads the updated image);
# otherwise open the disk, which boots a new machine.
#
# A persistent data disk (disks/data.dsk) rides in drive 2 for ^S/^O:
# it is created blank once and never overwritten by builds, so saved
# documents survive. Save to it with a ",D2" filename suffix.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DSK="$PROJECT_DIR/disks/data.dsk"
AC_JAR="$PROJECT_DIR/tools/AppleCommander-ac-13.1.jar"

"$PROJECT_DIR/bin/build.sh"

if [ ! -f "$DATA_DSK" ]; then
    echo "==> creating blank data disk (drive 2): disks/data.dsk"
    java -jar "$AC_JAR" -dos140 "$DATA_DSK"
fi

echo "==> booting build/texr.dsk in Virtual ]["
# Eject + re-insert before restarting: Virtual ][ keeps a cached copy
# of a disk once the emulated machine has written to it (e.g. ^S), and
# a plain restart would boot that stale cache instead of the new build.
if osascript >/dev/null 2>&1 <<EOF
tell application "Virtual ]["
  if (count machines) is 0 then error "no machine"
  try
    eject device "S6D1" of machine 1
  end try
  insert "$PROJECT_DIR/build/texr.dsk" into device "S6D1" of machine 1
  restart front machine
end tell
EOF
then
    echo "    rebooted the open machine (fresh disk image)"
else
    open -a "Virtual ][" "$PROJECT_DIR/build/texr.dsk"
    sleep 3
fi

echo "==> attaching data disk to drive 2"
osascript >/dev/null <<EOF
tell application "Virtual ]["
	if (disk image of device "S6D2" of machine 1) is not "$DATA_DSK" then
		try
			eject device "S6D2" of machine 1
		end try
		insert "$DATA_DSK" into device "S6D2" of machine 1
	end if
end tell
EOF
