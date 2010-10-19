.include "routines/conf/config.inc"

;defines
.enum $f1
SpcCmdUploadSong	db		;indicates that a song is to be uploaded
SpcCmdUploadSongT1	db		;indicates that data for transfer1 is on apu ports
SpcCmdUploadSongT2	db		;indicates that data for transfer2 is on apu ports
SpcCmdUploadSongDone	db		;indicates that song upload is complete
SpcCmdReceiveStream	db		;indicates that 65816 wants to stream brr data to spc
SpcCmdReceiveStreamComplete	db	;spc wants to end stream transmission.
SpcCmdSubmitStreamNumber	db	;indicates that hdma transfer has started.  Its important that bit0 of this command is set.(brr end bit)
SpcCmdUploadSamplePack	db		;indicates that a sample pack is to be uploaded. the rest of the commands are taken from normal song upload
SpcCmdUploadSamplePackDone	db		;indicates that sample pack upload is complete
SpcCmdPlaySoundEffect	db		;play a sound effect
SpcCmdStopSong	db		;stop song or stream
SpcCmdSetSongSpeed	db		;set timer speed of mod playback routine
SpcCmdSetSongChMask	db		;song channel mask
SpcCmdReportType	db		;type of data spc should respond with
.ende


.define  SpcFrameSize		144
.define	 SpcFramesPerBank	455	
.define SpcScanlineWaitCount	5		;amount of scanlines to wait before frame send
.define stimulusEmpty $ffff
.define stimulusCallbackCount 8		;should be 8 due to limitations in mod format
.define modStimulusCommand $E0		;pro tracker mod command used to trigger stimuli

;data structures
.STRUCT callbackBuff
pointer		dw	;pointer to callback routine. $ffff means empty
.ENDST

;zp-vars
.enum 0
_tmp ds 8
SpcCurrentStreamSet		db
SpcHandlerState			db
SpcHandlerArgument0		db
SpcHandlerArgument1		db
SpcHandlerArgument2		db
SpcCmdFifoStart			db
SpcCmdFifoEnd			db

SpcStreamVolume			db
;SpcSEVolume			db
;SpcSEPitch			db
SpcSongSpeed			db		;default $a0
SpcSongChMask			db		;default $0f
SpcReportType			dw		;0=none 1=timecode 2=channel-levels(vol out) 3=special mod command
SpcReportInstrBuff	dw
PtPlayerDataPointerLo		db	;assumes dreg: $0000 really? doesnt look that way.
PtPlayerDataPointerHi		db	;assumes dreg: $0000
PtPlayerDataPointerBa		db	;assumes dreg: $0000
PtPlayerCurrentSong		db	;assumes dreg: $0000
PtPlayerCurrentSamplePack	db
PtPlayerCurrentSoundEffect	db

PtPlayerSmplBufferPosLo		db	;not needed at all
PtPlayerSmplBufferPosHi		db
SpcUploadedFlag				db	;msb set=song upload complete and playing. bit6 set=sample pack uploaded
SpcStreamFrame			dw
SpcSoundEffectFlipFlag		dw		;flag alternating between each sound effect upload so that spc doesnt trigger the same one twice.
lastStimulusBuffer	dw		;used to detect changes in spc stimulus report. to simplify handshaking, only changes cause registered callback routine to be triggered

SpcCmdFifo			ds 64
stimulusCallbacks INSTANCEOF callbackBuff stimulusCallbackCount

zpLen ds 0
.ende

;ram buffers
.ramsection "spc queue" bank 0 slot 1
SpcReportBuffer ds 16
.ends

.ramsection "hdma-spc buffer dummy" bank 0 slot 1
HdmaSpcBuffer ds 200
.ends


.base BSL
.bank 0 slot 0
.org 0

.Section "SongLUT" superfree
SongLUT:
	PTRLONG SongLUT rez_bubbletoast2
.ends	

.Section "song 0" superfree
	SONG rez_bubbletoast2
.ends

.Section "SamplepackLUT" superfree				
PtPlayerSamplePackPointertable:
	PTRLONG PtPlayerSamplePackPointertable SamplePack0 
.ends

.Section "sample pack 0" superfree
SamplePack0:
	.dw (SamplePack0End-SamplePack0)

SamplePackStart0:
	.db 1				;number of samples in this pack

Sample0Header:
	.dw (Sample0-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample0-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0


Sample0:
	.incbin "data/sounds/hit.brr"

SamplePack0End:
.ends

.Section "streamLUT" superfree				
StreamSetLut:
	PTRLONG PtPlayerSamplePackPointertable SamplePack0 
.ends

.Section "Audio Player" superfree
PtplayerSpcCode:
	.dw (PtplayerSpcCodeEnd-PtplayerSpcCode-2)
	
	.incbin "data/apu/apucode.bin"			
	
PtplayerSpcCodeEnd:
	.dw $0000		;termination code
	.dw $0000
	.incbin "data/apu/apucode.bin" READ 2		;spc start adress
.ends	


.section "spcDat" semifree
	OOPOBJ Spc $81 zpLen playSong SpcSetReportType registerStimulusCallback
.ends

.section "SpcHandlerSubroutineJumpLUT" semifree
SpcHandlerSubroutineJumpLUT:
	PTRNORM	SpcHandlerSubroutineJumpLUT	init_Spc
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcIdle
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcUploadSong
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcUploadSampleset
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcStreamData
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcStreamDataWait
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcPlaySoundeffectUpload	
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcPlaySoundeffectWait
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcStopSongInit
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcStopSongWait 
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetSpeedInit
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetSpeedWait
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetChMaskInit
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetChMaskWait
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetReportTypeInit
	PTRNORM	SpcHandlerSubroutineJumpLUT	SpcSetReportTypeWait
	PTRNORM	SpcHandlerSubroutineJumpLUT	kill_Spc
.ends
