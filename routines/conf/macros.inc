
;dispatch obj method. parameters: \1 pointer to obj hash \2 method .ptr to execute \3 parameters(optional)
.macro CALL
.if NARGS > 3
	.fail
.endif
.if NARGS < 2
	.fail
.endif

ldx #\2
ldy #\1
.ifdefm \3
lda #\3
.endif
jsr dispatchObjMethod
.endm

;create reference pointer to routine so that it can be properly be jumped at by jsr(0),x. only used for callbacks so far. should be used inside seperate callback section
.macro REGISTER_CALLBACK
.if NARGS != 1
	.fail
.endif
\1.CLB:
.dw \1
.endm

;create instance of class. parameters: \1 class pointer \2 pointer to obj hash \3 parameter to pass to class init routine(optional)
.macro NEW
.if NARGS > 3
	.fail
.endif
.if NARGS < 2
	.fail
.endif

lda #\1
ldx #\2
.ifdefm \3
ldy #\3
.endif
jsr createOopObj
.endm

;terminate script, do some garbage collection aswell
.macro DIE
	jsr terminateScript
	rtl
.endm

;terminate call, don´t do any garbage collection
.macro RETURN
	rep #$31
	tsc
	clc
	adc #7	;two RTLs from script, one RTS from script dispatcher
	tcs
	rtl
.endm

;wait for equation(two variables) to become true. If not true, save current PC and return, then try again next frame
.macro WAIT
.if NARGS != 3
	.fail
.endif
	jsr SavePC
	lda.w \1
	cmp.w \3

.if ">" == \2
	bcc Wait\@
	
WaitOkStep\@:
	bne WaitOk\@
.endif

.if ">=" == \2
	bcs WaitOk\@
.endif

.if "<=" == \2
	beq WaitOk\@
	bcc WaitOk\@
.endif

.if "<" == \2
	bcc WaitOk\@
.endif

.if "==" == \2
	beq WaitOk\@
.endif

.if "!=" == \2
	bne WaitOk\@
.endif

Wait\@:
	rtl
	
WaitOk\@:
.endm

;yet another hack because wla is too fucking, fucking stupid to differentiate between immediate and adress values supplied as macro arguments
;no idea how long I can still take this crap...
;wait for equation(two variables) to become true. If not true, save current PC and return, then try again next frame
.macro WAIT_IMMEDIATE
.if NARGS != 3
	.fail
.endif
	jsr SavePC
	lda.w \1
	cmp.w #\3

.if ">" == \2
	bcc WaitI\@
	
WaitIOkStep\@:
	bne WaitIOk\@
.endif

.if ">=" == \2
	bcs WaitIOk\@
.endif

.if "<=" == \2
	beq WaitIOk\@
	bcc WaitIOk\@
.endif

.if "<" == \2
	bcc WaitIOk\@
.endif

.if "==" == \2
	beq WaitIOk\@
.endif

.if "!=" == \2
	bne WaitIOk\@
.endif

WaitI\@:
	rtl
	
WaitIOk\@:
.endm

;1 parameter, song file
.macro SONG
.if NARGS != 1
	.fail
.endif

\1:
	.dw End\1-\1
	;.dw 0
	.incbin "data/songs/\1.bgm"
End\1:
.endm

;creates a 3-byte pointer and a definition of pointernumber in table: label.PTR
;params: 1=pointer table base 2=target label
.macro PTRLONG
PtrLong\1\@:
	.dw \2
	.db :\2 
.ifndef \2.PTR	;define only once 
	.define "\2.PTR" (PtrLong\1\@ - \1 )/3
	.export \2.PTR
.endif
.endm

;creates a 2-byte pointer and a definition of pointernumber in table: label.PTR
;params: 1=pointer table base 2=target label
.macro PTRNORM
PtrNorm\1\@:
	.dw \2 
	.define "\2.PTR" (PtrNorm\1\@ - \1 )/2
	.export \2.PTR
.endm


;creates oop object. parameters: 1=class name  2=flags 3=zp-bufferlength 4-8: additional routines ;4=init 5=play 6=kill 7,8=additional routines
;object id = \1.OBJID
.macro OOPOBJ
	.if NARGS < 3
		.fail
	.endif
\1.CLS:
relative\1:
	.db \2
	.db OBJID.\1
	.db \3
	.db NARGS
	.db T_CLSS_\1-relative\1
	
	.define init_\1.MTD 0
	.export init_\1.MTD
	.dw init_\1
	.db T_CLSS_init_\1-relative\1

	.define play_\1.MTD 1
	.export play_\1.MTD
	.dw play_\1
	.db T_CLSS_play_\1-relative\1

	.define kill_\1.MTD 2
	.export kill_\1.MTD
	.dw kill_\1
	.db T_CLSS_kill_\1-relative\1

	.ifdefm \4
		.define \1.\4.MTD 3
		.export \1.\4.MTD
		.dw \4
		.db T_CLSS_\4-relative\1
	.endif

	
	.ifdefm \5
		.define \1.\5.MTD 4
		.export \1.\5.MTD
		.dw \5
		.db T_CLSS_\5-relative\1
	.endif
	
	.ifdefm \6
		.define \1.\6.MTD 5
		.export \1.\6.MTD
		.dw \6
		.db T_CLSS_\6-relative\1
	.endif

	.ifdefm \7
		.define \1.\7.MTD 6
		.export \1.\7.MTD
		.dw \7
		.db T_CLSS_\7-relative\1
	.endif

	.ifdefm \8
		.define \1.\8.MTD 7
		.export \1.\8.MTD
		.dw \8
		.db T_CLSS_\8-relative\1
	.endif

T_CLSS_\1:
	.db "\1",0

T_CLSS_init_\1:
	.db "init_\1",0

T_CLSS_play_\1:
	.db "play_\1",0

T_CLSS_kill_\1:
	.db "kill_\1",0

	.ifdefm \4
T_CLSS_\4:
	.db "\4",0
	.endif

	.ifdefm \5
T_CLSS_\5:
	.db "\5",0
	.endif

	.ifdefm \6
T_CLSS_\6:
	.db "\6",0
	.endif

	.ifdefm \7
T_CLSS_\7:
	.db "\7",0
	.endif

	.ifdefm \8
T_CLSS_\8:
	.db "\8",0
	.endif

.endm

;parameters: 1=file label 2=file path 3=read length
;returns \1.LEN filelength
.macro FILEINC
\1:
	.ifdefm \3
		.incbin \2 read \3 fsize \1.LEN
	.else
		.incbin \2 fsize \1.LEN
	.endif
.endm

