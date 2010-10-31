.include "routines/h/demo.h"

.section "demo main handler"
;quick & dirty setup
init_Demo:
	sep #$20
	lda #INIDSP_FORCE_BLANK				;force blank
	sta.l INIDSP
	lda #0
	sta.l NMITIMEN			;disable irqs

	lda #0
	sta.w BGTilesVram12

	lda #$ffff>>8 &$f0
	sta.w BG1TilemapVram

	lda #BGMODE_MODE_3
	sta.w ScreenMode

	lda #T_BG1_ENABLE
	sta.w MainScreen
	lda #T_BG1_ENABLE
	sta.w SubScreen

	lda #CGADSUB_BAC_ENABLE | CGADSUB_BG1_ENABLE
	sta.w CgadsubConfig
	lda #0
	sta.w windowMainscreen
	sta.l TSW
	sta.w colorAdditionSelect

	jsr UploadDebugPalette
	jsr setupTilemap


	lda #$ff
	sta.w ScreenBrightness
	lda.w InterruptEnableFlags
	sta.l NMITIMEN

	rep #$31
	lda #-(((28-frameResY)/2)*8)
	sta.w yScrollBG1

		NEW Sa1Iface.CLS.PTR rendererPTR
		NEW Spc.CLS.PTR soundPTR

		lda rendererPTR			;save pointer for irq usage
		sta.w rendererIrqPTR
		lda rendererPTR+2
		sta.w rendererIrqPTR+2
	
		CALL Sa1Iface.renderScene.MTD rendererPTR 0
		CALL Spc.registerStimulusCallback.MTD soundPTR spcStimulusTrigger.CLB


	sep #$20
	lda #INIDSP_BRIGHTNESS								;just to be on the safe side
	sta.w ScreenBrightness
	lda #T_BG1_ENABLE
	sta.w MainScreen
	sta.w SubScreen
	rts

;msb clear= select scene, msb set=exec hdma effect(or create hdma object or whatever)
;the scene changer may not work as desired if frames are rendered too fast(not a problem on real hardware, but on snes9x, for example)
spcStimulusTrigger:
	sep #$20
	bmi spcStimulusTriggerHdma
	rep #$31
	and #$7f
	sta.w rendererScene
	stz.w rendererFrame

	lda #$baad
	rts

spcStimulusTriggerHdma:
	pea E_Todo
	jsr PrintException
	stp

kill_Demo:
	rep #$31
	lda #OBJR_kill
	sta 3,s
	rts

play_Demo:
	rts

setupTilemap:
	php
	sep #$20
	lda #VMAIN_INCREMENT_MODE
	sta.l VMAIN		;vram port word access
	rep #$31	
	lda.w BG1TilemapVram
	and #$f0
	xba
	lsr a
	lda.w #$7000
	sta.l VMADDL

	ldx #0	;h-count
	ldy #0	;v-count

	lda #1
	tilemapYloop:
			tilemapXloop:
			sta.l VMDATAL
			inc a
			inx
			cpx #frameResX
			bcc tilemapXloop
	
		ldx #0
		iny
		cpy #frameResY
		bcc tilemapYloop
	
	plp
	rts


UploadDebugPalette:
	php
	phb
	sep #$20
	lda #REGS
	pha
	plb
						;transfer bright initial palette		
	stz.w CGADD			;upload frame palette
	rep #$31
	lda.w #debugPal ;source
	sta.w DMASRC0L
	
	sep #$20			
	lda.b #:debugPal
	sta.w DMASRC0B
	rep #$31
	
	lda.w #debugPalEnd-debugPal ;length
	sta.w DMALEN0L
	sep #$20
	lda.b #$00			;Set the DMA mode (byte, normal increment)
	sta.w DMAP0       
	lda.b #CGDATA & $ff    			;Set the destination register ( CGDATA: CG-RAM Write )
	sta.w DMADEST0
	lda.b #DMA_CHANNEL0_ENABLE    			;Initiate the DMA transfer
	sta.w MDMAEN
	plb
	plp
	rts

.ends


.section "debug palette"
debugPal:
.db 0
/*
.rept $100
.dw $7fff
.endr
*/
debugPalEnd:
.ends
