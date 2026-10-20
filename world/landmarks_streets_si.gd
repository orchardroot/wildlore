class_name StreetsSI
extends RefCounted
## Local street architecture for the original Scotland, Ireland and Northern Ireland towns (wave 31, A2):
## Edinburgh and Glasgow tenements, Aberdeen granite, Orkney flagstone, harled Highland cottages, Portree's
## painted harbour row, Dublin Georgian doors, Ulster brick terraces and Kilkenny limestone. Called from
## Landmarks.building (see the STYLES arm there). Same rules as Landmarks: vertex colour, low poly, origin at the
## footprint's north-west corner, door on the south face at the same spot as Landmarks._door.

const STYLES := ["edinburgh_tenement", "glasgow_tenement", "aberdeen_granite", "orkney_flagstone", "highland_sandstone",
	"harled_cottage", "harbour_row", "dublin_georgian", "ulster_terrace", "kilkenny_limestone"]

const SLATE := Color("4a5160")
const BLUE_SLATE := Color("3d4655")
const FLAG := Color("6f6a62")
const WHITE := Color("f2eee2")
const BLACK := Color("23252b")

## Per-style look: walls (one picked per building from its seed), trim, roof, storeys, and feature flags.
const LOOKS := {
	"edinburgh_tenement": {"walls": [Color("b3a58b"), Color("a89f90"), Color("bba98a")], "trim": Color("d3c8b0"), "roof": BLUE_SLATE,
		"storeys": 3, "crow": true, "string": true, "stacks": true, "doors": [Color("2b2f3a"), Color("5a2a2a"), Color("2f4a3a")]},
	"glasgow_tenement": {"walls": [Color("a4492f"), Color("b0553a"), Color("984230")], "trim": Color("dcc2a4"), "roof": BLUE_SLATE,
		"storeys": 3, "string": true, "cornice": true, "bay": true, "stacks": true, "rise": 0.22, "doors": [Color("1f2a33")]},
	"aberdeen_granite": {"walls": [Color("a1a6a9"), Color("959b9f"), Color("adb0ae")], "trim": Color("d6d9d8"), "roof": Color("3a414d"),
		"storeys": 2, "speckle": true, "stacks": true, "dormers": true, "doors": [Color("2f3a4a"), Color("40302a")]},
	"orkney_flagstone": {"walls": [Color("8a8478"), Color("7e796e"), Color("958f82")], "trim": Color("b5ae9f"), "roof": FLAG,
		"storeys": 1, "crow": true, "stacks": true, "flagged": true, "doors": [Color("2c4a5a"), Color("5a3a2a"), Color("34503a")]},
	"highland_sandstone": {"walls": [Color("c09a7c"), Color("b88f72"), Color("c8a888")], "trim": Color("e6d8c0"), "roof": SLATE,
		"storeys": 2, "string": true, "stacks": true, "dormers": true, "doors": [Color("3a2f2a"), Color("2c4a3a")]},
	"harled_cottage": {"walls": [Color("ece7d8"), Color("e6e0cf")], "trim": BLACK, "roof": SLATE,
		"storeys": 1, "stacks": true, "dormers": true, "doors": [Color("a3322a"), Color("2c5a8a"), Color("2f6a4a"), Color("2a2a2a")]},
	"dublin_georgian": {"walls": [Color("8f4f3c"), Color("9a5a42"), Color("86483a"), Color("a0694c")], "trim": WHITE, "roof": BLUE_SLATE,
		"storeys": 3, "georgian": true, "railings": true, "parapet": true,
		"doors": [Color("b3202a"), Color("2d5fa3"), Color("e0b52c"), Color("2e7a4c"), Color("6a3a8a"), Color("e07a2c"), Color("20242c")]},
	"ulster_terrace": {"walls": [Color("a1463a"), Color("98412f"), Color("ab5642")], "trim": Color("e4ddd0"), "roof": SLATE,
		"storeys": 2, "bay": true, "stacks": true, "pots": true, "doors": [Color("1f3a5a"), Color("2a2a2a"), Color("3a5a3a"), Color("6a2a2a")]},
	"harbour_row": {"walls": [Color("f0cf6a")], "trim": WHITE, "roof": SLATE, "storeys": 2, "stacks": true, "pots": true,
		"doors": [Color("2c4a6a"), Color("a3322a"), Color("2a2a2a"), Color("2f5a4a")]},
	"kilkenny_limestone": {"walls": [Color("8f918c"), Color("9a9b94"), Color("85878a")], "trim": Color("c9c8bc"), "roof": BLUE_SLATE,
		"storeys": 2, "string": true, "stacks": true, "doors": [Color("a33a2a"), Color("1f3a5a"), Color("2f5a3a"), Color("20202a")]},
}

