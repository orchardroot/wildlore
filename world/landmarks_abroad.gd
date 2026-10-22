class_name AbroadStyles
extends RefCounted
## These isles abroad (wave 45 L): the street architecture of the places the peoples of Britain and Ireland settled,
## so Gaiman, Baddeck, Boston, Bristol (Tennessee and Virginia) and Roscoff don't look like every other town.
## Same contract and dressings as StreetsEW (world/landmarks_streets_ew.gd): a Landmarks._house with its own palette
## plus lintels, parapets, porches and so on. Called from Meshes.building (one hook).

## name -> {walls: [palette], roof, storeys, terrace, doors: [palette], plus the StreetsEW dressings}
const DEFS := {
	# Gaiman: low red-brick houses and chapels built by the Welsh settlers, a tin roof, a whitewashed render here and there
	"gaiman_brick": {"walls": [Color("a4523c"), Color("9a4a36"), Color("b0604a"), Color("e8e0cc")], "roof": Color("8a8f94"),
		"storeys": 1, "trim": Color("e8dcc0"), "surround": Color("e8dcc0"), "doors": [Color("2f5a3a"), Color("6a3a2a"), Color("2f4a6a")]},
	# Cape Breton: cedar shingle and white clapboard, steep roofs for the snow
	"cb_shingle": {"walls": [Color("f2f0ea"), Color("b9b2a2"), Color("d9d2c2"), Color("c95a4a")], "roof": Color("3e4650"),
		"storeys": 2, "trim": Color("fbfaf4"), "surround": Color("fbfaf4"), "porch": Color("fbfaf4"),
		"doors": [Color("a02a2a"), Color("2a4a6a"), Color("2f5a3a")]},
	# Boston: red-brick rowhouses with bow fronts and black railings
	"boston_brick": {"walls": [Color("8e3e30"), Color("98463a"), Color("84382c")], "roof": Color("3a3e46"), "storeys": 3,
		"terrace": true, "trim": Color("e6dccb"), "string": Color("e6dccb"), "bays": 2, "railings": true,
		"doors": [Color("1c1c1e"), Color("2a4a3a"), Color("5a2a2a")]},
	# Boston's wooden triple-deckers: one flat per floor, a porch on each, painted every colour of New England
	"boston_triple": {"walls": [Color("c9d6e0"), Color("e8dcae"), Color("cfd8c4"), Color("e6c8b8")], "roof": Color("4a4f58"),
		"storeys": 3, "trim": Color("fbf8f0"), "balcony": Color("fbf8f0"), "surround": Color("fbf8f0"),
		"doors": [Color("2a3a5a"), Color("5a2a2a")]},
	# Bristol, Tennessee and Virginia: brick shopfronts on State Street, a cornice on top
	"bristol_store": {"walls": [Color("9a5440"), Color("a86048"), Color("8c4a3a"), Color("c8b48c")], "roof": Color("4a4a4e"),
		"storeys": 2, "trim": Color("e8dcc0"), "parapet": Color("d8ccb0"), "doors": [Color("2a2a2a"), Color("2a4a5a")]},
	# Appalachian clapboard: a farmhouse with a deep porch for sitting out with a fiddle
	"appalachian_frame": {"walls": [Color("f0ece0"), Color("d8cbb0"), Color("b8c4b0")], "roof": Color("7a3a30"), "storeys": 2,
		"trim": Color("fbf8f0"), "porch": Color("8a6a4a"), "stacks": true, "doors": [Color("3a2a22"), Color("2a4a3a")]},
	# Roscoff: grey granite houses with dark slate roofs and tall chimney stacks, shutters in sea blue
	"breton_granite": {"walls": [Color("9a9a94"), Color("a6a49c"), Color("8e8f8a")], "roof": Color("3a3f4a"), "storeys": 2,
		"trim": Color("c8c6bc"), "surround": Color("2f6a8a"), "stacks": true, "doors": [Color("2f6a8a"), Color("3a5a3a"), Color("8a3a34")]},
	# A Breton whitewashed fisher's house
	"breton_white": {"walls": [Color("f2f0ea"), Color("ebe7dc")], "roof": Color("3a3f4a"), "storeys": 1,
		"surround": Color("8e8f8a"), "stacks": true, "doors": [Color("2f6a8a"), Color("2a4a7a")]},
}
const STYLES := ["gaiman_brick", "cb_shingle", "boston_brick", "boston_triple", "bristol_store", "appalachian_frame",
	"breton_granite", "breton_white"]

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
	Landmarks._house(st, wst, w, d, door_x, rng, wall, def.roof, storeys, def.get("terrace", false), false)
	var hgt := 1.15 * storeys + 0.2
	if def.has("surround"):
		StreetsEW._surrounds(st, w, d, storeys, door_x, def.surround)
	if def.has("trim"):
		StreetsEW._lintels(st, w, float(d), storeys, door_x, def.trim)
	if def.has("string") and storeys > 1:
		Meshes.box(st, Vector3(-0.02, 1.2, d - 0.07), Vector3(w + 0.04, 0.07, 0.1), def.string)
	if def.has("parapet"):
		Meshes.box(st, Vector3(-0.06, hgt - 0.02, d - 0.12), Vector3(w + 0.12, 0.3, 0.2), def.parapet)
		Meshes.box(st, Vector3(-0.06, hgt + 0.28, d - 0.1), Vector3(w + 0.12, 0.08, 0.16), def.parapet.lightened(0.05))
	if def.has("bays"):
		StreetsEW._bays(st, wst, w, d, door_x, wall, int(def.bays))
	if def.has("balcony") and storeys > 1:
		StreetsEW._balcony(st, w, d, door_x, def.balcony)
	if def.has("stacks"):
		StreetsEW._stacks(st, w, d, hgt, wall)
	if def.has("railings"):
		StreetsEW._railings(st, w, d, door_x, Color("1d1f24"))
	var porch: Color = def.get("porch", Color(0, 0, 0, 0))
	var dc: Array = def.doors
	StreetsEW._door_paint(st, door_x, float(d), dc[rng.randi() % dc.size()], porch, wall)
	return [Meshes._finish(st), Meshes._finish(wst), Landmarks._chimneys]
