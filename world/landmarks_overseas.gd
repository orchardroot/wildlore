class_name OverseasStyles
extends RefCounted
## British Overseas Territories (3.3): local street architecture, a few point props (palm, cannon, salt heap, buried
## house) and the territory water tints. Building styles are Landmarks._house with their own palette plus a few
## StreetsEW dressings; called from Meshes.building (one hook). Same rules as Landmarks: vertex colour, low poly,
## origin at the footprint's north-west corner, door on the south.

## name -> {walls: [palette], roof, storeys, plus the StreetsEW dressings: trim, string, parapet, surround, balcony, stacks, porch, doors}
const DEFS := {
	"carib_pastel": {"walls": [Color("f2b6c0"), Color("a9dcc0"), Color("f2dc7e"), Color("9ccbe8"), Color("f5c09a"), Color("d6b8e6")],
		"roof": Color("b5483c"), "storeys": 2, "trim": Color("fbf6ea"), "surround": Color("fbf6ea"), "balcony": Color("f4f0e6"),
		"doors": [Color("2a8a8a"), Color("fbf6ea"), Color("2f5a8a")]},
	"carib_cottage": {"walls": [Color("f0e8d4"), Color("9ccbe8"), Color("f5c09a"), Color("a9dcc0")],
		"roof": Color("6e8a7a"), "storeys": 1, "trim": Color("fbf6ea"), "surround": Color("fbf6ea"),
		"doors": [Color("b5483c"), Color("2f5a8a"), Color("fbf6ea")]},
	"bermuda_cottage": {"walls": [Color("f2b6c0"), Color("f5e6a8"), Color("a9dcc0"), Color("f5c09a"), Color("f4f0e6")],
		"roof": Color("f6f3ea"), "storeys": 2, "stacks": true, "surround": Color("4a5a6e"), "string": Color("fbf6ea"),
		"doors": [Color("2f5a8a"), Color("2a2a2a"), Color("2f6a4a")]},
	"bermuda_dockyard": {"walls": [Color("d8ccaa"), Color("d0c4a2"), Color("dcd2b4")], "roof": Color("5a5f68"), "storeys": 3,
		"trim": Color("efe6cc"), "string": Color("efe6cc"), "parapet": Color("efe6cc"), "railings": true,
		"doors": [Color("2a3a4a"), Color("3a2a22")]},
	"cayman_clapboard": {"walls": [Color("f4efe2"), Color("cfe3ee"), Color("d7ead2"), Color("f5e6a8")],
		"roof": Color("b5483c"), "storeys": 2, "trim": Color("3f6a8a"), "balcony": Color("3f6a8a"), "surround": Color("3f6a8a"),
		"doors": [Color("3f6a8a"), Color("b5483c")]},
	"tci_salt": {"walls": [Color("f4efe2"), Color("efe6cc"), Color("e8dcc0")], "roof": Color("7a8590"), "storeys": 2,
		"trim": Color("fbf6ea"), "balcony": Color("5a4636"), "surround": Color("4a6a7a"),
		"doors": [Color("4a6a7a"), Color("5a4636")]},
	"bvi_stone": {"walls": [Color("e8dcc4"), Color("dfd2b6"), Color("efe4cc")], "roof": Color("c0603c"), "storeys": 2,
		"trim": Color("fbf6ea"), "surround": Color("fbf6ea"), "balcony": Color("2f6a5a"),
		"doors": [Color("2f6a5a"), Color("3a2a22")]},
	"anguilla_coral": {"walls": [Color("f1e4cf"), Color("e8d3b5"), Color("f5ead6")], "roof": Color("c0503c"), "storeys": 1,
		"trim": Color("fbf6ea"), "surround": Color("3f8a9a"),
		"doors": [Color("3f8a9a"), Color("fbf6ea"), Color("c0503c")]},
	"montserrat_cottage": {"walls": [Color("f0ead8"), Color("c9c4b0"), Color("e6dcc2")], "roof": Color("8a3a30"), "storeys": 1,
		"trim": Color("fbf6ea"), "surround": Color("2f6a3a"),
		"doors": [Color("2f6a3a"), Color("fbf6ea")]},
	"fort_stone": {"walls": [Color("a8a290"), Color("a09a88"), Color("b0aa98")], "roof": Color("5a5f68"), "storeys": 2,
		"parapet": Color("c0b9a2"), "string": Color("c0b9a2"), "doors": [Color("2a2a2a"), Color("3a2a22")]},
}
## One-off landmarks (not StreetsEW-style houses): Gibbs Hill's cast-iron lighthouse, the granite boulders of The Baths,
## the Soufriere Hills volcano with its observatory hut.
const LANDMARKS := ["gibbs_hill", "baths_boulders", "soufriere_hills"]
const STYLES := ["carib_pastel", "carib_cottage", "bermuda_cottage", "bermuda_dockyard", "cayman_clapboard", "tci_salt",
	"bvi_stone", "anguilla_coral", "montserrat_cottage", "fort_stone"]

## Point props and tile props (a legend_extra "prop") this file draws.
const PROPS := ["palm", "cannon", "salt_heap", "buried_roof"]
## legend_extra prop name -> [mesh constructor name, variants, foliage?] (read by ZoneBuilder._props)
const TILE_PROPS := {"palm": ["palm", 3, true]}

const FROND := [Color("3f8a3a"), Color("4c9a40"), Color("358034")]
const SEA_DEEP := Color(0.04, 0.3, 0.42)
const SEA_SHALLOW := Color(0.2, 0.74, 0.74)

static func has_style(style: String) -> bool:
	return DEFS.has(style) or style in LANDMARKS

## A house-like style (name board hangs over the windows), as opposed to a landmark that stands on its own.
static func is_house(style: String) -> bool:
	return DEFS.has(style)

## The shallow/deep water colours for a zone: a legend_extra "_water" entry {"shallow": "#hex", "deep": "#hex"} tints
## both sheets (Caribbean turquoise); no entry keeps the grey-green home waters.
static func water_pair(z: ZoneData, deep: bool, fallback: Array) -> Array:
	var tint: Dictionary = z.legend_extra.get("_water", {})
	if tint.is_empty():
		return fallback
	if deep:
		return [Color(str(tint.get("deep", "#0b4a6a"))), Color(str(tint.get("deep_top", "#2f8ca8")))]
	return [Color(str(tint.get("deep", "#0b4a6a"))).lerp(Color(str(tint.get("shallow", "#35c4c0"))), 0.55), Color(str(tint.get("shallow", "#35c4c0")))]

## Same contract as Landmarks.building: [body_mesh, windows_mesh, chimney tops].
static func building(w: int, d: int, style: String, door_x: int, seed_value: int) -> Array:
	var rng := Meshes._rng(seed_value)
	var st := Meshes._st()
	var wst := Meshes._st()
	if style in LANDMARKS:
		match style:
			"gibbs_hill":
				_gibbs_hill(st, wst, w, d, door_x, rng)
			"baths_boulders":
				_baths(st, w, d, door_x, rng)
			_:
				_volcano(st, w, d, door_x, rng)
		return [Meshes._finish(st), Meshes._finish(wst), PackedVector3Array()]
	Landmarks._wr.seed = seed_value * 7 + 3
	Landmarks._chimneys = PackedVector3Array()
	var def: Dictionary = DEFS[style]
	var walls: Array = def.walls
	var wall: Color = walls[rng.randi() % walls.size()]
	var storeys: int = def.storeys
	Landmarks._house(st, wst, w, d, door_x, rng, wall, def.roof, storeys, false, false)
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
	if def.has("balcony") and storeys > 1:
		StreetsEW._balcony(st, w, d, door_x, def.balcony)
	if def.has("stacks"):
		StreetsEW._stacks(st, w, d, hgt, wall)
	if def.has("railings"):
		StreetsEW._railings(st, w, d, door_x, Color("1d1f24"))
	var dc: Array = def.doors
	StreetsEW._door_paint(st, door_x, float(d), dc[rng.randi() % dc.size()], Color(0, 0, 0, 0), wall)
	if style == "fort_stone":
		_battlements(st, w, d, hgt)
	return [Meshes._finish(st), Meshes._finish(wst), Landmarks._chimneys]

## Crenellations along the front and sides of a fort's wall-head.
static func _battlements(st: SurfaceTool, w: int, d: int, hgt: float) -> void:
	var stone := Color("b8b29c")
	for i in range(int(w * 2)):
		if i % 2 == 0:
			Meshes.box(st, Vector3(i * 0.5, hgt + 0.3, d - 0.14), Vector3(0.4, 0.26, 0.16), stone)

## A point prop mesh by name (ZoneBuilder._ctor calls this for anything in PROPS).
static func prop(name: String, variant: int) -> ArrayMesh:
	match name:
		"palm":
			return palm(variant)
		"cannon":
			return cannon()
		"salt_heap":
			return salt_heap(variant)
		_:
			return buried_roof(variant)

