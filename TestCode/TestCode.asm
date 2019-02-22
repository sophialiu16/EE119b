.device AT90S4414
.equ SREG = $3f 	; stack register location

; clear all registers
CLEAR:      EOR     R1, R1
            EOR     R2, R2
            EOR     R3, R3
            EOR     R4, R4
            EOR     R5, R5
            EOR     R6, R6
            EOR     R7, R7
            EOR     R8, R8
            EOR     R9, R9
            EOR     R10, R10
            EOR     R11, R11
            EOR     R12, R12
            EOR     R13, R13
            EOR     R14, R14
            EOR     R15, R15
            EOR     R16, R16
            EOR     R17, R17
            EOR     R18, R18
            EOR     R19, R19
            EOR     R20, R20
; ALU tests
ALUtests:
            RJMP     ADD1F
ADD1F: ;test ADIW
            EOR     R1, R1
            EOR     R25, R25
            EOR     R24, R24
            OUT     SReg, R1
            ADIW    R25:R24, $11    ; ADDIW 0, $11
            IN      R3, SReg
            STS     $FE00, R3       ; W 00 FE00
ADD1resF:
            LDI     R20, $C3        ;ensure top two bits in SReg not changed
            IN      R20, SReg
            CPI     R25, 0
            BREQ    ADD1resL
            NOP
ADD1resL:
            CPI     R24, $11
            BREQ    ADD2F
            NOP
ADD2F: ;test ADD Carry Flag
            LDI     R16, $F0
            LDI     R17, $52
            ADD     R16, R17        ; ADD $F0, $52
            IN      R18, SReg
            STS     $FE00, R18      ; W 01 FE00
ADD2res:
            CPI     R16, $42
            BREQ    ADD3F
            NOP
ADD3F: ;test ADD Zero Flag
            LDI     R18, $00
            LDI     R16, $00
            ADD     R16, R18        ; ADD 0, 0
            IN      R3, SReg
            STS     $FE01, R3       ; W 02 FE01
ADD3res:
            CPI     R16, $00
            BREQ    ADC1F
            NOP
ADC1F: ;test H,S,N flag
            LDI     R16, $0F
            LDI     R17, $81
            ADC     R16, R17        ; ADC $0F, $81
            IN      R3, SReg
            STS     $FE02, R3       ; W 34 FE02
ADC1res:
            CPI     R16, $90
            BREQ    ADC2F
            NOP
ADC2F: ;test S,V,C flags
            LDI     R18, $80
            LDI     R16, $80
            LDI     R17, $40
            LDI     R19, $40
            ADC     R16, R18        ; ADC $80, $80
            IN      R3, SReg
            STS     $FE03, R3       ; W 1B FE03
ADD4F: ;test S,V,N flags
            ADD     R17, R19        ; ADD $40, $40
            IN      R3, SReg
            STS     $FE00, R3       ; W 0C FE00
ADC2res:
            CPI     R16, $00
            BREQ    ADD4res
            NOP
ADD4res:
            CPI     R17, $80
            BREQ    AND1F
            NOP
AND1F:  ;test S,V,N,Z
            LDI     R16, $00
            OUT     SReg, R16       ;clear SReg
            LDI     R16, $D8
            LDI     R17, $D3
            AND     R16, R17        ; AND $D8, $D3
            IN      R3, SReg
            STS     $FF00, R3       ; W 14 FF00
AND1res:
            CPI     R16, $D0
            BREQ    AND2F
            NOP
AND2F: ; test S,V,N,Z
            LDI     R17, $2F
            AND     R16, R17        ; AND $D0, $2F
            IN      R3, SReg
            STS     $FF00, R3       ; W 02 FF00
AND1res1:
            CPI     R16, $00
            BREQ    ANDI1F
            NOP
ANDI1F:  ;test S,V,N,Z
            LDI     R16, $D8
            ANDI    R16, $D3        ; ANDI D8, D3
            IN      R3, SReg
            STS     $FF00, R3       ; W 14 FF00
ANDI1res:
            CPI     R16, $D0
            BREQ    ANDI2F
            NOP
ANDI2F: ; test S,V,N,Z
            ANDI    R16, $2F        ; ANDI D0, 2F
            IN      R3, SReg
            STS     $FF00, R3       ; W 02 FF00
