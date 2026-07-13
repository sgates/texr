; ===================================================================
; editor.s — milestone 1: full-screen editing, screen-as-buffer
;
; Rows 0-22 are the document (the text page IS the buffer for now);
; row 23 is an inverse status bar with live line/column readout.
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
        jsr     setline

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
:       cmp     #$91            ; ^Q quit
        bne     :+
        jsr     HOME
        rts
:       cmp     #$90            ; ^P hi-res preview
        bne     :+
        jmp     do_prev
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
        jsr     crlf
@out:   jmp     edloop

; --- RETURN, with markdown list continuation ------------------------
; On a "- " / "* " item the next line auto-starts with the same
; marker (if it's blank); on an empty item the marker is removed
; instead, ending the list.
do_cr:  ldy     #0
        lda     (LINEP),y
        cmp     #('-' | $80)
        beq     @mark
        cmp     #('*' | $80)
        bne     @plain
@mark:  ldy     #1
        lda     (LINEP),y
        cmp     #$A0
        bne     @plain
        ldy     #2              ; any item text?
@rest:  lda     (LINEP),y
        cmp     #$A0
        bne     @cont
        iny
        cpy     #40
        bne     @rest
        lda     #$A0            ; empty item: erase marker, end list
        ldy     #1
        sta     (LINEP),y
        dey
        sta     (LINEP),y
@plain: jsr     crlf
        jmp     edloop
@cont:  ldy     #0              ; remember which marker
        lda     (LINEP),y
        sta     TMP
        jsr     crlf
        ldy     #39             ; only take over a blank line
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
        lda     #2
        sta     CURCOL
@done:  jmp     edloop

do_left:
        lda     CURCOL
        beq     @prev
        dec     CURCOL
        jmp     edloop
@prev:  lda     CURROW          ; col 0: hop to end of previous row
        beq     @stay
        dec     CURROW
        jsr     setline
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
        beq     :+
        dec     CURROW
        jsr     setline
:       jmp     edloop

do_down:
        lda     CURROW
        cmp     #MAXROW
        bcs     :+
        inc     CURROW
        jsr     setline
:       jmp     edloop

; --- help modal ------------------------------------------------------
do_help:
        lda     CURROW          ; draw_items steers by CURROW; keep ours
        pha
        jsr     scr_save
        lda     #<help_items
        sta     ITEMP
        lda     #>help_items
        sta     ITEMP+1
        jsr     draw_items
@wait:  jsr     getkey
        cmp     #$9B            ; ESC closes
        bne     @wait
        jsr     scr_restore
        pla
        sta     CURROW
        jsr     setline
        jmp     edloop

scr_save:                       ; document rows 0-22 -> SCRBUF
        lda     #<SCRBUF
        sta     DSTP
        lda     #>SCRBUF
        sta     DSTP+1
        ldx     #0
@row:   lda     rowlo,x
        sta     LINEP
        lda     rowhi,x
        sta     LINEP+1
        ldy     #39
@col:   lda     (LINEP),y
        sta     (DSTP),y
        dey
        bpl     @col
        lda     DSTP            ; DSTP += 40
        clc
        adc     #40
        sta     DSTP
        bcc     :+
        inc     DSTP+1
:       inx
        cpx     #23
        bne     @row
        rts

scr_restore:                    ; SCRBUF -> document rows 0-22
        lda     #<SCRBUF
        sta     DSTP
        lda     #>SCRBUF
        sta     DSTP+1
        ldx     #0
@row:   lda     rowlo,x
        sta     LINEP
        lda     rowhi,x
        sta     LINEP+1
        ldy     #39
@col:   lda     (DSTP),y
        sta     (LINEP),y
        dey
        bpl     @col
        lda     DSTP            ; DSTP += 40
        clc
        adc     #40
        sta     DSTP
        bcc     :+
        inc     DSTP+1
:       inx
        cpx     #23
        bne     @row
        rts

; --- backspace: delete char left of cursor, pull line left ----------
; Typing immediately after lands where the deleted text was.
do_del: lda     CURCOL
        bne     :+
        jmp     edloop          ; nothing left of col 0 (line join TBD)
:       dec     CURCOL
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
        jmp     edloop

; --- helpers ---------------------------------------------------------
crlf:   lda     #0
        sta     CURCOL
        lda     CURROW
        cmp     #MAXROW
        bcs     :+
        inc     CURROW
:       jmp     setline

cursor_on:                      ; show cursor: invert the cell
        ldy     CURCOL
        lda     (LINEP),y
        sta     SAVCHR
        and     #$3F
        sta     (LINEP),y
        rts

cursor_off:                     ; restore what was under it
        ldy     CURCOL
        lda     SAVCHR
        sta     (LINEP),y
        rts

upd_status:                     ; live LN/COL readout (1-based)
        lda     CURROW
        clc
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
        .byte   13,  6, hlp_m1 - hlp_k5
        .word   hlp_k5
        .byte   15,  6, hlp_ml - hlp_m1
        .word   hlp_m1
        .byte   16,  6, hlp_m2 - hlp_ml
        .word   hlp_ml
        .byte   17,  6, hlp_esc - hlp_m2
        .word   hlp_m2
        .byte   18, 14, hlp_end - hlp_esc
        .word   hlp_esc
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
hlp_k1: htext   "RETURN    NEW LINE"
hlp_k2: htext   "ARROWS    MOVE LEFT / RIGHT"
hlp_k3: htext   "^J / ^K   MOVE DOWN / UP"
hlp_k4: htext   "^D        BACKSPACE"
hlp_kp: htext   "^P        HI-RES PREVIEW"
hlp_k5: htext   "^Q        QUIT TO DOS"
hlp_m1: htext   "--- ===   AUTO-FILL RULE LINE"
hlp_ml: htext   "- OR *    LISTS AUTO-CONTINUE"
hlp_m2: htext   "TYPING INSERTS AT THE CURSOR"
hlp_esc:
        ftext   " ESC CLOSES "
hlp_end:
