extends RefCounted
## The Moors: A aeolian, a lonely brass line over a low drone, wind sweeping past and the odd harp note.

const A := "1:6 r:2 | 5,:4 7,:2 1:2 | 3:6 2:2 | 1:8 | 6,:4 1:2 3:2 | 2:3 1:1 7,:4 | 5,:6 r:2 | 1:8"
const B := "3:4 5:2 3:2 | 6:6 5:2 | 4:4 3:2 2:2 | 3:8 | 5:4 3:2 5:2 | 6:4 7:2 6:2 | 5:4 3:2 2:2 | 1:8"
const WIND := "1:16 1:16 1:16 1:16"
const CA := [1, 5, 6, 1, 4, 5, 1, 1]
const CB := [1, 6, 4, 1, 3, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.2
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 24
	c.drone(0, 24, 0.5)
	for r in 3:
		var b := r * 8
		var m := B if r == 1 else A
		var ch: Array = CB if r == 1 else CA
		c.lead("surf", WIND, b, 8, 0.45)
		c.lead("brass", m, b, 8, 0.65 if r != 1 else 0.8)
		c.arp("harp", ch, b, "0...2...", 0.35 if r != 1 else 0.5)
		if r == 1:
			c.lead("whistle", m, b, 8, 0.25, 12)
		if r == 2:
			c.lead("reed", m, b, 8, 0.3, 12)
			c.drums("X.......", b, 8, 0.3)
	return c
