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
1$:	
	LDAX	D				; ACC = CURRENT CHAR IN STR
	
;	CALL	C_ISALPHA			; CHECK IF LETTER
;	JNC	NOTLETTER
	
;	ANI	223				; IF SO, CONVERT TO UPPERCASE
	
2$:
	CMP	M				; COMPARE WITH CURRENT TOKEN LETTER
	JNZ	3$				; EXIT LOOP IF DIFFERENT
	
	INX	H				; INCREMENT TOKEN TABLE PTR
	INX	D				; INCREMENT STR PTR
	INR	B				; INCREMENT LENGTH COUNTER
	
	JMP	1$				; LOOP
	
3$:
	MOV	A,M				; CHECK IF DIFFERENT CHAR IS 
	ORA	A				; END OF TOKEN
	JM	5$				; BY CHECKING UPPER BIT FOR '1'

4$:						; ADVANCE TO NEXT TOKEN
	INX	H
	MOV	A,M				; CHECK FOR BEGIN OF NEXT TOKEN
	ORA	A				; (UPPER BIT == 1)
	JZ	6$				; FOUND END OF TABLE
	JP	4$				; LOOP UNTIL FOUND

	JMP	6$
	
5$:	STC					; SET CARRY TO INDICATE FOUND
	MOV	A,B				; TOKEN LENGTH
	STA	TOK_CURRTOKENLEN		; STORE IN VAR

6$:
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
	
1$:
	MOV	A,M				; READ ID FROM TOKEN TABLE
	STA	TOK_CURRTOKEN			; STORE IN CURRTOKEN
	
	ORA	A				; CHECK IF 0 (END OF TABLE)
	JZ 	2$

	INX	H				; FIRST CHAR OF TOKEN STRING

	CALL	TOK_CMP				; COMPARE WITH CURRENT STRING
	
	JC	2$
	
	JMP	1$
	
2$:
	POP	H
	POP	D
	POP	B
	RET

;*********************************************************
;* TOK_FINDTOKENSTR:  	FROM STRING ID IN ACC,
;*			SETS H-L TO POINT TO CORRESPONDING
;*			STRING (OR 0x0000 IF NOT FOUND)
TOK_FINDTOKENSTR::
	PUSH	B
	
	MOV	B,A				; ID TO FIND IN B	

	
	LXI	H,K_TABLE			; HL POINTS TO TOKEN TABLE

1$:
	MOV	A,M				; CURRENT ID IN A
	
	CMP	B				; CHECK IF FOUND TOKEN
	JZ	3$
	
	ORA	A				; CHECK IF END OF TABLE
	JZ	2$
	
	INX	H				; ADVANCE IN TABLE
	
	JMP	1$

2$:
	LXI	H,0				; NOT FOUND, HL = 0
	JMP	4$

3$:
	INX	H				; FOUND, STR IS AT PTR+1

4$:
	POP	B

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
