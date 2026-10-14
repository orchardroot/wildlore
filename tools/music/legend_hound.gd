extends RefCounted
## Legend: the Cu-Sith. B-flat aeolian with a flat second, hooves galloping on the drums, a thin eerie whistle
## and a pipe wailing above a heavy drone. Dark and relentless.

const A := "1:3 b2:1 1:2 7,:2 | 1:4 5,:4 | 3:3 4:1 3:2 b2:2 | 1:8 | 5:3 6:1 5:2 4:2 | 3:4 b2:4 | 1:3 b2:1 1:2 7,:2 | 1:8"
const B := "5':4 6':2 5':2 | 4':4 3':4 | b2':4 1':2 7:2 | 1':8 | 5':4 6':2 5':2 | 4':6 b2':2 | 1':4 7:2 6:2 | 5:8"
const CA := [1, 1, 6, 1, 4, 7, 1, 1]
const CB := [1, 6, 2, 1, 1, 4, 7, 5]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 46
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.13
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	c.lead("whistle", A, 0, 8, 0.45, 12)
	c.lead("pipe", A, 0, 8, 0.5, 0)
	c.lead("fiddle", B, 8, 8, 0.8)
	c.lead("whistle", B, 8, 8, 0.4, 12)
	c.lead("fiddle", A, 16, 8, 0.85)
	c.lead("whistle", A, 16, 8, 0.4, 12)
	c.lead("brass", B, 24, 8, 0.45, -12)
	c.lead("fiddle", B, 24, 8, 0.95)
	c.lead("whistle", B, 24, 8, 0.4, 12)
	c.bass(CA, 0, "x.......", 0.6)
	c.bass(CB, 8, "x..x..x.", 0.8)
	c.bass(CA, 16, "x..x..x.", 0.85)
	c.bass(CB, 24, "x..x..x.", 0.85)
	c.drums("X.......", 0, 8, 0.7)
	c.drums("XxX.XxX.", 8, 24, 1.0)
	c.drums("..r...r.", 8, 24, 0.5)
	c.drone(0, 32, 0.6)
	return c
