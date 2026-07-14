; ===================================================================
; demo.s — bundled demo document
;
; Ctrl-D on a pristine (untouched) document loads a showcase of every
; markdown feature, matching bin/demos/markdown_render_demo.sh. Once
; the document has been touched, Ctrl-D goes back to being backspace.
; ===================================================================

; --- load the demo, called from do_del on an empty document ---------
load_demo:
        lda     #1              ; write into the document buffer
        sta     DITGT
        lda     #<demo_items
        sta     ITEMP
        lda     #>demo_items
        sta     ITEMP+1
        jsr     draw_items
        lda     #0
        sta     DITGT
        sta     CURCOL
        sta     CURROW
        sta     TOPLN
        jsr     redraw          ; show it; redraw ends in setline
        jmp     edloop

; A=1 if every buffer line is blank, else A=0. Clobbers LINEP, X, Y.
is_doc_empty:
        ldx     #0
@row:   lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        ldy     #39
@col:   lda     (LINEP),y
        cmp     #$A0
        bne     @found
        dey
        bpl     @col
        inx
        cpx     #DOCLINES
        bne     @row
        lda     #1
        rts
@found: lda     #0
        rts

; --- layout table: row, col, len, source ----------------------------
demo_items:
        .byte    0,  0, dline1_end - dline1
        .word   dline1
        .byte    2,  0, dline2_end - dline2
        .word   dline2
        .byte    4,  0, dline3_end - dline3
        .word   dline3
        .byte    5,  0, dline4_end - dline4
        .word   dline4
        .byte    6,  0, dline5_end - dline5
        .word   dline5
        .byte    8,  0, dline6_end - dline6
        .word   dline6
        .byte   10,  0, dline7_end - dline7
        .word   dline7
        .byte   12,  0, drule1_end - drule1
        .word   drule1
        .byte   13,  0, drule2_end - drule2
        .word   drule2
        .byte   15,  0, dline8_end - dline8
        .word   dline8
        .byte   $FF

dline1: htext   "# TEXR MARKDOWN DEMO"
dline1_end:
dline2: htext   "## LISTS CONTINUE THEMSELVES"
dline2_end:
dline3: htext   "- BULLETS GET ROUND DOTS"
dline3_end:
dline4: htext   "- THIS LINE ONLY NEEDED RETURN"
dline4_end:
dline5: htext   "- CTRL-P TO RENDER MARKDOWN PREVIEW" 
dline5_end:
dline6: htext   "* STAR MARKERS WORK TOO"
dline6_end:
dline7: htext   "## RULES AUTO-FILL AND RENDER"
dline7_end:
drule1: .repeat 40
        .byte   ('-' | $80)
        .endrep
drule1_end:
drule2: .repeat 40
        .byte   ('=' | $80)
        .endrep
drule2_end:
dline8: htext   "PLAIN TEXT AND #MIDLINE TAGS STAY PUT."
dline8_end:
