extends RefCounted
## Cornwall: an original lilting air in G, sung by a male voice choir over a quiet harp, a whistle floating above on the second verse.

const A := "5:2 1':2 3':2 | 2':3 1':3 | 7:2 6:2 5:2 | 5:6 | 5:2 1':2 3':2 | 5':3 3':3 | 4':2 2':2 7:2 | 1':6"
const B := "3':2 3':2 5':2 | 4':3 3':3 | 2':2 2':2 4':2 | 3':6 | 1':2 7:2 6:2 | 5:2 6:2 7:2 | 2':2 7:2 5:2 | 1':6"
const CA := [1, 5, 5, 1, 1, 1, 5, 1]
const CB := [1, 4, 5, 1, 4, 5, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.22
	c.upb = 6
	c.seam_fade = 0.012
	c.bars = 32
	for r in 2:
		var b := r * 16
		c.lead("choir", A, b, 8, 0.8)
		c.lead("choir", B, b + 8, 8, 0.8)
		c.pad("choir", CA, b, 0.16, -12)
		c.pad("choir", CB, b + 8, 0.16, -12)
		c.arp("harp", CA, b, "012321", 0.35)
		c.arp("harp", CB, b + 8, "012321", 0.35)
		c.bass(CA, b, "x..o..", 0.5)
		c.bass(CB, b + 8, "x..o..", 0.5)
		if r == 1:
			c.lead("whistle", A, b, 8, 0.3, 12)
			c.lead("whistle", B, b + 8, 8, 0.3, 12)
	return c
