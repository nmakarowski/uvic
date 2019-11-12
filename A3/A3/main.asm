;	ASSIGNMENT 3 - CSC 230
;	main.asm

;	NAME: Nicole Makarowski
;	ID: V00891873
;	
;
;
; 
;---------------------------------------------------------------------------------------------------------------------------------
;			INITIALIZATIONS
;.cseg 
.org 0x0000
	jmp setup
.org 0x0028
	jmp timer1_ISR

;------------------------------------------------------------------
;TESTING
;ldi i, 9
;ldi j, 6
;ldi button_val, 4

;---------------------------------------------------------------------------------------------------------------------------
;		
;									START OF FUNCTION



main_loop:

	call delay
	call check_button  ;button_val set based on button pressed  
	
	call display_strings_main

	call int_to_string
	ldi r16, 0x00
	push r16
	ldi r16, 0x02
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(num)
	push r16
	ldi r16, low(num)
	push r16
	call lcd_puts
	pop r16 
	pop r16

	call int_to_string
	ldi r16, 0x00
	push r16
	ldi r16, 0x0A
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(speed)
	push r16
	ldi r16, low(speed)
	push r16
	call lcd_puts
	pop r16 
	pop r16

	cpi  button_val, 0         
	breq main_loop

	cpi button_val, 1
	breq go_right

	cpi button_val, 2
	breq go_up

	cpi button_val, 3
	breq go_down

	cpi button_val, 4
	breq go_left

	cpi button_val, 5
	breq go_select


	rjmp main_loop      

go_right:
	ldi r19, 0b00100000
	sts PORTL, r19
	ldi r19, 0x00
	out PORTB, r19	
	
	cpi cursor_x, 10
	ldi r17, 2

	breq move_cursor
	cpi cursor_x, 4
	ldi r17, 10
	breq move_cursor
	
	
	inc cursor_x
	rjmp main_loop	
go_up:
	ldi r19, 0b00001000
	sts PORTL, r19
	ldi r19, 0x00
	out PORTB, r19
	
	cpi cursor_x, 2
	ldi r17, 100
	breq up_n
	cpi cursor_x, 3
	ldi r17, 10
	breq up_n
	cpi cursor_x,4
	ldi r17, 1
	breq up_n
	
	cpi cursor_x,10
	ldi r17, 1
	breq up_spd
			
	rjmp main_loop
go_down:
	ldi r19, 0b00000010
	sts PORTL, r19
	ldi r19, 0x00
	out PORTB, r19
	
	cpi cursor_x, 2
	ldi r17, 100
	breq down_n
	cpi cursor_x, 3
	ldi r17, 10
	breq down_n
	cpi cursor_x,4
	ldi r17, 1
	breq down_n

	cpi cursor_x,10
	ldi r17, 1
	breq down_spd

	rjmp main_loop

go_left:
	ldi r19, 0b00000000
	sts PORTL, r19
	ldi r19, 0b00001000
	out PORTB, r19

	cpi cursor_x, 10
	ldi r17, 4

	breq move_cursor
	cpi cursor_x, 2
	ldi r17, 10
	breq move_cursor

	dec cursor_x
	rjmp main_loop
go_select:
	ldi r19, 0b00000000
	sts PORTL, r19
	ldi r19, 0b00000010
	out PORTB, r19
	rjmp main_loop		


move_cursor:
	mov cursor_x, r17
	rjmp main_loop
up_n:
	add n, r17
	rjmp main_loop
down_n:
	sub n, r17
	rjmp main_loop
up_spd:
	add spd, r17
	rjmp main_loop
down_spd:
	sub spd, r17
	rjmp main_loop
;------------------------------------------------
;				S E T U P

setup:
	.def spd = r15
	.def val = r20
	.def count = r21
	.def cursor_x = r22
	.def cursor_y = r23
	.def button_val = r24
	.def n = r25
	
	
	;initialize stack pointer
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

	;initialize PORTL and PORTB
	ldi	r16, 0b10101010
	sts DDRL, r16
	out DDRB, r16

	; initialize the Analog to Digital converter
	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16

	

	; initialize the LCD
	call lcd_init			
	
	; clear the screen
	call lcd_clr
	call lcd_init
	call init_strings
	call display_strings_intro
	call delay_1sec

	

	;START AT [0,0] = 1
	;sets LED to 0b000001
	ldi r19, 0b00000000
	sts PORTL, r19
	ldi r19, 0b00000000
	out PORTB, r19

	call timer1_setup

	ldi button_val, 0 
	ldi cursor_x, 4
	ldi cursor_y, 0
	ldi n, 0
	ldi r19, 1
	mov spd, r19

	jmp main_loop

;----------------------------------
;TIMER DELAY VALUES
.equ speed0 = 0		 	;STOP

;clock /64
.equ speed1 = 15625		;1/16 sec
.equ speed2 = 31250		;1/8  sec

;clock /256
.equ speed3 = 15625		;1/4  sec
.equ speed4 = 31250		;1/2  sec

