extends RefCounted
## Ferry sting: two long blasts of a ship's horn in D, then a small rising harp figure. Does not loop.

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 50
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.25
	c.upb = 8
	c.bars = 2
	c.loop = false
	c.tail = 1.2
	c.lead("brass", "1,+5,+1:6 r:2", 0, 1, 0.9)
	c.lead("brass", "1,+5,+1:2 r:1 1,+5,+1:4 r:1", 1, 1, 0.9)
	c.lead("harp", "1:1 3:1 5:1 1':1 3':1 5':1 1'':2", 1, 1, 0.4)
	c.drone(0, 2, 0.3)
	return c
