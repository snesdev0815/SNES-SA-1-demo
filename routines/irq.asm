.include "routines/h/irq.h"

.section "irq stuff"
/*
Sa1NoCharConvTransfer:

	lda.w $4211			;clear irq flag
	rep #$39
	plb
	pld
	ply
	plx
	pla
	rti
*/

IrqLoader:
;switch to 16bit a/x in order to preserve everything and not just 8bit of the accu
	rep #$39		
	pha
	phx
	phy
	phd
	phb	
	lda.w #VARS
	tcd
	lda.l irqCount
	inc a
	sta.l irqCount
	sep #$20
	lda.b #REGS
	pha
	plb
	stz.w $4201			;clear iobit
	stz.w $4200	;no nmis during irq. I can't stand this shit anymore.
/*
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	lda.w $4211			;clear irq flag, no need to clear this if cpu h/v counters are never irq sources
*/	
	jsr Sa1IrqHandler
	bcs detectedUnhandledIrq
		
		sep #$20
		lda #$80
		sta.w $4200
		rep #$39
	
		plb
		pld
		ply
		plx
		pla
		rti

detectedUnhandledIrq:
	pea E_UnhandledIrq						;print error if no irq occurs for some time
	jsr PrintException
	stp
	
.ends


		
