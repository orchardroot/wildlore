extends RefCounted
## A Highland march: an original tune in A mixolydian for the pipe chanter over a steady drone, with a fiddle joining the second time round.

const A := "1:3 1:1 3:2 5:2 | 1':3 7:1 5:4 | 6:3 5:1 4:2 2:2 | 1:6 r:2 | 1:3 1:1 3:2 5:2 | 1':2 5':2 3':2 1':2 | 7:3 5:1 6:2 4:2 | 1:8"
const B := "5:3 5:1 1':2 5:2 | 3':3 1':1 5:4 | 6:3 6:1 1':2 6:2 | 5:6 r:2 | 5':3 3':1 1':2 3':2 | 4':3 3':1 2':4 | 7:3 1':1 6:2 4:2 | 1:8"
const CA := [1, 1, 4, 1, 1, 1, 5, 1]
const CB := [1, 1, 4, 5, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.16
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	c.drone(0, 32, 0.3)
	for r in 2:
		var b := r * 16
		c.lead("chanter", A, b, 8, 0.8)
		c.lead("chanter", B, b + 8, 8, 0.8)
		if r == 1:
			c.lead("fiddle", A, b, 8, 0.3, -12)
			c.lead("fiddle", B, b + 8, 8, 0.3, -12)
		c.bass(CA, b, "x...o...", 0.5)
		c.bass(CB, b + 8, "x...o...", 0.5)
		c.drums("X.r.x.r.", b, 16, 0.5)
	return c
