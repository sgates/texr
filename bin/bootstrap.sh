#!/usr/bin/env bash
# bootstrap.sh — verify the texr toolchain, offer to install anything missing.
#
# Checks:
#   1. Homebrew            (installer for everything else)
#   2. cc65 (ca65/cl65)    6502 cross-assembler          [brew install cc65]
#   3. Java runtime        needed to run AppleCommander  [brew install --cask temurin]
#   4. AppleCommander jar  disk-image tool               [direct download -- no brew formula]
#   5. Virtual ][          emulator                      [manual install -- paid app]
#   6. disks/template.dsk  bootable DOS 3.3 template     [copied from the System Master image]
#
# Usage: bin/bootstrap.sh [--yes]     (--yes skips the confirmation prompt)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS_DIR="$PROJECT_DIR/tools"

AC_VERSION="13.1"
AC_JAR="$TOOLS_DIR/AppleCommander-ac-${AC_VERSION}.jar"
AC_URL="https://github.com/AppleCommander/AppleCommander/releases/download/${AC_VERSION}/AppleCommander-ac-${AC_VERSION}.jar"

TEMPLATE_DSK="$PROJECT_DIR/disks/template.dsk"
SYSTEM_MASTER="$PROJECT_DIR/../DOS 3.3 System Master - 680-0210-A (1982).dsk"

ASSUME_YES=0
[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && ASSUME_YES=1

ok()   { printf '  \033[32m[ok]\033[0m      %s\n' "$1"; }
miss() { printf '  \033[31m[missing]\033[0m %s\n' "$1"; }
note() { printf '  \033[33m[note]\033[0m    %s\n' "$1"; }

MISSING=()          # names of things we can install automatically
MANUAL=()           # things the user has to handle themselves

echo "texr toolchain check"
echo "--------------------"

# 1. Homebrew
if command -v brew >/dev/null 2>&1; then
    ok "Homebrew ($(command -v brew))"
    HAVE_BREW=1
else
    miss "Homebrew"
    MANUAL+=("Homebrew: install from https://brew.sh, then re-run this script")
    HAVE_BREW=0
fi

# 2. cc65
if command -v cl65 >/dev/null 2>&1 && command -v ca65 >/dev/null 2>&1; then
    ok "cc65 ($(ca65 --version 2>&1 | head -1))"
else
    miss "cc65 (ca65/cl65 assembler + linker)"
    MISSING+=("cc65")
fi

# 3. Java (for AppleCommander)
if command -v java >/dev/null 2>&1; then
    ok "Java ($(java -version 2>&1 | head -1))"
else
    miss "Java runtime (needed by AppleCommander)"
    MISSING+=("java")
fi

# 4. AppleCommander CLI jar
if [[ -f "$AC_JAR" ]]; then
    ok "AppleCommander $AC_VERSION ($AC_JAR)"
else
    miss "AppleCommander CLI jar (no Homebrew formula; downloaded from GitHub)"
    MISSING+=("applecommander")
fi

# 5. Virtual ][ emulator
if [[ -d "/Applications/Virtual ][.app" ]]; then
    ok "Virtual ][ (/Applications/Virtual ][.app)"
else
    miss "Virtual ][ emulator"
    MANUAL+=("Virtual ][: paid app, install from https://www.virtualii.com")
fi

# 6. Bootable DOS 3.3 template disk
if [[ -f "$TEMPLATE_DSK" ]]; then
    ok "DOS 3.3 template disk (disks/template.dsk)"
elif [[ -f "$SYSTEM_MASTER" ]]; then
    miss "DOS 3.3 template disk (will copy from your System Master image)"
    MISSING+=("template")
else
    miss "DOS 3.3 template disk"
    MANUAL+=("template disk: copy any bootable DOS 3.3 .dsk to disks/template.dsk")
fi

echo

# Report things we can't fix automatically.
if [[ ${#MANUAL[@]} -gt 0 ]]; then
    echo "Needs manual attention:"
    for m in "${MANUAL[@]}"; do note "$m"; done
    echo
fi

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All installable tools are present. You're ready: run bin/build_and_run.sh"
    exit 0
fi

echo "Missing but installable: ${MISSING[*]}"
if [[ $ASSUME_YES -eq 0 ]]; then
    read -r -p "Install now? [y/N] " answer
    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Skipped. Re-run bin/bootstrap.sh when ready."; exit 1 ;;
    esac
fi

for item in "${MISSING[@]}"; do
    case "$item" in
        cc65)
            [[ $HAVE_BREW -eq 1 ]] || { echo "Cannot install cc65 without Homebrew."; exit 1; }
            echo "==> brew install cc65"
            brew install cc65
            ;;
        java)
            [[ $HAVE_BREW -eq 1 ]] || { echo "Cannot install Java without Homebrew."; exit 1; }
            echo "==> brew install --cask temurin"
            brew install --cask temurin
            ;;
        applecommander)
            echo "==> downloading AppleCommander $AC_VERSION"
            mkdir -p "$TOOLS_DIR"
            curl -fL --progress-bar -o "$AC_JAR" "$AC_URL"
            ;;
        template)
            echo "==> copying DOS 3.3 System Master to disks/template.dsk"
            mkdir -p "$PROJECT_DIR/disks"
            cp "$SYSTEM_MASTER" "$TEMPLATE_DSK"
            ;;
    esac
done

echo
echo "Bootstrap complete. Build with bin/build.sh, or build and boot with bin/build_and_run.sh"
