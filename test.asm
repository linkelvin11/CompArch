

LIST	P=PIC16F877A
	include <p16F877A.inc>
	__CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF

OFFSET	EQU	0x50
DATAWRITE	EQU 0x51
DATAREAD	EQU 0x52
INS1		EQU 0x20
INS2		EQU 0x21
PC			EQU 0x22

ORG 0xF0
	#include "subs.asm"
ORG 0x00
	goto	start

ORG 0x10
start
	movlw	0x00
	movwf	PC
loop
	incf	PC, F
	; call writeins
	nop;
	call readins
	nop;
	nop;
	nop;
	
	goto loop
end
	