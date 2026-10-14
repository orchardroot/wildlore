extends RefCounted
## Causeway coast route: a lonely tin whistle in F major over slow harp arpeggios, a breath of drone,
## and long waves and wind moving through. Wide and unhurried.

const A := "3:4 5:2 1':2 | 3':6 2':2 | 1':4 5:2 6:2 | 5:8 | 3:4 5:2 1':2 | 3':4 5':2 3':2 | 2':4 1':2 7:2 | 1':8"
const B := "6:4 1':2 3':2 | 5':6 3':2 | 4':4 3':2 2':2 | 3':8 | 6:4 1':2 3':2 | 5':4 6':2 5':2 | 3':2 2':2 1':2 7:2 | 1':6 r:2"
const CA := [1, 5, 6, 4, 1, 3, 5, 1]
const CB := [6, 1, 4, 1, 6, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 53
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.25
	c.upb = 8
	c.seam_fade = 0.02
	c.bars = 16
	c.lead("whistle", A, 0, 8, 0.75)
	c.lead("whistle", B, 8, 8, 0.8)
	c.lead("pipe", B, 8, 8, 0.3, -12)
	c.arp("harp", CA, 0, "0.1.2.3.", 0.35)
	c.arp("harp", CB, 8, "0.1.2.3.", 0.35)
	c.drone(0, 16, 0.25)
	for k in 5:
		c._add("surf", float(k * 26), 12.0, 60, 0.5)
	c._add("surf", 4.0, 40.0, 60, 0.25)
	c._add("surf", 70.0, 40.0, 60, 0.25)
	return c
