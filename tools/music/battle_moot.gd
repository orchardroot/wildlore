extends RefCounted
## The Moot: the Four Winds. A grand, fast A major fanfare with running fiddle and gusts of wind in the drums' gaps.

const A := "1:2 1:1 1:1 5:2 1':2 | 3':3 2':1 1':2 5:2 | 6:2 6:1 6:1 1':2 3':2 | 2':6 r:2 | 1:2 1:1 1:1 5:2 1':2 | 4':3 3':1 2':2 1':2 | 7:2 1':2 2':2 5:2 | 1':6 r:2"
const B := "1':1 2':1 3':1 5':1 3':1 2':1 1':1 5:1 | 2':1 3':1 4':1 6':1 4':1 3':1 2':1 6:1 | 3':1 4':1 5':1 7':1 5':1 4':1 3':1 7:1 | 1'':4 5':4 | 6':2 5':2 4':2 3':2 | 4':2 3':2 2':2 1':2 | 2':2 7:2 5:2 7:2 | 1':8"
const GUST := "1:16 1:16 1:16 1:16"
const CA := [1, 1, 6, 5, 1, 4, 5, 1]
const CB := [1, 4, 3, 1, 4, 5, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.09
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 48
	c.drums("X.xrX.xr", 0, 48, 0.9)
	c.drums("s.s.s.s.", 0, 48, 0.5)
	for r in 6:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.bass(ch, b, "x.xox.xo", 0.85)
		c.lead("surf", GUST, b, 8, 0.4)
		if r % 2 == 0:
			c.lead("brass", m, b, 8, 0.9)
			c.pad("brass", ch, b, 0.25, -12)
		else:
			c.lead("fiddle", m, b, 8, 0.9)
			c.lead("whistle", m, b, 8, 0.4, 12)
			c.strum("guitar", ch, b, "X.x.X.x.", 0.45)
		if r >= 2:
			c.lead("fiddle", m, b, 8, 0.45, 12 if r % 2 == 0 else -12)
		if r >= 4:
			c.lead("brass", m, b, 8, 0.5, -12 if r % 2 == 1 else 0)
			c.arp("harp", ch, b, "01230123", 0.4)
	return c