ANDI1res1:
            CPI     R16, $00
            BREQ    ASR1F
            NOP
ASR1F:
            LDI     R16, $81
            ASR     R16             ; ASR $81
            IN      R3, SReg
            STS     $FF00, R3       ; W 15 FF00
ASR1res:
            CPI     R16, $C0
            BREQ    LSR1F
            NOP
LSR1F:
            LDI     R16, $81
            LSR     R16             ; LSR $81
            IN      R3, SReg
            STS     $FF00, R3       ; W 19 FF00
LSR1res:
            CPI     R16, $40
            BREQ    BCLR1
            NOP

BCLR1:
            LDI     R16, $19
            OUT     SReg, R16
            BCLR    1
            IN      R3, SReg
            STS     $FF00, R3       ; W 19 FF00
BCLR2:
            BCLR    0
            IN      R3, SReg
            STS     $0070, R3       ; W 18 0070
BCLR3:
            BCLR    4
            IN      R3, SReg
            STS     $0071, R3       ; W 08 0071
BSET1:
            BSET    1
            IN      R3, SReg
            STS     $FF00, R3       ; W 0A FF00
BCLR4:
            BCLR    7
            IN      R3, SReg
            STS     $FF80, R3       ; W 0A FF80
BSET2:
            BSET    6
            IN      R3, SReg
            STS     $FF81, R3       ; W 4A FF81
BLD1F:
            LDI     R16, $01
            BLD     R16, 7
            IN      R3, SReg
            STS     $FF00, R3       ; W 4A FF00
BLD1res:
            CPI     R16, $81
            BREQ    BST1F
            NOP
BST1F:
            BST     R16, 1
            IN      R3, SReg
            STS     $FF00, R3       ; W 02 FF00
BLD1res1:
            CPI     R16, $81
            BREQ    INC1res
            NOP
INC1res:
            INC     R16
            CPI     R16, $82        ; INC $81
            BREQ    DEC1res
            NOP
DEC1res:
            DEC     R16
            CPI     R16, $81        ; DEC $82
            BREQ    SUB1F
            NOP
SUB1F: ;test V
            LDI     R16, $AF
            LDI     R17, $7F
            SUB     R16, R17        ; SUB $AF, $7F
            IN      R3, SReg
            STS     $FF00, R3       ; W 18 FF00
SUB1res:
            CPI     R16, $30
            BREQ    SUBI1F
            NOP
SUBI1F: ;test 0
            SUBI    R16, $30        ; SUBI $30, $30
            IN      R3, SReg
            STS     $FF00, R3       ; W 02 FF00
SUBI1res:
            CPI     R16, $00
            BREQ    SWAP1
            NOP
SWAP1:
            SWAP    R16             ; SWAP 0
            CPI     R16, $00
            BREQ    SWAP2
            NOP
SWAP2:
            LDI     R16, $80
            SWAP    R16             ; SWAP $80
            CPI     R16, $08
            BREQ    COM1
            NOP

COM1:
	LDI 	R16, $00
	COM 	R16 		; COM 00
	LDI 	R17, $FF
	CPSE 	R16, R17 	; check result, skip if succeeds
	NOP

	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $15
	CPSE 	R24, R25	; check sreg correctly set
	NOP

COM2:
	COM 	R16 		; COM FF
	LDI 	R17, $00
	CPSE 	R16, R17 	; check result, skip if succeeds
	NOP

	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $03
	CPSE 	R24, R25	; check sreg correctly set
	NOP

COM3:
	LDI 	R16, $56
	COM 	R16 		; COM 56
	LDI 	R17, $A9
	CPSE 	R16, R17 	; check result, skip if succeeds
	NOP

	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $15
	CPSE 	R24, R25	; check sreg correctly set
	NOP

EOR1:
	LDI 	R16, $55
	LDI 	R17, $AA
	EOR 	R16, R17	; EOR $55, $AA

	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $15
	CPSE 	R24, R25	; check sreg correctly set
	ADD		R16, R17	; skip if success

	CPI 	R16, $FF	; check xor result
	BRBS 	1, EOR2		; branch if equal (zero bit set)
	LDI 	R16, $00 	; skip if equal

