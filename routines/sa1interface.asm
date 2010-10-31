.include "routines/h/sa1interface.h"
.section "sa1interface"

init_Sa1Iface:
	sep #$20
	lda #CCNT_SA1_CPU_RESET
	sta.l CCNT		;reset sa1
	lda #SIC_CHARCONV_IRQ_CLEAR | SIC_SA1_IRQ_CLEAR
	sta.l SIC		;clear irqs to snes
	lda #0
	sta.l CXB		;disable bankswitching banks $c0-$ff
	inc a
	sta.l DXB
	inc a
	sta.l EXB
	inc a
	sta.l FXB
	lda #0
	sta.l BMAPS		;swap in lowest bw-ram bank into $00-$3f:6000-$7fff
	sta.l BWPA		;deprotect all bw-ram banks for snes
	lda #SBWE_SNES_BWRAM_WRITE_ENABLE
	sta.l SBWE		;snes bw-ram write enable

	lda #%11111111
	sta.l SIWP	;write-enable all iram banks for snes.
	lda #CDMA_CHARCONV_END
	sta.l CDMA	;end char conversion, 8bpp
	lda #SIC_CHARCONV_IRQ_CLEAR | SIC_SA1_IRQ_CLEAR
	sta.l SIC		;clear both irqs(shouldnt be se at reset, but whatever...)
	lda #SIE_CPU_IRQ_ENABLE | SIE_CHARCONV_IRQ_ENABLE
	sta.l SIE		;enable normal & char irq to snes

	rep #$31
	lda #(Sa1Boot-Sa1CodeStart)+IramCodeDummy	;set sa1 reset vector
	sta.l CRV
	lda #(Sa1EmptyHandler-Sa1CodeStart)+IramCodeDummy	;set sa1 nmi vector
	sta.l CNV
	sta.l CIV

	lda #$ff
	jsr CheckBWramSize
	jsr ClearIram
	jsr SetupBWram
	jsr UploadSa1Code

	sep #$20
	lda #0
	sta.l cmdCommit
	lda #%00000000
	sta.l CCNT		;start sa-1
	rts

;uploads sa1 routines to iram, org 0. set irem write enable for snes cpu first!!
UploadSa1Code:
	php
	sep #$20
	lda #:Sa1CodeStart	;source pointer
	sta _tmp+2

	rep #$31
	lda #Sa1CodeStart
	sta _tmp

	ldy #0
	tyx

UploadSa1CodeLoop:
	   lda [_tmp],y
	   sta.l IramCodeDummy,x
	   cmp.l IramCodeDummy,x
	   beq UploadSa1CodeOk

			pea E_Sa1IramCode						;print error if uploaded bytes dont match
			jsr PrintException
			stp
  
	UploadSa1CodeOk:
		inx
		inx
		iny
		iny
		cpy #Sa1CodeEnd-Sa1CodeStart
		bcc UploadSa1CodeLoop
	plp
	rts

SetupBWram:
	php
	rep #$31
	lda #0
	tax

	ClearBWramLoop:
		sta.l frameBuff1,x
		cmp.l frameBuff1,x
		beq ClearBWramLoopOK
			pea E_Sa1BWramClear						;print error if uploaded bytes dont match
			jsr PrintException
			stp
	
	ClearBWramLoopOK:
		inx
		inx
		cpx #framebuffsize
		bcc ClearBWramLoop
	plp
	rts

;in: a,8bit, bytesize*$ff to check for
CheckBWramSize:
	php
	phb
	rep #$31
	and.w #$ff
	sta.b _tmp	;blocks
	xba
	sta.b _tmp+2	;max location

	pea BWRAM << 8
	plb
	plb
	ldx.w #0

	lda.w #$55aa
	sta.w $0,x
	cmp.w $0,x
	bne ErrNoBwram	

	lda.w #$aa55
	sta.w $0,x
	cmp.w $0,x
	bne ErrNoBwram	

	ldx.b _tmp+2
	lda.b _tmp

	CheckBWramSizeLoop:
		sta.w $0,x

		pha
		txa
		sec
		sbc.w #$100
		tax
		pla

		dec a		

		bne CheckBWramSizeLoop

	ldx.b _tmp+2
	lda.b _tmp
	cmp.w $0,x	
	bne ErrBwramTooSmall

	plb
	plp
	rts

