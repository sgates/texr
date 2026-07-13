; ===================================================================
; font.s — 5x7 font for the hi-res renderer, ASCII $20-$5F
;
; Each glyph is 8 bytes: 7 art rows + 1 blank spacing row. Glyphs
; occupy pixel columns 0-4 of the 7-pixel cell; columns 5-6 are
; inter-character spacing. Apple II hi-res shows bit 0 leftmost,
; so the grow macro maps the first art column to bit 0.
; ===================================================================

.macro  grow s                  ; one glyph row: '#' = pixel on
        .assert .strlen(s) = 5, error, "glyph row must be 5 chars"
        .byte   ((.strat(s,0)='#') << 0) | ((.strat(s,1)='#') << 1) | ((.strat(s,2)='#') << 2) | ((.strat(s,3)='#') << 3) | ((.strat(s,4)='#') << 4)
.endmacro

font:
; $20 space
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        .byte   0
; $21 !
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "     "
        grow    "  #  "
        .byte   0
; $22 "
        grow    " # # "
        grow    " # # "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        .byte   0
; $23 #
        grow    " # # "
        grow    " # # "
        grow    "#####"
        grow    " # # "
        grow    "#####"
        grow    " # # "
        grow    " # # "
        .byte   0
; $24 $
        grow    "  #  "
        grow    " ####"
        grow    "# #  "
        grow    " ### "
        grow    "  # #"
        grow    "#### "
        grow    "  #  "
        .byte   0
; $25 %
        grow    "##   "
        grow    "##  #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    "#  ##"
        grow    "   ##"
        .byte   0
; $26 &
        grow    " ##  "
        grow    "#  # "
        grow    "# #  "
        grow    " #   "
        grow    "# # #"
        grow    "#  # "
        grow    " ## #"
        .byte   0
; $27 '
        grow    "  #  "
        grow    "  #  "
        grow    " #   "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        .byte   0
; $28 (
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    " #   "
        grow    " #   "
        grow    "  #  "
        grow    "   # "
        .byte   0
; $29 )
        grow    " #   "
        grow    "  #  "
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        .byte   0
; $2A *
        grow    "     "
        grow    " # # "
        grow    "  #  "
        grow    "#####"
        grow    "  #  "
        grow    " # # "
        grow    "     "
        .byte   0
; $2B +
        grow    "     "
        grow    "  #  "
        grow    "  #  "
        grow    "#####"
        grow    "  #  "
        grow    "  #  "
        grow    "     "
        .byte   0
; $2C ,
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    " ##  "
        grow    "  #  "
        grow    " #   "
        .byte   0
; $2D -
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "#####"
        grow    "     "
        grow    "     "
        grow    "     "
        .byte   0
; $2E .
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    " ##  "
        grow    " ##  "
        .byte   0
; $2F /
        grow    "     "
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    "#    "
        grow    "     "
        .byte   0
; $30 0
        grow    " ### "
        grow    "#   #"
        grow    "#  ##"
        grow    "# # #"
        grow    "##  #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $31 1
        grow    "  #  "
        grow    " ##  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    " ### "
        .byte   0
; $32 2
        grow    " ### "
        grow    "#   #"
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    "#####"
        .byte   0
; $33 3
        grow    "#####"
        grow    "   # "
        grow    "  #  "
        grow    "   # "
        grow    "    #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $34 4
        grow    "   # "
        grow    "  ## "
        grow    " # # "
        grow    "#  # "
        grow    "#####"
        grow    "   # "
        grow    "   # "
        .byte   0
; $35 5
        grow    "#####"
        grow    "#    "
        grow    "#### "
        grow    "    #"
        grow    "    #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $36 6
        grow    "  ## "
        grow    " #   "
        grow    "#    "
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $37 7
        grow    "#####"
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    " #   "
        grow    " #   "
        .byte   0
; $38 8
        grow    " ### "
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $39 9
        grow    " ### "
        grow    "#   #"
        grow    "#   #"
        grow    " ####"
        grow    "    #"
        grow    "   # "
        grow    " ##  "
        .byte   0
; $3A :
        grow    "     "
        grow    " ##  "
        grow    " ##  "
        grow    "     "
        grow    " ##  "
        grow    " ##  "
        grow    "     "
        .byte   0
; $3B ;
        grow    "     "
        grow    " ##  "
        grow    " ##  "
        grow    "     "
        grow    " ##  "
        grow    "  #  "
        grow    " #   "
        .byte   0
; $3C <
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    "#    "
        grow    " #   "
        grow    "  #  "
        grow    "   # "
        .byte   0
; $3D =
        grow    "     "
        grow    "     "
        grow    "#####"
        grow    "     "
        grow    "#####"
        grow    "     "
        grow    "     "
        .byte   0
