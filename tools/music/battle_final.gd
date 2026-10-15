extends RefCounted
## Vane: B minor. Pompous brass fanfares that keep slipping into flat-second menace over a relentless, hammering bass.

const A := "1:3 1:1 3:2 5:2 | 1':4 7:2 5:2 | 6:3 6:1 5:2 3:2 | 4:4 #4:2 5:2 | 1:3 1:1 3:2 5:2 | 1':3 2':1 4':4 | 7:2 6:2 5:2 b2:2 | 1:8"
const B := "5':1 b2':1 5':1 b2':1 5':1 b2':1 5':2 | 4':1 3':1 4':1 3':1 4':1 3':1 4':2 | 5':1 b2':1 5':1 b2':1 5':1 6':1 7':2 | 1'':4 r:4 | 6':2 5':2 4':2 3':2 | 4':2 3':2 b2':2 1':2 | #4':2 5':2 6':2 b2'':2 | 1'':8"
const CA := [1, 1, 6, 4, 1, 4, 5, 1]
const CB := [1, 6, 1, 1, 6, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 47
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.1
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 48
	c.drone(0, 48, 0.5)
	c.drums("X.XxX.Xx", 0, 48, 1.0)
	c.drums("r.rr.rr.", 0, 48, 0.5)
	for r in 6:
		var b := r * 8
		var m := B if r in [1, 3, 4] else A
		var ch: Array = CB if r in [1, 3, 4] else CA
		c.bass(ch, b, "xxxxxxxo", 0.85)
		match r:
			0:
				c.lead("brass", m, b, 8, 0.85)
				c.pad("brass", ch, b, 0.2, -12)
			1:
				c.lead("fiddle", m, b, 8, 0.9)
				c.lead("brass", m, b, 8, 0.5, -12)
			2:
				c.lead("brass", m, b, 8, 0.9)
				c.lead("fiddle", m, b, 8, 0.7)
				c.strum("bouzouki", ch, b, "X.xxX.xx", 0.5)
			3:
				c.lead("fiddle", m, b, 8, 0.95)
				c.lead("brass", m, b, 8, 0.7)
				c.lead("whistle", m, b, 8, 0.4, 12)
				c.pad("brass", ch, b, 0.25, -12)
			4:
				c.lead("brass", m, b, 8, 0.95)
				c.lead("pipe", m, b, 8, 0.5, 12)
				c.arp("harp", ch, b, "01230123", 0.4)
			5:
				c.lead("brass", m, b, 8, 0.95)
				c.lead("fiddle", m, b, 8, 0.8, 12)
				c.pad("brass", ch, b, 0.3, -12)
				c.strum("bouzouki", ch, b, "X.xxX.xx", 0.5)
	return c
