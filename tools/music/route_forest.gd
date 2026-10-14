extends RefCounted
## Forest road: a bouncing 6/8 jig in E dorian. Three rounds: whistle, fiddle, both.

const A := "1:1 3:1 5:1 1':2 5:1 | 7:1 5:1 4:1 5:2 3:1 | 1:1 3:1 5:1 1':2 3':1 | 2':3 1':1 7:2 | 1:1 3:1 5:1 1':2 5:1 | 4':2 3':1 2':2 1':1 | 5:1 7:1 2':1 7:1 5:1 7:1 | 1:4 r:2"
const B := "3':2 2':1 1':2 7:1 | 5:2 6:1 7:2 5:1 | 1':3 3':1 5':2 | 4':2 3':1 2':2 1':1 | 3':2 2':1 1':2 7:1 | 6:1 7:1 1':1 2':1 3':1 4':1 | 5':3 4':1 2':2 | 1':4 r:2"
const CA := [1, 7, 1, 5, 1, 4, 5, 1]
const CB := [1, 4, 1, 4, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 64
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.15
	c.upb = 6
	c.bars = 48
	for r in 3:
		var b := r * 16
		if r == 0:
			c.lead("whistle", A, b, 8, 0.8)
			c.lead("whistle", B, b + 8, 8, 0.8)
		elif r == 1:
			c.lead("fiddle", A, b, 8, 0.8)
			c.lead("fiddle", B, b + 8, 8, 0.8)
		else:
			c.lead("fiddle", A, b, 8, 0.75)
			c.lead("fiddle", B, b + 8, 8, 0.75)
			c.lead("whistle", A, b, 8, 0.4, 12)
			c.lead("whistle", B, b + 8, 8, 0.4, 12)
		c.arp("harp", CA, b, "0.12.1", 0.5)
		c.arp("harp", CB, b + 8, "0.12.1", 0.5)
		c.bass(CA, b, "x..o..", 0.55)
		c.bass(CB, b + 8, "x..o..", 0.55)
		c.drums("X.rX.x" if r > 0 else "X..x..", b, 16, 0.55)
		c.drone(b, 16, 0.25)
	return c
