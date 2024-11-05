stringteste: .db "Hello, world!",0
testenumber: .dw 5589

_start:
	; print message
	LDA #$20
	STA TextPos+1
	LDA #$21
	STA TextPos
	LDA #>stringteste
	STA TextVector+1
	LDA #<stringteste
	STA TextVector
	JSR Print
	; print number
	LDA #$20
	STA 5
	LDA #$41
	STA 4
	LDA testenumber
	STA 0
	LDA testenumber+1
	STA 1
	JSR Bin2Dec
	; print 64*96
	LDA #0
	STA 1
	LDA #64
	STA 0
	LDY #96
	JSR M_TEPPLES
	LDA #$20
	STA 5
	LDA #$61
	STA 4
	JSR Bin2Dec
	; print factorial of 7
	LDA #7
	STA 0
	JSR M_FACTORIAL
	LDA #$20
	STA 5
	LDA #$81
	STA 4
	JSR Bin2Dec