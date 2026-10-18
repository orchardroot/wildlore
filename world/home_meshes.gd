class_name HomeMeshes
extends RefCounted
## Meshes for the home base, in the same flat-shaded vertex-colour style as world/meshes.gd: the trophy cabinet
## (built from what's on it, so it fills in as you play), the raised garden beds and the plants at each stage.

const OAK := Color("5a3b26")
const OAK_LIGHT := Color("7a5236")
const BAIZE := Color("27483a")
const BRASS := Color("c9a54a")
const SOIL := Color("3d2a1e")
const SOIL_TOP := Color("4a3324")
const SLEEPER := Color("6e5138")
## Fruit or flower colours per material, and the leaf green it grows with.
const FRUIT := {
	"sloes": [Color("3e4a80"), Color("5a68a6")], "hazelnuts": [Color("9a6a3a"), Color("b8884e")],
	"blackberries": [Color("2b1d33"), Color("4a2550")], "elderflower": [Color("f4ecd0"), Color("fffbea")],
	"wild_garlic": [Color("f6f4ea"), Color("ffffff")], "rowan_berry": [Color("d8452a"), Color("f0683a")],
	"hawthorn_berry": [Color("9a2030"), Color("c03040")],
}
const LEAF := {
	"sloes": Color("34502c"), "hazelnuts": Color("5c7f3a"), "blackberries": Color("3d5e2c"), "elderflower": Color("4f7a3a"),
	"wild_garlic": Color("3f7a34"), "rowan_berry": Color("4a7036"), "hawthorn_berry": Color("3f6a30"),
}

static var _cache := {}

static func _cached(key: String, make: Callable) -> ArrayMesh:
	if not _cache.has(key):
		_cache[key] = make.call()
	return _cache[key]

static func _mi(mesh: ArrayMesh, shadow := true) -> MeshInstance3D:
	Meshes.materials()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = Meshes.solid
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

# --- the trophy cabinet -----------------------------------------------------------------

## A two-tile oak cabinet against the north wall, green baize behind three shelves. Stones on the top shelf,
## awards in the middle, legend plaques at the bottom, and the diploma framed on the wall above.
static func shelf_node(trophies: Array) -> Node3D:
	var n := Node3D.new()
	n.add_child(_mi(_cached("cabinet", _cabinet)))
	var st := Meshes._st()
	var rng := Meshes._rng(77)
	var stones := trophies.filter(func(t): return t.kind == "stone")
	var awards := trophies.filter(func(t): return t.kind == "award")
	var legends := trophies.filter(func(t): return t.kind == "legend")
	# top shelf: the Wardstones, each on a little brass stand
	for i in stones.size():
		var x := -0.78 + i * 0.173
		var col: Color = TypeColours.COLOURS.get(str(stones[i].id), Color("9a9aa0"))
		Meshes.box(st, Vector3(x - 0.05, 1.22, -0.12), Vector3(0.1, 0.03, 0.1), BRASS)
		Meshes.blob(st, Vector3(x, 1.32, -0.07), Vector3(0.065, 0.085, 0.055), col, rng, 0.22)
		Meshes.box(st, Vector3(x - 0.012, 1.36, -0.02), Vector3(0.024, 0.024, 0.02), col.lightened(0.55))  # a glint
	# middle shelf: the Fieldbook awards
	for i in awards.size():
		var x := -0.6 + i * 0.4
		_award(st, rng, str(awards[i].id), Vector3(x, 0.72, -0.08))
	# bottom shelf: a brass-fronted plaque per legend
	for i in legends.size():
		var x := -0.8 + (i % 8) * 0.2 + 0.04
		var y := 0.18 + (i / 8) * 0.0
		Meshes.box(st, Vector3(x, y, -0.16), Vector3(0.16, 0.2, 0.05), OAK_LIGHT.darkened(0.1))
		Meshes.box(st, Vector3(x + 0.025, y + 0.04, -0.11), Vector3(0.11, 0.12, 0.012), BRASS, BRASS.lightened(0.2))
	var pillars := 0
	for t in trophies:
		match str(t.kind):
			"diploma":
				_diploma(st)
			"rosette":  # red show rosettes pinned along the middle shelf's lip, one per show won (up to five)
				for i in mini(5, int(t.get("n", 1))):
					_show_rosette(st, rng, Vector3(0.78 - i * 0.15, 0.6, 0.05))
			"title":  # the Moot Champion certificate, framed on the wall beside the diploma
				_certificate(st)
			"pillar":  # Pillar of the Community trophies along the top of the cabinet, either side of the pediment
				var x := -0.86 + pillars * 0.14 if pillars < 3 else 0.58 + (pillars - 3) * 0.14
				_pillar_trophy(st, rng, str(t.id), Vector3(x, 1.72, -0.16))
				pillars += 1
	if trophies.size() > 0:
		var mi := _mi(Meshes._finish(st), false)
		mi.name = "Trophies"
		n.add_child(mi)
	return n

