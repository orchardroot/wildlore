extends RefCounted
## City town (Manchester, Liverpool): a Merseybeat nod in G ionic. Bouncing bass, jangling off-beat guitar, a bright pluck lead.

const A := "5:1 5:1 3:1 5:1 1':2 5:1 3:1 | 6:1 6:1 1':1 6:1 3':2 1':1 6:1 | 4':1 4':1 1':1 4':1 6':2 4':1 1':1 | 5':2 4':1 3':1 2':2 7:1 2':1 | 3':1 3':1 1':1 3':1 5':2 3':1 1':1 | 6:1 1':1 3':1 6':1 5':2 3':2 | 6:1 1':1 4':1 6':1 6':1 5':1 4':1 3':1 | 2':2 4':2 2':2 7:2"
const B := "6:2 1':2 4':2 6':2 | 6':1 5':1 4':1 3':1 4':4 | 5:2 1':2 3':2 5':2 | 5':1 4':1 3':1 2':1 3':4 | 6:1 6:1 1':2 3':2 6':2 | 5':2 3':2 1':4 | 2':1 2':1 4':2 7':2 5':2 | 5':2 4':2 2':2 7:2"
const CA := [1, 6, 4, 5, 1, 6, 4, 5]
const CB := [4, 4, 1, 1, 6, 6, 5, 5]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 67
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.2
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("guitar", A, b, 8, 0.95)
		c.lead("guitar", B, b + 8, 8, 0.95)
		if r == 1:
			c.lead("whistle", A, b, 8, 0.4, 12)
			c.lead("whistle", B, b + 8, 8, 0.4, 12)
			c.lead("guitar", A, b, 8, 0.35, 12)
			c.lead("guitar", B, b + 8, 8, 0.35, 12)
		c.strum("guitar", CA, b, ".xX.xX.x" if r == 0 else "xXxXxXxX", 0.45)
		c.strum("guitar", CB, b + 8, ".xX.xX.x" if r == 0 else "xXxXxXxX", 0.45)
		c.bass(CA, b, "x.xox.xo", 0.8)
		c.bass(CB, b + 8, "x.xox.xo", 0.8)
		c.drums("X.r.x.rr", b, 16, 0.6)
		c.drums("s.s.s.s.", b, 16, 0.5)
	return c
