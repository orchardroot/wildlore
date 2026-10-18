extends RefCounted
## Forest road: a bouncing 6/8 jig in E dorian. Rounds: whistle, fiddle, a C part, then both.
## 2.1: a short harp-and-bodhran intro that plays once, and a C part over A major (pipe, then fiddle) for a 64-bar body.

const A := "1:1 3:1 5:1 1':2 5:1 | 7:1 5:1 4:1 5:2 3:1 | 1:1 3:1 5:1 1':2 3':1 | 2':3 1':1 7:2 | 1:1 3:1 5:1 1':2 5:1 | 4':2 3':1 2':2 1':1 | 5:1 7:1 2':1 7:1 5:1 7:1 | 1:4 r:2"
const B := "3':2 2':1 1':2 7:1 | 5:2 6:1 7:2 5:1 | 1':3 3':1 5':2 | 4':2 3':1 2':2 1':1 | 3':2 2':1 1':2 7:1 | 6:1 7:1 1':1 2':1 3':1 4':1 | 5':3 4':1 2':2 | 1':4 r:2"
const C := "4:1 6:1 1':1 6:2 4:1 | 5:1 3:1 1:1 3:2 5:1 | 6:1 1':1 2':1 1':2 6:1 | 5:3 7:2 2':1 | 3':2 2':1 7:2 5:1 | 7:1 2':1 4':1 2':2 7:1 | 5:1 7:1 2':1 5':2 4':1 | 1':4 r:2"
const INTRO := "r:6 | r:6 | r:6 | r:3 5,:1 6,:1 7,:1"
const CA := [1, 7, 1, 5, 1, 4, 5, 1]
const CB := [1, 4, 1, 4, 1, 4, 5, 1]
const CC := [4, 1, 4, 5, 3, 7, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 64
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.15
	c.upb = 6
	c.intro_bars = 4
	c.bars = 68
	c.arp("harp", [1, 1, 7, 5], 0, "0.12.1", 0.42)
	c.drums("X..x..", 0, 4, 0.45)
	c.lead("whistle", INTRO, 0, 4, 0.6)
	c.drone(0, 4, 0.2)
	for r in 3:
		var b := 4 + (r if r < 2 else 3) * 16
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
	# C: a brighter turn over A major, the pipe over guitar first, then the fiddle with the band.
	var cb := 4 + 32
	c.lead("pipe", C, cb, 8, 0.8)
	c.strum("guitar", CC, cb, "X..x..", 0.4)
	c.bass(CC, cb, "x.....", 0.5)
	c.drums("X.....", cb, 8, 0.45)
	c.lead("fiddle", C, cb + 8, 8, 0.8)
	c.lead("pipe", C, cb + 8, 8, 0.3, 12)
	c.arp("harp", CC, cb + 8, "0.12.1", 0.45)
	c.bass(CC, cb + 8, "x..o..", 0.55)
	c.drums("X.rX.x", cb + 8, 8, 0.5)
	c.drone(cb, 16, 0.2)
	return c
