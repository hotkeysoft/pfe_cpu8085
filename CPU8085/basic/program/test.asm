.module 	programtest
.title 		Tests program Module

.include	'program.def'
.include	'..\common\common.def'
.include	'..\io\io.def'
.include	'..\error\error.def'

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


	LXI	H,0xA000		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	
	CALL	PRG_INIT

LOOP:
	JMP	LOOP


;TESTSTR1:	.asciz	''

.area	DATA	(REL,CON)

;OUTSTR:	.ds 128
