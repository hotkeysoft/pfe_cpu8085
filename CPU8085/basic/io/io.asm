.module 	io
.title 		Input/Output module (term+sound)

.include	'..\common\common.def'

TIMER	=	0x40			;TIMER PORT BASE
T_C0	=	TIMER+0			;COUNTER 0
T_C1	=	TIMER+1			;COUNTER 1
T_C2	=	TIMER+2			;COUNTER 2
T_CWR	=	TIMER+3			;CONTROL WORD REGISTER

UART	=	0x60			;UART PORT BASE
U_RBR	=	UART+0			;RECEIVER BUFFER REGISTER (READ ONLY)
U_THR	=	UART+0			;TRANSMITTER HOLDING REGISTER (WRITE ONLY)
U_IER	=	UART+1			;INTERRUPT ENABLE REGISTER
U_IIR	=	UART+2			;INTERRUPT IDENTIFICATION REGISTER (READ ONLY)
U_LCR	=	UART+3			;LINE CONTROL REGISTER
U_MCR	=	UART+4			;MODEM CONTROL REGISTER
U_LSR	=	UART+5			;LINE STATUS REGISTER
U_MSR	=	UART+6			;MODEM STATUS REGISTER
U_SCR	=	UART+7			;SCRATCH REGISTER
U_DLL	=	UART+0			;DIVISOR LATCH (LSB)
U_DLM	= 	UART+1			;DIVISOR LATCH (MSB)

MISC	=	0x80			;MISC GATES

TERM_ATTN = 	1

.area	BOOT	(ABS)

;*********************************************************
.org	0x0024
RST45:
	DI
	JMP	INTTI0

;*********************************************************
.org	0x0034
RST65:
	DI
	JMP	INTUART

.area	_CODE

;*********************************************************
;* IO_INIT:  INITIALIZES MODULE
IO_INIT::
	CALL	IO_INITMISC		;INITIALIZE MISC OUTPUTS
	CALL	IO_INITTIMER		;INITIALIZE TIMER
	CALL	IO_INITUART		;INITIALIZE UART	
	CALL	IO_INITKBBUF		;INITIALIZE KEYBOARD BUFFER

	MVI	A,7			;LIGHT GRAY FG, BLACK BG
	CALL	IO_SETCOLOR		;SET CURRENT ATTRIBUTE
	
	CALL	IO_HOME			;SET CURRENT POS (HOME)
	CALL	IO_CLS			;CLEARS THE SCREEN
	RET

;*********************************************************
;* UART ROUTINES
;*********************************************************

;*********************************************************
;* IO_INITKBBUF:  INITIALIZES KEYBOARD BUFFER
IO_INITKBBUF:
	LXI	H,0			;HL = 0
	SHLD	IO_KBUFPTR		;WORD AT IOKBUFPTR = 0
	RET

;*********************************************************
;* IO_INITUART:  INITIALIZES UART
IO_INITUART:
.if ~DEBUG
	MVI	A,0xA0			;SET DLA MODE
	OUT	U_LCR		
	
	MVI	A,0x0C			;BAUD RATE SETUP
	OUT	U_DLL			;9600 BAUDS
	MVI	A,0x00		
	OUT	U_DLM
	
	MVI	A,0x03			;LCR SETUP
	OUT	U_LCR			;8 DATA, 1 STOP, NO PARITY, DLA_OFF
	
	MVI	A,0x01			;INTERRUPT ENABLE REGISTER
	OUT	U_IER			;ENABLE RECEIVED DATA AVAILABLE INTERRUPT
.endif
	RET

;********************************************************
; INTUART:  INTERRUPT HANDLER FOR UART (STUFF A CHAR IN THE KB BUFFER)
INTUART:
	PUSH	PSW
	PUSH	D
	PUSH	H
	
	LHLD	IO_KBUFPTR		;LOAD HL WITH WORD AT IOKBUFPTR

	MOV	A,H			;HI PTR IN A
	INR	A			;HI PTR + 1
	ANI	0x0F			;HI PTR MOD 16
	MOV	H,A			;BACK IN H
	
	CMP	L			;COMPARE NEW HI PTR WITH LO PTR	

	JZ	1$			;IF PTRS ARE EQUAL, BUFFER IS FULL
	
	SHLD	IO_KBUFPTR		;PUT BACK UPDATED PTR AT IOKBUFPTR

	DCR	A			;HI PTR -1
	ANI	0x0F			;HI PTR MOD 16
	
	MOV	E,A			;0-H IN D-E (OFFSET TO ADD TO BUF ADDRESS)
	MVI	D,0
		
	LXI	H,IO_KBUF		;ADDRESS OF KB BUF IN H-L
	
	DAD	D			;NEW ADDRESS IN H-L

	IN	U_RBR			;GET THE BYTE
	
	MOV	M,A			;NEW CHAR READ -> KB BUFFER
	
	JMP 	2$
