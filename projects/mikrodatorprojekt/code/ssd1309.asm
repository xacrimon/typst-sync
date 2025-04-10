#ifndef __ssd1309_asm
#define __ssd1309_asm

.include "m_util.inc"

INIT_PARAMS: .db $81,$ff,$a4,$20,$00,$a6,$d9,$f1,$af,$2e,$a1,$40,$d3,$00,$d5,$80,$c8,$e3
.equ INIT_PARAMS_LEN = 18

.dseg
VRAM: .byte 768

CACTI_HEAD: .byte 1
CACTI: .byte 128

CACTI_DIFF: .byte 1
CACTI_LAST: .byte 1

POS_Y: .byte 1
VEL_Y: .byte 1


.equ POS_X=31
.equ JMP_VEL=22
.equ EXJMP_VEL=26
.equ GRAVITY=1
.equ DIST_THRES=14

RNG_STATE: .byte 4
.equ RNG_STATE_SZ=4

.cseg
reset_player:
	ldi r16, 0
	sts POS_Y, r16
	sts VEL_y, r16


update_player:
	; ladda v�rden
	ldi r23, 0
	lds r16, POS_Y
	lds r17, VEL_y
	; om p� marken, g�r inget
	cp r16, r23
	cpc r17, r23
	breq update_player_end
	; addera hastighet p� fart, uppdatera hastighet f�r gravitation
	mov r18, r17
	asr r18
	asr r18
	asr r18
	add r16, r18
	subi r17, GRAVITY
	; om ej p� marken, slut
	cpi r16, 128
	brlo update_player_end
	; landat, nollst�ll position och hastighet
	ldi r16, 0
	ldi r17, 0
update_player_end:
	; spara v�rden
	sts POS_Y, r16
	sts VEL_Y, r17
	ret

update_player_input:
	
	lds r16, POS_Y
	cpi r16,0
	brne Jump_disable
	sts POS_Y, R16

	sbic PIND, 0
	rjmp update_player_input_end
	sbis PIND, 1
	jmp big_jump
	ldi r16, JMP_VEL
	jmp store_jump

big_jump:
	ldi r16, EXJMP_VEL

store_jump:
	sts VEL_Y, r16
	jmp update_player_input_end

Jump_disable:
	sts POS_Y, R16

update_player_input_end:
	ret

test_death:
	ldi r16, 0
	lds r19, POS_Y
	lds r17, CACTI_HEAD
	subi r17, -POS_X
	cpi r17, 128
	brlo test_death_2
	subi r17, 127
test_death_2:
	mov ZL, r17
	LEAC Z, CACTI
	ld r18, Z
	cpi r18, 0
	breq test_death_ok
	cpi r19, 8
	brsh test_death_ok
	ldi r16, 1
test_death_ok:
	ret

reset_cacti:
	ldi r16, $FF
	sts CACTI_LAST, r16
	rcall RAND_LCG_INIT
	ldi r16, 8
	sts CACTI_DIFF, r16
	ret

clear_cacti:
	ldi r16, $00
	sts CACTI_HEAD, r16
	LDIW Z, CACTI
	ldi r17, 128
clear_cacti_loop:
	st Z+, r16
	dec r17
	brne clear_cacti_loop
	ret

step_cacti:
	rcall RAND_LCG
	lds r17, CACTI_DIFF
	cp r16, r17
	brsh step_cacti_no
	lds r16, CACTI_LAST
	cpi r16, DIST_THRES
	brlo step_cacti_no
	rjmp step_cacti_yes
step_cacti_yes:
	rcall place_cacti
	rjmp step_cacti_end
step_cacti_no:
	rcall place_no_cacti
	rjmp step_cacti_end
step_cacti_end:
	rcall shift_cacti
	ret

place_cacti:
	ldi r16, 0
	sts CACTI_LAST, r16
	ldi r16, $FF
	lds ZL, CACTI_HEAD
	LEAC Z, CACTI
	st Z, r16
	ret

place_no_cacti:
	lds r16, CACTI_LAST
	inc r16
	sts CACTI_LAST, r16
	ldi r16, $00
	lds ZL, CACTI_HEAD
	LEAC Z, CACTI
	st Z, r16
	ret

shift_cacti:
	lds r16, CACTI_HEAD
	inc r16
	cpi r16, 128
	brne shift_cacti_no_reset
	ldi r16, $00
