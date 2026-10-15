extends RefCounted
## Wild battle: a driving reel in D mixolydian. Fiddle throughout, whistle joins from the second round.

const A := "1':1 7:1 1':1 5:1 1':1 5:1 3:1 5:1 | 1':1 7:1 1':1 5:1 1':1 2':1 3':2 | 4':1 3':1 2':1 3':1 4':1 3':1 2':1 1':1 | 7:2 5:2 3:2 5:2 | 1':1 7:1 1':1 5:1 1':1 5:1 3:1 5:1 | 3':1 4':1 5':2 4':1 3':1 2':2 | 4':1 3':1 2':1 3':1 4':2 2':2 | 1':4 7:2 5:2"
const B := "5':2 5':1 4':1 3':1 4':1 5':2 | 5':1 3':1 5':1 3':1 4':2 2':2 | 5':1 6':1 7':1 6':1 5':1 4':1 3':1 2':1 | 1':2 3':2 5':4 | 5':2 5':1 4':1 3':1 4':1 5':2 | 5':1 4':1 3':1 4':1 5':2 3':2 | 2':1 3':1 4':1 3':1 2':1 1':1 7:2 | 1':6 r:2"
const CA := [1, 1, 4, 5, 1, 1, 4, 1]
const CB := [1, 1, 5, 1, 1, 1, 4, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.1
	c.upb = 8
	c.bars = 48
	c.level_db = 1.0
	for r in 3:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.85)
		c.lead("fiddle", B, b + 8, 8, 0.85)
		if r >= 1:
			c.lead("whistle", A, b, 8, 0.35, 12)
			c.lead("whistle", B, b + 8, 8, 0.35, 12)
		c.strum("guitar", CA, b, "X.x.X.x.", 0.5)
		c.strum("guitar", CB, b + 8, "X.x.X.x.", 0.5)
		c.bass(CA, b, "x.o.x.o.", 0.7)
		c.bass(CB, b + 8, "x.o.x.o.", 0.7)
		c.drums("X.xxX.xr", b, 16, 0.7)
		c.drone(b, 16, 0.2)
	return c
