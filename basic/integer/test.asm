.module 	inttest
.title 		Tests Integer Module

.include	'integer.def'
.include	'..\io\io.def'


STACK	==	0xFFFF			;SYSTEM STACK

.area	BOOT	(ABS)

.org 	0x0000
	
RST0:
	LXI	SP,STACK		;INITALIZE STACK
	JMP 	START

.org	0x0038
RST7:	
	HLT
	

;*********************************************************
;* MAIN PROGRAM
;*********************************************************
.area 	_CODE

START:
 	CALL IO_CLS
;	CALL TEST_INEG
;	CALL TEST_IADD
;	CALL TEST_ISUB
;	CALL TEST_ICMP
;	CALL TEST_IMUL
	CALL TEST_ITOA
	CALL TEST_ITOA2
;	CALL TEST_ABS
;	CALL TEST_SGN
;	CALL TEST_RND
;	CALL TEST_SQR
	HLT

TEST_INEG:
	LXI	H,0x0000		; = 0
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_NEG			; SHOULD BE 0
	
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_NEG			; SHOULD BE -1 (0xFFFF)

	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_NEG			; SHOULD BE 1 (0x0001)

	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,INT_ACC0	
	CALL	INT_NEG			; SHOULD BE -32767 (0x8001)

	LXI	H,0x8001		; = -32767
	SHLD	INT_ACC0
	LXI	H,INT_ACC0	
	CALL	INT_NEG			; SHOULD BE 32767 (0x7FFF)
	
	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC0
	LXI	H,INT_ACC0	
	CALL	INT_NEG			; OVERFLOW SHOULD BE 1
	
	RET

TEST_IADD:
	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_ADD			; OVERFLOW SHOULD BE 1

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC0
	LXI	H,0x8001		; = -32767
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_ADD			; = -32768

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC0
	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_ADD			; = OVERFLOW SHOULD BE 1

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_ADD			; = OVERFLOW SHOULD BE 1

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x4000		; = 16384
	SHLD	INT_ACC0
	LXI	H,0x3FFF		; = 16383
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_ADD			; = 32767 (0x7FFF)

	RET

TEST_ISUB:
	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = 0 (0x0000)

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = OVERFLOW SHOULD BE 1

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x0000		; = 0
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = -1 (0xFFFF)

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0x8001		; = -32767
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = -32768 (0x8000)

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC0
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = -32768 (0x8000)

	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	LXI	H,0xFFFE		; = -2
	SHLD	INT_ACC0
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_SUB			; = OVERFLOW SHOULD BE 1

	RET

TEST_ICMP:
	LXI	H,0x0000		; = 0
	SHLD	INT_ACC0
	LXI	H,0x0000		; = 0
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0

	LXI	H,0x0000		; = 0
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0xFF

	LXI	H,0x0001		; = 1
	SHLD	INT_ACC0
	LXI	H,0x0000		; = 0
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0x01

	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC0
	LXI	H,0x0001		; = 1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0xFF

	LXI	H,0x0001		; = 1
	SHLD	INT_ACC0
	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0x01

	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0x01

	LXI	H,0xFFFF		; = -1
	SHLD	INT_ACC0
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0xFF

	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC0
	LXI	H,0x8000		; = -32768
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0x00

	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC0
	LXI	H,0x7FFF		; = 32767
	SHLD	INT_ACC1
	LXI	H,INT_ACC1
	CALL	INT_CMP			; ACC = 0x00

	RET

TEST_IMUL:
	MVI	A,0
	STA	INT_OVERFLOW		; RESET OVERFLOW FLAG
	
	LXI	H,2048
	SHLD	INT_ACC0
	LXI	H,15
	SHLD	INT_ACC2
	LXI	H,INT_ACC2
	CALL	INT_MUL

	RET

TEST_ITOA:
	LXI	H,0
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "0", LEN 1
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,1
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "1", LEN 1
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,10
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "10", LEN 2
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,100
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "100", LEN 3
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,1000
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "1000", LEN 4
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	
	
	LXI	H,10000
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "10000", LEN 5
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,32767
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "32767", LEN 5
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-1
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-1", LEN 2
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-10
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-10", LEN 3
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-100
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-100", LEN 4
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-1000
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-1000", LEN 5
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	
	
	LXI	H,-10000
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-10000", LEN 6
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-32767
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-32767", LEN 6
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	

	LXI	H,-32768
	SHLD	INT_ACC0
	CALL	INT_ITOA		; = "-32768", LEN 6
	CALL	IO_PUTCH
	MVI	A,':
	CALL	IO_PUTC
	CALL	IO_PUTS
	CALL	IO_PUTCR	
	
	RET

; ITOA all values from 0-255
TEST_ITOA2:
	MVI	B,0x00
