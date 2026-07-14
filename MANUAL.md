```
 _____________________________________________________________________
|                                                                     |
|                                                                     |
|                #####  #####  #   #  ####                            |
|                  #    #       # #   #   #                           |
|                  #    ####     #    ####                            |
|                  #    #       # #   # #                             |
|                  #    #####  #   #  #  #                            |
|                  ===================================                |
|                                                                     |
|                A MARKDOWN TEXT EDITOR                               |
|                FOR THE APPLE ][ PLUS                                |
|                                                                     |
|                USER MANUAL  .  VERSION 0.1                          |
|                                                                     |
|                REQUIRES: APPLE ][ PLUS OR LATER, 48K,               |
|                ONE DISK DRIVE, DOS 3.3                              |
|_____________________________________________________________________|
```

> TEXR IS A FULL-SCREEN TEXT EDITOR THAT SPEAKS MARKDOWN. THE FILES
> IT WRITES ARE ORDINARY TEXT FILES THAT ANY COMPUTER — TODAY'S OR
> TOMORROW'S — CAN READ. NO CONVERSION. NO SPECIAL FORMAT. THAT IS
> THE WHOLE IDEA.

---

## CONTENTS

1.  [GETTING STARTED](#1-getting-started)
2.  [THE EDITING SCREEN](#2-the-editing-screen)
3.  [TYPING AND EDITING](#3-typing-and-editing)
4.  [MARKDOWN, AND HOW TEXR HELPS](#4-markdown-and-how-texr-helps)
5.  [THE HI-RES PREVIEW](#5-the-hi-res-preview)
6.  [SAVING YOUR WORK](#6-saving-your-work)
7.  [LOADING A DOCUMENT](#7-loading-a-document)
8.  [COMMAND SUMMARY CARD](#8-command-summary-card)
9.  [IN CASE OF DIFFICULTY](#9-in-case-of-difficulty)
10. [APPENDIX A: MARKDOWN QUICK REFERENCE](#appendix-a-markdown-quick-reference)
11. [APPENDIX B: TECHNICAL NOTES](#appendix-b-technical-notes)

---

## 1. GETTING STARTED

Insert the TEXR diskette in drive 1, close the door, and switch on
the computer. The disk boots DOS 3.3 and starts TEXR by itself. In a
few seconds you will see the title screen.

From the title screen:

    PRESS ANY KEY .... begin with an empty document
    PRESS CTRL-D ..... begin with the built-in demonstration
                       document already loaded -- the fastest
                       way to see what TEXR can do
    PRESS ESC ........ (once you are in the editor) opens the
                       help screen at any time

If you keep your documents on a second diskette, put it in drive 2
before you begin. A data diskette is any ordinary DOS 3.3 formatted
diskette — TEXR does not require anything special.

**TRY THIS FIRST:** press CTRL-D at the title screen, then press
CTRL-P. You are looking at a markdown document, typeset on your
Apple's hi-res screen. Press ESC to come back. Everything you just
saw is explained in the chapters that follow.

## 2. THE EDITING SCREEN

The top 23 lines of the screen show your document. The bottom line
is the STATUS BAR. It shows the program name and the line and column
the cursor is on, counted from 1:

     TEXR 0.1 - MARKDOWN - LN  1  COL  1

A document may be up to 99 LINES of 40 COLUMNS. The screen is a
window onto it: move the cursor past the top or bottom edge and the
window slides. The LN readout always tells you where you really are.

Press CTRL-N and TEXR draws LINE NUMBERS down the left edge. The
numbers borrow three columns from the display, so the last three
columns of each line are hidden while numbers are shown — they are
still in your document, only tucked out of sight. CTRL-N again turns
numbers off.

The Apple ][ plus displays capitals only, and so TEXR works in
capitals. Your documents are no less markdown for it.

## 3. TYPING AND EDITING

TEXR always INSERTS. Characters you type push the rest of the line
to the right; a character pushed past column 40 is lost, so keep an
eye on long lines. Typing in the last column carries you to the next
line.

MOVING AROUND:

    LEFT / RIGHT ARROW ... one column (wrapping at line ends)
    CTRL-J ............... down one line
    CTRL-K ............... up one line

(On an Apple //e or later, the up and down arrow keys work too.)

THE RETURN KEY splits the line at the cursor. Everything from the
cursor to the end of the line moves to a new line inserted below,
and the lines beneath it shuffle down. Press RETURN at the start of
a line to open a blank line above it. If your document already fills
all 99 lines, the last line falls off the end — TEXR will not split
when the cursor is on line 99 itself.

THE DELETE KEY (CTRL-D) is a backspace: it removes the character to
the LEFT of the cursor and pulls the line together, so you can rub
out a mistake and retype it without touching the arrow keys.

At column 1, CTRL-D JOINS the line onto the end of the line above,
with the cursor left at the seam. If the two lines together will not
fit in 40 columns, TEXR refuses and nothing is changed.

(CTRL-D on a completely empty document loads the demonstration
instead — the same one the title screen offers.)

## 4. MARKDOWN, AND HOW TEXR HELPS

Markdown is plain text with a little punctuation that any modern
computer can typeset: `#` for headings, `-` for list items, `---`
for a dividing rule. You could type it all yourself. TEXR lends a
hand:

RULE LINES. On an empty line, type `---` or `===`. The moment you
type the third character, TEXR fills the line to the margin and
moves you to the next line. (A `===` under a line of text is also
how markdown marks a top-level heading — the title screen does it.)

LISTS CONTINUE THEMSELVES. Begin a line with `- ` or `* ` and write
your item. When you press RETURN, the next line starts with the same
marker, ready for the next item. To end the list, press RETURN on an
item with nothing in it: the marker is erased and you stay put.

HEADINGS are typed the ordinary markdown way — `# TITLE` for the
largest, `## SECTION`, and so on to `######`. TEXR does not decorate
them on the text screen (the file must stay plain), but the preview
gives them their due. Which brings us to —

## 5. THE HI-RES PREVIEW

Press CTRL-P and TEXR typesets the visible window of your document
on the hi-res graphics screen, with a proper font and real markdown
rendering:

    # HEADING ......... bold lettering, underlined, marker gone
    ## TO ###### ...... underlined, marker gone
    - ITEM / * ITEM ... indented, with a round bullet dot
    ---  ............. a solid rule, drawn as a line of pixels
    ===  ............. a double rule
    ANYTHING ELSE ..... plain text, exactly as typed

Headings get a line of breathing room above and below, so they read
like headings even when you typed them snug. A `#` in the middle of
a sentence is left alone — only `#` at the start of a line, followed
by a space, makes a heading.

Press ESC to return to the editor. The preview shows the 23 lines
the window is on; scroll and press CTRL-P again to proof the rest.

## 6. SAVING YOUR WORK

Press CTRL-S. The status bar becomes a prompt:

    SAVE:

Type a name — letters and digits, up to 20 characters — and press
RETURN. ESC changes your mind; CTRL-D or the left arrow rubs out a
character.

TEXR adds **.MD** to the name automatically (`NOTES` is saved as
`NOTES.MD`). That suffix is how TEXR recognizes its own documents
later. On the diskette, the file is a standard DOS 3.3 TEXT file:
`CATALOG` shows it, `EXEC` and BASIC can read it, and carried to a
modern computer it is a readable markdown file, byte for byte.

TO SAVE ON DRIVE 2, add the usual DOS drive suffix to the name:

    SAVE: NOTES,D2

DOS remembers the drive you used last, in the ordinary DOS way. Say
`,D1` when you want the boot drive again.

Saving replaces a file of the same name without complaint — TEXR
assumes you meant it. Trailing blanks are trimmed from each line and
blank lines are kept, so what you wrote is what is on the disk.

## 7. LOADING A DOCUMENT

Press CTRL-O and TEXR reads the diskette's catalog itself — no need
to quit and run CATALOG. A window opens listing every TEXR document
(that is, every TEXT file ending in `.MD`) on the drive:

     ______________________________________
    |  LOAD .MD FILE   DRIVE 2             |
    |                                      |
    |  NOTES.MD          <- highlighted    |
    |  SHOPPING.MD                         |
    |  CHAPTER1.MD                         |
    |                                      |
    |  RETURN LOADS - ESC - 1/2 DRIVE      |
    |______________________________________|

    CTRL-J / CTRL-K or the ARROW KEYS move the highlight
    RETURN .... loads the highlighted document
    1 or 2 .... shows that drive instead (drive 2 first,
                since that is where documents usually live)
    ESC ....... closes the window, document untouched

Loading replaces the document in memory — save first if it matters.
The window lists up to 13 documents. Files from other programs, and
text files without the `.MD` ending, are not shown.

A document longer than the editor's 99 lines is cut off at 99.
Lines longer than 40 columns are wrapped. Small letters are shown as
capitals, which is all the ][ plus can display.

## 8. COMMAND SUMMARY CARD

Clip and keep. Or simply press ESC — the same card lives in the
program.

    -------------- CURSOR ---------------
    LEFT / RIGHT ARROW    move one column
    CTRL-J / CTRL-K       down / up one line

    -------------- EDITING --------------
    (TYPING)              inserts at the cursor
    RETURN                split line / new line;
                          continues - and * lists
    CTRL-D                backspace; at column 1,
                          joins onto the line above
    --- OR ===            on an empty line: fills
                          the rule to the margin

    -------------- SCREENS --------------
    ESC                   help card (ESC closes)
    CTRL-P                hi-res markdown preview
    CTRL-N                line numbers on / off

    -------------- DISKETTE -------------
    CTRL-S                save  (adds .MD; ,D2 for
                          drive 2)
    CTRL-O                pick and load a document
    CTRL-Q                quit (restarts the disk)

    -------------- SPECIAL --------------
    CTRL-D                on an empty document (or at
                          the title screen): load the
                          demonstration document

## 9. IN CASE OF DIFFICULTY

**THE SCREEN SAYS `DISK ERROR n - PRESS ANY KEY`.** DOS reported a
problem and TEXR caught it; press a key and carry on. The number
tells you what went wrong:

    NO. | MEANING           | WHAT TO DO
    ----|-------------------|--------------------------------
     4  | WRITE PROTECTED   | remove the write-protect tab
     6  | FILE NOT FOUND    | check the name and the drive
     8  | I/O ERROR         | door open? diskette in? seated
        |                   | squarely? not formatted?
     9  | DISK FULL         | use another diskette
    10  | FILE LOCKED       | UNLOCK it from BASIC first
    11  | SYNTAX ERROR      | a character in the name that
        |                   | DOS does not allow

**MY FILE DOES NOT APPEAR IN THE CTRL-O WINDOW.** The window shows
TEXT files whose names end in `.MD`. A document saved by another
program (or by an early TEXR) can be renamed from BASIC:

    RENAME OLDFILE,OLDFILE.MD

**IT SAYS `NO .MD FILES ON THIS DRIVE`.** You are probably looking
at the wrong drive — press 1 or 2.

**CTRL-D WILL NOT JOIN TWO LINES.** Together they would be wider
than 40 columns. Shorten one first.

**I PRESSED CTRL-Q AND THE MACHINE REBOOTED.** It is supposed to.
See the note in Appendix B.

**THE LAST FEW COLUMNS OF MY LINES HAVE VANISHED.** Line numbers
are on. Press CTRL-N; the columns were never gone.

## APPENDIX A: MARKDOWN QUICK REFERENCE

The subset of markdown that TEXR assists with and typesets:

    YOU TYPE                 THE PREVIEW SHOWS
    ------------------------ -------------------------------
    # PROJECT PLAN           bold underlined heading
    ## THIS WEEK             underlined heading
    - MILK                   indented, round bullet dot
    * ALSO WORKS             indented, round bullet dot
    ---                      a solid dividing rule
    ===                      a double dividing rule
    PLAIN TEXT               plain text

Anything else you type is preserved untouched — TEXR never rewrites
your words. A modern markdown renderer will happily accept the whole
file and add its own refinements (real bold, proportional type,
colour) that no 1979 television set was ever asked to produce.

## APPENDIX B: TECHNICAL NOTES

FOR THE CURIOUS AND THE ADVANCED USER.

**FILE FORMAT.** A TEXR document is a DOS 3.3 sequential TEXT file:
each line is high-bit ASCII ended by a carriage return; trailing
spaces are trimmed; blank lines are preserved. Strip the high bit
and swap CR for LF and you have a UTF-8-clean markdown file — which
is exactly what a modern disk-image tool (AppleCommander and its
kin) does when it exports one.

**CAPACITY.** 99 lines of 40 columns (3,960 characters). The editor
holds the document at $4000-$4F77; the program lives at $6000 and
stays clear of DOS at $9600.

**THE CATALOG WINDOW** reads the diskette directly through RWTS —
track $11, where DOS 3.3 keeps its catalog — rather than parsing
CATALOG's screen output. It lists the first 13 matching files.

**DISK ERRORS** are intercepted from DOS's own error handler for
the duration of a disk operation, which is why a bad diskette lands
you back in the editor rather than at a BASIC prompt with your
document lost.

**CTRL-Q REBOOTS** because DOS 3.3 cannot survive a machine-language
program returning to it once that program has used the file
commands; the polite exit is a fresh boot, a convention TEXR shares
with most application software of its era. Save first.

**THE DEMONSTRATION DOCUMENT** is built into the program and costs
you nothing on the diskette.

---

```
 _____________________________________________________________________
|                                                                     |
|   TEXR IS BUILT WITH CC65 AND TESTED ON REAL AND EMULATED APPLE     |
|   HARDWARE. THIS MANUAL IS ITSELF A MARKDOWN DOCUMENT -- OPEN IT    |
|   IN A MODERN RENDERER AND IT TYPESETS, WHICH IS RATHER THE POINT.  |
|_____________________________________________________________________|
```
