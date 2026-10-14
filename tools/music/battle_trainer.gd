extends RefCounted
## Trainer battle: a sterner reel in A dorian, fiddle with whistle above, shaker driving the offbeats.

const A := "1':2 1':1 5:1 1':2 5:1 3:1 | 1':1 2':1 3':2 2':2 1':2 | 4':2 4':1 3':1 2':2 1':1 7:1 | 6:2 5:2 7:2 5:2 | 1':2 1':1 5:1 1':2 5:1 3:1 | 3':2 4':1 5':1 4':2 3':2 | 2':1 3':1 4':1 3':1 2':1 1':1 7:1 6:1 | 5:6 r:2"
const B := "5':1 5':1 5':1 3':1 5':2 4':2 | 3':1 3':1 3':1 1':1 3':2 2':2 | 1':1 2':1 3':1 4':1 5':1 4':1 3':1 2':1 | 1':4 5:2 1':2 | 5':1 5':1 5':1 3':1 5':2 4':2 | 3':1 3':1 3':1 1':1 3':2 2':2 | 4':1 3':1 2':1 1':1 7:1 6:1 5:1 7:1 | 1':6 r:2"
const CA := [1, 1, 4, 5, 1, 3, 5, 5]
const CB := [3, 1, 1, 1, 3, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.095
	c.upb = 8
	c.bars = 48
	for r in 3:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.85)
		c.lead("fiddle", B, b + 8, 8, 0.85)
		c.lead("whistle", A, b, 8, 0.35 if r > 0 else 0.2, 12)
		c.lead("whistle", B, b + 8, 8, 0.35 if r > 0 else 0.2, 12)
		c.strum("guitar", CA, b, "X.xxX.xx", 0.5)
		c.strum("guitar", CB, b + 8, "X.xxX.xx", 0.5)
		c.bass(CA, b, "x.xox.xo", 0.7)
		c.bass(CB, b + 8, "x.xox.xo", 0.7)
		c.drums("X.xxX.xr", b, 16, 0.75)
		c.drums(".s.s.s.s", b, 16, 0.6)
		c.drone(b, 16, 0.2)
	return c
