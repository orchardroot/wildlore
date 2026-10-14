extends RefCounted
## Sanctuary: a calm 3/4 air in G dorian. Whistle and harp, then a soft fiddle with the whistle above.

const A := "5:4 3:2 | 4:3 3:1 2:2 | 1:4 2:2 | 3:6 | 5:4 6:2 | 5:3 4:1 3:2 | 2:3 3:1 2:2 | 1:6"
const B := "1':3 7:1 6:2 | 5:3 6:1 7:2 | 1':3 2':1 3':2 | 2':4 1':2 | 3':3 2':1 1':2 | 7:3 6:1 5:2 | 4:3 3:1 2:2 | 1:6"
const CA := [1, 7, 1, 3, 4, 3, 5, 1]
const CB := [1, 5, 1, 2, 1, 5, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 67
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.25
	c.upb = 6
	c.bars = 32
	for r in 2:
		var b := r * 16
		if r == 0:
			c.lead("whistle", A, b, 8, 0.75)
			c.lead("whistle", B, b + 8, 8, 0.75)
		else:
			c.lead("fiddle", A, b, 8, 0.6)
			c.lead("fiddle", B, b + 8, 8, 0.6)
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
		c.arp("harp", CA, b, "012321", 0.5)
		c.arp("harp", CB, b + 8, "012321", 0.5)
		c.drone(b, 8, 0.5)
		c.drone(b + 8, 8, 0.5)
	return c
