.module 	error
.title 		Error handling

.include	'..\io\io.def'
.include	'..\integer\integer.def'
.include	'..\program\program.def'
.include	'..\expreval\expreval.def'

.area	_CODE

ERR_UNKNOWN::
	LXI	H,ERR_STR_UNKNOWN
	JMP	ERR_HANDLER
	
ERR_NOENDSTR::
	LXI	H,ERR_STR_NOENDSTR
	JMP	ERR_HANDLER
	
ERR_INVALIDCHAR::
	LXI	H,ERR_STR_INVALIDCHAR
	JMP	ERR_HANDLER
	
ERR_STACKOVERFLOW::
	LXI	H,ERR_STR_STACKOVERFLOW
	JMP	ERR_HANDLER
	
ERR_STACKUNDERFLOW::
	LXI	H,ERR_STR_STACKUNDERFLOW
	JMP	ERR_HANDLER
	
ERR_TYPEMISMATCH::
	LXI	H,ERR_STR_TYPEMISMATCH
	JMP	ERR_HANDLER
	
ERR_OVERFLOW::
	LXI	H,ERR_STR_OVERFLOW
	JMP	ERR_HANDLER
	
ERR_ILLEGAL::
	LXI	H,ERR_STR_ILLEGAL
	JMP	ERR_HANDLER
	
ERR_SYNTAX::
	LXI	H,ERR_STR_SYNTAX
	JMP	ERR_HANDLER
	
ERR_ELSEWITHOUTIF::
	LXI	H,ERR_STR_ELSEWITHOUTIF
	JMP	ERR_HANDLER
	
ERR_LINENOTFOUND::
	LXI	H,ERR_STR_LINENOTFOUND
	JMP	ERR_HANDLER
	
ERR_STRTOOLONG::
	LXI	H,ERR_STR_STRTOOLONG
	JMP	ERR_HANDLER

ERR_DIVZERO::
	LXI	H,ERR_STR_DIVZERO
	JMP	ERR_HANDLER


ERR_HANDLER:
	MVI	A,'?			; PRINT '?'
	CALL	IO_PUTC
	
	CALL	IO_PUTS			; PRINT ERROR MESSAGE

	LXI	H,ERR_STR_ERROR		; PRINT ' ERROR'
	CALL	IO_PUTS
	
	LHLD	PRG_CURRLINE		; CHECK IF PROGRAM CURRENTLY RUNNING
	MOV	A,L			; 
	CPI	0			; CHECK IF CURRENT LINE == 0
	JNZ	1$			; 
	MOV	A,H			; 
	CPI	0			;
	JNZ	1$			;

	JMP	2$			; CURRENT LINE IS ZERO -> IMMEDIATE MODE
	
1$:	; PROGRAM CURRENTLY RUNNING, PRINT LINE NUMBER
	LXI	H,ERR_STR_ATLINE
	CALL	IO_PUTS			; PRINTS '?XXX AT LINE YYY'
	
	LHLD	PRG_CURRLINE		; LOAD LINE NUMBER
	SHLD	INT_ACC0		; PUT IN INT_ACC0
	CALL	INT_ITOA		; CONVERT TO STRING
	CALL	IO_PUTS			; PRINT VALUE	
	
2$:	; END OF ERROR MESSAGE	
	MVI	A,13			; CR
	CALL	IO_PUTC			; END OF LINE

	; UNWIND EXPRESSION STACK
	CALL	EXP_CLRSTACK
	
	; UNWIND STACK
	LXI	SP,0xFFFF
	
	
	LHLD	ERR_RESTARTPTR		; LOAD RESTART POSITION
	PCHL				; GO TO RESTART POS

	
ERR_STR_ATLINE:			.asciz	" at line"
ERR_STR_ERROR:			.asciz	" error"
	
ERR_STR_NOENDSTR:		.asciz	"Unterminated string constant"
ERR_STR_INVALIDCHAR:		.asciz	"Invalid symbol"
ERR_STR_STACKOVERFLOW:		.asciz	"Expression too complex"
ERR_STR_STACKUNDERFLOW:		.asciz	"Missing parameter"
ERR_STR_TYPEMISMATCH:		.asciz	"Type mismatch"
ERR_STR_OVERFLOW:		.asciz	"Overflow"
ERR_STR_ILLEGAL:		.asciz	"Illegal argument"
ERR_STR_SYNTAX:			.asciz	"Syntax"
ERR_STR_ELSEWITHOUTIF:		.asciz	"ELSE without IF"
ERR_STR_LINENOTFOUND:		.asciz	"Undefined line number"
ERR_STR_STRTOOLONG:		.asciz	"String too long"
ERR_STR_DIVZERO:		.asciz	"Division by zero"
ERR_STR_UNKNOWN:		.asciz	"Unknown"

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

ERR_RESTARTPTR::	.ds	2		; JUMP TO THIS ADDRESS 
						; AFTER ERROR
