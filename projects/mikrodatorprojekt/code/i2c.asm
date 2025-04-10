#ifndef __i2c_asm
#define __i2c_asm

.equ i2c_STAT_START = $08
.equ i2c_STAT_TX_ADDR_ACK = $18
.equ i2c_STAT_TX_DATA_ACK = $28
.equ i2c_STAT_RX_ADDR_ACK = $40
.equ i2c_STAT_RX_DATA_ACK = $50
.equ i2c_STAT_RX_DATA_NO_ACK = $58

i2c__START:
.org TWIaddr
rjmp int_i2c
.org i2c__START

; initializes the i2c driver. should be ran once during startup
i2c_init:
	; configure the frequency divider to generate a signal
	; that should be 100 kHz assuming a 16 MHz CPU frequency
	; TWBR = 18, TWPS = 1
	ldi r16, 18
	out TWBR, r16
	ldi r16, (0<<TWPS1)|(0<<TWPS0)
	out TWSR, r16

	; has the i2c circuit take control of the pins
	ldi r16, (1<<TWEN)|(1<<TWIE)
	out TWCR, r16
	ret

; waits for the next i2c bus response
i2c_wait:
	in r16, TWCR
	sbrc r16, TWINT
	ret
	rcall psm_enter
	rjmp i2c_wait

; i2c interrupt handler. only disables TWIE but the wake
; allows handling to continue outside the interrupt context
int_i2c:
	in r16, TWCR
	andi r16, 0b01000100
	out TWCR, r16
	reti

; asserts the most recent status code against an expected value
i2c_assert:
	in r17, TWSR
	andi r17, $F8
	cp r16, r17
	brne error
	ret

; starts an i2c transaction
i2c_start:
	ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)|(1<<TWIE)
	out TWCR, r16
	ret

; takes an i2c slave address input in r16 and returns a packet that enters master write mode
i2c_mode_mw:
	lsl r16
	andi r16, 0b1111_1110
	ret

; takes an i2c slave address input in r16 and returns a packet that enters master read mode
i2c_mode_mr:
	lsl r16
	ori r16, 0b0000_0001
	ret

; sends SLA+R/W and data packets within a transaction
i2c_payload_send:
	out TWDR, r16
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	out TWCR, r16
	ret

; accepts a data byte and signals for more
i2c_data_accept:
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)|(1<<TWIE)
	out TWCR, r16
	ret

; accepts a final data byte
i2c_data_accept_final:
	ldi r16, (1<<TWINT)|(1<<TWEN)|(1<<TWIE)
	out TWCR, r16
	ret

; returns the last accepted data byte
i2c_data_get:
	in r16, TWDR
	ret

; end the i2c transaction
i2c_stop:
	ldi r16, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)|(1<<TWIE)
	out TWCR, r16
i2c_stop_wait:
	in r16, TWCR
	sbrc r16, TWSTO
	rjmp i2c_stop_wait
	ret

.include "psm.asm"
.include "error.asm"

#endif
