; $Id: hellorld.asm 522 2023-11-21 01:53:23Z mkarcz $
;-----------------------------------------------------------------------------
; Hellorld program for PAL-1, KIM-1 replica.
; Scrolls HELLOrLd text on 6-digit 7-seg LED display.
;-----------------------------------------------------------------------------

SAD   .EQU  1740h ; segments selection
PADD  .EQU  1741h ; directional registers
SBD   .EQU  1742h ; digit selection

DELCTSTV = $30    ; reload value for scroll delay counter
                 
       .cseg 

		 .org 200h

		 jmp main

; 7-seg codes for "HELLOrLd PAL-1"
; $f6, $f9, $b8, $b8, $bf, $d0, $b8, $de, $00, $f3, $f7, $b8, $c0, $86
;   H,   E,   L,   L,   O,   r,   L,   d,   _,   P,   A,   L,   -,   1
; Scrolling sequence:

mytext01 .byte $f6, $f9, $b8, $b8, $bf, $d0  ; H E L L O r
         .byte $f9, $b8, $b8, $bf, $d0, $b8  ; E L L O r L
         .byte $b8, $b8, $bf, $d0, $b8, $de  ; L L O r L d
         .byte $b8, $bf, $d0, $b8, $de, $00  ; L O r L d _
         .byte $bf, $d0, $b8, $de, $00, $f3  ; O r L d _ P
         .byte $d0, $b8, $de, $00, $f3, $f7  ; r L d _ P A
         .byte $b8, $de, $00, $f3, $f7, $b8  ; L d _ P A L
         .byte $de, $00, $f3, $f7, $b8, $c0  ; d _ P A L -
         .byte $00, $f3, $f7, $b8, $c0, $86  ; _ P A L - 1
         .byte $f3, $f7, $b8, $c0, $86, $00  ; P A L - 1 _
         .byte $f7, $b8, $c0, $86, $00, $00  ; A L - 1 _ _
         .byte $b8, $c0, $86, $00, $00, $00  ; L - 1 _ _ _
         .byte $c0, $86, $00, $00, $00, $00  ; - 1 _ _ _ _
         .byte $86, $00, $00, $00, $00, $f6  ; 1 _ _ _ _ H
         .byte $00, $00, $00, $00, $f6, $f9  ; _ _ _ _ H E
         .byte $00, $00, $00, $f6, $f9, $b8  ; _ _ _ H E L
         .byte $00, $00, $f6, $f9, $b8, $b8  ; _ _ H E L L
         .byte $00, $f6, $f9, $b8, $b8, $bf  ; _ H E L L O
         .byte $aa                           ; $aa - terminating code

digsel   .byte $09, $0b, $0d, $0f, $11, $13

; Counters

txct     .byte 0
delct1   .byte $04
delct2   .byte $ff

;-----------------------------------------------------------------------------
; Subroutines
;-----------------------------------------------------------------------------

; Time delay, count down for delct1 * 256 iterations,
; then return.
; Uses: A, X, Y
; Preserves: X, Y

delay          txa
               pha
               tya
               pha
               ldx delct1
del00          ldy #$ff
del01          dey
               bne del01
del02          dex
               beq del03
               bne del00
del03          pla
               tay
               pla
               tax
               rts

; Display six 7-seg codes starting at mytext01 + txct
; Uses: A, X, Y

disp7seg       ldx #0
               ldy txct
               stx SAD        ; attempt at getting rid of "ghost" artefacts
d7seg01        lda digsel,x
               sta SBD
               lda mytext01,y
               sta SAD
               lda #$01
               sta delct1
               jsr delay
               iny
               inx
               cpx #6
               bne d7seg01
               rts

;-----------------------------------------------------------------------------
; Main loop
;-----------------------------------------------------------------------------
		
main           lda #$7f       ; initialize directional register bits
               sta PADD
l000           lda #0         ; initialize text / 7-seg codes index
               sta txct
l001           lda #DELCTSTV  ; initialize scroll delay counter
               sta delct2
l002           jsr disp7seg   ; display text on 7-seg display
               dec delct2     ; decrement delay counter
               bne l002       ; if counter > 0, keep displaying current text
               inc txct       ; increase text index by 6  / scroll left
               inc txct       ; (number of 7-seg digits in display = 6)
               inc txct
               inc txct
               inc txct
               inc txct
               ldx txct
               lda mytext01,x ; check for terminating code
               cmp #$aa       ; if 7-seg code is $aa,
               beq l000       ; start over the scrolling  sequence
               sec            ; otherwise, scrolling sequence is not finished,
               bcs l001       ; jump to the scroll counter reload and text
                              ; display loop
		.END


