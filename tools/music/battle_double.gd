extends RefCounted
## Double battle: faster and more urgent than the trainer reel. E aeolian, stabbing fiddle over a chugging guitar and bass.

const A := "1':2 7:1 1':1 2':2 1':1 7:1 | 6:2 5:1 6:1 7:2 5:2 | 1':2 7:1 1':1 2':2 3':1 2':1 | 1':3 7:1 5:4 | 1':2 7:1 1':1 2':2 1':1 7:1 | 6:2 5:1 6:1 7:2 2':2 | 3':2 2':1 3':1 4':2 3':1 2':1 | 1':2 7:2 5:2 7:2"
const B := "5':1 5':1 3':1 5':1 6':2 5':2 | 4':1 4':1 2':1 4':1 5':2 4':2 | 3':1 3':1 1':1 3':1 4':2 3':2 | 2':2 1':2 7:2 5:2 | 5':1 5':1 3':1 5':1 6':2 5':2 | 4':1 4':1 2':1 4':1 5':2 7':2 | 1'':2 7':1 6':1 5':2 3':2 | 1':6 r:2"
const CA := [1, 6, 1, 5, 1, 6, 7, 5]
const CB := [1, 4, 1, 6, 1, 4, 3, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 64
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.08
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 48
	for r in 3:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.9)
		c.lead("fiddle", B, b + 8, 8, 0.9)
		c.lead("whistle", A, b, 8, 0.3 if r > 0 else 0.15, 12)
		c.lead("whistle", B, b + 8, 8, 0.3 if r > 0 else 0.15, 12)
		if r == 2:
			c.lead("brass", A, b, 8, 0.35, -12)
			c.lead("brass", B, b + 8, 8, 0.35, -12)
		c.strum("guitar", CA, b, "XxXxXxXx", 0.5)
		c.strum("guitar", CB, b + 8, "XxXxXxXx", 0.5)
		c.bass(CA, b, "xxoxxoxo", 0.75)
		c.bass(CB, b + 8, "xxoxxoxo", 0.75)
		c.drums("XxrXxrXr", b, 16, 0.8)
		c.drums("s.s.s.s.", b, 16, 0.6)
	return c
