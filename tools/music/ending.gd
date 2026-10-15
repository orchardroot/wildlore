extends RefCounted
## Ending: a long, warm reprise of the title air in D dorian. It starts as a lone whistle, gathers fiddle, bass, harp,
## brass and bells, then settles into a slow final cadence. Does not loop.

const T := preload("res://tools/music/title.gd")
const CODA := "5:2 1':3 2':1 3':2 | 2':4 1':2 7:2 | 6:2 5:3 3:1 5:2 | 4:4 5:4 | 3':4 2':2 1':2 | 5:4 7:2 2':2 | 1':4 3':2 5':2 | 1':8"
const CCODA := [1, 7, 1, 4, 3, 5, 1, 1]
const BELLS := "1':2 r:6 r:8 5:2 r:6 r:8 1':2 r:6 r:8 5:2 r:6 1'':4 r:4"

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.18
	c.upb = 8
	c.bars = 48
	c.level_db = -1.0
	c.loop = false
	c.tail = 3.0
	for r in 6:
		var b := r * 8
		var m: String = T.A if r % 2 == 0 else T.B
		var ch: Array = T.CA if r % 2 == 0 else T.CB
		if r == 5:
			m = CODA
			ch = CCODA
		c.arp("harp", ch, b, "01212101", 0.35 + 0.05 * minf(r, 4))
		c.drone(b, 8, 0.3)
		match r:
			0:
				c.lead("whistle", m, b, 8, 0.7)
			1:
				c.lead("whistle", m, b, 8, 0.8)
				c.pad("fiddle", ch, b, 0.15, -12)
			2:
				c.lead("fiddle", m, b, 8, 0.8)
				c.lead("whistle", m, b, 8, 0.3, 12)
				c.bass(ch, b, "x...o...", 0.5)
				c.pad("fiddle", ch, b, 0.15, -12)
			3:
				c.lead("fiddle", m, b, 8, 0.85)
				c.lead("whistle", m, b, 8, 0.35, 12)
				c.bass(ch, b, "x...o...", 0.6)
				c.drums("X...x.r.", b, 8, 0.45)
				c.pad("brass", ch, b, 0.2, -12)
			4:
				c.lead("fiddle", m, b, 8, 0.9)
				c.lead("whistle", m, b, 8, 0.4, 12)
				c.lead("brass", m, b, 8, 0.45, -12)
				c.lead("reed", m, b, 8, 0.3)
				c.bass(ch, b, "x...o...", 0.7)
				c.drums("X...x.r.", b, 8, 0.6)
				c.pad("brass", ch, b, 0.25, -12)
				c.lead("bell", BELLS, b, 8, 0.5, -12)
			5:
				c.lead("fiddle", m, b, 8, 0.8)
				c.lead("whistle", m, b, 8, 0.4, 12)
				c.lead("brass", m, b, 8, 0.3, -12)
				c.pad("fiddle", ch, b, 0.2, -12)
				c.bass(ch, b, "x.......", 0.5)
				c.lead("bell", "1'':3 r:61", b, 8, 0.5, -12)
	return c
