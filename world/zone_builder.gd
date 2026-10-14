class_name ZoneBuilder
extends RefCounted
## Turns a ZoneData grid into a little 3D diorama: one merged ground mesh, MultiMeshes for repeated props,
## buildings, water. Tile (x, y) has its centre at world (x + 0.5, h * 0.5, y + 0.5); rows run south (+z).

const LEVEL := 0.5          # world units per height level
const SKIRT := 1.6          # how far the diorama's outer edge drops
const GROUND_COLOURS := {
	"grass": Color("527f37"), "tall_grass": Color("4f8035"), "path": Color("b9a57c"), "road": Color("55575d"),
	"cobbles": Color("9a8f80"), "sand": Color("cdb57f"), "flowers": Color("5c8f3c"), "shallow": Color("8fa39a"),
	"water": Color("6b7f6a"), "door": Color("c8b48a"), "building": Color("b9a98a"), "floor_wood": Color("7f5a3d"),
	"floor_tile": Color("bdb6a2"), "counter": Color("9a6b43"), "ledge_south": Color("5c8f3c"), "cliff": Color("8c8270"),
	"tree_oak": Color("4f8035"), "tree_pine": Color("4a7634"), "hedge": Color("557f37"), "drystone_wall": Color("5c8f3c"),
	"fence": Color("5c8f3c"), "rock": Color("5c8f3c"),
}
const SIDE_EARTH := Color("6a5238")
const SIDE_ROCK := Color("7d7462")

## Surface height of a tile's ground (water beds sit lower).
static func ground_y(z: ZoneData, p: Vector2i) -> float:
	var t := z.tile_at(p)
	var base := z.height_at(p) * LEVEL
	match t:
		"water":
			return base - 0.4
		"shallow":
			return base - 0.14
		"cliff":
			return base + LEVEL
	return base

static func build(z: ZoneData) -> Node3D:
	Meshes.materials()
	var root := Node3D.new()
	root.name = "Zone_" + z.id
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(z.id)
	root.add_child(_ground(z, rng))
	var water := _water(z)
	if water:
		root.add_child(water)
	_props(z, root, rng)
	_buildings(z, root)
	if z.kind == "interior":
		root.add_child(_interior_walls(z))
	return root

# --- ground --------------------------------------------------------------------

static func _ground(z: ZoneData, rng: RandomNumberGenerator) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for y in z.height:
		for x in z.width:
			var p := Vector2i(x, y)
			var t := z.tile_at(p)
			if t == "void":
				continue
			var gy := ground_y(z, p)
			var col: Color = GROUND_COLOURS.get(t, Color("ff00ff"))
			var ex: Dictionary = z.legend_extra.get(z.char_at(p), {})
			if ex.has("colour"):
				col = Color(str(ex.colour))
			col = _vary(t, col, x, y, rng)
			var x0 := float(x)
			var z0 := float(y)
			Meshes.quad4(st, Vector3(x0, gy, z0), Vector3(x0 + 1, gy, z0), Vector3(x0 + 1, gy, z0 + 1), Vector3(x0, gy, z0 + 1),
				_paint(col, x0, z0), _paint(col, x0 + 1, z0), _paint(col, x0 + 1, z0 + 1), _paint(col, x0, z0 + 1))
			# side faces wherever the neighbour is lower (or missing: the diorama skirt)
			for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
				var q: Vector2i = p + d
				var outside := not z.in_bounds(q) or z.tile_at(q) == "void"
				if outside and z.kind == "interior":
					continue  # rooms float in darkness, no diorama skirt
				var ny := -SKIRT if outside else ground_y(z, q)
				if ny >= gy - 0.001:
					continue
				var side := SIDE_ROCK if t == "cliff" or gy - ny > LEVEL * 1.5 else SIDE_EARTH
				var lip := col.darkened(0.15)
				_side(st, x0, z0, d, gy, ny, side, lip)
			if t == "ledge_south":
				Meshes.box(st, Vector3(x0, gy - 0.18, z0 + 0.82), Vector3(1.0, 0.18, 0.18), SIDE_EARTH, col.darkened(0.1))
	st.index()
	var mi := MeshInstance3D.new()
	mi.name = "Ground"
	mi.mesh = st.commit()
	mi.material_override = Meshes.solid
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mi

