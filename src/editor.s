; ===================================================================
; editor.s — buffered editing with a scrolling window (M12)
;
; The document lives in DOCBUF (99 fixed 40-byte lines of screen
; codes); screen rows 0-22 are a window starting at line TOPLN, and
; row 23 is an inverse status bar with live line/column readout.
; LINEP points at the cursor's buffer line, SCRP at its screen row;
; edits go to the buffer and blitline repaints the row.
;
; Keys:  printables insert (shift right within the line)
;        RETURN new line       left/right arrows move
;        ^J down  ^K up        ^D delete char   ^Q quit
;
; Markdown: typing --- or === as the first three columns of an
; otherwise empty line auto-fills the rule to the right margin and
; advances to the next line.
; ===================================================================

editor_run:
        jsr     HOME
        ldy     #39             ; static status bar
@sb:    lda     statmsg,y
        sta     STATROW,y
        dey
        bpl     @sb
        lda     #0
        sta     CURCOL
        sta     CURROW
        sta     TOPLN
        sta     GUTON
        jsr     docinit
        jsr     setline
        lda     KEYCH           ; ^D on the splash: straight to the demo
        cmp     #$84
        bne     edloop
        jmp     load_demo

edloop: jsr     upd_status
        jsr     cursor_on
        jsr     getkey
        sta     KEYCH
        jsr     cursor_off
        lda     KEYCH
        cmp     #$8D            ; RETURN
        bne     :+
        jmp     do_cr
:       cmp     #$88            ; left arrow
        bne     :+
        jmp     do_left
:       cmp     #$95            ; right arrow
        bne     :+
        jmp     do_right
:       cmp     #$8B            ; ^K / up arrow
        bne     :+
        jmp     do_up
:       cmp     #$8A            ; ^J / down arrow
        bne     :+
        jmp     do_down
:       cmp     #$84            ; ^D delete
        bne     :+
        jmp     do_del
:       cmp     #$91            ; ^Q quit: reboot the disk
        bne     :+
        jsr     HOME
        jmp     REBOOT
:       cmp     #$90            ; ^P hi-res preview
        bne     :+
        jmp     do_prev
:       cmp     #$8E            ; ^N toggle line numbers
        bne     :+
        jmp     do_gut
:       cmp     #$93            ; ^S save to disk
        bne     :+
        jmp     do_save
:       cmp     #$8F            ; ^O open from disk
        bne     :+
        jmp     do_load
:       cmp     #$9B            ; ESC opens help
        bne     :+
        jmp     do_help
:       cmp     #$FF            ; ctrl-? where the keyboard has it (//e)
        bne     :+
        jmp     do_help
:       cmp     #$A0            ; printable?
        bcs     do_char
        jmp     edloop          ; ignore other control keys

; --- self-insert with markdown rule detection ----------------------
do_char:
        ldy     #39             ; open a gap: shift cols right
@shift: cpy     CURCOL
        beq     @store
        dey
        lda     (LINEP),y
        iny
        sta     (LINEP),y
        dey
        jmp     @shift
@store: lda     KEYCH
        sta     (LINEP),y
        jsr     blitline
        inc     CURCOL
        lda     CURCOL
        cmp     #40
        bcc     @rule
        jsr     crlf            ; wrap at the right margin
        jmp     edloop

@rule:  cmp     #3              ; just typed the 3rd column?
        bne     @out
        lda     KEYCH
        cmp     #('-' | $80)
        beq     @check
        cmp     #('=' | $80)
        bne     @out
@check: ldy     #2              ; cols 0-2 all the rule char...
@head:  lda     (LINEP),y
        cmp     KEYCH
        bne     @out
        dey
        bpl     @head
        ldy     #3              ; ...and nothing else on the line
@blank: lda     (LINEP),y
        cmp     #$A0
        bne     @out
        iny
        cpy     #40
        bne     @blank
        lda     KEYCH           ; auto-fill to the right margin
        ldy     #3
@fill:  sta     (LINEP),y
        iny
        cpy     #40
        bne     @fill
        jsr     blitline
        jsr     crlf
