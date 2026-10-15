extends RefCounted
## The Underground: E aeolian. A relentless chugging pulse like wheels on rails, a thin reed line and a sour brass swell.

const A := "1:3 r:1 1:1 b2:1 1:2 | 5:3 r:1 5:1 4:1 3:2 | 1:3 r:1 1:1 b2:1 1:2 | 7,:4 5,:4 | 3:3 r:1 3:1 4:1 5:2 | 6:3 r:1 5:1 4:1 3:2 | 4:2 3:2 2:2 b2:2 | 1:8"
const B := "5':1 r:1 5':1 r:1 5':1 4':1 3':2 | 4':1 r:1 4':1 r:1 4':1 3':1 b2':2 | 5':1 r:1 5':1 r:1 5':1 6':1 7':2 | 1'':4 5':4 | 6':2 5':2 4':2 3':2 | 4':2 3':2 b2':2 1':2 | 7:2 1':2 b2':2 7:2 | 1':6 r:2"
const CA := [1, 5, 1, 7, 3, 6, 4, 1]
const CB := [1, 4, 1, 5, 6, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 40
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.1
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 40
	c.drone(0, 40, 0.5)
	for k in 40:
		c.bass([1], k, "x.xxx.xo", 0.65 if k < 8 else 0.8)
	c.drums("X.sxX.sx", 0, 40, 0.7)
	c.drums("s.s.s.s.", 0, 40, 0.5)
	c.drums("..r...r.", 8, 32, 0.5)
	for r in 5:
		var b := r * 8
		var m := B if r in [2, 3] else A
		var ch: Array = CB if r in [2, 3] else CA
		match r:
			0:
				c.lead("reed", m, b, 8, 0.6)
			1:
				c.lead("reed", m, b, 8, 0.6)
				c.lead("fiddle", m, b, 8, 0.4, -12)
			2:
				c.lead("fiddle", m, b, 8, 0.8)
				c.lead("brass", m, b, 8, 0.45, -12)
			3:
				c.lead("brass", m, b, 8, 0.55)
				c.lead("whistle", m, b, 8, 0.4, 12)
				c.pad("brass", ch, b, 0.2, -12)
			4:
				c.lead("reed", m, b, 8, 0.55)
	return c