;clock /1024
.equ speed5 = 15625		;1.0  sec
.equ speed6 = 23438		;1.5  sec
.equ speed7 = 31250		;2.0  sec
.equ speed8 = 39063		;2.5  sec
.equ speed9 = 46875		;3.0  sec

;----------------------------------------------------------------------
;set up timer -- currently set for 1 sec delay
;need to create variable speeds???
;from lab 8 :)
.equ TIMER1_DELAY = 15625;total timer ticks on AVR timer site - - sets 1 sec delay
.equ TIMER1_MAX_COUNT = 0xFFFF
.equ TIMER1_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER1_DELAY
timer1_setup:	
	push r16
	; timer mode	
	ldi r16, 0x00		; normal operation
	sts TCCR1A, r16

	; prescale 
	; Our clock is 16 MHz, which is 16,000,000 per second
	;
	; scale values are the last 3 bits of TCCR1B:
	;
	; 000 - timer disabled
	; 001 - clock (no scaling)
	; 010 - clock / 8
	; 011 - clock / 64
	; 100 - clock / 256
	; 101 - clock / 1024
	; 110 - external pin Tx falling edge
	; 111 - external pin Tx rising edge
	ldi r16, (1<<CS12)|(1<<CS10)	; clock / 1024
	sts TCCR1B, r16

	; set timer counter to TIMER1_COUNTER_INIT (defined above)
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	
	; allow timer to interrupt the CPU when it's counter overflows
	ldi r16, 1<<TOIE1
	sts TIMSK1, r16
	pop r16
	; enable interrupts (the I bit in SREG)
	sei	

	ret
;-------------------------------------------------------------------------------------------
timer1_ISR:
	push r16
	push r17
	push r18
	lds r16, SREG
	push r16

	; RESET timer counter to TIMER1_COUNTER_INIT (defined above)
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte

	;------------
	;toggling LEDs for testing
	ldi r18, 0b00001010
	in r17, PORTB
	eor r18, r17
	out PORTB, r18

	ldi r18, 0b10101010
	lds r17, PORTL
	eor r18, r17
	sts PORTL, r18


	call flash_cursor


	pop r16
	sts SREG, r16
	pop r18
	pop r17
	pop r16
	reti

;--------------------------------------------------------------------
cursor_ISR:
	push r16
	push r17
	push r18
	lds r16, SREG
	push r16

	; RESET timer counter to TIMER1_COUNTER_INIT (defined above)
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte

	call flash_cursor


	pop r16
	sts SREG, r16
	pop r18
	pop r17
	pop r16
	reti 
