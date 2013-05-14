writedata:
	movlw	0xA0
	addwf	OFFSET, W
	bsf	STATUS, RP0	; Bank 1
	movwf	FSR
	bcf	STATUS, RP0	; Bank 0
	movf	DATAWRITE, W
	bsf	STATUS, RP0	; Bank 1
	MOVWF	INDF
	bcf STATUS, RP0
	return

readdata:
	movlw	0xA0
	addwf	OFFSET, W
	bsf	STATUS, RP0	; Bank 1
	movwf	FSR
	MOVF	INDF, W
	bcf	STATUS, RP0	; Bank 0
	return

readins:
	BCF	STATUS, C
	RLF	PC, W;
	BSF STATUS, RP1 ;
	BCF STATUS, RP0 ;Bank 2
	MOVWF EEADR ;to read from
	BSF STATUS, RP0 ;Bank 3
	BCF EECON1, EEPGD ;Point to Data memory
	BSF EECON1, RD ;Start read operation
	BCF STATUS, RP0 ;Bank 2
	MOVF EEDATA, W ;
	BCF	STATUS, RP1
	MOVWF	INS1
	
	BSF STATUS, RP1
	INCF EEADR, F ;to read from
	BSF STATUS, RP0 ;Bank 3
	BCF EECON1, EEPGD ;Point to Data memory
	BSF EECON1, RD ;Start read operation
	BCF STATUS, RP0 ;Bank 2
	MOVF EEDATA, W ;W = EEDATA
	BCF	STATUS, RP1
	MOVWF	INS2
	return