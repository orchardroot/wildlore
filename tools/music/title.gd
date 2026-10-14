extends RefCounted
## Title: a slow, hopeful air in D dorian. Whistle first time round, fiddle with whistle on top the second.

const A := "5:2 1':3 2':1 3':2 | 2':4 1':2 7:2 | 6:2 5:3 3:1 5:2 | 4:4 5:4 | 5:2 1':3 2':1 3':2 | 5':4 3':2 2':2 | 1':3 7:1 6:2 4:2 | 5:6 r:2"
const B := "1':2 3':2 5':4 | 5':2 4':2 3':2 2':2 | 3':2 2':2 1':2 7:2 | 1':4 5:2 7:2 | 1':2 3':2 5':4 | 6':3 5':1 4':2 2':2 | 4':2 3':2 2':2 7:2 | 1':8"
const CA := [1, 7, 1, 4, 1, 3, 7, 5]
const CB := [1, 5, 3, 1, 1, 4, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.17
	c.upb = 8
	c.bars = 32
	for r in 2:
		var b := r * 16
		if r == 0:
			c.lead("whistle", A, b, 8, 0.85)
			c.lead("whistle", B, b + 8, 8, 0.85)
			c.drums("X.......", b, 16, 0.4)
		else:
			c.lead("fiddle", A, b, 8, 0.85)
			c.lead("fiddle", B, b + 8, 8, 0.85)
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
			c.bass(CA, b, "x...o...", 0.6)
			c.bass(CB, b + 8, "x...o...", 0.6)
			c.drums("X...x.r.", b, 16, 0.55)
		c.arp("harp", CA, b, "01212101", 0.55)
		c.arp("harp", CB, b + 8, "01212101", 0.55)
		c.drone(b, 8, 0.35)
		c.drone(b + 8, 8, 0.35)
	return c
