.module 	tokenize
.title 		Tokenization of basic statements

.include	'..\common\common.def'

.area	_CODE

;*********************************************************
;* TOK_CMP:  	CHECK IF CURRENT STRING MATCHES CURRENT
;* 		TOKEN.  
;*		H-L: PTR IN TOKEN TABLE:
;*		D-E: PTR TO STRING
;*		OUTPUT: CF = 1 IF FOUND
;*		IF NOT FOUND, H-L ADVANCED TO NEXT TOKEN
;*		** B is modified **
TOK_CMP:
	PUSH	D
	
	MVI	B,0				; B COUNTS TOKEN LENGTH
LOO:	
	LDAX	D				; ACC = CURRENT CHAR IN STR
	
;	CALL	C_ISALPHA			; CHECK IF LETTER
;	JNC	NOTLETTER
	
;	ANI	223				; IF SO, CONVERT TO UPPERCASE
	
NOTLETTER:
	CMP	M				; COMPARE WITH CURRENT TOKEN LETTER
	JNZ	DIFF				; EXIT LOOP IF DIFFERENT
	
	INX	H				; INCREMENT TOKEN TABLE PTR
	INX	D				; INCREMENT STR PTR
	INR	B				; INCREMENT LENGTH COUNTER
	
	JMP	LOO				; LOOP
	
DIFF:
	MOV	A,M				; CHECK IF DIFFERENT CHAR IS 
	ORA	A				; END OF TOKEN
	JM	EOT				; BY CHECKING UPPER BIT FOR '1'

LP:						; ADVANCE TO NEXT TOKEN
	INX	H
	MOV	A,M				; CHECK FOR BEGIN OF NEXT TOKEN
	ORA	A				; (UPPER BIT == 1)
	JZ	END				; FOUND END OF TABLE
	JP	LP				; LOOP UNTIL FOUND

	JMP	END
	
EOT:	STC					; SET CARRY TO INDICATE FOUND
	MOV	A,B				; TOKEN LENGTH
	STA	TOK_CURRTOKENLEN		; STORE IN VAR

END:
	POP	D	
	RET


;*********************************************************
;* TOK_FINDTOKENID:  	FINDS TOKEN ID FROM STRING AT 
;* 			TOK_CURRPOS.  SETS TOK_CURRTOKEN
;*			TO ID IF FOUND, ELSE 0
TOK_FINDTOKENID::
	PUSH	B
	PUSH	D
	PUSH	H
	
	LHLD	TOK_CURRPOS			; LOAD CURRENT POS IN HL
	XCHG					; SWAP WITH DE

	LXI	H,K_TABLE			; HL POINTS TO TOKEN TABLE
	
LOOP:
	MOV	A,M				; READ ID FROM TOKEN TABLE
	STA	TOK_CURRTOKEN			; STORE IN CURRTOKEN
	
	ORA	A				; CHECK IF 0 (END OF TABLE)
	JZ 	EXIT

	INX	H				; FIRST CHAR OF TOKEN STRING

	CALL	TOK_CMP				; COMPARE WITH CURRENT STRING
	
	JC	FOUND
	
	JMP	LOOP
	
FOUND:
EXIT:
	POP	H
	POP	D
	POP	B
	RET
	
TOK_FINDTOKENSTR::
	RET
	
TOK_TOKENIZE1::
	RET
	
	
TOK_TOKENIZE2::
	RET

;*********************************************************
;* RAM VARIABLES
;*********************************************************

.area	DATA	(REL,CON)

TOK_CURRPOS::		.ds	2			; CURRENT POSITION
TOK_CURRTOKEN::		.ds	1			; CURRENT TOKEN ID
TOK_CURRTOKENLEN::	.ds	1			; CURRENT TOKEN LENGTH
