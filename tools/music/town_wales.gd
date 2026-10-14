extends RefCounted
## Welsh town: a slow chapel hymn in F ionic over rippling harp arpeggios. Whistle takes the tune, then a fiddle choir joins.

const A := "3:4 5:4 | 1':4 5:2 3:2 | 4:4 6:4 | 5:8 | 6:4 1':4 | 6:4 4:2 6:2 | 5:4 7:2 2':2 | 2':6 7:2"
const B := "1':4 3':4 | 2':4 7:2 5:2 | 6:4 1':2 3':2 | 3':4 7:2 5:2 | 4':4 3':2 2':2 | 1':4 3:2 5:2 | 7:4 2':2 7:2 | 1':8"
const CA := [1, 1, 4, 1, 6, 4, 5, 5]
const CB := [1, 5, 6, 3, 4, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 65
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.275
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("whistle", A, 0, 8, 0.75)
	c.lead("fiddle", B, 8, 8, 0.6)
	c.lead("whistle", B, 8, 8, 0.45, 12)
	c.lead("fiddle", A, 0, 8, 0.2, -12)
	c.arp("harp", CA, 0, "01231232", 0.5)
	c.arp("harp", CB, 8, "01231232", 0.5)
	c.bass(CA, 0, "x.......", 0.55)
	c.bass(CB, 8, "x.......", 0.55)
	c.drone(0, 16, 0.2)
	return c
