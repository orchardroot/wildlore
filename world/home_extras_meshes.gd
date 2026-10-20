class_name HomeExtrasMeshes
extends RefCounted
## Meshes for the 3.1 home and garden extras, in the flat-shaded vertex-colour style of home_meshes.gd: the souvenir
## shelf (built from what's set on it), the framed Gazetteer plaque boards, and the garden's bird table, bug hotel
## and pond. Local origin is the tile centre on the ground; shelf and board face +z (the scene rotates them).

const OAK := Color("5a3b26")
const OAK_LIGHT := Color("7a5236")
const BACK := Color("e4d6b4")
const BRASS := Color("c9a54a")
const CREAM := Color("f2ead2")
const NATION_COLOURS := {"england": Color("d04040"), "wales": Color("3f9a4a"), "scotland": Color("2f6fb0"),
	"northern_ireland": Color("c8a040"), "ireland": Color("2fa070"), "mann": Color("9a4a9a")}
## Shelf boards: surface heights of the two tiers, and the x of the three places on each.
const TIERS := [0.4, 0.86]
const PLACES := [-0.26, 0.0, 0.26]

static var _cache := {}

static func _cached(key: String, make: Callable) -> ArrayMesh:
	if not _cache.has(key):
		_cache[key] = make.call()
	return _cache[key]

static func _mi(mesh: ArrayMesh, shadow := true) -> MeshInstance3D:
	return HomeMeshes._mi(mesh, shadow)

# --- the souvenir shelf --------------------------------------------------------------------------

## A small oak display unit with two tiers of three places. `ids` are the six souvenir ids in slot order ("" empty).
static func shelf_node(ids: Array) -> Node3D:
	var n := Node3D.new()
	n.add_child(_mi(_cached("souv_shelf", _shelf)))
	var st := Meshes._st()
	var rng := Meshes._rng(311)
	var any := false
	for i in mini(ids.size(), 6):
		var s := HomeExtras.souvenir(str(ids[i]))
		if s.is_empty():
			continue
		any = true
		_item(st, rng, str(s.shape), Vector3(PLACES[i % 3], TIERS[i / 3], 0.0), s.col, s.col2)
	if any:
		var mi := _mi(Meshes._finish(st), false)
		mi.name = "Souvenirs"
		n.add_child(mi)
	return n

static func _shelf() -> ArrayMesh:
	var st := Meshes._st()
	Meshes.box(st, Vector3(-0.44, 0.0, -0.17), Vector3(0.88, 0.08, 0.34), OAK.darkened(0.15))   # plinth
	Meshes.box(st, Vector3(-0.42, 0.08, -0.17), Vector3(0.84, 1.24, 0.03), BACK, BACK.darkened(0.05))  # backing
	Meshes.box(st, Vector3(-0.44, 0.08, -0.17), Vector3(0.05, 1.28, 0.34), OAK)    # sides
	Meshes.box(st, Vector3(0.39, 0.08, -0.17), Vector3(0.05, 1.28, 0.34), OAK)
	for y in TIERS:  # the boards, with a little brass lip
		Meshes.box(st, Vector3(-0.42, y - 0.04, -0.15), Vector3(0.84, 0.04, 0.3), OAK_LIGHT)
		Meshes.box(st, Vector3(-0.42, y - 0.04, 0.13), Vector3(0.84, 0.05, 0.02), BRASS.darkened(0.1))
	Meshes.box(st, Vector3(-0.46, 1.34, -0.19), Vector3(0.92, 0.07, 0.38), OAK)    # cornice
	Meshes.box(st, Vector3(-0.36, 1.41, -0.15), Vector3(0.72, 0.06, 0.3), OAK_LIGHT)
	return Meshes._finish(st)

