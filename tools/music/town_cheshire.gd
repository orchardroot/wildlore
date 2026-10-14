extends RefCounted
## Cheshire town: an easy-going reel in G mixolydian, guitar strum under a whistle, then fiddle.

const A := "3:1 5:1 1':2 7:1 5:1 3:2 | 4:1 6:1 1':2 6:1 4:1 6:2 | 3:1 5:1 1':2 2':1 3':1 2':2 | 1':2 7:2 5:4 | 3:1 5:1 1':2 7:1 5:1 3:2 | 6:1 1':1 3':2 2':1 1':1 6:2 | 5:2 7:2 2':2 7:2 | 1':6 r:2"
const B := "1':2 7:1 6:1 5:2 3:2 | 4:2 5:1 6:1 5:2 4:2 | 3:2 4:1 5:1 6:2 5:2 | 7:2 5:2 3:2 5:2 | 1':2 7:1 6:1 5:2 3:2 | 4:1 6:1 1':2 6:2 4:2 | 5:2 4:2 3:2 2:2 | 1:6 r:2"
const CA := [1, 4, 1, 5, 1, 4, 5, 1]
const CB := [1, 4, 1, 5, 1, 4, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 67
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.15
	c.upb = 8
	c.bars = 32
	for r in 2:
		var b := r * 16
		var inst := "whistle" if r == 0 else "fiddle"
		c.lead(inst, A, b, 8, 0.8)
		c.lead(inst, B, b + 8, 8, 0.8)
		c.strum("guitar", CA, b, "X.x.X.x.", 0.5)
		c.strum("guitar", CB, b + 8, "X.x.X.x.", 0.5)
		c.bass(CA, b, "x.o.x.o.", 0.6)
		c.bass(CB, b + 8, "x.o.x.o.", 0.6)
		c.drums("X.x.X.xr" if r == 1 else "X...x...", b, 16, 0.6)
		if r == 1:
			c.arp("harp", CA, b, "0.1.2.3.", 0.4)
			c.arp("harp", CB, b + 8, "0.1.2.3.", 0.4)
		c.drone(b, 16, 0.25)
	return c