EOR2:
    OUT     SReg, R0    ; Clear sreg
	LDI 	R17, $FF
	EOR 	R16, R17 	; EOR $FF, $FF
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $02
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R16, $00	; check xor result
	BRBS 	1, NEG1		; branch if equal (zero bit set)
	STS 	$FF00, R16	; should skip if succeeds

NEG1:
	LDI 	R17, $FF
	NEG 	R17		 	; NEG $FF
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $21
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $01	; check result
	BRBS 	1, NEG2		; branch if equal (zero bit set)
	STS 	$FF00, R16	; should skip if succeeds

NEG2:
	LDI 	R17, $00
	NEG 	R17		 	; NEG $00
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $02
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $00	; check result
	BRBS 	1, NEG3		; branch if equal (zero bit set)
	STS 	$FF00, R16	; should skip if succeeds

NEG3:
	LDI 	R17, $80
	NEG 	R17		 	; NEG $FF
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $0D
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $80	; check result
	BRBS 	1, OR1		; branch if equal (zero bit set)
	STS 	$FF00, R16	; should skip if succeeds

OR1:
	LDI 	R16, $55
	LDI 	R17, $AA
	OR  	R16, R17 	; OR $55, $AA
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $14
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R16, $FF	; check or result
	BRBS 	1, ORI1		; branch if equal (zero bit set)
	ADIW 	R24, $A 	; should skip if succeeds

ORI1:
	ORI 	R17, $22 	; OR $AA, $22
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $14
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $AA	; check ori result
	BRBS 	1, ROR1		; branch if equal (zero bit set)
	ADIW 	R24, $A 	; should skip if succeeds

ROR1:
    OUT     SReg, R0    ; Clear sreg
	BSET 	0			; set carry bit
  	ROR 	R17		 	; ROR $AA
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $0C
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $D5	; check result
	BRBS 	1, ROR2		; branch if equal (zero bit set)
	SWAP 	R17		 	; should skip if succeeds

ROR2:
    OUT     SReg, R0    ; Clear sreg
	BCLR 	0			; clear carry bit
  	ROR 	R17		 	; ROR $D5
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $19
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $6A	; check result
	BRBS 	1, SBC1		; branch if equal (zero bit set)
	SWAP 	R17		 	; should skip if succeeds

SBC1:
    OUT     SReg, R0    ; Clear sreg
	BCLR 	0			; clear carry bit
	LDI 	R16, $00
	LDI 	R17, $FF
  	SBC 	R16, R17	; SBC 00, FF no carry
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $21
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R16, $01	; check result
	BRBS 	1, SBC2		; branch if equal (zero bit set)
	SWAP 	R16		 	; should skip if succeeds
	NOP

SBC2:
    OUT     SReg, R0    ; Clear sreg
	BSET 	0			; set carry bit
	LDI 	R16, $50
	LDI 	R17, $70
  	SBC 	R16, R17	; SBC 50, 70 with carry
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $35
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R16, $DF	; check result
	BRBS 	1, SBCI1	; branch if equal (zero bit set)
	LDI 	R16, $00	; should skip if succeeds
	NOP

SBCI1:
    OUT     SReg, R0    ; Clear sreg
	BSET	0			; set carry bit
	LDI 	R17, $7A
  	SBCI 	R17, $7A	; SBCI 7A, 7A with carry
	IN 		R24, SREG 	; store new sreg
	LDI 	R25, $35
	CPSE 	R24, R25	; check sreg correctly set
	NOP					; skip if success

	CPI 	R17, $FF	; check result
	BRBS 	1, SBIW1	; branch if equal (zero bit set)
	LDI 	R17, $00	; should skip if succeeds
	NOP

SBIW1:
    OUT     SReg, R0    ; Clear sreg
	LDI 	R24, $7A
	LDI 	R25, $01
  	SBIW 	R24, $0A	; SBCI 017A, A
	IN 		R16, SREG 	; store new sreg
	LDI 	R17, $00
	CPSE 	R16, R17	; check sreg correctly set
	NOP					; skip if success

	BSET	0			; clear carry bit
	LDI 	R16, $70
	LDI 	R17, $01 	; compare R25:R24 with R17:R16
	CP 		R24, R16	; compare low byte
	CPC 	R25, R17	; compare high byte
	BRBS 	1, BR1		; branch if equal (zero bit set)
	NOP 				; skip if success