const PAINTS := [Color("e8a2b4"), Color("f0cf6a"), Color("6fa4d2"), Color("8cc48c"), Color("d4605a"), Color("5fb4ac"), Color("e9936a"), Color("b7a2d6")]

static func build(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator, style: String) -> void:
	var look: Dictionary = LOOKS[style]
	var walls: Array = look.walls
	var wall: Color = walls[rng.randi() % walls.size()]
	var trim: Color = look.trim
	var roof: Color = look.roof
	var doors: Array = look.doors
	var door_col: Color = doors[rng.randi() % doors.size()]
	var storeys: int = look.storeys
	if storeys == 1 and style == "orkney_flagstone" and w >= 5 and d >= 4:
		storeys = 2  # the bigger Orkney houses are a storey and a half; two reads better at this scale
	var sh := 1.2
	var hgt := sh * storeys + 0.2
	var painted := style == "harbour_row"
	if painted:
		wall = Color("e4dfd2")  # gables and stacks are limewash; the colour is painted on the front
	# body, plinth
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), wall)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), wall.darkened(0.3))
	var rise := minf(1.2, d * float(look.get("rise", 0.38)))
	if look.get("parapet", false):
		# Georgian: a flat roof behind a stone-capped parapet
		Meshes.box(st, Vector3(-0.02, hgt, -0.02), Vector3(w + 0.04, 0.34, d + 0.04), wall)
		Meshes.box(st, Vector3(-0.05, hgt + 0.34, -0.05), Vector3(w + 0.1, 0.08, d + 0.1), trim.darkened(0.1))
		Meshes.box(st, Vector3(0.1, hgt + 0.1, 0.1), Vector3(w - 0.2, 0.3, d - 0.2), roof)
		rise = 0.0
	else:
		Landmarks._roof(st, w, d, hgt, roof, wall, float(look.get("rise", 0.38)))
	if look.get("crow", false):
		_crow_steps(st, w, d, hgt, rise, wall.darkened(0.06))
	if look.get("cornice", false):
		Meshes.box(st, Vector3(-0.08, hgt - 0.12, d - 0.1), Vector3(w + 0.16, 0.16, 0.2), trim)
	if look.get("georgian", false):
		Meshes.box(st, Vector3(-0.02, hgt - 0.02, d - 0.04), Vector3(w + 0.04, 0.08, 0.1), trim)
	# string courses between the floors
	if look.get("string", false):
		for s in range(1, storeys):
			Meshes.box(st, Vector3(0.0, sh * s + 0.12, d - 0.05), Vector3(w, 0.07, 0.08), trim)
	# stone speckle for granite: darker and lighter flecks scattered over the front
	if look.get("speckle", false):
		for i in range(w * 3):
			var sx: float = 0.15 + rng.randf() * (w - 0.4)
			var sy: float = 0.25 + rng.randf() * (hgt - 0.5)
			var tone: float = rng.randf_range(-0.16, 0.14)
			Meshes.box(st, Vector3(sx, sy, d - 0.07), Vector3(0.13, 0.09, 0.03), wall.lightened(tone) if tone > 0.0 else wall.darkened(-tone))
	# painted harbour row: each house its own colour, a pale divider between
	if painted:
		var start := rng.randi() % PAINTS.size()
		for x in w:
			var col: Color = PAINTS[(start + x * 3) % PAINTS.size()]
			Meshes.box(st, Vector3(x + 0.02, 0.16, d - 0.08), Vector3(0.96, hgt - 0.16, 0.06), col)
			if x > 0:
				Meshes.box(st, Vector3(x - 0.03, 0.0, d - 0.1), Vector3(0.06, hgt, 0.1), WHITE)
		Meshes.box(st, Vector3(-0.02, 0.0, d - 0.04), Vector3(w + 0.04, 0.2, 0.08), WHITE)
		Meshes.box(st, Vector3(-0.02, hgt - 0.1, d - 0.04), Vector3(w + 0.04, 0.1, 0.08), WHITE)
	# chimney stacks: on the gable ends, or one per two terrace houses with pots
	if look.get("stacks", false):
		var top := hgt + rise
		for sx in [0.0, w - 0.34]:
			Meshes.box(st, Vector3(sx, hgt - 0.3, d * 0.5 - 0.2), Vector3(0.34, rise + 0.7, 0.4), wall.darkened(0.12), trim.darkened(0.2))
			Meshes.box(st, Vector3(sx - 0.03, top + 0.38, d * 0.5 - 0.23), Vector3(0.4, 0.07, 0.46), trim.darkened(0.15))
			for px in [0.04, 0.2]:
				Meshes.box(st, Vector3(sx + px, top + 0.45, d * 0.5 - 0.08), Vector3(0.1, 0.2, 0.1), Color("a0553c"))
			Landmarks._chimneys.append(Vector3(sx + 0.17, top + 0.7, d * 0.5))
		if look.get("pots", false):
			for i in range(2, w - 1, 2):
				Meshes.box(st, Vector3(i - 0.17, hgt + rise * 0.55, d * 0.5 - 0.17), Vector3(0.34, rise * 0.45 + 0.75, 0.34), wall.darkened(0.2))
				Meshes.box(st, Vector3(i - 0.1, hgt + rise + 0.72, d * 0.5 - 0.1), Vector3(0.2, 0.2, 0.2), Color("a0553c"))
				Landmarks._chimneys.append(Vector3(i, hgt + rise + 0.95, d * 0.5))
	# dormers on the front slope
	if look.get("dormers", false) and d >= 4 and w >= 4:
		var yb := hgt + rise * (1.0 - (d - 0.5 - d * 0.5) / (d * 0.5 + 0.18)) - 0.25
		for dx in range(1, w - 1, 2):
			var x0 := dx + 0.2
			Meshes.box(st, Vector3(x0, yb, d - 0.55), Vector3(0.6, 0.85, 0.5), wall)
			Meshes.box(st, Vector3(x0 - 0.06, yb + 0.85, d - 0.62), Vector3(0.72, 0.09, 0.64), roof.darkened(0.1))
			Landmarks._window(st, wst, x0 + 0.1, yb + 0.22, d - 0.0, 0.4, 0.45, trim)
	# bays: a ground-floor (Ulster) or two-storey (Glasgow) bay window every third house
	if look.get("bay", false):
		var bay_h: float = sh * (2 if storeys >= 3 else 1) - 0.25
		for bx in range(0, w):
			if not _is_bay(bx, door_x, storeys):
				continue
			Meshes.box(st, Vector3(bx + 0.1, 0.16, d - 0.02), Vector3(0.8, bay_h, 0.2), wall.lightened(0.05))
			Meshes.box(st, Vector3(bx + 0.06, bay_h + 0.16, d - 0.04), Vector3(0.88, 0.08, 0.26), trim)
			for s in (2 if storeys >= 3 else 1):
				Landmarks._window(st, wst, bx + 0.22, 0.4 + sh * s, d + 0.17, 0.56, 0.56, trim)
	# windows (skipping the bay tiles' ground floor, which got their own)
	var bay_tiles := {}
	if look.get("bay", false):
		for bx in range(0, w):
			if _is_bay(bx, door_x, storeys):
				bay_tiles[bx] = true
	for s in storeys:
		var wy := 0.4 + sh * s
		var wh := 0.56
		if look.get("georgian", false):
			wh = [0.66, 0.7, 0.5][mini(s, 2)]  # tall piano nobile, shorter top floor
			wy = [0.34, 1.5, 2.72][mini(s, 2)] + (0.0 if s < 2 else 0.04)
		for x in w:
			if x == door_x and s == 0:
				continue
			if bay_tiles.has(x) and (s == 0 or (storeys >= 3 and s == 1)):
				continue
			Landmarks._window(st, wst, x + 0.27, wy, d, 0.46, wh, trim)
			if look.get("georgian", false):
				Meshes.box(st, Vector3(x + 0.24, wy + wh + 0.05, d - 0.06), Vector3(0.52, 0.06, 0.06), trim)  # lintel
	_door(st, door_x, d, door_col, trim, look)
	if look.get("railings", false):
		_railings(st, w, d, door_x)

