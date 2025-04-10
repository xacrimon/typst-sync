;
; game.asm
;
; Created: 2025-02-03 15:24:34
; Author : joewe275
;

.include "m_util.inc"

.equ L_ADDR8 = $24

.equ UPDATE_INTERVAL = 70
.equ DISPLAY_INITIAL = 9

.dseg
.org SRAM_START
DISPLAY_UPDATE_CLOCK_COUNTDOWN: .byte 1
DO_DISPLAY_UPDATE: .byte 1
DISPLAY_VALUE: .byte 1
DO_GAME_UPDATE: .byte 1

.cseg  
.org $00
rjmp entrypoint
.org OVF0addr
rjmp int_timer0

.org INT_VECTORS_SIZE
entrypoint:
	; configure the stack
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; initialize hardware and begin the startup process
	rcall hw_init

	rjmp startup_seq

hw_init:
	; start timer/counter0 in normal mode with a clock division of 1024
	ldi r16, (1<<CS02)|(1<<CS00)
	out TCCR0, r16

	; enable timer/counter0 interrupt
	ldi r16, (1<<TOIE0)
	out TIMSK, r16

	; start the i2c driver
	call i2c_init

	call	spi_masterinit
	ret

startup_seq:
	; initialize SRAM variables
	clr r16
	sts DO_DISPLAY_UPDATE, r16
	sts DO_GAME_UPDATE, r16
	ldi r16, UPDATE_INTERVAL
	sts DISPLAY_UPDATE_CLOCK_COUNTDOWN, r16
	ldi r16, DISPLAY_INITIAL
	sts DISPLAY_VALUE, r16

	call reset_cacti
	call clear_cacti
	call reset_player

	call ssd1309_init
	call clear_vram

	ldi r16, 0
	sts FRAMES, r16
	sts FRAMES+1, r16

	; we're done, enable interrupts and initiera LCD // finish
	sei
	call LCD_init
	rjmp cold_main

; executed on counter overflow which occurs every 1/(CPU_F/1024)*256=16.38ms
int_timer0:
	; save will-be clobbered registers
	push r16
	in r16, SREG
	push r16
	; ---
	ldi r16, 1
	sts DO_GAME_UPDATE, r16
	; tick counter and skip if it isn't zero
	lds r16, DISPLAY_UPDATE_CLOCK_COUNTDOWN
	dec r16
	brne int_timer0_store_countdown
	; schedule a display update
	ldi r16, 1
	sts DO_DISPLAY_UPDATE, r16
	; reset counter
	ldi r16, UPDATE_INTERVAL
int_timer0_store_countdown:
	sts DISPLAY_UPDATE_CLOCK_COUNTDOWN, r16
	; restore CPU state
	pop r16
	out SREG, r16
	pop r16
	reti

.dseg
FRAMES: .byte 2
.cseg

cold_main:
	call menu__text
	call nollstall_score
	call reset_player
	call reset_cacti
	call clear_cacti
	call clear_vram
	call write_frame
	

score_main:
	sbic PIND, 0
	jmp score_main
	call clear_display
	call LCD__15ms
	call score_text

main:
	call poangrakning
	call skriv_ut
	lds r16, DO_GAME_UPDATE
	sbrc r16, 0
	rcall game_update

	sbrc r16, 0
	rjmp klar

	; idle until next thing to do
	rcall psm_enter
    rjmp main

klar:
	call LCD__15ms
	call END_Text
	CALL speaker
MAIN_END:
	sbic PIND, 1
	jmp MAIN_END
	jmp cold_main


game_update:
	ldi r16, 0
	sts DO_GAME_UPDATE, r16

	call update_player
	call update_player_input
	call step_cacti
	call clear_vram
	call draw_frame
	call write_frame

	lds ZL, FRAMES+1
	lds ZH, FRAMES
	adiw ZH:ZL, 1
	sts FRAMES+1, ZL
	sts FRAMES, ZH

	call test_death
	ret

display_update:
	; clear queue flag
	clr r16
	sts DO_DISPLAY_UPDATE, r16
	; load and increment value, reset at max
	lds r16, DISPLAY_VALUE
	inc r16
	cpi r16, 10
	brne display_update_no_reset
	clr r16
	; store the value and write it to the screen
display_update_no_reset:
	sts DISPLAY_VALUE, r16
	rcall display_write
	ret

display_write:
	PUSHD Z
	mov ZL, r16

	rcall i2c_start
	rcall i2c_wait
	ldi r16, i2c_STAT_START
	rcall i2c_assert

	ldi r16, L_ADDR8
	rcall i2c_mode_mw
	rcall i2c_payload_send
	rcall i2c_wait
	ldi r16, i2c_STAT_TX_ADDR_ACK
	rcall i2c_assert

	LEAC Z, FONT*2
	lpm r16, Z

	rcall i2c_payload_send
	rcall i2c_wait
	ldi r16, i2c_STAT_TX_DATA_ACK
	rcall i2c_assert

	rcall i2c_stop
	POPD Z
	ret

.equ SEG_A=1<<0
.equ SEG_B=1<<1
.equ SEG_C=1<<2
.equ SEG_D=1<<3
.equ SEG_E=1<<4
.equ SEG_F=1<<5
.equ SEG_G=1<<6

.equ DIGIT_0=(SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F)
.equ DIGIT_1=(SEG_B | SEG_C)
.equ DIGIT_2=(SEG_A | SEG_B | SEG_G | SEG_D | SEG_E)
.equ DIGIT_3=(SEG_A | SEG_B | SEG_G | SEG_C | SEG_D)
.equ DIGIT_4=(SEG_F | SEG_B | SEG_G | SEG_C)
.equ DIGIT_5=(SEG_A | SEG_C | SEG_D | SEG_G | SEG_F)
.equ DIGIT_6=(SEG_C | SEG_D | SEG_E | SEG_F | SEG_G)
.equ DIGIT_7=(SEG_A | SEG_B | SEG_C)
.equ DIGIT_8=(SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F | SEG_G)
.equ DIGIT_9=(SEG_A | SEG_B | SEG_C | SEG_D | SEG_F | SEG_G)

FONT:
	.db DIGIT_0, DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4, DIGIT_5, DIGIT_6, DIGIT_7, DIGIT_8, DIGIT_9

.include "psm.asm"
.include "i2c.asm"
.include "ssd1309.asm"
.include "functions.inc"
.include "LCD.inc"


