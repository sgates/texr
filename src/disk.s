; ===================================================================
; disk.s — ^S save / ^O load as DOS 3.3 text files (M15)
;
; Files are plain markdown text: high-bit ASCII lines ending in CR,
; trailing spaces stripped, blank lines preserved. Commands go out
; through the DOS 3.3 command channel (ctrl-D + command via COUT);
; file bytes come back through the DOS input intercept (KSW).
;
; DOS prints errors and exits to BASIC, which would kill the editor,
; so while a disk operation runs we patch DOS's common error entry
; ($A6D2 on stock 48K DOS 3.3 — pinned, we ship the boot disk) with
; a JMP to trap_handler. The handler mimics the cleanup DOS itself
; does after an error, restores our stack, and returns to the editor.
; Error code 5 (END OF DATA) is how a load normally *finishes*.
; ===================================================================

COUT    := $FDED                ; ROM char out (via DOS's CSW hook)
DERRV   = $A6D2                 ; DOS 3.3 error entry, code in A
DCLN1   = $A851                 ; DOS error-path cleanup calls,
DCLN2   = $A65E                 ;   exactly what $A6EF-$A6F4 does

; --- ^S: save the document -------------------------------------------
do_save:
        lda     #0
        sta     DMODE
        jsr     fname_prompt
        bcc     :+
        jmp     edloop          ; cancelled
:       jsr     add_md          ; texr documents are NAME.MD
        tsx                     ; trap restores the stack to here
        stx     SAVSP
        jsr     trap_on
        lda     #$8D            ; known start-of-line for the first ^D
        jsr     COUT
        ldx     #1              ; commands with the filename appended
        lda     #<c_open
        ldy     #>c_open
        jsr     doscmd
        ldx     #1              ; OPEN/DELETE/OPEN truncates an
        lda     #<c_del         ; existing file of the same name
        ldy     #>c_del
        jsr     doscmd
        ldx     #1
        lda     #<c_open
        ldy     #>c_open
        jsr     doscmd
        ldx     #2              ; WRITE takes no drive suffix
        lda     #<c_write
        ldy     #>c_write
        jsr     doscmd
        ldx     #DOCLINES-1     ; last line with content
@last:  lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        ldy     #39
@sc:    lda     (LINEP),y
        cmp     #$A0
        bne     @found
        dey
        bpl     @sc
        dex
        bpl     @last
        ldx     #0              ; empty doc: save one blank line
@found: stx     LASTLN
        lda     #0
        sta     TMP2            ; current line
@line:  ldx     TMP2
        lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        ldy     #39             ; TMP = length w/o trailing spaces
@len:   lda     (LINEP),y
        cmp     #$A0
        bne     @lend
        dey
        bpl     @len
@lend:  iny
        sty     TMP
        ldy     #0
@ch:    cpy     TMP
        beq     @cr
        lda     (LINEP),y
        sty     TMP3
        jsr     COUT            ; WRITE mode: goes to the file
        ldy     TMP3
        iny
        bne     @ch
@cr:    lda     #$8D
        jsr     COUT
        lda     TMP2
        cmp     LASTLN
        beq     @close
        inc     TMP2
        bne     @line
@close: ldx     #0              ; CLOSE takes no filename
        lda     #<c_close
        ldy     #>c_close
        jsr     doscmd
        jsr     trap_off
        jsr     stat_restore
        jsr     redraw          ; the first CR may have scrolled
        jmp     edloop

; --- load: entered from the ^O picker with FNBUF/FNLEN/FNCUT set ----
load_go:
        lda     #1
        sta     DMODE
        tsx
        stx     SAVSP
        jsr     trap_on
        lda     #$8D
        jsr     COUT
        ldx     #1              ; VERIFY: FILE NOT FOUND without the
        lda     #<c_verify      ; side effect of OPEN creating one
        ldy     #>c_verify
        jsr     doscmd
        ldx     #1
        lda     #<c_open
        ldy     #>c_open
        jsr     doscmd
        ldx     #2              ; READ takes no drive suffix
        lda     #<c_read
        ldy     #>c_read
        jsr     doscmd
        jsr     docinit         ; file is real: wipe the document
        lda     #0
        sta     TMP             ; col
        sta     TMP2            ; line
@rd:    jsr     rdksw
        cmp     #$8D
        bne     @ch
        lda     #0              ; newline
        sta     TMP
        inc     TMP2
        lda     TMP2
        cmp     #DOCLINES
        bcc     @rd
        bcs     @full
@ch:    cmp     #$A0
        bcc     @rd             ; drop control chars
        cmp     #$E0
        bcc     :+
        and     #$DF            ; fold lowercase for the ][+
:       ldx     TMP
        cpx     #40
        bcc     :+
        ldx     #0              ; hard-wrap long lines
        stx     TMP
        inc     TMP2
        ldx     TMP2
        cpx     #DOCLINES
        bcs     @full
:       jsr     putch
        jmp     @rd
@full:  jsr     trap_off        ; document full before EOF
        jsr     dos_close
        jmp     load_finish

load_finish:                    ; success (EOF trap or full doc)
        lda     #0
        sta     CURCOL
        sta     CURROW
        sta     TOPLN
        jsr     stat_restore
        jsr     redraw
        jmp     edloop

putch:  pha                     ; store A at doc line TMP2, col TMP
        ldx     TMP2
        lda     buflo,x
        sta     LINEP
        lda     bufhi,x
        sta     LINEP+1
        pla
        ldy     TMP
        sta     (LINEP),y
        inc     TMP
        rts

rdksw:  jmp     ($0038)         ; DOS input hook: next file byte in A

; --- DOS error trap ---------------------------------------------------
trap_on:                        ; JMP trap_handler over the error entry
        lda     #$4C
        sta     DERRV
        lda     #<trap_handler
        sta     DERRV+1
        lda     #>trap_handler
        sta     DERRV+2
        rts

trap_off:                       ; restore "STA $AA5C"
        lda     #$8D
        sta     DERRV
        lda     #$5C
        sta     DERRV+1
        lda     #$AA
        sta     DERRV+2
        rts

trap_handler:                   ; arrives with the DOS error code in A
        sta     ERRCD
        jsr     DCLN1           ; the cleanup DOS's own error path runs
        jsr     DCLN2
        ldx     SAVSP           ; unwind to do_save/do_load entry depth
        txs
        jsr     trap_off
        jsr     dos_close       ; drop any half-open file
        lda     DMODE
        beq     @fail           ; any error during save is a failure
        lda     ERRCD
        cmp     #5              ; END OF DATA: the load simply ended
        beq     load_finish
@fail:  ldy     #39             ; "DISK ERROR NN" on the status row
@fill:  lda     dmsg,y
        sta     STATROW,y
        dey
        bpl     @fill
        lda     ERRCD
        ldx     #12             ; code digits at status cols 12-13
        jsr     puts2
        jsr     getkey          ; any key acknowledges
        jsr     stat_restore
        jsr     redraw          ; a load may have wiped the document
        jmp     edloop

dos_close:                      ; ctrl-D CLOSE, safe when nothing open
        ldx     #0
        lda     #<c_close
        ldy     #>c_close
        jmp     doscmd

; --- command channel --------------------------------------------------
; Emit ctrl-D + prefix (A/Y, null-terminated) + filename + CR.
; X picks the filename form: 0 = none (CLOSE), 1 = as typed (OPEN /
; DELETE / VERIFY accept a ",D2" drive suffix), 2 = up to the comma
; (READ / WRITE reject drive params; they find the open file by name).
; Every command and every data line ends in CR, so the next ctrl-D is
; always at the start of a line, which is what DOS's intercept needs.
doscmd: sta     SRCP
        sty     SRCP+1
        stx     TMP4
        lda     #$84            ; ctrl-D, high bit set
        jsr     COUT
        ldy     #0
@pfx:   lda     (SRCP),y
        beq     @fn
        sty     TMP3
        jsr     COUT
        ldy     TMP3
        iny
        bne     @pfx
@fn:    lda     TMP4
        beq     @cr
        cmp     #2
        bne     :+
        lda     FNCUT           ; bare name only
        bne     @go
:       lda     FNLEN           ; name as typed
@go:    sta     TMP4
        ldy     #0
@f:     cpy     TMP4
        beq     @cr
        lda     FNBUF,y
        sty     TMP3
        jsr     COUT
        ldy     TMP3
        iny
        bne     @f
@cr:    lda     #$8D
        jmp     COUT

; --- filename prompt on the status row --------------------------------
; Returns carry clear + FNBUF/FNLEN, or carry set if cancelled (ESC,
; or RETURN on an empty name). ^D / left arrow rub out.
fname_prompt:
        ldy     #39             ; inverse-blank the row
        lda     #$20
@clr:   sta     STATROW,y
        dey
        bpl     @clr
        ldx     #5              ; "SAVE: " / "LOAD: "
        lda     DMODE
        bne     @ll
@sl:    lda     p_save,x
        sta     STATROW,x
        dex
        bpl     @sl
        bmi     @go
@ll:    lda     p_load,x
        sta     STATROW,x
        dex
        bpl     @ll
@go:    lda     #0
        sta     FNLEN
@key:   jsr     getkey
        cmp     #$8D            ; RETURN accepts
        beq     @done
        cmp     #$9B            ; ESC cancels
        beq     @cancel
        cmp     #$84            ; ^D rubs out
        beq     @rub
        cmp     #$88            ; so does left arrow
        beq     @rub
        cmp     #$A0            ; printable only (comma allowed: a
        bcc     @key            ; ",D2" suffix picks drive 2)
        ldx     FNLEN
        cpx     #20             ; name length cap
        bcs     @key
        sta     FNBUF,x
        and     #$3F            ; echo inverse
        sta     STATROW+6,x
        inc     FNLEN
        bne     @key
