class_name PacificStyles
extends RefCounted
## The Pacific and Indian Ocean territories (Pitcairn, Diego Garcia and East Point): white weatherboard with a tin roof
## and a veranda, a longboat shed, a base hangar, control tower and pale concrete block, a coral-stone plantation ruin,
## and a little white island church. Called from Landmarks.building (see the "pitcairn_house" arms there).
## Same rules as Landmarks: vertex colour, low poly, origin at the footprint's north-west corner, door on the south.

const STYLES := ["pitcairn_house", "boat_shed", "base_hangar", "control_tower", "base_block", "plantation_ruin", "island_church"]
const WEATHERBOARD := [Color("eee9dc"), Color("e4ddc8"), Color("d8e4e0"), Color("efe2d0")]
const TIN := [Color("a6443a"), Color("4f7a52"), Color("8a8f94"), Color("3f6a8a")]
const CONCRETE := Color("cfcbc0")
const CORAL_STONE := Color("c9c0a8")
const RUST := Color("8d5a3a")

## A white weatherboard house, one storey, a corrugated-iron roof (red, green, grey or blue by seed) and a front veranda.
static func house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = WEATHERBOARD[rng.randi() % WEATHERBOARD.size()]
	var roof: Color = TIN[rng.randi() % TIN.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, roof, 1, false, false)
	_veranda(st, w, d, roof, wall)
	# a rainwater tank at the side: every house here lives off its roof
	Meshes.cylinder(st, Vector3(w - 0.35, 0, d * 0.5), 0.28, 0.9, 7, Color("8aa4a0"))

static func _veranda(st: SurfaceTool, w: int, d: int, roof: Color, wall: Color) -> void:
	Meshes.box(st, Vector3(0.0, 1.02, d - 0.05), Vector3(w, 0.07, 0.55), roof.darkened(0.1))
	for i in range(w + 1):
		Meshes.box(st, Vector3(minf(i, w - 0.07), 0.0, d + 0.42), Vector3(0.07, 1.05, 0.07), wall.darkened(0.12))
	Meshes.box(st, Vector3(0.0, 0.0, d - 0.05), Vector3(w, 0.1, 0.55), wall.darkened(0.3))

## A longboat shed on the shore: a wide, low weatherboard shed with a big open front, and a longboat drawn up beside it.
static func boat_shed(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("b9c7c4")
	var roof := Color("7a8a90")
	var h := 1.55
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.5), wall)
	Landmarks._roof_at(st, -0.12, w + 0.12, -0.1, d - 0.3, h, 0.7, roof, wall)
	Meshes.box(st, Vector3(door_x - 0.6, 0.0, d - 0.56), Vector3(1.8, 1.25, 0.08), Color("2b2a2a"))
	Meshes.box(st, Vector3(door_x - 0.7, 1.25, d - 0.6), Vector3(2.0, 0.1, 0.12), wall.darkened(0.25))
	# the longboat, bows to the sea: white hull, a blue sheer stripe, a thwart or two
	var bx := 0.2 if door_x > w * 0.5 else w - 2.8
	Meshes.box(st, Vector3(bx, 0.1, d - 0.45), Vector3(2.6, 0.32, 0.5), Color("efece4"))
	Meshes.box(st, Vector3(bx + 0.1, 0.4, d - 0.42), Vector3(2.4, 0.07, 0.44), Color("2f5d86"))
	Meshes.box(st, Vector3(bx + 0.9, 0.42, d - 0.4), Vector3(0.12, 0.05, 0.4), Color("7a5530"))
	Meshes.box(st, Vector3(bx + 1.6, 0.42, d - 0.4), Vector3(0.12, 0.05, 0.4), Color("7a5530"))
	Landmarks._door(st, -1, d, wall)

## An aircraft hangar: a wide pale barrel of a building, stepped to suggest the curve, with huge dark doors and a stripe.
static func base_hangar(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("c4c8c6")
	var steps := [[0.0, 1.5], [0.35, 2.0], [0.9, 2.4], [1.5, 2.6]]
	for s in steps:
		var inset: float = s[0]
		Meshes.box(st, Vector3(0.05, 0.0 if inset == 0.0 else s[1] - 0.4, inset * 0.5 + 0.05), Vector3(w - 0.1, 0.45 if inset > 0.0 else s[1], d - 0.1 - inset), wall.darkened(0.04 * steps.find(s)))
	Meshes.box(st, Vector3(0.6, 0.0, d - 0.1), Vector3(w - 1.2, 1.7, 0.08), Color("3a3e44"))
	Meshes.box(st, Vector3(0.6, 1.7, d - 0.12), Vector3(w - 1.2, 0.12, 0.12), Color("b8433a"))
	Meshes.box(st, Vector3(0.05, 1.5, d - 0.06), Vector3(w - 0.1, 0.12, 0.06), Color("2f5d86"))

## A control tower: a pale concrete base, a tall shaft and a glazed cab with a flat roof and a mast.
static func control_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, 1.2, d - 0.1), CONCRETE)
	Meshes.box(st, Vector3(0.0, 1.2, 0.0), Vector3(w, 0.12, d), CONCRETE.darkened(0.25))
	var tx := door_x - 0.1
	Meshes.box(st, Vector3(tx, 1.3, d * 0.5 - 0.4), Vector3(1.2, 2.6, 0.8), CONCRETE.lightened(0.04))
	Meshes.box(st, Vector3(tx - 0.35, 3.9, d * 0.5 - 0.75), Vector3(1.9, 0.12, 1.5), CONCRETE.darkened(0.3))
	Meshes.box(st, Vector3(tx - 0.3, 4.02, d * 0.5 - 0.7), Vector3(1.8, 0.9, 1.4), Color("6fa0b8"))
	Meshes.box(st, Vector3(tx - 0.4, 4.92, d * 0.5 - 0.8), Vector3(2.0, 0.12, 1.6), CONCRETE.darkened(0.15))
	Meshes.box(st, Vector3(tx + 0.5, 5.04, d * 0.5 - 0.05), Vector3(0.06, 1.1, 0.06), Color("5a5e64"))
	Meshes.box(st, Vector3(tx + 0.3, 5.9, d * 0.5 - 0.05), Vector3(0.46, 0.06, 0.06), Color("b8433a"))
	for x in w:
		if x != door_x:
			Landmarks._window(st, wst, x + 0.25, 0.5, d, 0.5, 0.5, CONCRETE.lightened(0.15))
	Landmarks._door(st, door_x, d, CONCRETE, 0.9)

