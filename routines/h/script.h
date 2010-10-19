.include "routines/conf/config.inc"

;defines
.def NumOfHashptr 8

;zp-vars
.enum 0
_tmp ds 16
currScript	dw
currPC	dw	;current exec address in script
buffFlags db	;flags.
buffBank db		;bank. unused, just for convenience
buffA	dw
buffX	dw
buffY	dw
buffStack dw	;used to check for stack trashes
hashPtr INSTANCEOF oopObjHash NumOfHashptr
zpLen ds 0
.ende

.ramsection "selfmod jsl" bank 0 slot 1
SelfModJSL	ds 5	;used for selfmodifying jumps, jsl + rtl
.ends


.base BSL
.bank 0 slot 0
.section "script obj"
	OOPOBJ Script $80 zpLen
.ends


.section "script LUT" superfree
scriptLUT:
	PTRNORM scriptLUT bootstrap
	PTRNORM scriptLUT infinNest
scriptLUTEnd:
.ends

.include "routines/script/bootstrap.script"
.include "routines/script/infinNest.script"
