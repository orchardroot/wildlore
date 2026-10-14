extends RefCounted
## Southern moor: Dartmoor in mist. E dorian, a very low drone, a distant pipe with long gaps, and the odd high harp note.

const PIPE := "r:8 | 5:3 r:1 3:4 | 2:6 r:2 | r:4 3:2 5:2 | 6:4 5:2 3:2 | 3:8 | r:2 2:2 3:2 2:2 | 1:6 r:2 | r:8 | 5,:4 r:4"
const HARP := "r:8 | r:8 | 5':1 r:7 | r:8 | r:6 3':1 r:1 | r:8 | r:8 | 1':1 r:7 | r:8 | r:8"

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 52
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.42
	c.upb = 8
	c.seam_fade = 0.2
	c.bars = 10
	c.lead("pipe", PIPE, 0, 10, 0.7, 12)
	c.lead("pipe", PIPE, 0, 10, 0.12, 24)
	c.lead("harp", HARP, 0, 10, 0.3, 12)
	c.drone(0, 10, 0.55)
	for k in 3:
		c._add("surf", float((k * 3 + 1) * 8), 20.0, 60, 0.45)
	return c