1$:
	IN	U_RBR			;GET THE BYTE, DO NOTHING WITH IT

2$:
	POP	H
	POP 	D
	POP	PSW
	EI
	RET

;********************************************************
; IO_GETCHAR:  GETS A CHAR FROM KEYBOARD BUFFER (RETURNED IN ACC - 0 IF EMPTY)
IO_GETCHAR::
	PUSH	B
	PUSH	D
	PUSH	H
	
	LHLD	IO_KBUFPTR		;LOAD HL WITH WORD AT IOKBUFPTR

	MOV	A,L			;LO PTR IN A
	
	CMP	H			;COMPARE LO PTR WITH HI PTR
	
	JZ	1$			;IF PTRS ARE EQUAL, BUFFER IS EMPTY

	MOV	C,L			;0-L IN B-C (OFFSET TO ADD TO BUF ADDRESS)
	MVI	B,0

	XCHG				;HL <-> DE
		
	LXI	H,IO_KBUF		;ADDRESS OF KB BUF IN H-L
	
	DAD	B			;NEW ADDRESS IN H-L
	
	MOV	B,M			;KB BUFFER -> B

	XCHG				;HL <-> DE

	MOV	A,L

	INR	A			;LO PTR + 1
	ANI	0x0F			;LO PTR MOD 16
	MOV	L,A			;BACK IN LO

	SHLD	IO_KBUFPTR		;PUT BACK UPDATED PTR AT IOKBUFPTR
	
	MOV	A,B		
	
	JMP 	2$
	
1$:
	MVI	A,0			;NOTHING IN BUFFER

2$:
	POP	H
	POP 	D
	POP	B
	RET


;*********************************************************
;* OUTPUT ROUTINES
;*********************************************************

;********************************************************
; IO_PUTC: SENDS A CHAR (FROM ACC) TO THE TERMINAL
IO_PUTC::
.if ~DEBUG
	PUSH	PSW
	
1$:	
	IN	U_LSR			;LINE STATUS REGISTER
	ANI	0x20			;CHECK IF UART IS READY
	JZ	1$			;IF NOT, WAIT FOR IT

	POP	PSW			;GET BACK CHAR

.endif
	OUT	U_THR	
	
	RET

;********************************************************
; IO_PUTCR: PRINTS NEW LINE CHARACTER
IO_PUTCR::
	MVI	A,13
	JMP	IO_PUTC

;********************************************************
; IO_PUTS: PUTS STRING - TERMINATED BY NULL OR HI BYTE=1
;	   PRE TO STRING IN HL
IO_PUTS::
	PUSH	PSW
	PUSH	H
	
1$:
	MOV	A,M		;LOAD CHAR FROM MEMORY
	ORA	A		;END OF STRING?
	JZ	2$
	JM	2$

	CALL 	IO_PUTC		;PRINT CHAR
	
	INX	H		;INCREMENT ADDRESS	
	
	JMP	1$		;LOOP
	
2$:
	POP	H
	POP	PSW
	RET

;********************************************************
; IO_PUTSN: PUTS STRING - LENGTH IN B, PTR IN HL
IO_PUTSN::
	PUSH	PSW
	PUSH	B
	
1$:
	MOV	A,B		; CHECK COUNT
	ORA	A		; CHECK IF ZERO
	JZ	2$
	
	MOV	A,M		;LOAD CHAR FROM MEMORY

	CALL 	IO_PUTC		;PRINT CHAR
	
	INX	H		;INCREMENT ADDRESS
	DCR	B
	
	JMP	1$		;LOOP
	