shift_cacti_no_reset:
	sts CACTI_HEAD, r16
	ret

draw_frame:
	lds r19, CACTI_HEAD
	ldi r18, 128
	sub r18, r19
	mov ZL, r19
	LEAC Z, CACTI
	LDIW X, VRAM+(128*5)
draw_frame_cacti_loop:
	ld r16, Z+
	st X+, r16
	dec r18
	brne draw_frame_cacti_loop
	cpi r19, 0
	breq draw_frame_cube
	mov r18, r19
	LDIW Z, CACTI
draw_frame_cacti_loop_2:
	ld r16, Z+
	st X+, r16
	dec r18
	brne draw_frame_cacti_loop_2
draw_frame_cube:
	lds r16, POS_Y
	cpi r16, 0
	breq draw_frame_cube_1
	brne draw_frame_cube_2
draw_frame_cube_1:
	rcall draw_cube_1
	rjmp draw_frame_end
draw_frame_cube_2:
	rcall draw_cube_2
	rjmp draw_frame_end
draw_frame_end:
	ret

draw_cube_1:
	ldi r16, POS_X
	lds r17, POS_Y
	ldi YL, 5
	sbis PIND, 1
	ldi YL, 3
	ldi r25, 5
in2:
	mov r24, YL
in1:
	push r16
	push r17
	rcall light_pixel
	pop r17
	pop r16
	subi r17, -1
	dec r24
	brne in1
	subi r16, -1
	sub r17, YL
	dec r25
	brne in2
	ret

draw_cube_2:
	ldi r16, POS_X
	lds r17, POS_Y
	ldi r25, 4
in2_2:
	ldi r24, 4
in2_1:
	push r16
	push r17
	rcall light_pixel
	pop r17
	pop r16
	subi r16, -1
	subi r17, -1
	dec r24
	brne in2_1
	;--
	subi r16, 5
	subi r17, 3
	;--
	dec r25
	brne in2_2
	ret

; x/y i r16/r17
light_pixel:
	mov r23, r17
	asr r17
	asr r17
	asr r17
	ldi r18, 5
	sub r18, r17
	LDIW Z, VRAM
light_pixel_loop:
	ldi r19, 128
	add ZL, r19
	ldi r19, 0
	adc ZH, r19
	dec r18
	brne light_pixel_loop
    ;---
	add ZL, r16
	ldi r20, 0
	adc ZH, r20
	;---
	ld r21, Z
	andi r23, 0b0000_0111
	;---
	ldi r22, 0b1000_0000
light_pixel_shift_loop:
	cpi r23, 0
	breq light_pixel_end
	lsr r22
	dec r23
	rjmp light_pixel_shift_loop
light_pixel_end:
	or r21, r22
	st Z, r21
	ret

RNG_SEED: .db 0, 27, 121, 211

RAND_LCG_INIT:
	push r16
	push r17
	PUSHD Z
	PUSHD X

	LDIW Z, 2*RNG_SEED
	LDIW X, RNG_STATE
	ldi r17, RNG_STATE_SZ

RNG_LCG_INIT_loop:
	lpm r16, Z+
	st X+, r16
	dec r17
	brne RNG_LCG_INIT_loop

	POPD X
	POPD Z
	pop r17
	pop r16
	ret

RAND_LCG:
	; save registers
	push r20

	; load rng state from memory
	lds r16, RNG_STATE+0
	lds r17, RNG_STATE+1
	lds r18, RNG_STATE+2
	lds r19, RNG_STATE+3

	; perform bitmixing
	; r16=x, r17=a, r18=b, r19=c, r20=tmp
	inc r16
	eor r17, r19
	eor r17, r16
	add r18, r17
	mov r20, r18
	lsr r20
	eor r20, r17
	add r19, r20

	; save rng state to memory
	sts RNG_STATE+0, r16
	sts RNG_STATE+1, r17
	sts RNG_STATE+2, r18
	sts RNG_STATE+3, r19

	; place return value
	mov r16, r19

	; restore registers
	pop r20
	ret

clear_vram:
	LDIW Z, VRAM
	ldi r20, 12
clear_vram_loop_outer:
	ldi r21, 64
