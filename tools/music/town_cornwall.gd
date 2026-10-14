extends RefCounted
## Cornish harbour: a fishing song in 6/8, C major. An accordion-ish reed carries the tune over oom-pah chords,
## and the whole quay joins in an octave down on the second verse.

const A := "5:2 1':1 1':2 1':1 | 3':2 1':1 5:3 | 6:2 6:1 6':2 5':1 | 3':3 1':3 | 5:2 1':1 1':2 1':1 | 3':2 5':1 3':2 1':1 | 2':2 7:1 2':2 4':1 | 1':5 r:1"
const B := "5':2 5':1 5':2 3':1 | 6':2 5':1 3':3 | 4':2 4':1 4':2 3':1 | 2':3 5:3 | 5':2 5':1 5':2 3':1 | 6':2 5':1 3':2 1':1 | 2':2 3':1 2':2 7:1 | 1':5 r:1"
const CA := [1, 1, 4, 1, 1, 1, 5, 1]
const CB := [1, 1, 4, 5, 1, 1, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 60
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.2
	c.upb = 6
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("reed", A, b, 8, 0.85)
		c.lead("reed", B, b + 8, 8, 0.85)
		if r == 1:
			c.lead("reed", A, b, 8, 0.35, -12)
			c.lead("reed", B, b + 8, 8, 0.35, -12)
			c.lead("whistle", B, b + 8, 8, 0.25, 12)
		c.strum("reed", CA, b, "X..x..", 0.4, -12)
		c.strum("reed", CB, b + 8, "X..x..", 0.4, -12)
		c.bass(CA, b, "x..o..", 0.65)
		c.bass(CB, b + 8, "x..o..", 0.65)
		c.drums("X..r.r" if r == 0 else "X.rx.r", b, 16, 0.45)
	return c