ErrNoBwram:
	pea E_Sa1NoBWram
	jsr PrintException
	plb
	plp
	rts

ErrBwramTooSmall:
	pea E_Sa1BWramToSmall
	jsr PrintException
	plb
	plp
	rts

ClearIram:
	php
	rep #$31
	lda #0
	tax

	ClearIramLoop:
		sta.l SA1IRAM,x
		cmp.l SA1IRAM,x
		beq ClearIramLoopOK
			pea E_Sa1IramClear						;print error if uploaded bytes dont match
			jsr PrintException
			stp
	
	ClearIramLoopOK:
		inx
		inx
		cpx #SA1IRAMLEN
		bcc ClearIramLoop
	plp
	rts

play_Sa1Iface:
	rts

Sa1IrqNextFrame:
	rep #$31
	pha		;reserve some stack space
	pha
	pha
	pha
	lda.w rendererScene
	and #$ff
	sta 1,s
	asl a
	clc
	adc 1,s
	tax
	lda.l DemoSceneLUT,x
	tay
	lda.l DemoSceneLUT+1,x
	pha
	plb
	plb

	lda 0,y
	sta 1,s
	lda.l rendererFrame
	inc a
	cmp 1,s
	bcc SetupFrameIrqNoOver
		lda.l rendererScene
		inc a
		and #$ff
		sta.l rendererScene
		cmp #17
		bcc SetupFrameIrqNoEnd
			pea E_Sa1Test						;print error if no irq occurs for some time
			jsr PrintException
			stp

SetupFrameIrqNoEnd:
	sta 1,s
	asl a
	clc
	adc 1,s
	tax
	lda.l DemoSceneLUT,x
	tay
	lda.l DemoSceneLUT+1,x
	pha
	plb
	plb

	lda #0

SetupFrameIrqNoOver:
	sta 1,s
	sta.l rendererFrame
	asl a
	clc
	adc 1,s
	inc a			;skip number of frames
	inc a
	sta 1,s
	tya
	clc
	adc 1,s
	tay
	lda 0,y
	sta.l cmdFrame		;tell sa1 to render frame
	lda 1,y
	sta.l cmdFrame+1		;tell sa1 to render frame
	pea REGS
	plb
	plb
	lda.l retGfxPtr
	sta 1,s
	lda.l retGfxPtr+1
	sta 2,s
	lda.l retPalPtr
	sta 4,s
	lda.l retPalPtr+1
	sta 5,s
	lda.l retPalLen
	sta 7,s

	lda 1,s		;lda.l retGfxPtr
	and #%1111100000000000
	sta.w SDA
	
	sep #$20
	lda 3,s		;lda.l retGfxPtr+2
	sta.w SDA+2	
	lda #CDMA_TILES_PER_ROW_32 | CDMA_8BPP	;char conversion settings,8bpp,32 hor-tiles
	sta.w CDMA

	stz.w charConvReady

	rep #$35
	lda #IramCharConvBuff
	sta.w DDA

	sep #$20
	ldx #0

	Sa1IrqWaitCharConv:			;wait for charconv-ack-irq to happen
		lda.w charConvReady
		bne Sa1IrqCharConvReady

			inx
			bne Sa1IrqWaitCharConv
				pea E_Sa1NoIrq						;print error if no irq occurs for some time
				jsr PrintException
				stp

Sa1IrqCharConvReady:
	sei	;set irq again so that no other irq can happen till rti


