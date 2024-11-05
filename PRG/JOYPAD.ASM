; reads joypad

_j_buttons = $00 ; (2)

J_READ1: ; read 1 controller
	LDA #1
	STA JOYPAD_PORT   ; strobe joypad to capture button state
	STA _j_buttons    ; store LSB that will later be shifted into carry
	LSR               ; A = 0
	STA JOYPAD_PORT   ; stops reloading
_j_read1_loop:
	LDA JOYPAD_PORT
	LSR               ; store bit in carry
	ROL _j_buttons    ; carry goes into LSB
	BCC _j_read1_loop ; once MSB is shifted into carry we've read the controller
	RTS

J_READ2: ; read both controllers
	LDX #0
	JSR _j_readx      ; first perform the read with X = 0 (cont 1) to return here later
	INX               ; then fall into the same routine with X = 1 (cont 2)
_j_readx:
	LDA #1
	STA JOYPAD_PORT   ; strobe joypad to capture button state
	STA _j_buttons,X  ; store LSB that will later be shifted into carry
	LSR               ; A = 0
	STA JOYPAD_PORT   ; stops reloading
_j_readx_loop:
	LDA JOYPAD_PORT,X
	AND #%00000011    ; ignore uninteresting bits
	CMP #1            ; set carry if nonzero
	ROL _j_buttons,X  ; carry goes into LSB
	BCC _j_readx_loop ; once MSB is shifted into carry we've read the controller
	RTS