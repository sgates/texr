; ===================================================================
; hgr.s — hi-res markdown preview (milestone 1: plain text)
;
; ^P renders the document to the 280x192 hi-res screen with a 5x7
; software font (7x8 cells = 40x24 chars) and flips to graphics;
; ESC flips back to text mode. Hi-res page 1 ($2000-$3FFF) is a
; separate memory page, so the text screen needs no save/restore.
; ===================================================================

; --- display soft switches ------------------------------------------
TXTCLR  := $C050                ; graphics on
TXTSET  := $C051                ; text on
MIXCLR  := $C052                ; full-screen (no text window)
LOWSCR  := $C054                ; page 1
HIRESON := $C057                ; hi-res mode

; --- markdown line-start screen codes --------------------------------
RDASH   = '-' | $80
REQ     = '=' | $80
RSTAR   = '*' | $80
RHASH   = '#' | $80
RSPC    = ' ' | $80

BULLET  = 64                    ; font index of the list-dot glyph

; --- ^P handler ------------------------------------------------------
do_prev:
        lda     CURROW          ; render loop steers by CURROW; keep ours
        pha
        jsr     hgr_clear
        lda     #0
        sta     CURROW
@row:   jsr     setline
        jsr     render_line
        inc     CURROW
        lda     CURROW
        cmp     #23
        bne     @row
        bit     TXTCLR          ; rendered off-screen; now flip to it
        bit     MIXCLR
        bit     LOWSCR
        bit     HIRESON
@wait:  jsr     getkey
        cmp     #$9B            ; ESC returns to the editor
        bne     @wait
        bit     TXTSET
        pla
        sta     CURROW
        jsr     setline
        jmp     edloop

; --- render one document line with markdown semantics ---------------
; LINEP/CURROW select the line. Rules become pixel lines, "- "/"* "
; become dotted bullets, "# " headings drop the marker and underline.
render_line:
        lda     #0
        sta     HBOLD
        ldy     #0
        lda     (LINEP),y
        cmp     #RDASH
        beq     @dash
        cmp     #REQ
        beq     @equals
        cmp     #RSTAR
        beq     @star
        cmp     #RHASH
        beq     @hash
@plain: lda     #0              ; ordinary text, rendered in place
        sta     TMP
        sta     TMP2
        jmp     render_text

@dash:  ldy     #1              ; "- " bullet, "---" rule, else text
        lda     (LINEP),y
        cmp     #RSPC
        beq     @bullet
        cmp     #RDASH
        bne     @plain
        ldy     #2
        lda     (LINEP),y
        cmp     #RDASH
        bne     @plain
        lda     #39             ; --- : single full-width rule
        ldx     #3
        jmp     hline

@equals:
        ldy     #1              ; "===" rule, else text
        lda     (LINEP),y
        cmp     #REQ
        bne     @plain
        ldy     #2
        lda     (LINEP),y
        cmp     #REQ
        bne     @plain
        lda     #39             ; === : double full-width rule
        ldx     #2
        jsr     hline
        lda     #39
        ldx     #4
        jmp     hline

@star:  ldy     #1              ; "* " is a bullet too
        lda     (LINEP),y
        cmp     #RSPC
        bne     @plain
@bullet:
        lda     #0              ; dot at the margin, gap, text at col 2
        sta     HCOL
        lda     #BULLET
        jsr     draw_idx
        lda     #2              ; item text stays in place
        sta     TMP
        sta     TMP2
        jmp     render_text

@hash:  ldy     #0              ; count leading #s (max 6)
@cnt:   lda     (LINEP),y
        cmp     #RHASH
        bne     @cntend
        iny
        cpy     #7
        bne     @cnt
@cntend:
        lda     (LINEP),y
        cmp     #RSPC           ; "#TEXT" without space is just text
        bne     @plain
        cpy     #1              ; h1 renders bold (double-strike)
        bne     :+
        lda     #$80
        sta     HBOLD