2$:
	POP	B
	POP	PSW
	RET
	
;********************************************************
; IO_PUTCB: PRINTS A BYTE (ACC) IN BINARY (I.E. 10011010)
IO_PUTCB::
	PUSH	PSW
	PUSH	B
	
	MOV	C,A		;KEEP IN NUMBER IN C
	
	MVI	B,8		;8 BINARY DIGITS
1$:
	MOV	A,C		;GET NUMBER
	RAL			;SHIFT LEFT
	MOV	C,A		;PUT BACK IN C
	JC	2$		;0 OR 1?
	
	MVI	A,#'0		;WE HAVE A ZERO
	JMP 	3$	
2$:
	MVI	A,#'1		;WE HAVE A ONE
	
3$:
	CALL	IO_PUTC		;PRINT THE BIT

	DCR	B		;LOOP FOR 8 BITS
	JNZ	1$
	
	POP	B
	POP	PSW
	RET

;********************************************************
; IO_PUTCH: PRINTS A BYTE (ACC) IN HEX
IO_PUTCH::
	PUSH	PSW		;SAVE LOW DIGIT
	RRC			;MAKE HIGH.
	RRC			;DIGIT.
	RRC			;INTO.
	RRC			;LOW DIGIT.
	CALL	IO_PUTN		;PRINT HIGH DIGIT
	POP	PSW		;GET LOW DIGIT BACK
	CALL	IO_PUTN		;PRINT LOW DIGIT
	RET
	
;********************************************************	
; IO_PUTN: DISPLAYS NIBBLE IN LOWER 4 BITS OF A ('0'..'F')
IO_PUTN:
	PUSH	PSW
	ANI	0x0F		;GET RID OF EXCESS BAGGAGE
	ADI	0x30		;CONVERT TO ASCII NUMBER
	CPI	0x3A		;TEST FOR ALPHA CHARACTER
	JC	1$		;IF NOT, WE ARE OK
	ADI	7		;CONVERT TO CHARACTER
1$:	
	CALL	IO_PUTC
	POP	PSW
	RET

;********************************************************
; IO_PUTHLHEX: SHOW 16 BIT VALUE OF HL IN HEX
IO_PUTHLHEX::
	PUSH 	PSW
	MOV	A,H		;GET H
	CALL	IO_PUTCH	;DISPLAY H IN HEX
	MOV	A,L		;GET L
	CALL	IO_PUTCH	;DISPLAY L IN HEX
	POP	PSW
	RET

;*********************************************************
;* IO_CLS:  CLEARS SCREEN (FILL WITH CURRENT ATTRIBUTE)
IO_CLS::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,1			;TERM:CLS
	CALL	IO_PUTC
	RET

;********************************************************
; IO_HOME: MOVE CURSOR TO HOME POSITION (0,0)
IO_HOME::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,12			;TERM:HOME
	CALL	IO_PUTC
	RET


;*********************************************************
;* IO_GOTOXY:  SET CURSOR POSITION;  X-Y IN H-L
IO_GOTOXY::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,11			;TERM:GOTOXY
	CALL	IO_PUTC
	
	MOV	A,H			;TERM:X
	CALL	IO_PUTC
	
	MOV	A,L			;TERM:Y
	CALL	IO_PUTC			

	RET

;*********************************************************
;* IO_SCROLLUP:  SCROLLS THE SCREEN ONE LINE
IO_SCROLLUP::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,3			;TERM:SCROLLUP
	CALL	IO_PUTC

	RET


;********************************************************
; IO_MOVEUP: MOVE CURSOR ONE LINE UP
IO_MOVEUP::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,4			;TERM:MOVEUP
	CALL	IO_PUTC

	RET

;********************************************************
; IO_MOVEDOWN: MOVE CURSOR ONE LINE DOWN
IO_MOVEDOWN::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,5			;TERM:MOVEDOWN
	CALL	IO_PUTC

	RET

;********************************************************
; IO_MOVELEFT: MOVE CURSOR ONE CHAR LEFT
IO_MOVELEFT::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,6			;TERM:MOVELEFT
	CALL	IO_PUTC

	RET
	

;********************************************************
; IO_MOVERIGHT: MOVE CURSOR ONE CHAR RIGHT
IO_MOVERIGHT::
	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,7			;TERM:MOVERIGHT
	CALL	IO_PUTC
	RET


