; FINAL PROJECT - ECE 151
; MARK BRYK AND KELVIN LIN

	LIST	P=PIC16F877A
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
INS1	EQU 0x20
INS2	EQU 0x21
OUTALU	EQU 0x22
MYSTATUS EQU 0x23
BB		EQU	0x24
BTITLE	EQU 0x25
PC2		EQU 0x26
PC1		EQU 0x27

	ORG 0x00
	goto	start

	ORG 0x10
start
	bsf	STATUS, RP0	; Bank 1
	movlw 	0x07 
	movwf	ADCON1 ; Set all lower bits of ADCON Special Reg to allow I/O from PORTE
	movlw	0x00	; All bits output
	movwf	TRISA	; 	PORTA = 6 bits- Inputs from ALU
	movwf	TRISB	; 	PORTB = Outputs to ALU - INS2
	movwf	TRISC	;	PORTC = First Half of Instruction 
	movwf 	TRISD	;	PORTD = Second Half of Instruction, then Outputs to ALU - 4 bits - CIN, Mode
	movwf 	TRISE	;	
	bcf	STATUS, RP0	; Bank 0
	
	MOVLW 0x00 ; clear PC
	MOVWF	PC1
	MOVWF	PC2
	
	MOVLW	0x07
	MOVWF	PORTE

LSTART
	bsf		STATUS, RP0
	movlw	0x00
	movwf	TRISA
	bcf		STATUS, RP0

	INCF 	PC2, F
	BTFSC	STATUS, Z;
	INCF	PC1, F

LJMP	
	MOVF	PC1, W
	MOVWF	PORTA
	MOVF	PC2, W
	MOVWF	PORTB
		
	bsf		STATUS, RP0
	movlw	0xff
	movwf	TRISC
	movwf	TRISD
	bcf		STATUS, RP0

	MOVF	PORTD, W; Read instruction 2 from EEPROM - THIS WILL CHANGE to PORTC
	MOVWF	INS2    ; Store instruction 2
	MOVF 	PORTC, W; Read instruction 1 from EEPROM
	MOVWF	INS1    ; Store instruction 1
	
	bsf		STATUS, RP0
	movlw	0xff
	movwf	TRISA
	movlw	0x00
	movwf	TRISC
	movwf	TRISD
	bcf		STATUS, RP0
	
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

L0	nop
	GOTO	LSTART

L1	; ADD
		
	; Grab B title, send it to SRAM
			MOVLW	0x05	; Clear ~OE and Set ~WE
			MOVWF	PORTE

			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	BTITLE		
			SWAPF	BTITLE
			MOVF	BTITLE, W
			MOVWF	PORTC
	;Read B bucket from SRAM and store
			MOVF	PORTA, W	
			MOVWF	BB
			SWAPF	BB
	; Grab C title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			MOVF	BB, W
		XORWF	PORTB, F	; now port B is full with buckets

	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x07     
		MOVWF	PORTD


			MOVLW	0x01
			MOVWF	PORTE
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
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART
	
L2	; SUB
			MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
			MOVWF	PORTE

	; Grab B title, send it to SRAM
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	BTITLE		
			SWAPF	BTITLE
			MOVF	BTITLE, W
			MOVWF	PORTC
	;Read B bucket from SRAM and store
			MOVF	PORTA, W	
			MOVWF	BB
			SWAPF	BB
	; Grab C title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			MOVF	BB, W
		XORWF	PORTB, F	; now port B is full with buckets
	
	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x06     
		MOVWF	PORTD				
	
			MOVLW	0x01
			MOVWF	PORTE

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
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART


L3	; AND
			MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
			MOVWF	PORTE	
	; Grab B title, send it to SRAM
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	BTITLE		
			SWAPF	BTITLE
			MOVF	BTITLE, W
			MOVWF	PORTC

	;Read B bucket from SRAM and store
			MOVF	PORTA, W	
			MOVWF	BB
			SWAPF	BB
	; Grab C title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
			BSF		PORTC, 4
			BCF		PORTC, 5
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			MOVF	BB, W
		XORWF	PORTB, F	; now port B is full with buckets
			
	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x00     
		MOVWF	PORTD
			MOVLW	0x01
			MOVWF	PORTE
	; Clear Z bits of MyStatus Register
	   MOVLW	0xFD
	   ANDWF	MYSTATUS, F
	   BTFSS	PORTA, 6
	   BSF		MYSTATUS, 1
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

L4	; OR
			MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
			MOVWF	PORTE	
	; Grab B title, send it to SRAM
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	BTITLE		
			SWAPF	BTITLE
			MOVF	BTITLE, W
			MOVWF	PORTC

	;Read B bucket from SRAM and store
			MOVF	PORTA, W	
			MOVWF	BB
			SWAPF	BB
	; Grab C title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
			BSF		PORTC, 4
			BCF		PORTC, 5
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			MOVF	BB, W
		XORWF	PORTB, F	; now port B is full with buckets
			
	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x01     
		MOVWF	PORTD
			MOVLW	0x01
			MOVWF	PORTE
	

	; Clear Z bit of MyStatus Register
	   MOVLW	0xFD
	   ANDWF	MYSTATUS, F
	   BTFSS	PORTA, 6
	   BSF		MYSTATUS, 1
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

