; FINAL PROJECT - ECE 151
; MARK BRYK AND KELVIN LIN

	LIST	P=PIC16F877A9
	include <p16F877A.inc>
	__CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF

CASE0	EQU	0x00
CASE1	EQU	0x10
CASE2	EQU	0x20
CASE3	EQU	0x30
CASE4	EQU	0x40
CASE5	EQU	0x50
CASE6	EQU	0x60
CASE7	EQU	0x70
CASE8	EQU	0x80
CASE9	EQU	0x90
CASE10	EQU	0xA0
CASE11	EQU	0xB0
CASE12	EQU	0xC0
CASE13	EQU	0xD0
CASE14	EQU	0xE0

CBLOCK	0x20
INS1
INS2
MYSTATUS
PC
DATAWRITE
OFFSET
OFFTMP
DATATMP
BB
TOS
ENDC

	ORG 0x00
	goto	start
	

	ORG 0x10
start
	bsf	STATUS, RP0	; Bank 1
	movlw 	0x07 
	movwf	ADCON1 ; Set all lower bits of ADCON Special Reg to allow I/O from PORTE
	movlw	0xFF
	movwf	TRISA	; 	PORTA = 6 bits- Inputs from ALU
	movlw	0x00	; All bits output
	movwf	TRISB	; 	PORTB = Outputs to ALU - INS2
	movwf	TRISC	;	PORTC = First Half of Instruction 	
	bcf	STATUS, RP0	; Bank 0
	
	MOVLW 0x00 ; clear PC
	MOVWF	PC	
	GOTO	LJMP


LSTART
	INCF	PC, F

LJMP	
	CALL	readins
	
	MOVF	INS1, W;
	ANDLW	0xF0	; Take first 4 bits of Ins1 = Mode
	
	XORLW	CASE0	; If W is Case0, this will make W 0;
	BTFSC	STATUS, Z
	GOTO	L0
	XORLW	CASE1
	BTFSC	STATUS, Z
	GOTO	L1
	XORLW	CASE1^CASE2
	BTFSC	STATUS, Z
	GOTO	L2
	XORLW	CASE2^CASE3
	BTFSC	STATUS, Z
	GOTO	L3
	XORLW	CASE3^CASE4
	BTFSC	STATUS, Z
	GOTO	L4
	XORLW	CASE4^CASE5
	BTFSC	STATUS, Z
	GOTO	L5
	XORLW	CASE5^CASE6
	BTFSC	STATUS, Z
	GOTO	L6
	XORLW	CASE6^CASE7
	BTFSC	STATUS, Z
	GOTO	L7
	XORLW	CASE7^CASE8
	BTFSC	STATUS, Z
	GOTO	L8
	XORLW	CASE8^CASE9
	BTFSC	STATUS, Z
	GOTO	L9
	XORLW	CASE9^CASE10
	BTFSC	STATUS, Z
	GOTO	L10
	XORLW	CASE10^CASE11
	BTFSC	STATUS, Z
	GOTO	L11
	XORLW	CASE11^CASE12
	BTFSC	STATUS, Z
	GOTO	L12
	XORLW	CASE12^CASE13
	BTFSC	STATUS, Z
	GOTO	L13
	XORLW	CASE13^CASE14
	BTFSC	STATUS, Z
	GOTO	L14

L0	nop
	GOTO	LSTART

L1	; ADD
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	OFFSET
			SWAPF	OFFSET
			
			CALL	readdata
			MOVWF	PORTB
			SWAPF	PORTB, F
		; Grab C title,
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET

	;Read C bucket and put in bottom of Port B (to ALU)
			CALL	readdata
			XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x07     
		MOVWF	PORTC

	; Clear Z and C bits of MyStatus Register		
		MOVLW	0xFC          
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 5      ; Check Z and C ALU outputs in PortA
		BSF		MYSTATUS, 0
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1	

	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART
	