;*********************************************************
;* IO_SETFG:  SET FOREGROUND COLOR (IN ACC) (0-15)
IO_SETFG::
	PUSH	PSW
	PUSH	B
	
	ANI	0x0F		;CLEAR USELESS BITS
	MOV 	B,A		;FG COLOR IN B
	
	LDA	IO_CURRATTR	;CURRENT COLOR IN ACC
	ANI	0xF0		;CLEAR UPPER BITS
	
	ORA	B		;MERGE WITH BG COLOR
	
	CALL	IO_SETCOLOR	;STORE NEW ATTR VALUE
	
	POP	B
	POP	PSW
	RET

;*********************************************************
;* IO_SETBG:  SET BACKGROUND COLOR (IN ACC) (0-15)
IO_SETBG::
	PUSH	PSW
	PUSH	B
	
	ANI	0x0F		;CLEAR USELESS BITS
	RLC
	RLC
	RLC			;SHIFT 4 BITS TO THE LEFT
	RLC				
	MOV 	B,A		;BG COLOR IN B
	
	LDA	IO_CURRATTR	;CURRENT COLOR IN ACC
	ANI	0x0F		;CLEAR UPPER BITS
	
	ORA	B		;MERGE WITH BG COLOR
	
	CALL	IO_SETCOLOR	;STORE NEW ATTR VALUE
	
	POP	B	
	POP	PSW
	RET

;*********************************************************
;* IO_SETCOLOR:  SET COLOR; COMBINED COLOR IN ACC
IO_SETCOLOR::
	PUSH	PSW

	MVI	A,TERM_ATTN		;TERM:ATTN
	CALL	IO_PUTC
	MVI	A,2			;TERM:SETCOLOR
	CALL	IO_PUTC

	POP	PSW
	CALL	IO_PUTC			;TERM:ATTRIBUTE
	
	STA	IO_CURRATTR		;STORE ATTRIBUTE
	
	RET

;*********************************************************
;* TIMER ROUTINES
;*********************************************************

;*********************************************************
;* IO_INITTIMER:  INITIALIZES TIMERS
IO_INITTIMER:
	LXI	H,0x0000		;CLEAR H-L
	SHLD	TICNT			;H-L IN WORD AT 'TICNT'

.if ~DEBUG
;* SET COUNTER 0	

	MVI	A,0x36			;COUNTER 0, LSB+MSB, MODE 2, NOBCD
	OUT	T_CWR
	
;* SOURCE:14400HZ,  DEST:10HZ, DIVIDE BY 1440 (0x05A0)

	MVI	A,0xA0			;LSB
	OUT	T_C0
	
	MVI	A,0x05			;MSB
	OUT	T_C0
	
;* ENABLE OUTPUT
	IN	MISC
	ORI	1			;SET BIT 0
	OUT 	MISC	
	
;* SET COUNTER 1

;* SET COUNTER 2

	MVI	A,0xB6			;COUNTER 2, LSB+MSB, MODE 3, NOBCD
	OUT	T_CWR
.endif

	RET

;*********************************************************
;* INTTI0:  INTERRUPT HANDLER FOR TIMER 0. INCREMENTS TICNT
INTTI0:
	PUSH	H
	
	LHLD	TICNT
	INX	H
	SHLD	TICNT
	POP	H
	
	EI
	RET


;*********************************************************
;* IO_BEEP:  MAKES A 440HZ BEEP FOR 1/2 SECOND
IO_BEEP::
.if ~DEBUG
	PUSH 	PSW
	
	MVI	A,45			;LA4 440HZ
	CALL	IO_SOUNDON
	MVI	A,5		
	CALL 	IO_DELAY		;WAIT 5 * 100 MS
	CALL	IO_SOUNDOFF
	
	POP	PSW
.endif	
	RET

