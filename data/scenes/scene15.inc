.section "scene15. lut" superfree
DemoScene15:
	.dw ((DemoScene15End-DemoScene15)/3)-2
	PTRLONG DemoScene15 scene15.000
	PTRLONG DemoScene15 scene15.001
	PTRLONG DemoScene15 scene15.002
	PTRLONG DemoScene15 scene15.003
	PTRLONG DemoScene15 scene15.004
	PTRLONG DemoScene15 scene15.005
	PTRLONG DemoScene15 scene15.006
	PTRLONG DemoScene15 scene15.007
	PTRLONG DemoScene15 scene15.008

DemoScene15End:

.ends


.section "scene15.000" superfree
	FILEINC scene15.000 "data/frames/scene15.000"
	FILEINC scene15.001 "data/frames/scene15.001"
	FILEINC scene15.002 "data/frames/scene15.002"
	FILEINC scene15.003 "data/frames/scene15.003"
	FILEINC scene15.004 "data/frames/scene15.004"
	FILEINC scene15.005 "data/frames/scene15.005"
	FILEINC scene15.006 "data/frames/scene15.006"
	FILEINC scene15.007 "data/frames/scene15.007"
	FILEINC scene15.008 "data/frames/scene15.008"
.ends

