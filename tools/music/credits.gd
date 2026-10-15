extends RefCounted
## Credits: gentle A major, harp and whistle with soft fiddle, unhurried. Does not loop (the player can loop it once).

const A := "1:4 3:4 | 5:6 3:2 | 6:4 5:4 | 3:8 | 2:4 4:4 | 6:6 4:2 | 5:4 3:2 2:2 | 1:8"
const B := "3:4 5:4 | 1':6 7:2 | 6:4 4:4 | 5:8 | 4:4 6:4 | 2':6 7:2 | 1':4 5:2 3:2 | 1:8"
const CA := [1, 1, 4, 6, 2, 4, 5, 1]
const CB := [1, 1, 4, 1, 4, 5, 1, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.22
	c.upb = 8
	c.bars = 40
	c.loop = false
	c.tail = 3.0
	for r in 5:
		var b := r * 8
		var m := A if r % 2 == 0 else B
		var ch: Array = CA if r % 2 == 0 else CB
		c.arp("harp", ch, b, "01232101", 0.5)
		c.pad("fiddle", ch, b, 0.15, -12)
		match r:
			0:
				c.lead("whistle", m, b, 8, 0.65)
			1:
				c.lead("whistle", m, b, 8, 0.7)
				c.lead("fiddle", m, b, 8, 0.3, -12)
			2:
				c.lead("fiddle", m, b, 8, 0.7)
				c.lead("whistle", m, b, 8, 0.3, 12)
			3:
				c.lead("whistle", m, b, 8, 0.75)
				c.lead("fiddle", m, b, 8, 0.5)
				c.drone(b, 8, 0.3)
			4:
				c.lead("whistle", m, b, 8, 0.6)
				c.drone(b, 8, 0.3)
	return c
