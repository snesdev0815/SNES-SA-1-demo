# 65816 stuff
ROMFILE = demo.sfc
VPATH = routines/
AC = wla-65816
AFLAGS = -o
LD = wlalink
LDFLAGS = -vdsr
FL = snesflash
FLFLAGS = -wf
sources  := $(wildcard routines/*.asm)
objects  := $(patsubst %.asm,%.o,$(sources))
linkfile := linkobjs.lst
blndscenes  := $(wildcard data/frames/*.blend)
blndframes  := $(patsubst %.blend,%.001,$(blndscenes))


# spc stuff
SPCAC = wla-spc700
SPCSFILES  = data/apu/apucode.asm
SPCOFILES  = $(SPCSFILES:.asm=.o)
SPCFILE = $(SPCSFILES:.asm=.bin)

all: spc $(objects)
	$(LD) $(LDFLAGS) $(linkfile) $(ROMFILE)
	
$(objects): $(sources)
	$(AC) $(AFLAGS) $(patsubst %.o,%.asm,$@) $@

spc: $(SPCOFILES)
	$(LD) -vsb spclinkfile $(SPCFILE)

$(SPCOFILES): $(SPCSFILES)
	$(SPCAC) $(AFLAGS) $(SPCSFILES)

$(blndframes): $(blndscenes)
	blender $(patsubst %.001,%.blend,$@) -P snes_export_shell.py

flash:
	$(FL) $(FLFLAGS) $(ROMFILE)

clean:
	rm -f $(ROMFILE) $(SPCFILE) $(objects) core *~ *.o *.sym *.srm data/apu/*.o data/apu/*.sym
