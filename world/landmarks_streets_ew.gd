class_name StreetsEW
extends RefCounted
## Local street architecture for the original English, Welsh and Manx towns: Bath stone, Manchester soot-brick,
## Chester's Rows, York's jettied timber, Welsh slate and limewash, Cornish granite and so on. Every style is a
## Landmarks._house with its own palette plus a few dressings (lintels, bays, railings, parapets, gable stacks).
## Called from Meshes.building (one hook); zone files only change a building's `style` value.
## Same rules as Landmarks: vertex colour, low poly, origin at the footprint's north-west corner, door on the south.

const GOLD := Color("dcc08c")

## name -> {walls: [palette, picked per building], roof, storeys, terrace, tudor, doors: [palette], plus dressings}
## Dressings: trim (lintels and sills), string (course at first floor), parapet, bays (ground-floor bays), porch,
## railings, stacks (gable-end stacks), pots (round Cumbrian chimneys), strip (weavers' top-floor glazing),
## surround (dark or pale window surrounds), gallery (Chester Row), oriel (York jetty window), balcony.
const DEFS := {
	"bath_stone": {"walls": [Color("dfc48e"), Color("d8bc86"), Color("e3cc9a")], "roof": Color("5a5f68"), "storeys": 3,
		"trim": Color("efe0b8"), "string": Color("efe0b8"), "parapet": Color("efe0b8"), "porch": Color("efe0b8"),
		"railings": true, "doors": [Color("22262c"), Color("2d3b4e"), Color("3a4a3c")]},
	"grainger_ashlar": {"walls": [Color("cdbfa0"), Color("c4b697"), Color("d3c6a8")], "roof": Color("4d5563"), "storeys": 3,
		"trim": Color("e6dcc2"), "string": Color("e6dcc2"), "parapet": Color("e6dcc2"), "porch": Color("e6dcc2"),
		"doors": [Color("1f2a3a"), Color("2c2c30"), Color("4a2a2a")]},
	"mill_brick": {"walls": [Color("7e3a2e"), Color("74362c"), Color("85412f")], "roof": Color("454b57"), "storeys": 2,
		"terrace": true, "trim": Color("a89a84"), "string": Color("a89a84"), "doors": [Color("2a2a2a"), Color("3d2c24")]},
	"backtoback": {"walls": [Color("8a4338"), Color("7a3d36"), Color("5d5f6c")], "roof": Color("3f4552"), "storeys": 3,
		"terrace": true, "trim": Color("4a5266"), "string": Color("4a5266"), "doors": [Color("2c3a4c"), Color("4a2a2a"), Color("2f4a36")]},
	"grit_terrace": {"walls": [Color("8c8270"), Color("857b69"), Color("93897a")], "roof": Color("6b665f"), "storeys": 2,
		"trim": Color("b2a994"), "surround": Color("b2a994"), "stacks": true, "doors": [Color("3b3028"), Color("2f4538")]},
	"silk_terrace": {"walls": [Color("9a5a42"), Color("8f5240"), Color("a3694d")], "roof": Color("4a505c"), "storeys": 3,
		"terrace": true, "trim": Color("a99f8a"), "strip": true, "doors": [Color("2c3a3a"), Color("3b2a22")]},
	"chester_row": {"walls": [Color("efe8d4"), Color("e8dfc8")], "roof": Color("5a4a44"), "storeys": 2, "tudor": true,
		"gallery": Color("b5654a"), "doors": [Color("1f1f1f"), Color("5a1f1f")]},
	"york_timber": {"walls": [Color("e2cfa4"), Color("d9c394"), Color("e8d8b6")], "roof": Color("9a5240"), "storeys": 2,
		"tudor": true, "oriel": true, "stacks": true, "doors": [Color("3a2a20"), Color("2a3a30")]},
	"lake_slate": {"walls": [Color("7b8274"), Color("747c70"), Color("838a7b")], "roof": Color("485048"), "storeys": 2,
		"surround": Color("e6e2d4"), "pots": true, "doors": [Color("3d2d24"), Color("2f4a40"), Color("6a3030")]},
	"cornish_granite": {"walls": [Color("a8a8a0"), Color("a0a29b"), Color("b0b0a8")], "roof": Color("4f5760"), "storeys": 2,
		"trim": Color("c8c8c0"), "stacks": true, "doors": [Color("2f6a6a"), Color("2c3a5a"), Color("8a3a34")]},
	"whitby_pantile": {"walls": [Color("8a5a46"), Color("93624c"), Color("7e5442")], "roof": Color("c05a3a"), "storeys": 2,
		"surround": Color("f0ece0"), "stacks": true, "doors": [Color("2a4a5a"), Color("f0ece0"), Color("3a2a22")]},
	"london_stucco": {"walls": [Color("efe6d0"), Color("e8ddc4"), Color("f2ecdc")], "roof": Color("4a4f58"), "storeys": 3,
		"trim": Color("fbf6ea"), "string": Color("fbf6ea"), "parapet": Color("fbf6ea"), "porch": Color("fbf6ea"),
		"railings": true, "doors": [Color("1c1c1e"), Color("1f3a5a"), Color("3a1e24")]},
	"london_stock": {"walls": [Color("c4aa6a"), Color("bba060"), Color("cdb374")], "roof": Color("454a54"), "storeys": 3,
		"terrace": true, "trim": Color("f2eee0"), "railings": true, "doors": [Color("1c1c1e"), Color("2a4a3a"), Color("5a2a2a")]},
	"scouse_terrace": {"walls": [Color("a04a3a"), Color("944438"), Color("a8523f")], "roof": Color("454b57"), "storeys": 2,
		"terrace": true, "trim": Color("e0d6c2"), "bays": 2, "doors": [Color("1f3a4a"), Color("3a5a3a"), Color("5a2a2a")]},
	"lace_market": {"walls": [Color("9a4a38"), Color("8f4434"), Color("a2503c")], "roof": Color("4a505c"), "storeys": 3,
		"trim": Color("e2d8c0"), "string": Color("e2d8c0"), "parapet": Color("e2d8c0"), "doors": [Color("2a2a2a"), Color("3a2a22")]},
	"lancs_limestone": {"walls": [Color("a9aaa0"), Color("a0a198"), Color("b2b2a6")], "roof": Color("4a515c"), "storeys": 3,
		"trim": Color("d6d4c6"), "porch": Color("d6d4c6"), "string": Color("d6d4c6"), "doors": [Color("1f2a3a"), Color("3a2a22"), Color("2a4a3a")]},
	"lias_stone": {"walls": [Color("7f8590"), Color("777d88"), Color("878c96")], "roof": Color("9b6a4a"), "storeys": 2,
		"trim": GOLD, "surround": GOLD, "stacks": true, "doors": [Color("3a2a22"), Color("2f4a3a")]},
	"welsh_whitewash": {"walls": [Color("f0ece0"), Color("ebe5d6"), Color("f4f0e6")], "roof": Color("575a6a"), "storeys": 2,
		"surround": Color("3c4048"), "stacks": true, "doors": [Color("2f4a7a"), Color("8a3030"), Color("2f5a3a"), Color("3a3a3a")]},
	"slate_row": {"walls": [Color("6e747a"), Color("676d74"), Color("767c80")], "roof": Color("625a74"), "storeys": 2,
		"trim": Color("a2a6a8"), "surround": Color("4e535a"), "stacks": true, "doors": [Color("3a2a22"), Color("2a3a4a"), Color("5a2a2a")]},
	"aber_seafront": {"walls": [Color("e8a2b4"), Color("f0cf6a"), Color("8fb4d8"), Color("9ccf9a"), Color("c9a8d8"), Color("f0b48a")],
		"roof": Color("4d5563"), "storeys": 3, "terrace": true, "trim": Color("f8f4ea"), "bays": 2, "railings": true,
		"doors": [Color("f8f4ea"), Color("2a3a5a")]},
	"cardiff_polychrome": {"walls": [Color("a04838"), Color("964236"), Color("a85040")], "roof": Color("454b57"), "storeys": 2,
		"terrace": true, "trim": Color("8b8172"), "string": Color("8b8172"), "bays": 2, "doors": [Color("2a3a3a"), Color("3a2a22")]},
	"douglas_prom": {"walls": [Color("f1e9d4"), Color("e9e0c8"), Color("f4eee0")], "roof": Color("505a68"), "storeys": 3,
		"terrace": true, "trim": Color("3f6a8a"), "bays": 2, "balcony": Color("2c3a48"), "parapet": Color("3f6a8a"),
		"doors": [Color("3f6a8a"), Color("a03a34")]},
}
const STYLES := ["bath_stone", "grainger_ashlar", "mill_brick", "backtoback", "grit_terrace", "silk_terrace", "chester_row",
	"york_timber", "lake_slate", "cornish_granite", "whitby_pantile", "london_stucco", "london_stock", "scouse_terrace",
	"lace_market", "lancs_limestone", "lias_stone", "welsh_whitewash", "slate_row", "aber_seafront", "cardiff_polychrome",
	"douglas_prom"]

