#!/usr/bin/env bash
# markdown_render_demo.sh — build, boot, and type a document into texr
# that shows off every markdown feature: bold h1 / underlined headings,
# auto-continuing bullet lists, --- / === rule auto-fill, and the ^P
# hi-res render. Ends on the rendered preview; press ESC in the
# emulator to return to the editor.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

"$PROJECT_DIR/bin/build_and_run.sh"

"$PROJECT_DIR/bin/demos/_wait_for_ready.sh"

echo "==> typing the demo document"
osascript <<'EOF'
tell application "Virtual ]["
	-- headings: h1 renders bold + underlined, h2 underlined
	type line "# TEXR MARKDOWN DEMO"
	type line ""
	type line "## LISTS CONTINUE THEMSELVES"
	type line ""

	-- only the first item needs its marker typed; RETURN
	-- auto-starts the next, and an empty item ends the list
	type line "- BULLETS GET ROUND DOTS"
	type line "THIS LINE ONLY NEEDED RETURN"
	type line "SO DID THIS ONE"
	type line ""
	type line "* STAR MARKERS WORK TOO"
	type line ""

	type line "## RULES AUTO-FILL AND RENDER"
	type line ""
	-- the third character triggers the fill + new line itself
	type text "---"
	delay 1
	type text "==="
	delay 1
	type line ""
	type line "PLAIN TEXT AND #MIDLINE TAGS STAY PUT."

	-- flip to the hi-res render
	delay 1
	type ctrl "P"
end tell
EOF

echo "done: rendered preview is on screen (ESC returns to the editor)"
