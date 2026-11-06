; Hellorld! for NEC PC-8801/8001
; Original post by yosi2112 on the Usagi Electric Discord (#general, 2023/10/24)
; Restored from the memory dump (E000H-E020H) posted there.
;
; Assemble with the Macro Assembler AS (Alfred Arnold):
;   asl -cpu Z80 PC8801_hellorld.asm
;   p2bin PC8801_hellorld
;
; NOTE for PC-8001: change the bytes at E000H-E002H and E013H-E015H
; to 00H (i.e. replace the two CALLs below, marked "PC-8801 only",
; with NOPs).  On the PC-8001 no ROM switching is needed.

	cpu	Z80

	org	0e000h

START:
	call	0f16ch		; PC-8801 only: switch ROM (to N-BASIC side)
				; PC-8001: change E000H-E002H to 00H
	ld	bc,MSG		; BC -> "Hellorld!" string
LOOP:
	ld	a,(bc)		; get one character
	cp	00h		; end of string ?
	jp	z,DONE		; yes -> finish
	call	0257h		; print character in A
	inc	bc		; next character
	jp	LOOP

DONE:
	call	0f175h		; PC-8801 only: switch ROM back
				; PC-8001: change E013H-E015H to 00H
	rst	38h		; FFH in the dump: end / break

MSG:
	db	"Hellorld!",00h

	end
