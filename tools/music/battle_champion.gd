extends RefCounted
## The Champion: the biggest battle theme. D dorian, brass and fiddle in unison with whistle above, bouzouki and harp driving underneath.

const A := "1:2 3:2 5:2 1':2 | 7:3 6:1 5:4 | 4:2 6:2 1':2 4':2 | 3':6 2':2 | 1':2 7:2 6:2 5:2 | 4:2 5:2 6:2 7:2 | 1':2 2':2 3':2 5':2 | 1'':6 r:2"
const B := "5':2 5':1 4':1 3':2 2':2 | 3':2 3':1 2':1 1':4 | 2':2 2':1 1':1 7:2 6:2 | 7:4 5:4 | 5':2 5':1 4':1 3':2 2':2 | 6':2 6':1 5':1 4':4 | 3':2 4':2 5':2 7':2 | 1'':8"
const CA := [1, 5, 4, 3, 6, 4, 1, 1]
const CB := [1, 1, 5, 5, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 50
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.085
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 56
	c.drums("X.xrXxxr", 0, 56, 1.0)
	c.drums("s.s.s.s.", 0, 56, 0.5)
	for r in 7:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.bass(ch, b, "xxoxxxox", 0.9)
		c.lead("brass", m, b, 8, 0.85)
		if r >= 1:
			c.lead("fiddle", m, b, 8, 0.8)
			c.strum("bouzouki", ch, b, "X.xxX.xx", 0.5)
		if r >= 2:
			c.lead("whistle", m, b, 8, 0.45, 12)
			c.pad("brass", ch, b, 0.25, -12)
		if r >= 3:
			c.arp("harp", ch, b, "01230123", 0.45)
			c.lead("reed", m, b, 8, 0.35, -12)
		if r >= 5:
			c.lead("pipe", m, b, 8, 0.35, 12)
			c.drone(b, 8, 0.4)
	return c
