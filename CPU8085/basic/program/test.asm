.module 	programtest
.title 		Tests program Module

.include	'program.def'
.include	'..\common\common.def'
.include	'..\io\io.def'
.include	'..\error\error.def'
.include	'..\expreval\expreval.def'
.include	'..\integer\integer.def'
.include	'..\strings\strings.def'
.include	'..\variables\variable.def'

STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	DI
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START


;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS

	; IO INIT
	CALL	IO_INIT
	LXI	H,0
	SHLD	PRG_CURRLINE

	CALL	INT_INIT
	CALL	EXP_INIT

	; TEST PROGRAM
	LXI	H,TESTPRG1		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	
	LXI	H,TESTPRG4END
	SHLD	PRG_HIPTR
	SHLD	VAR_LOPTR
	SHLD	VAR_HIPTR
	
	CALL	PRG_INIT	

	; SET STR PTRS
	LXI	H,0xA000
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

	; SET ZZ = 70
	MVI	B,'Z
	MVI	C,'Z
	MVI	A,SID_CINT
	STA	VAR_TEMP1
	LXI	H,70
	SHLD	VAR_TEMP1+1
	LXI	H,VAR_TEMP1
	CALL	VAR_SET

;	JMP	TEST_LIST
;	JMP	TEST_FIND
;	JMP	TEST_INSERT
;	JMP	TEST_REMOVE
	JMP	TEST_RUN

TEST_LIST:
	CALL	PRG_LIST


TEST_FIND:
	LXI	B,10
	CALL	PRG_FIND
	CALL	IO_PUTHLHEX
	CALL	IO_PUTCR

	LXI	B,40
	CALL	PRG_FIND
	CALL	IO_PUTHLHEX
	CALL	IO_PUTCR

	LXI	B,5
	CALL	PRG_FIND
	CALL	IO_PUTHLHEX
	CALL	IO_PUTCR

	LXI	B,25
	CALL	PRG_FIND
	CALL	IO_PUTHLHEX
	CALL	IO_PUTCR


TEST_INSERT:
	CALL	PRG_LIST
	CALL	IO_PUTCR
	
	; INSERT LINE 25
	LXI	B,25
	MVI	A,6
	LXI	H,TESTINSERT1
	CALL	PRG_INSERT	
	
	CALL	PRG_LIST
	CALL	IO_PUTCR
	
	; INSERT LINE 1
	LXI	B,1
	MVI	A,6
	LXI	H,TESTINSERT1
	CALL	PRG_INSERT	

	CALL	PRG_LIST
	CALL	IO_PUTCR

	; INSERT LINE 666
	LXI	B,666
	MVI	A,12
	LXI	H,TESTINSERT2
	CALL	PRG_INSERT	

	CALL	PRG_LIST
	CALL	IO_PUTCR

	; REPLACE LINE 10
	LXI	B,10
	MVI	A,12
	LXI	H,TESTINSERT2
	CALL	PRG_INSERT	

	CALL	PRG_LIST
	CALL	IO_PUTCR

	; REPLACE LINE 1
	LXI	B,1
	MVI	A,12
	LXI	H,TESTINSERT2
	CALL	PRG_INSERT	

	CALL	PRG_LIST
	CALL	IO_PUTCR


TEST_REMOVE:
	; REMOVE LINE 1
	LXI	B,1
	CALL	PRG_REMOVE

	CALL	PRG_LIST
	CALL	IO_PUTCR

	; REMOVE LINE 25
	LXI	B,30
	CALL	PRG_REMOVE

	CALL	PRG_LIST
	CALL	IO_PUTCR

	; REMOVE LINE 1
	LXI	B,666
	CALL	PRG_REMOVE

	CALL	PRG_LIST
	CALL	IO_PUTCR

TEST_RUN:
	LXI	H,LOOP
	SHLD	ERR_RESTARTPTR

	CALL	PRG_LIST
	CALL	IO_PUTCR
	
	CALL	PRG_RUN

LOOP:
	JMP	LOOP

.area	DATA	(REL,CON)

TESTPRG1:	
	.db	TESTPRG1END-TESTPRG1	; SIZE
	.dw	10			; LINE NO
	.db	K_PRINT,32,SID_CINT .dw 1234 .db 0
TESTPRG1END:
TESTPRG2:	
	.db	TESTPRG2END-TESTPRG2	; SIZE
	.dw	20			; LINE NO
	.db	K_LET,32,SID_VAR,'A,'B,32,K_EQUAL,32,SID_CINT .dw -6666 .db 0
TESTPRG2END:
TESTPRG3:	
	.db	TESTPRG3END-TESTPRG3	; SIZE
	.dw	30			; LINE NO
	.db	K_PRINT,32,SID_VAR,'A,'B,32,', ,SID_CSTR,4 .ascii "ABCD" .db 0
TESTPRG3END:
TESTPRG4:	
	.db	TESTPRG4END-TESTPRG4	; SIZE
	.dw	40			; LINE NO
	.db	K_GOTO,32,SID_CINT .dw 10 .db 0
TESTPRG4END:

	.ds	64

TESTINSERT1:
	.db	K_PRINT,32,SID_VAR,128+'A,00 .db 0
TESTINSERT2:
	.db	K_LET,32,SID_VAR,'Z,00,32,K_EQUAL,32,SID_CINT .dw 6789 .db 0


;OUTSTR:	.ds 128

