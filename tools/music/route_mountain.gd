extends RefCounted
## Mountain route: slow, wide and lonely, D aeolian. Hollow open fifths, a high whistle, a far-off drum.

const A := "1':6 r:2 | 5:2 5':6 | 2':6 3':2 | 1':8 | 6:2 6':6 | 5':4 3':4 | 4':4 2':4 | 5:8"
const B := "1':4 5':4 | 3':4 5':4 | 7':6 5':2 | 4':4 2':4 | 6':4 3':4 | 5':6 3':2 | 2':4 7:4 | 1':6 r:2"
const CH := [1, 1, 7, 7, 6, 6, 5, 5, 1, 1, 7, 7, 6, 6, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.35
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("whistle", A, 0, 8, 0.8)
	c.lead("whistle", B, 8, 8, 0.8)
	c.lead("whistle", B, 8, 8, 0.25, 12)
	# Open fifths: root and fifth sounded together, nothing in between.
	for k in CH.size():
		var r: int = c._root(int(CH[k]))
		c._add("harp", float(k * 8), 6.0, c.midi_of(r), 0.55)
		c._add("harp", float(k * 8) + 0.1, 6.0, c.midi_of(r + 4), 0.5)
		c._add("harp", float(k * 8) + 4.0, 4.0, c.midi_of(r + 7), 0.35)
		c._add("harp", float(k * 8) + 4.1, 4.0, c.midi_of(r + 11), 0.3)
	c.bass(CH, 0, "x...o...", 0.5)
	c.drums("X.......", 0, 16, 0.3)
	c.drone(0, 8, 0.6)
	c.drone(8, 8, 0.6)
	return c
