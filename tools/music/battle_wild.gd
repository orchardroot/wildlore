extends RefCounted
## Wild battle: a driving reel in D mixolydian. Fiddle throughout, whistle joins from the second round.
## 2.1: a two-bar lead-in (drums, then a fiddle run up into the tune) that plays once, and a C part over C and G
## major (whistle and bouzouki, then fiddle), for a 64-bar body.

const A := "1':1 7:1 1':1 5:1 1':1 5:1 3:1 5:1 | 1':1 7:1 1':1 5:1 1':1 2':1 3':2 | 4':1 3':1 2':1 3':1 4':1 3':1 2':1 1':1 | 7:2 5:2 3:2 5:2 | 1':1 7:1 1':1 5:1 1':1 5:1 3:1 5:1 | 3':1 4':1 5':2 4':1 3':1 2':2 | 4':1 3':1 2':1 3':1 4':2 2':2 | 1':4 7:2 5:2"
const B := "5':2 5':1 4':1 3':1 4':1 5':2 | 5':1 3':1 5':1 3':1 4':2 2':2 | 5':1 6':1 7':1 6':1 5':1 4':1 3':1 2':1 | 1':2 3':2 5':4 | 5':2 5':1 4':1 3':1 4':1 5':2 | 5':1 4':1 3':1 4':1 5':2 3':2 | 2':1 3':1 4':1 3':1 2':1 1':1 7:2 | 1':6 r:2"
const C := "7:1 2':1 4':1 2':1 7:1 2':1 4':2 | 4':1 6':1 4':1 1':1 6:1 1':1 4':2 | 5':2 3':1 1':1 3':2 5':2 | 5':1 4':1 2':1 7:1 5:4 | 7:1 2':1 4':1 7':1 6':1 4':1 2':2 | 1':1 4':1 6':1 4':1 1':2 6:2 | 5:1 7:1 2':1 5':1 4':1 2':1 7:2 | 5:2 7:2 2':2 5:2"
const INTRO := "r:8 | 1:1 2:1 3:1 4:1 5:1 6:1 7:1 r:1"
const CA := [1, 1, 4, 5, 1, 1, 4, 1]
const CB := [1, 1, 5, 1, 1, 1, 4, 1]
const CC := [7, 4, 1, 5, 7, 4, 5, 5]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.1
	c.upb = 8
	c.intro_bars = 2
	c.bars = 66
	c.level_db = 1.0
	c.drums("X..X..X.", 0, 1, 0.8)
	c.drums("X.X.X.XX", 1, 1, 0.8)
	c.strum("guitar", [1, 5], 0, "X.....X.", 0.55)
	c.bass([1, 5], 0, "x..x..x.", 0.7)
	c.lead("fiddle", INTRO, 0, 2, 0.85)
	for r in 3:
		var b := 2 + (r if r < 2 else 3) * 16
		c.lead("fiddle", A, b, 8, 0.85)
		c.lead("fiddle", B, b + 8, 8, 0.85)
		if r >= 1:
			c.lead("whistle", A, b, 8, 0.35, 12)
			c.lead("whistle", B, b + 8, 8, 0.35, 12)
		if r == 2:
			c.arp("harp", CA, b, "0.1.2.1.", 0.35)
			c.arp("harp", CB, b + 8, "0.1.2.1.", 0.35)
		c.strum("guitar", CA, b, "X.x.X.x.", 0.5)
		c.strum("guitar", CB, b + 8, "X.x.X.x.", 0.5)
		c.bass(CA, b, "x.o.x.o.", 0.7)
		c.bass(CB, b + 8, "x.o.x.o.", 0.7)
		c.drums("X.xxX.xr", b, 16, 0.7)
		c.drone(b, 16, 0.2)
	# C: the whistle leads over a bouzouki chop with the drums thinned out, then the fiddle drives it home.
	var cb := 2 + 32
	c.lead("whistle", C, cb, 8, 0.8)
	c.strum("bouzouki", CC, cb, "X..x..x.", 0.5)
	c.bass(CC, cb, "x...x...", 0.65)
	c.drums("X...X.x.", cb, 8, 0.6)
	c.lead("fiddle", C, cb + 8, 8, 0.85)
	c.lead("whistle", C, cb + 8, 8, 0.3, 12)
	c.strum("guitar", CC, cb + 8, "X.x.X.x.", 0.5)
	c.strum("bouzouki", CC, cb + 8, "X..x..x.", 0.35)
	c.bass(CC, cb + 8, "x.o.x.o.", 0.7)
	c.drums("X.xxX.xr", cb + 8, 8, 0.7)
	c.drone(cb, 16, 0.2)
	return c
