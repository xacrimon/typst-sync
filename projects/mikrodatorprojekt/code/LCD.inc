/** LCD
 * LCD_init() - make sure to call TWI__init first
 * LCD_write_char(r16=ascii)
 */

	.equ LCD__DISPLAYADDR = $20 ; TWI 7-bit addr
	.equ LCD__RS = 0
	.equ LCD__RW = 1
	.equ LCD__E = 2
	.equ LCD__BL = 3
	.equ LCD__Data = 4
	// LCD__data = 4..7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD_init()
LCD_init:
	
	// 15 ms already done. I promise
	// RS=0, RW=0, DB7..4=0011. Wait 4.1 ms
	// RS=0, RW=0, DB7..4=0011. Wait 100us
	// RS=0, RW=0, DB7..4=0011
	// RS=0, RW=0, DB7..4=0010 + 37 us
	// ctrl=0x2C // [0 0 1 DL N F * *] Function set. 37us
	// ctrl=0x0F // [0000 1 D C B] Display on/off control. 37 us
	// ctrl=0x01 // Clear display. Time???
	// ctrl=0x06 // [0 1 I/D S]  Entry mode set. 37 us
	call	LCD__15ms
	ldi	r16, (0x3 << LCD__Data) | (0 << LCD__RS)
	call	LCD__send_byte
	
	call	LCD__15ms

	ldi	r16, (0x3 << LCD__Data) | (0 << LCD__RS)
	call	LCD__send_byte
	

	ldi	r16, (0x3 << LCD__Data) | (0 << LCD__RS)
	call	LCD__send_byte
	

	ldi	r16, (0x2 << LCD__Data) | (0 << LCD__RS)
	call	LCD__send_byte
	
	ldi	r16, 0x2C
	call	LCD__send_ctrl

	ldi	r16, 0x0C
	call	LCD__send_ctrl

	ldi	r16, 0x01
	call	LCD__send_ctrl 

	
	ldi	r16, 0x06
	call	LCD__send_ctrl
	call	LCD__15ms
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD_write_char(r16=ascii)
LCD_write_char:
	call	LCD__send_char
	ret

////////////////////////////////////////////////////// PRIVATES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD__send_char(r16=ascii)
LCD__send_char:
	push	r16
	// Most Significant Nibble:
	andi	r16, 0xf0 ; isolate MSNibble
	ori		r16, (1<<LCD__RS) | (1<<LCD__BL)
	call	LCD__send_byte
	pop	r16
	// LeastSignificantNibble:
	swap	r16
	andi	r16, 0xf0 ; isolate MSNibble
	ori		r16, (1<<LCD__RS) | (1<<LCD__BL)
	call	LCD__send_byte
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD__send_ctrl(r16=instr)
LCD__send_ctrl:
	push	r16
	// Most Significant Nibble:
	andi	r16, 0xf0 ; isolate MSNibble
	ori		r16, (1<<LCD__BL)
	call	LCD__send_byte
	pop	r16
	// LeastSignificantNibble:
	swap	r16
	andi	r16, 0xf0 ; isolate MSNibble
	ori		r16, (1<<LCD__BL)
	call	LCD__send_byte
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD__send_byte(r16=ctrl+nibble)
LCD__send_byte:
	push r17
	push r16
	rcall i2c_start
	rcall i2c_wait
	ldi r16, i2c_STAT_START
	//rcall i2c_assert

	ldi	r16, LCD__DISPLAYADDR
	rcall i2c_mode_mw
	rcall i2c_payload_send
	rcall i2c_wait
	ldi r16, i2c_STAT_TX_ADDR_ACK
	//rcall i2c_assert
	
	pop r16
	push r16
	
	ori	r16, (1<<LCD__E)
	rcall i2c_payload_send
	rcall i2c_wait
	ldi r16, i2c_STAT_TX_DATA_ACK
	//rcall i2c_assert

	pop r16
	
	rcall i2c_payload_send
	rcall i2c_wait
	ldi r16, i2c_STAT_TX_DATA_ACK
	//rcall i2c_assert

	rcall i2c_stop
	pop r17
	ret

	/*push	r16
	ldi	r16, LCD__DISPLAYADDR*2+0 // 7->8 bit + write
	call	TWI_OPEN
	pop	r16
	push	r16
	ori	r16, (1<<LCD__E)
	call	TWI_81 // with E
	pop	r16
	call	TWI_81 // without E
	call	TWI_CLOSE*/
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD__1ms()
LCD__1ms:
	.set LOOP_COUNT = 16000*1/4 ; (16k cc/ms) * (15 ms) / (4 cc/rotation)
	push	r25
	push	r24
	ldi	r24, LOW(LOOP_COUNT)
	ldi	r25, HIGH(LOOP_COUNT)
LCD__1ms__loop:
	sbiw r25:r24, 1 ; sub imm from word. 2 cc
	brne	LCD__1ms__loop ; 2 cc
	pop	r24
	pop	r25
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;; LCD__15ms()
LCD__15ms:
	.set LOOP_COUNT = 16000*15/4 ; (16k cc/ms) * (15 ms) / (4 cc/rotation)
	push	r25
	push	r24
	ldi	r24, LOW(LOOP_COUNT)
	ldi	r25, HIGH(LOOP_COUNT)
LCD__15ms__loop:
	sbiw r25:r24, 1 ; sub imm from word. 2 cc
	brne	LCD__15ms__loop ; 2 cc
	pop	r24
	pop	r25
	ret


