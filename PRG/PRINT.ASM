; String print

TextVector = $02 ; (2)
TextPos    = $04 ; (2)

Print:
	LDY #0
    LDA TextPos+1
	STA PPU_ADDRESS
    LDA TextPos
	STA PPU_ADDRESS
_writestrloop:
	LDA (TextVector),Y
	BEQ _writestrdone
	STA PPU_DATA
	INY
	BNE _writestrloop
_writestrdone:
	RTS

PrintReverse:
    LDA TextPos+1
	STA PPU_ADDRESS
    LDA TextPos
	STA PPU_ADDRESS
_writestrloop2:
	LDA (TextVector),Y
	BEQ _writestrdone2
	STA PPU_DATA
	DEY
	BNE _writestrloop2
_writestrdone2:
	RTS

; Binary/Decimal

_bin2dec_value   = $00 ; (2)
_bin2dec_mod10   = $02 ; (2)
;TextPos
_bin2dec_spec    = $06 ; special
_bin2dec_charpos = $07
_bin2dec_chars   = $08 ; (6)

Bin2Dec:
	LDX #1
	STX _bin2dec_charpos ; Reset char buffer position
	DEX
	STX _bin2dec_chars   ; First byte must be null: Ascii text is in reverse order
_b2d_divreset:
	; Init remainder val
	LDA #0
	STA _bin2dec_mod10
	STA _bin2dec_mod10+1
	CLC
	
	LDX #16
_b2d_divloop:
	; Rotate quotient and remainder
	ROL _bin2dec_value
	ROL _bin2dec_value+1
	ROL _bin2dec_mod10
	ROL _bin2dec_mod10+1
	
	; A,Y = dividend - divisor
	SEC
	LDA _bin2dec_mod10
	SBC #10
	TAY                  ; Save low byte in Y
	LDA _bin2dec_mod10+1
	SBC #0
	BCC _b2d_ignr        ; Branch if dividend < divisor
	STY _bin2dec_mod10
	STA _bin2dec_mod10+1
_b2d_ignr:
	DEX
	BNE _b2d_divloop
	ROL _bin2dec_value   ; Shift in the last bit of the quotient
	ROL _bin2dec_value+1
	
	LDA _bin2dec_mod10
	CLC
	ADC #"0"
	LDX _bin2dec_charpos
	STA _bin2dec_chars,X
	INX
	STX _bin2dec_charpos
	
	; We will continue dividing if remainder != 0
	LDA _bin2dec_value
	ORA _bin2dec_value+1
	BNE _b2d_divreset    ; Branch to restart process
	
	LDA _bin2dec_spec
	BNE _b2d_end
	
	LDA #<_bin2dec_chars
	STA TextVector
	LDA #0
	STA TextVector+1
	LDY _bin2dec_charpos
	DEY
	JSR PrintReverse
_b2d_end:
	RTS