@out:   jmp     edloop

; --- RETURN: split the line at the cursor (M13) ----------------------
; The tail (cursor to col 39) moves to a fresh line inserted below;
; lines under it shift down and line 98 falls off. Markdown lists
; continue: RETURN at the end of a "- "/"* " item starts the next one
; with the same marker, and RETURN on an empty item erases the marker
; and stays put instead of inserting.
do_cr:  ldy     #0
        lda     (LINEP),y
        cmp     #('-' | $80)
        beq     @mark
        cmp     #('*' | $80)
        beq     @mark
        lda     #0              ; no list marker
        sta     TMP
        beq     @split
@mark:  sta     TMP             ; remember which marker
        ldy     #1
        lda     (LINEP),y
        cmp     #$A0
        beq     @item
        lda     #0              ; "-X..." is not a list item
        sta     TMP
        beq     @split
@item:  ldy     #2              ; any item text?
@rest:  lda     (LINEP),y
        cmp     #$A0
        bne     @split
        iny
        cpy     #40
        bne     @rest
        lda     #$A0            ; empty item: erase marker, stay put
        ldy     #1
        sta     (LINEP),y
        dey
        sta     (LINEP),y
        jsr     blitline
        lda     #0
        sta     CURCOL
        jmp     edloop

@split: lda     TOPLN           ; current document line
        clc
        adc     CURROW
        cmp     #DOCLINES-1     ; on the last line there's no room
        bcc     :+
        jmp     edloop
:       adc     #1              ; carry clear: gap goes below us
        sta     TMP2
        jsr     ins_line
        ldx     TMP2            ; DSTP = gap line - CURCOL, so the
        lda     buflo,x         ; shared Y indexes src col CURCOL..39
        sec                     ; onto dest col 0..
        sbc     CURCOL
        sta     DSTP
        lda     bufhi,x
        sbc     #0
        sta     DSTP+1
        ldy     CURCOL
@tail:  lda     (LINEP),y       ; move the tail, blanking the source
        sta     (DSTP),y
        lda     #$A0
        sta     (LINEP),y
        iny
        cpy     #40
        bne     @tail
        jsr     crlf            ; cursor onto the new line (may scroll)
        jsr     redraw          ; everything below changed
        lda     TMP             ; continue the list onto a blank line
        beq     @done
        ldy     #39
@blank: lda     (LINEP),y
        cmp     #$A0
        bne     @done
        dey
        bpl     @blank
        ldy     #0
        lda     TMP
        sta     (LINEP),y
        iny
        lda     #$A0
        sta     (LINEP),y
        jsr     blitline
        lda     #2
        sta     CURCOL
@done:  jmp     edloop

do_left:
        lda     CURCOL
        beq     @prev
        dec     CURCOL
        jmp     edloop
@prev:  lda     CURROW          ; col 0: hop to end of previous line
        beq     @scrl
        dec     CURROW
        jsr     setline
        lda     #39
        sta     CURCOL
        jmp     edloop
@scrl:  lda     TOPLN           ; row 0: scroll the window up
        beq     @stay
        dec     TOPLN
        jsr     redraw
        lda     #39
        sta     CURCOL
@stay:  jmp     edloop

do_right:
        lda     CURCOL
        cmp     #39
        bcc     @inc
        jsr     crlf            ; col 39: hop to start of next row
        jmp     edloop
@inc:   inc     CURCOL
        jmp     edloop

do_up:  lda     CURROW
        beq     @top
        dec     CURROW
        jsr     setline
        jmp     edloop
@top:   lda     TOPLN           ; row 0: scroll the window up
        beq     :+
        dec     TOPLN
        jsr     redraw
:       jmp     edloop

do_down:
        lda     CURROW
        cmp     #MAXROW
        bcs     @bot
        inc     CURROW
        jsr     setline
        jmp     edloop
@bot:   lda     TOPLN           ; row 22: scroll the window down
        cmp     #TOPMAX
        bcs     :+
        inc     TOPLN
        jsr     redraw
