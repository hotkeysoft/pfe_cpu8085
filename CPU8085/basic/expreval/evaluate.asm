.module 	evaluate
.title 		Expression evaluation

.include	'expreval.def'
.include	'..\common\common.def'
.include	'..\variables\variable.def'
.include	'..\integer\integer.def'

.area	_CODE


;*********************************************************
;* EVAL_EVALUATE: 	EVALUATE FUNCTION (KEYWORD IN ACC)
EVAL_EVALUATE::
	PUSH	H
	
	STA	EVAL_CURRKEYWORD

	; EVALUATE BINARY CALCULATION
	CPI	K_POWER
	JZ	1$
	CPI	K_MULTIPLY
	JZ	1$	
	CPI	K_DIVIDE
	JZ	1$
	CPI	K_ADD
	JZ	1$
	CPI	K_SUBSTRACT
	JZ	1$

	; EVALUATE BINARY RELATION	
	CPI	K_EQUAL
	JZ	2$
	CPI	K_NOTEQUAL
	JZ	2$
	CPI	K_LESS
	JZ	2$
	CPI	K_GREATER
	JZ	2$
	CPI	K_LESSEQUAL
	JZ	2$
	CPI	K_GREATEREQUAL
	JZ	2$
	
	; EVALUATE LOGICAL OPERATION (BIN)
	CPI	K_AND
	JZ	3$
	CPI	K_OR
	JZ	3$
	CPI	K_XOR
	JZ	3$
	
	; NEGATION (UNARY)
	CPI	K_NEGATE
	JZ	4$
	
	; LOGICAL NOT (UNARY)
	CPI	K_NOT
	JZ	5$
	
	JMP	END

1$:
	CALL	EVAL_BINARYOP
	CALL	EVAL_CHECKSAMETYPE
	CALL	EVAL_BINARYCALC
	JMP	END

2$:
	CALL	EVAL_BINARYOP
	CALL	EVAL_CHECKSAMETYPE
	CALL	EVAL_BINARYREL
	JMP	END

3$:
	CALL	EVAL_BINARYOP
	CALL	EVAL_CHECKSAMETYPE
	CALL	EVAL_BINARYLOG
	JMP	END
	
4$:	
	CALL	EVAL_UNARYOP
	CALL	EVAL_NEGATE
	JMP	END
	
5$:
	CALL	EVAL_UNARYOP
	CALL	EVAL_NOT
	JMP	END
	
END:
	POP	H
	RET

;*********************************************************
;* EVAL_UNARYOP: 	EXTRACT PARAMETERS FOR UNARY
;*			OPERATION (VAR_TEMP1)
EVAL_UNARYOP:
	CALL	EVAL_COPY1
	RET

;*********************************************************
;* EVAL_BINARYOP: 	EXTRACT PARAMETERS FOR BINARY 
;*			OPERATION (VAR_TEMP1, VAR_TEMP2)
EVAL_BINARYOP:
	CALL	EVAL_COPY1
	CALL	EVAL_COPY2
	RET

;*********************************************************
;* EVAL_TERNARYOP: 	EXTRACT PARAMETERS FOR TERNARY
;*			OPERATION (VAR_TEMP1, VAR_TEMP2,
;*			VAR_TEMP3)
EVAL_TERNARYOP:
	CALL	EVAL_COPY1
	CALL	EVAL_COPY2
	CALL	EVAL_COPY3
	RET

;*********************************************************
;* EVAL_CHECKSAMSTYPE: 	CHECKS IF VAR_TEMP1 & VAR_TEMP2
;*			ARE OF SAME TYPE
EVAL_CHECKSAMETYPE:
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	MOV	B,A				; COPY TO B
	LDA	VAR_TEMP2			; TYPE OF VAR2 IN ACC
	
	CMP	B
	JNZ	1$
		
	RET

1$:	HLT

