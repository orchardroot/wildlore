extends RefCounted
## York: a stately F major air, cathedral bells tolling over string-like fiddle pads and a rippling harp.

const A := "1:4 3:2 5:2 | 6:4 5:4 | 4:3 3:1 2:2 1:2 | 2:8 | 3:4 5:2 1':2 | 7:3 6:1 5:2 4:2 | 3:2 2:2 1:2 2:2 | 1:8"
const B := "5:4 1':2 3':2 | 2':4 1':4 | 7:3 1':1 2':2 7:2 | 1':8 | 6:4 4':2 3':2 | 2':3 1':1 7:2 5:2 | 6:2 7:2 1':2 2':2 | 1':8"
const BELLS := "1':2 r:6 5:2 r:6 4:2 r:6 5:2 r:6 1':2 r:6 5:2 r:6 4:2 r:6 1:2 r:6"
const CA := [1, 6, 4, 5, 1, 5, 4, 1]
const CB := [1, 5, 1, 1, 4, 5, 4, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 53
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.19
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 4:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.lead("bell", BELLS, b, 8, 0.7 if r < 2 else 0.85, -12)
		c.pad("fiddle", ch, b, 0.22, -12)
		c.arp("harp", ch, b, "01212101", 0.4 if r < 2 else 0.5)
		c.drone(b, 8, 0.3)
		match r:
			0:
				c.lead("harp", m, b, 8, 0.8)
			1:
				c.lead("whistle", m, b, 8, 0.8)
			2:
				c.lead("fiddle", m, b, 8, 0.85)
				c.lead("whistle", m, b, 8, 0.3, 12)
				c.bass(ch, b, "x...o...", 0.5)
			3:
				c.lead("fiddle", m, b, 8, 0.9)
				c.lead("brass", m, b, 8, 0.35, -12)
				c.lead("whistle", m, b, 8, 0.35, 12)
				c.bass(ch, b, "x...o...", 0.6)
	return c