:       jmp     edloop

; --- help modal ------------------------------------------------------
; The modal draws straight over the window; closing just repaints the
; window from the buffer — no save/restore needed anymore.
do_help:
        lda     #0
        sta     DITGT
        lda     #<help_items
        sta     ITEMP
        lda     #>help_items
        sta     ITEMP+1
        jsr     draw_items
@wait:  jsr     getkey
        cmp     #$9B            ; ESC closes
        bne     @wait
        jsr     redraw
        jmp     edloop

; --- backspace: delete char left of cursor, pull line left ----------
; Typing immediately after lands where the deleted text was. At col 0
; the line joins onto the end of the previous one (if the two fit in
; 40 columns). On a pristine (0,0, all-blank) document, ^D instead
; loads the bundled demo — see src/demo.s.
do_del: lda     CURCOL
        beq     :+
        jmp     @char
:       lda     CURROW          ; col 0: join, unless at document top
        ora     TOPLN
        bne     @join
        jsr     is_doc_empty    ; top of doc: maybe load the demo
        beq     @fix
        jmp     load_demo
@fix:   jsr     setline         ; is_doc_empty walked LINEP
@noop:  jmp     edloop

@join:  lda     TOPLN           ; TMP2 = current doc line (>= 1 here)
        clc
        adc     CURROW
        sta     TMP2
        tax
        dex                     ; DSTP = previous line
        lda     buflo,x
        sta     DSTP
        lda     bufhi,x
        sta     DSTP+1
        ldy     #39             ; TMP = previous line's length
@plen:  lda     (DSTP),y
        cmp     #$A0
        bne     @pend
        dey
        bpl     @plen
@pend:  iny
        sty     TMP
        ldy     #39             ; Y+1 = current line's length
@clen:  lda     (LINEP),y
        cmp     #$A0
        bne     @cend
        dey
        bpl     @clen
@cend:  iny
        tya                     ; both must fit in 40 columns
        clc
        adc     TMP
        cmp     #41
        bcs     @noop
        lda     #40             ; SAVCHR = columns free on prev line
        sec
        sbc     TMP
        sta     SAVCHR
        lda     DSTP            ; DSTP += prev len: dest of the copy
        clc
        adc     TMP
        sta     DSTP
        bcc     :+
        inc     DSTP+1
:       ldy     #0
@copy:  cpy     SAVCHR          ; append current line after prev text
        beq     @drop
        lda     (LINEP),y
        sta     (DSTP),y
        iny
        bne     @copy
@drop:  jsr     del_line        ; close the gap (TMP2 still set)
        lda     CURROW          ; cursor to the join seam
        beq     @scrl
        dec     CURROW
        jmp     @seam
@scrl:  dec     TOPLN           ; row 0: window slides up instead
@seam:  lda     TMP             ; a full prev line puts the seam at
        cmp     #40             ; 40 -- clamp to the last column
        bcc     :+
        lda     #39
:       sta     CURCOL
        jsr     redraw
        jmp     edloop

@char:  dec     CURCOL
        ldy     CURCOL
@pull:  cpy     #39
        beq     @last
        iny
        lda     (LINEP),y
        dey
        sta     (LINEP),y
        iny
        jmp     @pull
@last:  lda     #$A0
        sta     (LINEP),y
        jsr     blitline
        jmp     edloop

; --- helpers ---------------------------------------------------------
crlf:   lda     #0
        sta     CURCOL
        lda     CURROW
        cmp     #MAXROW
        bcs     @bot
        inc     CURROW
        jmp     setline
@bot:   lda     TOPLN           ; bottom row: scroll the window down
        cmp     #TOPMAX
        bcs     :+
        inc     TOPLN
        jmp     redraw          ; redraw ends in setline
:       jmp     setline

do_gut: lda     GUTON           ; ^N: toggle the line-number gutter
        eor     #$01
        sta     GUTON
        jsr     redraw
        jmp     edloop

blitline:                       ; repaint the cursor row from its line
        lda     GUTON
        bne     @gut
        ldy     #39
