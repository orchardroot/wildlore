extends RefCounted
## The Lakes: G mixolydian, slow and open. A harp ripples constantly, a whistle floats above, water laps.

const A := "5:4 3:4 | 2:6 1:2 | 3:4 5:4 | 6:6 5:2 | 4:4 3:4 | 2:4 4:4 | 3:4 2:2 1:2 | 1:8"
const B := "1':4 7:4 | 6:6 5:2 | 5:4 1':4 | 2':6 1':2 | 7:4 6:4 | 4':4 2':4 | 3':4 2':2 7:2 | 1':8"
const WAVES := "1:16 1:16 1:16 1:16"
const CA := [1, 5, 1, 4, 4, 5, 1, 1]
const CB := [1, 4, 1, 5, 5, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.26
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.drone(0, 16, 0.3)
	for r in 2:
		var b := r * 8
		var m := A if r == 0 else B
		var ch: Array = CA if r == 0 else CB
		c.arp("harp", ch, b, "01232101", 0.55)
		c.arp("harp", ch, b, "..2.3.2.", 0.35, 12)
		c.lead("surf", WAVES, b, 8, 0.25)
		c.pad("fiddle", ch, b, 0.15, -12)
		c.lead("whistle", m, b, 8, 0.6 if r == 0 else 0.75)
		if r == 1:
			c.lead("fiddle", m, b, 8, 0.3, -12)
	return c
