.module 	error
.title 		Error handling

.include	'..\io\io.def'
.include	'..\integer\integer.def'

.area	_CODE

ERR_TOK_UNKNOWN::
	LXI	H,ERR_STR_TOK_UNKNOWN
	JMP	ERR_HANDLER
	
ERR_TOK_NOENDSTR::
	LXI	H,ERR_STR_TOK_NOENDSTR
	JMP	ERR_HANDLER
	
ERR_TOK_INVALIDCHAR::
	LXI	H,ERR_STR_TOK_INVALIDCHAR
	JMP	ERR_HANDLER
	
ERR_EXP_STACKOVERFLOW::
	LXI	H,ERR_STR_EXP_STACKOVERFLOW
	JMP	ERR_HANDLER
	
ERR_EXP_STACKUNDERFLOW::
	LXI	H,ERR_STR_EXP_STACKUNDERFLOW
	JMP	ERR_HANDLER
	
ERR_EXP_TYPEMISMATCH::
	LXI	H,ERR_STR_EXP_TYPEMISMATCH
	JMP	ERR_HANDLER
	
ERR_EXP_OVERFLOW::
	LXI	H,ERR_STR_EXP_OVERFLOW
	JMP	ERR_HANDLER
	
ERR_EXP_ILLEGAL::
	LXI	H,ERR_STR_EXP_ILLEGAL
	JMP	ERR_HANDLER
	
ERR_EXP_DIVZERO::
	LXI	H,ERR_STR_EXP_DIVZERO
	JMP	ERR_HANDLER
	
ERR_EXP_SYNTAX::
	LXI	H,ERR_STR_EXP_SYNTAX
	JMP	ERR_HANDLER
	
ERR_EXP_ELSEWITHOUTIF::
	LXI	H,ERR_STR_EXP_ELSEWITHOUTIF
	JMP	ERR_HANDLER
	
ERR_EXP_LINENOTFOUND::
	LXI	H,ERR_STR_EXP_LINENOTFOUND
	JMP	ERR_HANDLER
	
ERR_EXP_STRTOOLONG::
	LXI	H,ERR_STR_EXP_STRTOOLONG
	JMP	ERR_HANDLER

ERR_UNKNOWN::
	LXI	H,ERR_STR_UNKNOWN
	JMP	ERR_HANDLER

ERR_HANDLER:
	MVI	A,'?			; PRINT '?'
	CALL	IO_PUTC
	
	CALL	IO_PUTS			; PRINT ERROR MESSAGE
	
	LHLD	ERR_CURRLINE		; CHECK IF PROGRAM CURRENTLY RUNNING
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
	
	LHLD	ERR_CURRLINE		; LOAD LINE NUMBER
	SHLD	INT_ACC0		; PUT IN INT_ACC0
	CALL	INT_ITOA		; CONVERT TO STRING
	CALL	IO_PUTS			; PRINT VALUE	
	
2$:	; END OF ERROR MESSAGE	
	MVI	A,13			; CR
	CALL	IO_PUTC			; END OF LINE
	
	; UNWIND STACK
	LXI	SP,0xFFFF
	
	LHLD	ERR_RESTARTPTR		; LOAD RESTART POSITION
	PCHL				; GO TO RESTART POS

	
ERR_STR_ATLINE:			.asciz	" at line"
	
ERR_STR_TOK_UNKNOWN:		.asciz	"TOK: Unknown token"
ERR_STR_TOK_NOENDSTR:		.asciz	"TOK: Unterminated string constant"
ERR_STR_TOK_INVALIDCHAR:	.asciz	"TOK: Invalid symbol"
ERR_STR_EXP_STACKOVERFLOW:	.asciz	"EXP: Stack overflow"
ERR_STR_EXP_STACKUNDERFLOW:	.asciz	"EXP: Stack underflow"
ERR_STR_EXP_TYPEMISMATCH:	.asciz	"EXP: Type mismatch"
ERR_STR_EXP_OVERFLOW:		.asciz	"EXP: Overflow"
ERR_STR_EXP_ILLEGAL:		.asciz	"EXP: Illegal argument"
ERR_STR_EXP_DIVZERO:		.asciz	"EXP: Division by zero"
ERR_STR_EXP_SYNTAX:		.asciz	"EXP: Syntax error"
ERR_STR_EXP_ELSEWITHOUTIF:	.asciz	"EXP: ELSE without IF"
ERR_STR_EXP_LINENOTFOUND:	.asciz	"EXP: Undefined line number"
ERR_STR_EXP_STRTOOLONG:		.asciz	"EXP: String too long"
ERR_STR_UNKNOWN:		.asciz	"Unknown Error"
	
TESTSTR1:	.asciz	''	

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

ERR_RESTARTPTR::	.ds	2		; JUMP TO THIS ADDRESS 
						; AFTER ERROR

ERR_CURRLINE::		.ds	2		; REPLACE WITH PROGRAM MODULE
