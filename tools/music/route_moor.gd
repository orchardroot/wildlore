extends RefCounted
## Moor: slow, open 6/8 in A dorian. Wide intervals, a long drone, a heartbeat of bodhran.

const A := "1':3 5:3 | 7:2 6:1 5:3 | 1':2 2':1 3':3 | 2':3 1':3 | 1':3 5:3 | 4':2 3':1 2':3 | 3':2 2':1 1':2 7:1 | 1':6"
const B := "5':3 4':1 3':2 | 2':3 3':1 2':2 | 1':3 2':1 3':2 | 5':6 | 6':2 5':1 4':2 3':1 | 2':2 1':1 7:2 6:1 | 5:3 6:1 7:2 | 1':6"
const CA := [1, 7, 1, 5, 1, 4, 1, 1]
const CB := [3, 5, 1, 3, 4, 5, 1, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.2
	c.upb = 6
	c.bars = 32
	for r in 2:
		var b := r * 16
		var inst := "whistle" if r == 0 else "fiddle"
		c.lead(inst, A, b, 8, 0.8)
		c.lead(inst, B, b + 8, 8, 0.8)
		if r == 1:
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
		c.arp("harp", CA, b, "0..1..", 0.5)
		c.arp("harp", CB, b + 8, "0..1..", 0.5)
		c.drums("X.....", b, 16, 0.4 if r == 0 else 0.55)
		c.drone(b, 8, 0.7)
		c.drone(b + 8, 8, 0.7)
	return c
