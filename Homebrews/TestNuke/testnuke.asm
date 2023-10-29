WinAPE Z80 Assembler V1.0.13

000001  0000                ; Write this to a file
000002  0000                write "BreadBordZ80.bin"
000004  0000                ; init needed values
000005  0000  (FFFF)        HIMEM 		equ &FFFF
000007  0000                ;where are we in memory?
000008  0000  (0000)        org &0000
000010  0000                Init
000011  0000                	;Init the stackpointer
000012  0000  31 FF FF      	ld SP, HIMEM
000013  0003                	
000014  0003                	;LCD init routine
000015  0003  CD 13 00      	call LCD_Init
000017  0006                Main
000018  0006  CD 79 00      	call LCD_Home
000019  0009  CD 73 00      	call LCD_Clear
000020  000C                	;Pointer to the string
000021  000C  21 2F 01      	ld hl, Hello_Line
000022  000F  CD 66 00      	call LCD_PutStr
000023  0012                	;done
000024  0012  76            	halt
000025  0013                	;jp Main
000001  0013                ;PIO settings
000002  0013                ;Adresses in IO-space
000003  0013  (0000)        LCDPIO_A_Data 		equ &00 ;LCD control
000004  0013  (0001)        LCDPIO_A_Command	equ &01
000005  0013  (0002)        LCDPIO_B_Data		equ &02 ;LCD Data
000006  0013  (0003)        LCDPIO_B_Command	equ &03
000008  0013  (00CF)        LCDPIO_Mode3		equ &CF
000009  0013  (0000)        LCDPIO_Mode3OUT		equ &00
000010  0013  (00FF)        LCDPIO_Mode3IN		equ &FF
000012  0013                ;LCD settings
000013  0013  (0000)        LCD_RS			equ &00
000014  0013  (0001)        LCD_RW			equ &01
000015  0013  (0002)        LCD_E			equ &02
000017  0013                ;LCD constants set here 
000018  0013  (0004)        Init_Loop 		equ &0004
000019  0013                ;DB5 DB4 DB3
000020  0013  (0038)        Init_Command_1 		equ &38
000021  0013                ;DB3 DB2
000022  0013  (000C)        Init_Command_2 		equ &0C
000023  0013                ;DB0
000024  0013  (0006)        Init_Command_3 		equ &06
000025  0013                ;DB1 DB2
000026  0013  (0001)        Init_Command_4 		equ &01
000029  0013                ;DB0
000030  0013  (0001)        LCD_Command_Clear 	equ &01
000031  0013                ;DB1
000032  0013  (0002)        LCD_Command_Home 	equ &02
000034  0013                ;Subroutines
000035  0013                LCD_Init
000036  0013                ;PIO_Init
000036  0013                
000037  0013                ;	call LCDPIO_SET_A_MODE3
000038  0013                ;	call LCDPIO_SET_B_MODE3
000039  0013  CD FF 00      	call LCDPIO_SET_A_OUT
000040  0016  CD 11 01      	call LCDPIO_SET_B_OUT
000041  0019  0E 00         	ld c, &00
000043  001B                LCD_Init_Loop
000044  001B  79            	ld a, c
000045  001C  D6 04         	sub a, Init_Loop
000046  001E  D2 29 00      	jp nc, LCD_Init_Next
000047  0021  3E 38         	ld a, Init_Command_1
000048  0023  CD 88 00      	call CMD_Out_NoWait
000049  0026  0C            	inc c
000050  0027  18 F2         	jr LCD_Init_Loop
000052  0029                LCD_Init_Next
000053  0029  3E 0C         	ld a, Init_Command_2
000054  002B  CD 96 00      	call CMD_Out
000056  002E  3E 06         	ld a, Init_Command_3
000057  0030  CD 96 00      	call CMD_Out
000059  0033  3E 01         	ld a, Init_Command_4
000060  0035  CD 96 00      	call CMD_Out
000061  0038                ;LCD_Init
000062  0038  C9            ret
000064  0039                ;LCD Set X Y Function
000065  0039                ;Register BC holds XY
000066  0039                LCD_SetXY
000067  0039  0D            	dec c
000068  003A  CA 4A 00      	jp z, First_Line
000069  003D  0D            	dec c
000070  003E  CA 51 00      	jp z, Second_Line
000071  0041  0D            	dec c
000072  0042  CA 58 00      	jp z, Third_Line
000073  0045  0D            	dec c
000074  0046  CA 5F 00      	jp z, Fourth_Line
000075  0049                ;We should not end up here, but let's return anyway
000076  0049  C9            ret
000078  004A                ;First line begins on &00, add &80 to enable DB7
000079  004A                First_Line
000080  004A  78            	ld a, b
000081  004B  C6 80         	add a, &80
000082  004D  CD 96 00      	call CMD_Out
000083  0050  C9            ret
000085  0051                ;Second line begins on &40, add &80 to enable DB7 = &c0
000086  0051                Second_Line
000087  0051  78            	ld a, b
000088  0052  C6 C0         	add a, &c0
000089  0054  CD 96 00      	call CMD_Out
000090  0057  C9            ret
000092  0058                ;Third line begins on &14, add &80 to enable DB7 = &94
000093  0058                Third_Line
000094  0058  78            	ld a, b
000095  0059  C6 94         	add a, &94
000096  005B  CD 96 00      	call CMD_Out
000097  005E  C9            ret
000099  005F                ;Fourth line begins on &54, add &80 to enable DB7 = &d4
000100  005F                Fourth_Line
000101  005F  78            	ld a, b
000102  0060  C6 D4         	add a, &d4
000103  0062  CD 96 00      	call CMD_Out
000104  0065  C9            ret
000106  0066                ;Put a 0 ended string on the LCD. (DOES NOT CHECK THE SIZE!!!)
000107  0066                ;Pointer to the string must be in HL
000108  0066                LCD_PutStr
000109  0066  7E            	ld a, (hl)
000110  0067  FE 00         	cp 0
000111  0069  CA 72 00      	jp z, LCD_PutStr_Done
000112  006C  CD A7 00      	call CHAR_Out
000113  006F  23            	inc hl
000114  0070  18 F4         	jr LCD_PutStr
000116  0072                LCD_PutStr_Done
000118  0072                ;LCD_PutStr
000119  0072  C9            ret
000121  0073                LCD_Clear
000122  0073  3E 01         	ld a, LCD_Command_Clear
000123  0075  CD 96 00      	call CMD_Out
000124  0078                ;LCD_Clear
000125  0078  C9            ret
000127  0079                LCD_Home
000128  0079  3E 02         	ld a, LCD_Command_Home
000129  007B  CD 96 00      	call CMD_Out
000130  007E                ;LCD_Home
000131  007E  C9            ret
000133  007F                LCD_Wait
000134  007F  CD C0 00      	call LCD_ReadCommand
000135  0082  CB 7F         	bit 7,a
000136  0084  C2 7F 00      	jp nz, LCD_Wait
000137  0087                ;LCD_Wait
000138  0087  C9            ret
000140  0088                ;During the init we cannot wait for the LCD busy signal
000141  0088                CMD_Out_NoWait
000142  0088                	;prepare a command, write to the PIO port
000143  0088  CD 29 01      	call LCDPIO_B_OUT
000144  008B                	;Clear a, we need it again
000145  008B  AF            	xor a
000146  008C                	;Only set E
000147  008C  CB D7         	set LCD_E, a
000148  008E                	;strobe E 
000149  008E  CD 23 01      	call LCDPIO_A_OUT
000150  0091  AF            	xor a
000151  0092  CD 23 01      	call LCDPIO_A_OUT
000152  0095                ;CMD_Out_NoWait
000153  0095  C9            ret
000155  0096                ;Write a command to the LCD
000156  0096                ;Command must be in register a
000157  0096                CMD_Out
000158  0096                	;Prepare a command, write to the PIO port
000159  0096  CD 29 01      	call LCDPIO_B_OUT
000160  0099                	;Clear a, we need it again
000161  0099  AF            	xor a
000162  009A                	;Only set E
000163  009A  CB D7         	set LCD_E, a
000164  009C                	;strobe E 
000165  009C  CD 23 01      	call LCDPIO_A_OUT
000166  009F  AF            	xor a
000167  00A0  CD 23 01      	call LCDPIO_A_OUT
000168  00A3  CD 7F 00      	call LCD_Wait
000169  00A6                ;CMD_Out
000170  00A6  C9            ret
000172  00A7                ;Write a char to the LCD
000173  00A7                ;The char must be in register a 
000174  00A7                CHAR_Out
000175  00A7                	;Prepare a character, write to the PIO port
000176  00A7  CD 29 01      	call LCDPIO_B_OUT
000177  00AA                	;Clear a, we need it again
000178  00AA  AF            	xor a
000179  00AB                	;Set the RS high
000180  00AB  CB C7         	set LCD_RS, a
000181  00AD  CD 23 01      	call LCDPIO_A_OUT
000182  00B0                	;Strobe E
000183  00B0  CB D7         	set LCD_E, a
000184  00B2  CD 23 01      	call LCDPIO_A_OUT
000185  00B5  AF            	xor a
000186  00B6  CD 23 01      	call LCDPIO_A_OUT
000187  00B9  CD 29 01      	call LCDPIO_B_OUT
000188  00BC  CD 7F 00      	call LCD_Wait
000189  00BF                ;CHAR_Out
000190  00BF  C9            ret
000192  00C0                ;Read de LCD status
000193  00C0                ;Puts the result into register a
000194  00C0                LCD_ReadCommand
000195  00C0                	;Set the b port to input
000196  00C0  CD 1A 01      	call LCDPIO_SET_B_IN
000197  00C3                	;Set the R/W bit high to read.
000198  00C3  AF            	xor a
000199  00C4  CB CF         	set LCD_RW, a
000200  00C6  CD 23 01      	call LCDPIO_A_OUT
000201  00C9                	;Set the E high
000202  00C9  CB D7         	set LCD_E, a
000203  00CB  CD 23 01      	call LCDPIO_A_OUT
000204  00CE                	;Read the databus
000205  00CE  CD 2C 01      	call LCDPIO_B_IN
000206  00D1                	;push BC onto the stack
000207  00D1  C5            	push bc
000208  00D2                	;save the data read
000209  00D2  47            	ld b, a
000210  00D3                	;Reset the R/W and the E
000211  00D3  AF            	xor a
000212  00D4  CD 23 01      	call LCDPIO_A_OUT
000213  00D7                	;recover the data into a
000214  00D7  78            	ld a, b
000215  00D8                	;get BC values back from the stack
000216  00D8  C1            	pop bc
000217  00D9                	;Set the b port to output again
000218  00D9  CD 11 01      	call LCDPIO_SET_B_OUT
000219  00DC                ;LCD_ReadCommand
000220  00DC  C9            ret
000222  00DD                ;Read de LCD Char RAM
000223  00DD                ;Register BC holds XY
000224  00DD                ;Puts the result into register a
000225  00DD                LCD_ReadCHAR
000226  00DD                	;Set the XY we want to read
000227  00DD  CD 39 00      	call LCD_SetXY
000228  00E0  AF            	xor a
000229  00E1                	;Set the b port to input
000230  00E1  CD 1A 01      	call LCDPIO_SET_B_IN
000231  00E4                	;Set the RS bit high to read.
000232  00E4  CB C7         	set LCD_RS, a
000233  00E6                	;Set the R/W bit high to read.
000234  00E6  CB CF         	set LCD_RW, a
000235  00E8  CD 23 01      	call LCDPIO_A_OUT
000236  00EB                	;Set the E high
000237  00EB  CB D7         	set LCD_E, a
000238  00ED  CD 23 01      	call LCDPIO_A_OUT
000239  00F0                	;Read the databus
000240  00F0  CD 2C 01      	call LCDPIO_B_IN
000241  00F3                	;push BC onto the stack
000242  00F3  C5            	push bc
000243  00F4                	;save the data read
000244  00F4  47            	ld b, a
000245  00F5                	;Reset the R/W and the E
000246  00F5  AF            	xor a
000247  00F6  CD 23 01      	call LCDPIO_A_OUT
000248  00F9                	;Set the b port to output again
000249  00F9  CD 11 01      	call LCDPIO_SET_B_OUT
000250  00FC                	;recover the data into a
000251  00FC  78            	ld a, b
000252  00FD                	;get BC values back from the stack
000253  00FD  C1            	pop bc
000254  00FE                ;LCD_ReadCHAR
000255  00FE  C9            ret
000257  00FF                ;PIO routines
000258  00FF                ;Set port A in mode 3
000259  00FF                ;LCDPIO_SET_A_MODE3
000259  00FF                
000260  00FF                ;	ld a, LCDPIO_Mode3
000261  00FF                ;	out (LCDPIO_A_Command), a
000262  00FF                ;ret
000264  00FF                ;Set port A as outputs
000265  00FF                LCDPIO_SET_A_OUT
000266  00FF  3E CF         	ld a, LCDPIO_Mode3
000267  0101  D3 01         	out (LCDPIO_A_Command), a
000268  0103  3E 00         	ld a, LCDPIO_Mode3OUT
000269  0105  D3 01         	out (LCDPIO_A_Command), a
000270  0107  C9            ret
000272  0108                ;Set port A as inputs
000273  0108                LCDPIO_SET_A_IN
000274  0108  3E CF         	ld a, LCDPIO_Mode3
000275  010A  D3 01         	out (LCDPIO_A_Command), a
000276  010C  3E FF         	ld a, LCDPIO_Mode3IN
000277  010E  D3 01         	out (LCDPIO_A_Command), a
000278  0110  C9            ret
000280  0111                ;Set port B in mode 3
000281  0111                ;LCDPIO_SET_B_MODE3
000281  0111                
000282  0111                ;	ld a, LCDPIO_Mode3
000283  0111                ;	out (LCDPIO_B_Command), a
000284  0111                ;ret
000286  0111                ;Set port B as outputs
000287  0111                LCDPIO_SET_B_OUT
000288  0111  3E CF         	ld a, LCDPIO_Mode3
000289  0113  D3 03         	out (LCDPIO_B_Command), a
000290  0115  3E 00         	ld a, LCDPIO_Mode3OUT
000291  0117  D3 03         	out (LCDPIO_B_Command), a
000292  0119  C9            ret
000294  011A                ;Set port B as inputs
000295  011A                LCDPIO_SET_B_IN
000296  011A  3E CF         	ld a, LCDPIO_Mode3
000297  011C  D3 03         	out (LCDPIO_B_Command), a
000298  011E  3E FF         	ld a, LCDPIO_Mode3IN
000299  0120  D3 03         	out (LCDPIO_B_Command), a
000300  0122  C9            ret
000302  0123                ;Transmit to port a
000303  0123                LCDPIO_A_OUT
000304  0123  D3 00         	out (LCDPIO_A_Data), a
000305  0125  C9            ret
000307  0126                ;Read in port a
000308  0126                LCDPIO_A_IN
000309  0126  DB 00         	in a, (LCDPIO_A_Data)
000310  0128  C9            ret
000312  0129                ;Transmit to port b
000313  0129                LCDPIO_B_OUT
000314  0129  D3 02         	out (LCDPIO_B_Data), a
000315  012B  C9            ret
000317  012C                ;Read in port b
000318  012C                LCDPIO_B_IN
000319  012C  DB 02         	in a, (LCDPIO_B_Data)
000320  012E  C9            ret
000027  012E  C9            read "Hd44780_PIO.asm"
000029  012F                Hello_Line
000030  012F  48 65 6C 6C   	db 'Hellord!',0
        0133  6F 72 64 21 
        0137  00 
