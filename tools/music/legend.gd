extends RefCounted
## Legend battle: pounding drums and a soaring fiddle in G aeolian. Epic, relentless, a little desperate.

const A := "5:2 1':2 3':4 | 6':4 5':2 3':2 | 2':4 7:2 5:2 | 1':6 r:2 | 5:2 1':2 3':2 5':2 | 6':4 3':2 1':2 | 7:2 2':2 4':2 7':2 | 5':6 7:2"
const B := "1'':4 7':2 6':2 | 5':4 7':4 | 1'':6 5':2 | 3':4 5':4 | 6':2 1'':2 6':2 3'':2 | 2'':4 7':2 5':2 | 4':4 5':2 7':2 | 1':6 r:2"
const CA := [1, 6, 7, 1, 1, 6, 7, 5]
const CB := [6, 7, 1, 1, 6, 7, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.19
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.95)
		c.lead("fiddle", B, b + 8, 8, 0.95)
		c.lead("whistle", A, b, 8, 0.45, 12)
		c.lead("whistle", B, b + 8, 8, 0.45, 12)
		if r == 1:
			c.lead("brass", A, b, 8, 0.4, -12)
			c.lead("brass", B, b + 8, 8, 0.4, -12)
		c.strum("guitar", CA, b, "XxXxXxXx", 0.55)
		c.strum("guitar", CB, b + 8, "XxXxXxXx", 0.55)
		c.bass(CA, b, "xxxxxxxx", 0.85)
		c.bass(CB, b + 8, "xxxxxxxx", 0.85)
		c.drums("XxXxXxXX", b, 16, 1.0)
		c.drums("r.r.r.r.", b, 16, 0.6)
		c.drone(b, 16, 0.35)
	return c
