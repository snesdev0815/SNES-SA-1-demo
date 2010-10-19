	.include "routines/h/textstrings.h"
	
.section "textstrings" superfree

T_EXCP_exception:
	.db TC_pos
	.dw $42
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db "an exception has occured!",TC_brk
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db "error-message:"
	.db TC_pos
	.dw $182
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db TC_sub
	.dw T_EXCP_cpuInfo.PTR
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db TC_sub
	.dw T_EXCP_sa1Info.PTR
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db TC_sub
	.dw T_EXCP_irqInfo.PTR
	.db TC_sub
	.dw T_EXCP_starLine.PTR
	.db TC_end
	
T_EXCP_starLine:
	.db "****************************",TC_brk,TC_end
	
T_EXCP_cpuInfo:
	.db "cpu status:",TC_brk
	.db "a:   ",TC_hToS
	.dw excA
	.db :excA,
	.db 2," x:   ",TC_hToS
	.dw excX
	.db :excX,
	.db 2," y: ",TC_hToS
	.dw excY
	.db :excY,
	.db 2,TC_brk,"flag:  ",TC_hToS
	.dw excFlags
	.db :excFlags,
	.db 1," stck:",TC_hToS
	.dw excStack
	.db :excStack,
	.db 2," pc:",TC_hToS
	.dw excPc
	.db :excPc,
	.db 2,TC_brk,"dp:  ",TC_hToS
	.dw excDp
	.db :excDp,
	.db 2," pb:    ",TC_hToS
	.dw excPb
	.db :excPb,
	.db 1," db:  ",TC_hToS
	.dw excDb
	.db :excDb,
	.db 1,TC_brk,TC_end

T_EXCP_sa1Info:
	.db "SA-1 status:",TC_brk
	.db "cp:  ",TC_hToS
	.dw sa1CP
	.db :sa1CP,2
	.db " flags: ",TC_hToS
	.dw $2300
	.db 0,2
	.db TC_brk,"ver: ",TC_hToS
	.dw $230e
	.db 0,2
	.db " frame: ",TC_hToS
	.dw cmdFrame
	.db cmdFrame>>16,2	
	.db TC_brk,TC_end

T_EXCP_irqInfo:
	.db "IRQ status:",TC_brk
	.db "NMIs:   ",TC_hToS
	.dw FrameCounter
	.db FrameCounter>>16,2
	.db " IRQs:   ",TC_hToS
	.dw irqCount
	.db irqCount>>16,2
	.db TC_brk,"chrIRQs:",TC_hToS
	.dw dmaIrqCount
	.db dmaIrqCount>>16,2
	.db " frmIRQs:",TC_hToS
	.dw frameIrqCount
	.db frameIrqCount>>16,2,TC_brk
	.db "framebuffer:",TC_hToS
	.dw frameBuffHistory
	.db frameBuffHistory>>16,3
	.db " irqCp:",TC_hToS
	.dw irqCheckpoint
	.db irqCheckpoint>>16,1,TC_brk
	.db TC_end


T_EXCP_E_StackTrash:
	.db TC_pos
	.dw $102
	.db "Routine ",TC_diSub
	.dw routStr
	.db TC_brk,"of class ",TC_diSub
	.dw classStr
	.db TC_brk,"has trashed the stack.",TC_end

T_EXCP_E_Sa1IramCode:
	.db TC_pos
	.dw $102
	.db "Error while copying",TC_brk,"SA-1 bootcode to I-RAM,",TC_brk,"aborting...",TC_end

T_EXCP_E_Sa1IramClear:
	.db TC_pos
	.dw $102
	.db "Error while clearing",TC_brk,"SA-1 I-RAM, aborting...",TC_end

	
T_EXCP_E_ObjLstFull:
	.db TC_pos
	.dw $102
	.db "No free slot left to create",TC_brk
	.db "instance of class ",TC_diSub
	.dw classStr
	.db ".",TC_end

T_EXCP_E_ObjRamFull:
	.db TC_pos
	.dw $102
	.db "Unable to allocate ram",TC_brk
	.db "for instance of class ",TC_diSub
	.dw classStr
	.db ",",TC_brk,"insufficient memory.",TC_end