static func _cabinet() -> ArrayMesh:
	var st := Meshes._st()
	# the carcass: sides, top, plinth, back
	Meshes.box(st, Vector3(-0.95, 0, -0.36), Vector3(1.9, 0.1, 0.42), OAK.darkened(0.2))           # plinth
	Meshes.box(st, Vector3(-0.95, 0.1, -0.36), Vector3(0.06, 1.55, 0.42), OAK)                     # left side
	Meshes.box(st, Vector3(0.89, 0.1, -0.36), Vector3(0.06, 1.55, 0.42), OAK)                      # right side
	Meshes.box(st, Vector3(-0.98, 1.65, -0.38), Vector3(1.96, 0.07, 0.46), OAK_LIGHT)              # top, a little proud
	Meshes.box(st, Vector3(-0.89, 0.1, -0.36), Vector3(1.78, 1.55, 0.04), BAIZE)                   # baize back
	for y in [0.12, 0.62, 1.12]:
		Meshes.box(st, Vector3(-0.89, y, -0.32), Vector3(1.78, 0.05, 0.36), OAK_LIGHT)              # shelves
		Meshes.box(st, Vector3(-0.89, y + 0.05, 0.03), Vector3(1.78, 0.018, 0.012), BRASS)           # a brass lip
	# a little carved pediment
	Meshes.box(st, Vector3(-0.5, 1.72, -0.34), Vector3(1.0, 0.08, 0.06), OAK)
	Meshes.box(st, Vector3(-0.2, 1.8, -0.34), Vector3(0.4, 0.06, 0.06), OAK_LIGHT)
	return Meshes._finish(st)

static func _award(st: SurfaceTool, rng: RandomNumberGenerator, id: String, at: Vector3) -> void:
	match id:
		"25":  # a green rosette with two tails
			Meshes.box(st, at + Vector3(-0.05, 0.0, 0.0), Vector3(0.04, 0.16, 0.01), Color("2f7a3a"))
			Meshes.box(st, at + Vector3(0.01, 0.0, 0.0), Vector3(0.04, 0.14, 0.01), Color("2f7a3a"))
			Meshes.cylinder(st, at + Vector3(0, 0.22, -0.02), 0.11, 0.02, 10, Color("3f9a4a"))
			Meshes.cylinder(st, at + Vector3(0, 0.22, 0.0), 0.05, 0.02, 8, BRASS)
		"50":  # a blue ribbon on a little stand
			Meshes.box(st, at + Vector3(-0.08, 0, -0.04), Vector3(0.16, 0.03, 0.08), OAK_LIGHT)
			Meshes.box(st, at + Vector3(-0.03, 0.03, -0.01), Vector3(0.06, 0.24, 0.012), Color("2f5fb0"))
			Meshes.box(st, at + Vector3(-0.045, 0.24, -0.015), Vector3(0.09, 0.06, 0.02), Color("3f72c8"))
		"100":  # a bronze medal on a tartan ribbon
			Meshes.box(st, at + Vector3(-0.035, 0.12, -0.01), Vector3(0.07, 0.16, 0.012), Color("9a2a2a"))
			Meshes.box(st, at + Vector3(-0.012, 0.12, -0.005), Vector3(0.024, 0.16, 0.012), Color("2a4a2a"))
			Meshes.cylinder(st, at + Vector3(0, 0.0, 0.0), 0.075, 0.12, 10, Color("b07a3a"))
		_:  # an oak shield with a brass boss
			Meshes.box(st, at + Vector3(-0.09, 0.02, -0.02), Vector3(0.18, 0.24, 0.03), OAK_LIGHT)
			Meshes.blob(st, at + Vector3(0, 0.14, 0.02), Vector3(0.04, 0.04, 0.02), BRASS, rng, 0.05)

