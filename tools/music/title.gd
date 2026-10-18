extends RefCounted
## Title: a slow, hopeful air in D dorian. Whistle first time round, fiddle with whistle on top the second.
## 2.1: a harp intro that plays once, then 64 bars: whistle, fiddle, a C part that lifts to the relative major
## (harp alone, then fiddle), and a last round with the whole band.

const A := "5:2 1':3 2':1 3':2 | 2':4 1':2 7:2 | 6:2 5:3 3:1 5:2 | 4:4 5:4 | 5:2 1':3 2':1 3':2 | 5':4 3':2 2':2 | 1':3 7:1 6:2 4:2 | 5:6 r:2"
const B := "1':2 3':2 5':4 | 5':2 4':2 3':2 2':2 | 3':2 2':2 1':2 7:2 | 1':4 5:2 7:2 | 1':2 3':2 5':4 | 6':3 5':1 4':2 2':2 | 4':2 3':2 2':2 7:2 | 1':8"
const C := "3':3 2':1 1':2 5:2 | 7:2 2':2 4':4 | 4':3 3':1 2':2 1':2 | 1':4 3':2 5':2 | 5':3 4':1 3':2 5:2 | 7:2 2':2 4':2 3':2 | 2':3 1':1 7:2 5:2 | 1':8"
const CA := [1, 7, 1, 4, 1, 3, 7, 5]
const CB := [1, 5, 3, 1, 1, 4, 7, 1]
const CC := [3, 7, 4, 1, 3, 7, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.17
	c.upb = 8
	c.intro_bars = 4
	c.bars = 68
	c.arp("harp", [1, 4, 7, 1], 0, "0.1.2.3.", 0.42)
	c.drone(0, 4, 0.3)
	for r in 3:
		var b := 4 + (r if r < 2 else 3) * 16
		if r == 0:
			c.lead("whistle", A, b, 8, 0.85)
			c.lead("whistle", B, b + 8, 8, 0.85)
			c.drums("X.......", b, 16, 0.4)
		else:
			c.lead("fiddle", A, b, 8, 0.85)
			c.lead("fiddle", B, b + 8, 8, 0.85)
			c.lead("whistle", A, b, 8, 0.3 if r == 1 else 0.4, 12)
			c.lead("whistle", B, b + 8, 8, 0.3 if r == 1 else 0.4, 12)
			c.bass(CA, b, "x...o...", 0.6)
			c.bass(CB, b + 8, "x...o...", 0.6)
			c.drums("X...x.r." if r == 1 else "X...x.rr", b, 16, 0.55)
		c.arp("harp", CA, b, "01212101", 0.55)
		c.arp("harp", CB, b + 8, "01212101", 0.55)
		c.drone(b, 8, 0.35)
		c.drone(b + 8, 8, 0.35)
	# C: up to the relative major, the harp alone over a low bass first, then the fiddle.
	var cb := 4 + 32
	c.lead("harp", C, cb, 8, 0.95)
	c.bass(CC, cb, "x.......", 0.45)
	c.lead("fiddle", C, cb + 8, 8, 0.85)
	c.arp("harp", CC, cb + 8, "01212101", 0.5)
	c.bass(CC, cb + 8, "x...o...", 0.55)
	c.drums("X.......", cb + 8, 8, 0.45)
	c.drone(cb, 16, 0.3)
	return c
