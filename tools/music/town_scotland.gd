extends RefCounted
## Scottish town: a strathspey in A mixolydian. Fiddle with Scotch snaps (short-long pairs) over a pipe-like drone,
## a harp arpeggiating underneath, and a chanter doubling the second strain. Steady and dignified.

const A := "1':4 7:1 1':3 5:4 3:4 | 6:4 5:1 6:3 7:4 5:4 | 1':4 7:1 1':3 3':4 1':4 | 7:4 5:2 7:2 1':4 r:4 | 1':4 7:1 1':3 5:4 3:4 | 6:2 6:2 5:1 6:3 7:2 1':2 2':4 | 3':4 2':1 3':3 1':4 7:1 5:3 | 1':12 r:4"
const B := "3':4 5':1 3':3 2':4 1':4 | 3':2 5':2 6':4 5':4 3':4 | 6':4 5':1 6':3 1'':4 6':4 | 5':4 3':2 2':2 1':4 r:4 | 3':4 5':1 3':3 2':4 1':4 | 2':2 3':2 5':4 3':4 2':4 | 1':4 7:1 1':3 3':4 5:4 | 1':12 r:4"
const CA := [1, 4, 1, 7, 1, 4, 1, 1]
const CB := [1, 7, 4, 1, 1, 5, 7, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 57
	c.mode = Composer.MODES["mixolydian"]
	c.unit = 0.125
	c.upb = 16
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("fiddle", A, 0, 8, 0.85)
	c.lead("fiddle", B, 8, 8, 0.9)
	c.lead("chanter", B, 8, 8, 0.3, 0)
	c.arp("harp", CA, 0, "0.1.2.3.2.1.0...", 0.4)
	c.arp("harp", CB, 8, "0.1.2.3.2.1.0...", 0.45)
	c.bass(CA, 0, "x...o...x...o...", 0.55)
	c.bass(CB, 8, "x...o...x...o...", 0.55)
	c.drums("X...r...x...r...", 0, 16, 0.5)
	c.drone(0, 16, 0.55)
	return c