## A coconut palm: a trunk that leans and curves (stacked segments), a ring of drooping fronds and a few coconuts.
static func palm(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(7000 + variant)
	var st := Meshes._st()
	var lean := 0.07 + 0.03 * (variant % 3)
	var trunk := Color("8a6a4a")
	var x := 0.0
	var y := 0.0
	for i in 5:
		Meshes.cylinder(st, Vector3(x, y, 0), 0.1 - i * 0.008, 0.36, 5, trunk.darkened(0.04 * (i % 2)))
		x += lean * (1.0 + i * 0.25)
		y += 0.34
	var top := Vector3(x, y + 0.02, 0)
	var g: Color = FROND[variant % FROND.size()]
	for i in 8:
		var a := TAU * i / 8.0 + rng.randf() * 0.3
		var reach := 0.85 + rng.randf() * 0.25
		var tip := top + Vector3(cos(a) * reach, -0.32 - rng.randf() * 0.15, sin(a) * reach)
		var mid := top + Vector3(cos(a) * reach * 0.5, 0.12, sin(a) * reach * 0.5)
		var side := Vector3(-sin(a), 0, cos(a)) * 0.2
		var c := g.lightened(0.05 * (i % 3))
		Meshes._tri(st, top, mid + side, tip, c)
		Meshes._tri(st, top, tip, mid + side, c.darkened(0.25))
		Meshes._tri(st, top, tip, mid - side, c)
		Meshes._tri(st, top, mid - side, tip, c.darkened(0.25))
	for i in 3:
		Meshes.blob(st, top + Vector3(0.1 * i - 0.1, -0.12, 0.08 * (i % 2)), Vector3(0.09, 0.09, 0.09), Color("5a4630"), rng, 0.1)
	return Meshes._finish(st)

## An old iron muzzle-loader on a wooden carriage, pointing south over the water.
static func cannon() -> ArrayMesh:
	var st := Meshes._st()
	var wood := Color("6b4a32")
	var iron := Color("2c2f34")
	Meshes.box(st, Vector3(-0.28, 0.0, -0.3), Vector3(0.56, 0.18, 0.7), wood)
	Meshes.box(st, Vector3(-0.3, 0.0, -0.1), Vector3(0.1, 0.34, 0.1), wood.darkened(0.2))
	Meshes.box(st, Vector3(0.2, 0.0, -0.1), Vector3(0.1, 0.34, 0.1), wood.darkened(0.2))
	Landmarks._beam(st, Vector3(0, 0.36, -0.3), Vector3(0, 0.3, 0.5), 0.2, iron)
	Meshes.box(st, Vector3(-0.1, 0.26, 0.46), Vector3(0.2, 0.2, 0.08), iron.lightened(0.1))
	return Meshes._finish(st)

## A heap of raked sea salt, white with a blue-grey shadow side.
static func salt_heap(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(7100 + variant)
	var st := Meshes._st()
	Meshes.cone(st, Vector3(0, 0, 0), 0.5, 0.55 + 0.1 * (variant % 3), 7, Color("f2f4f6"), rng)
	Meshes.cone(st, Vector3(0.28, 0, 0.12), 0.28, 0.3, 6, Color("e4e8ec"), rng)
	return Meshes._finish(st)

## The top of a house swallowed by volcanic ash: a drift of grey, a roof ridge and a chimney sticking out.
static func buried_roof(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(7200 + variant)
	var st := Meshes._st()
	var ash := Color("77726e")
	Meshes.blob(st, Vector3(0, 0.15, 0), Vector3(0.55, 0.28, 0.5), ash, rng, 0.2)
	var roof := Color("8a3a30")
	var a := Vector3(-0.4, 0.3, -0.3)
	var b := Vector3(0.4, 0.3, -0.3)
	var c := Vector3(0.4, 0.3, 0.3)
	var d := Vector3(-0.4, 0.3, 0.3)
	var r0 := Vector3(-0.4, 0.62, 0.0)
	var r1 := Vector3(0.4, 0.62, 0.0)
	Meshes._quad(st, r0, r1, c, d, roof)
	Meshes._quad(st, r1, r0, a, b, roof.darkened(0.15))
	Meshes._tri(st, r0, d, a, ash)
	Meshes._tri(st, r1, b, c, ash)
	Meshes.box(st, Vector3(0.1, 0.5, -0.08), Vector3(0.14, 0.4, 0.16), Color("9a8e84"))
	Meshes.blob(st, Vector3(-0.35, 0.12, 0.3), Vector3(0.3, 0.14, 0.26), ash.darkened(0.06), rng, 0.2)
	return Meshes._finish(st)

## Gibbs Hill Lighthouse: a white cast-iron tower that tapers, a gallery, a lantern room and a dark cap, behind a
## low whitewashed keeper's cottage that carries the door.
static func _gibbs_hill(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var white := Color("f3f0e8")
	var cx := w * 0.5
	var cz := d - 2.3
	for i in 5:
		Meshes.cylinder(st, Vector3(cx, 0.9 + i * 1.0, cz), 0.72 - i * 0.07, 1.0, 10, white.darkened(0.04 * (i % 2)))
	Meshes.cylinder(st, Vector3(cx, 5.9, cz), 0.62, 0.14, 10, Color("2c2f36"))
	Meshes.cylinder(st, Vector3(cx, 6.04, cz), 0.4, 0.6, 10, Color("f6e7a0"))
	Meshes.cone(st, Vector3(cx, 6.64, cz), 0.52, 0.5, 10, Color("2c2f36"), rng)
	Meshes.box(st, Vector3(0.05, 0, d - 1.5), Vector3(w - 0.1, 1.3, 1.45), white.darkened(0.03))
	Landmarks._roof_at(st, -0.1, w + 0.1, d - 1.6, d, 1.3, 0.5, Color("e8e4d8"), white)
	Landmarks._door(st, door_x, d - 0.05, Color("3b5a7a"), 1.0)
	Landmarks._window(st, wst, 0.4, 0.5, d - 0.05, 0.5, 0.5, white)

## The Baths: huge rounded granite boulders heaped over a footprint, a dark gap at the door for the grotto.
static func _baths(st: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var greys := [Color("a9a398"), Color("b8b2a6"), Color("9a958b"), Color("c2bcae")]
	for i in w * 2:
		var bx := 0.4 + rng.randf() * (w - 0.8)
		var bz := 0.5 + rng.randf() * (d - 1.5)
		var r := 0.6 + rng.randf() * 0.5
		Meshes.blob(st, Vector3(bx, r * 0.8, bz), Vector3(r, r * 0.85, r), greys[i % greys.size()], rng, 0.1)
	for i in 3:
		Meshes.blob(st, Vector3(w * 0.5 + (i - 1) * 1.1, 1.9 + (i % 2) * 0.4, d * 0.4), Vector3(0.8, 0.7, 0.8), greys[(i + 1) % greys.size()], rng, 0.1)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.9), Vector3(0.8, 0.95, 0.9), Color("1f2326"))
		Meshes.blob(st, Vector3(door_x + 0.5, 1.0, d - 0.55), Vector3(0.7, 0.35, 0.5), greys[0], rng, 0.08)

## The Soufriere Hills: a grey-brown ash cone with a glowing crater and a plume, and the observatory hut at its foot.
static func _volcano(st: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var cx := w * 0.5
	var cz := (d - 1.6) * 0.5
	var ash := Color("6e6a66")
	Meshes.cone(st, Vector3(cx, 0, cz), minf(w, d) * 0.5 + 0.8, 4.6, 12, ash, rng)
	Meshes.cone(st, Vector3(cx - 1.4, 0, cz + 0.2), 1.6, 2.2, 8, ash.lightened(0.08), rng)
	Meshes.cone(st, Vector3(cx + 1.5, 0, cz - 0.1), 1.4, 1.8, 8, Color("5f6b4a"), rng)
	Meshes.cylinder(st, Vector3(cx, 4.4, cz), 0.5, 0.25, 8, Color("e8602a"))
	for i in 4:
		Meshes.blob(st, Vector3(cx + 0.3 * i, 5.0 + i * 0.5, cz + 0.2 * (i % 2)), Vector3(0.5 + 0.12 * i, 0.4, 0.5 + 0.12 * i), Color("8a8480").darkened(0.05 * i), rng, 0.15)
	var wall := Color("f0ead8")
	Meshes.box(st, Vector3(door_x - 0.9, 0, d - 1.5), Vector3(2.8, 1.1, 1.4), wall)
	Landmarks._roof_at(st, door_x - 1.0, door_x + 2.0, d - 1.6, d, 1.1, 0.45, Color("8a3a30"), wall)
	Landmarks._door(st, door_x, d - 0.1, Color("2f6a3a"), 0.95)
