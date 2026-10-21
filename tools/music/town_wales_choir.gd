extends RefCounted
## Welsh valleys: an original hymn-like tune in B-flat for a male voice choir, with a harp rippling underneath. The choir answers itself an octave down.

const A := "5:4 1':4 | 3':4 2':2 1':2 | 7:4 5:4 | 6:8 | 6:4 1':4 | 4':4 3':2 2':2 | 1':4 7:2 5:2 | 1':8"
const B := "3':4 5':4 | 4':4 3':2 2':2 | 3':4 1':4 | 2':8 | 5:4 7:4 | 1':4 6:4 | 4:4 5:2 7:2 | 1':8"
const CA := [1, 1, 5, 6, 4, 4, 5, 1]
const CB := [1, 4, 1, 5, 5, 6, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 58
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.3
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("choir", A, 0, 8, 0.8)
	c.lead("choir", B, 8, 8, 0.8)
	c.lead("choir", A, 0, 8, 0.4, -12)
	c.lead("choir", B, 8, 8, 0.4, -12)
	c.pad("choir", CA, 0, 0.18, -12)
	c.pad("choir", CB, 8, 0.18, -12)
	c.arp("harp", CA, 0, "01231232", 0.4)
	c.arp("harp", CB, 8, "01231232", 0.4)
	c.bass(CA, 0, "x.......", 0.5)
	c.bass(CB, 8, "x.......", 0.5)
	return c