@col:   lda     (LINEP),y
        sta     (SCRP),y
        dey
        bpl     @col
        rts
@gut:   lda     TOPLN           ; inverse 2-digit number + gap, then
        clc                     ; doc cols 0-36 at screen cols 3-39
        adc     CURROW
        adc     #1              ; 1-based line number
        ldy     #0
@tens:  cmp     #10
        bcc     @ones
        sbc     #10
        iny
        bne     @tens
@ones:  pha
        tya
        beq     @blank          ; suppress leading zero
        ora     #$30            ; inverse digit
        bne     @tput
@blank: lda     #$20            ; inverse space
@tput:  ldy     #0
        sta     (SCRP),y
        pla
        ora     #$30
        iny
        sta     (SCRP),y
        iny
        lda     #$A0            ; gap column
        sta     (SCRP),y
        lda     SCRP            ; DSTP = screen row + 3
        clc
        adc     #3
        sta     DSTP
        lda     SCRP+1
        adc     #0
        sta     DSTP+1
        ldy     #36
@gcol:  lda     (LINEP),y
        sta     (DSTP),y
        dey
        bpl     @gcol
        rts

; --- buffer line ops (all clobber A, X, Y, SRCP, DSTP) ---------------
ins_line:                       ; open a blank gap at doc line TMP2;
        ldx     #DOCLINES-1     ; lines below shift down, 98 falls off
@loop:  cpx     TMP2
        beq     @gap
        lda     buflo,x         ; copy line X-1 down into line X
        sta     DSTP
        lda     bufhi,x
        sta     DSTP+1
        dex
        lda     buflo,x
        sta     SRCP
        lda     bufhi,x
        sta     SRCP+1
        jsr     copy40
        jmp     @loop
@gap:   jmp     blank_line

del_line:                       ; delete doc line TMP2; lines below
        ldx     TMP2            ; shift up, line 98 goes blank
@loop:  cpx     #DOCLINES-1
        beq     blank_line
        lda     buflo,x         ; copy line X+1 up into line X
        sta     DSTP
        lda     bufhi,x
        sta     DSTP+1
        inx
        lda     buflo,x
        sta     SRCP
        lda     bufhi,x
        sta     SRCP+1
        jsr     copy40
        jmp     @loop

blank_line:                     ; fill doc line X with spaces
        lda     buflo,x
        sta     DSTP
        lda     bufhi,x
        sta     DSTP+1
        lda     #$A0
        ldy     #39
@col:   sta     (DSTP),y
        dey
        bpl     @col
        rts

copy40: ldy     #39             ; copy one line record (SRCP)->(DSTP)
@col:   lda     (SRCP),y
        sta     (DSTP),y
        dey
        bpl     @col
        rts

redraw:                         ; repaint the whole window from TOPLN
        lda     CURROW
        pha
        lda     #0
        sta     CURROW
@row:   jsr     setline
        jsr     blitline
        inc     CURROW
        lda     CURROW
        cmp     #23
        bne     @row
        pla
        sta     CURROW
        jmp     setline

docinit:                        ; blank the whole document buffer
        lda     #<DOCBUF
        sta     DSTP
        lda     #>DOCBUF
        sta     DSTP+1
        ldx     #16             ; 16 pages covers 99 x 40 bytes
        lda     #$A0
        ldy     #0
@fill:  sta     (DSTP),y
        iny
        bne     @fill
        inc     DSTP+1
        dex
        bne     @fill
        rts

cursor_on:                      ; show cursor: invert the screen cell
        jsr     curscr          ; (display only; the buffer keeps the
        lda     (SCRP),y        ;  real character)
        sta     SAVCHR
        and     #$3F
        sta     (SCRP),y
        rts

cursor_off:                     ; restore what was under it
        jsr     curscr
        lda     SAVCHR
        sta     (SCRP),y
        rts

curscr: ldy     CURCOL          ; Y = cursor's screen column: gutter
        lda     GUTON           ; shifts it +3, pinned to the edge
        beq     @done
        iny
        iny
        iny
        cpy     #40
        bcc     @done
        ldy     #39