IrqIrqWaitScanlineLoop:
		stz.w WRIO
		and (0,s),y
		lda #WRIO_JOY2_IOBIT_LATCH
		sta.w WRIO
		and (0,s),y
		lda.w SLHV
		lda.w STAT78			;reset OPVCT to low byte
		lda.w OPVCT			;get current scanline
		cmp #((((28-frameResY)/2)+frameResY)*8)-1
		bne IrqIrqWaitScanlineLoop

	lda #INIDSP_FORCE_BLANK
	sta.w INIDSP
	rep #$31
	lda.w #0+(TILE8BPP/2)
	sta.w VMADDL			;vram adress $0000
	lda.w #frameResX*frameResY*TILE8BPP
	sta.w DMALEN0L
	lda 1,s		;lda.l retGfxPtr
	sta.w DMASRC0L			;Store the data offset into DMA source offset
	ora.l frameBuffHistory	;save adress so that we can see if erroneous transfers occured 
	sta.l frameBuffHistory

	sep #$20
	lda 3,s		;lda.l retGfxPtr+2
	sta.w DMASRC0B			;Store the data bank of the source data
	ora.l frameBuffHistory+2
	sta.l frameBuffHistory+2
	lda.b #VMAIN_INCREMENT_MODE
	sta.w VMAIN			;set VRAM transfer mode to word-access, increment by 1
	lda.b #DMAP_2_REG_WRITE_ONCE			;Set the DMA mode (word, normal increment)
	sta.w DMAP0       
	lda.b #VMDATAL & $ff    			;Set the destination register (VRAM gate)
	sta.w DMADEST0
	lda.b #DMA_CHANNEL0_ENABLE    			;Initiate the DMA transfer
	sta.w MDMAEN

	;transfer frame palette
	rep #$31
	lda 4,s		;lda.l retPalPtr ;source
	sta.w DMASRC0L
	lda 5,s		;lda.l retPalPtr+1 
	sta.w DMASRC0H
	
	lda 7,s	;	lda.l retPalLen ;length
	sta.w DMALEN0L
	sep #$20		
	stz.w CGADD			;upload frame palette
	lda.b #$00			;Set the DMA mode (byte, normal increment)
	sta.w DMAP0       
	lda.b #CGDATA & $ff    			;Set the destination register ( CGDATA: CG-RAM Write )
	sta.w DMADEST0
	lda.b #DMA_CHANNEL0_ENABLE    			;Initiate both DMA transfers
	sta.w MDMAEN

	lda #CDMA_CHARCONV_END		;tell sa1 transfer is complete
	sta.l CDMA

	lda.l ScreenBrightness
	and #INIDSP_FORCE_BLANK ~ $ff
	sta.w INIDSP

	lda #1			;committing frame after irq setup saves us from using irq busy flag
	sta.l cmdCommit	

	rep #$31
	pla
	pla
	pla
	pla
	rts

kill_Sa1Iface:
	rts

;appearently, both normal irq and charconv irq flags are set at the same time on real hardware. why?
;emu:530 frm-irqs, 530 char-irqs, total a61 irqs (diff=1)
;real: 530 frm-irqs, 530 char-irqs, total 8c7 irqs (diff=199)
Sa1IrqHandler:
	.ACCU 8
	.INDEX 16

	lda.l CFR
	sta.w Sa1IrqFlags
	lda.l SFR
	sta.w SnesIrqFlags
	sta.l SIC		;clear sa1 irqs to snes. else, irq line would stay set all the time
	and # SIE_CHARCONV_IRQ_ENABLE | SIE_CPU_IRQ_ENABLE
	cmp # SIE_CHARCONV_IRQ_ENABLE | SIE_CPU_IRQ_ENABLE
	bne Sa1NoDoubleIrq
		pea E_Sa1DoubleIrq	;2 different irqs should never occur at the same time
		jsr PrintException
		stp
		