## Garside's diploma in a gilt frame, hung above the cabinet. Cream paper, a few lines and a red (potato) seal.
static func _diploma(st: SurfaceTool) -> void:
	var z := -0.42
	Meshes.box(st, Vector3(-0.34, 2.0, z), Vector3(0.68, 0.5, 0.04), Color("b8913a"), Color("d8b45a"))
	Meshes.box(st, Vector3(-0.29, 2.05, z + 0.04), Vector3(0.58, 0.4, 0.008), Color("f2e8cc"))
	for i in 4:
		var w := 0.4 if i != 0 else 0.3
		Meshes.box(st, Vector3(-w * 0.5, 2.36 - i * 0.07, z + 0.05), Vector3(w, 0.014, 0.004), Color("6a5a48"))
	Meshes.cylinder(st, Vector3(0.17, 2.1, z + 0.05), 0.04, 0.008, 10, Color("a82a2a"))

## A red County Show rosette hanging from a shelf lip: two tails under a pleated disc with a gold centre.
static func _show_rosette(st: SurfaceTool, rng: RandomNumberGenerator, at: Vector3) -> void:
	Meshes.box(st, at + Vector3(-0.035, -0.17, 0.0), Vector3(0.03, 0.12, 0.008), Color("9a1f24"))
	Meshes.box(st, at + Vector3(0.006, -0.16, 0.0), Vector3(0.03, 0.11, 0.008), Color("9a1f24"))
	Meshes.blob(st, at + Vector3(0, -0.04, 0.01), Vector3(0.055, 0.055, 0.014), Color("c8282c"), rng, 0.12)
	Meshes.blob(st, at + Vector3(0, -0.04, 0.026), Vector3(0.022, 0.022, 0.008), BRASS, rng, 0.1)

static func _certificate(st: SurfaceTool) -> void:
	var z := -0.42
	Meshes.box(st, Vector3(0.46, 2.04, z), Vector3(0.4, 0.32, 0.04), Color("3a2a1e"), Color("5a4430"))
	Meshes.box(st, Vector3(0.49, 2.07, z + 0.04), Vector3(0.34, 0.26, 0.008), Color("efe6cf"))
	for i in 3:
		Meshes.box(st, Vector3(0.53, 2.27 - i * 0.06, z + 0.05), Vector3(0.26 if i else 0.2, 0.012, 0.004), Color("6a5a48"))
	Meshes.cylinder(st, Vector3(0.78, 2.1, z + 0.05), 0.03, 0.008, 10, Color("2f5fb0"))

## Each nation's Pillar trophy, small, on top of the cabinet.
static func _pillar_trophy(st: SurfaceTool, rng: RandomNumberGenerator, nation: String, at: Vector3) -> void:
	match nation:
		"england":  # a rolled scroll tied with a rose
			Meshes.box(st, at + Vector3(-0.05, 0.0, 0.0), Vector3(0.1, 0.035, 0.035), Color("efe3c2"))
			Meshes.blob(st, at + Vector3(0.0, 0.045, 0.02), Vector3(0.022, 0.022, 0.018), Color("c8282c"), rng, 0.2)
		"wales":  # a lovespoon stood upright
			Meshes.box(st, at + Vector3(-0.01, 0.0, 0.0), Vector3(0.02, 0.14, 0.012), Color("a8643a"))
			Meshes.blob(st, at + Vector3(0.0, 0.16, 0.0), Vector3(0.03, 0.04, 0.012), Color("a8643a"), rng, 0.1)
		"scotland":  # a silver quaich with its two lugs
			Meshes.cylinder(st, at, 0.045, 0.04, 10, Color("c8ccd2"))
			Meshes.box(st, at + Vector3(-0.07, 0.025, -0.008), Vector3(0.14, 0.012, 0.016), Color("b0b4ba"))
		"northern_ireland":  # a folded white linen sash
			Meshes.box(st, at + Vector3(-0.05, 0.0, -0.03), Vector3(0.1, 0.03, 0.06), Color("f2efe6"))
			Meshes.box(st, at + Vector3(-0.012, 0.0, 0.03), Vector3(0.024, 0.031, 0.004), Color("2f7a3a"))
		"ireland":  # a gold brooch on a little velvet cushion
			Meshes.box(st, at + Vector3(-0.05, 0.0, -0.04), Vector3(0.1, 0.03, 0.08), Color("6a2040"))
			Meshes.blob(st, at + Vector3(0.0, 0.045, 0.0), Vector3(0.025, 0.02, 0.012), BRASS, rng, 0.15)
		_:  # the Manx Three Legs badge, on its edge
			Meshes.blob(st, at + Vector3(0, 0.045, 0.0), Vector3(0.04, 0.04, 0.012), Color("b8282c"), rng, 0.1)
			Meshes.blob(st, at + Vector3(0, 0.045, 0.014), Vector3(0.016, 0.016, 0.006), BRASS, rng, 0.1)

