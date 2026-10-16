extends TestCase
## Visual QA regressions: labels that read against the wrong building, flags flying into walls and the like.

func _zone(rows: Array, props: Array) -> ZoneData:
	return ZoneData.from_dict({"id": "qa", "name": "QA", "kind": "town", "rows": rows, "props": props, "warps": [], "edges": {},
		"npcs": [], "encounters": {}, "signs": [], "spawn": [0, 0], "weather": {}})

func _label(root: Node3D, building: String) -> Label3D:
	for c in root.get_node(building).get_children():
		if c is Label3D:
			return c
	return null

func test_aqueduct_names_itself_on_the_trough_not_at_door_height() -> void:
	# a low label under the deck reads as the name of whatever house stands in front of the viaduct
	Meshes.materials()
	var z := _zone(["BBBBBB", "BBBBBB", "......"], [{"type": "building", "style": "aqueduct", "x": 0, "y": 0, "w": 6, "h": 2, "label": "Viaduct"}])
	var root := ZoneBuilder.build(z)
	var lbl := _label(root, "Building_0_0")
	assert_true(lbl != null, "has a label")
	assert_true(lbl.position.y > 3.0, "label up on the trough, not at %.2f" % lbl.position.y)
	root.free()

func test_house_label_stays_over_the_door() -> void:
	Meshes.materials()
	var z := _zone(["BBBB", "BBDB", "...."], [{"type": "building", "style": "red_brick", "x": 0, "y": 0, "w": 4, "h": 2, "label": "Shop"}])
	var root := ZoneBuilder.build(z)
	assert_true(absf(_label(root, "Building_0_0").position.y - 1.35) < 0.001, "door-height label")
	root.free()

func test_peat_stack_is_brown_not_slate() -> void:
	# Chat Moss cuts peat; its stacks read as slate heaps when they come out blue-grey
	var peat: PackedColorArray = Landmarks.slate_heap(3).surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	var slate: PackedColorArray = Landmarks.slate_heap(0).surface_get_arrays(0)[Mesh.ARRAY_COLOR]
	assert_true(peat[0].r > peat[0].b, "peat is warm brown")
	assert_true(slate[0].b > slate[0].r, "slate stays blue-grey")

func test_building_on_a_slope_stands_at_its_door() -> void:
	# placed at its north-west corner's height, a building on rising ground had its door buried in the hill
	Meshes.materials()
	var d := {"id": "qa", "name": "QA", "kind": "town", "rows": ["BBB", "BDB", "..."], "heights": ["000", "222", "222"],
		"props": [{"type": "building", "style": "stone", "x": 0, "y": 0, "w": 3, "h": 2, "label": "Hall"}], "warps": [], "edges": {},
		"npcs": [], "encounters": {}, "signs": [], "spawn": [0, 2], "weather": {}}
	var root := ZoneBuilder.build(ZoneData.from_dict(d))
	assert_true(absf((root.get_node("Building_0_0") as Node3D).position.y - 2 * ZoneBuilder.LEVEL) < 0.001, "base at the door's height")
	root.free()

func _pool(rows: Array, lamp: Vector2i) -> Transform3D:
	var z := _zone(rows, [{"type": "lamp_post", "x": lamp.x, "y": lamp.y}])
	return ZoneBuilder.lamp_pool(z, lamp)

func test_lamp_pool_in_the_open_is_full_size() -> void:
	var t := _pool([".....", ".....", ".....", ".....", "....."], Vector2i(2, 2))
	assert_true(absf(t.basis.get_scale().x - 3.4) < 0.01, "full pool")
	assert_true(absf(t.origin.x - 2.5) < 0.01 and absf(t.origin.z - 2.5) < 0.01, "centred on the lamp")

func test_lamp_pool_by_water_keeps_to_the_bank() -> void:
	# a full pool hangs out over the water (or off a bridge) as a floating disc of light
	var t := _pool([".....", ".....", ".....", "~~~~~", "~~~~~"], Vector2i(2, 2))
	assert_true(t.basis.get_scale().x < 3.0, "smaller pool")
	assert_true(t.origin.z < 2.5, "pushed back from the water")
	assert_true(t.origin.z + t.basis.get_scale().x * 0.5 <= 3.01, "stops at the water's edge")

func test_lamp_pool_with_water_both_sides_shrinks_in_place() -> void:
	var t := _pool(["~~~~~", "~~~~~", "~~.~~", "~~~~~", "~~~~~"], Vector2i(2, 2))
	assert_true(t.basis.get_scale().x <= 1.3, "just the lamp's own tile")
	assert_true(absf(t.origin.x - 2.5) < 0.01 and absf(t.origin.z - 2.5) < 0.01, "centred")