static func _side(st: SurfaceTool, x0: float, z0: float, d: Vector2i, top: float, bottom: float, col: Color, lip: Color) -> void:
	var a: Vector3
	var b: Vector3
	match d:
		Vector2i(0, 1):
			a = Vector3(x0, 0, z0 + 1)
			b = Vector3(x0 + 1, 0, z0 + 1)
		Vector2i(0, -1):
			a = Vector3(x0 + 1, 0, z0)
			b = Vector3(x0, 0, z0)
		Vector2i(1, 0):
			a = Vector3(x0 + 1, 0, z0 + 1)
			b = Vector3(x0 + 1, 0, z0)
		_:
			a = Vector3(x0, 0, z0)
			b = Vector3(x0, 0, z0 + 1)
	var mid := maxf(bottom, top - 0.12)
	Meshes._quad(st, Vector3(a.x, top, a.z), Vector3(b.x, top, b.z), Vector3(b.x, mid, b.z), Vector3(a.x, mid, a.z), lip)
	Meshes._quad(st, Vector3(a.x, mid, a.z), Vector3(b.x, mid, b.z), Vector3(b.x, bottom, b.z), Vector3(a.x, bottom, a.z), col)

static var _noise: FastNoiseLite

## Low-frequency colour drift across the ground so it reads as painted, not tiled.
static func _paint(col: Color, x: float, z: float) -> Color:
	if _noise == null:
		_noise = FastNoiseLite.new()
		_noise.frequency = 0.09
		_noise.seed = 7
	var n := _noise.get_noise_2d(x, z)
	var warm := Color(col.r * 1.06, col.g * 1.02, col.b * 0.9)
	var cool := Color(col.r * 0.9, col.g * 0.97, col.b * 1.08)
	return col.lerp(warm if n > 0.0 else cool, absf(n) * 0.9).lightened(n * 0.06)

static func _vary(t: String, col: Color, x: int, y: int, rng: RandomNumberGenerator) -> Color:
	match t:
		"cobbles":
			col = col.darkened(rng.randf_range(0.0, 0.07))
		"floor_tile":
			col = col.darkened(0.08) if (x + y) % 2 == 0 else col
		"floor_wood":
			col = col.darkened(0.07) if x % 2 == 0 else col.lightened(0.03)
		"road":
			pass
	return col.lightened(rng.randf_range(-0.02, 0.02))

# --- water ---------------------------------------------------------------------

static func _water(z: ZoneData) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var any := false
	for y in z.height:
		for x in z.width:
			var p := Vector2i(x, y)
			var t := z.tile_at(p)
			if t != "water" and t != "shallow":
				continue
			any = true
			var wy := z.height_at(p) * LEVEL - (0.1 if t == "water" else 0.05)
			Meshes._quad(st, Vector3(x, wy, y), Vector3(x + 1, wy, y), Vector3(x + 1, wy, y + 1), Vector3(x, wy, y + 1), Color.WHITE)
	if not any:
		return null
	st.index()
	var mi := MeshInstance3D.new()
	mi.name = "Water"
	mi.mesh = st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = load("res://art/shaders/water.gdshader")
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

# --- props ---------------------------------------------------------------------

## Tile name -> [mesh constructor name, variants, foliage?]
const TILE_PROPS := {
	"tree_oak": ["oak", 3, true], "tree_pine": ["pine", 3, true], "hedge": ["hedge_segment", 2, true],
	"drystone_wall": ["wall_segment", 3, false], "fence": ["fence_segment", 1, false], "rock": ["rock", 3, false],
	"flowers": ["flower_patch", 3, true], "tall_grass": ["tall_grass_tuft", 3, true], "counter": ["counter", 1, false],
}
const LINEAR := ["hedge", "drystone_wall", "fence"]

