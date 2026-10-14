extends RefCounted
## Irish town: a lively session reel in D mixolydian. Fiddle leads, tin whistle joins an octave up on the second pass,
## bouzouki chops the chords and a bodhran pushes the pulse.

const A := "5:1 1':1 1':1 7:1 1':1 2':1 3':1 1':1 | 7:1 5:1 5:1 3:1 5:1 7:1 5:1 3:1 | 4:1 6:1 6:1 1':1 6:1 1':1 3':1 6:1 | 5:2 3:1 5:1 7:2 2':2 | 5:1 1':1 1':1 7:1 1':1 2':1 3':1 1':1 | 7:1 5:1 5:1 3:1 5:1 7:1 2':1 7:1 | 6:1 1':1 3':1 1':1 6:1 1':1 5:1 6:1 | 7:1 5:1 3:1 5:1 1':4"
const B := "3':2 3':1 5':1 3':1 2':1 1':1 7:1 | 1':1 2':1 3':1 1':1 7:2 5:2 | 6':2 6':1 5':1 3':1 5':1 6':2 | 5':1 3':1 2':1 3':1 5':4 | 3':2 3':1 5':1 3':1 2':1 1':1 7:1 | 1':1 2':1 3':1 4':1 5':2 3':2 | 6':1 5':1 3':1 2':1 1':1 7:1 5:1 7:1 | 1':6 r:2"
const CA := [1, 7, 4, 1, 1, 7, 4, 1]
const CB := [1, 1, 4, 1, 1, 4, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 62
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.17
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.85)
		c.lead("fiddle", B, b + 8, 8, 0.85)
		if r == 1:
			c.lead("whistle", A, b, 8, 0.4, 12)
			c.lead("whistle", B, b + 8, 8, 0.4, 12)
		else:
			c.lead("whistle", B, b + 8, 8, 0.25, 0)
		c.strum("bouzouki", CA, b, "X.xxX.xx", 0.55)
		c.strum("bouzouki", CB, b + 8, "X.xxX.xx", 0.55)
		c.bass(CA, b, "x.xox.xo", 0.6)
		c.bass(CB, b + 8, "x.xox.xo", 0.6)
		c.drums("XxrXxrXx" if r == 0 else "XxrXxrXr", b, 16, 0.7)
	return c