Sa1NoDoubleIrq:
	lda #0
	sta.l irqCheckpoint

	lda.w SnesIrqFlags
	bit # SIE_CHARCONV_IRQ_ENABLE
	beq Sa1NoCharConvTransfer

		lda #1
		sta.l irqCheckpoint

		lda #1
		sta.w charConvReady
		rep #$31
		lda.l dmaIrqCount
		inc a
		sta.l dmaIrqCount

		clc
		rts
		
Sa1NoCharConvTransfer:
	sep #$20
	lda.w SnesIrqFlags
	bpl Sa1NoNormalIrq

		lda #2
		sta.l irqCheckpoint

		jsr Sa1IrqNextFrame

		rep #$31
		lda.l frameIrqCount
		inc a
		sta.l frameIrqCount

		clc
		rts

Sa1NoNormalIrq:
	clc
	sec	;unhandled irq
	rts

renderScene:
	rep #$31
	and.w #$ff
	sta.w rendererScene
	stz.w rendererFrame
	jsr SetupFramePtr
	rts

SetupFramePtr:
	php
	SetupFramePtrRpt:
	rep #$31
	lda.w rendererScene
	and #$ff
	sta _tmp
	asl a
	clc
	adc _tmp
	tax
	lda.l DemoSceneLUT,x
	sta _tmp
	lda.l DemoSceneLUT+1,x
	sta _tmp+1
	ldy.w #0				;number of frames in scene
	lda [_tmp],y
	sta _tmp+3
	lda.w rendererFrame
	cmp _tmp+3
	bcc SetupFrameNoOver
		plp	;scene complete
		rts

SetupFrameNoOver:
	sta _tmp+3
	sta.w rendererFrame
	asl a
	clc
	adc _tmp+3
	inc a			;skip number of frames
	inc a
	tay
	lda [_tmp],y
	sta.l cmdFrame		;tell sa1 to render frame
	iny
	lda [_tmp],y
	sta.l cmdFrame+1		;tell sa1 to render frame

	sep #$20
	lda #1
	sta.l cmdCommit	
	plp
	rts

.ends

;this is relocatable code, don't use absolute branching(jmp/jsr/jsl)
.section "sa1 code in iram" align 2
Sa1CodeStart:
Sa1Boot:
	sei		;switch to native mode
	clc
	xce
	rep #$31
	lda #sa1Stack-1
	tcs
	lda #sa1IramDp
	tcd
	sep #$20
	lda #REGS
	pha
	plb
	lda #0
	sta.l SCNT	;disable snes irq,snes irq/nmi vector from rom
	sta.l CIE	;mask off sa1 irqs
	lda #CIC_IRQ_SNES2SA1_CLEAR | CIC_IRQ_TIMER2SA1_CLEAR | CIC_IRQ_DMA2SA1_CLEAR | CIC_NMI_SNES2SA1_CLEAR
	sta.l CIC	;clear all sa1 irqs
	lda #0
	sta.l TMC	;disable sa1 timers
	sta.l BMAP
	lda #CBWE_SA1_BWRAM_WRITE_ENABLE
	sta.l CBWE	;sa1 bwram write enable
	lda #%11111111
	sta.l CIWP	;write-enable all iram banks for sa1. is this correct??
	lda #0
	sta.l DCNT	;disable sa1 dma

	lda #$0
	sta.l BBF	;4bpp mode

	lda #MCNT_CUMULATIVE_SUM
	sta.l MCNT	;clear cumul sum

	lda #BWRAM
	sta.w currFrameBuff+2
	rep #$31
	lda #0	;frameBuff1
	sta.w currFrameBuff
	sep #$20