; $3E >
        grow    " #   "
        grow    "  #  "
        grow    "   # "
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        .byte   0
; $3F ?
        grow    " ### "
        grow    "#   #"
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    "     "
        grow    "  #  "
        .byte   0
; $40 @
        grow    " ### "
        grow    "#   #"
        grow    "    #"
        grow    " ## #"
        grow    "# # #"
        grow    "# # #"
        grow    " ### "
        .byte   0
; $41 A
        grow    "  #  "
        grow    " # # "
        grow    "#   #"
        grow    "#   #"
        grow    "#####"
        grow    "#   #"
        grow    "#   #"
        .byte   0
; $42 B
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    "#### "
        .byte   0
; $43 C
        grow    " ### "
        grow    "#   #"
        grow    "#    "
        grow    "#    "
        grow    "#    "
        grow    "#   #"
        grow    " ### "
        .byte   0
; $44 D
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#### "
        .byte   0
; $45 E
        grow    "#####"
        grow    "#    "
        grow    "#    "
        grow    "#### "
        grow    "#    "
        grow    "#    "
        grow    "#####"
        .byte   0
; $46 F
        grow    "#####"
        grow    "#    "
        grow    "#    "
        grow    "#### "
        grow    "#    "
        grow    "#    "
        grow    "#    "
        .byte   0
; $47 G
        grow    " ### "
        grow    "#   #"
        grow    "#    "
        grow    "# ###"
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $48 H
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#####"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        .byte   0
; $49 I
        grow    " ### "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    " ### "
        .byte   0
; $4A J
        grow    "  ###"
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    "#  # "
        grow    " ##  "
        .byte   0
; $4B K
        grow    "#   #"
        grow    "#  # "
        grow    "# #  "
        grow    "##   "
        grow    "# #  "
        grow    "#  # "
        grow    "#   #"
        .byte   0
; $4C L
        grow    "#    "
        grow    "#    "
        grow    "#    "
        grow    "#    "
        grow    "#    "
        grow    "#    "
        grow    "#####"
        .byte   0
; $4D M
        grow    "#   #"
        grow    "## ##"
        grow    "# # #"
        grow    "# # #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        .byte   0
; $4E N
        grow    "#   #"
        grow    "##  #"
        grow    "# # #"
        grow    "#  ##"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        .byte   0
; $4F O
        grow    " ### "
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $50 P
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    "#### "
        grow    "#    "
        grow    "#    "
        grow    "#    "
        .byte   0
; $51 Q
        grow    " ### "
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "# # #"
        grow    "#  # "
        grow    " ## #"
        .byte   0
; $52 R
        grow    "#### "
        grow    "#   #"
        grow    "#   #"
        grow    "#### "
        grow    "# #  "
        grow    "#  # "
        grow    "#   #"
        .byte   0
; $53 S
        grow    " ####"
        grow    "#    "
        grow    "#    "
        grow    " ### "
        grow    "    #"
        grow    "    #"
        grow    "#### "
        .byte   0
; $54 T
        grow    "#####"
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        .byte   0
; $55 U
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    " ### "
        .byte   0
; $56 V
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    " # # "
        grow    "  #  "
        .byte   0
; $57 W
        grow    "#   #"
        grow    "#   #"
        grow    "#   #"
        grow    "# # #"
        grow    "# # #"
        grow    "## ##"
        grow    "#   #"
        .byte   0
; $58 X
        grow    "#   #"
        grow    "#   #"
        grow    " # # "
        grow    "  #  "
        grow    " # # "
        grow    "#   #"
        grow    "#   #"
        .byte   0
; $59 Y
        grow    "#   #"
        grow    "#   #"
        grow    " # # "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        grow    "  #  "
        .byte   0
; $5A Z
        grow    "#####"
        grow    "    #"
        grow    "   # "
        grow    "  #  "
        grow    " #   "
        grow    "#    "
        grow    "#####"
        .byte   0
; $5B [
        grow    " ### "
        grow    " #   "
        grow    " #   "
        grow    " #   "
        grow    " #   "
        grow    " #   "
        grow    " ### "
        .byte   0
; $5C backslash
        grow    "     "
        grow    "#    "
        grow    " #   "
        grow    "  #  "
        grow    "   # "
        grow    "    #"
        grow    "     "
        .byte   0
; $5D ]
        grow    " ### "
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    "   # "
        grow    " ### "
        .byte   0
; $5E ^
        grow    "  #  "
        grow    " # # "
        grow    "#   #"
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        .byte   0
; $5F _
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "     "
        grow    "#####"
        .byte   0

; --- special glyphs beyond the ASCII set ----------------------------
; index 64: markdown list bullet
        grow    "     "
        grow    " ### "
        grow    "#####"
        grow    "#####"
        grow    " ### "
        grow    "     "
        grow    "     "
        .byte   0

        .assert * - font = 65 * 8, error, "font must be 65 glyphs of 8 bytes"
