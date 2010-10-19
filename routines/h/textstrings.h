.include "routines/conf/config.inc"


;defines

;data structures

;text string commands
.enum 0 export
TC_end	db		;terminate string
TC_sub	db		;print 0x00-terminated string, then return. 1 arg/1 byte: 16bit pointernumber(of stringpointer-LUT) to string
TC_iSub	db		;print 0x00-terminated string, then return. ;1 arg/2 bytes: 16bit pointer in bank $7e to 16bit pointernumber(of stringpointer-LUT) to string
TC_dSub	db		;print 0x00-terminated string, then return. ;1 arg/3 bytes: 24bit stringpointer
TC_diSub	db	;print 0x00-terminated string, then return. ;1 arg/2 bytes: 16bit pointer in bank $7e to 24bit string pointer
TC_pos	db		;set screen position, 1 arg/1 byte: tile position on screen
TC_brk	db		;linebreak, no arguments
TC_hToS	db		;print hex value. arg0,24bit:pointer to value. arg1,8bit: length(32 max)
.ende

;ram buffers

;data includes
.base BSL
.section "textstring lut" superfree
TextstringLUT:
	PTRLONG TextstringLUT T_EXCP_exception
	PTRLONG TextstringLUT T_EXCP_starLine
	PTRLONG TextstringLUT T_EXCP_E_ObjLstFull
	PTRLONG TextstringLUT T_EXCP_E_ObjRamFull
	PTRLONG TextstringLUT T_EXCP_E_StackTrash
	PTRLONG TextstringLUT T_EXCP_E_Brk
	PTRLONG TextstringLUT T_EXCP_E_StackOver
	PTRLONG TextstringLUT T_EXCP_LastCalled
	PTRLONG TextstringLUT T_EXCP_HexTest
	PTRLONG TextstringLUT T_EXCP_E_Sa1IramCode
	PTRLONG TextstringLUT T_EXCP_E_Sa1IramClear
	PTRLONG TextstringLUT T_EXCP_Sa1Test
	PTRLONG TextstringLUT T_EXCP_cpuInfo
	PTRLONG TextstringLUT T_EXCP_sa1Info
	PTRLONG TextstringLUT T_EXCP_irqInfo
	PTRLONG TextstringLUT T_EXCP_Sa1NoIrq
	PTRLONG TextstringLUT T_EXCP_Todo
	PTRLONG TextstringLUT T_EXCP_SpcTimeout
	PTRLONG TextstringLUT T_EXCP_ObjBadHash
	PTRLONG TextstringLUT T_EXCP_ObjBadMethod
	PTRLONG TextstringLUT T_EXCP_undefined
	PTRLONG TextstringLUT T_EXCP_BadScript
	PTRLONG TextstringLUT T_EXCP_StackUnder
	PTRLONG TextstringLUT T_EXCP_E_Cop
	PTRLONG TextstringLUT T_EXCP_E_ScriptStackTrash
	PTRLONG TextstringLUT T_EXCP_E_UnhandledIrq
	PTRLONG TextstringLUT T_EXCP_E_Sa1BWramClear
	PTRLONG TextstringLUT T_EXCP_E_Sa1NoBWram
	PTRLONG TextstringLUT T_EXCP_E_Sa1BWramToSmall
	PTRLONG TextstringLUT T_EXCP_E_Sa1DoubleIrq
	PTRLONG TextstringLUT T_EXCP_Sa1BwramReq
	PTRLONG TextstringLUT T_EXCP_E_SpcNoStimulusCallback
.ends

