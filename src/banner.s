; ===================================================================
; banner.s — splash screen
; Big TEXR in inverse-video blocks, markdown-styled subtitle.
; ===================================================================

banner_show:
        jsr     HOME
        lda     #<items
        sta     ITEMP
        lda     #>items
        sta     ITEMP+1
        jmp     draw_items

; --- layout table: row, col, len, source ---------------------------
items:  .byte    2,  7, 26
        .word   blk1
        .byte    3,  7, 26
        .word   blk2
        .byte    4,  7, 26
        .word   blk3
        .byte    5,  7, 26
        .word   blk4
        .byte    6,  7, 26
        .word   blk5
        .byte    8,  9, 22
        .word   sub_title
        .byte    9,  9, 22
        .word   sub_rule
        .byte   11,  9, 21
        .word   sub_for
        .byte   14, 18,  4
        .word   sub_ver
        .byte   17,  9, 22
        .word   sub_key
        .byte   21, 11, 18
        .word   sub_help
        .byte   $FF

; --- TEXR in a 5x5 block font, letters 2 cols apart ----------------
blk1:   brow    "#####  #####  #   #  #### "
blk2:   brow    "  #    #       # #   #   #"
blk3:   brow    "  #    ####     #    #### "
blk4:   brow    "  #    #       # #   # #  "
blk5:   brow    "  #    #####  #   #  #  # "
        .assert blk2 - blk1 = 26, error, "banner rows must be 26 bytes"
        .assert * - blk5 = 26, error, "banner rows must be 26 bytes"

sub_title:
        htext   "A MARKDOWN TEXT EDITOR"
sub_rule:                       ; a setext underline, naturally
        htext   "======================"
sub_for:
        htext   "FOR THE APPLE ][ PLUS"
sub_ver:
        htext   "V0.1"
sub_key:
        ftext   "PRESS ANY KEY TO BEGIN"
sub_help:
        htext   "PRESS ESC FOR HELP"