BR1:
	LDI 	R16, $11
	CPI 	R16, $89
	BRBC	1, BR2
	NOP
	NOP

BR2:
	NOP
	SBRS	R16, 0		; SBRC $11 bit 0
	LDI		R16, $FF	; skip if success
	SBRC	R16, 2		; SBRS $11 bit 2
	LDS		R16, $FF00	; skip if success
	SBRC	R16, 5		; SBRS $11 bit 5
	ADIW	R25:R24, $11; skip if success

LoadStore:
; AVR load/store operations
; LDI
	IN 		R24, SREG	; store flags
	LDI		R16, $AB	; load R16 with constant xAB
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ 	LdISreg		; skip if check succeeds
	NOP

LdISreg:
	CPI		R16, $AB	; compare R16 with correct value
	BREQ 	LdIJmp		; skip if check succeeds
	NOP

LdIJmp:
; LD X
	LDI 	R17, $01
	STS 	$FF23, R17	; W 01 FF23
	LDI 	R27, $FF	; set X high byte to $FF
	LDI 	R26, $23	; set X low byte to $23
	IN      R24, SREG	; store flags
	LD  	R16, X		; R 01 FF23
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    LdXSReg		; skip if check succeeds
	NOP

LdXSReg:
	CPI		R16, $01	; compare R16 with correct value
	BREQ 	LdXJmp		; skip if check succeeds
	NOP

LdXJmp:
; LD X+ post increment
	IN      R24, SREG   ; store flags
	LD 		R17, X+		; R 01 FF23
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    LdXpSReg	; skip if check succeeds
	NOP

LdXpSreg:
	CP 		R17, R16 	; compare R17 with initially stored X
	BREQ 	LdXpJmp		; skip if check succeeds
	NOP

LdXpJmp:
	LDI 	R17, $22
	STS 	$FF24, R17	; W 22 FF24
	LD		R18, X		; R 22 FF24
	CPI     R18, $22	; check X incremented
	BREQ    LdXpCheck   ; skip if check succeeds
	NOP

LdXpCheck:
; LD -X pre decrement
	IN		R24, SREG 	; store flags
	LD		R19, -X  	; R 01 FF23
	IN		R25, SREG 	; store new flags
	CP		R24, R25    ; check flags unchanged
	BREQ    LdXdSreg	; skip if check succeeds
	NOp

LdXdSreg:
	CP 		R19, R16	; compare R19 with initially stored X
	BREQ	LdXdJmp 	; skip if check succeeds
	NOp

LdXdJmp:
; LD Y+ post increment
	LDI 	R16, $EE
	STS 	$FF45, R16	; W EE FF45
	LDI 	R29, $FF	; set Y high byte to $FF
	LDI 	R28, $45	; set Y low byte to $45
	LD 		R17, Y+		; R EE FF45
	CPI		R17, $EE 	; compare R17 with initially stored Y
	BREQ 	LdYpJmp		; skip if check succeeds
	NOP

LdYpJmp:
	CPI     R28, $46	; check Y incremented
	BREQ    LdYpCheck   ; skip if check succeeds
	NOP

LdYpCheck:
; LD -Y pre decrement
	LD		R19, -Y  	; R EE FF45
						; decrement Y and load R19
	CP 		R19, R16	; compare R25 with initially stored Y
	BREQ	LdYdJmp 	; skip if check succeeds
	NOP

LdYdJmp:
; LD Z+ post increment
	LDI 	R16, $78
	STS 	$FEA1, R16	; W 78 FEA1
	LDI 	R31, $FE	; set Z high byte to $FE
	LDI 	R30, $A1	; set Z low byte to $A1
	LD 		R17, Z+		; R 78 FEA1
	CP 		R17, R16 	; compare R17 with initially stored Z
	BREQ 	LdZpJmp		; skip if check succeeds
	NOP

LdZpJmp:
	CPI     R30, $79	; check Z incremented
	BREQ    LdZpCheck   ; skip if check succeeds
	NOP

LdZpCheck:
; LD -Z pre decrement
	LD		R19, -Z  	; R 78 FEA1
	CP 		R19, R16	; compare R25 with initially stored Z
	BREQ	LdZdJmp 	; skip if check succeeds
	NOP

