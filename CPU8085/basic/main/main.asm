;*********************************************************
;* MODULE:	MAIN
;* 
;* DESCRIPTION:	SETUP OF MODULES, MAIN LOOP
;*
;* $Id: main.asm,v 1.11 2002-01-26 23:38:05 Dominic Thibodeau Exp $
;*

.module 	main
.title 		Main Module

.include	'..\error\error.def'
.include	'..\expreval\expreval.def'
.include	'..\integer\integer.def'
.include	'..\io\io.def'
.include	'..\program\program.def'
.include	'..\strings\strings.def'
.include	'..\tokenize\tokenize.def'
.include	'..\variables\variable.def'

STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	DI
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START

.org	0x0030
RST6:	
	JMP	ERR_BREAK

.org	0x0038
RST7:	
	JMP	ERR_UNKNOWN

;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
	; IO INIT
	CALL	IO_INIT

	MVI	A,8			;SET INTERRUPT MASK
	SIM
	EI				;ENABLE INTERRUPTS

	CALL	IO_BEEP

	CALL	INT_INIT
	CALL	EXP_INIT

	LXI	H,0
	SHLD	PRG_CURRLINE

	; TEST PROGRAM
	LXI	H,0x9000		; PROGRAM MEMORY
	SHLD	PRG_LOPTR
	CALL	PRG_INIT

	; SET STR PTRS
	LXI	H,STACK-1024
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

	LXI	H,RESTART
	SHLD	ERR_RESTARTPTR

	LXI	H,BEGINSTR			; DISPLAY BANNER STRING
	CALL	IO_PUTS
RESTART:
	LXI	H,READYSTR			; PRINT 'READY'
	CALL	IO_PUTS
	CALL	IO_PUTCR

LOOP:
	CALL	PRG_RESET			; RESET STATE VARIABLES
	CALL	EXP_CLEARSTACK

	CALL	EXP_READLINE			; READ LINE INTO INPUT BUFFER

	LXI	H,EXP_INBUFFER			; PTR TO INPUT STR IN HL
	
	CALL	EXECUTE
	
	JMP	LOOP


EXECUTE::
	; CHECK IF BEGINNING OF LINE IS NUMBER
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	MOV	A,M				; READ CURRENT CHAR
	CALL	C_ISDIGIT			; CHECK IF DIGIT
	JNC	IMMEDIATE
	
	; FOUND A NUMBER. CONVERT IT
	CALL	INT_ATOI			; CONVERT TO INT (INT_ACC0)

	LDA	INT_ACC0			; LINE NUMBER IN BC
	MOV	C,A
	LDA	INT_ACC0+1
	MOV	B,A

	
	MOV	A,M				; CHECK CURR CHAR
	CPI	' 				; FOR SPACE
	JNZ	NOSPACE
	
	INX	H				; SKIP IT
	
NOSPACE:
	PUSH	H
	
	; CHECK IF LINE IS EMPTY
	CALL	EXP_SKIPWHITESPACE		; SKIP SPACES
	MOV	A,M				; CHECK FIRST NON-SPACE CHAR
	CPI	0
	POP	H
	
	JZ	REMOVE				; EMPTY STRING - REMOVE LINE

	; STRING IS NOT EMPTY, SO INSERT IT
	PUSH	H
	CALL	TOK_TOKENIZE1			; TOKENIZATION - FIRST PASS
	POP	H

	XCHG
	LHLD	PRG_LOPTR			; IN HL AND DE
	INX	H
	INX	H
	INX	H
	
	PUSH	H
	CALL	TOK_TOKENIZE2
	POP	D
	
	; HL IS AT THE END OF THE LINE
	
	; CALCULATE -BEGIN OF LINE ZERO
	
	; DE = ~BEGIN OF LINE ZERO
	MOV	A,D
	CMA
	MOV	D,A
	
	MOV	A,E
	CMA
	MOV	E,A

	INX	D				; DE = -BEGIN OF LINE ZERO
	
	; CALCULATE THE SIZE OF THE STRING
	DAD	D				; HL = HL-BEGIN OF LINE ZERO
	
	; MAKE SURE SIZE <256
	MOV	A,H
	CPI	0
	JNZ	ERR_STRTOOLONG
	
	MOV	A,L				; SIZE OF STRING IN ACC\

	LHLD	PRG_LOPTR			; DATA IN HL
	INX	H
	INX	H
	INX	H
	
	CALL	PRG_INSERT			; INSERT THE LINE
	
	RET

REMOVE:	; REMOVE THE LINE

	CALL	PRG_REMOVE
	RET
	
IMMEDIATE:
	; IMMEDIATE MODE
	PUSH	H
	CALL	TOK_TOKENIZE1			; TOKENIZATION - FIRST PASS
	POP	H
	XCHG

	LHLD	PRG_LOPTR
	INX	H
	INX	H
	INX	H

	CALL	TOK_TOKENIZE2			; TOKENIZATION - SECOND PASS


	CALL	PRG_RUNIMMEDIATE

	LXI	H,READYSTR			; PRINT 'READY'
	CALL	IO_PUTS
	CALL	IO_PUTCR
	
	RET	

BEGINSTR:	.ascii '8085 BASIC Version 1.0 (PFE Edition)' .db 13
		.ascii '(C) Copyright 2001 Dominic Thibodeau' .db 13
		.db 13,0

READYSTR:	.asciz	'Ready.'

.area	DATA	(REL,CON)


	