static func has_style(style: String) -> bool:
	return DEFS.has(style)

## Same contract as Landmarks.building: [body_mesh, windows_mesh, chimney tops].
static func building(w: int, d: int, style: String, door_x: int, seed_value: int) -> Array:
	var rng := Meshes._rng(seed_value)
	var st := Meshes._st()
	var wst := Meshes._st()
	Landmarks._wr.seed = seed_value * 7 + 3
	Landmarks._chimneys = PackedVector3Array()
	var def: Dictionary = DEFS[style]
	var walls: Array = def.walls
	var wall: Color = walls[rng.randi() % walls.size()]
	var storeys: int = def.storeys
	var tudor: bool = def.get("tudor", false)
	Landmarks._house(st, wst, w, d, door_x, rng, wall, def.roof, storeys, def.get("terrace", false), tudor)
	var hgt := 1.15 * storeys + 0.2
	var zf: float = d + (0.12 if tudor else 0.0)  # tudor upper floors oversail
	if def.has("surround"):
		_surrounds(st, w, d, storeys, door_x, def.surround)
	if def.has("trim"):
		_lintels(st, w, zf, storeys, door_x, def.trim)
	if def.has("string"):
		Meshes.box(st, Vector3(-0.02, 1.2, zf - 0.07), Vector3(w + 0.04, 0.07, 0.1), def.string)
	if def.has("parapet"):
		Meshes.box(st, Vector3(-0.06, hgt - 0.02, d - 0.12), Vector3(w + 0.12, 0.3, 0.2), def.parapet)
		Meshes.box(st, Vector3(-0.06, hgt + 0.28, d - 0.1), Vector3(w + 0.12, 0.08, 0.16), def.parapet.lightened(0.05))
	if def.has("bays"):
		_bays(st, wst, w, d, door_x, wall, int(def.bays))
	if def.has("strip"):
		_strip(st, wst, w, d, storeys)
	if def.has("gallery"):
		_gallery(st, w, d, def.gallery)
	if def.has("oriel"):
		_oriel(st, wst, w, d, door_x, wall, hgt)
	if def.has("balcony"):
		_balcony(st, w, d, door_x, def.balcony)
	if def.has("stacks"):
		_stacks(st, w, d, hgt, wall)
	if def.has("pots"):
		_pots(st, w, d, hgt, wall)
	if def.has("railings"):
		_railings(st, w, d, door_x, Color("1d1f24"))
	var porch: Color = def.get("porch", Color(0, 0, 0, 0))
	var dc: Array = def.doors
	_door_paint(st, door_x, zf if tudor else float(d), dc[rng.randi() % dc.size()], porch, wall)
	return [Meshes._finish(st), Meshes._finish(wst), Landmarks._chimneys]

