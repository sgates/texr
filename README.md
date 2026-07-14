# texr

**[&#128214; User Manual](MANUAL.md)** — the full guide, written in
period style (and in markdown, naturally).

A markdown-first text editor for the Apple ][+ (48K + Language Card),
written in 6502 assembly, cross-developed with cc65 and tested in
Virtual ][ before going to real hardware via ADTPro.

The Apple ][ can't render font effects, so texr instead treats markdown
*syntax* as a first-class citizen: files are plain markdown, ready for
any modern renderer, and the editor actively assists with the syntax.
First such feature: typing `---` or `===` at the start of an empty line
auto-fills the rule to the right margin and advances to the next line.

Documents live in a 99-line buffer ($4000); the 23 text rows are a
scrolling window into it, so files can be four screens tall. See
`milestones.md` for what's shipped and what's planned.

## Editor keys

    ESC           help popup (ESC again closes; ctrl-? also opens on a //e)
    RETURN        splits the line at the cursor (at column 0 this
                  inserts a blank line above). On a "- " / "* " list
                  item the next line auto-starts with the same marker,
                  and RETURN on an empty item removes the marker and
                  ends the list
    left/right    move cursor
    ^J / ^K       cursor down / up (also //e up/down arrows)
    ^N            toggle the line-number gutter (display-only: the
                  last 3 columns of each line are hidden while it's on)
    ^D            backspace: delete char left of cursor, pull line left.
                  At column 0 the line joins onto the end of the
                  previous one (refused if the two don't fit in 40
                  columns). On a pristine (untouched) document, ^D
                  instead loads a bundled demo showcasing every
                  markdown feature. Pressing ^D to dismiss the splash
                  screen goes straight into the editor with the demo
                  already loaded — no need to dismiss the splash first
    ^P            hi-res preview: renders the document at 280x192 with a
                  5x7 software font (ESC returns to the editor).
                  Markdown is rendered, not echoed:
                    - "- " / "* " items get an indented round bullet dot
                    - "---" becomes a solid pixel rule, "===" a double rule
                    - "# " headings drop their markers, are underlined, and
                      get a blank row above and below to set them off;
                      h1 ("# ") is also rendered bold by double-striking
                      each glyph one pixel apart
    ^S            save as a plain DOS 3.3 text file (readable markdown
                  on disk): filename prompt on the status row, RETURN
                  accepts, ESC cancels. ".MD" is appended automatically
                  so texr can recognize its own documents
    ^O            file picker: lists the ".MD" text files on a drive
                  (read straight from the DOS catalog with RWTS) in a
                  modal box. ^J/^K or arrows move the highlight, RETURN
                  loads, 1 / 2 switch drives (data disk in drive 2 is
                  the default), ESC cancels. Disk errors show
                  "DISK ERROR n" and return to the editor
    ^Q            quit: reboots the disk (after file I/O, DOS 3.3
                  cannot survive a BRUN program returning, so texr
                  restarts like most period application disks)
    printables    insert (shifts the rest of the line right)

## Layout

    MANUAL.md             the user manual (period style)
    milestones.md         shipped and planned feature log
    bin/bootstrap.sh      check toolchain; offers to install what's missing
    bin/build.sh          assemble src/ and produce a bootable build/texr.dsk
    bin/build_and_run.sh  build, then (re)boot the disk in Virtual ][;
                          also creates disks/data.dsk (once) and keeps
                          it attached to drive 2 for ^S/^O
    bin/screen.sh         print the emulator's text screen to stdout
    bin/snap.sh [out]     save a PNG screenshot of the emulator screen
    bin/demos/            feature demos: markdown_render_demo.sh builds,
                          boots, types a showcase document, and ends on
                          the ^P hi-res render. _wait_for_ready.sh polls
                          the emulator's screen text every 0.5s (rather
                          than sleeping a fixed guess) for the boot
                          banner, dismisses it, then waits for the
                          editor's status bar before a demo starts typing
    src/main.s            entry point + shared routines (ca65 syntax)
    src/defs.inc          constants, zero-page map, text macros
    src/banner.s          splash screen
    src/editor.s          editor main loop
    src/hgr.s             hi-res preview renderer (7x8 cells, 40x24)
    src/font.s            5x7 font as editable # art, ASCII $20-$5F
    src/demo.s            bundled demo document, loaded by ^D on an
                          empty document (see splash screen hint)
    src/disk.s            ^S/^O DOS 3.3 text-file save/load, with a
                          patch-trap on DOS's error handler
    src/catalog.s         ^O file picker: RWTS catalog scan + modal
                          selection UI
    disks/template.dsk    bootable DOS 3.3 template (copied from System Master)
    disks/data.dsk        persistent blank data disk in drive 2; never
                          overwritten by builds, so saved docs survive
    tools/                AppleCommander CLI jar (downloaded by bootstrap)
    build/                outputs: texr.bin, texr.lst, texr.dsk

## Workflow

    bin/bootstrap.sh      # once, or whenever tools change
    bin/build_and_run.sh  # edit -> build -> boot loop

The generated `build/texr.dsk` boots DOS 3.3 and its `HELLO` greeting does
`BRUN TEXR`, so the program runs automatically at power-on. The same image
can be transferred to a real floppy with ADTPro.

Note: `bin/build.sh` recreates `build/texr.dsk` from the template, so
save documents to the drive-2 data disk instead: give ^S a filename
like `NOTES,D2`. DOS remembers the drive, so later plain names keep
using drive 2 until a `,D1` switches back. `disks/data.dsk` is created
once and never touched by builds — documents there survive rebuilds,
and the image can go to a real floppy with ADTPro.

## Memory notes

- Program ORG is `$6000` (set in `bin/build.sh`), safely below DOS 3.3 at `$9600`.
- The document buffer sits at `$4000-$4F77`: 99 fixed 40-byte line
  records of screen codes. The text page is only a view of it.
- Text page 1 lives at `$0400-$07FF` with interleaved rows:
  `base = $400 + (row mod 8) * $80 + (row div 8) * $28`.
- The Language Card gives 16K of bank-switched RAM at `$D000-$FFFF`
  (soft switches `$C080-$C08F`) — future home for 400+ line documents.
