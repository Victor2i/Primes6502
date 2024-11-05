; draws a visual representation of the sieve of eratosthenes

_s_vbar_c      = $0F
_s_at_addr_low = $10
_s_at_addr_hi  = $11
_s_sq_val      = $12
_s_c_low       = $13
_s_c_hi        = $14
_s_sx          = $15
_s_sy          = $16
_s_c_low_start = $17
_s_c_hi_start  = $18
_s_c_first     = $19
_s_s_at        = $20 ; (64)

_s_cg_offset   = 3

S_DRAW:
	LDA #%00010000
	STA PPU_CTRL ; disable NMIs so we have full control on timing
	
	; clear buffer
	LDA #0
	LDY #64
_s_bufferclear:
	STA _s_s_at,Y
	DEY
	BNE _s_bufferclear
	
	; create squares to draw later on the screen
	LDA _s_c_low_start
	ORA #1
	STA _s_c_low
	LDA _s_c_hi_start
	ORA #$60
	STA _s_c_hi
	
	LDX #_s_cg_offset+1
	LDY #1
_s_sqs_loop:
	STX _s_sx        ; save X
	STY _s_sy        ; save Y
_s_chk_prime:
	LDY #0
	LDA (_s_c_low),Y
	BNE _s_chk_even  ; not prime
	LDA #2
	JMP _s_putsquare
_s_chk_even:
	CPX #5+_s_cg_offset
	BEQ _s_even_or_5 ; n is 10k+5
	TXA
	AND #1
	CMP #(_s_cg_offset & 1)
	BNE _s_composite ; n is even
_s_even_or_5:
	LDA #3
	JMP _s_putsquare
_s_composite:
	LDA #1
_s_putsquare:
	LDX _s_sx
	LDY _s_sy
	JSR _s_mapsquare
	TAY                ; save value
	LDA _s_at_addr_low
	SEC
	SBC #$C0
	TAX
	TYA
	ORA _s_s_at,X
	STA _s_s_at,X
	
	JSR _s_inc_counter
	LDX _s_sx
	LDY _s_sy
	INX
	CPX #11+_s_cg_offset
	BCC _s_sqs_loop
	LDX #_s_cg_offset+1
	INY
	CPY #15
	BCC _s_sqs_loop
	
	LDA _s_c_first
	BNE _s_alreadydid
	INC _s_c_first
	
	; draw border lines on the left and on the right to enclose the sieve
	LDA #%00010100 ; vram increment = 32
	STA PPU_CTRL
	
	LDA #$16
	STA _s_vbar_c
	LDY #$40+(_s_cg_offset*2)+1

_s_screenloop:
	LDA #$20
	STA PPU_ADDRESS
	STY PPU_ADDRESS ; set address to $2005 (X:5 Y:0)
	JSR _s_l28      ; draw the line
	INY
	DEC _s_vbar_c
	BNE _s_screenloop
	
	LDA #%00010000 ; vram increment = 1
	STA PPU_CTRL
	
	; show digits on top of the screen
	LDA #$20
	STA PPU_ADDRESS
	LDA #$20+(_s_cg_offset+1)*2
	STA PPU_ADDRESS
	
	LDA #$20
	LDX #9
	LDY #$31
_s_topnumbers:      ; draw digits 1,2,3...0 at the top of the screen
	STA PPU_DATA
	STY PPU_DATA
	INY
	DEX
	BNE _s_topnumbers
	STA PPU_DATA
	LDY #$30
	STY PPU_DATA    ; last digit after 9 will be 0
	
_s_alreadydid:
	; draw numbers on the left representing tens (k*10)
	LDA #1
	STA 6
	
	LDA _s_c_low_start
	STA _s_c_low
	STA 0
	LDA _s_c_hi_start
	STA _s_c_hi
	STA 1
	JSR Bin2Dec
	LDX 7
	LDA #"0"
_s_force_zeroes:
	STA 8,X
	INX
	CPX #5
	BCC _s_force_zeroes
	
	LDA #14
	STA _s_vbar_c
	LDA #$20
	STA _s_at_addr_hi
	LDA #$42
	STA _s_at_addr_low
	
	JSR _s_vblank_wait ; wait till we're in vblank to start writing to PPU
	LDA #0
	STA PPU_MASK
	
_s_tens_loop:
	LDA _s_at_addr_hi
	STA 5
	LDA _s_at_addr_low
	STA 4
	
	LDA #0
	STA 3
	LDA #8
	STA 2
	LSR
	TAY
	JSR PrintReverse
	
	LDY #$30
	INC 10
	LDA 10
	CMP #$3A
	BNE _s_skip_nc
	STY 10
	INC 11
	
	LDA 11
	CMP #$3A
	BNE _s_skip_nc
	STY 11
	INC 12
	
_s_skip_nc:
	CLC
	LDA _s_at_addr_low
	ADC #$40
	STA _s_at_addr_low
	BCC _s_skip_nc2
	INC _s_at_addr_hi
_s_skip_nc2:
	DEC _s_vbar_c
	BNE _s_tens_loop
	LDA #0
	STA 6
	
	JSR _s_enableppu
	JSR _s_vblank_end_wait
	JSR _s_vblank_wait
	
	; transfer the squares we created earlier to the screen
	LDA #$23
	STA PPU_ADDRESS
	LDA #$C0
	STA PPU_ADDRESS
	LDY #$40
	LDX #0
	
_s_transfer_at:
	LDA _s_s_at,X
	STA PPU_DATA
	INX
	DEY
	BNE _s_transfer_at

_s_enableppu:
	LDA #%10010000
	STA PPU_CTRL
	LDA #%00011110
	STA PPU_MASK
	LDA #0
	STA PPU_SCROLL
	LDA #0
	STA PPU_SCROLL
	RTS

_s_l28:
	LDA #2
	LDX #28
_s_l28_loop:
	STA PPU_DATA
	DEX
	BNE _s_l28_loop
	RTS

_s_mapsquare:
	STA _s_sq_val
	TXA
	AND #%00001110
	LSR
	STA _s_at_addr_low
	TYA
	AND #%00001110
	ASL
	ASL
	ORA _s_at_addr_low
	ORA #$C0
	STA _s_at_addr_low
	TYA
	AND #1
	ASL
	STA _s_at_addr_hi
	TXA
	AND #1
	ORA _s_at_addr_hi
	TAX
	LDA #$23
	STA _s_at_addr_hi
	LDA _s_sq_val
_s_bitshifts:
	CPX #0
	BEQ _s_bitshifts_end
_s_bitshifts_loop:
	ASL
	ASL
	DEX
	BNE _s_bitshifts_loop
_s_bitshifts_end:
	RTS

_s_inc_counter:
	INC _s_c_low
	BNE _s_bitshifts_end
	INC _s_c_hi
_s_inc_counter_end:
	RTS

_s_vblank_wait:
	BIT PPU_STATUS
	BPL _s_vblank_wait
	RTS

_s_vblank_end_wait:
	BIT PPU_STATUS
	BMI _s_vblank_end_wait
	RTS