LdZdJmp:
; LDD Y + q unsigned displacement
	LDI 	R18, $06
	STS 	$0076, R18	; W 06 0076
	CLR 	R29			; clear Y high byte to $00
	LDI 	R28, $71	; set Y low byte to $71
	IN      R24, SREG	; store flags
	LDD  	R16, Y+5	; R 06 0076
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    LdYQSReg	; skip if check succeeds
	NOP

LdYQSReg:
	CPI		R16, $06	; compare R16 with correct value
	BREQ 	LdYQJmp		; skip if check succeeds
	NOP

LdYQJmp:
; LDD Z + q unsigned displacement
	LDI 	R18, $FF
	STS 	$002C, R18	; IO Reg addr - W FF 002C
	CLR 	R31			; clear Z high byte to $00
	LDI 	R30, $22	; set Z low byte to $22
	IN      R24, SREG	; store flags
	LDD  	R16, Z+10	; IO Reg addr - R FF 002C
						; load R16 with contents of data space Z+10
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    LdZQSReg	; skip if check succeeds
	NOP

LdZQSReg:
	CPI		R16, $FF	; compare R16 with correct value
	BREQ 	LdZQJmp		; skip if check succeeds
	NOP

LdZQJmp:
; LDS
	LDI		R18, $2B 
	STS		$FF81, R18	; W 2B FF81
	LDS 	R20, $FF81	; R 2B FF81
						; load R20 with consents of data space $10FF
	CPI		R20, $2B	; compare R20 with correct value
	BREQ 	LdSJmp		; skip if check succeeds
	NOP

LdSJmp:
; MOV
	LDI		R20, $26	; load R20 with x26
	LDI     R21, $90	; load R21 with x90
	IN      R24, SREG	; store flags
	MOV 	R21, R20	; copy R20 to R21
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    MovSReg		; skip if check succeeds
	NOP

MovSreg:
	CP 		R21, R20 	; check R21 = R20
	BREQ 	MovJmp		; skip if check succeeds
	NOP

MovJmp:
	CPI 	R21, $26  	; check R20 copied to R21
	BREQ	MovJmp1		; skip if check succeeds
	NOP

MovJmp1:
; St X
	LDI     R22, $58	; load R22 with x58
	CLR		R27			; clear X high byte
	LDI 	R26, $7B	; set X low byte to $7B
	IN      R24, SREG	; store flags
	ST  	X, R22		; W 58 007B
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StXSReg		; skip if check succeeds
	NOP

StXSReg:
	LD 		R23, X		; R 58 007B
	CP		R23, R22	; compare R23 with R22 (=$58)
	BREQ	StXJmp		; skip if check succeeds
	NOP

StXJmp:
; St X + post increment
	LDI 	R16, $12	; load R16 with $12
	IN      R24, SREG	; store flags
	ST  	X+, R16		; W 12 007B
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StXpSReg	; skip if check succeeds
	NOP

StXpSReg:
	CPI     R26, $7C	; check X incremented (low byte)
	BREQ   	StXpCheck	; skip if check succeeds
	NOP

StXpCheck:
	CPI     R27, $00	; check X incremented (high byte)
	BREQ   	StXpCheck1	; skip if check succeeds
	NOP

StXpCheck1:
	LD 		R17, -X		; R 12 007B
	CP		R17, R16	; compare R17 with R16 (=$12)
	BREQ	StXpJmp		; skip if check succeeds
	NOP

StXpJmp:
	CPI		R17, $12	; compare R17 with constant $12
	BREQ	StXpJmp1	; skip if check succeeds
	NOP

StXpJmp1:
; St -X pre decrement
	; X $007B
	LDI     R18, $44    ; load R18 with $44
	IN      R24, SREG	; store flags
	ST  	-X, R18		; W 44 007A
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StXdSReg	; skip if check succeeds
	NOP

StXdSReg:
	CPI     R26, $7A	; check X decremented (low byte)
	BREQ   	StXdCheck	; skip if check succeeds
	NOP

StXdCheck:
	CPI     R27, $00	; check X decremented (high byte)
	BREQ   	StXdCheck1	; skip if check succeeds
	NOP

StXdCheck1:
	LD 		R19, X		; R 44 007A
	CP 		R19, R18    ; compare R18 with R19
	BREQ 	StXdJmp		; skip if check succeeds
	NOP

