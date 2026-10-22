class_name BordersStyles
extends RefCounted
## 4.5 "Borders and neighbours": La Linea de la Concepcion across the frontier from Gibraltar, and Nicosia, both
## sides of the Green Line, reached by the road north from Dhekelia through Pyla. Called from Landmarks.building via
## build(). Same rules as Landmarks: vertex colour, low poly, origin at the footprint's north-west corner, door on the
## south face. Flags are painted into the styles themselves (the Spanish one on the frontier post, the UN's on its
## tower); nothing in Nicosia flies a national flag here, on either side.

const STYLES := ["andaluz_house", "andaluz_church", "frontier_post", "fort_ruin", "venetian_gate", "venetian_wall",
	"selimiye", "han", "kioski_house", "orthodox_church", "checkpoint_booth", "un_tower"]

const WHITEWASH := Color("f2efe6")
const OCHRE := Color("d9a441")
const ALBERO := Color("d8b26a")      # the yellow-ochre trim of Andalusian houses
const PANTILE := Color("b4623e")
const IRON := Color("2a2a30")
const CYPRUS_STONE := Color("d9c49a")  # the honey limestone of old Nicosia
const DARK_WOOD := Color("5a3a26")
const UN_BLUE := Color("4b92db")
const DOORS := [Color("2f5d8a"), Color("3e6b4a"), Color("7a2e2a"), Color("5a3a26")]

static func build(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator, style: String) -> void:
	match style:
		"andaluz_house":
			andaluz_house(st, wst, w, d, door_x, rng)
		"andaluz_church":
			andaluz_church(st, wst, w, d, door_x)
		"frontier_post":
			frontier_post(st, wst, w, d, door_x)
		"fort_ruin":
			fort_ruin(st, w, d, rng)
		"venetian_gate":
			venetian_gate(st, wst, w, d, door_x)
		"venetian_wall":
			venetian_wall(st, w, d, rng)
		"orthodox_church":
			orthodox_church(st, wst, w, d, door_x, rng)
		"selimiye":
			selimiye(st, wst, w, d, door_x, rng)
		"han":
			han(st, wst, w, d, door_x, rng)
		"kioski_house":
			kioski_house(st, wst, w, d, door_x, rng)
		"checkpoint_booth":
			checkpoint_booth(st, wst, w, d, door_x)
		"un_tower":
			un_tower(st, wst, w, d, door_x)

## An Andalusian town house: whitewash over a yellow-ochre plinth, a terracotta pantile roof, black iron window
## grilles (rejas) on the ground floor, a little balcony above, and geraniums in pots on the wall.
static func andaluz_house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var storeys := 2 if rng.randf() < 0.75 else 3
	var h := 1.1 * storeys + 0.15
	var wall := WHITEWASH.darkened(rng.randf() * 0.05)
	var trim: Color = ALBERO if rng.randf() < 0.6 else Color("c7a07a")
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall)
	Meshes.box(st, Vector3(0.0, 0.0, d - 0.1), Vector3(w, 0.32, 0.08), trim)                       # the painted plinth
	Meshes.box(st, Vector3(-0.04, h, -0.04), Vector3(w + 0.08, 0.1, d + 0.08), trim)               # eaves band
	Landmarks._roof_at(st, -0.05, w + 0.05, 0.0, d, h + 0.1, 0.5, PANTILE, wall)
	var door_col: Color = DOORS[rng.randi() % DOORS.size()]
	for s in range(storeys):
		for x in range(w):
			if s == 0 and x == door_x:
				continue
			var y := 0.4 + s * 1.1
			Landmarks._window(st, wst, x + 0.25, y, d, 0.5, 0.7, trim)
			if s == 0:
				for i in range(4):                                                                   # the reja
					Meshes.box(st, Vector3(x + 0.27 + i * 0.14, y - 0.02, d + 0.02), Vector3(0.03, 0.74, 0.03), IRON)
				Meshes.box(st, Vector3(x + 0.22, y + 0.3, d + 0.02), Vector3(0.56, 0.03, 0.03), IRON)
			elif s == 1 and (x + rng.randi()) % 2 == 0:
				Meshes.box(st, Vector3(x + 0.12, y - 0.04, d), Vector3(0.76, 0.05, 0.26), IRON)        # balcony
				Meshes.box(st, Vector3(x + 0.12, y + 0.3, d + 0.24), Vector3(0.76, 0.04, 0.03), IRON)
			if rng.randf() < 0.45:
				Meshes.box(st, Vector3(x + 0.1, y + 0.9, d + 0.02), Vector3(0.14, 0.12, 0.1), PANTILE)  # a geranium pot
				Meshes.box(st, Vector3(x + 0.09, y + 1.02, d + 0.03), Vector3(0.16, 0.08, 0.1), Color("c8283a"))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.06), Vector3(0.8, 1.1, 0.04), trim)
		Meshes.box(st, Vector3(door_x + 0.22, 0.16, d - 0.08), Vector3(0.56, 0.9, 0.06), door_col)

