class_name RewildMeshes
extends RefCounted
## The low-poly props of the rewilding sites, built once and cached: the damage (peat hags, drain pipes, stumps,
## litter, tyres, a trolley), the work (canes, tree guards, sphagnum plugs, wool bales) and the recovery (cotton
## grass, ferns, young trees, willows, gorse, a beaver dam, water lilies). Each sits on its tile at the origin.

static var _cache := {}

static func get_mesh(name: String) -> ArrayMesh:
	if not _cache.has(name):
		_cache[name] = _build(name)
	return _cache[name]

const PEAT := Color("3a2a1e")
const PEAT_FACE := Color("2a1d14")
const RUST := Color("8a4a2a")
const GUARD := Color("9fbf8a")
const SPHAG_GREEN := Color("8aa53a")
const SPHAG_RED := Color("b0503a")
const COTTON := Color("f4f1e6")
const FERN := Color("5f8f3a")
const WILLOW := Color("8aa86a")
const GORSE := Color("3f5a2a")
const GORSE_FLOWER := Color("f2c53a")

static func _build(name: String) -> ArrayMesh:
	var rng := Meshes._rng(hash(name) & 0xFFFF)
	var st := Meshes._st()
	match name:
		"hag":
			# an eroded peat hag: a dark block with a grassy cap overhanging its crumbling face
			Meshes.box(st, Vector3(-0.38, 0, -0.3), Vector3(0.76, 0.36, 0.6), PEAT_FACE, PEAT)
			Meshes.blob(st, Vector3(0.02, 0.4, 0.0), Vector3(0.44, 0.08, 0.36), Color("6a6a3a"), rng, 0.25)
			Meshes.blob(st, Vector3(0.3, 0.06, 0.32), Vector3(0.18, 0.08, 0.12), PEAT, rng, 0.3)
		"pipe":
			# a plastic drain pipe poking out of a cut, half full of brown water
			for i in 6:
				var a0 := TAU * i / 6.0
				var a1 := TAU * (i + 1) / 6.0
				var r := 0.11
				var p0 := Vector3(-0.4, 0.1 + sin(a0) * r, cos(a0) * r)
				var p1 := Vector3(-0.4, 0.1 + sin(a1) * r, cos(a1) * r)
				Meshes._quad(st, p0, p1, p1 + Vector3(0.8, 0, 0), p0 + Vector3(0.8, 0, 0), Color("4f5a5f").lightened(0.06 * (i % 2)))
			Meshes.box(st, Vector3(0.38, 0.0, -0.12), Vector3(0.04, 0.22, 0.24), Color("2f3638"))
			Meshes.box(st, Vector3(-0.5, 0, -0.18), Vector3(0.12, 0.05, 0.36), PEAT_FACE)
		"litter":
			# a crisp packet, a can and a carrier bag
			Meshes.box(st, Vector3(-0.2, 0, -0.1), Vector3(0.16, 0.02, 0.12), Color("d8343a"), Color("e8e04a"))
			Meshes.cylinder(st, Vector3(0.12, 0, 0.1), 0.035, 0.11, 6, Color("c8ccd0"))
			Meshes.blob(st, Vector3(0.05, 0.04, -0.2), Vector3(0.1, 0.05, 0.08), Color("e8e8f0"), rng, 0.35)
		"litter_heap":
			Meshes.blob(st, Vector3(0, 0.12, 0), Vector3(0.3, 0.14, 0.26), Color("2a2a2e"), rng, 0.3)
			Meshes.box(st, Vector3(-0.28, 0.0, 0.1), Vector3(0.18, 0.03, 0.14), Color("d8343a"), Color("e8e04a"))
			Meshes.cylinder(st, Vector3(0.22, 0, -0.12), 0.04, 0.12, 6, Color("4a8ac8"))
			Meshes.cylinder(st, Vector3(0.18, 0, 0.2), 0.035, 0.1, 6, Color("c8ccd0"))
			Meshes.blob(st, Vector3(-0.1, 0.25, -0.05), Vector3(0.12, 0.08, 0.1), Color("eaeaf2"), rng, 0.35)
		"post":
			# a rusty Enclosure fence post with a sagging strand of wire and a tag
			Meshes.box(st, Vector3(-0.05, 0, -0.05), Vector3(0.1, 0.85, 0.1), Color("6a6058"))
			Meshes.box(st, Vector3(0.05, 0.55, -0.01), Vector3(0.45, 0.02, 0.02), RUST)
			Meshes.box(st, Vector3(0.05, 0.35, -0.01), Vector3(0.3, 0.02, 0.02), RUST.darkened(0.2))
			Meshes.box(st, Vector3(-0.08, 0.62, 0.05), Vector3(0.16, 0.12, 0.01), Color("c8b84a"))
		"plug":
			# sphagnum cushions, green and claret
			for i in 5:
				var p := Vector3(rng.randf_range(-0.32, 0.32), 0, rng.randf_range(-0.32, 0.32))
				Meshes.blob(st, p + Vector3(0, 0.03, 0), Vector3(0.11, 0.06, 0.11), SPHAG_RED if i % 3 == 0 else SPHAG_GREEN.lightened(rng.randf_range(-0.08, 0.1)), rng, 0.3)
		"bale":
			# a wool bale wedged in a gully as a dam
			Meshes.box(st, Vector3(-0.42, -0.02, -0.12), Vector3(0.84, 0.05, 0.24), PEAT_FACE)
			Meshes.blob(st, Vector3(0, 0.12, 0), Vector3(0.34, 0.14, 0.18), Color("e2dccb"), rng, 0.12)
			Meshes.blob(st, Vector3(-0.2, 0.1, 0.02), Vector3(0.18, 0.1, 0.14), Color("d6cfbc"), rng, 0.12)
		"cotton":
			# cotton grass: thin stems with white tufts nodding in the wind
			for i in 9:
				var p := Vector3(rng.randf_range(-0.38, 0.38), 0, rng.randf_range(-0.38, 0.38))
				var h := rng.randf_range(0.28, 0.45)
				Meshes.box(st, p + Vector3(-0.01, 0, -0.01), Vector3(0.02, h, 0.02), Color("6f7f3a"))
				Meshes.blob(st, p + Vector3(0, h + 0.03, 0), Vector3(0.05, 0.06, 0.05), COTTON, rng, 0.25)
		"pool_rim":
			# sedge and sphagnum round a bog pool, softening its square edge
			for i in 14:
				var a := TAU * i / 14.0 + rng.randf_range(-0.15, 0.15)
				var rr := 0.5 + rng.randf_range(0.0, 0.14) + (0.12 if i % 7 == 3 else 0.0)
				var p := Vector3(cos(a) * rr, 0, sin(a) * rr)
				if i % 3 == 0:
					Meshes.blob(st, p + Vector3(0, 0.03, 0), Vector3(0.12, 0.06, 0.12), SPHAG_RED if i % 2 == 0 else SPHAG_GREEN, rng, 0.3)
				else:
					for k in 4:
						var side := Vector3(rng.randf_range(-0.05, 0.05), 0, rng.randf_range(-0.05, 0.05))
						var tip := p + Vector3(rng.randf_range(-0.08, 0.08), rng.randf_range(0.22, 0.36), rng.randf_range(-0.08, 0.08))
						Meshes._tri(st, p - Vector3(0.03, 0, 0) + side, p + Vector3(0.03, 0, 0) + side, tip, Color("7a8a3a").lightened(rng.randf_range(-0.1, 0.1)))
		"stump":
			# a sawn conifer stump: pale cut face, dark bark, a root or two
			Meshes.cylinder(st, Vector3.ZERO, 0.2, 0.22, 7, Color("5a4030"))
			Meshes._quad(st, Vector3(-0.15, 0.225, -0.09), Vector3(0.15, 0.225, -0.09), Vector3(0.15, 0.225, 0.09), Vector3(-0.15, 0.225, 0.09), Color("c8a878"))
			Meshes.box(st, Vector3(0.12, 0, -0.04), Vector3(0.22, 0.06, 0.08), Color("4a3428"))
			Meshes.box(st, Vector3(-0.32, 0, 0.02), Vector3(0.18, 0.05, 0.07), Color("4a3428"))
		"brash":
			# heaped brash: cut branches gone rusty brown
			for i in 7:
				var a := rng.randf() * TAU
				var c := Vector3(rng.randf_range(-0.2, 0.2), 0.05 + i * 0.015, rng.randf_range(-0.2, 0.2))
				var d := Vector3(cos(a), 0.1, sin(a)) * 0.35
				Meshes._tri(st, c - d, c + d, c + Vector3(0, 0.12, 0), Color("7a5a3a").lightened(rng.randf_range(-0.1, 0.1)))
				Meshes._tri(st, c + d, c - d, c + Vector3(0, 0.12, 0), Color("6a4a30"))
			Meshes.blob(st, Vector3(0, 0.08, 0), Vector3(0.3, 0.08, 0.24), Color("7a5236"), rng, 0.35)
		"guard":
			# a pale green tree guard tube with a sapling's leaves bursting out of the top, and its stake
			Meshes.cylinder(st, Vector3.ZERO, 0.07, 0.55, 6, GUARD)
			Meshes.box(st, Vector3(0.07, 0, -0.015), Vector3(0.03, 0.62, 0.03), Color("8a6a46"))
			Meshes.blob(st, Vector3(0, 0.66, 0), Vector3(0.12, 0.1, 0.12), Color("6a9a3a"), rng, 0.3)
		"cane":
			# a bamboo cane with orange tape, and the sapling waiting at its foot
			Meshes.box(st, Vector3(-0.015, 0, -0.015), Vector3(0.03, 0.8, 0.03), Color("d8c08a"))
			Meshes._quad(st, Vector3(0.015, 0.72, 0), Vector3(0.2, 0.7, 0.02), Vector3(0.2, 0.64, 0.02), Vector3(0.015, 0.66, 0), Color("f07a2a"))
			Meshes.cylinder(st, Vector3(0.18, 0, 0.12), 0.08, 0.12, 6, Color("2a2a2a"))
			Meshes.blob(st, Vector3(0.18, 0.18, 0.12), Vector3(0.08, 0.08, 0.08), Color("6a9a3a"), rng, 0.3)
		"fern":
			# bracken and hart's-tongue: arching fronds
			for i in 7:
				var a := TAU * i / 7.0 + rng.randf_range(-0.2, 0.2)
				var d := Vector3(cos(a), 0, sin(a))
				var side := Vector3(-d.z, 0, d.x) * 0.07
				var tip := d * rng.randf_range(0.32, 0.42) + Vector3(0, 0.22, 0)
				var mid := d * 0.18 + Vector3(0, 0.3, 0)
				var col := FERN.lightened(rng.randf_range(-0.08, 0.1))
				Meshes._quad(st, Vector3.ZERO - side * 0.3, Vector3.ZERO + side * 0.3, mid + side, mid - side, col)
				Meshes._tri(st, mid - side, mid + side, tip, col.lightened(0.05))
				Meshes._quad(st, mid + side, Vector3.ZERO + side * 0.3, Vector3.ZERO - side * 0.3, mid - side, col.darkened(0.15))
		"mossy_rock":
			Meshes.blob(st, Vector3(0, 0.18, 0), Vector3(0.36, 0.26, 0.32), Color("7d7462"), rng, 0.25)
			Meshes.blob(st, Vector3(0, 0.36, 0), Vector3(0.3, 0.1, 0.26), Color("5f8a34"), rng, 0.3)
		"young_oak":
			Meshes.cylinder(st, Vector3.ZERO, 0.06, 0.6, 5, Meshes.TRUNK)
			Meshes.blob(st, Vector3(0, 0.85, 0), Vector3(0.36, 0.34, 0.36), Meshes.OAK_GREENS[1], rng)
			Meshes.blob(st, Vector3(0.14, 0.7, 0.1), Vector3(0.22, 0.2, 0.22), Meshes.OAK_GREENS[0], rng)
			Meshes.cylinder(st, Vector3(0.18, 0, -0.1), 0.06, 0.4, 6, GUARD)
		"young_pine":
			Meshes.cylinder(st, Vector3.ZERO, 0.05, 0.3, 5, Meshes.TRUNK.darkened(0.1))
			Meshes.cone(st, Vector3(0, 0.2, 0), 0.36, 0.55, 7, Meshes.PINE_GREEN.lightened(0.06), rng)
			Meshes.cone(st, Vector3(0, 0.55, 0), 0.24, 0.5, 7, Meshes.PINE_GREEN.lightened(0.12), rng)
		"juniper":
			Meshes.cone(st, Vector3(0, 0, 0), 0.3, 0.9, 6, Color("3a5a3a"), rng)
			Meshes.blob(st, Vector3(0.1, 0.25, 0.05), Vector3(0.22, 0.25, 0.22), Color("365638"), rng, 0.3)
		"blaeberry":
			for i in 4:
				var p := Vector3(rng.randf_range(-0.3, 0.3), 0, rng.randf_range(-0.3, 0.3))
				Meshes.blob(st, p + Vector3(0, 0.1, 0), Vector3(0.16, 0.11, 0.16), Color("5a7a34").lightened(rng.randf_range(-0.05, 0.1)), rng, 0.3)
			for i in 8:
				var p := Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(0.12, 0.2), rng.randf_range(-0.3, 0.3))
				Meshes.box(st, p, Vector3(0.04, 0.04, 0.04), Color("3a3a6a"))
		"heather":
			return Meshes.heather_tuft(1)
		"reed":
			return Meshes.reeds(2)
		"flowers":
			return Meshes.flower_patch(1)
		"sheep":
			return Landmarks.sheep(0)
		"tyre":
			for i in 8:
				var a0 := TAU * i / 8.0
				var a1 := TAU * (i + 1) / 8.0
				var o0 := Vector3(cos(a0), 0, sin(a0))
				var o1 := Vector3(cos(a1), 0, sin(a1))
				Meshes._quad(st, o0 * 0.3 + Vector3(0, 0.12, 0), o1 * 0.3 + Vector3(0, 0.12, 0), o1 * 0.15 + Vector3(0, 0.12, 0), o0 * 0.15 + Vector3(0, 0.12, 0), Color("2a2a2c"))
				Meshes._quad(st, o1 * 0.3, o0 * 0.3, o0 * 0.3 + Vector3(0, 0.12, 0), o1 * 0.3 + Vector3(0, 0.12, 0), Color("1f1f22"))
		"trolley":
			# a shopping trolley on its side, as is traditional
			var wire := Color("a8b0b8")
			Meshes.box(st, Vector3(-0.35, 0.0, -0.22), Vector3(0.7, 0.04, 0.44), wire)
			Meshes.box(st, Vector3(-0.35, 0.0, -0.22), Vector3(0.04, 0.4, 0.44), wire)
			Meshes.box(st, Vector3(-0.35, 0.36, -0.22), Vector3(0.7, 0.04, 0.04), wire)
			Meshes.box(st, Vector3(-0.35, 0.36, 0.18), Vector3(0.7, 0.04, 0.04), wire)
			Meshes.box(st, Vector3(0.31, 0.0, -0.22), Vector3(0.04, 0.4, 0.04), wire)
			Meshes.box(st, Vector3(0.31, 0.0, 0.18), Vector3(0.04, 0.4, 0.04), wire)
			Meshes.box(st, Vector3(0.2, 0.42, -0.25), Vector3(0.08, 0.06, 0.5), Color("c8343a"))
		"young_willow", "willow":
			var big := name == "willow"
			var h := 1.1 if big else 0.6
			Meshes.cylinder(st, Vector3.ZERO, 0.09 if big else 0.05, h, 5, Color("7a6a50"))
			Meshes.blob(st, Vector3(0, h + 0.25, 0), Vector3(0.55, 0.45, 0.55) * (1.0 if big else 0.6), WILLOW, rng)
			Meshes.blob(st, Vector3(0.2, h + 0.05, 0.1), Vector3(0.4, 0.4, 0.4) * (1.0 if big else 0.6), WILLOW.darkened(0.08), rng)
			if big:
				Meshes.blob(st, Vector3(-0.25, h + 0.1, -0.1), Vector3(0.38, 0.42, 0.38), WILLOW.lightened(0.05), rng)
		"meadowsweet":
			for i in 5:
				var p := Vector3(rng.randf_range(-0.3, 0.3), 0, rng.randf_range(-0.3, 0.3))
				var h := rng.randf_range(0.35, 0.55)
				Meshes.box(st, p + Vector3(-0.012, 0, -0.012), Vector3(0.024, h, 0.024), Color("4f7a3a"))
				Meshes.blob(st, p + Vector3(0, h + 0.03, 0), Vector3(0.09, 0.05, 0.09), Color("f2ecd0"), rng, 0.3)
		"dam":
			# a beaver dam: a low bank of gnawed sticks and mud across the water
			Meshes.blob(st, Vector3(0, 0.04, 0), Vector3(0.56, 0.2, 0.3), Color("4a3a2a"), rng, 0.25)
			for i in 12:
				var a := rng.randf_range(-0.5, 0.5)
				var c := Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0.08, 0.24), rng.randf_range(-0.18, 0.18))
				var d := Vector3(cos(a), rng.randf_range(-0.1, 0.1), sin(a)) * rng.randf_range(0.18, 0.3)
				var w := Vector3(0, 0.03, 0)
				Meshes._quad(st, c - d, c + d, c + d + w, c - d + w, Color("8a6a4a").lightened(rng.randf_range(-0.1, 0.12)))
				Meshes._quad(st, c + d, c - d, c - d + w, c + d + w, Color("7a5a3a"))
		"lily":
			for i in 4:
				var p := Vector3(rng.randf_range(-0.3, 0.3), 0.02, rng.randf_range(-0.3, 0.3))
				var r := rng.randf_range(0.08, 0.12)
				var ring := Meshes._ring(p, r, p.y, 7)
				for k in 6:
					Meshes._tri(st, p, ring[k + 1], ring[k], Color("3f6a34"))
				if i % 2 == 0:
					Meshes.blob(st, p + Vector3(0, 0.03, 0), Vector3(0.04, 0.03, 0.04), Color("f8f4f0"), rng, 0.2)
		"young_gorse", "gorse":
			var s := 1.0 if name == "gorse" else 0.55
			Meshes.blob(st, Vector3(0, 0.32 * s, 0), Vector3(0.44, 0.34, 0.42) * s, GORSE, rng, 0.3)
			Meshes.blob(st, Vector3(0.15, 0.5 * s, -0.05), Vector3(0.26, 0.2, 0.26) * s, GORSE.lightened(0.06), rng, 0.3)
			var flowers := 18 if name == "gorse" else 5
			for i in flowers:
				var a := rng.randf() * TAU
				var up := rng.randf_range(0.1, 0.9)
				var p := Vector3(cos(a) * 0.4 * s * sqrt(1.0 - up * up), (0.32 + up * 0.32) * s, sin(a) * 0.38 * s * sqrt(1.0 - up * up))
				Meshes.box(st, p - Vector3(0.03, 0.03, 0.03), Vector3(0.06, 0.06, 0.06), GORSE_FLOWER)
		_:
			push_warning("RewildMeshes: no mesh '%s'" % name)
			return Meshes.rock(0)
	return Meshes._finish(st)