clear_vram_loop_inner:
	; --
	ldi r16, $00
	st Z+, r16
	; --
	dec r21
	brne clear_vram_loop_inner
	dec r20
	brne clear_vram_loop_outer
	; --
	ret

write_frame:
	PUSHD Z

	;set column address
	ldi r16, $21
	call spi_send_inst
	ldi r16, 0
	call spi_send_inst
	ldi r16, 127
	call spi_send_inst

	;set page address
	ldi r16, $22
	call spi_send_inst
	ldi r16, 0
	call spi_send_inst
	ldi r16, 7
	call spi_send_inst

	call wait_2us

	lds r16, FRAMES+1
	sbrc r16, 6
	call write_sky_1
	lds r16, FRAMES+1
	sbrs r16, 6
	call write_sky_2

	LDIW Z, VRAM
	ldi r20, 12
write_frame_loop_outer:
	ldi r21, 64
write_frame_loop_inner:
	; --
	ld r16, Z+
	call spi_send_data
	; --
	dec r21
	brne write_frame_loop_inner
	dec r20
	brne write_frame_loop_outer

	call write_ground
	POPD Z
	ret

write_sky_1:
	ldi r20, 128/4 ; bytecount (128*4)/8
write_sky_1_loop:
	ldi r16, $54
	rcall spi_send_data
	rcall spi_send_data
	ldi r16, $2A
	rcall spi_send_data
	ldi r16, $54
	rcall spi_send_data
	dec r20
	brne write_sky_1_loop
	ret

write_sky_2:
	ldi r20, 128/4 ; bytecount (128*4)/8
write_sky_2_loop:
	ldi r16, $2A
	rcall spi_send_data
	ldi r16, $54
	rcall spi_send_data
	rcall spi_send_data
	rcall spi_send_data
	dec r20
	brne write_sky_2_loop
	ret

write_ground:
	ldi r20, 128 ; bytecount (128*12)/8
	ldi r16, $FF  ; all pixels on
write_ground_loop:
	rcall spi_send_data
	dec r20
	brne write_ground_loop
	ret

spi_send_inst:
	cbi portb,4
	call	SPI_MasterTransmit
	ret

spi_send_data:
	sbi		portb,4
	call	SPI_MasterTransmit
	ret
 
SPI_MasterInit:
	push	r17
	; set (mosi, sck, d/c#, res#)
	ldi		r17, (1<<DDB5)|(1<<DDB7)|(1<<DDB4)|1
	out		DDRB, r17

	; Enable SPI, Master, set clock rate fck/16
	ldi		r17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out		SPCR, r17
	pop		r17
	ret
 
SPI_MasterTransmit:
		; Start transmission of data (r16)
	out		SPDR, r16	;Data Register
		;gaar vidare och kollar att den kan transmitta 
Wait_Transmit:
		; Wait for transmission complete
	in		r22, SPSR ;Status Register
	sbrs	r22, SPIF ;Interrupt Flag
	rjmp	Wait_Transmit
	ret
 
ssd1309_init:
	;reset
	sbi		portb,0
	call	wait_45us
	cbi		portb,0
	call	wait_45us
	sbi		portb,0
 
 
	ldi		zH, HIGH(INIT_PARAMS*2)
	ldi		zL, LOW(INIT_PARAMS*2)
 
	call	wait_45us
	
	sbi		PORTB,4
	cbi		PORTB,4 ; clear d/c#
 
	ldi		r18, INIT_PARAMS_LEN
param_loop:
	call	wait_2us
 
	lpm		r16, z+
	call	SPI_MasterTransmit
 
	dec		r18
	brne	param_loop
	ret

; meant to busyloop for 2us, probably doesn't
wait_2us:
	push	r20
	push	r21
	ldi		r20,$F
wait_loop_2us:
	ldi		r21,$f
wait_inner_loop_2us:
	dec		r21
	brne	wait_inner_loop_2us
	dec		r20
	brne	wait_loop_2us
	pop		r21
	pop		r20
	ret

; meant to busyloop for 45us, probably doesn't
wait_45us:
	push	r20
	push	r21
	ldi		r20,$F
wait_loop_45:
	ldi		r21,$f
wait_inner_loop_45: 
	dec		r21
	brne	wait_inner_loop_45
	dec		r20
	brne	wait_loop_45
	pop		r21
	pop		r20
	ret

#endif
