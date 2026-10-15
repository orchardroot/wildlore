extends RefCounted
## Keeper battle: the fastest, fullest reel, in E dorian. Pedal-point runs, doubled leads, drums and shaker in every bar.

const A := "1':1 1':1 5:1 1':1 3':1 1':1 5:1 1':1 | 7:1 7:1 5:1 7:1 2':1 7:1 5:1 7:1 | 6:1 6:1 5:1 6:1 1':1 6:1 5:1 6:1 | 5:2 6:1 7:1 1':4 | 1':1 1':1 5:1 1':1 3':1 1':1 5:1 1':1 | 3':1 3':1 1':1 3':1 5':1 3':1 1':1 3':1 | 4':1 3':1 2':1 1':1 7:1 6:1 5:1 4:1 | 5:2 7:2 2':2 5:2"
const B := "5':2 5':1 4':1 3':2 2':2 | 1':2 7:1 1':1 2':2 3':2 | 4':2 3':1 4':1 5':2 4':2 | 3':2 2':2 1':4 | 5':2 5':1 4':1 3':2 2':2 | 6':2 5':1 4':1 3':2 5':2 | 4':1 3':1 2':1 3':1 4':1 3':1 2':1 1':1 | 1':4 7:1 6:1 5:2"
const CA := [1, 7, 4, 1, 1, 1, 5, 5]
const CB := [1, 1, 4, 1, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 64
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.085
	c.upb = 8
	c.bars = 48
	c.level_db = 1.0
	for r in 3:
		var b := r * 16
		c.lead("fiddle", A, b, 8, 0.9)
		c.lead("fiddle", B, b + 8, 8, 0.9)
		c.lead("whistle", A, b, 8, 0.4, 12)
		c.lead("whistle", B, b + 8, 8, 0.4, 12)
		if r >= 1:
			c.lead("fiddle", A, b, 8, 0.35, -12)
			c.lead("fiddle", B, b + 8, 8, 0.35, -12)
		c.strum("guitar", CA, b, "XxxxXxxx" if r == 0 else "XxXxXxXx", 0.55)
		c.strum("guitar", CB, b + 8, "XxxxXxxx" if r == 0 else "XxXxXxXx", 0.55)
		c.bass(CA, b, "xxoxxxox", 0.75)
		c.bass(CB, b + 8, "xxoxxxox", 0.75)
		c.drums("XxxxXxxr", b, 16, 0.85)
		c.drums("ssssssss", b, 16, 0.5)
		c.drone(b, 16, 0.2)
	return c