T_EXCP_E_Brk:
	.db TC_pos
	.dw $102
	.db "BRK encountered.",TC_brk,TC_sub
	.dw T_EXCP_LastCalled.PTR
	.db TC_end

T_EXCP_E_StackOver:
	.db TC_pos
	.dw $102
	.db "Stack overflow detected.",TC_brk,TC_sub
	.dw T_EXCP_LastCalled.PTR
	.db TC_end


T_EXCP_LastCalled:
	.db "Last called routine was ",TC_brk,TC_diSub
	.dw routStr
	.db " of class ",TC_diSub
	.dw classStr
	.db ".",TC_end

T_EXCP_HexTest:
	.db "hex test:",TC_hToS
	.dw 0
	.db $c0
	.db 16,", lala!",TC_end

T_EXCP_Sa1Test:
	.db TC_pos
	.dw $102
	.db "SA-1 frame test complete.",TC_end

T_EXCP_Sa1NoIrq:
	.db TC_pos
	.dw $102
	.db "SA-1 didn't generate",TC_brk
	.db "char-conversion IRQ.",TC_end

T_EXCP_Todo:
	.db TC_pos
	.dw $102
	.db "TODO:",TC_brk
	.db "Routine needs reworking",TC_end

T_EXCP_SpcTimeout:
	.db TC_pos
	.dw $102
	.db "SPC700 communication",TC_brk
	.db "timeout.",TC_end

T_EXCP_ObjBadHash:
	.db TC_pos
	.dw $102
	.db "Bad object hash encountered",TC_brk
	.db "while dispatching obj method.",TC_end

T_EXCP_ObjBadMethod:
	.db TC_pos
	.dw $102
	.db "Unable to execute non-existant",TC_brk
	.db "method of class",TC_diSub
	.dw classStr
	.db ".",TC_end

T_EXCP_undefined:
	.db "undefined",TC_end

T_EXCP_BadScript:
	.db TC_pos
	.dw $102
	.db "Unable to execute non-existant",TC_brk
	.db "script.",TC_end

T_EXCP_StackUnder:
	.db TC_pos
	.dw $102
	.db "Stack underflow detected.",TC_brk,TC_sub
	.dw T_EXCP_LastCalled.PTR
	.db TC_end

T_EXCP_E_Cop:
	.db TC_pos
	.dw $102
	.db "COP encountered.",TC_brk,TC_sub
	.dw T_EXCP_LastCalled.PTR
	.db TC_end

T_EXCP_E_ScriptStackTrash:
	.db TC_pos
	.dw $102
	.db "A script has trashed the",TC_brk
	.db "stack. Last called routine",TC_brk
	.db "was ",TC_diSub
	.dw routStr
	.db " of class ",TC_brk,TC_diSub
	.dw classStr
	.db ".",TC_end

T_EXCP_E_UnhandledIrq:
	.db TC_pos
	.dw $102
	.db "Unhandled IRQ encountered.",TC_end

T_EXCP_E_Sa1BWramClear:
	.db TC_pos
	.dw $102
	.db "Error while clearing",TC_brk,"SA-1 framebuffer, aborting...",TC_end

T_EXCP_E_Sa1NoBWram:
	.db TC_pos
	.dw $102
	.db "No SA-1 BW-RAM present,",TC_brk,TC_sub
	.dw T_EXCP_Sa1BwramReq.PTR
	.db TC_end


T_EXCP_E_Sa1BWramToSmall:
	.db TC_pos
	.dw $102
	.db "SA-1 BW-RAM too small,",TC_brk,TC_sub
	.dw T_EXCP_Sa1BwramReq.PTR
	.db TC_end


T_EXCP_Sa1BwramReq:
	.db "at least 64kkbyte required.",TC_end

T_EXCP_E_Sa1DoubleIrq:
	.db TC_pos
	.dw $102
	.db "SA-1 generated ambiguous IRQ.",TC_end

T_EXCP_E_SpcNoStimulusCallback:
	.db TC_pos
	.dw $102
	.db "No callback routine for",TC_brk
	.db "SPC stimulus registered.",TC_end

.ends