## A whitewashed Andalusian parish church: a long nave with a pantile roof, ochre pilasters and a square bell tower
## with an open belfry and a tiled spire at the west end. The door sits under a round arch.
static func andaluz_church(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var h := 2.6
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), WHITEWASH)
	Meshes.box(st, Vector3(0.0, 0.0, d - 0.1), Vector3(w, 0.3, 0.08), ALBERO)
	Landmarks._roof_at(st, 0.0, w, 0.0, d, h, 0.9, PANTILE, WHITEWASH)
	for x in range(0, w + 1, 2):
		Meshes.box(st, Vector3(x - 0.08, 0.0, d - 0.06), Vector3(0.16, h, 0.06), ALBERO)            # pilasters
	for x in range(1, w, 2):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.3, 1.3, d, 0.4, 0.8, ALBERO)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.2, 0.0, d - 0.04), Vector3(1.4, 1.7, 0.06), ALBERO)
		Meshes.cylinder(st, Vector3(door_x + 0.5, 1.6, d - 0.02), 0.55, 0.06, 8, ALBERO)
		Meshes.box(st, Vector3(door_x + 0.18, 0.16, d - 0.07), Vector3(0.64, 1.15, 0.06), DARK_WOOD)
	# the bell tower at the west end
	var tw := 1.8
	Meshes.box(st, Vector3(0.1, 0.0, d * 0.5 - tw * 0.5), Vector3(tw, h + 2.0, tw), WHITEWASH)
	Meshes.box(st, Vector3(0.05, h + 0.6, d * 0.5 - tw * 0.5 - 0.05), Vector3(tw + 0.1, 0.12, tw + 0.1), ALBERO)
	for i in range(2):
		Meshes.box(st, Vector3(0.45 + i * 0.6, h + 1.0, d * 0.5 + tw * 0.5 - 0.02), Vector3(0.36, 0.7, 0.04), Color("3a3430"))
	Meshes.box(st, Vector3(0.05, h + 2.0, d * 0.5 - tw * 0.5 - 0.05), Vector3(tw + 0.1, 0.12, tw + 0.1), ALBERO)
	var rng := Meshes._rng(1713)
	Meshes.cone(st, Vector3(0.1 + tw * 0.5, h + 2.12, d * 0.5), tw * 0.62, 1.1, 4, Color("3f7e8a"), rng)  # glazed tiles
	Meshes.box(st, Vector3(0.1 + tw * 0.5 - 0.03, h + 3.15, d * 0.5 - 0.03), Vector3(0.06, 0.5, 0.06), IRON)
	Meshes.box(st, Vector3(0.1 + tw * 0.5 - 0.15, h + 3.45, d * 0.5 - 0.03), Vector3(0.3, 0.05, 0.06), IRON)

