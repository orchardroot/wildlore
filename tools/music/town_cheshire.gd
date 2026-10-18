extends RefCounted
## Cheshire town: an easy-going reel in G mixolydian, guitar strum under a whistle, then fiddle.
## 2.1: a strummed intro that plays once, then 64 bars: A B twice, a C part over F and C chords (harp, then fiddle),
## and a last full round, so the first hour in Macclesfield is not the same 38 seconds on repeat.

const A := "3:1 5:1 1':2 7:1 5:1 3:2 | 4:1 6:1 1':2 6:1 4:1 6:2 | 3:1 5:1 1':2 2':1 3':1 2':2 | 1':2 7:2 5:4 | 3:1 5:1 1':2 7:1 5:1 3:2 | 6:1 1':1 3':2 2':1 1':1 6:2 | 5:2 7:2 2':2 7:2 | 1':6 r:2"
const B := "1':2 7:1 6:1 5:2 3:2 | 4:2 5:1 6:1 5:2 4:2 | 3:2 4:1 5:1 6:2 5:2 | 7:2 5:2 3:2 5:2 | 1':2 7:1 6:1 5:2 3:2 | 4:1 6:1 1':2 6:2 4:2 | 5:2 4:2 3:2 2:2 | 1:6 r:2"
const C := "2':2 1':1 7:1 4:2 2:2 | 4:2 6:1 1':1 6:2 4:2 | 5:1 6:1 5:1 3:1 1:2 3:2 | 2:2 5:2 7:2 5:2 | 2':2 4':1 2':1 7:2 2':2 | 1':2 7:1 6:1 4:2 6:2 | 5:2 7:1 2':1 3':2 2':2 | 1':6 r:2"
const INTRO := "r:8 | r:8 | r:8 | r:4 5,:1 7,:1 1:1 2:1"
const CA := [1, 4, 1, 5, 1, 4, 5, 1]
const CB := [1, 4, 1, 5, 1, 4, 5, 1]
const CC := [7, 4, 1, 5, 7, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 67
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.15
	c.upb = 8
	c.intro_bars = 4
	c.bars = 68
	c.strum("guitar", [1, 4, 1, 5], 0, "X...x...", 0.38)
	c.lead("whistle", INTRO, 0, 4, 0.6)
	c.drone(0, 4, 0.2)
	for r in 3:
		var b := 4 + (r if r < 2 else 3) * 16
		var inst := "whistle" if r == 0 else "fiddle"
		c.lead(inst, A, b, 8, 0.8)
		c.lead(inst, B, b + 8, 8, 0.8)
		if r == 2:
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
		c.strum("guitar", CA, b, "X.x.X.x.", 0.5)
		c.strum("guitar", CB, b + 8, "X.x.X.x.", 0.5)
		c.bass(CA, b, "x.o.x.o.", 0.6)
		c.bass(CB, b + 8, "x.o.x.o.", 0.6)
		c.drums("X.x.X.xr" if r > 0 else "X...x...", b, 16, 0.6)
		if r > 0:
			c.arp("harp", CA, b, "0.1.2.3.", 0.4)
			c.arp("harp", CB, b + 8, "0.1.2.3.", 0.4)
		c.drone(b, 16, 0.25)
	# C: the harp alone over a soft strum first, then the fiddle takes it with the band back in.
	var cb := 4 + 32
	c.lead("harp", C, cb, 8, 0.9)
	c.strum("guitar", CC, cb, "X...x...", 0.4)
	c.bass(CC, cb, "x...o...", 0.5)
	c.drums("X.......", cb, 8, 0.45)
	c.lead("fiddle", C, cb + 8, 8, 0.8)
	c.lead("whistle", C, cb + 8, 8, 0.25, 12)
	c.strum("guitar", CC, cb + 8, "X.x.X.x.", 0.5)
	c.bass(CC, cb + 8, "x.o.x.o.", 0.6)
	c.arp("harp", CC, cb + 8, "0.1.2.3.", 0.35)
	c.drums("X...X.x.", cb + 8, 8, 0.55)
	c.drone(cb, 16, 0.2)
	return c
