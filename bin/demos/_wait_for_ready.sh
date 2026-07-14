#!/usr/bin/env bash
# _wait_for_ready.sh — poll the emulator instead of guessing a fixed
# boot delay. Waits for the "PRESS ANY KEY" banner, dismisses it, then
# waits for the editor's status bar to confirm edloop has started.
# Shared by bin/demos/*.sh; not meant to be run standalone.
set -euo pipefail

TIMEOUT="${1:-30}"              # seconds to wait for each stage
POLL=0.5
MAX_TRIES=$(( TIMEOUT * 2 ))

wait_for() {
    local needle="$1" tries=0 screen
    while (( tries < MAX_TRIES )); do
        screen="$(osascript -e 'tell application "Virtual ][" to return content of screen text of machine 1' 2>/dev/null || true)"
        if [[ "$screen" == *"$needle"* ]]; then
            return 0
        fi
        sleep "$POLL"
        tries=$((tries + 1))
    done
    echo "==> timed out after ${TIMEOUT}s waiting for: $needle" >&2
    return 1
}

echo "==> waiting for the boot banner"
wait_for "PRESS ANY KEY"

osascript -e 'tell application "Virtual ][" to type text " "' >/dev/null

echo "==> waiting for the editor to be ready"
wait_for "TEXR 0.1 - MARKDOWN"

echo "==> texr is ready"
