.define IramCharConvBuff $3000	;another hack, this needs to be properly aligned which wla dx cant handle for ramsections
.define SA1IRAM $3000+128 ;hacky, but needs to be defined before memmap
.define SA1IRAMLEN $800-128
.define LOROMOFFSET $8000

.MEMORYMAP
DEFAULTSLOT 0
SLOTSIZE $10000
SLOT 0 $0000	;rom
SLOTSIZE $10000-$2000
SLOT 1 $7e2000	;ram in bank $7e
SLOTSIZE $2000
SLOT 2 16	;zero-page ram. 16=debug value to check if all routines relocate properly

SLOTSIZE $2000
SLOT 3 $6000	;sa-1 bw-ram mirror(snes,sa1)

SLOTSIZE $780	;SA1IRAMLEN-128
SLOT 4 $3080; SA1IRAM+128	;sa-1 i-ram(snes,sa1)
SLOTSIZE $10000
SLOT 5 $400000	;sa-1 bw-ram, bank $40(snes,sa1) 
SLOT 6 $600000	;sa-1 bw-ram 2/4bpp byte-per-pixel mirror, bank $60(snes,sa1) 


.ENDME

.ROMBANKSIZE $10000    ; Every ROM bank is 64 KBytes in size, also necessary.
.ROMBANKS 16           ; 2Mbits -- Tells WLA that you want to use 32 ROM banks.

/*
;this will cause wla dx to be caught in infini loop 
.ROMBANKMAP
BANKSTOTAL 8
BANKSIZE $10000
BANKS 8
.ENDRO
*/
/*
.snesheader
name "BRKPOINT10           "
lorom
slowrom
cartridgetype $34
romsize 9
sramsize 7
country 0
licenseecode $33
version 0
.endsnes
*/
/*
.SNESNATIVEVECTOR
COP    EmptyHandler
BRK    Stop
ABORT  EmptyHandler
NMI    ($8000+NmiHandler+1)
UNUSED IrqHookUp
IRQ    EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR
COP    EmptyHandler
ABORT  EmptyHandler
NMI    EmptyHandler
RESET  Boot
IRQBRK EmptyHandler
.ENDEMUVECTOR
*/
.EMPTYFILL 0


;kernel defines:
;bank defines
.def BSL		$c0
.def ROM		$c0
.def RAM		$7e
.def RAM2		RAM+1
.def REGS		$00

;sa1 stuff:
.def BWRAM	$40
.def BWRAMMIRROR	$60

.def BWRAMWRBANK BWRAMMIRROR

.include "routines/conf/globals.inc"
.include "routines/conf/structs.inc"
.include "routines/conf/macros.inc"

