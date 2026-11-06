; Hellorld! for NEC PC-8801/8001
; Original post by yosi2112 on the Usagi Electric Discord (#general, 2023/10/24)
; Restored from the memory dump (E000H-E020H) posted there.
;
; Version 1.1.0 (semantic versioning)
;   1.1.0 - Auto-detect PC-8801 / PC-8001 via port 31H (method below),
;           so a single binary runs on both machines.
;   1.0.0 - Restored source from the Discord dump post. PC-8001 use
;           required changing E000H-E002H and E013H-E015H to 00H.
;
; Assemble with the Macro Assembler AS (Alfred Arnold):
;   asl -cpu Z80 PC8801_hellorld.asm
;   p2bin PC8801_hellorld
;
; Machine check (port 31H):
;   PC-8801: IN A,(31H) reads the DIP switch (mode select) byte.
;   PC-8001: port 31H has no read device (30H is write-only and is
;            mirrored over 30H-3FH), so FFH is returned.
;   The ROM-switch calls are therefore executed with CALL NZ:
;   they run only on the PC-8801, where ROM switching is needed,
;   and are skipped on the PC-8001.

	cpu	Z80

	org	0e000h

START:
	in	a,(31h)		; machine check: FFH = PC-8001
	cp	0ffh
	call	nz,0f16ch	; PC-8801 only: switch ROM (to N-BASIC side)
	ld	bc,MSG		; BC -> "Hellorld!" string
LOOP:
	ld	a,(bc)		; get one character
	cp	00h		; end of string ?
	jp	z,DONE		; yes -> finish
	call	0257h		; print character in A
	inc	bc		; next character
	jp	LOOP

DONE:
	in	a,(31h)		; machine check again: FFH = PC-8001
	cp	0ffh
	call	nz,0f175h	; PC-8801 only: switch ROM back
	rst	38h		; FFH in the dump: end / break

MSG:
	db	"Hellorld!",00h

	end
