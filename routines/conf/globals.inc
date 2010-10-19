
;kernel zp-vars(used by init,memoryclear,oophandler etc)
.enum 0
kernelStart ds 0

tmp					ds 20
dpBuffr			dw
stackBuffr	dw
errCurr			db
classCurr		db
routCurr		db
OopObjSlotPtr dw	;current position in obj-entry buffer
OopObjRamPtr dw	;current fill position in obj ram block
kernelEnd 	ds 0
.ende


/*
;needed for a couple of opcodes that use 16bit addressing w/o zero page
.enum RAMBAS
RamBasePtr	ds 3
.ende
*/
;global defines
.define TILE2BPP	16
.define TILE4BPP	32
.define TILE8BPP	64

.define frameResX 32
.define frameResY 15

.define rwTest	$aa55

.define oopCreateNoPtr $ffff