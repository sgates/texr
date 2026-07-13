# texr

A markdown-first text editor for the Apple ][+ (48K + Language Card),
written in 6502 assembly, cross-developed with cc65 and tested in
Virtual ][ before going to real hardware via ADTPro.

The Apple ][ can't render font effects, so texr instead treats markdown
*syntax* as a first-class citizen: files are plain markdown, ready for
any modern renderer, and the editor actively assists with the syntax.
First such feature: typing `---` or `===` at the start of an empty line
auto-fills the rule to the right margin and advances to the next line.

## Editor keys

    ESC           help popup (ESC again closes; ctrl-? also opens on a //e)
    RETURN        new line; on a "- " / "* " list item the next line
                  auto-starts with the same marker, and RETURN on an
                  empty item removes the marker and ends the list
    left/right    move cursor
    ^J / ^K       cursor down / up (also //e up/down arrows)
    ^D            backspace: delete char left of cursor, pull line left
    ^P            hi-res preview: renders the document at 280x192 with a
                  5x7 software font (ESC returns to the editor).
                  Markdown is rendered, not echoed:
                    - "- " / "* " items get round bullet dots
                    - "---" becomes a solid pixel rule, "===" a double rule
                    - "# " headings drop their markers and are underlined;
                      h1 ("# ") is also rendered bold by double-striking
                      each glyph one pixel apart
    ^Q            quit to DOS
    printables    insert (shifts the rest of the line right)

## Layout

    bin/bootstrap.sh      check toolchain; offers to install what's missing
    bin/build.sh          assemble src/ and produce a bootable build/texr.dsk
    bin/build_and_run.sh  build, then (re)boot the disk in Virtual ][
    bin/screen.sh         print the emulator's text screen to stdout
    bin/snap.sh [out]     save a PNG screenshot of the emulator screen
    src/main.s            entry point + shared routines (ca65 syntax)
    src/defs.inc          constants, zero-page map, text macros
    src/banner.s          splash screen
    src/editor.s          editor main loop
    src/hgr.s             hi-res preview renderer (7x8 cells, 40x24)
    src/font.s            5x7 font as editable # art, ASCII $20-$5F
    disks/template.dsk    bootable DOS 3.3 template (copied from System Master)
    tools/                AppleCommander CLI jar (downloaded by bootstrap)
    build/                outputs: texr.bin, texr.lst, texr.dsk

## Workflow

    bin/bootstrap.sh      # once, or whenever tools change
    bin/build_and_run.sh  # edit -> build -> boot loop

The generated `build/texr.dsk` boots DOS 3.3 and its `HELLO` greeting does
`BRUN TEXR`, so the program runs automatically at power-on. The same image
can be transferred to a real floppy with ADTPro.

## Memory notes

- Program ORG is `$6000` (set in `bin/build.sh`), safely below DOS 3.3 at `$9600`.
- Text page 1 lives at `$0400-$07FF` with interleaved rows:
  `base = $400 + (row mod 8) * $80 + (row div 8) * $28`.
- The Language Card gives 16K of bank-switched RAM at `$D000-$FFFF`
  (soft switches `$C080-$C08F`) — planned home for the document buffer.
