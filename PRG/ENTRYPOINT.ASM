; Fonctions primaires

_nmi_timer = $100
_nmi_busy  = $101

_NMI:
NMI_RTI:
	JSR J_READ1
	LDA 0
	ORA _nmi_timer
	BEQ _nmi_ignore
	DEC _nmi_timer
	BPL _nmi_ignore
	LDA #8
	STA _nmi_timer
	LDA _nmi_busy
	BNE _nmi_ignore
	JSR _check_controller
_nmi_ignore:
	RTI

_IRQ:
	RTI

_start:
	; test beep
	LDA #%01001000
	STA APU_SQUARE1_VOL
	LDA #%01000100
	STA APU_SQUARE1_LO
	LDA #%00000001
	STA APU_MASTER_CTRL
	LDA #%00000000
	STA APU_SQUARE1_HI
	
	; compute primes
	JSR P_FIND ; find all primes (stores them as zeroes in ext ram $6000-$7FFF)
	JSR S_DRAW ; draw sieve representation
	
	JSR Rendu_image
_nmiwait:
	JMP _nmiwait

Rendu_image:
	JSR __VBlank_wait
	LDA #%10010000
	STA PPU_CTRL
	LDA #%00011110
	STA PPU_MASK
	LDA #0
	STA PPU_SCROLL
	LDA #0
	STA PPU_SCROLL
	RTS

_check_controller:
	INC _nmi_busy
	
	LDA 0
	AND #JOYPAD_UP
	BNE _scrollup_10
	
	LDA 0
	AND #JOYPAD_LEFT
	BNE _scrollup_140
	
	LDA 0
	AND #JOYPAD_DOWN
	BNE _scrolldown_10
	
	LDA 0
	AND #JOYPAD_RIGHT
	BNE _scrolldown_140
	
	DEC _nmi_busy
	RTS
_scrollup_10:
	LDA $17
	ORA $18
	BEQ _scroll_ov
	SEC
	LDA $17
	SBC #10
	STA $17
	BCS _scroll_nc
	DEC $18
	JMP _scroll_nc

_scrolldown_10:
	CLC
	LDA $17
	ADC #10
	STA $17
	BCC _scroll_nc
	INC $18
_scroll_nc:
	JSR S_DRAW
_scroll_ov:
	DEC _nmi_busy
	RTS

_scrollup_140:
	LDA $17
	ORA $18
	BEQ _scroll_ov
	SEC
	LDA $17
	SBC #140
	STA $17
	BCS _scroll_nc
	DEC $18
	BPL _scroll_nc
	LDA #0
	STA $17
	STA $18
	JMP _scroll_nc

_scrolldown_140:
	CLC
	LDA $17
	ADC #140
	STA $17
	BCC _scroll_nc
	INC $18
	JMP _scroll_nc