.include "routines/h/demo.h"

.section "demo main handler"
;quick & dirty setup
init_Demo:
sep #$20
lda #$80				;force blank
sta.l $002100
lda #0
sta.l $004200			;disable irqs

lda #0
sta.w BGTilesVram12

lda #$ffff>>8 &$f0
sta.w BG1TilemapVram

lda #3
sta.w ScreenMode

lda #%00000001
sta.w MainScreen
lda #%00000001
sta.w SubScreen

lda #%00100001
sta.w CgadsubConfig
lda #0
sta.w WMS
sta.l $00212f
sta.w CGWsel
;lda #%00000111

;sta.l FixedColourB
jsr UploadDebugPalette
jsr setupTilemap


lda #$ff
sta.w ScreenBrightness
lda.w InterruptEnableFlags
sta.l $004200

rep #$31
;stz.w rendererFrame
;lda #0
;sta.w rendererScene
lda #-(((28-frameResY)/2)*8)
sta.w BG1VOf

	NEW Sa1Iface.CLS.PTR rendererPTR
	NEW Spc.CLS.PTR soundPTR

	lda rendererPTR			;save pointer for irq usage
	sta.w rendererIrqPTR
	lda rendererPTR+2
	sta.w rendererIrqPTR+2
	
	CALL Sa1Iface.renderScene.MTD rendererPTR 0

	CALL Spc.registerStimulusCallback.MTD soundPTR spcStimulusTrigger.CLB


sep #$20
lda #$ff								;just to be on the safe side
sta.w ScreenBrightness
lda #1
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
;	CALL Sa1Iface.renderScene.MTD rendererPTR

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
/*
sep #$20
nop
nop
nop	;adding nops here makes polys flash wildly. what gets overwritten where? reason was that framebuffer1/2 were sometimes swapped around in ramsection define
;****
nop
*/
rts

setupTilemap:
php
sep #$20
lda #%10000000
sta.l $002115	;vram port word access
rep #$31	
lda.w BG1TilemapVram
and #$f0
xba
lsr a
lda.w #$7000
sta.l $002116

ldx #0	;h-count
ldy #0	;v-count

lda #1

	tilemapYloop:
		tilemapXloop:
		sta.l $002118
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
	stz.w $2121			;upload frame palette
	rep #$31
	lda.w #debugPal ;source
	sta.w $4302
	
	sep #$20			
	lda.b #:debugPal
	sta.w $4304
	rep #$31
	
	lda.w #debugPalEnd-debugPal ;length
	sta.w $4305
	sep #$20
	lda.b #$00			;Set the DMA mode (byte, normal increment)
	sta.w $4300       
	lda.b #$22    			;Set the destination register ( $2122: CG-RAM Write )
	sta.w $4301      
	lda.b #$01    			;Initiate the DMA transfer
	sta.w $420B
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
