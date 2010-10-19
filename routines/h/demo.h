.include "routines/conf/config.inc"

;zp-vars
.enum 0
_tmp ds 8
currFrm dw
currScene dw
;currSceneFrameNum dw
rendererPTR INSTANCEOF oopObjHash
soundPTR INSTANCEOF oopObjHash
zpLen ds 0
.ende

.define sceneNumber 17


.base BSL
.bank 0 slot 0

.section "demoDat"
	OOPOBJ Demo $81 zpLen
.ends

;callbacks are just pointers to the actual callback routine because jsr(0),x jumps to pointer, not direct adress
.section "demoCallbacks"
	REGISTER_CALLBACK spcStimulusTrigger
.ends
