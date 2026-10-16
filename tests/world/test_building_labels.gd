extends TestCase
## Building name labels: drawn through the building's own towers and walls, but depth-tested when another
## building stands between the label and the (north-facing, tilted) camera.

func _zone(props: Array) -> ZoneData:
	var rows := []
	for i in 30:
		rows.append("..............................")
	return ZoneData.from_dict({"id": "t", "name": "T", "kind": "town", "rows": rows, "props": props, "warps": [],
		"edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [2, 2], "weather": {}})

func _b(x: int, y: int, w: int, h: int, style := "red_brick", label := "") -> Dictionary:
	var d := {"type": "building", "x": x, "y": y, "w": w, "h": h, "style": style}
	if label != "":
		d["label"] = label
	return d

func test_lone_building_keeps_the_label_always_visible() -> void:
	var z := _zone([_b(5, 5, 6, 4, "castle", "Town Hall")])
	assert_false(ZoneBuilder.label_occluded(z, z.props[0]))

func test_tall_building_just_south_and_overlapping_x_occludes() -> void:
	var z := _zone([_b(5, 5, 6, 4, "red_brick", "Samson"), _b(6, 10, 6, 4, "red_brick")])
	assert_true(ZoneBuilder.label_occluded(z, z.props[0]))

func test_building_to_the_side_does_not_occlude() -> void:
	var z := _zone([_b(5, 5, 6, 4, "red_brick", "Samson"), _b(16, 10, 6, 4, "red_brick")])
	assert_false(ZoneBuilder.label_occluded(z, z.props[0]))

func test_building_to_the_north_does_not_occlude() -> void:
	var z := _zone([_b(5, 12, 6, 4, "red_brick", "Samson"), _b(5, 2, 6, 4, "red_brick")])
	assert_false(ZoneBuilder.label_occluded(z, z.props[0]))

func test_low_building_far_south_cannot_reach_the_label_line() -> void:
	# a one-storey house nine tiles south: the sight line to the camera is well above it
	var z := _zone([_b(5, 5, 6, 4, "red_brick", "Samson"), _b(6, 18, 3, 2, "red_brick")])
	assert_false(ZoneBuilder.label_occluded(z, z.props[0]))

func test_tall_styles_reach_further_than_houses() -> void:
	var near := _zone([_b(5, 5, 6, 4, "red_brick", "A"), _b(6, 14, 3, 2, "red_brick")])
	var tall := _zone([_b(5, 5, 6, 4, "red_brick", "A"), _b(6, 14, 3, 2, "glass_tower")])
	assert_false(ZoneBuilder.label_occluded(near, near.props[0]))
	assert_true(ZoneBuilder.label_occluded(tall, tall.props[0]))

func test_heights_by_style_and_size() -> void:
	assert_true(ZoneBuilder.building_height("cathedral", 6, 4) > ZoneBuilder.building_height("red_brick", 6, 4))
	assert_true(ZoneBuilder.building_height("red_brick", 6, 4) > ZoneBuilder.building_height("red_brick", 3, 2))

func test_label_node_follows_the_rule() -> void:
	Meshes.materials()
	var z := _zone([_b(5, 5, 6, 4, "red_brick", "Samson"), _b(6, 10, 6, 4, "red_brick"), _b(20, 5, 6, 4, "castle", "Hall")])
	var root := ZoneBuilder.build(z)
	var seen := {}
	for n in root.get_children():
		for c in n.get_children():
			if c is Label3D:
				seen[(c as Label3D).text] = (c as Label3D).no_depth_test
	assert_eq(seen.get("Samson"), false)
	assert_eq(seen.get("Hall"), true)
	root.free()
