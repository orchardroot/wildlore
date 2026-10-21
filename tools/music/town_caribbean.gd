extends RefCounted
## The Caribbean territories: an original calypso-ish tune in C for steel pan, with a bouncing bass, guitar offbeats and a shaker.

const A := "3:2 5:2 1':2 5:2 | 3':2 1':2 5:4 | 4:2 6:2 1':2 6:2 | 4':2 1':2 6:4 | 3:2 5:2 1':2 5:2 | 3':2 5':2 3':4 | 2':2 1':2 7:2 5:2 | 1':8"
const B := "5:2 7:2 2':2 7:2 | 5':2 2':2 7:4 | 6:2 1':2 3':2 1':2 | 6':2 3':2 1':4 | 5:2 7:2 2':2 4':2 | 3':2 2':2 1':4 | 4:2 2':2 7:2 5:2 | 1':8"
const CA := [1, 1, 4, 4, 1, 1, 5, 1]
const CB := [5, 5, 6, 6, 5, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 60
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.17
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("pan", A, b, 8, 0.8)
		c.lead("pan", B, b + 8, 8, 0.8)
		if r == 1:
			c.lead("pan", A, b, 8, 0.3, 12)
			c.lead("pan", B, b + 8, 8, 0.3, 12)
		c.strum("guitar", CA, b, "..x..x.x", 0.4)
		c.strum("guitar", CB, b + 8, "..x..x.x", 0.4)
		c.bass(CA, b, "x..xo.x.", 0.6)
		c.bass(CB, b + 8, "x..xo.x.", 0.6)
		c.drums("Xsrs.srs", b, 16, 0.45)
	return c
