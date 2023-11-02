; Hellord challenge on the Maniek86 6502 homebrew computer. Text is displayed on ST7920 128x64 LCD connected to Port A of 8255 I/O
; 
; 8255 is mapped at $B000
;
; LCD pinout:
; D4 - PA0
; D5 - PA1
; D6 - PA2
; D7 - PA3
; 
; RST - Reset from any expansion port
; RS - PA6
; EN - PA7
; 

IO_CTRL = $B003
IO_PORTA = $B000
IO_PORTB = $B001


.segment "ROM"
.org $C000

wait:                   ; wait for the LCD
    PHA                 ; Preserve registers
    TXA
    PHA
    TYA
    PHA
    
    LDY #4             ; 16 * 256 = 1024, when CPU is running at 1 MHz then this will be 2 MS * instructions cycles which is here about 14 MS?
 
    @loopY:
    LDX #$FF
    
    @loopX:
    DEX
    CPX #$00
    BNE @loopX
    
    DEY
    CPY #$00
    BNE @loopY
    
    PLA             ; Restore registers
    TAY
    PLA
    TAX
    PLA
    RTS
    
send_byte:              ; Send byte to display stored in A, and if X is #$FF set RS
    ; We transfer 4 higher bits first and then 4 lower bits
    
    TAY                 ; Store byte in Y for later
    
    
    LSR A               ; Shift the higher bytes in A
    LSR A
    LSR A
    LSR A
    
    JSR @send_nibble    ; Send higher bits
    
    TYA
    
    JSR @send_nibble    ; Send lower bits
    
    RTS
    
        @send_nibble:
        
        AND #%00001111      ; Keep only lower bits
        ORA #%10000000      ; Set EN bit
        
        CPX #$FF
        BNE @noRS
        
        ORA #%01000000      ; Set RS bit if X is #$FF
        
        @noRS:
        
        STA IO_PORTA           ; Set PORT_A pins
        JSR wait            ; Wait for LCD
        
        AND #%01111111      ; clear EN bit
        STA IO_PORTA           
        JSR wait            ; And wait again for LCD
        
        RTS
    
    
    

start:
    LDX #$FF            ; Init stack and disable interrupts and turn decimal mode off
    TXS
    SEI
    CLD
    
    LDA #%10001001      ; Configure port C as input, ports A and B as outputs
    STA IO_CTRL
    LDA #%10000000      ; Lets lit up the LED connected to PB7 on the PCB (to confirm the code is working)
    STA IO_PORTB
    
    JSR wait            
    JSR wait            ; wait a bit for LCD to fully reset
    JSR wait
        
    
    ; LCD init
    LDA #%10000010      ; EN = 1, RS = 0, init LCD in 4-bit interface. This doesn't change RE as datasheet states that you can't change DL (4/8 bit interface) and RE (extended instr. set) at once
    STA IO_PORTA
    
    JSR wait            ; wait for LCD
    AND #%01111111      ; clear EN bit
    STA IO_PORTA           
    JSR wait            ; And wait again for LCD
    
    ; Now we can use send_byte subroutine 
    
    LDX #$00            ; RS = 0 (instr)
    LDA #%00001100      ; Display on; cursor off; blink off
    JSR send_byte
    
    LDA #%00000110      ; Entry mode
    JSR send_byte
    
    LDA #%00000001      ; Clear display
    JSR send_byte
    
    ; We are in basic instruction set which is text only, so lets print the "Hellord!"
    
    LDY #$00            ; String pointer
    
    @loop:
    LDX #$FF            ; RS = 1 (data)
    
    TYA                 ; send_byte destroys Y, so we need to save it before loading char
    PHA
        
    LDA message, Y      ; load char and display it
    JSR send_byte
    
    PLA                 ; restore Y
    TAY
    
    LDA message, Y      ; we need to load again char as send_byte destroyed A too
    CMP #$00            ; if end of string, break
    BEQ end
    
    INY                 ; Increase Y
    
    JMP @loop
    
end:
    JMP end

message:
    .byte	"Hellorld!", $00
    
    
.segment "VECTS"
.org $FFFA
	.word	start		; NMI 
	.word	start		; RESET 
	.word	start		; IRQ 