## A frontier post: a low glass-fronted office under a deep flat canopy on slim posts that reaches out over the lane,
## a red and white barrier arm, and a mast with the red, yellow and red of Spain.
static func frontier_post(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("e6e2d6")
	var h := 1.5
	Meshes.box(st, Vector3(0.1, 0, 0.3), Vector3(w - 0.2, h, d - 0.5), wall, wall.darkened(0.1))
	for x in range(w):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.1, 0.4, d - 0.2, 0.8, 0.8, Color("5a6674"))
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.2, wall, 1.0)
	# the canopy, reaching south over the pavement, on posts
	Meshes.box(st, Vector3(-0.3, h + 0.2, 0.0), Vector3(w + 0.6, 0.18, d + 0.9), Color("f4f2ec"), Color("cfccc2"))
	Meshes.box(st, Vector3(-0.3, h + 0.2, d + 0.88), Vector3(w + 0.6, 0.1, 0.04), Color("2a4a86"))
	for x in [-0.2, w * 0.5, w + 0.1]:
		Meshes.box(st, Vector3(x, 0.0, d + 0.7), Vector3(0.1, h + 0.2, 0.1), Color("9aa3ab"))
	# barrier arm off the east end
	Meshes.box(st, Vector3(w + 0.05, 0.0, d + 0.2), Vector3(0.22, 0.7, 0.22), Color("e8e4da"))
	for i in range(6):
		Meshes.box(st, Vector3(w + 0.27 + i * 0.3, 0.6, d + 0.27), Vector3(0.3, 0.07, 0.07), Color("c8283a") if i % 2 == 0 else Color("f4f1e8"))
	# the mast and the flag of Spain (red, a broad yellow band, red)
	var fx := 0.3
	Meshes.box(st, Vector3(fx, 0, -0.2), Vector3(0.07, 3.0, 0.07), Color("e4e2da"))
	Meshes.box(st, Vector3(fx + 0.07, 2.62, -0.19), Vector3(0.7, 0.12, 0.03), Color("aa151b"))
	Meshes.box(st, Vector3(fx + 0.07, 2.38, -0.19), Vector3(0.7, 0.24, 0.03), Color("f1bf00"))
	Meshes.box(st, Vector3(fx + 0.07, 2.26, -0.19), Vector3(0.7, 0.12, 0.03), Color("aa151b"))

## A ruined fort: knee-high and shoulder-high stubs of a sandstone curtain wall and a broken angle bastion, with
## blocks tumbled in the sand. No door.
static func fort_ruin(st: SurfaceTool, w: int, d: int, rng: RandomNumberGenerator) -> void:
	var stone := Color("cdb68a")
	var x := 0.0
	while x < w:
		var seg := 0.6 + rng.randf() * 1.2
		var hh := 0.3 + rng.randf() * 1.3
		Meshes.box(st, Vector3(x, 0.0, d - 1.0), Vector3(minf(seg, w - x), hh, 0.8), stone.darkened(rng.randf() * 0.15), stone.lightened(0.1))
		x += seg + (0.3 if rng.randf() < 0.3 else 0.0)
	# the bastion's point, at the east end, angled
	Meshes.box(st, Vector3(w - 2.2, 0.0, 0.2), Vector3(2.0, 1.6, d - 1.2), stone.darkened(0.08), stone.lightened(0.08))
	Meshes.box(st, Vector3(w - 1.6, 1.6, 0.4), Vector3(1.2, 0.5, d * 0.4), stone.darkened(0.12))
	Meshes.box(st, Vector3(0.0, 0.0, 0.2), Vector3(0.8, 1.1, d - 1.2), stone.darkened(0.1))
	for i in range(5):
		Meshes.blob(st, Vector3(0.6 + rng.randf() * (w - 1.2), 0.15, d - 0.1 + rng.randf() * 0.3), Vector3(0.25, 0.18, 0.2), stone.darkened(0.2), rng, 0.2)