;*********************************************************
;* IO_SOUNDON:  PROGRAMS COUNTER 0 AND ENABLES SOUND OUTPUT
IO_SOUNDON::
.if ~DEBUG

	PUSH 	PSW
	PUSH	B
	
	CALL	IO_SOUNDOFF		;TURNS OFF SOUND BEFORE REPROGRAMMING
	
	RLC				;OFFSET *= 2 (TABLE CONTAINS WORDS)

	MVI	B,0
	MOV	C,A			;OFFSET IN B-C
	
	LXI	H,NOTES			;TABLE BASE IN H-L
	DAD	B			;ADD OFFSET TO H-L
	
	MOV	A,M			;BYTE AT H-L IN A (NOTE LSB)
	
	OUT	T_C2			;DIVIDER LSB TO COUNTER
	
	INX	H			;H-L POINTS TO NEXT BYTE
	MOV	A,M			;BYTE AD H-L IN A (NOTE MSB)
	
	OUT	T_C2			;DIVIDER MSB TO COUNTER	
	
	IN	MISC			;INPUT MISC REGISTER
	ORI	0x04			;TURNS ON BIT 2
	OUT	MISC			;OUTPUT MISC REGISTER
	
	POP	B
	POP	PSW	
.endif
	RET

;*********************************************************
;* IO_SOUNDOFF:  DISABLES SOUND OUTPUT
IO_SOUNDOFF::
.if ~DEBUG
	PUSH 	PSW
	
	IN	MISC			;INPUT MISC REGISTER
	ANI	0xFB			;TURNS OFF BIT 2
	OUT	MISC			;OUTPUT MISC REGISTER
	
	POP	PSW
.endif	
	RET


;*********************************************************
;* MISC ROUTINES
;*********************************************************
IO_INITMISC:
.if ~DEBUG
	MVI	A,0			;ALL OUTPUTS LOW
	OUT	MISC
.endif	
	RET

;*********************************************************
;* IO_DELAY, WAITS ACC * 100MS
IO_DELAY::
.if ~DEBUG
	PUSH 	PSW
	PUSH 	H
	PUSH	D

	LHLD	TICNT			;LOAD CURRENT COUNT IN H-L

	MOV	E,A			;COUNT IN D-E
	MVI	D,0
	
	DAD	D			;ADD TO H-L
	
	XCHG				;EXCHANGE D&E, H&L, TARGET NOW IN D-E
	
1$:	LHLD	TICNT			;LOAD CURRENT COUNT IN H-L

	MOV	A,H			;MSB IN A
	XRA	D			;COMPARE WITH MSB OF TARGET
	JNZ	1$			;DIFFERENT -> LOOP
	
	MOV	A,L			;LSB IN A
	XRA	E			;COMPARE WITH LSB OF TARGET
	JNZ	1$			;DIFFERENT -> LOOP	
	
;* WE ARE DONE!
	
	POP	D
	POP	H
	POP 	PSW
.endif	
	RET


NOTES:	.dw	0xDC29,0xCFCE,0xC424,0xB922,0xAEBE,0xA4EF,0x9BAE,0x92F1,0x8AB1,0x82E9,0x7B90,0x74A0
	.dw	0x6E15,0x67E7,0x6212,0x5C91,0x575F,0x5278,0x4DD7,0x4978,0x4559,0x4174,0x3DC8,0x3A50
	.dw	0x370A,0x33FA,0x3109,0x2E49,0x2BB0,0x293C,0x26EB,0x24BC,0x22AC,0x20BA,0x1EE4,0x1D28
	.dw	0x1B85,0x19FA,0x1885,0x1724,0x15D8,0x149E,0x1376,0x125E,0x1156,0x105D,0x0F72,0x0E94
	.dw	0x0DC3,0x0CFD,0x0C42,0x0B92,0x0AEC,0x0A4F,0x09BB,0x092F,0x08AB,0x082F,0x07B9,0x074A
	.dw	0x06E1,0x067E,0x0621,0x05C9,0x0576,0x0527,0x04DD,0x0498,0x0456,0x0417,0x03DC,0x03A5
	.dw	0x0371,0x033F,0x0311,0x02E5,0x02BB,0x0294,0x026F,0x024C,0x022B,0x020C,0x01EE,0x01D3

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

TICNT:		.ds	2			;TIMER - COUNTER

IO_KBUF:	.ds	16			;KEYBOARD BUFFER
IO_KBUFPTR:	.ds	2			;KEYBOARD BUFFER - BEGIN/END PTR

IO_CURRATTR:	.ds	1			;CONSOLE - CURRENT ATTRIBUTE