;*********************************************************
;* EVAL_BINARYCALC: 	EVALUATES BINARY CALCULATION
;*			(+, -, * /)
EVAL_BINARYCALC::
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	CPI	SID_CSTR
	JZ	6$
	
	; OPERATION ON INTEGERS
	
	LHLD	VAR_TEMP2+1			; HL = VAR_TEMP2 VALUE
	SHLD	INT_ACC0			; PUT IN INT_ACC0
	
	LXI	H,VAR_TEMP1+1
	
	LDA	EVAL_CURRKEYWORD		; ACC = CURR KEYWORD
	
	CPI	K_ADD
	JZ	1$
	CPI	K_SUBSTRACT
	JZ	2$
	CPI	K_MULTIPLY
	JZ	3$
	CPI	K_DIVIDE
	JZ	4$
	
	HLT
	
1$:	; ADD
	CALL	INT_ADD
	JMP	5$
	
2$:	; SUB
	CALL	INT_SUB
	JMP	5$

3$:	; MUL
	CALL	INT_MUL
	JMP	5$

4$:	; DIV
	CALL	INT_DIV
	JMP	5$
	
5$:	
	LHLD	INT_ACC0			; READ OP RESULT
	SHLD	VAR_TEMP3+1			; PUT IN VAR_TEMP3
	
	MVI	A,SID_CINT			; FLAG AS AN INT
	STA	VAR_TEMP3			; PUT AT BEGINNING OF VAR_TEMP3
	
	LXI	H,VAR_TEMP3			; ADDRESS OF VAR_TEMP3 IN HL	
	CALL	EXP_PUSH			; PUSH RESULT ON STACK
	
	RET	
	
6$:	; OPERATION ON STRINGS
	HLT


;*********************************************************
;* EVAL_BINARYREL: 	EVALUATES BINARY RELATION
;*			(< > <= >= = <>)
EVAL_BINARYREL::
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	CPI	SID_CSTR
	JZ	STR
	
	; OPERATION ON INTEGERS
	
	LHLD	VAR_TEMP2+1			; HL = VAR_TEMP2 VALUE
	SHLD	INT_ACC0			; PUT IN INT_ACC0
	
	LXI	H,VAR_TEMP1+1
	
	CALL	INT_CMP				; COMPARE THE INTS, RESULT
	MOV	B,A				; COPY RESULT IN B
	
	LDA	EVAL_CURRKEYWORD		; ACC = CURR KEYWORD

	CPI	K_EQUAL
	JZ	EQUAL
	CPI	K_NOTEQUAL
	JZ	NOTEQUAL
	CPI	K_LESS
	JZ	LESS
	CPI	K_GREATER
	JZ	GREATER
	CPI	K_LESSEQUAL
	JZ	LESSEQUAL
	CPI	K_GREATEREQUAL
	JZ	GREATEREQUAL

	HLT

EQUAL:		; =
	MVI	A,0x00				; CHECK IF B == 0
	ORA	B
	JZ	TRUE
	JMP	FALSE

NOTEQUAL:	; <>
	MVI	A,0x00				; CHECK IF B <> 0
	ORA	B
	JZ	FALSE
	JMP	TRUE

LESS:		; <
	MVI	A,0xFF				; CHECK IF B = 0xFF
	CMP	B
	JZ	TRUE
	JMP	FALSE

GREATER:	; >
	MVI	A,0x01				; CHECK IF B == 0x01
	CMP	B
	JZ	TRUE
	JMP	FALSE

LESSEQUAL:	; <=
	MVI	A,0xFF				; CHECK IF B = 0xFF
	CMP	B
	JZ	TRUE
	JMP	EQUAL				; CHECK FOR EQUALITY

GREATEREQUAL:	; >=
	MVI	A,0x01				; CHECK IF B = 0x01
	CMP	B
	JZ	TRUE
	JMP	EQUAL				; CHECK FOR EQUALITY
	
TRUE:	; TRUE
	LXI	H,0xFFFF
	JMP	IRET
	
FALSE:	; FALSE
	LXI	H,0x0000
	JMP	IRET

IRET:	
	SHLD	VAR_TEMP3+1			; PUT RESULT IN VAR_TEMP3
	
	MVI	A,SID_CINT			; FLAG AS AN INT
	STA	VAR_TEMP3			; PUT AT BEGINNING OF VAR_TEMP3
	
	LXI	H,VAR_TEMP3			; ADDRESS OF VAR_TEMP3 IN HL	
	CALL	EXP_PUSH			; PUSH RESULT ON STACK
	
	RET	
	