static func _wy(s: int) -> float:
	return 0.4 + 1.15 * s

## Pale (or dark) stone lintels over each window and a sill under it.
static func _lintels(st: SurfaceTool, w: int, d: float, storeys: int, door_x: int, col: Color) -> void:
	for s in storeys:
		for x in w:
			if x == door_x and s == 0:
				continue
			Meshes.box(st, Vector3(x + 0.2, _wy(s) + 0.6, d - 0.075), Vector3(0.6, 0.08, 0.07), col)
			Meshes.box(st, Vector3(x + 0.2, _wy(s) - 0.15, d - 0.075), Vector3(0.6, 0.06, 0.1), col)

## A frame around each window, behind the glazing's own frame so it reads as a surround.
static func _surrounds(st: SurfaceTool, w: int, d: int, storeys: int, door_x: int, col: Color) -> void:
	for s in storeys:
		for x in w:
			if x == door_x and s == 0:
				continue
			Meshes.box(st, Vector3(x + 0.18, _wy(s) - 0.12, d - 0.062), Vector3(0.64, 0.76, 0.024), col)

## Ground-floor bay windows, one tile in `every`, skipping the door tile.
static func _bays(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, wall: Color, every: int) -> void:
	for x in range(w):
		if x == door_x or x % every != 0 and w > 2:
			continue
		Meshes.box(st, Vector3(x + 0.1, 0.16, d - 0.02), Vector3(0.8, 0.95, 0.24), wall.lightened(0.06))
		Meshes.box(st, Vector3(x + 0.05, 1.08, d - 0.02), Vector3(0.9, 0.08, 0.3), wall.darkened(0.35))
		Meshes.box(wst, Vector3(x + 0.2, 0.32, d + 0.225), Vector3(0.6, 0.62, 0.03), Landmarks.window_colour(Landmarks._wr))

