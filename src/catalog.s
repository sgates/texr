; ===================================================================
; catalog.s — in-app file picker for ^O (M16)
;
; Reads the DOS 3.3 catalog directly with RWTS (track $11 chain) and
; lists TEXT files whose names end in ".MD" — texr's own documents —
; in a modal box. ^J/^K or the arrow keys move the highlight, RETURN
; loads the file, ESC cancels, and 1 / 2 rescans that drive (the data
; disk in drive 2 is the default). Selection hands a "NAME,Dn" file
; spec to load_go in disk.s.
; ===================================================================

RWTS    := $B7B5                ; DOS 3.3 RWTS entry (A/Y -> IOB)
DCT     = $B7FB                 ; DOS's device characteristics table
CATSEC  = $5000                 ; sector buffer (below program ORG)
FLIST   = $5100                 ; up to 13 names x 24 screen codes
MAXPICK = 13                    ; box rows 6-18

; --- ^O: scan + pick -------------------------------------------------
do_load:
        lda     #2              ; the data disk is the usual home
        sta     CATDRV
@rescan:
        lda     CATDRV
        jsr     pkscan
        php                     ; keep the disk-error flag
        jsr     pkdraw          ; box, title, hint, entries
        plp
        bcc     :+
        lda     #<m_derr        ; RWTS failed (no disk?)
        ldy     #>m_derr
        jsr     pkmsg
        jmp     @key
:       lda     NFILES
        bne     :+
        lda     #<m_none
        ldy     #>m_none
        jsr     pkmsg
        jmp     @key
:       lda     #0
        sta     CURSEL
        sec                     ; highlight entry 0
        jsr     pkrow
@key:   jsr     getkey
        cmp     #$9B            ; ESC cancels
        bne     :+
        jsr     redraw
        jmp     edloop
:       cmp     #$B1            ; 1 / 2 pick the drive
        bne     :+
        lda     #1
        sta     CATDRV
        jmp     @rescan
:       cmp     #$B2
        bne     :+
        lda     #2
        sta     CATDRV
        jmp     @rescan
:       ldx     NFILES          ; everything below needs files
        beq     @key
        cmp     #$8D            ; RETURN loads the selection
        beq     @go
        cmp     #$8A            ; ^J / right arrow move down
        beq     @down
        cmp     #$95
        beq     @down
        cmp     #$8B            ; ^K / left arrow move up
        beq     @up
        cmp     #$88
        beq     @up
        bne     @key
@down:  lda     CURSEL
        clc
        adc     #1
        cmp     NFILES
        bcs     @key
        pha
        clc                     ; unhighlight the old row
        jsr     pkrow
        pla
        sta     CURSEL
        sec
        jsr     pkrow
        jmp     @key
@up:    lda     CURSEL
        beq     @key
        clc
        jsr     pkrow
        dec     CURSEL
        sec
        jsr     pkrow
        jmp     @key
@go:    ldx     CURSEL          ; FNBUF = "NAME,Dn"
        lda     FLENS,x
        sta     FNCUT
        jsr     pkptr           ; SRCP -> the name
        ldy     #0
@cp:    cpy     FNCUT
        beq     :+
        lda     (SRCP),y
        sta     FNBUF,y
        iny
        bne     @cp
:       lda     #$AC            ; ","
        sta     FNBUF,y
        iny
        lda     #$C4            ; "D"
        sta     FNBUF,y
        iny
        lda     CATDRV
        ora     #$B0
        sta     FNBUF,y
        iny
        sty     FNLEN
        jmp     load_go

; --- catalog scan -----------------------------------------------------
; A = drive. Fills FLIST/FLENS/NFILES with ".MD" text files. Carry
; set if RWTS failed. Clobbers A, X, Y, TMP, TMP2, TMP3, DSTP, SRCP.
pkscan: sta     iob_drv
        lda     #0
        sta     NFILES
        lda     #<FLIST
        sta     DSTP
        lda     #>FLIST
        sta     DSTP+1
        lda     #17             ; VTOC at track $11 sector 0
        sta     iob_trk
        lda     #0
        sta     iob_sec
        jsr     rwts_rd
        bcs     @out
        lda     CATSEC+1        ; first catalog sector
        sta     iob_trk
        lda     CATSEC+2
        sta     iob_sec
@sect:  lda     iob_trk
        beq     @done           ; end of chain
        jsr     rwts_rd
        bcs     @out
        lda     #$0B            ; 7 entries of $23 bytes
        sta     TMP
@ent:   ldx     TMP
        lda     CATSEC,x        ; TS-list track
        beq     @done           ; unused entry: end of catalog
        cmp     #$FF
        beq     @next           ; deleted
        inx
        inx
        lda     CATSEC,x        ; file type
        and     #$7F
        bne     @next           ; texr documents are TEXT files
        jsr     consider
@next:  lda     TMP
        clc
        adc     #$23
        sta     TMP
        bcc     @ent            ; carry: past the 7th entry
        lda     CATSEC+1        ; follow the chain
        pha
        lda     CATSEC+2
        sta     iob_sec
        pla
        sta     iob_trk
        jmp     @sect
@done:  clc
@out:   rts

; Store the entry at TMP if its name ends in ".MD" and it fits.
consider:
        lda     TMP
        clc
        adc     #3              ; name field starts at entry+3
        sta     TMP2
        ldy     #29             ; stripped length -> TMP3
@len:   tya
        clc
        adc     TMP2
        tax
        lda     CATSEC,x
        cmp     #$A0
        bne     @gotl
        dey
        bpl     @len
        rts                     ; blank name