Sa1WaitFrame:
		lda #5
		sta.l frameBuff1+(frameResX*frameResY*TILE8BPP)
		lda.w cmdCommit
		beq Sa1WaitFrame

	lda #0					;clear commit, wait for next frame
	sta.w cmdCommit

	rep #$31
	lda.w cmdFrame+1
	sta.w retPalPtrBuff+1
	sta sa1tmp+1

	lda.w cmdFrame
	sta sa1tmp
	inc a									;skip pal-length byte
	sta.w retPalPtrBuff
	ldy #0					;get pal-length
	lda [sa1tmp],y
	and #$ff
	asl a
	sta.w retPalLenBuff

	inc a
	clc							;update pointer, point to polycount
	adc sa1tmp
	sta sa1tmp
	lda [sa1tmp],y
	sta polyNum
	inc sa1tmp		;move pointer to polys
	inc sa1tmp

	sep #$20
	stz.w CFR		;clear dma flag (and all irq msgs from snes)
	lda #DCNT_DMA_ENABLE | DCNT_DMA_DESTINATION | DCNT_DMA_SOURCE_ROM		;dma-clear bw-ram framebuffer
	sta.l DCNT

	rep #$31
	lda #FrameBufferClearer
	sta.l SDA

	sep #$20
	lda #:FrameBufferClearer	;source
	sta.l SDA+2

	rep #$31
	lda #frameResX*frameResY*TILE8BPP	;length
	sta.l DTC

	lda.w currFrameBuff
	sta.l DDA

	sep #$20
	lda.w currFrameBuff+2
	sta.l DDA+2

;copy polys to iram buffer while bw-ram framebuffer is being cleared
	rep #$31
	ldy #0
	lda sa1tmp
	sta polyPtr
	lda sa1tmp+1
	sta polyPtr+1
;draw pixels. later:draw polys
	rep #$31
	ldy #0
	lda polyNum
	stz sa1tmp+2
	tax

	IramDrawPixelLoop:
		rep #$31
		lda [polyPtr],y	;get poly data from rom, no use copying to iram first
		sta col
		iny
		lda [polyPtr],y
		sta poly.1.x
		iny
		iny
		lda [polyPtr],y
		sta poly.2.x
		iny
		iny
		lda [polyPtr],y
		sta poly.3.x
		iny
		iny
		phy
		jsr Sa1DrawPoly-Sa1CodeStart+IramCodeDummy
		ply
		lda polyNum
		lda sa1tmp+2
		inc a
		sta sa1tmp+2
		cmp polyNum
		bcc IramDrawPixelLoop

	rep #$31
	lda.w retPalLenBuff
	sta.w retPalLen
	lda.w retPalPtrBuff
	sta.w retPalPtr
	lda.w retPalPtrBuff+1
	sta.w retPalPtr+1

	lda.w currFrameBuff
	sta.w retGfxPtr
	lda.w currFrameBuff+1
	sta.w retGfxPtr+1

	sep #$20
	lda # SCNT_SNES_CPU_IRQ			;trigger irq sa1->snes.
	sta.l SCNT

	lda #DCNT_DMA_ENABLE | DCNT_PRIORITY | DCNT_DMA_MODE | DCNT_CHARCONV_MODE | DCNT_DMA_DESTINATION | DCNT_DMA_SOURCE_BWRAM	;set dma mode to bw-ram->i-ram char1 conversion
	sta.l DCNT

	brl Sa1WaitFrame

Sa1EmptyHandler:
	rti

Sa1DrawLine:
	sep #$20
	lda zpB.march
	bmi Sa1DrawLineLeftMarchYLoop
	;march X
Sa1DrawLineLeftMarchXLoop:
	lda zpB.dir
	bmi Sa1DrawLineLeftDirRight
		dec zpB.posx					;go left
		bra Sa1DrawLineLeftDirLeft

Sa1DrawLineLeftDirRight:
	inc zpB.posx
Sa1DrawLineLeftDirLeft:
		lda zpB.dy
		clc
		adc zpB.countr					;increment y-div-counter.
		bcs Sa1DrawLineLeftOverflow
		cmp zpB.dx 
		bcc Sa1DrawLineLeftNoOver

		Sa1DrawLineLeftOverflow:
			inc zpB.posy					;always march down
			sec									;update y-div-counter with remainder
			sbc zpB.dx
			sta zpB.countr
			lda zpB.posy
			cmp zpB.endy
			beq Sa1DrawLineLeftDone	;done if target point reached
			
			rep #$31
			rts

	Sa1DrawLineLeftNoOver:
		sta zpB.countr					;loop until next y-step
		bra Sa1DrawLineLeftMarchXLoop