L5	; XOR
			MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
			MOVWF	PORTE

	; Grab B title, send it to SRAM
			MOVF	INS2, W	
			ANDLW	0xF0
			MOVWF	BTITLE		
			SWAPF	BTITLE
			MOVF	BTITLE, W
			MOVWF	PORTC

	;Read B bucket from SRAM and store
			MOVF	PORTA, W	
			MOVWF	BB
			SWAPF	BB
	; Grab C title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
			BSF		PORTC, 4
			BCF		PORTC, 5
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			MOVF	BB, W
		XORWF	PORTB, F	; now port B is full with buckets
		
	; Set 3 mode bits on port d and send to ALU
		MOVLW	0x02     
		MOVWF	PORTD
			MOVLW	0x01
			MOVWF	PORTE
	; Clear Z bit of MyStatus Register
	   MOVLW	0xFD
	   ANDWF	MYSTATUS, F
	   BTFSS	PORTA, 6
	   BSF		MYSTATUS, 1
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

L6	;Shift Case
		MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
		MOVWF	PORTE
		BTFSC	INS2, 7	
		GOTO	L6R		; Right Shift
; Left Shift	
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read C bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			SWAPF	PORTB	
		MOVLW	0x03
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
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

	L6R
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read "B" bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			SWAPF	PORTB	
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
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

L7 	;Not Case
			MOVLW	0x05	; Clear ~OE and Set ~WE - Ready to read in
			MOVWF	PORTE
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read "B" bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	PORTB
			SWAPF	PORTB	
		MOVLW	0x05
		MOVWF	PORTD
	
			MOVLW	0x01
			MOVWF	PORTE
	; Clear C bit of MyStatus Register
		MOVLW	0xFD
		ANDWF	MYSTATUS, F
		BTFSS	PORTA, 6
		BSF		MYSTATUS, 1
	
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			
			MOVLW	0x00
			MOVWF	PORTE
			nop 		; ALU outputs write to SRAM
			MOVLW	0x07 ; Fill Port E with ones (3 bit port)
			MOVWF	PORTE

	GOTO	LSTART

L8	;Move Case
	BTFSC	INS2, 7
	GOTO	L8b ; This is move FF
	
	; unset TRISCA 
			bsf	STATUS, RP0	; Bank 1
			movlw	0x00
			movwf 	TRISA
			bcf	STATUS, RP0	; Bank 0
			MOVF INS2, W
			ANDLW	0x0F
			MOVWF	PORTA
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			BCF		PORTC, 4
			BCF		PORTC, 5
	
			BSF	STATUS, RP0	; Bank 1
			MOVLW	0xFF
			MOVWF	TRISA
			BCF		STATUS, RP0	; Bank 0

	GOTO LSTART

L8b	;Move Case 1 - MOVE FF
	; Finally, we will be writing to SRAM via Port A (I.e. DRIVING PORT A)
	; Grab "B" title, send it to SRAM
			MOVF	INS2, W
			ANDLW	0x0F
			MOVWF	PORTC
	;Read "B" bucket from SRAM and put in bottom of Port B (to ALU)
			MOVF	PORTA, W	
			MOVWF	BB
	
	; unset TRISCA 
			bsf	STATUS, RP0	; Bank 1
			movlw	0x00
			movwf 	TRISA
			bcf	STATUS, RP0	; Bank 0
			MOVF	BB, W
			MOVWF	PORTA
	; Grab A title, send it to SRAM, while Port A is feeding in the result.
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC
			BCF		PORTC, 4
			BCF		PORTC, 5
	
			BSF	STATUS, RP0	; Bank 1
			MOVLW	0xFF
			MOVWF	TRISA
			BCF		STATUS, RP0	; Bank 0
	GOTO LSTART

L9	;LOD
	GOTO LSTART
L10	;STO
	GOTO LSTART

L11	;TSC/TSS
	MOVLW	0x05
	MOVWF	PORTE
	
	;Find out what bb is
	MOVF	INS2, W
	ANDLW	0x03
	MOVWF	BB

	BTFSC	INS2, 7
	GOTO	L11S ; This is TSS
	; Grab A title, send it to SRAM
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC


	;Read A bucket from SRAM
			BTFSS	PORTA, BB
			GOTO	LPCINC
			GOTO 	LSTART	

L11S
	; Grab A title, send it to SRAM
			MOVF	INS1, W		
			ANDLW	0x0F
			MOVWF	PORTC

	;Read A bucket from SRAM
			BTFSC	PORTA, BB
			GOTO	LPCINC
			GOTO 	LSTART

LPCINC
	INCF 	PC2, F
	BTFSC	STATUS, Z;
	INCF	PC1, F
	GOTO LSTART

L12	;Jump
	BTFSC	INS1, 3
	GOTO	L12b ; This is TSS
	
	MOVF	INS1, W
	ANDLW	0x07
	MOVWF	PC1
	
	MOVF	INS2, W
	MOVWF	PC2
	GOTO 	LJMP

L12b
	; Grab A title, send it to SRAM
	MOVF	INS2, W		
	ANDLW	0x0F
	MOVWF	PORTC

	;Read A bucket from SRAM
	MOVF	PORTA, W
	ANDLW	0x07
	MOVWF	PC1
	nop;

	INCF	INS2
	MOVF	INS2, W		
	ANDLW	0x0F
	MOVWF	PORTC

	;Read A bucket from SRAM
	MOVF	PORTA, W
	MOVWF	PC2	
	SWAPF	PC2
	nop;
	
	INCF	INS2
	MOVF	INS2, W		
	ANDLW	0x0F
	MOVWF	PORTC

	;Read A bucket from SRAM
	MOVF	PORTA, W
	XORWF	PC2, F

	GOTO LJMP
	
END