STR:	
	
	RET

;*********************************************************
;* EVAL_BINARYLOG: 	EVALUATES LOGICAL RELATION (BINARY)
;*			(AND OR XOR)
EVAL_BINARYLOG::
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	CPI	SID_CSTR
	JZ	5$				; MUST BE INTEGER
	
	LHLD	VAR_TEMP2+1			; HL = VAR_TEMP2 VALUE
	SHLD	INT_ACC0			; PUT IN INT_ACC0
	
	LXI	H,VAR_TEMP1+1
	
	LDA	EVAL_CURRKEYWORD		; ACC = CURR KEYWORD
	
	CPI	K_AND
	JZ	1$
	CPI	K_OR
	JZ	2$
	CPI	K_XOR
	JZ	3$
	
	HLT
	
1$:	; AND
	CALL	INT_AND
	JMP	4$
	
2$:	; OR
	CALL	INT_OR
	JMP	4$

3$:	; XOR
	CALL	INT_XOR
	JMP	4$

4$:	
	LHLD	INT_ACC0			; READ OP RESULT
	SHLD	VAR_TEMP3+1			; PUT IN VAR_TEMP3
	
	MVI	A,SID_CINT			; FLAG AS AN INT
	STA	VAR_TEMP3			; PUT AT BEGINNING OF VAR_TEMP3
	
	LXI	H,VAR_TEMP3			; ADDRESS OF VAR_TEMP3 IN HL	
	CALL	EXP_PUSH			; PUSH RESULT ON STACK
	
	RET	
	
5$:	HLT

;*********************************************************
;* EVAL_NEGATE: 	EVALUATES INTEGER NEGATION
EVAL_NEGATE::
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	CPI	SID_CSTR
	JZ	1$				; MUST BE INTEGER
	
	LXI	H,VAR_TEMP1+1
	
	CALL	INT_NEG
	
	LXI	H,VAR_TEMP1			; ADDRESS OF VAR_TEMP1 IN HL	
	CALL	EXP_PUSH			; PUSH RESULT ON STACK
	
	RET	
	
1$:	HLT
	

;*********************************************************
;* EVAL_NOT: 	EVALUATES LOGICAL NOT
EVAL_NOT::
	LDA	VAR_TEMP1			; TYPE OF VAR1 IN ACC
	CPI	SID_CSTR
	JZ	1$				; MUST BE INTEGER
	
	LXI	H,VAR_TEMP1+1
	
	CALL	INT_NOT
	
	LXI	H,VAR_TEMP1			; ADDRESS OF VAR_TEMP1 IN HL	
	CALL	EXP_PUSH			; PUSH RESULT ON STACK
	
	RET	
	
1$:	HLT

;*********************************************************
;* EVAL_COPY1: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP1
EVAL_COPY1:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP1			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP1+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP1+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP1+3
	INX	H
	
	RET
		
;*********************************************************
;* EVAL_COPY2: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP2
EVAL_COPY2:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP2			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP2+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP2+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP2+3
	INX	H
	
	RET

;*********************************************************
;* EVAL_COPY3: 	POP FROM EXP STACK AND COPY VAR TO VAR_TEMP3
EVAL_COPY3:
	CALL	EXP_POP				; ADDR OF DATA IN H-L
	
	MOV	A,M				; DATA TYPE IN ACC
	
	CPI	SID_VAR				; CHECK IF VAR
	JZ	VAR
	
	STA	VAR_TEMP3			; BYTE 1
	INX	H
	
	MOV	A,M
	STA	VAR_TEMP3+1			; BYTE 2
	INX	H
	
	MOV	A,M				; BYTE 3
	STA	VAR_TEMP3+2
	INX	H

	MOV	A,M				; BYTE 4
	STA	VAR_TEMP3+3
	INX	H
	
	RET


VAR:
	HLT


;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

EVAL_CURRKEYWORD:	.ds	1		; CURRENT KEYWORD