	.include "routines/h/memoryclear.h"
.section "memclear"

ClearRegisters:
	php
	rep #$31
	sep #$20
	ldx #OBJSEL

MemClearLoop1:		;regs OBJSEL-BG34NBA
		stz.w $00,X		;set Sprite,Character,Tile sizes to lowest, and set addresses to $0000
		inx
		cpx #BG1HOFS
		bne MemClearLoop1

MemClearLoop2:		;regs BG1HOFS-BG4VOFS
		stz.w $00,X		;Set all BG scroll values to $0000
		stz.w $00,X
		inx
		cpx #VMAIN
		bne MemClearLoop2
	
	lda #VMAIN_INCREMENT_MODE		;reg VMAIN
	sta VMAIN		; Initialize VRAM transfer mode to word-access, increment by 1
	stz VMADDL
	stz VMADDH		;VRAM address = $0000
	stz M7SEL		;clear Mode7 setting
	ldx #M7A

MemClearLoop3:		;regs M7A-M7Y
		stz.w $00,X		;clear out the Mode7 matrix values
		stz.w $00,X
		inx
		cpx #CGADD
		bne MemClearLoop3
	ldx #W12SEL

MemClearLoop4:			;regs W12SEL-SETINI
		stz.w $00,X		;turn off windows, main screens, sub screens, color addition,
		inx				;fixed color = $00, no super-impose (external synchronization),
		cpx #MPYL		;no interlaced mode, normal resolution
		bne MemClearLoop4
	plp
	rts
	
ClearWRAM:
	phx
	phy
	php
	phb
	sep #$20
	pha
	lda.b #REGS
	pha
	plb
	pla

;don't use dma transfer from rom if executing from wram
.if BSL == RAM2
	REP #$31		; mem/A = 8 bit, X/Y = 16 bit   
	and.w #$7	;calculate adress of clear pattern word(8 entries max)
	asl a
	adc.w #ClearWramBytePatterns
	sta tmp
	SEP #$20

	lda #:ClearWramBytePatterns
	sta tmp+2

	rep #$31
	tya
	and.w #$fffe         ;word-align counter
	tay
	phy
	ldy.w #0
	lda [tmp],y
	ply

ClearWRAMLoop:
		sta.l RAM << 16,x
		inx
		inx
		dey
		dey
		bne ClearWRAMLoop

.else
	rep #$31		; mem/A = 8 bit, X/Y = 16 bit
	and.w #$7	;calculate adress of clear pattern word(8 entries max)
	asl a
	adc.w #ClearWramBytePatterns
	sta.w DMASRC1L	;dma source

	sep #$20
	lda.b #:ClearWramBytePatterns
	sta DMASRC1B         ;Set source bank to $00

	stx.w WMADDL	;store target wram adress in bank $7e
	stz.w WMADDH	;bank $7e

	lda #DMAP_FIXED_TRANSFER | DMAP_1_REG_WRITE_TWICE
	sta DMAP1         ;Set DMA mode to fixed source, WORD to WMDATA
	lda #WMDATA & $ff
	sta DMADEST1

	sty.w DMALEN1L         ;Set transfer size
	lda #DMA_CHANNEL1_ENABLE
	sta MDMAEN         ;Initiate transfer

.endif
	plb
	plp
	ply
	plx
	rts

;byte patterns to clear wram with.(8 entries max)   
ClearWramBytePatterns:
	.dw 0			;zeros
	.dw $eaea		;nops
	.dw $2400		;bg3 tilemap clear word
	.dw $00c9		;oam buffer
	.dw $2907		;bg1 tilemap clear

;clears whole vram. irqs must be disabled, screen blanked.   
ClearVRAM:
	pha
	phx
	php
	phb
	rep #$30		; mem/A = 8 bit, X/Y = 16 bit
	sep #$20
	lda #REGS
	pha
	plb   
	lda #VMAIN_INCREMENT_MODE
	sta VMAIN         ;Set VRAM port to word access
	lda #DMAP_FIXED_TRANSFER | DMAP_2_REG_WRITE_ONCE
	sta DMAP0         ;Set DMA mode to fixed source, WORD to VMDATAL/VMDATAH
	lda #VMDATAL & $ff
	sta DMADEST0
	ldx #$0000
	stx VMADDL         ;Set VRAM port address to $0000
	ldx #VramClearByte
	stx DMASRC0L         ;Set source address to $xx:0000
	lda #:VramClearByte
	sta DMASRC0B         ;Set source bank to $00
	ldx #$FFFF
	stx DMALEN0L         ;Set transfer size to 64k-1 bytes
	lda #DMA_CHANNEL0_ENABLE
	sta MDMAEN         ;Initiate transfer
	stz VMDATAH         ;clear the last byte of the VRAM
	plb
	plp
	plx
	pla
	rts

VramClearByte:
	.db 0

;copy random data to wram
;in:	tmp0-2 - source pointer
;			x							- wram bank $7e target
;			y							- transfer length							
DmaToWRAM:
	php
	phb
	sep #$20
	pha
	lda #REGS
	pha
	plb
	pla
	rep #$31		; mem/A = 8 bit, X/Y = 16 bit
	stz tmp       ;16bit counter
	sep #$20

DMAtoWRAMLoop:
		phy
		ldy tmp
		lda [tmp],y
		iny
		sty tmp
		ply
		sta.l RAM << 16,x
		inx
		dey
		bne DMAtoWRAMLoop
	plb
	plp
	rts

;uploads 1 hirom bank to ram bank $7f  
ROMToWRAM:
	php
	phb
	sep #$20
	pha
	lda #REGS
	pha
	plb
	pla

	rep #$31		; mem/A = 8 bit, X/Y = 16 bit
	stz DMALEN1L         ;Set transfer size
	stz DMASRC1L	;dma source
	stz WMADDL	;$7f0000

	sep #$20
	lda #ROM
	sta DMASRC1B         ;Set source bank to $00

	lda.b #1
	sta.w WMADDH	;bank $7e

	lda #DMAP_1_REG_WRITE_TWICE
	sta DMAP1         ;Set DMA mode to inc source, WORD to WMDATA
	lda #WMDATA & $ff
	sta DMADEST1

	lda #DMA_CHANNEL1_ENABLE
	sta MDMAEN         ;Initiate transfer
	jml ROMToWRAMJumper

ROMToWRAMJumper:
	plb
	plp
	rts

.ends