Sa1DrawLineLeftDone:
	inc zpB.posy
	rep #$31
	sec
	rts

Sa1DrawLineLeftMarchYLoop:
	inc zpB.posy
	lda zpB.posy
	cmp zpB.endy
	beq Sa1DrawLineLeftDone	;done if target point reached

		lda zpB.dx
		clc
		adc zpB.countr					;increment y-div-counter.
		bcs Sa1DrawLineLeftYOverflow
		cmp zpB.dy 
		bcc Sa1DrawLineLeftYNoOver

		Sa1DrawLineLeftYOverflow:
			sec									;update y-div-counter with remainder
			sbc zpB.dy
			sta zpB.countr
			lda zpB.dir
			bmi Sa1DrawLineLeftYDirRight
				dec zpB.posx					;go left
				bra Sa1DrawLineLeftYDirLeft
		Sa1DrawLineLeftYDirRight:
			inc zpB.posx
		Sa1DrawLineLeftYDirLeft:
			rep #$31
			rts

	Sa1DrawLineLeftYNoOver:
		sta zpB.countr					;loop until next y-step
		rep #$31

		rts

SkipPolyTop:
SkipPoly:
	pld
	rts

PolyRenderLeftDone:
	pld
	rts

Sa1DrawPoly:
;draw poly:
/*polys always have 3 vertices, sorted by their ordinates(lowest first)
first, we write all right/left edges into an array, then we fill the poly according to that
comparing 2.x and 3.x yields which of the two forms the left and which forms the right edge*/
	phd
	sep #$20
	stz polyTopBot
	lda poly.1.y
	cmp	poly.3.y
	beq SkipPoly	;skip poly if height=0

		rep #$31
		lda.w #re+sa1IramDp
		sta.w first.lin
		lda.w #le+sa1IramDp
		sta.w second.lin

		sep #$20
		stz polyTopBot
		lda poly.2.y
		cmp poly.3.y
		bne PolyRenderDontSkipLast
			inc poly.3.y

	PolyRenderDontSkipLast:
		cmp poly.1.y
		bne PolyRenderDontSkipFirst
			dec poly.1.y	;hack, might cause problems

	PolyRenderDontSkipFirst:
		rep #$31
		lda poly.1.x
		sta.w sourceVert
		lda poly.2.x
		sta.w targetVert
		
	PolyRenderSkipFirst:
		lda.w first.lin	;#le+sa1IramDp
		tcd
		jsr Sa1SetupLine-Sa1CodeStart+IramCodeDummy

		lda.w #sa1IramDp
		tcd
		lda poly.1.x
		sta.w sourceVert
		lda poly.3.x
		sta.w targetVert
		lda.w second.lin ;#re+sa1IramDp
		tcd
		jsr Sa1SetupLine-Sa1CodeStart+IramCodeDummy

	PolyTop2LeftMarchY:
		rep #$31
		lda.w first.lin	; #le+sa1IramDp
		tcd
		jsr Sa1DrawLine-Sa1CodeStart+IramCodeDummy
		bcc PolyTop2LeftDontFetchNextVert

			;setup second poly part or exit
			lda.w #sa1IramDp
			tcd
			lda polyTopBot	;done rendering poly?
			and #$ff
			bne PolyRenderLeftDone
								
			inc polyTopBot
			lda poly.2.x
			sta.w sourceVert
			lda poly.3.x
			sta.w targetVert
			lda.w first.lin ; #le+sa1IramDp
			tcd
			jsr Sa1SetupLine-Sa1CodeStart+IramCodeDummy

	PolyTop2LeftDontFetchNextVert:
		lda.w second.lin ;#re+sa1IramDp
		tcd
		jsr Sa1DrawLine-Sa1CodeStart+IramCodeDummy

		pea sa1IramDp
		pld

		sep #$20
		ldx re.posx
		lda le.posx
		sec
		sbc re.posx
		beq PolyTop2LeftMarchY
		bcs DrawSpanFastRev
			ldx le.posx
			lda re.posx
			sec
			sbc le.posx

	DrawSpanFastRev:
		rep #$31
		and #$ff
		inc a
		cmp #$ff
		bcc DrawSpanNoXMax
			lda #$ff
	DrawSpanNoXMax:
		tay

	DrawSpanNoDmaWait:
		lda.w CFR	;check dma end	;don't do dma fill if last one didn't finish yet
		bit #CFR_IRQ_END
		beq DrawSpanNoDma
		
			sep #$20
			stz.w CFR		;clear dma flag (and all irq msgs from snes)				
			rep #$31
			sty.w DTC
			lda #DCNT_DMA_ENABLE | DCNT_DMA_DESTINATION	;dma-clear bw-ram framebuffer
			sta.w DCNT
			
			lda col-1
			and #$ff00
			sta.w SDA
			stx.w DDA
			
			sep #$20
			lda #:DmaFillSrc	;source
			sta.w SDA+2

			lda.w currFrameBuff+2
			sta.w DDA+2
			brl PolyTop2LeftMarchY

	DrawSpanNoDma:
		.ACCU 16
		tya

		eor #$ff
		inc a
		sta fillBuff
		asl a
		clc
		adc fillBuff
		clc
		adc.w #FastFiller-Sa1CodeStart+IramCodeDummy
		sta.w FastFiller-Sa1CodeStart+IramCodeDummy+1

		sep #$20
		phb
		lda #BWRAM
		pha
		plb
		lda col

		inc a

	FastFiller:
		jmp	0
		.rept 256 
		FILLMACRO
		.endr
	
		plb
		brl PolyTop2LeftMarchY	;loop till line has been drawn

