.include "routines/conf/config.inc"

;zp-vars
.enum 0
R1			db
R2			db
R3			db
R4			db

zpLen ds 0
.ende


.base BSL
.section "rngDat"
	OOPOBJ Rng $81 zpLen Random
.ends
