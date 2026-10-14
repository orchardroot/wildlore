extends RefCounted
## North Channel ferry sting: a low horn blast in D, a chanter calls over a rolling harp, waves underneath. Does not loop.

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 50
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.25
	c.upb = 8
	c.bars = 2
	c.loop = false
	c.tail = 1.5
	c.lead("brass", "1,+5,+1:6 r:2", 0, 1, 0.9)
	c.lead("chanter", "5:1 1':1 2':1 3':1 5':1 3':1 2':1 1':1", 1, 1, 0.5)
	c.lead("harp", "1:1 3:1 5:1 1':1 3':1 5':1 1'':2", 1, 1, 0.4)
	c.drone(0, 2, 0.4)
	c._add("surf", 0.0, 14.0, 60, 0.4)
	return c