@done:  rts

upd_status:                     ; live LN/COL readout (1-based)
        lda     TOPLN
        clc
        adc     CURROW
        adc     #1
        ldx     #26             ; LN digits at status cols 26-27
        jsr     puts2
        lda     CURCOL
        clc
        adc     #1
        ldx     #34             ; COL digits at status cols 34-35
        ; fall through

puts2:  ldy     #0              ; A = 1..40 -> two inverse digits
@tens:  cmp     #10
        bcc     @ones
        sbc     #10
        iny
        bne     @tens
@ones:  sta     TMP
        tya
        beq     @blank          ; suppress leading zero
        ora     #$30
        bne     @put
@blank: lda     #$20
@put:   sta     STATROW,x
        inx
        lda     TMP
        ora     #$30
        sta     STATROW,x
        rts

; --- status bar (inverse), digit cells at 26-27 and 34-35 ----------
statmsg:
        itext   " TEXR 0.1 - MARKDOWN - LN     COL       "
        .assert * - statmsg = 40, error, "status bar must be 40 chars"

; --- help modal layout: box rows 3-20, cols 3-36 --------------------
help_items:
        .byte    3,  3, 34      ; top border
        .word   boxtop
        .repeat 16, r           ; interior
        .byte    4+r, 3, 34
        .word   boxmid
        .endrep
        .byte   20,  3, 34      ; bottom border
        .word   boxtop
        .byte    5, 13, hlp_t2 - hlp_t1
        .word   hlp_t1
        .byte    6, 13, hlp_k1 - hlp_t2
        .word   hlp_t2
        .byte    8,  6, hlp_k2 - hlp_k1
        .word   hlp_k1
        .byte    9,  6, hlp_k3 - hlp_k2
        .word   hlp_k2
        .byte   10,  6, hlp_k4 - hlp_k3
        .word   hlp_k3
        .byte   11,  6, hlp_kp - hlp_k4
        .word   hlp_k4
        .byte   12,  6, hlp_k5 - hlp_kp
        .word   hlp_kp
        .byte   13,  6, hlp_kn - hlp_k5
        .word   hlp_k5
        .byte   14,  6, hlp_ks - hlp_kn
        .word   hlp_kn
        .byte   15,  6, hlp_m1 - hlp_ks
        .word   hlp_ks
        .byte   16,  6, hlp_ml - hlp_m1
        .word   hlp_m1
        .byte   17,  6, hlp_esc - hlp_ml
        .word   hlp_ml
        .byte   18, 14, hlp_esc_end - hlp_esc
        .word   hlp_esc
        .byte   19,  6, hlp_end - hlp_dm
        .word   hlp_dm
        .byte   $FF

boxtop: .repeat 34              ; solid inverse bar
        .byte   $20
        .endrep
boxmid: .byte   $20             ; inverse edges, clear interior
        .repeat 32
        .byte   $A0
        .endrep
        .byte   $20

hlp_t1: htext   "TEXR COMMANDS"
hlp_t2: htext   "============="
hlp_k1: htext   "RETURN    SPLIT / NEW LINE"
hlp_k2: htext   "ARROWS    MOVE LEFT / RIGHT"
hlp_k3: htext   "^J / ^K   MOVE DOWN / UP"
hlp_k4: htext   "^D        BACKSPACE / JOIN"
hlp_kp: htext   "^P        HI-RES PREVIEW"
hlp_k5: htext   "^Q        QUIT TO DOS"
hlp_kn: htext   "^N        LINE NUMBERS ON/OFF"
hlp_ks: htext   "^S / ^O   SAVE / PICK+LOAD .MD"
hlp_m1: htext   "--- ===   AUTO-FILL RULE LINE"
hlp_ml: htext   "- OR *    LISTS AUTO-CONTINUE"
hlp_esc:
        ftext   " ESC CLOSES "
hlp_esc_end:
hlp_dm: htext   "^D ON BLANK DOC LOADS DEMO"
hlp_end:
