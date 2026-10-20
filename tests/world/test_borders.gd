extends TestCase
## The Carlisle and Scottish Borders cul-de-sacs: edges, scaling, regional creatures, quest flags.

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func test_edges_are_mirrored_cul_de_sacs() -> void:
	var kes := ZoneData.load_id("keswick")
	var car := ZoneData.load_id("carlisle")
	var edi := ZoneData.load_id("edinburgh")
	var bor := ZoneData.load_id("scottish_borders")
	assert_eq(str(kes.edges.north.to), "carlisle")
	assert_eq(str(car.edges.south.to), "keswick")
	assert_eq(car.edges.size(), 1, "Carlisle is a dead end")
	assert_eq(str(edi.edges.south.to), "scottish_borders")
	assert_eq(str(bor.edges.north.to), "edinburgh")
	assert_eq(bor.edges.size(), 1, "the Borders is a dead end")

func test_zones_are_scaled_to_their_anchor_band() -> void:
	assert_eq(ZoneData.load_id("carlisle").scaled_floor, 87)
	assert_eq(ZoneData.load_id("scottish_borders").scaled_floor, 69)
	for id in ["carl_reenactor", "carl_armstrong", "bord_rugby", "bord_douglas"]:
		assert_true(StoryData.trainer(id).has("scaled_floor"), id + " is scaled")

func test_regional_creatures_are_appendix_placed_and_have_art() -> void:
	var order: Array = _json("res://data/dex_order.json")
	var dex := Dex.load_default()
	for id in ["reivling", "reiver", "eildonmare"]:
		assert_true(dex.has(id), id + " loads")
		assert_true(bool(dex.get_species(id).get("appendix", false)), id + " is appendix")
		assert_true(id in order, id + " is in dex_order")
		for k in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [id, k]), id + " " + k)
	var z := ZoneData.load_id("scottish_borders")
	var found := false
	for e in z.encounters.grass:
		found = found or e.species == "eildonmare"
	assert_true(found, "Eildonmare roams the Borders")

func test_every_quest_flag_is_set_in_dialogue() -> void:
	var text := ""
	for f in JsonUtil.list_json("res://data/dialogue"):
		text += FileAccess.get_file_as_string(f)
	var q: Dictionary = _json("res://data/quests/borders.json")
	assert_true(q.quests.size() >= 3)
	for quest in q.quests:
		for flag in [quest.start_flag, quest.done_flag]:
			assert_true(text.contains('"flag": "%s"' % flag), "%s is set" % flag)
		for s in quest.steps:
			assert_true(text.contains('"flag": "%s"' % s.flag), "%s is set" % s.flag)
			assert_true(FileAccess.file_exists("res://data/zones/%s.json" % s.zone), "zone " + str(s.zone))

func test_plaques_are_unique_and_numerous() -> void:
	var ids := {}
	for zid in ["carlisle", "scottish_borders"]:
		var n := 0
		for s in ZoneData.load_id(zid).signs:
			if s.has("plaque"):
				n += 1
				assert_false(ids.has(s.plaque), "duplicate plaque " + str(s.plaque))
				ids[s.plaque] = true
		assert_true(n >= (8 if zid == "carlisle" else 3), zid + " has plaques")
