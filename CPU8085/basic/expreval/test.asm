.module 	exprevaltest
.title 		Tests expreval Module

.include	'expreval.def'
.include	'..\integer\integer.def'
.include	'..\tokenize\tokenize.def'
.include	'..\strings\strings.def'

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

	; SET STR PTRS
	LXI	H,0xA000
	SHLD	STR_LOPTR
	SHLD	STR_HIPTR

	CALL	INT_INIT
	CALL	EXP_INIT

;	JMP	TEST_BINCALC
;	JMP	TEST_BINREL
;	JMP	TEST_BINLOG
;	JMP	TEST_NEG
;	JMP	TEST_NOT
;	JMP	TEST_ABS
;	JMP	TEST_SGN
;	JMP	TEST_PEEK
;	JMP	TEST_RND
;	JMP	TEST_SQR
;	JMP	TEST_LEN
;	JMP	TEST_ASC
;	JMP	TEST_VAL
;	JMP	TEST_CHR
;	JMP	TEST_ADDSTR
;	JMP	TEST_BINRELSTR
;	JMP	TEST_STR
;	JMP	TEST_LEFT
	JMP	TEST_RIGHT
	
TEST_BINCALC:	; TEST OF ARITHMETIC OPERATORS
	LXI	H,TESTSTR001	; 4+4
	CALL 	EVAL		; RESULT: 8
	LXI	H,TESTSTR002	; 4-4
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR003	; 4*4
	CALL 	EVAL		; RESULT: 16
	LXI	H,TESTSTR004	; 4/4
	CALL 	EVAL		; RESULT: 1


TEST_BINREL:	; TEST OF BINARY RELATIONS
	LXI	H,TESTSTR101	; 4=4
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR102	; 4<>4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR103	; 4<4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR104	; 4>4
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR105	; 4<=4
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR106	; 4>=4
	CALL 	EVAL		; RESULT: TRUE

	LXI	H,TESTSTR111	; 1=10
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR112	; 1<>10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR113	; 1<10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR114	; 1>10
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR115	; 1<=10
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR116	; 1>=10
	CALL 	EVAL		; RESULT: FALSE

	LXI	H,TESTSTR121	; 10=1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR122	; 10<>1
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR123	; 10<1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR124	; 10>1
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTR125	; 10<=1
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTR126	; 10>=1
	CALL 	EVAL		; RESULT: TRUE

TEST_BINLOG:	; TESTS OF LOGICAL OPERATORS (AND OR XOR)
	LXI	H,TESTSTR201	; 0 AND 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR202	; 0 AND 255
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR203	; 255 AND 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR204	; 255 AND 255
	CALL 	EVAL		; RESULT: 255

	LXI	H,TESTSTR211	; 0 OR 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR212	; 0 OR 255
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR213	; 255 OR 0
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR214	; 255 OR 255
	CALL 	EVAL		; RESULT: 255

	LXI	H,TESTSTR221	; 0 XOR 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR222	; 0 XOR 255
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR223	; 255 XOR 0
	CALL 	EVAL		; RESULT: 255
	LXI	H,TESTSTR224	; 255 XOR 255
	CALL 	EVAL		; RESULT: 0

TEST_NEG:	;	TESTS OF NEGATION
	LXI	H,TESTSTR301	; -10
	CALL 	EVAL		; RESULT: -10
	LXI	H,TESTSTR302	; --10
	CALL 	EVAL		; RESULT: +10
	LXI	H,TESTSTR303	; -(2+2)
	CALL 	EVAL		; RESULT: -4
	LXI	H,TESTSTR304	; -(-5--1)
	CALL 	EVAL		; RESULT: +4

TEST_NOT:	;	TESTS OF NOT
	LXI	H,TESTSTR401	; NOT 0
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR402	; NOT NOT 0
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR403	; NOT -1
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR404	; NOT --1
	CALL 	EVAL		; RESULT: -2

TEST_ABS:	;	TESTS OF ABS
	LXI	H,TESTSTR501	; ABS ( 0  ) 
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR502	; ABS ( 1  ) 
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR503	; ABS ( -1 )
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR504	; ABS ( - ABS ( -10 ) )
	CALL 	EVAL		; RESULT: 10

TEST_SGN:	;	TESTS OF SGN
	LXI	H,TESTSTR601	; SGN ( 0  )
	CALL 	EVAL		; RESULT:  0
	LXI	H,TESTSTR602	; SGN ( 1  )
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR603	; SGN ( -1 )
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR604	; SGN ( -32768 )
	CALL 	EVAL		; RESULT: -1
	LXI	H,TESTSTR605	; SGN ( 32767 )
	CALL 	EVAL		; RESULT: 1

