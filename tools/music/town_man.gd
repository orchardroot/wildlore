extends RefCounted
## The Isle of Man: a slow original air in D dorian, whistle and fiddle over a harp, with the sea always somewhere behind it.

const A := "5:4 1':2 2':2 | 3':4 2':2 1':2 | 7:4 5:4 | 6:8 | 5:4 1':2 2':2 | 3':4 5':2 3':2 | 2':4 7:2 6:2 | 5:8"
const B := "3':4 5':4 | 6':4 5':2 3':2 | 2':4 1':4 | 7:8 | 3':2 2':2 1':2 7:2 | 6:4 5:4 | 4:4 6:2 7:2 | 1:8"
const CA := [1, 1, 5, 4, 1, 1, 5, 1]
const CB := [1, 4, 5, 5, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.3
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("whistle", A, 0, 8, 0.7)
	c.lead("fiddle", B, 8, 8, 0.6)
	c.lead("whistle", B, 8, 8, 0.3, 12)
	c.arp("harp", CA, 0, "0.12.321", 0.45)
	c.arp("harp", CB, 8, "0.12.321", 0.45)
	c.bass(CA, 0, "x.......", 0.5)
	c.bass(CB, 8, "x.......", 0.5)
	c.drone(0, 16, 0.18)
	return c
