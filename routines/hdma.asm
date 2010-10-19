/*
outline hdma interface:
-each hdma effect is a seperate normal obj
-there's no seperate hdma handler, only a couple of functions that automate setup:
	-allocateHdmaChannel
		-input: 24bit pointer to table/target reg/settings
		-get free channel
		-return carry set on success
	-deallocateHdmaChannel
	-allocateHdmaBuffer
	-deallocateHdmaBuffer


*/
.include "routines/h/hdma.h"
.section "hdmahandler"


.ends	
	