## One souvenir standing on a shelf at `at` (its base centre). About 0.2 across and 0.25 high at most.
static func _item(st: SurfaceTool, rng: RandomNumberGenerator, shape: String, at: Vector3, c: Color, c2: Color) -> void:
	match shape:
		"stick":  # a stick of rock or a miniature hurley, leaning back
			Meshes.box(st, at + Vector3(-0.025, 0.0, -0.03), Vector3(0.05, 0.3, 0.05), c)
			Meshes.box(st, at + Vector3(-0.027, 0.08, -0.032), Vector3(0.054, 0.04, 0.054), c2)
			Meshes.box(st, at + Vector3(-0.027, 0.17, -0.032), Vector3(0.054, 0.04, 0.054), c2)
		"jug":
			Meshes.cylinder(st, at, 0.075, 0.15, 8, c)
			Meshes.blob(st, at + Vector3(0, 0.2, 0), Vector3(0.06, 0.06, 0.06), c2, rng, 0.1)
			Meshes.box(st, at + Vector3(-0.1, 0.07, -0.015), Vector3(0.04, 0.07, 0.03), c)
			Meshes.box(st, at + Vector3(-0.09, 0.2, -0.07), Vector3(0.18, 0.025, 0.14), c.darkened(0.2))  # the hat
		"helmet":
			Meshes.blob(st, at + Vector3(0, 0.1, 0), Vector3(0.09, 0.09, 0.08), c, rng, 0.08)
			Meshes.box(st, at + Vector3(-0.1, 0.12, -0.015), Vector3(0.04, 0.12, 0.03), c2)
			Meshes.box(st, at + Vector3(0.06, 0.12, -0.015), Vector3(0.04, 0.12, 0.03), c2)
			Meshes.box(st, at + Vector3(-0.012, 0.0, 0.06), Vector3(0.024, 0.1, 0.01), c.darkened(0.3))
		"pencil":  # a big pencil stood on its end
			Meshes.box(st, at + Vector3(-0.03, 0.0, -0.03), Vector3(0.06, 0.28, 0.06), c)
			Meshes.cone(st, at + Vector3(0, 0.28, 0), 0.03, 0.07, 6, c2.lightened(0.3), rng)
			Meshes.box(st, at + Vector3(-0.031, 0.0, -0.031), Vector3(0.062, 0.05, 0.062), Color("d06060"))
		"bead", "ball":
			Meshes.blob(st, at + Vector3(0, 0.07, 0), Vector3(0.07, 0.07, 0.07), c, rng, 0.06 if shape == "ball" else 0.18)
			Meshes.box(st, at + Vector3(0.02, 0.1, 0.055), Vector3(0.025, 0.025, 0.02), c2)  # a glint
		"badge", "coaster":  # a flat disc standing up (badge) or propped (coaster)
			Meshes.cylinder(st, at + Vector3(0, 0.0, 0.0), 0.1, 0.02, 10, c.darkened(0.3))
			Meshes.box(st, at + Vector3(-0.07, 0.02, -0.07), Vector3(0.14, 0.16 if shape == "badge" else 0.03, 0.03), c)
			Meshes.box(st, at + Vector3(-0.03, 0.08, -0.04), Vector3(0.06, 0.06, 0.01), c2)
		"figure":  # a little animal: body, head, ears
			Meshes.blob(st, at + Vector3(0, 0.09, 0), Vector3(0.09, 0.08, 0.07), c, rng, 0.1)
			Meshes.blob(st, at + Vector3(0.05, 0.19, 0.02), Vector3(0.05, 0.05, 0.05), c, rng, 0.1)
			Meshes.box(st, at + Vector3(0.03, 0.23, 0.0), Vector3(0.03, 0.05, 0.03), c2)
			Meshes.box(st, at + Vector3(0.06, 0.23, 0.0), Vector3(0.03, 0.05, 0.03), c2)
			Meshes.box(st, at + Vector3(-0.06, 0.0, -0.06), Vector3(0.12, 0.02, 0.12), c2.darkened(0.3))
		"ring":  # a gold band on a little velvet cushion
			Meshes.box(st, at + Vector3(-0.08, 0.0, -0.06), Vector3(0.16, 0.05, 0.12), Color("5a1f2a"))
			Meshes.cylinder(st, at + Vector3(0, 0.05, 0), 0.06, 0.03, 10, c)
			Meshes.cylinder(st, at + Vector3(0, 0.05, 0), 0.036, 0.034, 10, Color("5a1f2a"))
			Meshes.blob(st, at + Vector3(0, 0.1, 0.0), Vector3(0.025, 0.025, 0.02), c2, rng, 0.05)
		"lamp":
			Meshes.cylinder(st, at, 0.06, 0.14, 8, c)
			Meshes.cylinder(st, at + Vector3(0, 0.14, 0), 0.045, 0.1, 8, c2.darkened(0.1))
			Meshes.box(st, at + Vector3(-0.05, 0.24, -0.01), Vector3(0.1, 0.02, 0.02), c)
			Meshes.box(st, at + Vector3(-0.01, 0.25, -0.01), Vector3(0.02, 0.04, 0.02), c)
		"tin":
			Meshes.cylinder(st, at, 0.09, 0.14, 10, c)
			Meshes.box(st, at + Vector3(-0.09, 0.05, 0.07), Vector3(0.18, 0.04, 0.02), c2)
			Meshes.cylinder(st, at + Vector3(0, 0.14, 0), 0.095, 0.025, 10, c.darkened(0.2))
		"cloth":  # a folded swatch or doily, two layers
			Meshes.box(st, at + Vector3(-0.1, 0.0, -0.08), Vector3(0.2, 0.03, 0.16), c)
			Meshes.box(st, at + Vector3(-0.09, 0.03, -0.07), Vector3(0.18, 0.025, 0.14), c2)
			Meshes.box(st, at + Vector3(-0.1, 0.0, -0.01), Vector3(0.2, 0.055, 0.02), c.darkened(0.15))
		_:
			Meshes.box(st, at + Vector3(-0.06, 0.0, -0.06), Vector3(0.12, 0.12, 0.12), c)

