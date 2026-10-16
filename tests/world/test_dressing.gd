extends TestCase
## Regional dressing, lamp pools and interior furnishing props.

const NEW_PROPS := ["bunting", "flagpole", "washing_line", "hanging_basket", "rug", "fireplace", "wall_picture", "clock",
	"kitchen_dresser", "fryer", "menu_board", "piano", "telescope", "plant_stand", "sofa", "display_case"]

func _zone(props: Array, kind := "town") -> ZoneData:
	var rows := ["xxxxxxxx", "x||||||x", "x||||||x", "x||||||x", "x||||||x", "xxxxxxxx"] if kind == "interior" else ["........", "........", "........", "........", "........"]
	return ZoneData.from_dict({"id": "t", "name": "T", "kind": kind, "rows": rows, "props": props, "warps": [], "edges": {},
		"npcs": [], "encounters": {}, "signs": [], "spawn": [2, 2], "weather": {}})

func test_every_new_prop_builds_a_mesh() -> void:
	for name in NEW_PROPS:
		assert_true(name in ZoneBuilder.POINT_PROPS, name + " is registered")
		var mesh: ArrayMesh = ZoneBuilder._ctor(name, 2)
		assert_true(mesh.get_surface_count() > 0, name + " has geometry")

func test_flags_all_build() -> void:
	for v in Dressing.FLAGS.size():
		assert_true(Dressing.flag(v).get_surface_count() > 0, "flag %d" % v)

func test_lamp_gets_a_pool_and_cloth_flutters() -> void:
	Meshes.materials()
	var z := _zone([{"type": "lamp_post", "x": 1, "y": 1}, {"type": "bunting", "x": 1, "y": 1, "variant": 3, "walk": true},
		{"type": "flagpole", "x": 4, "y": 2, "variant": 1}])
	var root := ZoneBuilder.build(z)
	assert_true(root.has_node("Props_lamp_pool_0"), "pool")
	assert_eq((root.get_node("Props_lamp_pool_0") as GeometryInstance3D).material_override, Meshes.pool)
	assert_eq((root.get_node("Props_bunting_3") as GeometryInstance3D).material_override, Meshes.flutter)
	assert_eq((root.get_node("Props_flag_1") as GeometryInstance3D).material_override, Meshes.flutter)
	root.free()

func test_fireplace_has_flickering_glow() -> void:
	Meshes.materials()
	var root := ZoneBuilder.build(_zone([{"type": "fireplace", "x": 2, "y": 1}], "interior"))
	assert_eq((root.get_node("Props_fireplace_fire_0") as GeometryInstance3D).material_override, Meshes.firelight)
	root.free()

func test_decor_that_hangs_does_not_block() -> void:
	var z := _zone([{"type": "bunting", "x": 1, "y": 1, "variant": 3, "walk": true}, {"type": "rug", "x": 1, "y": 2, "w": 2, "h": 2, "walk": true}])
	assert_true(z.walkable(Vector2i(1, 1)))
	assert_true(z.walkable(Vector2i(1, 2)))