## A pale concrete block: a one-storey flat-roofed building with a sunshade over the front, as the island's offices, mess
## and stores are built.
static func base_block(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = CONCRETE.lightened(0.03 * float(rng.randi() % 3))
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, 1.5, d - 0.1), wall)
	Meshes.box(st, Vector3(0.0, 1.5, 0.0), Vector3(w, 0.14, d), wall.darkened(0.25))
	Meshes.box(st, Vector3(0.0, 1.0, d - 0.05), Vector3(w, 0.07, 0.6), Color("5f7a8a"))
	for i in range(w + 1):
		Meshes.box(st, Vector3(minf(i, w - 0.06), 0.0, d + 0.5), Vector3(0.06, 1.03, 0.06), wall.darkened(0.3))
	for x in w:
		if x != door_x:
			Landmarks._window(st, wst, x + 0.25, 0.4, d, 0.5, 0.5, wall.lightened(0.15))
	Landmarks._door(st, door_x, d, wall, 0.95)
	# a plant-room box and a satellite dish on the roof
	Meshes.box(st, Vector3(w - 1.0, 1.64, 0.4), Vector3(0.7, 0.4, 0.6), wall.darkened(0.1))

## A plantation ruin: coral-stone walls broken to different heights, an open doorway and a few rafters and a scrap of rusted
## tin left on top, with the palms taking over.
static func plantation_ruin(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	for x in w:
		var hh := rng.randf_range(0.9, 1.9)
		if x == door_x:
			hh = 0.25
		Meshes.box(st, Vector3(x + 0.04, 0, d - 0.35), Vector3(0.92, hh, 0.22), CORAL_STONE.darkened(rng.randf() * 0.1))
	for z in range(1, d):
		for xs in [0.04, w - 0.3]:
			Meshes.box(st, Vector3(xs, 0, z - 0.1), Vector3(0.26, rng.randf_range(0.7, 1.8), 0.9), CORAL_STONE.darkened(rng.randf() * 0.1))
	Meshes.box(st, Vector3(0.04, 0, 0.05), Vector3(w - 0.08, rng.randf_range(1.2, 2.0), 0.26), CORAL_STONE)
	for i in range(1, w, 2):
		Meshes.box(st, Vector3(i - 0.05, 1.7, 0.3), Vector3(0.1, 0.1, d - 0.8), Color("5a4630"))
	Meshes.box(st, Vector3(w * 0.3, 1.75, 0.5), Vector3(1.6, 0.06, 1.4), RUST)
	Landmarks._door(st, -1, d, CORAL_STONE)

## A small white island church: weatherboard, a steep red roof, a bellcote on the gable and a cross.
static func island_church(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("f1eee4")
	var h := 2.0
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), wall.darkened(0.3))
	var roof := Color("b5473a")
	var a := Vector3(-0.15, h, -0.1)
	var b := Vector3(w + 0.15, h, -0.1)
	var c := Vector3(w + 0.15, h, d + 0.1)
	var dd := Vector3(-0.15, h, d + 0.1)
	var r0 := Vector3(w * 0.5, h + 1.3, -0.1)
	var r1 := Vector3(w * 0.5, h + 1.3, d + 0.1)
	Meshes._quad(st, r1, r0, a, dd, roof)
	Meshes._quad(st, r0, r1, c, b, roof.darkened(0.15))
	Meshes._tri(st, dd, c, r1, wall)
	Meshes._tri(st, b, a, r0, wall.darkened(0.06))
	var cx := w * 0.5 - 0.2
	Meshes.box(st, Vector3(cx, h + 1.1, d - 0.4), Vector3(0.4, 0.55, 0.3), wall)
	Meshes.box(st, Vector3(cx - 0.03, h + 1.65, d - 0.43), Vector3(0.46, 0.08, 0.36), roof.darkened(0.1))
	Meshes.box(st, Vector3(cx + 0.17, h + 1.73, d - 0.3), Vector3(0.06, 0.55, 0.06), Color("f6f2e4"))
	Meshes.box(st, Vector3(cx + 0.06, h + 2.0, d - 0.3), Vector3(0.28, 0.06, 0.06), Color("f6f2e4"))
	for x in [0.55, w - 1.05]:
		Landmarks._window(st, wst, x, 0.6, d, 0.5, 1.2, wall.darkened(0.12))
	Landmarks._door(st, door_x, d, wall, 1.1)