## A gate in the Venetian walls: a great sloping earth-and-stone rampart, a round-arched tunnel through it (the door),
## a band of darker stone and the shoulders of a bastion either side.
static func venetian_gate(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := CYPRUS_STONE
	var h := 2.4
	# battered (sloping) faces: three stacked slabs, each set back a little
	for i in range(3):
		var inset := i * 0.18
		Meshes.box(st, Vector3(0.0 + inset * 0.3, i * h / 3.0, inset), Vector3(w - inset * 0.6, h / 3.0, d - inset * 2.0), stone.darkened(0.04 * i), stone.lightened(0.08))
	Meshes.box(st, Vector3(-0.05, h, 0.3), Vector3(w + 0.1, 0.2, d - 0.6), stone.darkened(0.15))
	Meshes.box(st, Vector3(0.0, h + 0.2, 0.4), Vector3(w, 0.35, d - 0.8), Color("8a9a5a"))            # grass on the top
	var gx := float(door_x) if door_x >= 0 else w * 0.5 - 0.5
	Meshes.box(st, Vector3(gx - 0.3, 0.0, d - 0.04), Vector3(1.6, 1.9, 0.05), stone.lightened(0.12))
	Meshes.cylinder(st, Vector3(gx + 0.5, 1.75, d - 0.02), 0.78, 0.06, 10, stone.lightened(0.12))
	Meshes.box(st, Vector3(gx + 0.12, 0.0, d - 0.03), Vector3(0.76, 1.55, 0.06), Color("2c2824"))
	# a carved panel above the arch, where the lion of Venice once was
	Meshes.box(st, Vector3(gx + 0.15, 2.0, d - 0.02), Vector3(0.7, 0.3, 0.04), stone.darkened(0.2))

## A run of the Venetian walls: the battered rampart without a gate, grass along the top, a string course of darker
## stone and the odd patch of newer repair.
static func venetian_wall(st: SurfaceTool, w: int, d: int, rng: RandomNumberGenerator) -> void:
	var stone := CYPRUS_STONE
	var h := 2.4
	for i in range(3):
		var inset := i * 0.18
		Meshes.box(st, Vector3(0.0, i * h / 3.0, inset), Vector3(w, h / 3.0, d - inset * 2.0), stone.darkened(0.04 * i), stone.lightened(0.08))
	Meshes.box(st, Vector3(0.0, h * 0.62, d - 0.4), Vector3(w, 0.12, 0.06), stone.darkened(0.2))
	Meshes.box(st, Vector3(0.0, h, 0.3), Vector3(w, 0.2, d - 0.6), stone.darkened(0.15))
	Meshes.box(st, Vector3(0.0, h + 0.2, 0.4), Vector3(w, 0.3, d - 0.8), Color("8a9a5a"))
	for i in range(int(w / 4)):
		var px := rng.randf() * (w - 1.2)
		Meshes.box(st, Vector3(px, 0.2 + rng.randf() * 1.2, d - 0.38), Vector3(0.9 + rng.randf() * 0.6, 0.4, 0.04), stone.lightened(0.1))

## A Cypriot Orthodox church: honey stone, a cross-in-square body with low pitched roofs, a drum and dome over the
## crossing, a round-arched doorway and a separate bell tower at one corner.
static func orthodox_church(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var stone := CYPRUS_STONE.lightened(0.04)
	var roof := Color("b4623e")
	var h := 2.2
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), stone, stone.darkened(0.1))
	Landmarks._roof_at(st, 0.0, w, 0.0, d, h, 0.6, roof, stone)
	var cx := w * 0.5
	var cz := d * 0.5
	Meshes.cylinder(st, Vector3(cx, h + 0.3, cz), 1.0, 0.9, 10, stone.lightened(0.05))
	Meshes.blob(st, Vector3(cx, h + 1.2, cz), Vector3(0.95, 0.7, 0.95), Color("9a7a5a"), rng, 0.02)
	Meshes.box(st, Vector3(cx - 0.03, h + 1.85, cz - 0.03), Vector3(0.06, 0.5, 0.06), Color("d8c070"))
	Meshes.box(st, Vector3(cx - 0.18, h + 2.1, cz - 0.03), Vector3(0.36, 0.06, 0.06), Color("d8c070"))
	for x in range(1, w - 1, 2):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.3, 1.0, d, 0.4, 0.7, stone.darkened(0.2))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.1, 0.0, d - 0.04), Vector3(1.2, 1.5, 0.05), stone.lightened(0.12))
		Meshes.cylinder(st, Vector3(door_x + 0.5, 1.4, d - 0.02), 0.6, 0.06, 10, stone.lightened(0.12))
		Meshes.box(st, Vector3(door_x + 0.18, 0.0, d - 0.03), Vector3(0.64, 1.25, 0.06), DARK_WOOD)
	# the bell tower, north-east corner
	var bx := w - 1.6
	Meshes.box(st, Vector3(bx, 0.0, 0.2), Vector3(1.4, h + 1.6, 1.4), stone.lightened(0.06))
	Meshes.box(st, Vector3(bx + 0.3, h + 0.6, 1.58), Vector3(0.8, 0.7, 0.04), Color("3a3430"))
	Landmarks._roof_at(st, bx - 0.05, bx + 1.45, 0.15, 1.65, h + 1.6, 0.45, roof, stone)

