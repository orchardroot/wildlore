extends TestCase
## The place indicator: stand at a named building's door and its name and kind slide in at the bottom left.

func _zone() -> ZoneData:
	var rows := [
		"BBBBB.BBBB.BBB",
		"BBBBB.BBBB.BBB",
		"BBDBB.BBDB.BDB",
		"..............",
		"..............",
	]
	return ZoneData.from_dict({"id": "qa", "name": "QA", "kind": "town", "rows": rows, "edges": {}, "npcs": [],
		"encounters": {}, "signs": [], "spawn": [0, 4], "weather": {},
		"props": [
			{"type": "building", "style": "red_brick", "x": 0, "y": 0, "w": 5, "h": 3, "label": "Paradise Mill", "kind": "museum"},
			{"type": "building", "style": "cream_render", "x": 6, "y": 0, "w": 4, "h": 3, "label": "Home", "kind": "home"},
			{"type": "building", "style": "red_brick", "x": 11, "y": 0, "w": 3, "h": 3, "show_label": false},
		],
		"warps": [{"x": 2, "y": 2, "to": "macc_paradise", "tx": 1, "ty": 1}, {"x": 8, "y": 2, "to": "macc_home", "tx": 1, "ty": 1}]})

func test_in_front_of_a_named_door() -> void:
	var z := _zone()
	assert_eq(PlaceIndicator.place_near(z, Vector2i(2, 3)), {"name": "Paradise Mill", "kind": "Museum"})
	assert_eq(PlaceIndicator.place_near(z, Vector2i(1, 3)), {"name": "Paradise Mill", "kind": "Museum"}, "beside it")
	assert_eq(PlaceIndicator.place_near(z, Vector2i(3, 3)), {"name": "Paradise Mill", "kind": "Museum"}, "beside it")

func test_nothing_away_from_doors_or_at_homes() -> void:
	var z := _zone()
	assert_true(PlaceIndicator.place_near(z, Vector2i(2, 4)).is_empty(), "a step away")
	assert_true(PlaceIndicator.place_near(z, Vector2i(5, 3)).is_empty(), "off to the side")
	assert_true(PlaceIndicator.place_near(z, Vector2i(8, 3)).is_empty(), "home is not a place")
	assert_true(PlaceIndicator.place_near(z, Vector2i(12, 3)).is_empty(), "unnamed")

func test_text_joins_name_and_kind() -> void:
	assert_eq(PlaceIndicator.text_for({"name": "Paradise Mill", "kind": "Museum"}), "Paradise Mill  ·  Museum")
	assert_eq(PlaceIndicator.text_for({"name": "Silk Museum", "kind": ""}), "Silk Museum")