## Every third house gets a bay, but never the door's tile (or, with two-storey bays, its neighbours).
static func _is_bay(bx: int, door_x: int, storeys: int) -> bool:
	if bx == door_x or (storeys >= 3 and absi(bx - door_x) < 2):
		return false
	return (bx + door_x + 1) % 3 == 0

## The door, a coloured leaf where Landmarks._door puts its leaf, with a surround that suits the style.
static func _door(st: SurfaceTool, door_x: int, d: float, col: Color, trim: Color, look: Dictionary) -> void:
	if door_x < 0:
		return
	Meshes.box(st, Vector3(door_x + 0.22, 0.16, d - 0.08), Vector3(0.56, 0.9, 0.06), col)
	Meshes.box(st, Vector3(door_x + 0.15, 1.06, d - 0.09), Vector3(0.7, 0.08, 0.08), trim)
	if look.get("georgian", false):
		# white pilasters, a fanlight over the door, a pediment lintel and two stone steps out front
		for px in [door_x + 0.13, door_x + 0.78]:
			Meshes.box(st, Vector3(px, 0.16, d - 0.1), Vector3(0.1, 0.98, 0.1), trim)
		Meshes.box(st, Vector3(door_x + 0.2, 1.14, d - 0.075), Vector3(0.6, 0.2, 0.04), Color("d9d4c4"))
		Meshes.box(st, Vector3(door_x + 0.3, 1.34, d - 0.075), Vector3(0.4, 0.08, 0.04), Color("d9d4c4"))
		Meshes.box(st, Vector3(door_x + 0.1, 1.42, d - 0.1), Vector3(0.8, 0.07, 0.12), trim)
		Meshes.box(st, Vector3(door_x + 0.12, 0.0, d - 0.02), Vector3(0.76, 0.1, 0.22), Color("8a867c"))
		Meshes.box(st, Vector3(door_x + 0.18, 0.1, d - 0.02), Vector3(0.64, 0.08, 0.14), Color("9a968a"))
	elif look.get("crow", false) or look.get("bay", false):
		Meshes.box(st, Vector3(door_x + 0.16, 0.0, d - 0.02), Vector3(0.68, 0.08, 0.16), trim.darkened(0.25))  # a worn step

## Area railings along the pavement, with a gap for the door's steps.
static func _railings(st: SurfaceTool, w: int, d: int, door_x: int) -> void:
	for x in w:
		if x == door_x:
			continue
		Meshes.box(st, Vector3(x, 0.46, d + 0.1), Vector3(1.0, 0.04, 0.04), BLACK)
		for k in 3:
			Meshes.box(st, Vector3(x + 0.1 + k * 0.4, 0.0, d + 0.1), Vector3(0.04, 0.5, 0.04), BLACK)

## Crow-stepped gables on both ends, as Landmarks._crow_steps but sized to the building and its wall colour.
static func _crow_steps(st: SurfaceTool, w: int, d: int, hgt: float, rise: float, wall: Color) -> void:
	for xe in [-0.18, w + 0.18 - 0.14]:
		for side in [-1.0, 1.0]:
			for k in 3:
				var run := (d * 0.5) / 3.0
				var z0: float = d * 0.5 + (run * k if side > 0 else -run * (k + 1))
				var top := hgt + rise * (1.0 - (run * k) / (d * 0.5))
				Meshes.box(st, Vector3(xe, hgt - 0.02, z0), Vector3(0.14, top - hgt + 0.12, run), wall)
