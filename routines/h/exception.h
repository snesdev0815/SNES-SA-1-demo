.include "routines/conf/config.inc"


;defines
.define vramBase	0
.define errStrt	10

.enum errStrt export
E_ObjLstFull	db
E_ObjRamFull	db
E_StackTrash	db
E_Brk					db
E_StackOver		db
E_Sa1IramCode			db	;unable to copy stuff to sa1 iram buffer(needs to be write-enabled)
E_Sa1IramClear	db
E_Sa1Test db
E_Sa1NoIrq db
E_Todo db
E_SpcTimeout db
E_ObjBadHash	db
E_ObjBadMethod db
E_BadScript db
E_StackUnder db
E_Cop db
E_ScriptStackTrash db
E_UnhandledIrq	db
E_Sa1BWramClear db
E_Sa1NoBWram db
E_Sa1BWramToSmall db
E_Sa1DoubleIrq	db
E_SpcNoStimulusCallback	db

.ende

;data structures

;ram buffers
.base RAM
;this is where exception handler stores temp vars for exception display
.ramsection "exception cpu status buffr" bank 0 slot 2
excStack		dw
excA				dw
excY				dw
excX				dw
excDp				dw
excDb				db
excPb				db
excFlags		db
excPc				dw
excErr			dw
.ends


;data includes
.base BSL
.section "exception font tiles" superfree
	FILEINC ExcFontTiles "data/font/fixed8x8.pic"
.ends

.section "exception font pal" superfree
	FILEINC ExcFontPal "data/font/fixed8x8.clr" 8
.ends

.section "exception string command lut"
	ExcStrCmdLut:
		PTRNORM ExcStrCmdLut SUB_TC_end
		PTRNORM ExcStrCmdLut SUB_TC_sub
		PTRNORM ExcStrCmdLut SUB_TC_iSub
		PTRNORM ExcStrCmdLut SUB_TC_dSub
		PTRNORM ExcStrCmdLut SUB_TC_diSub
		PTRNORM ExcStrCmdLut SUB_TC_pos
		PTRNORM ExcStrCmdLut SUB_TC_brk
		PTRNORM ExcStrCmdLut SUB_TC_hToS
.ends

.section "err-msg string LUT" superfree
	ExcErrMsgStrLut:
		.db T_EXCP_E_ObjLstFull.PTR
		.db T_EXCP_E_ObjRamFull.PTR
		.db T_EXCP_E_StackTrash.PTR
		.db T_EXCP_E_Brk.PTR
		.db T_EXCP_E_StackOver.PTR
		.db T_EXCP_E_Sa1IramCode.PTR
		.db T_EXCP_E_Sa1IramClear.PTR
		.db T_EXCP_Sa1Test.PTR
		.db T_EXCP_Sa1NoIrq.PTR
		.db T_EXCP_Todo.PTR
		.db T_EXCP_SpcTimeout.PTR
		.db T_EXCP_ObjBadHash.PTR
		.db T_EXCP_ObjBadMethod.PTR
		.db T_EXCP_BadScript.PTR
		.db T_EXCP_StackUnder.PTR
		.db T_EXCP_E_Cop.PTR
		.db T_EXCP_E_ScriptStackTrash.PTR
		.db T_EXCP_E_UnhandledIrq.PTR
		.db T_EXCP_E_Sa1BWramClear.PTR
		.db T_EXCP_E_Sa1NoBWram.PTR
		.db T_EXCP_E_Sa1BWramToSmall.PTR
		.db T_EXCP_E_Sa1DoubleIrq.PTR
		.db T_EXCP_E_SpcNoStimulusCallback.PTR

.ends

