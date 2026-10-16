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