:       iny                     ; skip the space
        sty     TMP             ; text starts here...
        lda     #0
        sta     TMP2            ; ...and renders at the left margin
        jsr     render_text
        lda     HLAST           ; underline to the last glyph drawn
        ldx     #7
        jmp     hline

; --- copy chars TMP..39 of the line to dest cols from TMP2 ----------
; Tracks the last non-space destination column in HLAST.
render_text:
        lda     #0
        sta     HLAST
        lda     TMP2
        sta     HCOL
@loop:  ldy     TMP
        cpy     #40
        bcs     @done
        lda     (LINEP),y
        cmp     #RSPC
        beq     @sp
        ldx     HCOL
        stx     HLAST
@sp:    jsr     draw_glyph
        inc     TMP
        inc     HCOL
        jmp     @loop
@done:  rts

; --- horizontal pixel line -------------------------------------------
; Scanline X (0-7) of char row CURROW, cols 0 through A inclusive.
hline:  sta     TMP
        txa
        asl     a
        asl     a               ; scanline -> hi-byte offset (*$400)
        sta     TMP2
        ldx     CURROW
        lda     hgrlo,x
        sta     HPTR
        lda     hgrhi,x
        clc
        adc     TMP2
        sta     HPTR+1
        ldy     TMP
        lda     #$7F            ; all 7 pixels of each byte
@fill:  sta     (HPTR),y
        dey
        bpl     @fill
        rts

; --- draw one glyph --------------------------------------------------
; A = text screen code; cell = (CURROW, HCOL). Clobbers A, X, Y.
draw_glyph:
        and     #$7F            ; normal screen code -> ASCII
        cmp     #$20
        bcs     :+
        lda     #$20            ; control chars -> space
:       cmp     #$60
        bcc     :+
        sec
        sbc     #$20            ; lowercase -> uppercase
:       sec
        sbc     #$20            ; -> font index 0-63
        ; fall through

; A = font index; also the entry for special glyphs like BULLET
draw_idx:
        beq     @done           ; space: cell is already clear
        sta     FONTP           ; FONTP = font + index*8
        lda     #0
        asl     FONTP
        rol     a
        asl     FONTP
        rol     a
        asl     FONTP
        rol     a
        sta     FONTP+1
        lda     FONTP
        clc
        adc     #<font
        sta     FONTP
        lda     FONTP+1
        adc     #>font
        sta     FONTP+1
        ldx     CURROW          ; HPTR = cell's first scanline
        lda     hgrlo,x
        clc
        adc     HCOL            ; row base low bytes never carry (+39 max)
        sta     HPTR
        lda     hgrhi,x
        sta     HPTR+1
        ldx     #8              ; stamp 8 scanlines
@scan:  ldy     #0
        lda     (FONTP),y
        bit     HBOLD
        bpl     :+
        asl     a               ; bold: OR the glyph row with itself
        ora     (FONTP),y       ;   shifted one pixel right
:       sta     (HPTR),y
        inc     FONTP
        bne     :+
        inc     FONTP+1
:       lda     HPTR+1          ; next scanline is +$400
        clc
        adc     #4
        sta     HPTR+1
        dex
        bne     @scan
@done:  rts

; --- clear hi-res page 1 ---------------------------------------------
hgr_clear:
        lda     #0
        sta     HPTR
        ldx     #$20
@page:  stx     HPTR+1
        tay
@byte:  sta     (HPTR),y
        iny
        bne     @byte
        inx
        cpx     #$40
        bne     @page
        rts

; Hi-res char row bases: $2000 + (row mod 8)*$80 + (row div 8)*$28
hgrlo:  .repeat 24, r
        .byte   <($2000 + (r .mod 8) * $80 + (r / 8) * $28)
        .endrep
hgrhi:  .repeat 24, r
        .byte   >($2000 + (r .mod 8) * $80 + (r / 8) * $28)
        .endrep
