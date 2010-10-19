.include "routines/h/rng.h"
.section "rng"

init_Rng:
	rep #$31
	lda #$1234			;seed RNG
	sta R1
	lda #$55aa
	sta R3
	rts

kill_Rng:
	rep #$31
	lda #OBJR_kill
	sta 3,s
	rts

play_Rng

Random:
	php
	sep #$20
	LDA R3
	STA R4								;R4=R3
	LDA R2
	STA R3								;R3=R2
	LDA R1
	STA R2								;R2=R1
	CMP R3
	BMI R3_Greater				;If R3>R2 Then Goto R3_Greater
	
	LDA R3
	CLC
	ADC R4
	clc
	eor.w JoyPortBuffer&$ffff			;use button presses for rng aswell
	eor.w JoyPortBuffer&$ffff+2
	eor.w JoyPortBuffer&$ffff+4
	eor.w JoyPortBuffer&$ffff+6
	eor.w JoyPortBuffer&$ffff+8
	eor.w JoyPortBuffer&$ffff+10
	eor.w JoyPortBuffer&$ffff+12
	eor.w JoyPortBuffer&$ffff+14
	eor.w FrameCounter

	STA R1								;R1=R3+R4 MOD 256

	plp
	RTS									 ;Return R1
	
R3_Greater:
	CLC
	ADC R4
	clc
	eor.w JoyPortBuffer&$ffff+8
	eor.w FrameCounter

	STA R1								;R1=R2+R4 MOD 256
	plp
	RTS									 ;Return R1
.ends