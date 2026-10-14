extends RefCounted
## Coast route: a sea-shanty lilt in 6/8, D ionic. Fiddle lead, strummed guitar, and a very quiet swell of surf underneath.

const A := "5:1 1':1 1':1 3':2 1':1 | 5:1 1':1 5:1 3':2 1':1 | 6:1 4':1 4':1 6':2 4':1 | 5':3 3':3 | 1':1 1':1 5:1 3':2 1':1 | 6:1 4':1 6:1 6':2 4':1 | 7:1 2':1 7:1 5':2 2':1 | 1':3 r:3"
const B := "6':2 5':1 4':2 6:1 | 4':2 3':1 4':2 6:1 | 3':2 2':1 1':2 5:1 | 3':2 5':1 3':3 | 6':2 5':1 4':2 2':1 | 2':2 3':1 4':2 5':1 | 5':2 4':1 2':2 7:1 | 1':3 5:2 r:1"
const CA := [1, 1, 4, 1, 1, 4, 5, 1]
const CB := [4, 4, 1, 1, 4, 5, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.18
	c.upb = 6
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.85)
		c.lead("fiddle", B, b + 8, 8, 0.85)
		if r == 1:
			c.lead("whistle", A, b, 8, 0.35, 12)
			c.lead("whistle", B, b + 8, 8, 0.35, 12)
		c.strum("guitar", CA, b, "X.xX.x", 0.5)
		c.strum("guitar", CB, b + 8, "X.xX.x", 0.5)
		c.bass(CA, b, "x..o..", 0.65)
		c.bass(CB, b + 8, "x..o..", 0.65)
		c.drums("X..x.." if r == 0 else "X.rx.r", b, 16, 0.5)
		# Slow waves, one per four bars, barely there.
		for k in 4:
			c._add("surf", float((b + k * 4) * 6), 22.0, 60, 0.4)
	return c