# --- the plaque boards ---------------------------------------------------------------------------

## A framed board of six little frames, one a nation: the coloured band fills as you read its plaques, and a
## brass star comes up when you've read them all. `boards` is HomeExtras.boards().
static func boards_node(boards: Array) -> Node3D:
	var n := Node3D.new()
	n.add_child(_mi(_cached("board_frame", _board_frame)))
	var st := Meshes._st()
	for i in mini(boards.size(), 6):
		var b: Dictionary = boards[i]
		var x := -0.19 + (i % 2) * 0.38
		var y := 1.12 - (i / 2) * 0.36
		var col: Color = NATION_COLOURS.get(str(b.nation), Color("888888"))
		var total := int(b.total)
		var f := float(int(b.read)) / float(total) if total > 0 else 0.0
		Meshes.box(st, Vector3(x - 0.16, y - 0.14, 0.015), Vector3(0.32, 0.28, 0.02), OAK_LIGHT)       # the little frame
		Meshes.box(st, Vector3(x - 0.14, y - 0.12, 0.034), Vector3(0.28, 0.24, 0.01), CREAM)            # card
		Meshes.box(st, Vector3(x - 0.12, y - 0.1, 0.045), Vector3(0.24, 0.05, 0.008), col.darkened(0.55))  # band track
		if f > 0.0:
			Meshes.box(st, Vector3(x - 0.12, y - 0.1, 0.05), Vector3(0.24 * f, 0.05, 0.008), col)
		for k in 3:  # lines of "writing"
			Meshes.box(st, Vector3(x - 0.12, y + 0.0 + k * 0.035, 0.045), Vector3(0.24 - k * 0.05, 0.012, 0.006), Color("b8a88a"))
		if total > 0 and int(b.read) >= total:
			Meshes.box(st, Vector3(x + 0.07, y + 0.05, 0.06), Vector3(0.05, 0.05, 0.01), BRASS, BRASS.lightened(0.3))
	var mi := _mi(Meshes._finish(st), false)
	mi.name = "Frames"
	n.add_child(mi)
	return n

static func _board_frame() -> ArrayMesh:
	var st := Meshes._st()
	Meshes.box(st, Vector3(-0.46, 0.2, -0.01), Vector3(0.92, 1.1, 0.04), OAK.darkened(0.1))
	Meshes.box(st, Vector3(-0.42, 0.24, 0.03), Vector3(0.84, 1.02, 0.01), Color("2c4a3a"))   # green baize behind
	Meshes.box(st, Vector3(-0.2, 1.3, -0.02), Vector3(0.4, 0.08, 0.05), BRASS.darkened(0.1))  # a brass title strip
	return Meshes._finish(st)

# --- the garden features -------------------------------------------------------------------------

static func feature_node(kind: String) -> Node3D:
	var n := Node3D.new()
	n.add_child(_mi(_cached("garden:" + kind, func(): return _feature(kind))))
	return n