@rub:   ldx     FNLEN
        beq     @key
        dex
        stx     FNLEN
        lda     #$20
        sta     STATROW+6,x
        bne     @key
@done:  lda     FNLEN
        beq     @cancel         ; empty name = cancel
        ldx     #0              ; FNCUT = name length up to a ","
@cut:   cpx     FNLEN
        beq     @cok
        lda     FNBUF,x
        cmp     #$AC
        beq     @cok
        inx
        bne     @cut
@cok:   stx     FNCUT
        clc
        rts
@cancel:
        jsr     stat_restore
        sec
        rts

stat_restore:                   ; static status bar back on row 23
        ldy     #39
@sb:    lda     statmsg,y
        sta     STATROW,y
        dey
        bpl     @sb
        rts

; --- append ".MD" to the bare name unless it already ends in it ------
add_md: lda     FNCUT
        cmp     #3
        bcc     @ins
        ldx     FNCUT
        lda     FNBUF-3,x
        cmp     #$AE            ; "."
        bne     @ins
        lda     FNBUF-2,x
        cmp     #$CD            ; "M"
        bne     @ins
        lda     FNBUF-1,x
        cmp     #$C4            ; "D"
        beq     @done
@ins:   ldy     FNLEN           ; shift any ",Dn" tail right 3
@sh:    cpy     FNCUT
        beq     @put
        dey
        lda     FNBUF,y
        sta     FNBUF+3,y
        jmp     @sh
