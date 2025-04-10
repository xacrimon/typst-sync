
.dseg 
TIME: .byte 4
.cseg

.equ T=20
.equ F=40

/////////////////////////////////////////////////////////////////////////////meny text
menu__text:
	call clear_display
	call LCD__15ms
	PUSH ZL
    push ZH
	push r17

	ldi ZH,HIGH(MENU_tabell_rad1*2)
    ldi ZL,LOW(MENU_tabell_rad1*2)
	ldi r17, 14
	call send_text

	push r16
	ldi r16,$C0				// HOPPAR RAD 2
	call LCD__send_ctrl
	pop r16

	ldi ZH,HIGH(MENU_tabell_rad2*2)
    ldi ZL,LOW(MENU_tabell_rad2*2)
	ldi r17, 16
	call send_text

	pop r17
	Pop ZH
	POP ZL

	ret
	
 MENU_tabell_rad1:
	.db ' ',' ','!','S','T','A','R','T',' ','G','A','M','E','!'

MENU_tabell_rad2:
	.db 'P','R','E','S','S',' ','R',' ','T','O',' ','B','E','G','I','N'


	/////////////////////////////////////////////////////////////////////////////////score text
score_text:
	PUSH ZL
    push ZH
	push r17

	ldi ZH,HIGH(SCORE_tabell*2)
    ldi ZL,LOW(SCORE_tabell*2)
	ldi r17, 6
	call send_text

	pop r17
	Pop ZH
	POP ZL
	ret
 SCORE_tabell:
	 .db 'S','C','O','R','E',':'

 ////////////////////////////////////////////////////////////////////// clear lcd dislapy skriver ut score plus end text
 
    END_Text:
	call clear_display
	call LCD__15ms
	PUSH ZL
    push ZH
	push r17
	ldi ZH,HIGH(END_tabell*2)
    ldi ZL,LOW(END_tabell*2)
	ldi r17, 11
	call send_text
	call LCD__15ms
	CALL skriv_ut

	push r16
	ldi r16,$C0				// HOPPAR RAD 2
	call LCD__send_ctrl
	pop r16

	ldi ZH,HIGH(END_tabell_rad2*2)
    ldi ZL,LOW(END_tabell_rad2*2)
	ldi r17, 16
	call send_text
	pop r17
	Pop ZH
	POP ZL
	ret

 END_tabell:
	.db 'Y','O','U','R',' ','S','C','O','R','E',':'

	
 END_tabell_rad2:
	 .db 'T','O',' ','M','E','N','U',' ','P','R','E','S','S',' ','L', '!'


	 ////////////////////////////////////////////////////////////////////////////send tabell text i Z-pekare, l�ngden i r17 kommer in i r17

send_text:
	push r16
send_text_loop:
	lpm r16, Z+
	call LCD_write_char
	dec r17
	brne send_text_loop
	pop r16
	ret
	////////////////////////////////////////////////////////////////////////////////st�nger av curser shift
curser_shift_off:
	ldi r16, $10
	call LCD__send_ctrl
	ret    
	////////////////////////////////////////////////////////////////////clear display fr�n text
clear_display:
	ldi	r16, 1
	call  LCD__send_ctrl
	ret
	//////////////////////////////////////////////////////////////////////nollst�ller score po�ng
nollstall_score:
	ldi r16, 0x00
    sts TIME, r16
    sts TIME+1, r16
    sts TIME+2, r16
    sts TIME+3, r16
	sts TIME+4, r16
	sts TIME+5, r16
	ret
	//////////////////////////////////////////////////////////////////////////g�r uppr�kning av score 1-9999
poangrakning:
   push r17
   push ZH
   PUSH ZL
   PUSH XL
   push XH

   ldi ZH,HIGH(max_val*2)
   ldi ZL,LOW(max_val*2)
   ldi XH,HIGH(TIME)
   ldi XL,LOW(TIME)
   call poangrakning_loop

   pOP XH
   POP XL
   pOP ZL
   POP ZH
   pop r17
   ret
max_val:
  .db  10, 10, 10, 10

Sjutab:
  .db '0','1','2','3','4','5','6','7','8','9'
 
poangrakning_loop:
    LPM r17,Z+
    ld r16, X
	inc r16
    cp r16, R17
    brne poangstore 
	clr r16
	st X+, r16
	RJMP poangrakning_loop

poangstore:
    st x, r16
 	ret

	////////////////////////////////////////////////////////////////////////skriver ut score p� sk�rmen p� de fyra positioner l�ngst till h�ger
skriv_ut:
     ldi r17,1
	 ldi r16, $8F
	 ldi XH,HIGH(TIME)
	 ldi XL,LOW(TIME) ;ladda X = TIME.
	 ;ld r24, X+
	 adiw XH:XL, 1
	 adiw XH:XL, 1

skriv_position_loop:
	 push r16
	 call LCD__send_ctrl
	 pop r16
	 call utskrift
	 dec r16
	 cpi r16, $8B
	 breq skriv_ut_klar
	 jmp skriv_position_loop

skriv_ut_klar:
	ret

utskrift:
	push r16
	ld r16,X
	ldi ZH,HIGH(SJUTAB*2)  
	ldi ZL,LOW(SJUTAB*2)
	add ZL,r16 
	clr r16 
	adc ZH,r16 
	lpm r16,Z
	call LCD_write_char
	add XL,r17
	pop r16
	ret


speaker:
	
	
	in r22, DDRB
	ori r22, (1<<PINB1)
	out DDRB, R22
	
	push r16
	ldi r16, T
	call beep
	ldi r19, T
	CALL NOBEEP
	ldi r16, T
	call beep
	ldi r19, T
	call NOBEEP
	ldi r16, T
	call beep
	ldi r19, T
	call NOBEEP
	ldi r16, T
	call beep
	ldi r19, T
	call NOBEEP
	pop r16
	ret
	
beep:
	sbi PORTB,1
	CALL beepDELAY
	cbi PORTB,1
	CALL beepDELAY
	dec r16
	brne beep
	RET

NOBEEP:
	call beepDELAY
	call beepDELAY
	dec r19
	brne NOBEEP
	RET


beepDELAY: 
	ldi r21, F
beepDELAYYTTRELOOP: 
	ldi  r22, $1F
beepDELAYINRELOOP: 
	dec r22
	brne beepDELAYINRELOOP
	dec r21
	brne beepDELAYYTTRELOOP
	RET

