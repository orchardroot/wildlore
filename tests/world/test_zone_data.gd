extends TestCase

func _z(id: String) -> ZoneData:
	return ZoneData.load_id(id)

func _all() -> Dictionary:
	return {"testbed": _z("testbed"), "testbed_house": _z("testbed_house")}

func _base(rows: Array, extra := {}) -> Dictionary:
	var d := {"id": "t", "name": "T", "kind": "route", "rows": rows, "props": [], "warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [1, 1], "weather": {}}
	d.merge(extra, true)
	return d

func _has(errors: Array, needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false

func test_parse_testbed() -> void:
	var z := _z("testbed")
	assert_eq(z.width, 24)
	assert_eq(z.height, 18)
	assert_eq(z.tile_at(Vector2i(0, 0)), "tree_oak")
	assert_eq(z.tile_at(Vector2i(5, 1)), "tall_grass")
	assert_eq(z.tile_at(Vector2i(14, 4)), "door")
	assert_eq(z.tile_at(Vector2i(-1, 0)), "")
	assert_eq(z.spawn, Vector2i(4, 6))
	assert_eq(z.height_at(Vector2i(14, 13)), 2)

func test_walkable_classes() -> void:
	var z := _z("testbed")
	assert_true(z.walkable(Vector2i(2, 1)), "grass")
	assert_true(z.walkable(Vector2i(5, 1)), "tall grass")
	assert_true(z.walkable(Vector2i(14, 10)), "shallow")
	assert_true(z.walkable(Vector2i(14, 4)), "door")
	assert_false(z.walkable(Vector2i(14, 8)), "water")
	assert_false(z.walkable(Vector2i(0, 0)), "tree")
	assert_false(z.walkable(Vector2i(4, 7)), "hedge")
	assert_false(z.walkable(Vector2i(12, 2)), "building")
	assert_false(z.walkable(Vector2i(30, 2)), "out of bounds")

func test_ledge_is_one_way_south() -> void:
	var z := _z("testbed")
	assert_true(z.walkable(Vector2i(5, 12), Vector2i(0, 1)))
	assert_false(z.walkable(Vector2i(5, 12), Vector2i(0, -1)))
	assert_false(z.walkable(Vector2i(5, 12), Vector2i(1, 0)))

func test_height_step_rule() -> void:
	var z := _z("testbed")
	# row 13 is height 2, row 14 col 12 is height 0 next to col 13 height 2
	assert_false(z.walkable(Vector2i(13, 14), Vector2i(1, 0)), "climbing two levels")
	assert_true(z.walkable(Vector2i(14, 14), Vector2i(1, 0)), "same level")

func test_warp_and_sign_lookup() -> void:
	var z := _z("testbed")
	assert_eq(z.warp_at(Vector2i(14, 4)).to, "testbed_house")
	assert_eq(z.warp_at(Vector2i(1, 1)), {})
	assert_true(z.sign_at(Vector2i(9, 6)).text.begins_with("TESTBED"))

func test_real_zones_validate() -> void:
	var all := _all()
	for id in all:
		assert_eq(all[id].validate(all), [], id)

func test_validate_ragged_rows() -> void:
	var z := ZoneData.from_dict(_base(["...", ".."]))
	assert_true(_has(z.validate({"t": z}), "ragged"))

func test_validate_unknown_char() -> void:
	var z := ZoneData.from_dict(_base(["...", ".?.", "..."]))
	assert_true(_has(z.validate({"t": z}), "unknown tile char '?'"))

func test_validate_missing_warp_target() -> void:
	var z := ZoneData.from_dict(_base(["...", "...", "..."], {"warps": [{"x": 1, "y": 1, "to": "nowhere", "tx": 0, "ty": 0}]}))
	assert_true(_has(z.validate({"t": z}), "unknown zone 'nowhere'"))

func test_validate_unwalkable_arrival() -> void:
	var a := ZoneData.from_dict(_base(["...", "...", "..."], {"id": "a", "warps": [{"x": 1, "y": 1, "to": "b", "tx": 0, "ty": 0}]}))
	var b := ZoneData.from_dict(_base(["T..", "...", "..."], {"id": "b"}))
	assert_true(_has(a.validate({"a": a, "b": b}), "not walkable"))

func test_validate_unwalkable_spawn() -> void:
	var z := ZoneData.from_dict(_base(["TTT", "TTT", "TTT"]))
	assert_true(_has(z.validate({"t": z}), "spawn"))

func test_validate_building_footprint() -> void:
	var z := ZoneData.from_dict(_base(["BB..", "BB..", "...."], {"spawn": [3, 2]}))
	assert_true(_has(z.validate({"t": z}), "not covered by a building"))

func test_validate_edge_needs_a_way_back() -> void:
	var a := ZoneData.from_dict(_base(["...", "...", "..."], {"id": "a", "edges": {"north": {"to": "b", "offset": 0}}}))
	var b := ZoneData.from_dict(_base(["...", "...", "..."], {"id": "b"}))
	assert_true(_has(a.validate({"a": a, "b": b}), "no south edge back"))
