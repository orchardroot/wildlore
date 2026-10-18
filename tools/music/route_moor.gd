extends RefCounted
## Moor: slow, open 6/8 in A dorian. Wide intervals, a long drone, a heartbeat of bodhran.
## 2.1: a drone-and-harp intro that plays once, and a C part that opens out to C and D major (reed, then fiddle),
## for a 64-bar body: whistle, fiddle, C, then fiddle with whistle above.

const A := "1':3 5:3 | 7:2 6:1 5:3 | 1':2 2':1 3':3 | 2':3 1':3 | 1':3 5:3 | 4':2 3':1 2':3 | 3':2 2':1 1':2 7:1 | 1':6"
const B := "5':3 4':1 3':2 | 2':3 3':1 2':2 | 1':3 2':1 3':2 | 5':6 | 6':2 5':1 4':2 3':1 | 2':2 1':1 7:2 6:1 | 5:3 6:1 7:2 | 1':6"
const C := "3':3 5':3 | 4':2 3':1 1':3 | 5:3 1':2 3':1 | 2':6 | 5':3 3':2 5':1 | 4':2 2':1 1':3 | 7:2 2':1 5:3 | 1':6"
const CA := [1, 7, 1, 5, 1, 4, 1, 1]
const CB := [3, 5, 1, 3, 4, 5, 1, 1]
const CC := [3, 4, 1, 7, 3, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.2
	c.upb = 6
	c.intro_bars = 4
	c.bars = 68
	c.drone(0, 4, 0.55)
	c.arp("harp", [1, 7, 1, 5], 0, "0..1..", 0.4)
	c.lead("whistle", "r:6 | r:6 | r:6 | r:3 5:3", 0, 4, 0.45)
	for r in 3:
		var b := 4 + (r if r < 2 else 3) * 16
		var inst := "whistle" if r == 0 else "fiddle"
		c.lead(inst, A, b, 8, 0.8)
		c.lead(inst, B, b + 8, 8, 0.8)
		if r > 0:
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
		c.arp("harp", CA, b, "0..1..", 0.5)
		c.arp("harp", CB, b + 8, "0..1..", 0.5)
		c.drums("X.....", b, 16, 0.4 if r == 0 else 0.55)
		c.drone(b, 8, 0.7)
		c.drone(b + 8, 8, 0.7)
	# C: the sky opens. The reed alone over the drone and a slow harp, then the fiddle with the bodhran back.
	var cb := 4 + 32
	c.lead("reed", C, cb, 8, 0.55)
	c.arp("harp", CC, cb, "0.....", 0.45)
	c.lead("fiddle", C, cb + 8, 8, 0.8)
	c.lead("whistle", C, cb + 8, 8, 0.25, 12)
	c.arp("harp", CC, cb + 8, "0..1..", 0.5)
	c.drums("X.....", cb + 8, 8, 0.5)
	c.drone(cb, 8, 0.6)
	c.drone(cb + 8, 8, 0.7)
	return c
