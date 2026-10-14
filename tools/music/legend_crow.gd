extends RefCounted
## Legend: the Morrigan. D aeolian with a flat second, war drums pounding and a high keening fiddle that will not come down.

const A := "5':6 6':1 5':1 | 4':4 3':4 | b2':4 1':2 7:2 | 1':8 | 5':6 6':1 5':1 | 1'':4 7':2 6':2 | 5':4 4':2 b2':2 | 1':6 r:2"
const B := "1'':6 2'':1 1'':1 | 7':4 6':4 | 5':2 6':2 7':2 1'':2 | 3'':8 | 1'':6 b2'':1 1'':1 | 7':4 6':2 5':2 | 4':2 5':2 6':2 4':2 | 5':8"
const CA := [1, 1, 6, 1, 1, 7, 2, 1]
const CB := [1, 7, 6, 1, 1, 6, 4, 5]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 50
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.17
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 24
	c.lead("fiddle", A, 0, 8, 0.9)
	c.lead("whistle", A, 0, 8, 0.3, 12)
	c.lead("fiddle", B, 8, 8, 1.0)
	c.lead("reed", B, 8, 8, 0.4, -12)
	c.lead("whistle", B, 8, 8, 0.4, 12)
	c.lead("fiddle", A, 16, 8, 0.95)
	c.lead("brass", A, 16, 8, 0.4, -12)
	c.lead("whistle", A, 16, 8, 0.35, 12)
	c.strum("guitar", CA, 0, "X.xX.xX.", 0.5)
	c.strum("guitar", CB, 8, "X.xX.xX.", 0.55)
	c.strum("guitar", CA, 16, "X.xX.xX.", 0.55)
	c.bass(CA, 0, "x.x.x.xx", 0.8)
	c.bass(CB, 8, "x.x.x.xx", 0.85)
	c.bass(CA, 16, "x.x.x.xx", 0.85)
	c.drums("X..X.X..", 0, 8, 1.0)
	c.drums("XxxXXxxX", 8, 16, 1.0)
	c.drums("r.r.rr.r", 8, 16, 0.5)
	c.drone(0, 24, 0.4)
	return c
