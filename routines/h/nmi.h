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
window12Sel	db
window1Left	db
window2Left	db
windowBGLogic	db
windowMainscreen	db
windowObjSel	db
mosaicSetting	db
ScreenMode db
MainScreen db
SubScreen db
BGTilesVram12 db
BGTilesVram34 db
BG1TilemapVram db
BG2TilemapVram db
BG3TilemapVram db
BG4TilemapVram db
colorAdditionSelect db
CgadsubConfig db
FixedColourB db
FixedColourG db
FixedColourR db
xScrollBG1 dw
yScrollBG1 dw
xScrollBG2 dw
yScrollBG2 dw
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
