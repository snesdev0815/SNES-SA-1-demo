.include "routines/conf/config.inc"

/*
.STRUCT NmiZP
.ENDST


;ram buffers

.ramsection "nmi zp private vars" bank 0 slot 2
NmiPrivVars INSTANCEOF NmiZP
NmiPrivVarsEnd ds 0
.ends
*/

.ramsection "global vars nmi" bank 0 slot 1
GlobalVarsStrt ds 0

SetIni	db
W12SEL	db
W1L	db
W2L	db
WBGLOG	db
WMS	db
WOBJSEL	db
Mosaic	db
ScreenMode db
MainScreen db
SubScreen db
BGTilesVram12 db
BGTilesVram34 db
BG1TilemapVram db
BG2TilemapVram db
BG3TilemapVram db
BG4TilemapVram db
CGWsel db
CgadsubConfig db
FixedColourB db
FixedColourG db
FixedColourR db
BG1HOf dw
BG1VOf dw
BG2HOf dw
BG2VOf dw
ObjSel db

HdmaFlags		db
FrameCounter	dw
LastFrame		dw

FrameClipStart db
FrameClipEnd db

JoyPortBufferTrigger dw
JoyPortBuffer dw

CpuUsageScanline			db
ScreenBrightness 			db
InterruptEnableFlags	db

irqCount		dw
dmaIrqCount	dw
frameIrqCount dw
frameBuffHistory ds 3
irqCheckpoint db

;charConvReady db	;0=wait, 1=ready moved to main.h
CheckJoypadMode			db
JoyPortBufferOld	dw

GlobalVarsEnd ds 0
.ends

;joypad buttons:
;15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
;b  y  se st U  D  L R a x l r 0 0 0 0


.base BSL
/*
.section "nmiDat"
	OOPOBJ Nmi Nmi.OBJID $81 1 NmiInit NmiPlay NmiKill
.ends
*/
