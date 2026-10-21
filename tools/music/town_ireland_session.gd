extends RefCounted
## An Irish session: an original jig in G mixolydian. Fiddle and whistle trade the tune over guitar and a bodhran.

const A := "1:2 3:1 5:2 3:1 | 1:2 3:1 5:3 | 6:2 5:1 3:2 1:1 | 2:3 5,:3 | 1:2 3:1 5:2 3:1 | 1':2 7:1 5:3 | 6:2 5:1 4:2 2:1 | 1:5 r:1"
const B := "5:2 5:1 1':2 5:1 | 5:2 5:1 3':3 | 2':2 1':1 7:2 5:1 | 6:3 4:3 | 5:2 5:1 1':2 5:1 | 3':2 1':1 5':3 | 4':2 3':1 2':2 7:1 | 1':5 r:1"
const CA := [1, 1, 4, 5, 1, 1, 4, 1]
const CB := [1, 1, 5, 4, 1, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.2
	c.upb = 6
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("fiddle" if r == 0 else "whistle", A, b, 8, 0.8)
		c.lead("fiddle" if r == 0 else "whistle", B, b + 8, 8, 0.8)
		if r == 1:
			c.lead("fiddle", A, b, 8, 0.3, -12)
			c.lead("fiddle", B, b + 8, 8, 0.3, -12)
		c.strum("guitar", CA, b, "X.xX.x", 0.45)
		c.strum("guitar", CB, b + 8, "X.xX.x", 0.45)
		c.bass(CA, b, "x..o..", 0.6)
		c.bass(CB, b + 8, "x..o..", 0.6)
		c.drums("b.dbd.", b, 16, 0.55)
	return c
