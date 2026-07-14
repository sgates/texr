; ===================================================================
; texr — a markdown-first text editor for the Apple ][+
; Target: Apple ][+ (48K + Language Card), DOS 3.3
; Build:  ca65/cl65, raw binary at $6000, launched via BRUN TEXR
; ===================================================================
        .setcpu "6502"
        .include "defs.inc"

main:   bit     KBDSTRB         ; discard any pending boot keypress
        jsr     banner_show
        jsr     getkey
        sta     KEYCH           ; ^D dismissing the splash loads the demo
        jsr     editor_run
        rts                     ; back to the DOS prompt

; --- shared routines ------------------------------------------------

getkey: lda     KBD             ; wait for a key, return it in A
        bpl     getkey
        bit     KBDSTRB
        rts

; Render a layout table at (ITEMP): records of row, col, len, source
; address, terminated by row = $FF. Later records draw over earlier.
; DITGT picks the target: 0 = screen rows (banner, modals), else
; document buffer lines (the demo loader).
draw_items:
        ldy     #0
@item:  lda     (ITEMP),y       ; row, or $FF end marker
        cmp     #$FF
        beq     @done
        tax
        lda     DITGT
        beq     @scr
        lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        jmp     @col
@scr:   lda     rowlo,x
        sta     LINEP
        lda     rowhi,x
        sta     LINEP+1
@col:   iny
        lda     (ITEMP),y       ; column
        clc
        adc     LINEP
        sta     LINEP
        bcc     :+
        inc     LINEP+1         ; buffer lines can straddle pages
:       iny
        lda     (ITEMP),y       ; length
        sta     TMP
        iny
        lda     (ITEMP),y       ; source address
        sta     SRCP
        iny
        lda     (ITEMP),y
        sta     SRCP+1
        iny
        sty     TMP2
        ldy     #0
@copy:  lda     (SRCP),y
        sta     (LINEP),y
        iny
        cpy     TMP
        bne     @copy
        ldy     TMP2
        jmp     @item
@done:  rts

setline:                        ; LINEP = buffer line TOPLN+CURROW,
        ldx     CURROW          ; SCRP = CURROW's screen row base
        lda     rowlo,x
        sta     SCRP
        lda     rowhi,x
        sta     SCRP+1
        txa
        clc
        adc     TOPLN
        tax
        lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        rts

; Text page 1 row bases: $400 + (row mod 8)*$80 + (row div 8)*$28
rowlo:  .repeat 24, r
        .byte   <($0400 + (r .mod 8) * $80 + (r / 8) * $28)
        .endrep
rowhi:  .repeat 24, r
        .byte   >($0400 + (r .mod 8) * $80 + (r / 8) * $28)
        .endrep

; Document buffer line bases: DOCBUF + line * 40
buflo:  .repeat DOCLINES, r
        .byte   <(DOCBUF + r * 40)
        .endrep
bufhi:  .repeat DOCLINES, r
        .byte   >(DOCBUF + r * 40)
        .endrep

        .include "banner.s"
        .include "editor.s"
        .include "hgr.s"
        .include "font.s"
        .include "demo.s"
        .include "disk.s"
        .include "catalog.s"
