.section "scliptest. lut" superfree
DemoScliptest:
	.dw ((DemoScliptestEnd-DemoScliptest-2)/3)
	PTRLONG DemoScliptest scliptest.000
DemoScliptestEnd:

.ends

.section "scliptest.000" superfree
	FILEINC scliptest.000 "data/frames/cliptest.000"
.ends