# --- the garden ---------------------------------------------------------------------------

## A raised bed: old railway-sleeper sides round a mound of dark, raked soil.
static func bed_node() -> Node3D:
	var n := Node3D.new()
	n.add_child(_mi(_cached("bed", _bed)))
	return n

static func _bed() -> ArrayMesh:
	var st := Meshes._st()
	var h := 0.16
	Meshes.box(st, Vector3(-0.46, 0, -0.46), Vector3(0.92, h, 0.1), SLEEPER)
	Meshes.box(st, Vector3(-0.46, 0, 0.36), Vector3(0.92, h, 0.1), SLEEPER)
	Meshes.box(st, Vector3(-0.46, 0, -0.36), Vector3(0.1, h, 0.72), SLEEPER.darkened(0.05))
	Meshes.box(st, Vector3(0.36, 0, -0.36), Vector3(0.1, h, 0.72), SLEEPER.darkened(0.05))
	Meshes.box(st, Vector3(-0.36, 0, -0.36), Vector3(0.72, h - 0.02, 0.72), SOIL, SOIL_TOP)
	for i in 3:  # raked furrows
		Meshes.box(st, Vector3(-0.33, h - 0.02, -0.25 + i * 0.22), Vector3(0.66, 0.025, 0.07), SOIL_TOP.lightened(0.06))
	return Meshes._finish(st)

## The plant in a bed at one stage. Seed: a row of dibbed holes and a label stick. Sprout: little shoots.
## Growing: a leafy young plant. Ready: in full fruit or flower, with a sparkle.
static func plant_node(material: String, stage: String) -> Node3D:
	var n := Node3D.new()
	n.position.y = 0.14
	if stage == "ready":
		n.scale = Vector3.ONE * 1.15  # in full fruit it spills over the sleepers a little
	n.add_child(_mi(_cached("plant:%s:%s" % [material, stage], func(): return _plant(material, stage)), stage == "ready" or stage == "growing"))
	if stage == "ready":
		var sp := MeshInstance3D.new()  # the same twinkle as a forage bush ready to pick
		sp.mesh = Forage._cached("sparkle", func(): return Forage._sparkle())
		sp.material_override = Forage._sparkle_material()
		sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sp.position.y = 0.75
		n.add_child(sp)
	return n

static func _plant(material: String, stage: String) -> ArrayMesh:
	var rng := Meshes._rng(hash(material + stage))
	var st := Meshes._st()
	var leaf: Color = LEAF.get(material, Color("4f7a3a"))
	var fruit: Array = FRUIT.get(material, [Color("c03040"), Color("e04050")])
	var spots := [Vector3(-0.2, 0, -0.18), Vector3(0.2, 0, -0.18), Vector3(-0.2, 0, 0.18), Vector3(0.2, 0, 0.18)]
	match stage:
		"seed":
			for p in spots:
				Meshes.cylinder(st, p + Vector3(0, -0.005, 0), 0.04, 0.012, 6, SOIL.darkened(0.3))
			Meshes.box(st, Vector3(0.28, 0, 0.26), Vector3(0.02, 0.2, 0.02), Color("c8b48a"))
			Meshes.box(st, Vector3(0.24, 0.13, 0.27), Vector3(0.1, 0.07, 0.01), Color("efe6cc"))
		"sprout":
			# seedlings: a stem and a pair of seed leaves, a little cluster in each spot
			var fresh := leaf.lightened(0.3)
			for p in spots:
				for k in 3:
					var q: Vector3 = p + Vector3(rng.randf_range(-0.07, 0.07), 0, rng.randf_range(-0.07, 0.07))
					var h := rng.randf_range(0.12, 0.19)
					Meshes.box(st, q + Vector3(-0.012, 0, -0.012), Vector3(0.024, h, 0.024), leaf.lightened(0.15))
					var a := rng.randf() * PI
					for side in [-1.0, 1.0]:
						var d: Vector3 = Vector3(cos(a), 0, sin(a)) * float(side)
						var top := q + Vector3(0, h, 0)
						Meshes._quad(st, top, top + d * 0.06 + Vector3(0, 0.035, 0), top + d * 0.11 + Vector3(0, 0.01, 0), top + d * 0.05 - Vector3(0, 0.02, 0), fresh)
						Meshes._quad(st, top, top + d * 0.05 - Vector3(0, 0.02, 0), top + d * 0.11 + Vector3(0, 0.01, 0), top + d * 0.06 + Vector3(0, 0.035, 0), fresh.darkened(0.12))
		"growing":
			for p in spots:
				Meshes.blob(st, p + Vector3(0, 0.12, 0), Vector3(0.13, 0.12, 0.13), leaf.lightened(0.06), rng, 0.3)
		"ready":
			_full(st, rng, material, leaf, fruit)
	return Meshes._finish(st)