StXdJmp:
	CPI		R19, $44	; compare R19 with constant $44
	BREQ	StXdJmp1	; skip if check succeeds
	NOP					

StXdJmp1:
; St Y + post increment
	CLR		R29			; clear Y high byte
	LDI 	R28, $19	; set Y low byte to $19
	LDI 	R16, $12	; load R16 with $12
	ST  	Y+, R16		; reg remap addr - W 12 0019 
						; store R16 in data space Y and post increment
	CPI     R28, $1A	; check Y incremented (low byte)
	BREQ   	StYpCheck	; skip if check succeeds
	NOP

StYpCheck:
	CPI     R29, $00	; check Y incremented (high byte)
	BREQ   	StYpCheck1	; skip if check succeeds
	NOP

StYpCheck1:
	LD 		R17, -Y		; load R17 with pre decremented Y
	CPI		R17, $12	; compare R17 with R16 (=$12)
	BREQ	StYpJmp		; skip if check succeeds
	NOP

StYpJmp:
; St -Y pre decrement
	; Y $0019
	LDI     R18, $44    ; load R18 with $44
	ST  	-Y, R18		; store to R24 - W 44 0018 
	CPI     R28, $18	; check Y decremented (low byte)
	BREQ   	StYdCheck	; skip if check succeeds
	NOP

StYdCheck:
	CPI     R29, $00	; check Y decremented (high byte)
	BREQ   	StYdCheck1	; skip if check succeeds
	NOP

StYdCheck1:
	LD 		R19, Y+		; load R19 with Y (R24)
	CP 		R19, $44    ; check loaded from Y correctly 
	BREQ 	StYdJmp		; skip if check succeeds
	NOP

StYdJmp1:
; St Z + post increment
	LDI     R22, $CD	; load R22 with $CD
	CLR		R31			; clear Z high byte
	LDI 	R30, $69	; set Z low byte to $69
	LDI 	R16, $12	; load R16 with $12
	IN      R24, SREG	; store flags
	ST  	Z+, R16		; W 12 0069
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StZpSReg	; skip if check succeeds
	NOP

StZpSReg:
	CPI     R30, $6A	; check Z incremented (low byte)
	BREQ   	StZpCheck	; skip if check succeeds
	NOP

StZpCheck:
	CPI     R31, $00	; check Z incremented (high byte)
	BREQ   	StZpCheck1	; skip if check succeeds
	NOP

StZpCheck1:
	LD 		R17, -Z		; load R17 with pre decremented Z
	CP		R17, R16	; compare R17 with R16 (=$12)
	BREQ	StZpJmp		; skip if check succeeds
	NOP

StZpJmp:
	CPI		R17, $12	; compare R17 with constant $12
	BREQ	StZpJmp1	; skip if check succeeds
	NOP					; (probably an unnecessary check)

StZpJmp1:
; St -Z pre decrement
	; Y $0069
	LDI     R18, $44    ; load R18 with $44
	IN      R24, SREG	; store flags
	ST  	-Z, R18		; W 44 0068
						; store R18 in data space Z - 1
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StZdSReg	; skip if check succeeds
	NOP

StZdSReg:
	CPI     R30, $68	; check Z decremented (low byte)
	BREQ   	StZdCheck	; skip if check succeeds
	NOP

StZdCheck:
	CPI     R31, $00	; check Z decremented (high byte)
	BREQ   	StZdCheck1	; skip if check succeeds
	NOP

StZdCheck1:
	LD 		R19, Z		; load R19 with Z
	CP 		R19, R18    ; compare R18 with R19
	BREQ 	StZdJmp		; skip if check succeeds
	NOP

StZdJmp:
	CPI		R19, $44	; compare R19 with constant $44
	BREQ	StZdJmp1	; skip if check succeeds
	NOP					; (probably an unnecessary check)

StZdJmp1:
; STD Y + q
	CLR 	R29			; clear high byte of Y
	LDI 	R28, $77	; load low byte of Y with $77
	LDI 	R20, $73	; load R20 with $73
	IN      R24, SREG	; store flags
	STD  	Y + $11, R20; W 73 0088
						; store R20 ($73) in data space Y($0077) + q($11)
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StdYqSReg	; skip if check succeeds
	NOP

