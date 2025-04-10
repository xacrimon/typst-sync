#ifndef __psm_asm
#define __psm_asm

; enters idle mode until woken by an interrupt
psm_enter:
	ldi r16, (1<<SE)
	out MCUCR, r16
	sleep
	clr r16
	out MCUCR, r16
	ret

#endif
