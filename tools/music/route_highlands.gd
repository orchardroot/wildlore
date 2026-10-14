extends RefCounted
## Highlands route: a slow air in D dorian. A low drone under everything, a lonely pipe on the tune,
## sparse harp, and wind moving over the tops. The drums only arrive for the second half.

const A := "5:4 r:2 3:2 | 1:6 2:2 | 3:4 5:4 | 6:6 5:2 | 5:4 3:2 2:2 | 1:6 r:2 | 7,:4 1:4 | 1:8"
const B := "1':4 7:2 6:2 | 5:6 3:2 | 6:4 5:2 3:2 | 2:8 | 3:4 5:4 | 7:4 6:2 5:2 | 3:4 2:2 1:2 | 1:8"
const CA := [1, 1, 7, 6, 1, 4, 7, 1]
const CB := [1, 5, 6, 7, 1, 5, 4, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 50
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.3
	c.upb = 8
	c.seam_fade = 0.02
	c.bars = 16
	c.lead("pipe", A, 0, 8, 0.8, 12)
	c.lead("pipe", B, 8, 8, 0.85, 12)
	c.lead("chanter", A, 0, 8, 0.2, 0)
	c.lead("whistle", B, 8, 8, 0.25, 12)
	c.arp("harp", CA, 0, "0.......", 0.3)
	c.arp("harp", CB, 8, "0...2...", 0.3)
	c.drone(0, 16, 0.7)
	c.drums("X.......", 8, 8, 0.35)
	c._add("surf", 0.0, 40.0, 60, 0.45)
	c._add("surf", 60.0, 40.0, 60, 0.4)
	c._add("surf", 100.0, 28.0, 60, 0.35)
	return c