static func _full(st: SurfaceTool, rng: RandomNumberGenerator, material: String, leaf: Color, fruit: Array) -> void:
	match material:
		"wild_garlic":  # broad leaves and starry white heads on stalks
			for i in 12:
				var p := Vector3(rng.randf_range(-0.3, 0.3), 0, rng.randf_range(-0.3, 0.3))
				var a := rng.randf() * TAU
				var d := Vector3(cos(a), 0, sin(a))
				var s := Vector3(-d.z, 0, d.x) * 0.06
				Meshes._quad(st, p - s, p + s, p + d * 0.22 + s * 0.6 + Vector3(0, 0.16, 0), p + d * 0.22 - s * 0.6 + Vector3(0, 0.16, 0), leaf.lightened(rng.randf_range(-0.04, 0.12)))
			for i in 6:
				var p := Vector3(rng.randf_range(-0.25, 0.25), 0, rng.randf_range(-0.25, 0.25))
				Meshes.box(st, p, Vector3(0.015, 0.26, 0.015), leaf.lightened(0.15))
				Forage._dots(st, rng, 4, p + Vector3(0, 0.28, 0), Vector3(0.04, 0.015, 0.04), 0.035, fruit)
		"elderflower":  # a little elder with flat creamy heads
			Meshes.cylinder(st, Vector3.ZERO, 0.04, 0.3, 6, Color("8a7a62"))
			Meshes.blob(st, Vector3(0, 0.45, 0), Vector3(0.34, 0.22, 0.32), leaf, rng, 0.25)
			for i in 6:
				var p := Vector3(rng.randf_range(-0.28, 0.28), rng.randf_range(0.52, 0.64), rng.randf_range(-0.26, 0.26))
				Meshes.box(st, p - Vector3(0.07, 0, 0.07), Vector3(0.14, 0.035, 0.14), fruit[0], fruit[1])
		"hazelnuts":  # a hazel whip, nuts in their frilly husks
			for i in 3:
				Meshes.cylinder(st, Vector3((i - 1) * 0.06, 0, 0), 0.025, 0.42, 5, Color("7a5a3e"))
			Meshes.blob(st, Vector3(0, 0.5, 0), Vector3(0.34, 0.24, 0.32), leaf, rng, 0.25)
			for i in 6:
				var p := Vector3(rng.randf_range(-0.28, 0.28), rng.randf_range(0.36, 0.62), rng.randf_range(-0.04, 0.3))
				Meshes.box(st, p - Vector3(0.045, 0.045, 0.045), Vector3(0.09, 0.09, 0.09), fruit[0], fruit[1])
				Meshes.box(st, p - Vector3(0.055, -0.03, 0.055), Vector3(0.11, 0.035, 0.11), Color("9ab84a"))
		_:  # berries: a bushy cane or sapling hung with fruit
			Meshes.cylinder(st, Vector3.ZERO, 0.035, 0.22, 5, Color("4a3828"))
			Meshes.blob(st, Vector3(0, 0.36, 0), Vector3(0.36, 0.26, 0.34), leaf, rng, 0.3)
			Meshes.blob(st, Vector3(0.1, 0.52, 0.04), Vector3(0.2, 0.15, 0.2), leaf.lightened(0.06), rng, 0.3)
			var clusters := 7 if material != "rowan_berry" else 5
			for i in clusters:
				var c := Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(0.3, 0.6), rng.randf_range(-0.05, 0.32))
				Forage._dots(st, rng, 4 if material in ["rowan_berry", "hawthorn_berry"] else 3, c, Vector3(0.04, 0.03, 0.04), 0.06, fruit)
