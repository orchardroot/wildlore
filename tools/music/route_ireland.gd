extends RefCounted
## Irish route: a slow air in 3/4, D dorian. A lone whistle over a drone, with a few harp notes falling like rain.

const A := "5:3 1':2 7:1 | 6:3 5:3 | 3:3 5:2 6:1 | 5:6 | 5:3 1':2 2':1 | 3':3 2':2 1':1 | 7:3 6:2 5:1 | 6:6"
const B := "1':3 3':2 5':1 | 6':3 5':3 | 3':2 2':1 1':3 | 7:3 5:3 | 6:2 7:1 1':2 2':1 | 3':3 2':2 1':1 | 2':2 1':1 7:2 5:1 | 1':6"
const CA := [1, 4, 3, 1, 1, 3, 7, 4]
const CB := [1, 4, 3, 7, 4, 3, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.34
	c.upb = 6
	c.seam_fade = 0.05
	c.bars = 16
	c.lead("whistle", A, 0, 8, 0.6)
	c.lead("whistle", B, 8, 8, 0.65)
	c.lead("pipe", A, 8, 8, 0.2, -12)
	c.arp("harp", CA, 0, "0.1.2.", 0.28)
	c.arp("harp", CB, 8, "0.1.2.", 0.3)
	c.drone(0, 16, 0.4)
	return c
