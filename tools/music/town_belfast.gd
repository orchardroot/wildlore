extends RefCounted
## Belfast town: a bright, jaunty hornpipe in G major. Dotted pairs on the fiddle and accordion, whistle on the turns,
## a ship's-bell harp on the beat and a brisk rim tick.

const A := "5:1.5 1':.5 1':1.5 5:.5 3:1.5 5:.5 1':1.5 3':.5 | 2':1.5 7:.5 5:1.5 2:.5 7,:2 5,:2 | 1':1.5 3':.5 5':1.5 3':.5 1':1.5 5:.5 3:1 5:1 | 2':1.5 1':.5 7:1.5 6:.5 5:4 | 5:1.5 1':.5 1':1.5 5:.5 3:1.5 5:.5 1':1.5 3':.5 | 4':1.5 6':.5 4':1.5 2':.5 5':1.5 2':.5 7:1 2':1 | 1':1.5 3':.5 5':1.5 3':.5 2':1.5 7:.5 6:1 5:1 | 1':6 r:2"
const B := "3':1.5 5':.5 3':1.5 1':.5 3':1.5 5':.5 6':2 | 5':1.5 3':.5 2':1.5 3':.5 5':4 | 4':1.5 6':.5 4':1.5 2':.5 4':1.5 6':.5 1'':2 | 7':1.5 5':.5 2':1.5 7:.5 5:4 | 3':1.5 5':.5 3':1.5 1':.5 3':1.5 5':.5 6':2 | 2':1.5 3':.5 4':1.5 2':.5 5':1.5 3':.5 1':2 | 7:1.5 2':.5 5':1.5 2':.5 7':1.5 5':.5 2':2 | 1'':6 r:2"
const CA := [1, 5, 1, 5, 1, 4, 1, 1]
const CB := [1, 5, 4, 5, 1, 5, 5, 1]

static func build() -> Composer:
	var c := Composer.new()
	c.tonic = 55
	c.mode = Composer.MODES["ionian"]
	c.unit = 0.25
	c.upb = 8
	c.seam_fade = 0.012
	c.bars = 16
	c.lead("fiddle", A, 0, 8, 0.8)
	c.lead("reed", A, 0, 8, 0.35, -12)
	c.lead("fiddle", B, 8, 8, 0.85)
	c.lead("whistle", B, 8, 8, 0.4, 12)
	c.lead("reed", B, 8, 8, 0.3, -12)
	c.strum("guitar", CA, 0, "X.x.X.x.", 0.5)
	c.strum("guitar", CB, 8, "X.x.X.x.", 0.55)
	c.bass(CA, 0, "x.o.x.o.", 0.6)
	c.bass(CB, 8, "x.o.x.o.", 0.6)
	c.arp("harp", CB, 8, "3.......", 0.3)
	c.drums("XsrsXsrs", 0, 16, 0.6)
	return c
