.section "scene11. lut" superfree
DemoScene11:
	.dw ((DemoScene11End-DemoScene11)/3)-2
	PTRLONG DemoScene11 scene11.000
	PTRLONG DemoScene11 scene11.001
	PTRLONG DemoScene11 scene11.002
	PTRLONG DemoScene11 scene11.003
	PTRLONG DemoScene11 scene11.004
	PTRLONG DemoScene11 scene11.005
	PTRLONG DemoScene11 scene11.006
	PTRLONG DemoScene11 scene11.007
	PTRLONG DemoScene11 scene11.008
	PTRLONG DemoScene11 scene11.009
	PTRLONG DemoScene11 scene11.010

DemoScene11End:

.ends

.section "scene11.000" superfree
	FILEINC scene11.000 "data/frames/scene11.000"
	FILEINC scene11.001 "data/frames/scene11.001"
	FILEINC scene11.002 "data/frames/scene11.002"
	FILEINC scene11.003 "data/frames/scene11.003"
	FILEINC scene11.004 "data/frames/scene11.004"
	FILEINC scene11.005 "data/frames/scene11.005"
	FILEINC scene11.006 "data/frames/scene11.006"
	FILEINC scene11.007 "data/frames/scene11.007"
	FILEINC scene11.008 "data/frames/scene11.008"
	FILEINC scene11.009 "data/frames/scene11.009"
.ends

.section "scene11.010" superfree
	FILEINC scene11.010 "data/frames/scene11.010"

.ends
