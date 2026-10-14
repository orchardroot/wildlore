extends RefCounted
## Irish Sea ferry sting: one long horn blast in G, then a whistle climbs over a rising harp figure. Does not loop.

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.25
	c.upb = 8
	c.bars = 2
	c.loop = false
	c.tail = 1.0
	c.lead("brass", "1,+5,+1:6 r:2", 0, 1, 0.9)
	c.lead("whistle", "5:1 1':1 2':1 3':1 5':2 3':2", 1, 1, 0.55)
	c.lead("harp", "1:1 3:1 5:1 1':1 3':1 5':1 1'':2", 1, 1, 0.4)
	c.drone(0, 2, 0.3)
	return c