## The Selimiye Mosque: the Gothic cathedral of Saint Sophia, with its tall nave and buttresses, a west front of three
## great pointed doorways and a big window, and the two slender Ottoman minarets added above the towers after 1570.
static func selimiye(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var stone := Color("d6c29a")
	var h := 3.6
	Meshes.box(st, Vector3(0.6, 0, 0.3), Vector3(w - 1.2, h, d - 0.6), stone, stone.darkened(0.1))
	Meshes.box(st, Vector3(0.6, h, 0.3), Vector3(w - 1.2, 0.12, d - 0.6), stone.lightened(0.08))     # flat terrace roof
	Meshes.box(st, Vector3(0.0, 0, 0.8), Vector3(w, h * 0.6, d - 1.6), stone.darkened(0.06))           # aisles
	for z in range(1, d - 1):
		for side in [0.0, w - 0.3]:
			Meshes.box(st, Vector3(side, 0.0, z), Vector3(0.3, h * 0.75, 0.3), stone.darkened(0.12))     # buttresses
	# the west front faces south here: two square tower stubs and the big pointed window between
	var tw := 1.6
	for tx in [0.4, w - 0.4 - tw]:
		Meshes.box(st, Vector3(tx, 0.0, d - tw), Vector3(tw, h + 0.6, tw), stone.lightened(0.04), stone.darkened(0.05))
	var cx := w * 0.5
	Meshes.box(st, Vector3(cx - 0.9, 1.6, d - 0.02), Vector3(1.8, 1.6, 0.04), stone.darkened(0.25))
	Meshes.box(wst, Vector3(cx - 0.75, 1.7, d), Vector3(1.5, 1.4, 0.03), Landmarks.window_colour(Landmarks._wr))
	Meshes.cone(st, Vector3(cx, 3.2, d - 0.05), 0.95, 0.7, 4, stone.darkened(0.1), rng)
	# three pointed doorways
	for i in range(3):
		var dx := cx - 2.3 + i * 1.8
		if absf(dx + 0.5 - (door_x + 0.5)) < 0.6:
			continue
		Meshes.box(st, Vector3(dx, 0.0, d - 0.02), Vector3(1.0, 1.25, 0.04), stone.darkened(0.3))
		Meshes.cone(st, Vector3(dx + 0.5, 1.25, d - 0.02), 0.52, 0.45, 4, stone.darkened(0.3), rng)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.01), Vector3(0.8, 1.3, 0.05), Color("3b2a22"))
		Meshes.cone(st, Vector3(door_x + 0.5, 1.3, d - 0.01), 0.45, 0.4, 4, stone.darkened(0.3), rng)
	# the minarets: slim shafts with a balcony ring and a pencil cap
	for tx in [0.4 + tw * 0.5, w - 0.4 - tw * 0.5]:
		var mz := d - tw * 0.5
		Meshes.cylinder(st, Vector3(tx, h + 0.6, mz), 0.32, 3.6, 8, Color("e6dcc4"))
		Meshes.cylinder(st, Vector3(tx, h + 3.2, mz), 0.46, 0.14, 8, Color("cfc4aa"))
		Meshes.cylinder(st, Vector3(tx, h + 4.2, mz), 0.24, 0.7, 8, Color("e6dcc4"))
		Meshes.cone(st, Vector3(tx, h + 4.85, mz), 0.26, 1.0, 8, Color("8a8f96"), rng)

