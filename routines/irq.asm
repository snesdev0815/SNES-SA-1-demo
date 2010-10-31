.include "routines/h/irq.h"

.section "irq stuff"

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
	stz.w WRIO			;clear iobit
	stz.w NMITIMEN	;no nmis during irq. I can't stand this shit anymore.

	jsr Sa1IrqHandler
	bcs detectedUnhandledIrq
		
		sep #$20
		lda #NMITIMEN_NMI_ENABLE
		sta.w NMITIMEN
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

