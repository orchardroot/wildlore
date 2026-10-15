extends RefCounted
## London: quick, bright and a little cheeky. Syncopated whistle over off-beat guitar and a walking bass.

const A := "5:1 5:1 r:1 3:1 5:1 6:1 5:2 | 3:1 3:1 r:1 1:1 3:1 5:1 3:2 | 4:1 4:1 r:1 6:1 4:1 2:1 4:2 | 5:2 7:1 2':1 5:2 r:2 | 5:1 5:1 r:1 3:1 5:1 6:1 5:2 | 1':1 7:1 6:1 5:1 6:1 5:1 3:2 | 2:1 4:1 6:1 4:1 2:1 4:1 7,:1 2:1 | 1:6 r:2"
const B := "1':2 1':1 3':1 5':2 3':2 | 2':2 2':1 4':1 6':2 4':2 | 1':1 7:1 6:1 5:1 4:1 3:1 2:1 1:1 | 5:4 r:1 5:1 7:1 2':1 | 3':2 3':1 1':1 5:2 3':2 | 4':2 4':1 2':1 6:2 4':2 | 5':1 4':1 3':1 2':1 1':1 7:1 6:1 5:1 | 1':4 5':2 1'':2"
const CA := [1, 1, 4, 5, 1, 6, 5, 1]
const CB := [1, 4, 1, 5, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 60
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.11
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 40
	for r in 5:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.strum("guitar", ch, b, "..x.X.x.", 0.55)
		c.bass(ch, b, "x.o.x.ox", 0.75)
		c.drums("X.r.x.r.", b, 8, 0.6)
		c.drums("s.s.s.s.", b, 8, 0.5)
		match r:
			0:
				c.lead("whistle", m, b, 8, 0.85)
			1:
				c.lead("reed", m, b, 8, 0.8)
				c.lead("whistle", m, b, 8, 0.35, 12)
			2:
				c.lead("fiddle", m, b, 8, 0.85)
				c.lead("whistle", m, b, 8, 0.4)
			3:
				c.lead("whistle", m, b, 8, 0.8)
				c.lead("fiddle", m, b, 8, 0.55, -12)
				c.lead("bell", m, b, 8, 0.3, 12)
			4:
				c.lead("fiddle", m, b, 8, 0.85)
				c.lead("whistle", m, b, 8, 0.5, 12)
				c.lead("brass", m, b, 8, 0.4)
	return c
