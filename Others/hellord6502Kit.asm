; $Id: hellord.asm 516 2023-11-18 20:17:46Z mkarcz $
;-----------------------------------------------------------------------------
; LCD driver for 6502 KIT
;-----------------------------------------------------------------------------

BUSY              .EQU 80H

; below LCD's registers are mapped into memory space

command_write     .EQU 9000H
data_write        .EQU 9001H
command_read      .EQU 9002H
data_read         .EQU 9003H
                 
                 .cseg 

		 .org 200h

		 jmp main

mytext01        .byte "MOS 6502 Kit", 0
mytext02        .byte "Hellorld!", 0

; wait until LCD ready bit set

LcdReady       PHA
ready          LDA command_read
               AND #BUSY
               BNE ready   ; loop if busy flag = 1
               PLA
		         RTS

LCD_command_write 
               JSR LcdReady
               STA command_write
		         RTS
                  

LCD_data_write JSR LcdReady
               STA data_write
               RTS


clr_screen     JSR LcdReady
               LDA #1
		         JSR LCD_command_write
               RTS

InitLcd        LDA #38H
               JSR LCD_command_write
               LDA #0CH
	            JSR LCD_command_write
               JSR clr_screen
               LDX #0
		         LDY #0
		         JSR goto_xy
               RTS
		

; goto_xy(x,y)
; entry: A = y position
;        B = x position

goto_xy        TXA
               CMP #0
		         BNE case1
               TYA
		         CLC
               ADC #80H
               JSR LCD_command_write
		         RTS
                 
case1          CMP #1
               BNE case2
               TYA
		         CLC
		         ADC #0C0H
		         JSR LCD_command_write
		         RTS
                 
case2          RTS

; write ASCII code to LCD at current position
; entry: A

putch_lcd      JSR LcdReady
               JSR LCD_data_write
               RTS

;-----------------------------------------------------------------------------
		
main           JSR InitLcd
               LDX #0
l001           LDA mytext01,x
               BEQ nxttext
		         JSR putch_lcd
               INX
               BNE l001
nxttext        LDY #0
               LDX #1
               JSR goto_xy
               LDX #0
l002           LDA mytext02,x
               BEQ finished
		         JSR putch_lcd
               INX
               BNE l002
finished

		         BRK
               BRK

		 .org 300h

               JSR InitLcd
               BRK
               BRK

		.END


