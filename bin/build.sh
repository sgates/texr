#!/usr/bin/env bash
# build.sh — assemble texr and produce a bootable DOS 3.3 disk image.
#
# Output:
#   build/texr.bin   raw 6502 binary (ORG $6000)
#   build/texr.dsk   bootable disk: boots DOS 3.3, HELLO does BRUN TEXR
#
# The .dsk works in Virtual ][ directly and can go to real hardware via ADTPro.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
AC_JAR="$(ls "$PROJECT_DIR"/tools/AppleCommander-ac-*.jar 2>/dev/null | sort | tail -1 || true)"
TEMPLATE_DSK="$PROJECT_DIR/disks/template.dsk"

START_ADDR=0x6000

# Friendly guard: point at bootstrap instead of failing cryptically.
for need in cl65 java; do
    command -v "$need" >/dev/null 2>&1 || { echo "error: '$need' not found -- run bin/bootstrap.sh first" >&2; exit 1; }
done
[[ -n "$AC_JAR" && -f "$AC_JAR" ]] || { echo "error: AppleCommander jar not found -- run bin/bootstrap.sh first" >&2; exit 1; }
[[ -f "$TEMPLATE_DSK" ]] || { echo "error: disks/template.dsk not found -- run bin/bootstrap.sh first" >&2; exit 1; }

ac() { java -jar "$AC_JAR" "$@"; }

mkdir -p "$BUILD_DIR"

echo "==> assembling src/main.s (ORG $START_ADDR)"
cl65 -t none --start-addr "$START_ADDR" \
     --asm-include-dir "$PROJECT_DIR/src" \
     -o "$BUILD_DIR/texr.bin" \
     -l "$BUILD_DIR/texr.lst" \
     "$PROJECT_DIR/src/main.s"
rm -f "$PROJECT_DIR/src/main.o"
echo "    $(stat -f%z "$BUILD_DIR/texr.bin") bytes"

echo "==> building disk image"
cp "$TEMPLATE_DSK" "$BUILD_DIR/texr.dsk"

# Replace the greeting program with: 10 PRINT CHR$(4);"BRUN TEXR"
# (pre-tokenized Applesoft, load address $0801)
ac -d "$BUILD_DIR/texr.dsk" HELLO 2>/dev/null || true
printf '\x17\x08\x0a\x00\xba\xe7\x28\x34\x29\x3b\x22\x42\x52\x55\x4e\x20\x54\x45\x58\x52\x22\x00\x00\x00' \
    | ac -p "$BUILD_DIR/texr.dsk" HELLO A

# Our binary, with its load address in the DOS file header.
ac -d "$BUILD_DIR/texr.dsk" TEXR 2>/dev/null || true
ac -p "$BUILD_DIR/texr.dsk" TEXR B "$START_ADDR" < "$BUILD_DIR/texr.bin"

echo "==> catalog of build/texr.dsk"
ac -l "$BUILD_DIR/texr.dsk" | grep -E 'TEXR|HELLO' || true

echo "done: build/texr.dsk"