static func _props(z: ZoneData, root: Node3D, rng: RandomNumberGenerator) -> void:
	var buckets := {}  # "ctor:variant" -> Array[Transform3D]
	for y in z.height:
		for x in z.width:
			var p := Vector2i(x, y)
			var t := z.tile_at(p)
			var extra: Dictionary = z.legend_extra.get(z.char_at(p), {})
			var prop_name: String = extra.get("prop", "")
			var spec: Array = []
			if prop_name in ["heather", "reeds", "none"]:
				if prop_name == "none":
					continue
				spec = [prop_name + ("_tuft" if prop_name == "heather" else ""), 3, true]
			else:
				if prop_name != "":
					t = {"oak": "tree_oak", "pine": "tree_pine", "birch": "tree_oak", "bush": "rock", "rock": "rock"}.get(prop_name, t)
				if not TILE_PROPS.has(t):
					continue
				spec = TILE_PROPS[t]
			var variant := rng.randi() % int(spec[1])
			var basis := Basis()
			if t in LINEAR:
				var ns := z.tile_at(p + Vector2i(0, -1)) == t or z.tile_at(p + Vector2i(0, 1)) == t
				var ew := z.tile_at(p + Vector2i(-1, 0)) == t or z.tile_at(p + Vector2i(1, 0)) == t
				if ns and not ew:
					basis = Basis(Vector3.UP, PI / 2)
			elif t != "counter":
				basis = Basis(Vector3.UP, rng.randf() * TAU)
				var s := rng.randf_range(0.9, 1.15) if t.begins_with("tree") else 1.0
				basis = basis.scaled(Vector3(s, s, s))
			var origin := Vector3(x + 0.5, ground_y(z, p), y + 0.5)
			if t.begins_with("tree"):
				origin += Vector3(rng.randf_range(-0.12, 0.12), 0, rng.randf_range(-0.12, 0.12))
			var key := "%s:%d" % [spec[0], variant]
			if not buckets.has(key):
				buckets[key] = []
			buckets[key].append(Transform3D(basis, origin))
	for s in z.signs:
		_add(buckets, "sign_post:0", Transform3D(Basis(), Vector3(int(s.x) + 0.5, ground_y(z, Vector2i(int(s.x), int(s.y))), int(s.y) + 0.5)))
	for pr in z.props:
		var pt: String = pr.get("type", "")
		if pt in ["lamp_post", "bench", "bush", "birch", "oak", "pine", "rock", "market_stall", "planter", "phone_box", "post_box", "bookshelf", "potted_plant", "table", "bed"]:
			var pos := Vector2i(int(pr.x), int(pr.y))
			var tr := Transform3D(Basis(Vector3.UP, deg_to_rad(float(pr.get("rot", 0)))), Vector3(pos.x + 0.5, ground_y(z, pos), pos.y + 0.5))
			_add(buckets, "%s:%d" % [pt, int(pr.get("variant", 0))], tr)
			if pt == "lamp_post":
				_add(buckets, "lamp_bulb:0", tr)
	for key in buckets:
		var parts: PackedStringArray = key.split(":")
		var mesh: ArrayMesh = _ctor(parts[0], int(parts[1]))
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh
		var list: Array = buckets[key]
		mm.instance_count = list.size()
		for i in list.size():
			mm.set_instance_transform(i, list[i])
		var mmi := MultiMeshInstance3D.new()
		mmi.name = "Props_" + key.replace(":", "_")
		mmi.multimesh = mm
		var foliage := parts[0] in ["heather_tuft", "reeds"]
		for tname in TILE_PROPS:
			if TILE_PROPS[tname][0] == parts[0]:
				foliage = TILE_PROPS[tname][2]
		if parts[0] == "lamp_bulb":
			mmi.material_override = Meshes.glow
			mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			mmi.material_override = Meshes.foliage if foliage else Meshes.solid
			mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if parts[0] in ["tall_grass_tuft", "flower_patch"] else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		root.add_child(mmi)

static func _add(buckets: Dictionary, key: String, tr: Transform3D) -> void:
	if not buckets.has(key):
		buckets[key] = []
	buckets[key].append(tr)