static func _feature(kind: String) -> ArrayMesh:
	var st := Meshes._st()
	var rng := Meshes._rng(5100 + kind.length())
	match kind:
		"bird_table":  # a post, a tray with a little thatched roof
			Meshes.box(st, Vector3(-0.04, 0.0, -0.04), Vector3(0.08, 0.7, 0.08), OAK)
			Meshes.box(st, Vector3(-0.3, 0.7, -0.26), Vector3(0.6, 0.05, 0.52), OAK_LIGHT)
			Meshes.box(st, Vector3(-0.3, 0.75, -0.26), Vector3(0.6, 0.04, 0.03), OAK)
			Meshes.box(st, Vector3(-0.3, 0.75, 0.23), Vector3(0.6, 0.04, 0.03), OAK)
			for i in 6:  # seed and crumbs
				Meshes.box(st, Vector3(-0.22 + rng.randf() * 0.4, 0.75, -0.1 + rng.randf() * 0.2), Vector3(0.04, 0.02, 0.04), Color("d8b860"))
			Meshes.box(st, Vector3(-0.28, 1.08, -0.26), Vector3(0.04, 0.3, 0.04), OAK)  # roof posts
			Meshes.box(st, Vector3(0.24, 1.08, -0.26), Vector3(0.04, 0.3, 0.04), OAK)
			Meshes.box(st, Vector3(-0.36, 1.36, -0.32), Vector3(0.72, 0.07, 0.64), Color("a08a4a"))
			Meshes.box(st, Vector3(-0.26, 1.42, -0.24), Vector3(0.52, 0.06, 0.48), Color("b89c58"))
		"bug_hotel":  # stacked pallets stuffed with canes, bark, pine cones and straw
			var cols := [Color("8a6a3a"), Color("6a4a2a"), Color("a08a4a"), Color("4a3a2a"), Color("7a5a38")]
			for tier in 3:
				var y := 0.04 + tier * 0.34
				Meshes.box(st, Vector3(-0.38, y, -0.2), Vector3(0.76, 0.04, 0.4), OAK)
				for k in 8:
					var c: Color = cols[(k + tier) % cols.size()]
					Meshes.box(st, Vector3(-0.35 + k * 0.088, y + 0.04, -0.17), Vector3(0.075, 0.26, 0.34), c.darkened(rng.randf() * 0.12))
				Meshes.box(st, Vector3(-0.38, y + 0.04, -0.2), Vector3(0.03, 0.26, 0.4), OAK)
				Meshes.box(st, Vector3(0.35, y + 0.04, -0.2), Vector3(0.03, 0.26, 0.4), OAK)
			Meshes.box(st, Vector3(-0.42, 1.06, -0.24), Vector3(0.84, 0.05, 0.48), Color("5a7a3a"), Color("6f9a46"))  # turf roof
		"pond":  # a stone-edged pool with lily pads and reeds
			var water := Color("3f7f96")
			Meshes.cylinder(st, Vector3(0, 0.0, 0), 0.5, 0.05, 12, Color("7a7468"))
			Meshes.cylinder(st, Vector3(0, 0.04, 0), 0.4, 0.02, 12, water)
			Meshes.cylinder(st, Vector3(0, 0.055, 0), 0.34, 0.006, 12, water.lightened(0.18))
			for i in 8:  # edging stones
				var a := i * TAU / 8.0 + 0.2
				Meshes.blob(st, Vector3(cos(a) * 0.46, 0.05, sin(a) * 0.46), Vector3(0.09, 0.06, 0.08), Color("8a8478"), rng, 0.2)
			for p in [Vector3(-0.1, 0.06, 0.08), Vector3(0.14, 0.06, -0.06), Vector3(0.0, 0.06, -0.16)]:
				Meshes.cylinder(st, p, 0.07, 0.008, 8, Color("4f8a3e"))
			Meshes.box(st, Vector3(0.12, 0.062, -0.08), Vector3(0.04, 0.01, 0.04), Color("f0d0e0"))  # a lily
			for k in 4:  # reeds on the far side
				Meshes.box(st, Vector3(-0.3 + k * 0.05, 0.05, -0.38), Vector3(0.016, 0.4 + k % 2 * 0.1, 0.016), Color("5a7a3a"))
	return Meshes._finish(st)