TEST_PEEK:	;	TESTS OF PEEK
	LXI	H,TESTSTR701	; PEEK ( 0  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR702	; PEEK ( 32767  )
	CALL 	EVAL		; 
	LXI	H,TESTSTR703	; PEEK ( -1 )
	CALL 	EVAL		; 

TEST_RND:	;	TESTS OF RND
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 
	LXI	H,TESTSTRRND	; RND(0)
	CALL 	EVAL		; 

TEST_SQR:	;	TESTS OF SQR
	LXI	H,TESTSTR801	; SQR(10)
	CALL 	EVAL		; RESULT: 3
	LXI	H,TESTSTR802	; SQR(100)
	CALL 	EVAL		; RESULT: 10
	LXI	H,TESTSTR803	; SQR(1000)
	CALL 	EVAL		; RESULT: 31
	LXI	H,TESTSTR804	; SQR(10000)
	CALL 	EVAL		; RESULT: 100

TEST_LEN:	;	TESTS OF LEN
	LXI	H,TESTSTR901	; LEN("")
	CALL 	EVAL		; RESULT: 0
	LXI	H,TESTSTR902	; SQR("A")
	CALL 	EVAL		; RESULT: 1
	LXI	H,TESTSTR903	; SQR("12345")
	CALL 	EVAL		; RESULT: 5


TEST_ASC:	;	TESTS OF ASC
	LXI	H,TESTSTRA01	; ASC("1234")
	CALL 	EVAL		; RESULT: '1'
	LXI	H,TESTSTRA02	; ASC(" ")
	CALL 	EVAL		; RESULT: 32

TEST_VAL:	;	TESTS OF VAL
	LXI	H,TESTSTRB01	; VAL("1234")
	CALL 	EVAL		; RESULT: 1234
	LXI	H,TESTSTRB02	; VAL("-666")
	CALL 	EVAL		; RESULT: -666


TEST_CHR:	;	TESTS OF CHR$
	LXI	H,TESTSTRC01	; CHR$(65)
	CALL 	EVAL		; RESULT: "A"
	LXI	H,TESTSTRC02	; CHR$(48)
	CALL 	EVAL		; RESULT: "0"

TEST_ADDSTR:	;	TESTS OF ADD (STR)
	LXI	H,TESTSTRD01	; "1234"+"66"
	CALL 	EVAL		; RESULT: "123466"
	LXI	H,TESTSTRD02	; "6666"+""
	CALL 	EVAL		; RESULT: "6666"

TEST_BINRELSTR:	;	TESTS OF BINARY RELATIONS
	LXI	H,TESTSTRE01	; "A"="A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE02	; "B"<>"B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE03	; "C"<"C"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE04	; "C">"C"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE05	; "D"<="D"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE06	; "E">="E"
	CALL 	EVAL		; RESULT: TRUE

	LXI	H,TESTSTRE11	; "A"="B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE12	; "A"<>"B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE13	; "A"<"B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE14	; "A">"B"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE15	; "A"<="B"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE16	; "A">="B"
	CALL 	EVAL		; RESULT: FALSE

	LXI	H,TESTSTRE21	; "B"="A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE22	; "B"<>"A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE23	; "B"<"A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE24	; "B">"A"
	CALL 	EVAL		; RESULT: TRUE
	LXI	H,TESTSTRE25	; "B"<="A"
	CALL 	EVAL		; RESULT: FALSE
	LXI	H,TESTSTRE26	; "B">="A"
	CALL 	EVAL		; RESULT: TRUE

TEST_STR:	;	TESTS OF STR$
	LXI	H,TESTSTRF21	; STR$(0)
	CALL 	EVAL		; RESULT: " 0"
	LXI	H,TESTSTRF22	; STR$(-1)
	CALL 	EVAL		; RESULT: "-1"
	LXI	H,TESTSTRF23	; STR$(1234)
	CALL 	EVAL		; RESULT: "1234"
	LXI	H,TESTSTRF24	; STR$(10+10)
	CALL 	EVAL		; RESULT: "20"
	LXI	H,TESTSTRF25	; STR$(10*10)
	CALL 	EVAL		; RESULT: "100"

TEST_LEFT:	;	TESTS OF LEFT$
	LXI	H,TESTSTRG21	; LEFT$("ABCD",2)
	CALL 	EVAL		; RESULT: "AB"
	LXI	H,TESTSTRG22	; LEFT$("ABCD",4)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRG23	; LEFT$("ABCD",66)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRG24	; LEFT$("",0)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRG25	; LEFT$("",5)
	CALL 	EVAL		; RESULT: ""

TEST_RIGHT:	;	TESTS OF RIGHT$
	LXI	H,TESTSTRH21	; RIGHT$("ABCD",2)
	CALL 	EVAL		; RESULT: "CD"
	LXI	H,TESTSTRH22	; RIGHT$("ABCD",4)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRH23	; RIGHT$("ABCD",66)
	CALL 	EVAL		; RESULT: "ABCD"
	LXI	H,TESTSTRH24	; RIGHT$("",0)
	CALL 	EVAL		; RESULT: ""
	LXI	H,TESTSTRH25	; RIGHT$("",5)
	CALL 	EVAL		; RESULT: ""


LOOP:
	JMP	LOOP

	
EVAL:	
	PUSH	H
	CALL	TOK_TOKENIZE1
	POP	H
	XCHG
	LXI	H,OUTSTR
	CALL	TOK_TOKENIZE2
	LXI	H,OUTSTR
	CALL	EXP_EXPREVAL
	RET	



.area	DATA	(REL,CON)


;	TESTS OF BINARY ARITHMETIC OPERATIONS
TESTSTR001:	.asciz	'4+4'			; 8
TESTSTR002:	.asciz	'4-4'			; 0
TESTSTR003:	.asciz	'4*4'			; 16
TESTSTR004:	.asciz	'4/4'			; 1


;	TESTS OF BINARY RELATIONS
TESTSTR101:	.asciz	'4=4'			; TRUE
TESTSTR102:	.asciz	'4<>4'			; FALSE
TESTSTR103:	.asciz	'4<4'			; FALSE
TESTSTR104:	.asciz	'4>4'			; FALSE
TESTSTR105:	.asciz	'4<=4'			; TRUE
TESTSTR106:	.asciz	'4>=4'			; TRUE

TESTSTR111:	.asciz	'1=10'			; FALSE
TESTSTR112:	.asciz	'1<>10'			; TRUE
TESTSTR113:	.asciz	'1<10'			; TRUE
TESTSTR114:	.asciz	'1>10'			; FALSE
TESTSTR115:	.asciz	'1<=10'			; TRUE
TESTSTR116:	.asciz	'1>=10'			; FALSE

TESTSTR121:	.asciz	'10=1'			; FALSE
TESTSTR122:	.asciz	'10<>1'			; TRUE
TESTSTR123:	.asciz	'10<1'			; FALSE
TESTSTR124:	.asciz	'10>1'			; TRUE
TESTSTR125:	.asciz	'10<=1'			; FALSE
TESTSTR126:	.asciz	'10>=1'			; TRUE

;	TESTS OF LOGICAL OPERATORS (AND OR XOR)
TESTSTR201:	.asciz	'0 AND 0'		; 0
TESTSTR202:	.asciz	'0 AND 255'		; 0
TESTSTR203:	.asciz	'255 AND 0'		; 0
TESTSTR204:	.asciz	'255 AND 255'		; 255

TESTSTR211:	.asciz	'0 OR 0'		; 0
TESTSTR212:	.asciz	'0 OR 255'		; 255
TESTSTR213:	.asciz	'255 OR 0'		; 255
TESTSTR214:	.asciz	'255 OR 255'		; 255

TESTSTR221:	.asciz	'0 XOR 0'		; 0
TESTSTR222:	.asciz	'0 XOR 255'		; 255
TESTSTR223:	.asciz	'255 XOR 0'		; 255
TESTSTR224:	.asciz	'255 XOR 255'		; 0

;	TESTS OF NEGATION
TESTSTR301:	.asciz	'-10'			; -10
TESTSTR302:	.asciz	'--10'			; +10
TESTSTR303:	.asciz	'-(2+2)'		; -4
TESTSTR304:	.asciz	'-(-5--1)'		; +4

;	TESTS OF NOT
TESTSTR401:	.asciz	'NOT 0'			; -1
TESTSTR402:	.asciz	'NOT NOT 0'		; 0
TESTSTR403:	.asciz	'NOT -1'		; 0
TESTSTR404:	.asciz	'NOT --1'		; -2

;	TESTS OF ABS
TESTSTR501:	.asciz	'ABS ( 0  ) '		; 0
TESTSTR502:	.asciz	'ABS ( 1  ) '		; 1
TESTSTR503:	.asciz	'ABS ( -1 )'		; 1
TESTSTR504:	.asciz	'ABS ( - ABS ( -10 ) )'	; 

;	TESTS OF SGN
TESTSTR601:	.asciz	'SGN ( 0  ) '		; 0
TESTSTR602:	.asciz	'SGN ( 1  ) '		; 1
TESTSTR603:	.asciz	'SGN ( -1 )'		; -1
TESTSTR604:	.asciz	'SGN ( -32768 )'	; -1
TESTSTR605:	.asciz	'SGN ( 32767 )'		; 1

;	TESTS OF PEEK
TESTSTR701:	.asciz	'PEEK ( 0  ) '		; 
TESTSTR702:	.asciz	'PEEK ( 32767  ) '	; 
TESTSTR703:	.asciz	'PEEK ( -1 )'		; 1

;	TESTS OF RND
TESTSTRRND:	.asciz	'RND(0)'		; 

;	TESTS OF SQR
TESTSTR801:	.asciz	'SQR(10)'		; 3
TESTSTR802:	.asciz	'SQR(100)'		; 10
TESTSTR803:	.asciz	'SQR(1000)'		; 31
TESTSTR804:	.asciz	'SQR(10000)'		; 100

;	TESTS OF LEN
TESTSTR901:	.asciz	'LEN("")'		; 0
TESTSTR902:	.asciz	'LEN("A")'		; 1
TESTSTR903:	.asciz	'LEN("12345")'		; 5

;	TESTS OF ASC
TESTSTRA01:	.asciz	'ASC("1234")'		; '1'
TESTSTRA02:	.asciz	'ASC(" ")'		; 32

;	TESTS OF VAL
TESTSTRB01:	.asciz	'VAL("1234")'		; 1234
TESTSTRB02:	.asciz	'VAL("-666")'		; -666

;	TESTS OF CHR$
TESTSTRC01:	.asciz	'CHR$(65)'		; "A"
TESTSTRC02:	.asciz	'CHR$(48)'		; "0"

;	TESTS OF ADD (STR)
TESTSTRD01:	.asciz	'"1234"+"66"'		; "123466"
TESTSTRD02:	.asciz	'"6666"+""'		; "6666"

;	TESTS OF BINARY RELATIONS
TESTSTRE01:	.asciz	'"A"="A"'		; TRUE
TESTSTRE02:	.asciz	'"B"<>"B"'		; FALSE
TESTSTRE03:	.asciz	'"C"<"C"'		; FALSE
TESTSTRE04:	.asciz	'"C">"C"'		; FALSE
TESTSTRE05:	.asciz	'"D"<="D"'		; TRUE
TESTSTRE06:	.asciz	'"E">="E"'		; TRUE

TESTSTRE11:	.asciz	'"A"="B"'		; FALSE
TESTSTRE12:	.asciz	'"A"<>"B"'		; TRUE
TESTSTRE13:	.asciz	'"A"<"B"'		; TRUE
TESTSTRE14:	.asciz	'"A">"B"'		; FALSE
TESTSTRE15:	.asciz	'"A"<="B"'		; TRUE
TESTSTRE16:	.asciz	'"A">="B"'		; FALSE

TESTSTRE21:	.asciz	'"B"="A"'		; FALSE
TESTSTRE22:	.asciz	'"B"<>"A"'		; TRUE
TESTSTRE23:	.asciz	'"B"<"A"'		; FALSE
TESTSTRE24:	.asciz	'"B">"A"'		; TRUE
TESTSTRE25:	.asciz	'"B"<="A"'		; FALSE
TESTSTRE26:	.asciz	'"B">="A"'		; TRUE

;	TESTS OF STR$
TESTSTRF21:	.asciz	'STR$(0)'		; " 0"
TESTSTRF22:	.asciz	'STR$(-1)'		; "-1"
TESTSTRF23:	.asciz	'STR$(1234)'		; "1234"
TESTSTRF24:	.asciz	'STR$(10+10)'		; "20"
TESTSTRF25:	.asciz	'STR$(10*10)'		; "100"

;	TESTS OF LEFT$
TESTSTRG21:	.asciz	'LEFT$("ABCD",2)'	; "AB"
TESTSTRG22:	.asciz	'LEFT$("ABCD",4)'	; "ABCD"
TESTSTRG23:	.asciz	'LEFT$("ABCD",66)'	; "ABCD"
TESTSTRG24:	.asciz	'LEFT$("",0)'		; ""
TESTSTRG25:	.asciz	'LEFT$("",5)'		; ""

;	TESTS OF RIGHT$
TESTSTRH21:	.asciz	'RIGHT$("ABCD",2)'	; "CD"
TESTSTRH22:	.asciz	'RIGHT$("ABCD",4)'	; "ABCD"
TESTSTRH23:	.asciz	'RIGHT$("ABCD",66)'	; "ABCD"
TESTSTRH24:	.asciz	'RIGHT$("",0)'		; ""
TESTSTRH25:	.asciz	'RIGHT$("",5)'		; ""


OUTSTR:		.ds 128