1$:
	MVI	H,0
	MOV	L,B
	SHLD	INT_ACC0
	CALL	INT_ITOA
	CALL	IO_PUTS
	MVI	A,'\t
	CALL 	IO_PUTC	
	INR 	B
	JNZ 	1$
	RET

TEST_ATOI:
	LXI	H,TESTSTR1
	CALL	INT_ATOI

	LXI	H,TESTSTR2
	CALL	INT_ATOI

	LXI	H,TESTSTR3
	CALL	INT_ATOI

	LXI	H,TESTSTR4
	CALL	INT_ATOI

	LXI	H,TESTSTR5
	CALL	INT_ATOI

	LXI	H,TESTSTR6
	CALL	INT_ATOI

;	LXI	H,TESTSTR7
;	CALL	INT_ATOI

	LXI	H,TESTSTR8
	CALL	INT_ATOI

	LXI	H,TESTSTR9
	CALL	INT_ATOI

	LXI	H,TESTSTR10
	CALL	INT_ATOI

	LXI	H,TESTSTR11
	CALL	INT_ATOI

	LXI	H,TESTSTR12
	CALL	INT_ATOI

	LXI	H,TESTSTR13
	CALL	INT_ATOI

;	LXI	H,TESTSTR14
;	CALL	INT_ATOI

	LXI	H,TESTSTR15
	CALL	INT_ATOI

	LXI	H,TESTSTR16
	CALL	INT_ATOI

	LXI	H,TESTSTR17
	CALL	INT_ATOI

	LXI	H,TESTSTR18
	CALL	INT_ATOI

	LXI	H,TESTSTR19
	CALL	INT_ATOI

	LXI	H,TESTSTR20
	CALL	INT_ATOI

;	LXI	H,TESTSTR21
;	CALL	INT_ATOI

	LXI	H,TESTSTR22
	CALL	INT_ATOI

;	LXI	H,TESTSTR23
;	CALL	INT_ATOI

	LXI	H,TESTSTR24
	CALL	INT_ATOI

	LXI	H,TESTSTR25
	CALL	INT_ATOI

	RET

TEST_ABS:
	LXI	H,0x0000	; ABS(0)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = 0

	LXI	H,0x0001	; ABS(1)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = 1

	LXI	H,0xFFFF	; ABS(-1)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = 1

	LXI	H,0x7FFF	; ABS(32767)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = 32767

	LXI	H,0x8001	; ABS(-32767)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = 32767

	LXI	H,0x8000	; ABS(-32768)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_ABS		; = OVERFLOW

	RET

TEST_SGN:
	LXI	H,0x0000	; SGN(0)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = 0

	LXI	H,0x0001	; SGN(1)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = 1

	LXI	H,0xFFFF	; SGN(-1)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = -1

	LXI	H,0x7FFF	; SGN(32767)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = 1

	LXI	H,0x8001	; SGN(-32767)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = -1

	LXI	H,0x8000	; SGN(-32768)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SGN		; = -1

	RET

TEST_RND:
	CALL	INT_RND
	CALL	INT_RND
	CALL	INT_RND
	CALL	INT_RND
	
	RET

TEST_SQR:
	LXI	H,0x0000	; SQR(0)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 0

	LXI	H,0x0001	; SQR(1)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 1

	LXI	H,0x0002	; SQR(2)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 1

	LXI	H,0x0004	; SQR(4)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 2

	LXI	H,0x0005	; SQR(5)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 2

	LXI	H,0x0050	; SQR(80)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 8

	LXI	H,0x0500	; SQR(1280)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 35

	LXI	H,0x5000	; SQR(20480)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 143

	LXI	H,0x7FFF	; SQR(32767)
	SHLD	INT_ACC0
	LXI	H,INT_ACC0
	CALL	INT_SQR		; = 181
	
	RET

TESTSTR1:	.asciz	'0'
TESTSTR2:	.asciz	'1'
TESTSTR3:	.asciz	'12'
TESTSTR4:	.asciz	'123'
TESTSTR5:	.asciz	'1234'
TESTSTR6:	.asciz	'12345'
TESTSTR7:	.asciz	'123456'

TESTSTR8:	.asciz	'+0'
TESTSTR9:	.asciz	'+1'
TESTSTR10:	.asciz	'+12'
TESTSTR11:	.asciz	'+123'
TESTSTR12:	.asciz	'+1234'
TESTSTR13:	.asciz	'+12345'
TESTSTR14:	.asciz	'+123456'

TESTSTR15:	.asciz	'-0'
TESTSTR16:	.asciz	'-1'
TESTSTR17:	.asciz	'-12'
TESTSTR18:	.asciz	'-123'
TESTSTR19:	.asciz	'-1234'
TESTSTR20:	.asciz	'-12345'
TESTSTR21:	.asciz	'-123456'

TESTSTR22:	.asciz	'32767'
TESTSTR23:	.asciz	'32768'

TESTSTR24:	.asciz	'-32767'
TESTSTR25:	.asciz	'-32768'