extends RefCounted
## Legend: Enbarr and Nessie. G dorian in a rolling 6/8, deep brass and reed over rising and falling swells.
## Harp arpeggios roll like the sea; the climax lifts an octave with whistle and fiddle.

const A := "1:3 3:2 5:1 | 5:3 4:3 | 3:3 2:2 1:1 | 1:6 | 1:3 3:2 5:1 | 6:3 5:3 | 4:2 3:2 2:2 | 1:6"
const B := "5:3 1':2 5:1 | 6:3 5:3 | 4:3 3:2 2:1 | 3:6 | 5:3 1':2 5:1 | 2':3 1':3 | 7:2 5:2 6:2 | 5:6"
const C := "1':3 3':2 5':1 | 5':3 4':3 | 3':3 2':2 1':1 | 7:3 6:3 | 5:3 6:2 7:1 | 1':3 2':3 | 3':2 2':2 1':2 | 1':6"
const CA := [1, 4, 7, 1, 1, 4, 5, 1]
const CB := [5, 4, 3, 1, 5, 7, 4, 5]
const CC := [1, 4, 7, 6, 5, 4, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 43
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.2
	c.upb = 6
	c.seam_fade = 0.02
	c.bars = 32
	c.lead("brass", A, 0, 8, 0.6)
	c.lead("reed", B, 8, 8, 0.6)
	c.lead("brass", B, 8, 8, 0.5, -12)
	c.lead("brass", C, 16, 8, 0.75)
	c.lead("whistle", C, 16, 8, 0.4, 12)
	c.lead("fiddle", C, 16, 8, 0.5, 12)
	c.lead("brass", A, 24, 8, 0.65)
	c.lead("reed", A, 24, 8, 0.3, -12)
	c.arp("harp", CA, 0, "012321", 0.35)
	c.arp("harp", CB, 8, "012321", 0.4)
	c.arp("harp", CC, 16, "012321", 0.45)
	c.arp("harp", CA, 24, "012321", 0.35)
	c.bass(CA, 0, "x..x..", 0.7)
	c.bass(CB, 8, "x..x..", 0.7)
	c.bass(CC, 16, "x..x..", 0.7)
	c.bass(CA, 24, "x..x..", 0.7)
	c.drums("X..x..", 8, 24, 0.8)
	c.drone(0, 32, 0.5)
	for k in 16:
		c._add("surf", float(k * 12), 11.0, 60, 0.5)
	return c