StdYqSreg:
	LDD		R21, Y + $11 	; R 73 0088
							; load Y + q into R21
	CP 		R20, R21		; compare R20 and R21
	BREQ	StdYqJmp		; skip if check succeeds
	NOP

StdYqJmp:
; STD Z + q
	CLR 	R21			; clear high byte of Y
	LDI 	R30, $67	; load low byte of Y with $67
	LDI 	R20, $AA	; load R20 with $AA
	IN      R24, SREG	; store flags
	STD  	Z + $11, R20; W 73 0078
						; store R20 ($AA) in data space Z($0067) + q($11)
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StdZqSReg	; skip if check succeeds
	NOP

StdZqSreg:
	LDD		R21, Z + $11    ; R 73 0078
							; load Z + a into R21
	CP 		R20, R21		; compare R20 and R21
	BREQ	StdZqJmp		; skip if check succeeds
	NOP

StdZqJmp:
; STS
	LDI 	R16, $99	; load R16 with $99
	IN      R24, SREG	; store flags
	STS 	$FE57, R16	; W 99 FE57
						; store R16 ($99) in data space address $FE57
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    StsSReg		; skip if check succeeds
	NOP

StsSReg:
	LDS 	R17, $FE57  ; R 99 FE57
						; load R17 with data space contents of $FE57
	CP 		R16, R17 	; compare R16 and R17
	BREQ	StsJmp		; skip if check succeeds
	NOP

StsJmp:
; PUSH, POP
	PUSH 	R24			; put some things on the stack
	PUSH 	R0
	PUSH 	R24
	LDI 	R18, $50	; load R18 with $50
	IN      R24, SREG	; store flags
	PUSH 	R18			; push R18 onto stack
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    PushSReg	; skip if check succeeds
	NOP

PushSReg:
	LDI 	R19, $EF	; load R19 with $EF
	IN      R24, SREG	; store flags
	PUSH 	R19			; push R19 onto stack
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    PushSReg1	; skip if check succeeds
	NOP

PushSReg1:
	LDI 	R19, $31 	; load a different value into R19
	LDI 	R18, $67 	; load a different value into R18
	IN      R24, SREG	; store flags
	POP 	R19			; pop R19 off stack
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    PopSReg		; skip if check succeeds
	NOP
; check sp dec
PopSReg:
	CPI		R19, $EF 	; check R19 popped off stack
	BREQ	PopJmp		; skip if check succeeds
	NOP

PopJmp:
	IN      R24, SREG	; store flags
	POP 	R18			; pop R18 off stack
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    PopSReg1	; skip if check succeeds
	NOP

PopSReg1:
	CPI		R18, $50 	; check R18 popped off stack
	BREQ	PopJmp1		; skip if check succeeds
	NOP

PopJmp1:
; Unconditional branches
; JMP
	IN      R24, SREG	; store flags
	;JMP JmpTest
	RJMP JmpTest		; skip if check succeeds
	NOP

JmpTest:
	IN      R25, SREG	; store new flags
	CP 		R24, R25    ; check flags unchanged
	BREQ    JumpSReg	; skip if check succeeds
	NOP

JumpSReg:
; CALL
	IN      R24, SREG	; store flags
	;CALL 	CallTest
	RCALL 	CallTest	; skip to CallTest if succeeds
	IN      R25, SREG	; store new flags
	CPSE 	R24, R25    ; check flags unchanged
	;BREQ    CallSReg	; skip if check succeeds
	NOP

CallSReg:
; ICALL
	LDI 	R30, $7A
	LDI 	R31, $02	; load Z with ICallTest address ($019D) --TODO
	IN      R24, SREG	; store flags
	ICALL				; skip to ICallTest if succeeds
	IN      R25, SREG	; store new flags
	CPSE 	R24, R25    ; check flags unchanged
	;BREQ    ICallSReg	; skip if check succeeds

End:
	NOP

ICallSreg:
; I/O tests
	; check registers
	SBI 	$12, 3		; set bit 3 of port D
	CBI 	$12, 3		; clear bit 3 of port D

	; SLEEP		; sleep until interrupt
	NOP
	RET

CallTest:				; subroutine test
; RET
	NOP
	MOV R16, R0			; do something
	RET					; return from subroutine

ICallTest:				; indirect subroutine call test
	NOP
	ADD R1, R2			; do something
	RET
; JMP, RJMP, IJMP
