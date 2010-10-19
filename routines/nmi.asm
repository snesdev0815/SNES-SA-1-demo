;this nmi uses a maximum of 20 scanlines while streaming brr frames to the spc
.include "routines/h/nmi.h"
;.include "routines/joypadread.asm"
.section "nmi"

NMI:
	rep #$39
	pha
	phb
	phd
	phx
	phy
;	lda.w #NmiPrivVars
	lda.w #ZP
	tcd
	sep #$20	
	lda.l $004210			;reset nmi flag		
;	lda.w InterruptEnableFlags
;	and #$7f
;	sta.l $004200
	lda #RAM
	pha
	plb
	lda #0
	sta.l $004201			;clear iobit

;	lda.w HdmaFlags		;check which hdma channels need to be activated
;	and #$fc		;exclude channel #0,1(reserved for normal dma)
;	sta.l $00420C		;set hdma channels and disable dma channel

	rep #$31
	inc.w FrameCounter
	lda.w W12SEL
	sta.l $002123
	lda.w W1L
	sta.l $002126
	lda.w W2L
	sta.l $002128
	lda.w WBGLOG
	sta.l $00212a
	lda.w WMS
	sta.l $00212e

	sep #$20
	lda.w WOBJSEL
	sta.l $002125
	lda.w Mosaic
	sta.l $002106

	lda.w ScreenMode		;set screenmode and bg sizes
	sta.l $002105			;
	lda.w MainScreen		;setup main and subscreen
	sta.l $00212c			;
	lda.w SubScreen		;setup main and subscreen
	sta.l $00212d			;
	lda.w BGTilesVram12		;set offsets in vram for tiles
	sta.l $00210B			;of bg1 and bg2
	lda.w BGTilesVram34		;set offsets in vram for tiles
	sta.l $00210C			;of bg1 and bg2
	lda.w BG1TilemapVram	;set offset of bg1 tilemap in  vram
	sta.l $002107			;
	lda.w BG2TilemapVram	;set offset of bg2 tilemap in  vram
	sta.l $002108			;
	lda.w BG3TilemapVram	;set offset of bg3 tilemap in  vram
	sta.l $002109			;
	lda.w BG4TilemapVram	;set offset of bg3 tilemap in  vram
	sta.l $00210a			;

	lda.w CGWsel		;colour add/sub config
	sta.l $002130
	lda.w CgadsubConfig
	sta.l $002131
	lda.w FixedColourB
	and #%00011111
	ora #%10000000
	sta.l $2132
	lda.w FixedColourG
	and #%00011111
	ora #%01000000
	sta.l $002132
	lda.w FixedColourR
	and #%00011111
	ora #%00100000
	sta.l $002132

  lda.w BG1HOf		;set bg1 h-offset
	sta.l $00210d			;
  lda.w BG1HOf&$ffff+1		;
	sta.l $00210d			;
  lda.w BG1VOf		;set bg1 v-offset
	sta.l $00210e			;
  lda.w BG1VOf&$ffff+1		;
	sta.l $00210e			;
  lda.w BG2HOf		;set bg2 h-offset
	sta.l $00210f			;
  lda.w BG2HOf&$ffff+1		;
	sta.l $00210f			;
  lda.w BG2VOf		;set bg2 v-offset
	sta.l $002110			;
 	lda.w BG2VOf		;
	sta.l $002110			;

	lda.w ObjSel
	sta.l $002101
/*
	lda.b IrqRoutineNumberBuffer
	sta.b IrqRoutineNumber		;if this is zero, irqs are disabled
	beq NmiDisableHIrq

	rep #$31			;store current h-counter in reg
	lda.b IrqVCounter
	sta.w $4209			;v
	lda.b IrqHCounter
	sta.w $4207			;h
	sep #$20
	lda.b InterruptEnableFlags
	ora.b #%00110000		;enable v and h irq, will take effect next frame. irq is only triggered if both positions match
	sta.b InterruptEnableFlags
	sta.w $4200			;should be ok. hope it breaks nothing
	bra NmiHIrqDone

NmiDisableHIrq:
	lda.b InterruptEnableFlags
	and.b #%11011111		;disable h-irq
	sta.b InterruptEnableFlags

NmeiHIrqDone:
*/

	rep #$31
	lda.w CheckJoypadMode
	and #%11
	asl a
	tax
	sep #$20
	jsr (CheckJoypadModeLUT,x)
		
	rep #$39
	lda.w execFrame
	beq ObjHandlerNotExecuting
		lda.w FrameCounter
		sec
		sbc.w execFrame
		bcs ObjHandlerCheckExecTime
			lda.w execFrame		;wrap around
			sec
			sbc.w FrameCounter
		
		ObjHandlerCheckExecTime:
		
	ObjHandlerNotExecuting:
	ply
	plx
	pld
	plb
	pla
	rti				;return from nmi

NmiInit:
php
sep #$20
lda #$80			;enter forced blank
sta.l $002100
lda #0		;clear zero page
ldy #GlobalVarsEnd-GlobalVarsStrt
ldx #GlobalVarsStrt
jsr ClearWRAM
/*
lda #0		;clear zero page
ldy #NmiPrivVarsEnd-NmiPrivVars
ldx #NmiPrivVars
jsr ClearWRAM
*/
jsr ClearVRAM

lda #%10000001		;enable screen and nmi, auto joypad
sta.w InterruptEnableFlags
sta.l $004200
lda.w SetIni			;set display mode
sta.l $002133			;dont set this during nmi cause if the overscan flag is changed mid-nmi, it might result in screw ups with the nmi timing
;lda.w ScreenBrightness	;setup screen brightness
;and #$7f			;screen always on and enabled
;sta.l $002100
lda.l $004210	;pull up nmi line
lda.l $004211	;pull up irq line

lda #$ff
sta.w ScreenBrightness

rep #$31

plp
cli
rts

NmiPlay:
rep #$31
lda.w #$beef
rts

NmiKill:
sep #$20
sei
lda.w InterruptEnableFlags
and #$7f
sta.l $004200
rts




CheckJoypadModeLUT:
	.dw	CheckJoypadSinglePlayer
	.dw CheckJoypadVoid
	.dw CheckJoypadVoid
	.dw CheckJoypadVoid
	
CheckJoypadVoid:
	rts

;fast joy1 checker. check this late in nmi so we don't have to wait for auto joypad read to finish:
CheckJoypadSinglePlayer:
	lda.l $004212
	bit #$01
	bne CheckJoypadSinglePlayer

	rep #$30
	lda.w JoyPortBufferOld	;get last button state
	eor #$ffff			;xor
	sta.w JoyPortBufferTrigger
	lda.l $004218
	sta.w JoyPortBuffer
	sta.w JoyPortBufferOld
	and.w JoyPortBufferTrigger	;and and only get buttons that werent pressed last frame
	sta.w JoyPortBufferTrigger	;store in joypad buffer
	rts
	
.ends