@gotl:  iny
        sty     TMP3
        cpy     #4              ; ".MD" alone is no name
        bcc     @no
        cpy     #25             ; too wide for the box
        bcs     @no
        dey                     ; check the ".MD" suffix
        dey
        dey
        tya
        clc
        adc     TMP2
        tax
        lda     CATSEC,x
        cmp     #$AE            ; "."
        bne     @no
        lda     CATSEC+1,x
        cmp     #$CD            ; "M"
        bne     @no
        lda     CATSEC+2,x
        cmp     #$C4            ; "D"
        bne     @no
        lda     NFILES
        cmp     #MAXPICK
        bcs     @no
        ldy     #0              ; copy name, pad to 24
@cp:    cpy     TMP3
        bcs     @pad
        tya
        clc
        adc     TMP2
        tax
        lda     CATSEC,x
        bne     @st
@pad:   lda     #$A0
@st:    sta     (DSTP),y
        iny
        cpy     #24
        bne     @cp
        ldx     NFILES
        lda     TMP3
        sta     FLENS,x
        inc     NFILES
        lda     DSTP            ; next slot
        clc
        adc     #24
        sta     DSTP
        bcc     @no
        inc     DSTP+1
@no:    rts

rwts_rd:                        ; read iob_trk/iob_sec into CATSEC
        lda     #>iob
        ldy     #<iob
        jsr     RWTS
        rts                     ; carry set on error

; --- picker drawing ---------------------------------------------------
pkdraw: lda     #0
        sta     DITGT
        lda     #<pick_items
        sta     ITEMP
        lda     #>pick_items
        sta     ITEMP+1
        jsr     draw_items
        ldx     #4              ; drive digit in the title
        lda     rowlo,x
        sta     SCRP
        lda     rowhi,x
        sta     SCRP+1
        ldy     #28
        lda     CATDRV
        ora     #$B0
        sta     (SCRP),y
        lda     NFILES          ; entries, unhighlighted
        beq     @done
        lda     CURSEL
        pha
        lda     #0
        sta     CURSEL
@row:   clc
        jsr     pkrow
        inc     CURSEL
        lda     CURSEL
        cmp     NFILES
        bne     @row
        pla
        sta     CURSEL
@done:  rts

; Draw file row CURSEL at box row 6+CURSEL; carry set = highlighted.
pkrow:  php
        ldx     CURSEL
        jsr     pkptr
        lda     CURSEL
        clc
        adc     #6
        tax
        lda     rowlo,x
        clc
        adc     #6              ; names at col 6 (row bases don't carry)
        sta     SCRP
        lda     rowhi,x
        sta     SCRP+1
        plp
        ldy     #23
@col:   lda     (SRCP),y
        bcc     :+
        and     #$3F            ; inverse
:       sta     (SCRP),y
        dey
        bpl     @col
        rts

pkptr:  lda     #0              ; SRCP = FLIST + X*24
        sta     SRCP+1
        txa
        asl     a
        asl     a
        asl     a               ; x8
        sta     TMP4
        asl     a               ; x16
        clc
        adc     TMP4
        sta     SRCP
        lda     #0
        adc     #0
        sta     SRCP+1
        lda     SRCP
        clc
        adc     #<FLIST
        sta     SRCP
        lda     SRCP+1
        adc     #>FLIST
        sta     SRCP+1
        rts

pkmsg:  sta     SRCP            ; A/Y message -> box row 6 col 6
        sty     SRCP+1
        ldx     #6
        lda     rowlo,x
        clc
        adc     #6
        sta     SCRP
        lda     rowhi,x
        sta     SCRP+1
        ldy     #0
@ch:    lda     (SRCP),y
        beq     @done
        sta     (SCRP),y
        iny
        bne     @ch
@done:  rts

; --- layout -----------------------------------------------------------
pick_items:
        .byte    3,  3, 34      ; box, same style as the help modal
        .word   boxtop
        .repeat 16, r
        .byte    4+r, 3, 34
        .word   boxmid
        .endrep
        .byte   20,  3, 34
        .word   boxtop
        .byte    4,  6, pk_hint - pk_title
        .word   pk_title
        .byte   19,  5, pk_end - pk_hint
        .word   pk_hint
        .byte   $FF

pk_title:
        htext   "LOAD .MD FILE   DRIVE"
pk_hint:
        htext   "RETURN LOADS - ESC - 1/2 DRIVE"
pk_end:

m_none: htext   "NO .MD FILES ON THIS DRIVE"
        .byte   0
m_derr: htext   "DISK ERROR - TRY 1/2 OR ESC"
        .byte   0

CATDRV: .res    1               ; drive being listed (1/2)
NFILES: .res    1
CURSEL: .res    1
FLENS:  .res    MAXPICK

; RWTS input/output block (Beneath Apple DOS layout)
iob:    .byte   $01             ; IOB type
        .byte   $60             ; slot 6 * 16
iob_drv:
        .byte   $02             ; drive
        .byte   $00             ; volume: any
iob_trk:
        .byte   $11             ; track
iob_sec:
        .byte   $00             ; sector
        .word   DCT
        .word   CATSEC          ; data buffer
        .byte   $00
        .byte   $00             ; byte count: 256
        .byte   $01             ; command: READ
        .byte   $00             ; error code (out)
        .byte   $00             ; volume found (out)
        .byte   $60             ; prior slot
        .byte   $01             ; prior drive
