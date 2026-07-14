; ===================================================================
; defs.inc — shared constants, zero page, macros
; ===================================================================

; --- hardware / ROM ------------------------------------------------
KBD     := $C000                ; keyboard data (high bit = key ready)
KBDSTRB := $C010                ; clear keyboard strobe
HOME    := $FC58                ; clear text screen, cursor home
REBOOT  := $C600                ; slot-6 disk boot ROM. ^Q reboots:
                                ; DOS can't survive a return from a
                                ; BRUN program that ran file commands
                                ; (its pending-command state is gone
                                ; and both RTS and the $3D0 warm entry
                                ; wedge in RWTS), so like most period
                                ; application disks we restart instead.

; --- zero page (DOS 3.3 + Monitor safe cells) ----------------------
LINEP   = $06                   ; 2 bytes: base address of cursor row
CURCOL  = $08                   ; cursor column 0-39
CURROW  = $09                   ; cursor row 0-22
SAVCHR  = $19                   ; screen char under the cursor
KEYCH   = $1A                   ; last key pressed
TMP     = $1B                   ; scratch
SRCP    = $1C                   ; 2 bytes: draw_items copy source
TMP2    = $1E                   ; scratch (draw_items table index)
HLAST   = $1F                   ; hi-res render: last non-space column
HBOLD   = $E3                   ; bit 7 set: double-strike glyphs (h1)
ORROW   = $E4                   ; hi-res render: output row (0-23),
                                ;   decoupled from CURROW for spacing
RSTEP   = $E5                   ; hi-res render: rows ORROW advances by
TOPLN   = $E6                   ; document line shown on screen row 0
DITGT   = $E7                   ; draw_items target: 0 = screen rows,
                                ;   else document buffer lines
SCRP    = $E8                   ; 2 bytes: cursor row's screen base
                                ;   (LINEP now points into the buffer)
GUTON   = $EA                   ; nonzero: line-number gutter shown
                                ;   (display-only; buffer stays 40-wide)
DSTP    = $CE                   ; 2 bytes: screen save/restore pointer
FONTP   = DSTP                  ; 2 bytes: glyph source (never live at
                                ;   the same time as a modal save)
ITEMP   = $EB                   ; 2 bytes: draw_items layout table
HPTR    = $ED                   ; 2 bytes: hi-res draw pointer
HCOL    = $EF                   ; hi-res render column

; --- document buffer -------------------------------------------------
; Fixed 40-byte line records holding screen codes, space-padded, so a
; screen row refresh is a straight copy. The text page is only a view.
DOCBUF   = $4000                ; 99 lines x 40 = 3,960 bytes ($4F78)
DOCLINES = 99                   ; 2-digit line numbers, LC can raise it
TOPMAX   = DOCLINES - 23        ; highest TOPLN (23 view rows)

; --- screen layout -------------------------------------------------
MAXROW  = 22                    ; last editable row; row 23 is status
STATROW = $07D0                 ; text page 1, row 23

; --- text macros ----------------------------------------------------
; Screen codes: normal = ASCII|$80, inverse = ASCII&$3F,
; flash = ASCII&$3F|$40 (uppercase charset only on the ][+)

.macro  htext str               ; normal video
        .repeat .strlen(str), i
        .byte   .strat(str, i) | $80
        .endrep
.endmacro

.macro  itext str               ; inverse video
        .repeat .strlen(str), i
        .byte   .strat(str, i) & $3F
        .endrep
.endmacro

.macro  ftext str               ; flashing
        .repeat .strlen(str), i
        .byte   (.strat(str, i) & $3F) | $40
        .endrep
.endmacro

.macro  brow str                ; bitmap row: '#' = inverse block
        .repeat .strlen(str), i
        .if .strat(str, i) = '#'
        .byte   $20             ; inverse space = solid block
        .else
        .byte   $A0             ; normal space
        .endif
        .endrep
.endmacro
