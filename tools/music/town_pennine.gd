extends RefCounted
## The Pennines: an original slow chorale in A minor for a colliery brass band, with a whistle-like cornet descant above.

const A := "1:4 3:2 5:2 | 6:4 5:4 | 4:4 3:2 2:2 | 1:8 | 5:4 7:2 5:2 | 6:4 1':4 | 7:4 5:2 4:2 | 5:8"
const B := "3':4 1':4 | 6:4 4:4 | 5:2 6:2 7:2 5:2 | 1:8 | 1':4 7:2 6:2 | 5:4 4:2 3:2 | 4:4 2:2 5,:2 | 1:8"
const CA := [1, 6, 4, 1, 5, 6, 5, 5]
const CB := [1, 4, 5, 1, 6, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["aeolian"]
	c.unit = 0.3
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	for r in 1:
		var b := r * 16
		c.lead("brass", A, b, 8, 0.75)
		c.lead("brass", B, b + 8, 8, 0.75)
		c.pad("brass", CA, b, 0.22, -12)
		c.pad("brass", CB, b + 8, 0.22, -12)
		c.bass(CA, b, "x.......", 0.6)
		c.bass(CB, b + 8, "x.......", 0.6)
		c.lead("whistle", B, b + 8, 8, 0.25, 12)
	return c
