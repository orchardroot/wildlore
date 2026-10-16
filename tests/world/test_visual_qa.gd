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

func test_label_behind_a_building_moves_up_on_to_its_own_roof() -> void:
	# a name at door height, with another building a street in front, is drawn over that building's wall and
	# reads as its name: lift it on to the ridge of its own roof
	Meshes.materials()
	var rows := ["BBBBB", "BBDBB", ".....", "BBBBB", "BBBBB", "BBDBB", "....."]
	var props := [{"type": "building", "style": "stone", "x": 0, "y": 0, "w": 5, "h": 2, "label": "Back"},
		{"type": "building", "style": "terrace", "x": 0, "y": 3, "w": 5, "h": 3, "label": "Front"}]
	var root := ZoneBuilder.build(_zone(rows, props))
	var back := _label(root, "Building_0_0")
	var front := _label(root, "Building_0_3")
	var top := (root.get_node("Building_0_0") as MeshInstance3D).mesh.get_aabb().end.y
	assert_true(back.position.y > top, "back label above its roof (%.2f > %.2f)" % [back.position.y, top])
	assert_true(absf(front.position.y - 1.35) < 0.001, "front label stays over its door")
	root.free()

func test_short_grass_shows_low_tufts() -> void:
	# tall grass drawn bare ("none") left roaming creatures standing on what looks like a lawn; "short" draws
	# low tufts so you can see where they hide
	Meshes.materials()
	var d := {"id": "qa", "name": "QA", "kind": "route", "rows": ["kk", "kk"], "legend_extra": {"k": {"tile": "tall_grass", "prop": "short"}},
		"props": [], "warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [0, 0], "weather": {}}
	var root := ZoneBuilder.build(ZoneData.from_dict(d))
	var tufts := 0
	for c in root.get_children():
		if c is MultiMeshInstance3D and str(c.name).begins_with("Props_tall_grass_tuft"):
			tufts += (c as MultiMeshInstance3D).multimesh.instance_count
	assert_eq(tufts, 4)
	assert_true(ZoneBuilder.tuft_height("short") < 0.7, "low")
	assert_eq(ZoneBuilder.tuft_height(""), 1.0)
	root.free()

func test_london_landmarks_have_their_own_shapes() -> void:
	# Big Ben and the Shard were stood in by red and white lighthouses in the middle of the lawns
	for name in ["clock_tower", "shard"]:
		assert_true(name in ZoneBuilder.POINT_PROPS, name + " is a point prop")
		var mesh: ArrayMesh = ZoneBuilder._ctor(name, 0)
		assert_true(mesh.get_surface_count() > 0, name + " has geometry")
		assert_true(mesh.get_aabb().size.y > 3.5, name + " is tall")

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
