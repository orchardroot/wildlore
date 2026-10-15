extends RefCounted
## The north: a brass band in B-flat, oom-pah bass and a march snare, warm and proud.

const A := "1:2 1:1 3:1 5:2 3:2 | 6:2 6:1 5:1 4:4 | 5:2 5:1 4:1 3:2 2:2 | 1:6 r:2 | 1:2 1:1 3:1 5:2 1':2 | 7:2 6:1 5:1 6:4 | 4:2 5:2 6:2 2':2 | 1':6 r:2"
const B := "5:2 6:2 7:2 1':2 | 2':4 7:2 5:2 | 3':2 3':1 2':1 1':2 7:2 | 1':8 | 6:2 6:1 7:1 1':2 2':2 | 3':4 5':4 | 4':2 3':2 2':2 7:2 | 1':6 r:2"
const CA := [1, 4, 5, 1, 1, 5, 4, 1]
const CB := [1, 5, 1, 1, 4, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 58
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.14
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 4:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.lead("brass", m, b, 8, 0.85)
		c.pad("brass", ch, b, 0.22, -12)
		c.bass(ch, b, "x.o.x.o.", 0.8)
		c.drums("X.r.x.r.", b, 8, 0.6)
		c.strum("guitar", ch, b, "..x...x.", 0.45)
		if r >= 1:
			c.lead("reed", m, b, 8, 0.4, 12)
		if r >= 2:
			c.lead("whistle", m, b, 8, 0.3, 12)
			c.drums("s.s.s.s.", b, 8, 0.4)
	return c