L2	; SUB
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	OFFSET
			SWAPF	OFFSET
			
			CALL	readdata
			MOVWF	PORTB
			SWAPF	PORTB, F
		; Grab C title,
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET

	;Read C bucket and put in bottom of Port B (to ALU)
			CALL	readdata
			XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x06     
		MOVWF	PORTC

	; Clear Z and C bits of MyStatus Register		
		MOVLW	0xFC          
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 5      ; Check Z and C ALU outputs in PortA
		BSF		MYSTATUS, 0
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1	

			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L3	; AND
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	OFFSET
			SWAPF	OFFSET
			
			CALL	readdata
			MOVWF	PORTB
			SWAPF	PORTB, F
		; Grab C title,
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET

	;Read C bucket and put in bottom of Port B (to ALU)
			CALL	readdata
			XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x00     
		MOVWF	PORTC

	; Clear Z and C bits of MyStatus Register		
		MOVLW	0xFD          
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1	

			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L4	; OR
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	OFFSET
			SWAPF	OFFSET
			
			CALL	readdata
			MOVWF	PORTB
			SWAPF	PORTB, F
		; Grab C title,
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET

	;Read C bucket and put in bottom of Port B (to ALU)
			CALL	readdata
			XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x01     
		MOVWF	PORTC

	; Clear Z and C bits of MyStatus Register		
		MOVLW	0xFD          
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1	

			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L5	; XOR
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	OFFSET
			SWAPF	OFFSET
			
			CALL	readdata
			MOVWF	PORTB
			SWAPF	PORTB, F
		; Grab C title,
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET

	;Read C bucket and put in bottom of Port B (to ALU)
			CALL	readdata
			XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x02     
		MOVWF	PORTC

	; Clear Z and C bits of MyStatus Register		
		MOVLW	0xFD          
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1	

			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L6	;Shift Case
		BTFSC	INS2, 7	
		GOTO	L6R		; Right Shift
; Left Shift	
	; Grab "B" title
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET
			SWAPF	OFFSET, F
			CALL 	readdata	
			MOVWF	PORTB
			SWAPF	PORTB, F
			
			MOVLW	0x03
			MOVWF	PORTD

	; Clear C bit of MyStatus Register
		MOVLW	0xFE
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 5
		BSF		MYSTATUS, 0
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

	L6R
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET
			SWAPF	OFFSET, F
			CALL 	readdata	
			MOVWF	PORTB
			SWAPF	PORTB, F
			
			MOVLW	0x04
			MOVWF	PORTD
	
			MOVLW	0x01
			MOVWF	PORTE
	; Clear C bit of MyStatus Register
		MOVLW	0xFE
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 5
		BSF		MYSTATUS, 0
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L7 	;Not Case
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	OFFSET
	;Read "B" bucket from SRAM and put in bottom of Port B (to ALU)
			CALL 	readdata
			MOVWF	PORTB
			SWAPF	PORTB	
			
			MOVLW	0x05
			MOVWF	PORTD
	
	; Clear Z bit of MyStatus Register
		MOVLW	0xFD
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1
	
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	OFFSET
			MOVF	PORTA, W
			MOVWF	DATAWRITE
			CALL	writedata

	GOTO	LSTART

L8	;Move Case
	;Clear the Z bit
	MOVLW	0xFD
	ANDWF	MYSTATUS, F
	BTFSC	INS2, 7
	GOTO	L8b ; This is move FF
	
		MOVF INS2, W
		ANDLW	0x0F
		MOVWF	DATAWRITE
	
	; set the Z bit of MyStatus Register
		BTFSS	STATUS, Z
		BSF		MYSTATUS, 1

		MOVF	INS1, W		
		ANDLW	0x0F
		MOVWF	OFFSET
		CALL	writedata
			
	GOTO LSTART

L8b	;Move Case 1 - MOVE FF
		MOVF	INS2, W
		ANDLW	0x0F
		MOVWF	OFFSET
		CALL	readdata
		
		MOVWF	DATAWRITE

	; set the Z bit of MyStatus Register
		BTFSS	STATUS, Z
		BSF		MYSTATUS, 1

		MOVF	INS1, W		
		ANDLW	0x0F
		MOVWF	OFFSET
		CALL	writedata

	GOTO LSTART

L9	;LOD
	;Clear the Z bit
	MOVLW	0xFD
	ANDWF	MYSTATUS, F
	BTFSC	INS2, 7
	GOTO	L9b 	
	
	;Given offset
	MOVF	INS2, W
	MOVWF	OFFSET
	CALL	readdata

	; set the Z bit of MyStatus Register
	BTFSS	STATUS, Z
	BSF		MYSTATUS, 1

	MOVWF	DATAWRITE
	MOVF	INS1, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	writedata
	GOTO	LSTART

L9b	;Given Rb as offset
	MOVF	INS2, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	OFFTMP
	SWAPF	OFFTMP, F
	INCF	OFFSET, F
	CALL	readdata
	XORWF	OFFTMP, W
	MOVWF	OFFSET
	CALL	readdata

	; set the Z bit of MyStatus Register
	BTFSS	STATUS, Z
	BSF		MYSTATUS, 1

	MOVWF	DATAWRITE
	MOVF	INS1, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	writedata
	
	GOTO LSTART