## An Ottoman han (caravanserai): two storeys of rooms round a courtyard, an arcade of round arches on the street
## front, little lead domes along the roof and an octagonal mescit poking over the top. Door: the gateway.
static func han(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var stone := CYPRUS_STONE.darkened(0.03)
	var h := 2.6
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), stone, stone.darkened(0.12))
	Meshes.box(st, Vector3(-0.04, h, -0.04), Vector3(w + 0.08, 0.14, d + 0.08), stone.lightened(0.1))
	for x in range(w):
		if x == door_x:
			continue
		Meshes.box(st, Vector3(x + 0.2, 0.2, d - 0.02), Vector3(0.6, 0.9, 0.04), Color("4a3c30"))          # ground arcade
		Meshes.cylinder(st, Vector3(x + 0.5, 1.05, d - 0.01), 0.3, 0.05, 8, Color("4a3c30"))
		Landmarks._window(st, wst, x + 0.3, 1.65, d, 0.4, 0.5, stone.darkened(0.2))                         # upper rooms
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.2, 0.0, d - 0.03), Vector3(1.4, 1.8, 0.05), stone.lightened(0.12))
		Meshes.cylinder(st, Vector3(door_x + 0.5, 1.6, d - 0.02), 0.6, 0.06, 10, stone.lightened(0.12))
		Meshes.box(st, Vector3(door_x + 0.15, 0.0, d - 0.02), Vector3(0.7, 1.4, 0.06), Color("3b2a22"))
	# the row of small domes, and the octagonal mescit in the courtyard
	var lead := Color("8a8f96")
	for x in range(1, w, 2):
		Meshes.blob(st, Vector3(x + 0.0, h + 0.14, 0.6), Vector3(0.42, 0.32, 0.42), lead, rng, 0.02)
		Meshes.blob(st, Vector3(x + 0.0, h + 0.14, d - 0.6), Vector3(0.42, 0.32, 0.42), lead, rng, 0.02)
	Meshes.cylinder(st, Vector3(w * 0.5, h - 0.6, d * 0.5), 0.9, 1.4, 8, stone.lightened(0.05))
	Meshes.blob(st, Vector3(w * 0.5, h + 0.8, d * 0.5), Vector3(0.75, 0.55, 0.75), lead, rng, 0.02)

## An old Nicosia house, on either side of the line: honey limestone or render, a closed wooden balcony (the kioski,
## or kafesli in Turkish) jutting over the street from the upper floor, tall shuttered windows and a flat roof.
static func kioski_house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var walls := [CYPRUS_STONE, Color("e9dcc0"), Color("e3c9a0"), Color("d8d0bc")]
	var wall: Color = walls[rng.randi() % walls.size()]
	var h := 2.3
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall, wall.darkened(0.1))
	Meshes.box(st, Vector3(-0.03, h, -0.03), Vector3(w + 0.06, 0.12, d + 0.06), wall.lightened(0.12))
	var shutter: Color = [Color("3e6b4a"), Color("2f5d8a"), Color("6b4a32")][rng.randi() % 3]
	for x in range(w):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.25, 0.35, d, 0.5, 0.75, shutter)
	# the kioski: a timber box on brackets across the middle of the upper floor
	var kw := minf(w - 0.6, 2.4)
	var kx := (w - kw) * 0.5
	Meshes.box(st, Vector3(kx, 1.25, d - 0.05), Vector3(kw, 0.9, 0.5), DARK_WOOD, DARK_WOOD.lightened(0.1))
	for i in range(int(kw / 0.3)):
		Meshes.box(st, Vector3(kx + 0.1 + i * 0.3, 1.4, d + 0.46), Vector3(0.18, 0.6, 0.02), DARK_WOOD.lightened(0.25))
	Meshes.box(wst, Vector3(kx + 0.1, 1.45, d + 0.455), Vector3(kw - 0.2, 0.55, 0.01), Landmarks.window_colour(Landmarks._wr))
	for bx in [kx + 0.1, kx + kw - 0.2]:
		Meshes.box(st, Vector3(bx, 1.0, d - 0.02), Vector3(0.1, 0.25, 0.45), DARK_WOOD)
	for x in range(w):
		if x != door_x and (x < kx - 0.2 or x > kx + kw):
			Landmarks._window(st, wst, x + 0.25, 1.4, d, 0.5, 0.7, shutter)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.04), Vector3(0.8, 1.15, 0.05), wall.lightened(0.15))
		Meshes.box(st, Vector3(door_x + 0.2, 0.12, d - 0.07), Vector3(0.6, 0.95, 0.06), shutter.darkened(0.2))
	if rng.randf() < 0.5:
		Meshes.box(st, Vector3(0.4, h + 0.12, 0.4), Vector3(0.6, 0.5, 0.6), Color("e8e4dc"))              # water tank
		Meshes.box(st, Vector3(w - 1.4, h + 0.12, 0.4), Vector3(1.0, 0.1, 0.7), Color("2a3a5a"))           # solar heater