## The top floor of a silk mill terrace: one long band of weavers' windows.
static func _strip(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, storeys: int) -> void:
	var y := _wy(storeys - 1)
	Meshes.box(st, Vector3(0.12, y - 0.1, d - 0.07), Vector3(w - 0.24, 0.78, 0.03), Color("5a4a40"))
	Meshes.box(wst, Vector3(0.18, y - 0.02, d - 0.045), Vector3(w - 0.36, 0.62, 0.03), Landmarks.window_colour(Landmarks._wr))
	for x in range(1, w):
		Meshes.box(st, Vector3(x - 0.03, y - 0.04, d - 0.06), Vector3(0.06, 0.7, 0.04), Color("5a4a40"))

## Chester's Row: red sandstone posts carrying a covered gallery in front of the first floor.
static func _gallery(st: SurfaceTool, w: int, d: int, col: Color) -> void:
	var z := d + 0.5
	for x in range(w + 1):
		Meshes.box(st, Vector3(minf(x, w - 0.14), 0.0, z), Vector3(0.14, 1.15, 0.14), col)
	Meshes.box(st, Vector3(-0.05, 1.15, d + 0.1), Vector3(w + 0.1, 0.1, 0.62), col.darkened(0.15))
	Meshes.box(st, Vector3(-0.05, 1.25, z), Vector3(w + 0.1, 0.34, 0.06), Color("2b2422"))

## A bowed oriel window on the first floor, over the jetty.
static func _oriel(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, wall: Color, hgt: float) -> void:
	var x := 0 if door_x != 0 else w - 1
	var beam := Color("2b2422")
	Meshes.box(st, Vector3(x + 0.1, 1.3, d + 0.1), Vector3(0.8, 0.7, 0.22), wall.lightened(0.05))
	Meshes.box(st, Vector3(x + 0.06, 1.28, d + 0.1), Vector3(0.88, 0.07, 0.26), beam)
	Meshes.box(st, Vector3(x + 0.06, 1.98, d + 0.1), Vector3(0.88, 0.07, 0.26), beam)
	Meshes.box(wst, Vector3(x + 0.2, 1.4, d + 0.32), Vector3(0.6, 0.5, 0.03), Landmarks.window_colour(Landmarks._wr))