L10	;STO
	;Clear the Z bit
	MOVLW	0xFD
	ANDWF	MYSTATUS, F

	BTFSC	INS2, 7
	GOTO	L10b ; This is from Rb
	
	MOVF	INS1, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	DATAWRITE
	
	; set the Z bit of MyStatus Register
	BTFSS	STATUS, Z
	BSF		MYSTATUS, 1
	
	MOVF	INS2, W
	MOVWF	OFFSET
	CALL	writedata

	GOTO	LSTART
	
L10b
	MOVF	INS1, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	DATAWRITE

	; set the Z bit of MyStatus Register
	BTFSS	STATUS, Z
	BSF		MYSTATUS, 1

	MOVF	INS2, W
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	OFFTMP
	SWAPF	OFFTMP, F
	INCF	OFFSET, F
	CALL	readdata
	XORWF	OFFTMP, W
	MOVWF	OFFSET
	CALL	writedata

	GOTO 	LSTART

L11	;TSC/TSS	
	;Find out what bb is
	MOVF	INS2, W
	ANDLW	0x03
	MOVWF	BB

	MOVF	INS1, W		
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	
	MOVWF	DATATMP
	
	BTFSC	INS2, 7
	GOTO	L11b ; This is TSS

	BTFSS	DATATMP, BB
	INCF	PC, F
	GOTO 	LSTART	

L11b
	BTFSC	DATATMP, BB
	INCF	PC, F
	GOTO 	LSTART	

L12	;Jump
	BTFSC	INS1, 3
	GOTO	L12b ; This is Jump based on Rb
	
	MOVF	INS2, W
	MOVWF	PC
	GOTO 	LJMP

L12b
	; Grab A title, send it to SRAM
	MOVF	INS2, W		
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	PC
	SWAPF	PC, F
	INCF	OFFSET, F
	CALL	readdata
	XORWF	PC, F
	GOTO 	LJMP

L13	
	;JSR
	INCF	PC, W
	MOVWF	TOS
	
	BTFSC	INS1, 3
	GOTO	L13b ; This is JSR to Ra

	; This is JSR to literal k
	MOVF	INS2, W
	MOVWF	PC
	GOTO 	LJMP

L13b
	MOVF	INS2, W		
	ANDLW	0x0F
	MOVWF	OFFSET
	CALL	readdata
	MOVWF	PC
	SWAPF	PC, F
	INCF	OFFSET, F
	CALL	readdata
	XORWF	PC, F
	GOTO	LJMP

L14	
	MOVF	TOS, W
	MOVWF	PC
	GOTO	LJMP


	ORG 0x200	
writedata:
	movlw	0xA0
	addwf	OFFSET, W
	bsf		STATUS, RP0	; Bank 1
	movwf	FSR
	bcf		STATUS, RP0	; Bank 0
	movf	DATAWRITE, W
	bsf		STATUS, RP0	; Bank 1
	MOVWF	INDF
	bcf 	STATUS, RP0
	return

readdata:
	MOVLW	0xA0
	ADDWF	OFFSET, W
	BSF		STATUS, RP0	; Bank 1
	MOVWF	FSR
	MOVF	INDF, W
	BCF		STATUS, RP0	; Bank 0
	RETURN

readins:
	BCF		STATUS, C
	RLF		PC, W;
	BSF 	STATUS, RP1 ;
	BCF 	STATUS, RP0 ;Bank 2
	MOVWF 	EEADR ;to read from
	BSF 	STATUS, RP0 ;Bank 3
	BCF 	EECON1, EEPGD ;Point to Data memory
	BSF 	EECON1, RD ;Start read operation
	BCF 	STATUS, RP0 ;Bank 2
	MOVF 	EEDATA, W ;
	BCF		STATUS, RP1
	MOVWF	INS1
	
	BSF 	STATUS, RP1
	INCF 	EEADR, F ;to read from
	BSF 	STATUS, RP0 ;Bank 3
	BCF 	EECON1, EEPGD ;Point to Data memory
	BSF 	EECON1, RD ;Start read operation
	BCF 	STATUS, RP0 ;Bank 2
	MOVF 	EEDATA, W ;W = EEDATA
	BCF		STATUS, RP1
	MOVWF	INS2
	RETURN
END