## A checkpoint booth: a small white cabin with a window all round, a little canopy, and a barrier arm across the lane.
static func checkpoint_booth(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("eceae2")
	Meshes.box(st, Vector3(0.15, 0, 0.15), Vector3(w - 0.3, 1.3, d - 0.3), wall, wall.darkened(0.1))
	for x in range(w):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.2, 0.6, d - 0.15, 0.6, 0.55, Color("70777e"))
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.15, wall, 0.95)
	Meshes.box(st, Vector3(-0.1, 1.3, -0.1), Vector3(w + 0.2, 0.12, d + 0.5), Color("d0cec4"))
	Meshes.box(st, Vector3(w - 0.05, 0.0, d * 0.5), Vector3(0.2, 0.7, 0.2), wall)
	for i in range(5):
		Meshes.box(st, Vector3(w + 0.15 + i * 0.28, 0.62, d * 0.5 + 0.06), Vector3(0.28, 0.07, 0.07), Color("c8283a") if i % 2 == 0 else Color("f4f1e8"))

## A UN observation post: a white steel watchtower on four legs with a cabin on top, the letters panel in UN blue
## and the light blue UN flag on a short mast.
static func un_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var white := Color("f2f2ee")
	var cx := w * 0.5
	var cz := d * 0.5
	for lx in [-0.6, 0.5]:
		for lz in [-0.6, 0.5]:
			Meshes.box(st, Vector3(cx + lx, 0.0, cz + lz), Vector3(0.1, 2.4, 0.1), Color("c8c8c0"))
	Meshes.box(st, Vector3(cx - 0.8, 2.4, cz - 0.8), Vector3(1.6, 1.0, 1.6), white, white.darkened(0.1))
	Meshes.box(wst, Vector3(cx - 0.7, 2.75, cz + 0.79), Vector3(1.4, 0.4, 0.03), Landmarks.window_colour(Landmarks._wr))
	Meshes.box(st, Vector3(cx - 0.9, 3.4, cz - 0.9), Vector3(1.8, 0.1, 1.8), white.darkened(0.08))
	Meshes.box(st, Vector3(cx - 0.5, 2.48, cz + 0.8), Vector3(1.0, 0.22, 0.03), UN_BLUE)
	# ladder
	for i in range(8):
		Meshes.box(st, Vector3(cx + 0.55, 0.2 + i * 0.28, cz + 0.65), Vector3(0.3, 0.04, 0.04), Color("9aa3ab"))
	# the UN flag: light blue with a white disc for the emblem
	Meshes.box(st, Vector3(cx - 0.8, 3.5, cz - 0.8), Vector3(0.06, 1.3, 0.06), Color("e4e2da"))
	Meshes.box(st, Vector3(cx - 0.74, 4.3, cz - 0.79), Vector3(0.7, 0.44, 0.03), UN_BLUE)
	Meshes.box(st, Vector3(cx - 0.47, 4.43, cz - 0.81), Vector3(0.16, 0.18, 0.03), white)
	# sandbags round the foot
	for i in range(int(w)):
		Meshes.box(st, Vector3(i + 0.05, 0.0, d - 0.4), Vector3(0.9, 0.3, 0.35), Color("b8a878"))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.42), Vector3(0.8, 0.31, 0.37), Color("8a7a58"))
