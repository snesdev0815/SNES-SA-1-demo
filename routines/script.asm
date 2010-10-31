.include "routines/h/script.h"
.section "script class"
/*
@TODO
scripts should run predominantly on macros
have:
-a dedicated script zp space for obj hash pointers
-a script kill routine that acts as garbage collector and tries to delete all objs that are found in script obj hash pointers(except for sigletons)
-an obj-flag that indicates persistency(unkillable by kill routine; nmi/spc handler etc, basically most singletons)
-all luts should be placed in header files, superfree where possible
*/
;input: parameter a, number of script to run

;hacky, should be define, but wla is too stupid to resolve this as a define
NumOfScripts:
	.dw (scriptLUTEnd-scriptLUT)/2

init_Script:
	rep #$31
	and #$ff
	cmp.l NumOfScripts
	bcc initScriptNotInvalid

		pea E_BadScript
		jsr PrintException

initScriptNotInvalid:
	sta currScript
	asl a
	tax
	lda.l scriptLUT,x
	sta currPC
	php
	phb
	pla
	and.w #%1111101111111111	;exclude irq flag
	sta buffFlags

	jsr initHashPointers
	
	bra play_Script	;need to stay on same stack-tier here


collectGarbage:
	php
	rep #$31
	ldy #NumOfHashptr
	ldx #hashPtr

	collectGarbageLoop:		;kill all objects that were instanciated in current script 
		lda #0
		phy
		phx
		ldy #kill_Rng.MTD
		jsr dispatchObjMethod
		plx
		ply
		txa
		clc
		adc #_sizeof_oopObjHash
		tax
		dey
		bne collectGarbageLoop
	
	plp
	rts

;init obj hash pointers, mark as "empty, pointing to no obj"
initHashPointers:
	php
	rep #$31
	ldy #NumOfHashptr
	ldx #0

	initHashPointersLoop:
		lda #oopCreateNoPtr
		sta hashPtr.1.pntr,x
		txa
		clc
		adc #_sizeof_oopObjHash
		tax
		dey
		bne initHashPointersLoop 
	plp
	rts

play_Script:
	sep #$20
	lda #$22
	sta.l SelfModJSL
	lda #BSL
	sta.l SelfModJSL+3
	lda #$6b
	sta.l SelfModJSL+4

	rep #$31	
	tsc	;save script execution level
	sec
	sbc #6
	sta buffStack

	php
	php
	pla
	and.w #%100	;preserve irq flag
	ora buffFlags
	pha
	lda currPC
	sta.l SelfModJSL+1
	
	lda buffA
	ldx buffX
	ldy buffY
	plb
	plp
	
	jsl SelfModJSL
	
	rts
	
SavePC:
	php
	phb
	rep #$31
	sta buffA
	pla
	and.w #%1111101111111111	;exclude irq flag
	sta buffFlags
	lda 1,s	;save adress before savePC was called
	dec a
	dec a
	sta currPC
	stx buffX
	sty buffY
	rts

WaitReturn:
	rtl

;script obj kill routine, for external calls
kill_Script:
	rep #$31
	jsr collectGarbage
	lda #OBJR_kill	;lastly, kill script instance itself
	sta 3,s	
	rts

;script termination routine, called from within script
terminateScript:
	rep #$31
	tsc
	inc a	;this is a subroutine
	inc a
	cmp buffStack
	beq terminateScriptStackOk
		pea E_ScriptStackTrash
		jsr PrintException
		stp

terminateScriptStackOk:
	jsr collectGarbage
	tsc
	clc
	adc #8	;two RTLs from script, two RTS from script dispatcher
	tcs
	lda #OBJR_kill	;lastly, kill script instance itself
	sta 3,s	
	rts

.ends
