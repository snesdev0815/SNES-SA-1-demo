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
	lda.w #ZP
	tcd

	sep #$20	
	lda.l RDNMI			;reset nmi flag		
	lda #RAM
	pha
	plb
	lda #0
	sta.l WRIO			;clear iobit

;	lda.w HdmaFlags		;check which hdma channels need to be activated
;	and # DMA_CHANNEL0_ENABLE | DMA_CHANNEL1_ENABLE ~$ff		;exclude channel #0,1(reserved for normal dma)
;	sta.l HDMAEN		;set hdma channels and disable dma channel

	rep #$31
	inc.w FrameCounter
	lda.w window12Sel
	sta.l W12SEL
	lda.w window1Left
	sta.l W1L
	lda.w window2Left
	sta.l W2L
	lda.w windowBGLogic
	sta.l WBGLOG
	lda.w windowMainscreen
	sta.l TMW

	sep #$20
	lda.w windowObjSel
	sta.l WOBJSEL
	lda.w mosaicSetting
	sta.l MOSAIC

	lda.w ScreenMode		;set screenmode and bg sizes
	sta.l BGMODE
	lda.w MainScreen		;setup main and subscreen
	sta.l TMAIN
	lda.w SubScreen		;setup main and subscreen
	sta.l TSUB
	lda.w BGTilesVram12		;set offsets in vram for tiles
	sta.l BG12NBA			;of bg1 and bg2
	lda.w BGTilesVram34		;set offsets in vram for tiles
	sta.l BG34NBA			;of bg1 and bg2
	lda.w BG1TilemapVram	;set offset of bg1 tilemap in  vram
	sta.l BG1SC
	lda.w BG2TilemapVram	;set offset of bg2 tilemap in  vram
	sta.l BG2SC
	lda.w BG3TilemapVram	;set offset of bg3 tilemap in  vram
	sta.l BG3SC
	lda.w BG4TilemapVram	;set offset of bg3 tilemap in  vram
	sta.l BG4SC

	lda.w colorAdditionSelect		;colour add/sub config
	sta.l CGWSEL
	lda.w CgadsubConfig
	sta.l CGADSUB
	lda.w FixedColourB
	and #COLDATA_INTENSITY
	ora #COLDATA_BLUE
	sta.l COLDATA
	lda.w FixedColourG
	and #COLDATA_INTENSITY
	ora #COLDATA_GREEN
	sta.l COLDATA
	lda.w FixedColourR
	and #COLDATA_INTENSITY
	ora #COLDATA_RED
	sta.l COLDATA

	lda.w xScrollBG1		;set bg1 h-offset
	sta.l BG1HOFS
	lda.w xScrollBG1&$ffff+1
	sta.l BG1HOFS
	lda.w yScrollBG1		;set bg1 v-offset
	sta.l BG1VOFS
	lda.w yScrollBG1&$ffff+1
	sta.l BG1VOFS
	lda.w xScrollBG2		;set bg2 h-offset
	sta.l BG2HOFS
	lda.w xScrollBG2&$ffff+1
	sta.l BG2HOFS
	lda.w yScrollBG2		;set bg2 v-offset
	sta.l BG2VOFS
	lda.w yScrollBG2&$ffff+1
	sta.l BG2VOFS

	lda.w ObjSel
	sta.l OBJSEL

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
	lda #INIDSP_FORCE_BLANK			;enter forced blank
	sta.l INIDSP
	lda #0		;clear zero page
	ldy #GlobalVarsEnd-GlobalVarsStrt
	ldx #GlobalVarsStrt

	jsr ClearWRAM
	jsr ClearVRAM

	lda #NMITIMEN_NMI_ENABLE |	NMITIMEN_AUTO_JOY_READ	;enable screen and nmi, auto joypad
	sta.w InterruptEnableFlags
	sta.l NMITIMEN
	lda.w SetIni			;set display mode
	sta.l SETINI			;dont set this during nmi cause if the overscan flag is changed mid-nmi, it might result in screw ups with the nmi timing

	lda.l RDNMI	;pull up nmi line
	lda.l TIMEUP	;pull up irq line

	lda #$ff
	sta.w ScreenBrightness

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
	and #NMITIMEN_NMI_ENABLE ~$ff
	sta.l NMITIMEN
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
		lda.l HVBJOY
		bit #HVBJOY_AUTO_JOY_STATUS
		bne CheckJoypadSinglePlayer

	rep #$30
	lda.w JoyPortBufferOld	;get last button state
	eor #$ffff			;xor
	sta.w JoyPortBufferTrigger
	lda.l JOY1L
	sta.w JoyPortBuffer
	sta.w JoyPortBufferOld
	and.w JoyPortBufferTrigger	;and and only get buttons that werent pressed last frame
	sta.w JoyPortBufferTrigger	;store in joypad buffer
	rts
	
.ends