static func _ctor(name: String, variant: int) -> ArrayMesh:
	match name:
		"oak":
			return Meshes.oak(variant)
		"pine":
			return Meshes.pine(variant)
		"birch":
			return Meshes.birch(variant)
		"bush":
			return Meshes.bush(variant)
		"rock":
			return Meshes.rock(variant)
		"hedge_segment":
			return Meshes.hedge_segment(variant)
		"wall_segment":
			return Meshes.wall_segment(variant)
		"fence_segment":
			return Meshes.fence_segment()
		"flower_patch":
			return Meshes.flower_patch(variant)
		"tall_grass_tuft":
			return Meshes.tall_grass_tuft(variant)
		"heather_tuft":
			return Meshes.heather_tuft(variant)
		"reeds":
			return Meshes.reeds(variant)
		"lamp_post":
			return Meshes.lamp_post()
		"lamp_bulb":
			return Meshes.lamp_bulb()
		"bench":
			return Meshes.bench()
		"sign_post":
			return Meshes.sign_post()
		"market_stall":
			return Meshes.market_stall(variant)
		"bookshelf":
			return Meshes.bookshelf(variant)
		"potted_plant":
			return Meshes.potted_plant(variant)
		"table":
			return Meshes.table(variant)
		"bed":
			return Meshes.bed(variant)
		"planter":
			return Meshes.planter(variant)
		"phone_box":
			return Meshes.phone_box()
		"post_box":
			return Meshes.post_box()
		"counter":
			return Meshes.counter()
	push_warning("ZoneBuilder: unknown prop mesh '%s'" % name)
	return Meshes.rock(0)

# --- buildings -----------------------------------------------------------------

static func _buildings(z: ZoneData, root: Node3D) -> void:
	for pr in z.props:
		if pr.get("type") != "building":
			continue
		var bx := int(pr.x)
		var by := int(pr.y)
		var w := int(pr.w)
		var d := int(pr.h)
		var door_x := -1
		for x in range(bx, bx + w):
			if z.tile_at(Vector2i(x, by + d - 1)) == "door":
				door_x = x - bx
		var meshes: Array = Meshes.building(w, d, str(pr.get("style", "red_brick")), door_x, hash(z.id) + bx * 31 + by)
		var gy := z.height_at(Vector2i(bx, by)) * LEVEL
		var body := MeshInstance3D.new()
		body.name = "Building_%d_%d" % [bx, by]
		body.mesh = meshes[0]
		body.material_override = Meshes.solid
		body.position = Vector3(bx, gy, by)
		root.add_child(body)
		var win := MeshInstance3D.new()
		win.mesh = meshes[1]
		win.material_override = Meshes.glow
		win.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		body.add_child(win)
		if pr.has("label") and pr.get("show_label", true):
			var lbl := Label3D.new()
			lbl.text = str(pr.label)
			lbl.pixel_size = 0.006
			lbl.font_size = 48
			lbl.outline_size = 12
			lbl.modulate = Color("f2e8cf")
			lbl.outline_modulate = Color("1d2230")
			lbl.position = Vector3(w * 0.5, 1.35 if door_x >= 0 else 1.0, d + 0.02)
			lbl.billboard = BaseMaterial3D.BILLBOARD_DISABLED
			lbl.no_depth_test = false
			body.add_child(lbl)

# --- interiors -----------------------------------------------------------------

static func _interior_walls(z: ZoneData) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var plaster := Color("cfc3a8")
	var skirting := Color("6b4a32")
	for y in z.height:
		for x in z.width:
			var p := Vector2i(x, y)
			if z.tile_at(p) != "void":
				continue
			var south := z.tile_at(p + Vector2i(0, 1))
			var north := z.tile_at(p + Vector2i(0, -1))
			var east := z.tile_at(p + Vector2i(1, 0))
			var west := z.tile_at(p + Vector2i(-1, 0))
			var floor_s := south != "" and south != "void"
			var floor_n := north != "" and north != "void"
			var floor_e := east != "" and east != "void"
			var floor_w := west != "" and west != "void"
			if floor_s:
				Meshes.box(st, Vector3(x, 0, y + 0.6), Vector3(1, 2.4, 0.4), plaster, plaster.darkened(0.3))
				Meshes.box(st, Vector3(x, 0, y + 0.95), Vector3(1, 0.2, 0.06), skirting)
			elif floor_e or floor_w:
				var ox := x + (0.7 if floor_e else 0.0)
				Meshes.box(st, Vector3(ox, 0, y), Vector3(0.3, 1.2, 1), plaster.darkened(0.08), plaster.darkened(0.3))
			elif floor_n:
				Meshes.box(st, Vector3(x, 0, y), Vector3(1, 0.25, 0.3), plaster.darkened(0.1), skirting)
	st.index()
	var mi := MeshInstance3D.new()
	mi.name = "Walls"
	mi.mesh = st.commit()
	mi.material_override = Meshes.solid
	return mi