@put:   ldx     FNCUT
        lda     #$AE
        sta     FNBUF,x
        lda     #$CD
        sta     FNBUF+1,x
        lda     #$C4
        sta     FNBUF+2,x
        lda     FNLEN
        clc
        adc     #3
        sta     FNLEN
        lda     FNCUT
        clc
        adc     #3
        sta     FNCUT
@done:  rts

; --- data -------------------------------------------------------------
c_open:  htext  "OPEN "
        .byte   0
c_del:   htext  "DELETE "
        .byte   0
c_write: htext  "WRITE "
        .byte   0
c_read:  htext  "READ "
        .byte   0
c_verify:
        htext   "VERIFY "
        .byte   0
c_close: htext  "CLOSE"
        .byte   0

p_save: itext   "SAVE: "
p_load: itext   "LOAD: "

dmsg:   itext   " DISK ERROR    - PRESS ANY KEY          "
        .assert * - dmsg = 40, error, "disk error row must be 40 chars"

FNBUF:  .res    28              ; file spec (high-bit ASCII); room for
                                ;   a 24-char name + ",Dn"
FNLEN:  .res    1
FNCUT:  .res    1               ; length up to any "," (bare name)
DMODE:  .res    1               ; 0 = saving, 1 = loading
SAVSP:  .res    1               ; stack pointer at operation start
ERRCD:  .res    1               ; DOS error code from the trap
LASTLN: .res    1               ; last line with content (save)
TMP3:   .res    1               ; Y saves around COUT
TMP4:   .res    1               ; doscmd filename flag
