extends RefCounted
## Victory: a short, bright fanfare in D mixolydian. Does not loop.

const A := "5:1 5:1 1':2 5:1 1':1 3':2 | 5':2 4':1 3':1 2':2 1':2 | 1':1 3':1 5':2 3':1 5':1 7':2 | 5':2 3':2 1':4"

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.15
	c.upb = 8
	c.bars = 4
	c.loop = false
	c.tail = 1.2
	c.lead("fiddle", A, 0, 4, 0.9)
	c.lead("whistle", A, 0, 4, 0.5, 12)
	c.strum("guitar", [1, 1, 5, 1], 0, "X.x.X.x.", 0.55)
	c.bass([1, 1, 5, 1], 0, "x.o.x.o.", 0.7)
	c.drums("X.xxX.xr", 0, 4, 0.8)
	c.drone(0, 4, 0.3)
	return c