;-------------------------------------------------------------------------------------------
;init_strings stolen from lab 7
init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(line1)		; address of the destination string in data memory
	push r16
	ldi r16, low(line1)
	push r16
	ldi r16, high(line1_p << 1) ; address the source string in program memory
	push r16
	ldi r16, low(line1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	ldi r16, high(line2_p << 1)
	push r16
	ldi r16, low(line2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	ldi r16, high(cursor)
	push r16
	ldi r16, low(cursor)
	push r16
	ldi r16, high(cursor_p << 1)
	push r16
	ldi r16, low(cursor_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	ldi r16, high(disp1)
	push r16
	ldi r16, low(disp1)
	push r16
	ldi r16, high(disp1_p << 1)
	push r16
	ldi r16, low(disp1_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	ldi r16, high(disp2)
	push r16
	ldi r16, low(disp2)
	push r16
	ldi r16, high(disp2_p << 1)
	push r16
	ldi r16, low(disp2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret


;----------------------------------------------------
;set cursor
;push x then y of cursor position
;how to reset the character that cursor is over??
flash_cursor:
	push r16
	;call lcd_clr
	mov r16, cursor_y
	push r16
	mov r16, cursor_x
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	
	ldi r16, high(cursor)
	push r16
	ldi r16, low(cursor)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	pop r16
	call delay
	ret

;----------------------------------------------------
display_strings_intro:
	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret
;----------------------------------------------------
display_strings_main:
	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(disp1)
	push r16
	ldi r16, low(disp1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(disp2)
	push r16
	ldi r16, low(disp2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret




int_to_string:
	.def dividend=r0
	.def divisor=r1
	.def quotient=r2
	.def tempt=r17
	.def char0=r3
	;preserve the values of the registers
	push dividend
	push divisor
	push quotient
	push tempt
	push char0
	push ZH
	push ZL
	push YH
	push YL

	;store '0' in char0
	ldi tempt, '0'
	mov char0, tempt
	;Z points to first character of num in SRAM
	push r16
	ldi r16, high(num)
	push r16
	ldi r16, low(num)
	push r16
	ldi r16, high(num_p << 1)
	push r16
	ldi r16, low(num_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	
	pop r16

	ldi ZH, high(num)
	ldi ZL, low(num)
	ldi YH, high(speed)
	ldi YL, low(speed)

	adiw ZH:ZL, 3 ;Z points to null character
	adiw YH:YL, 1
	mov tempt, spd
	add tempt, char0
	st Y, tempt
	clr tempt 
	st Z, tempt ;set the last character to null
	sbiw ZH:ZL, 1 ;Z points the last digit location
	
	;initialize values for dividend, divisor
	mov tempt, n
	mov dividend, tempt
	ldi tempt, 10
	mov divisor, tempt
	
	clr quotient
	digit2str:
		cp dividend, divisor
		brlo finish
		division:
			inc quotient
			sub dividend, divisor
			cp dividend, divisor
			brsh division
		;change unsigned integer to character integer
		add dividend, char0
		st Z, dividend;store digits in reverse order
		sbiw r31:r30, 1 ;Z points to previous digit
		mov dividend, quotient
		clr quotient
		jmp digit2str
	finish:
	add dividend, char0
	st Z, dividend ;store the most significant digit

	;restore the values of the registers
	pop YL
	pop YH
	pop ZL
	pop ZH
	pop char0
	pop tempt
	pop quotient
	pop divisor
	pop dividend
	ret
	.undef dividend
	.undef divisor
	.undef quotient
	.undef tempt
	.undef char0



;-------------------------------------------------------------------------------------------
;check_button
;from lab
;uses registers:
;r16
;r17
;r18
;r19
;modifies r24, button_val
;	0 - NO BUTTON
;	1 - RIGHT
;	2 - UP
;	3 - DOWN
;	4 - LEFT
;	5 - SELECT

check_button:
	push r19
	push r18
	push r17
	push r16
	; start a2d conversion
	lds	r16, ADCSRA	  ; get the current value of SDRA
	ori r16, 0x40     ; set the ADSC bit to 1 to initiate conversion
	sts	ADCSRA, r16

	; wait for A2D conversion to complete
wait:
	lds r16, ADCSRA
	andi r16, 0x40     ; see if conversion is over by checking ADSC bit
	brne wait          ; ADSC will be reset to 0 is finished

	; read the value available as 10 bits in ADCH:ADCL
	lds r16, ADCL
	lds r17, ADCH

	ldi r18, low(0x3E8)
	ldi r19, high(0x3E8)
	cp r16, r18
	cpc r17, r19
	brge noButton

	ldi r18, low(RIGHT)
	ldi r19, high(RIGHT)
	cp r16, r18
	cpc r17, r19
	brlo rght

	ldi r18, low(UP)
	ldi r19, high(UP)
	cp r16, r18
	cpc r17, r19
	brlo up_button

	ldi r18, low(DOWN)
	ldi r19, high(DOWN)
	cp r16, r18
	cpc r17, r19
	brlo dwn

	ldi r18, low(LEFT)
	ldi r19, high(LEFT)
	cp r16, r18
	cpc r17, r19
	brlo lft

	ldi r18, low(SELECT)
	ldi r19, high(SELECT)
	cp r16, r18
	cpc r17, r19
	brlo slct 

	rjmp error


noButton:
	ldi r24, 0
	rjmp end_check_button

rght:
	ldi r24,1
	rjmp end_check_button

up_button:
	ldi r24, 2
	rjmp end_check_button

dwn:
	ldi r24, 3
	rjmp end_check_button

lft:
	ldi r24, 4
	rjmp end_check_button

slct:
	ldi r24, 5
	rjmp end_check_button
	

end_check_button:
	pop r16
	pop r17
	pop r18
	pop r19	
	ret

;---------------------------------------------------------------------------
; delay loops
;
; this function uses registers:
;
;	r19
;	r18
;	r17
;
delay:;for button
	push r19
	push r18
	push r17
	ldi r17, 0x0D

	x1:	ldi r18, 0xFF

		x2: ldi r19, 0xFF

			x3: 

				dec r19
				brne x3

			dec r18
			brne x2

		dec r17
		brne x1


	pop r17
	pop r18
	pop r19
	ret

delay_1sec:
	push r19
	push r18
	push r17
	ldi r17, 82
	ldi r18, 43
	ldi r19, 0
	l1:
		dec r19
		brne l1
		dec r18
		brne l1
		dec r17
		brne l1
		nop
	
	pop r19
	pop r18
	pop r17
ret


error:
	ldi r24,0
	jmp main_loop

;-----------------------------------------------------------------------------------------------------------------------------------
;					DATA AND CONSTANTS

 ;values for LCD Shield buttons
.equ RIGHT	= 0x032
.equ UP	    = 0x0C3
.equ DOWN	= 0x17C
.equ LEFT	= 0x22B
.equ SELECT	= 0x316

.equ MAX_X = 0x0F
.equ MAX_Y = 0x01
.equ MAX_digit = 9


line1_p: .db "  N Makarowski ", 0
line2_p: .db "CSC 230-Fall '19 ", 0

disp1_p: .db "n=    SPD: ", 0;cursor for n[2,4] spd[10]
disp2_p: .db "cnt:    v= ", 0 ; cnt[4,6] v[10,15]

cursor_p: .db "_", 0
num_p: .db "   ", 0

.dseg
line1: .byte 17;why 17? can we just choose any number or is this 17 for a reason
line2: .byte 17
disp1: .byte 17
disp2: .byte 17
blank_3: .byte 12
cursor: .byte 4

num: .byte 8
speed: .byte 4


#define LCD_LIBONLY
.include "lcd.asm"
