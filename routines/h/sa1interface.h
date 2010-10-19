.include "routines/conf/config.inc"

.define polyLen 7	;quick hack, this should be made according to vertex structs 
.define dmaFillThresh 10	;if poly-span is longer than this, do dma fill

.macro FILLMACRO
sta.w (\@~$ff)&$ff,x
.endm

.STRUCT vertex
x	db
y	db
.ENDST

.STRUCT edge
leE	db
riE	db
.ENDST

.STRUCT tile
p ds 64
.ENDST

.STRUCT linBuff
strt dw
end  dw
dpag dw
.ENDST

.STRUCT linDpag
lin dw
.ENDST


.STRUCT lineDist
dx db
dy db
startx db
starty db
endx db
endy db
march db	;x=0,y=$80
dir	db	;left=0,right=$80
countr	db	;division step counter
posx	db
posy	db
void	db
.ENDST

;zero-page version of render vars
.enum 0
zpB instanceof lineDist
.ende

;zp-vars 65816
.enum 0
_tmp ds 8
currFrm dw
currScene dw
;currSceneFrameNum dw
zpLen ds 0
.ende


.base REGS
.ramsection "sa1 iram handshake" bank 0 slot 4
cmdCommit		db	;if not zero, sa1 renders specified frame
cmdIrqBusy	db	;sa1 may only generate irq if this is not zero.
cmdFrame		ds 3	;frame to render
retDone			db	;not zero if sa1 is done rendering frame
retFrame		dw	;sa1 reports frame it has just rendered
retGfxPtr		ds 3	;24bit pointer to rendered frame bitmap buffer in bwram
retPalPtr		ds 3	;24bit pointer to frame palette
retPalLen		dw	;length of frame palette/2
retPalPtrBuff		ds 3
retPalLenBuff dw
currFrameBuff	ds 3	;pointer to framebuffer
sourceVert instanceof vertex	;used for line setup
targetVert instanceof vertex
first instanceof linDpag
second instanceof linDpag
sa1CP				db	;checkpoint,used for debugging
.ends

;sa1 direct page vars:
.enum 0
sa1IramDpStart	ds 0
sa1tmp ds 8
polyNum	dw	;amount of polys in current frame
polyPtr	ds 3
col		db	;current poly color index
poly instanceof vertex 3	;current poly vertices
polyHeight	db	;poly.3.y-poly.1.y
polyTopBot	dw	;0=top part, 1=bottom part
le instanceof lineDist
re instanceof lineDist
fillBuff		ds 3
;polyBuff instanceof linBuff 3
sa1IramDpEnd	ds 0
.ende

.ramsection "sa1 iram direct page vars" bank 0 slot 4
sa1IramDp ds sa1IramDpEnd-sa1IramDpStart
.ends

;create this to reserve space for sa1 program code
.ramsection "sa1 iram code buffr dummy" bank 0 slot 4 
IramCodeDummy ds $700	;wla isnt able to dynamically compute the length of Sa1 code section, so this hardcoded hack will have to do
.ends

.ramsection "sa1 iram stack" bank 0 slot 4
sa1StackStart  ds $20	;tiny stack
sa1Stack ds 0
.ends


.define framebuffsize $8000
.ramsection "sa1 bw-ram framebuffer 1" bank 0 slot 5
frameBuff1 ds framebuffsize ;instanceof tile frameResX*frameResY
.ends
/*
.ramsection "sa1 bw-ram framebuffer 2" bank 0 slot 5
frameBuff2 ds $7800 ;instanceof tile frameResX*frameResY
.ends
*/

.base BSL
.bank 0 slot 0
.org 0
.section "sa1IfDat"
	OOPOBJ Sa1Iface $81 zpLen renderScene /*Sa1NextFrame*/
.ends


.macro DMAFILL
.rept 256
.db \@
.endr
.endm

