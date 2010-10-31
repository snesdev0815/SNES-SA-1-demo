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

play_Rng:
	rts

Random:
	php
	sep #$20
	lda R3
	sta R4								;R4=R3
	lda R2
	sta R3								;R3=R2
	lda R1
	sta R2								;R2=R1
	cmp R3
	bmi R3_Greater				;If R3>R2 Then Goto R3_Greater
	
	lda R3
	clc
	adc R4
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

	sta R1								;R1=R3+R4 MOD 256

	plp
	rts									 ;Return R1
	
R3_Greater:
	clc
	adc R4
	clc
	eor.w JoyPortBuffer&$ffff+8
	eor.w FrameCounter

	sta R1								;R1=R2+R4 MOD 256
	plp
	rts									 ;Return R1

.ends

