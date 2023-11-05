;    /////////////////////////////////////////////////////////////
;   ///                        VECTORS                        ///
;  /////////////////////////////////////////////////////////////
	.org 0   ; entry point
  jmpf Start
	.org $03 ; External int. (INTO)                 - IO1CR
  reti
	.org $0B ; External int. (INT1)                 - IO1CR
  reti
	.org $13 ; External int. (INT2) and Timer 0 low - I23CR and T0CNT
  reti
	.org $1B ; External int. (INT3) and base timer  - I23CR and BTCR
  reti
	.org $23 ; Timer 0 high                         - T0CNT
  reti
	.org $2B ; Timer 1 Low and High                 - T1CNT
  reti
	.org $33 ; Serial IO 1                          - SCON0
  reti
	.org $3B ; Serial IO 2                          - SCON1
  reti
	.org $43 ; VMU to VMU comms                     - not listed? (160h/161h)
  reti
	.org $4B ; Port 3 interrupt                     - P3INT
	clr1 P3INT, 1
	mov #$FF, HaltCnt
  reti

	.org $1F0
goodbye:
	not1 EXT, 0
  jmpf goodbye

;    /////////////////////////////////////////////////////////////
;   ///                    DREAMCAST HEADER                   ///
;  /////////////////////////////////////////////////////////////
	.org $200
	.byte "hello, world!   " ; ................... 16-byte Title
	.byte "by https://github.com/jvsTSX    " ; ... 32-byte Description

;    /////////////////////////////////////////////////////////////
;   ///                       GAME ICON                       ///
;  /////////////////////////////////////////////////////////////
	.org $240 ; >>> ICON HEADER
	.org $260 ; >>> PALETTE TABLE
	.org $280 ; >>> ICON DATA



;    /////////////////////////////////////////////////////////////
;   ///                       GAME CODE                       ///
;  /////////////////////////////////////////////////////////////

	.include "sfr.i"
temp1 = $10
temp2 = $11
temp3 = $12
chptr = $13
HaltCnt = $14

Start:
	mov #00000101, P3INT ; enable joypad interrupt
	mov #0, T1CNT
	clr1 BTCR, 6

	; initialize screen
	mov #$80, 2
	mov #0, XBNK
.Loop:
	xor ACC
	st @r2 ; line 1
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2 ; line 2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	inc 2
	st @r2
	ld 2
	add #5
	st 2
  bnz .Loop
  bp XBNK, 0, .LoopDone
	inc XBNK
	mov #80, 2
  br .Loop
.LoopDone:
	
	; print hello world into the screen
	set1 VSEL, 4 ; WRAM autoincrement on
	mov #0, XBNK
	mov #$80, 2
	mov #12, temp1
	mov #<String, temp2
	mov #>String, temp3
  call PrintStringFlash
	
Main: ; wait untill MODE is pressed
	ld P3
  bp ACC, 6, .NoMode
	set1 BTCR, 6
	jmp goodbye
.NoMode:
  dbnz HaltCnt, Main
	set1 PCON, 0
  br Main



;    /////////////////////////////////////////////////////////////
;   ///                      SUBROUTINES                      ///
;  /////////////////////////////////////////////////////////////	
PrintStringFlash:
	; r2 and XBNK = XRAM location (make sure even line)
	; temp1 = char count
	; temp2 = flash address low
	; temp3 = flash address high
	
	; initialize WRAM
	ld temp1
	clr1 PSW, 7
	rorc
	addc #0
	st 1
  call ClearCharCellsWRAM

	; render text
	ld temp1
	st 1
	mov #0, chptr
.StringLoop:
	ld temp2
	st TRL
	ld temp3
	st TRH
	ldf
  call DrawChar
	inc temp2
	ld temp2
  bnz .NoCarry
	inc temp3
.NoCarry:
  dbnz 1, .StringLoop

	; copy result
	ld temp1
	clr1 PSW, 7
	rorc
	addc #0
	st 1
  call PrintCharCells
  ret





ClearCharCellsWRAM: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initializes work RAM char cells because the rendering process involves OR masking
	; r1 = char cell count (1 cell = 2 char)
	mov #0, VRMAD1
	set1 VRMAD2, 0
.CleanLoop:
	xor ACC
	st VTRBF
	st VTRBF
	st VTRBF
	st VTRBF
	st VTRBF
	st VTRBF
  dbnz 1, .CleanLoop
  ret



PrintCharCells: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; renders char cells from WRAM into XRAM
	; XBNK and r2 = position
	; 1 = cell count
	mov #0, C
	ld 2
	and #%00001111
	be #6, .here
.here
  bn PSW, 7, .evenline
	inc C
.evenline:

	mov #0, VRMAD1
	set1 VRMAD2, 0
.CopyLoop:
	mov #6, B
.SubLoop:
	ld VTRBF
	st @r2
	ld 2
  bp C, 0, .even
	add #4
.even:
	add #6
	st 2
	not1 C, 0
  dbnz B, .SubLoop
	ld 2
	sub #$2F
	st 2
  dbnz 1, .CopyLoop
  ret



DrawChar: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; renders one char to Work RAM
	; chptr = location in WRAM (100 - 180)
	; ACC = char to draw
  be #$20, .here0
.here0:
  bp PSW, 7, .BlankChar
	
  be #$80, .here1
.here1:
  bp PSW, 7, .EnglishChar
	
  be #$A0, .here2
.here2:
  bp PSW, 7, .BlankChar
	
  be #$E0, .here3
.here3:
  bp PSW, 7, .JapaneseChar

	; fail condition = blank char
.BlankChar: ; don't render anything
	inc chptr
  ret
	
.EnglishChar:
	mov #<En_Chars, TRL
	mov #>En_Chars, TRH
	sub #$20
  br .Continue	
	
.JapaneseChar:
	mov #<Jp_Chars, TRL
	mov #>Jp_Chars, TRH
	sub #$A0
	
.Continue: ; multiply index by 6 and add char table offset to TR
	st C
	mov #6, B
	xor ACC
	mul
	st B
	ld C
	add TRL
	st TRL
	ld B
	addc TRH
	st TRH

	set1 VRMAD2, 0 ; get current cell
	ld chptr
	clr1 PSW, 7
	rorc
	st C
	xor ACC
	mov #6, B

; mask new char data into the cell and store new result
	mov #6, 0
  bp PSW, 7, MaskRight ; check odd/even
MaskLeft: ; mask regular
	mul
	ld C
	st VRMAD1
.MaskLoop:
	ldf
	or VTRBF
	dec VRMAD1
	st VTRBF
	inc TRL
	ld TRL
  bnz .NoCarry
	inc TRH
.NoCarry
  dbnz 0, .MaskLoop
	inc chptr
  ret

MaskRight: ; mask with ROR
    mul
    ld C
    st VRMAD1
.MaskLoop:
	ldf
	ror
	ror
	ror
	ror
	or VTRBF
	dec VRMAD1
	st VTRBF
	inc TRL
	ld TRL
  bnz .NoCarry
	inc TRH
.NoCarry
  dbnz 0, .MaskLoop
	inc chptr
  ret



;    /////////////////////////////////////////////////////////////
;   ///                      DATA SPACE                       ///
;  /////////////////////////////////////////////////////////////	
String:
	.byte "Hellorld!   "
	;;;;;;;;;;;;;;;;;;;;

En_Chars:
	.include sprite "JIS_EN.png"  header="no"
	.include sprite "JIS_EN2.png" header="no"
	.include sprite "JIS_EN3.png" header="no"

Jp_Chars:
	.cnop 0, $200