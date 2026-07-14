# texr milestones

Working log of shipped and planned milestones. Newest work at the
bottom of each section; check a box when the feature is verified
running in the emulator (see README workflow).

## Completed

- [x] **M1 — Toolchain & project skeleton** (Jul 2026)
      `bin/bootstrap.sh` (checks tools, asks before installing),
      `bin/build.sh` (cc65 assemble + bootable DOS 3.3 .dsk via
      AppleCommander, auto-BRUN HELLO), `bin/build_and_run.sh`,
      `bin/screen.sh`, `bin/snap.sh`, Virtual ][ AppleScript workflow.
- [x] **M2 — Splash banner** — block-letter TEXR, markdown-styled
      subtitle, key hints.
- [x] **M3 — Screen editor core** — screen-as-buffer (rows 0-22),
      inverse status bar with live LN/COL, insert typing, arrows,
      ^J/^K, ^D backspace, ^Q quit.
- [x] **M4 — Markdown autofill** — `---` / `===` at the start of an
      empty line fill to the margin and advance.
- [x] **M5 — Help modal** — ESC opens command reference, ESC closes.
- [x] **M6 — Hi-res preview core (^P)** — 280x192 renderer, 5x7
      software font authored as `#` art in `src/font.s`.
- [x] **M7 — Preview markdown semantics** — bullet dots for `- `/`* `,
      single/double pixel rules for `---`/`===`, headings underlined
      with markers stripped.
- [x] **M8 — Preview eye candy** — h1 bold via double-strike, indented
      bullets, blank rows around headings (decoupled output row).
- [x] **M9 — List auto-continue** — RETURN on a `- `/`* ` item starts
      the next line with the marker; RETURN on an empty item ends the
      list.
- [x] **M10 — Demo tooling** — `bin/demos/markdown_render_demo.sh`
      types a showcase document; `bin/demos/_wait_for_ready.sh` polls
      the screen instead of fixed sleeps.
- [x] **M11 — Bundled demo** — demo document baked into the binary
      (`src/demo.s`); ^D on a pristine document loads it, and ^D
      straight from the splash screen skips into the loaded demo.
      Splash + help hints added.

## Planned — document buffer refactor

The screen stops being the document; a line buffer in main RAM
($4000, 99 fixed 40-byte records) becomes the truth and the screen
becomes a scrolling 23-row window. Unlocks everything below.

- [x] **M12 — Buffer + window core** (Jul 2026) — document buffer,
      window redraw, vertical scrolling, all existing features
      repointed at the buffer (typing, autofill, lists, demo, help,
      preview). Editor feels identical until a document outgrows the
      screen. Side benefit: the help modal repaints from the buffer,
      so SCRBUF and its save/restore code are gone.
- [x] **M13 — Real line semantics** (Jul 2026) — RETURN splits the
      line at the cursor (tail moves to a fresh inserted line; lines
      below shift, line 98 falls off); RETURN on an empty list item
      erases the marker and stays put; ^D at column 0 joins onto the
      previous line with the cursor at the seam (refused when the two
      lines don't fit in 40 columns; seam clamps to col 39 on a full
      line).
- [x] **M14 — Line-number gutter (^N)** (Jul 2026) — toggleable
      3-column gutter (inverse 2-digit number + gap); document shows
      at columns 3-39 while on, so the last 3 columns are hidden.
      Display-only: the buffer stays full-width and typing/cursor
      logic is untouched (cursor draw pins to the right edge).
- [ ] **M15 — Disk save/load** — ^S save / ^O open as plain DOS 3.3
      text files (readable markdown on disk), filename prompt on the
      status row, trailing spaces stripped, long lines wrapped on load.

## Backlog / ideas

- Smart wrap: typing past column 39 should split/flow onto the next
  line instead of just hopping the cursor down

- Inline `**bold**` / `*italic*` rendered via double-strike in ^P
- Double-width h1 glyphs
- `> ` blockquotes with a margin bar in ^P
- Preview scrolling for documents taller than one hi-res screen
- Nested / indented list bullets
- Language Card ($D000-$FFFF) buffer for 400+ line documents
- Verify on real hardware via ADTPro
