extends RefCounted
## Enclosure battle: a pompous brass march in E flat, with a villain's sneer of chromatic notes. Fast, and a little ridiculous.

const A := "1:1 1:1 1:2 5,:2 1:2 | 3:2 3:1 3:1 5:2 3:2 | 4:2 4:1 4:1 6:2 4:2 | 5:2 3:2 1:4 | 5:1 5:1 5:2 2':2 7:2 | 2':2 7:2 5:4 | 3':1 3':1 3':2 1':2 5:2 | 1':6 r:2"
const B := "6:1 6:1 1':2 6:2 #5:2 | 4:1 4:1 6:2 4:2 #4:2 | 5:1 5:1 1':2 5:2 3:2 | 7:2 5:2 2':4 | 1':1 1':1 3':2 1':2 #5:2 | 6:1 6:1 1':2 6:2 #5:2 | 5:1 6:1 7:1 2':1 4':2 2':2 | 1':2 r:1 5:1 1':4"
const CA := [1, 1, 4, 1, 5, 5, 1, 1]
const CB := [6, 4, 1, 5, 6, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 63
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.16
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("brass", A, b, 8, 0.85)
		c.lead("brass", B, b + 8, 8, 0.85)
		if r == 1:
			c.lead("fiddle", A, b, 8, 0.4, 12)
			c.lead("fiddle", B, b + 8, 8, 0.4, 12)
			c.lead("brass", A, b, 8, 0.4, -12)
			c.lead("brass", B, b + 8, 8, 0.4, -12)
		c.strum("brass", CA, b, "..x...x.", 0.4, -12)
		c.strum("brass", CB, b + 8, "..x...x.", 0.4, -12)
		c.bass(CA, b, "x.o.x.o.", 0.85)
		c.bass(CB, b + 8, "x.o.x.o.", 0.85)
		c.drums("X.r.x.rr", b, 16, 0.8)
		c.drums("s.s.s.s.", b, 16, 0.4)
	return c