;draw vertex pixels:
Sa1DrawVertices:
	rep #$31
	sep #$20
	lda #$ff	
	ldx poly.1.x
	sta.l frameBuff1,x
	ldx poly.2.x
	sta.l frameBuff1,x
	ldx poly.3.x
	sta.l frameBuff1,x
	rts

DrawSpanNoYMatch:
	rep #$31
	lda #$baad
DrawSpan2Done:
	plp
	rts

;sourceVert targetVert zpB.
Sa1SetupLine:
	sep #$20
	lda.w targetVert.y
	sec
	sbc.w sourceVert.y
	lsr a
	sta zpB.countr			
	rep #$31
	lda #$8080
	sta zpB.march
	lda.w sourceVert.x
	sta zpB.startx				
	sta zpB.posx
	lda.w targetVert.x
	sta zpB.endx
	sep #$21
	sbc.w sourceVert.x
	bcs Sa1SetupLineDxOk
		stz zpB.dir		;result was negative, try other way round
		lda.w sourceVert.x
		sec
		sbc.w targetVert.x

Sa1SetupLineDxOk:
	sta zpB.dx
	
	lda.w targetVert.y
	sec
	sbc.w sourceVert.y	;no need to check here, we always march from top to bottom
	sta zpB.dy
	cmp zpB.dx
	bcs Sa1SetupLineMarchY
		stz zpB.march
		lda zpB.dx
		lsr a
		sta zpB.countr

Sa1SetupLineMarchY:
	rep #$31
	rts

Sa1CodeEnd:

.ends


;a waste of memory, but since sa1 normal dma has no fixed mode, this is the fastest way to clear bw-ram
.section "frame buffer clearer" superfree
FrameBufferClearer:
	.rept $8000
		.db 0
	.endr
.ends

;dma polyfill source. needed because no fixed dma mode available on sa1
.section "dma fill src" superfree
DmaFillSrc:
	.rept 256
		DMAFILL
	.endr
.ends

