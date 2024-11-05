; Initialisation

_ramclear = $00 ; (2)

_reset:
	SEI
	CLD
	LDX #$FF
	TXS
	INX
	STX PPU_CTRL
	STX PPU_MASK
	LDA #%00110000
	STA APU_SQUARE1_VOL
	STA APU_SQUARE2_VOL
	STA APU_NOISE_VOL
	LDA #%00001000
	STA APU_SQUARE1_SWEEP
	STA APU_SQUARE2_SWEEP
	LDA #%10000000
	STA APU_TRIANGLE_CTRL
	STA APU_FRAME_COUNTER
	JSR __VBlank_wait
_Charger_palettes:
	LDA #$3F        ; Hi-byte
	STA PPU_ADDRESS
	LDA #$00        ; Lo-byte
	STA PPU_ADDRESS
_Charger_palettes_loop:
	LDA Palettes,X
	INX
	STA PPU_DATA
	CPX #$20
	BNE _Charger_palettes_loop
	
	LDX #8
	LDY #0
_Nettoie_RAM:              ; On nettoie la RAM de la console
	TYA ; A = 0
	STA _ramclear
	STA _ramclear+1
_Nettoie_RAM_loop:
	STA (_ramclear),Y
	INY
	BNE _Nettoie_RAM_loop
	INC _ramclear+1
	DEX
	BNE _Nettoie_RAM_loop
_Nettoie_ecran:
	LDA #$20
	STA PPU_ADDRESS
	LDA #$00
	STA PPU_ADDRESS
	LDX #$10
_Nettoie_ecran_loop:
	STA PPU_DATA
	INY
	BNE _Nettoie_ecran_loop
	DEX
	BNE _Nettoie_ecran_loop
__VBLANKWAIT2:
	JSR __VBlank_wait
	JMP _start

__VBlank_wait:
	BIT PPU_STATUS
	BPL __VBlank_wait
	LDX #$00
	LDA #$00
	RTS

Palettes:
	.incbin "CHR/DEFAULT.PAL"