; marks composite numbers and leaves unmarked numbers as zeroes

P_FIND:
	LDX #1 ; prime n
	LDY #2 ; increment
	LDA #4 ; first composite address low byte
	STA $0E
	LDA #$60
	STA $0F
	JSR SetComposites
	
	LDX #2
	LDY #6
	LDA #9
	STA $0E
	LDA #$60
	STA $0F
	JSR SetComposites
	
	LDX #3
	LDY #10
	LDA #25
	STA $0E
	LDA #$60
	STA $0F
	JSR SetComposites
	
	LDX #4
	LDY #14
	LDA #49
	STA $0E
	LDA #$60
	STA $0F
	JSR SetComposites
	
	LDX #5
	STX $10
	LDY #1
	
	JMP SetComposites121
	
SetComposites:
	CLC
_setcompositesloop:
	TXA
	LDX #0
	STA ($0E,X)
	TAX
	TYA
	ADC $0E
	STA $0E
	BCC _setcompositesloop ; skip the branch if address upper byte must be incremented
	CLC
	INC $0F
	BPL _setcompositesloop ; upper byte is signed so overflowing into negatives ends this routine (we reached $7FFF)
	RTS
	
FindPrimeX:
	INY
	LDA $6000,Y
	BNE FindPrimeX
	DEX
	BNE FindPrimeX
	RTS
	
SetComposites121: ; find upper primes past 7
	JSR FindPrimeX
	CPY #90
	BCS SetCompositesEnd
	
	TYA
	ASL
	STA $11       ; save double
	
	TYA
	JSR M_TEPPLES ; compute square
	
	CLC
	ADC #$60
	STA $0F
	LDA 0
	STA $0E       ; start address = $6000 + p*p
	
	LDY $11
	LDA $10
	TAX
	JSR SetComposites
	INC $10
	LDX $10
	LDY #1
	BPL SetComposites121
SetCompositesEnd:
	LDA #$FF
	STA $6000
	STA $6001
	RTS