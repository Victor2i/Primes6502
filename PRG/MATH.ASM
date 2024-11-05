; Extended arithmetic

_m_multiply_value        = $00 ; (2)
_m_multiply_multiplicand = $02 ; (2)
; multiplier is stored in X

M_MULTIPLY:
	CPX #0
	BEQ _m_multiply_zero
	LDA _m_multiply_value+1
	STA _m_multiply_multiplicand+1
	LDA _m_multiply_value
	STA _m_multiply_multiplicand
_m_multiply_loop:
	DEX
	BEQ _m_multiply_end
	LDA _m_multiply_value
	CLC
	ADC _m_multiply_multiplicand
	STA _m_multiply_value
	LDA _m_multiply_value+1
	ADC _m_multiply_multiplicand+1
	STA _m_multiply_value+1
	BCC _m_multiply_loop ; Always branch
_m_multiply_end:
	RTS
_m_multiply_zero:
	STX _m_multiply_value
	STX _m_multiply_value+1
	RTS

_t_prodlo  = $0000
_t_factor2 = $0001

M_TEPPLES:
	; Factor 1 is stored in the lower bits of prodlo
	; The low byte of the product is stored in the upper bits
	LSR ; Prime the carry bit for the loop
	STA _t_prodlo
	STY _t_factor2
	LDA #0
	LDY #8
_m_tepples_loop:
	; One bit of prodlo has already been shifted out into the carry
	BCC _m_tepples_noadd
	CLC
	ADC _t_factor2
_m_tepples_noadd:
	ROR
	ROR _t_prodlo        ; pull another bit out for the next iteration
	DEY                  ; inc/dec don't modify carry; only shifts and adds do
	BNE _m_tepples_loop
	STA 1
	RTS

_m_factorial_number       = $00 ; (2)
_m_factorial_copynumber   = $02 ; (2)

M_FACTORIAL:
	LDA #0
	STA _m_factorial_number+1
	STA _m_factorial_copynumber+1
	LDX _m_factorial_number
	BEQ _m_factorial_zero
	CPX #3
	BCC _m_factorial_end
	STX _m_factorial_copynumber
	DEX
_m_factorial_reset:
	DEX
	TXA
	TAY
_m_factorial_loop:
	CLC
	LDA _m_factorial_number
	ADC _m_factorial_copynumber
	STA _m_factorial_number
	LDA _m_factorial_number+1
	ADC _m_factorial_copynumber+1
	STA _m_factorial_number+1
	DEY
	BNE _m_factorial_loop
	LDA _m_factorial_number
	STA _m_factorial_copynumber
	LDA _m_factorial_number+1
	STA _m_factorial_copynumber+1
	CPX #1
	BNE _m_factorial_reset
_m_factorial_end:
	RTS
_m_factorial_zero:
	INC _m_factorial_number
	RTS