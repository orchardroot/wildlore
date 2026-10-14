extends RefCounted
## Legend: the Green Man. F dorian, an old pipe tune that climbs one step higher every four bars over earthy frame drums
## and a deep drone; the rest of the wood joins as it rises.

const P1 := "1:4 3:2 5:2 | 1:4 5:4 | 6:4 5:2 3:2 | 5:8"
const P2 := "5:4 6:2 1':2 | 5:4 1':4 | 2':4 1':2 6:2 | 1':8"
const P3 := "1':4 2':2 3':2 | 1':4 3':4 | 4':4 3':2 2':2 | 3':8"
const P4 := "3':2 5':2 3':2 5':2 | 6':2 5':2 3':2 5':2 | 1'':4 7':2 5':2 | 6':8"
const P5 := "1'':4 7':2 6':2 | 5':4 3':4 | 1'':2 7':2 6':2 5':2 | 1'':8"
const CH := [1, 1, 6, 1, 1, 4, 6, 1, 1, 3, 4, 1, 3, 1, 6, 5, 1, 5, 6, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 53
	c.mode = Composer.MODES["dorian"]
	c.unit = 0.2
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 20
	c.lead("pipe", P1, 0, 4, 0.9, 12)
	c.lead("pipe", P2, 4, 4, 0.95, 12)
	c.lead("pipe", P3, 8, 4, 1.0, 12)
	c.lead("whistle", P3, 8, 4, 0.35, 12)
	c.lead("pipe", P4, 12, 4, 1.0, 12)
	c.lead("fiddle", P4, 12, 4, 0.5, 0)
	c.lead("pipe", P5, 16, 4, 1.0, 12)
	c.lead("fiddle", P5, 16, 4, 0.7, 0)
	c.lead("brass", P5, 16, 4, 0.35, -12)
	c.drone(0, 20, 0.5)
	c.drums("X...x...", 0, 4, 0.7)
	c.drums("X.x.X.x.", 4, 4, 0.75)
	c.drums("X.xxX.xx", 8, 4, 0.85)
	c.drums("XxxXXxxX", 12, 8, 1.0)
	c.drums("r.r.r.r.", 12, 8, 0.5)
	c.bass(CH.slice(8), 8, "x...x...", 0.7)
	return c
