extends RefCounted
## Legend: Black Shuck. G minor, very sparse. A heartbeat, a cold drone and wind, with a long howling whistle.

const HOWL := "r:8 | 1':6 7:2 | 6:8 | r:4 5:4 | b2':6 1':2 | 7:8 | 5:4 b2:2 1:2 | r:8"
const LOW := "1:2 b2:2 1:2 7,:2 | 1:8 | 3:2 4:2 3:2 b2:2 | 1:8 | 5:2 6:2 5:2 4:2 | 3:4 b2:4 | 1:6 7,:2 | 1:8"
const WIND := "1:16 1:16 1:16 1:16"
const CA := [1, 1, 6, 1, 4, 7, 1, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 43
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.17
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 24
	c.drone(0, 24, 0.6)
	c.drums("X.x.....", 0, 24, 0.6)
	for r in 3:
		var b := r * 8
		c.lead("surf", WIND, b, 8, 0.3 + 0.1 * r)
		match r:
			0:
				c.lead("whistle", HOWL, b, 8, 0.7)
			1:
				c.lead("fiddle", LOW, b, 8, 0.5)
				c.lead("whistle", HOWL, b, 8, 0.45, 12)
			2:
				c.lead("whistle", HOWL, b, 8, 0.85)
				c.lead("pipe", HOWL, b, 8, 0.4, -12)
				c.lead("brass", LOW, b, 8, 0.4, -12)
				c.bass(CA, b, "x.......", 0.7)
	return c