## Iron balcony rail across the first floor.
static func _balcony(st: SurfaceTool, w: int, d: int, door_x: int, col: Color) -> void:
	Meshes.box(st, Vector3(-0.02, 1.16, d), Vector3(w + 0.04, 0.05, 0.3), col)
	Meshes.box(st, Vector3(-0.02, 1.56, d + 0.28), Vector3(w + 0.04, 0.04, 0.03), col)
	for i in range(int(w * 4) + 1):
		Meshes.box(st, Vector3(minf(i * 0.25, w - 0.03), 1.18, d + 0.28), Vector3(0.03, 0.38, 0.03), col)

## Black area railings along the pavement edge, a gap at the door.
static func _railings(st: SurfaceTool, w: int, d: int, door_x: int, col: Color) -> void:
	Meshes.box(st, Vector3(0.0, 0.46, d + 0.1), Vector3(w, 0.04, 0.04), col)
	for i in range(w * 3 + 1):
		var x := minf(i / 3.0, w - 0.03)
		if door_x >= 0 and x > door_x + 0.1 and x < door_x + 0.9:
			continue
		Meshes.box(st, Vector3(x, 0.0, d + 0.1), Vector3(0.03, 0.5, 0.03), col)

## Stacks at each gable end, the cluster of pots that says "old house".
static func _stacks(st: SurfaceTool, w: int, d: int, hgt: float, wall: Color) -> void:
	var rise := minf(1.2, d * 0.38)
	for x in [0.02, w - 0.36]:
		Meshes.box(st, Vector3(x, hgt - 0.1, d * 0.5 - 0.18), Vector3(0.34, rise + 0.7, 0.36), wall.darkened(0.12))
		Meshes.box(st, Vector3(x - 0.03, hgt + rise + 0.58, d * 0.5 - 0.21), Vector3(0.4, 0.08, 0.42), wall.lightened(0.15))
		Meshes.box(st, Vector3(x + 0.08, hgt + rise + 0.66, d * 0.5 - 0.1), Vector3(0.18, 0.2, 0.18), Color("a0553c"))

## Round Lakeland chimneys: tall cylinders, whitewashed.
static func _pots(st: SurfaceTool, w: int, d: int, hgt: float, wall: Color) -> void:
	var rise := minf(1.2, d * 0.38)
	for x in [0.3, w - 0.3]:
		Meshes.cylinder(st, Vector3(x, hgt - 0.1, d * 0.5), 0.2, rise + 0.9, 6, Color("e8e4d6"))
		Meshes.cylinder(st, Vector3(x, hgt + rise + 0.78, d * 0.5), 0.24, 0.1, 6, wall.darkened(0.3))

## A painted front door (over the plain one), with a pilastered porch and pediment when `porch` is set.
static func _door_paint(st: SurfaceTool, door_x: int, d: float, col: Color, porch: Color, wall: Color) -> void:
	if door_x < 0:
		return
	Meshes.box(st, Vector3(door_x + 0.22, 0.16, d - 0.075), Vector3(0.56, 0.9, 0.07), col)
	if porch.a > 0.0:
		for x in [door_x + 0.1, door_x + 0.82]:
			Meshes.box(st, Vector3(x, 0.0, d - 0.08), Vector3(0.08, 1.2, 0.12), porch)
		Meshes.box(st, Vector3(door_x + 0.06, 1.2, d - 0.08), Vector3(0.88, 0.1, 0.16), porch)
		Meshes.box(st, Vector3(door_x + 0.2, 1.3, d - 0.07), Vector3(0.6, 0.1, 0.12), porch.lightened(0.04))
