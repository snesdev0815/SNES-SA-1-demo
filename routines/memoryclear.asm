	.include "routines/h/memoryclear.h"
.section "memclear"
/*
;partially clears wram to predefined value
;in: 	a,8bit: number of word to clear memory with. 
;		x,16bit: target word adress in wram bank $7e
;		y,16bit: transfer length
;how to use:
	rep #$31
	sep #$20
	lda.b #0		;clear word: $0000
	ldy.w #$200
	ldx.w #PaletteBuffer&$ffff
	jsr ClearWRAM
*/	

ClearRegisters:
	php
	rep #$31
	sep #$20
	LDX #$2101

MemClearLoop1:		;regs $2101-$210C
	STZ.w $00,X		;set Sprite,Character,Tile sizes to lowest, and set addresses to $0000
	INX
	CPX #$210D
	BNE MemClearLoop1

MemClearLoop2:		;regs $210D-$2114
	STZ.w $00,X		;Set all BG scroll values to $0000
	STZ.w $00,X
	INX
	CPX #$2115
	BNE MemClearLoop2
	
	LDA #$80		;reg $2115
	STA $2115		; Initialize VRAM transfer mode to word-access, increment by 1
	STZ $2116		;regs $2117-$2117
	STZ $2117		;VRAM address = $0000
	STZ $211A		;clear Mode7 setting
	LDX #$211B

MemClearLoop3:		;regs $211B-$2120
	STZ.w $00,X		;clear out the Mode7 matrix values
	STZ.w $00,X
	INX
	CPX #$2121
	BNE MemClearLoop3
	LDX #$2123

MemClearLoop4:		;regs $2123-$2133
	STZ.w $00,X		;turn off windows, main screens, sub screens, color addition,
	INX			;fixed color = $00, no super-impose (external synchronization),
	CPX #$2134		;no interlaced mode, normal resolution
	BNE MemClearLoop4
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
   sta.l $7e0000,x
   inx
   inx
   dey
   dey
   bne ClearWRAMLoop

.else
   REP #$31		; mem/A = 8 bit, X/Y = 16 bit
   
   and.w #$7	;calculate adress of clear pattern word(8 entries max)
   asl a
   adc.w #ClearWramBytePatterns
   sta.w $4312	;dma source
   
   SEP #$20

   lda.b #:ClearWramBytePatterns
   STA $4314         ;Set source bank to $00
   
   stx.w $2181	;store target wram adress in bank $7e
   stz.w $2183	;bank $7e

   LDX #$800a
   STX $4310         ;Set DMA mode to fixed source, WORD to $2180

   sty.w $4315         ;Set transfer size
   LDA #$02
   STA $420B         ;Initiate transfer

.endif
   plb
   plp
   ply
   plx
   RTS

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
   REP #$30		; mem/A = 8 bit, X/Y = 16 bit
   SEP #$20
   lda #REGS
   pha
   plb   
   LDA #$80
   STA $2115         ;Set VRAM port to word access
   LDX #$1809
   STX $4300         ;Set DMA mode to fixed source, WORD to $2118/9
   LDX #$0000
   STX $2116         ;Set VRAM port address to $0000
   ldx #VramClearByte
   STX $4302         ;Set source address to $xx:0000
   LDA #:VramClearByte
   STA $4304         ;Set source bank to $00
   LDX #$FFFF
   STX $4305         ;Set transfer size to 64k-1 bytes
   LDA #$01
   STA $420B         ;Initiate transfer
   STZ $2119         ;clear the last byte of the VRAM
   plb
   plp
   plx
   pla
   RTS

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
   lda #$80
   pha
   plb
   pla
   REP #$31		; mem/A = 8 bit, X/Y = 16 bit
   stz tmp       ;16bit counter
    sep #$20

DMAtoWRAMLoop:
    phy
    ldy tmp
    lda [tmp],y
    iny
    sty tmp
    ply
    sta.l $7e0000,x
    inx
    dey
    bne DMAtoWRAMLoop

   plb
   plp
   RTS

;uploads 1 hirom bank to ram bank $7f  
ROMToWRAM:
   php
   phb
   sep #$20
   pha
   lda #$80
   pha
   plb
   pla
   REP #$31		; mem/A = 8 bit, X/Y = 16 bit
   
	stz $4315         ;Set transfer size
   stz $4312	;dma source
   stz $2181	;$7f0000
   SEP #$20

   lda #ROM
   STA $4314         ;Set source bank to $00
   
   lda.b #1
   sta.w $2183	;bank $7e

   LDX #$8002
   STX $4310         ;Set DMA mode to inc source, WORD to $2180

   
   LDA #$02
   STA $420B         ;Initiate transfer
   jml ROMToWRAMJumper
   
ROMToWRAMJumper:
   plb
   plp
   RTS   
.ends
   