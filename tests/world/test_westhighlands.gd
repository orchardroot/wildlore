extends TestCase
## 3.0 region: the West Highlands (Loch Lomond, Oban, Tobermory, Staffa, Iona): edges, scaling, creatures, quests.

const ZONES := ["loch_lomond", "oban", "tobermory"]
const NEW := ["staffling", "fingalith", "lekling", "lekbruiser", "cailleach"]

var dex := Dex.load_default()

func _zone(id: String) -> Dictionary:
	var z = JsonUtil.read("res://data/zones/%s.json" % id)
	return z if z is Dictionary else {}

func test_chain_of_edges_and_scaling() -> void:
	assert_eq(str(_zone("glasgow").edges.west.to), "loch_lomond")
	assert_eq(str(_zone("loch_lomond").edges.east.to), "glasgow")
	assert_eq(str(_zone("loch_lomond").edges.west.to), "oban")
	assert_eq(str(_zone("oban").edges.east.to), "loch_lomond")
	for id in ZONES:
		assert_eq(int(_zone(id).scaled_floor), 69, id)
	assert_eq(str(_zone("oban").ferry.route), "oban_tobermory")
	assert_eq(str(_zone("tobermory").ferry.route), "oban_tobermory")

func test_new_species_are_appendix_with_sprites() -> void:
	for id in NEW:
		assert_true(dex.has(id), id)
		assert_true(Dex.in_appendix(id), id)
		for kind in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [id, kind]), "%s %s" % [id, kind])
	assert_eq(dex.core_ids().size(), 200)

func test_creatures_are_placed() -> void:
	var placed := {}
	for id in ZONES + ["staffa_cave"]:
		for kind in _zone(id).encounters:
			for e in _zone(id).encounters[kind]:
				placed[str(e.species)] = true
	for id in ["staffling", "fingalith", "lekling"]:
		assert_true(placed.has(id), id)
	# the Cailleach is a quest legend
	assert_true(FileAccess.get_file_as_string("res://data/dialogue/oban.json").contains('"species": "cailleach"'))

func test_quest_flags_are_set_somewhere() -> void:
	var q = JsonUtil.read("res://data/quests/westhighlands.json")
	var text := ""
	for f in DirAccess.get_files_at("res://data/dialogue"):
		text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
	for quest in q.quests:
		var flags := [quest.start_flag, quest.done_flag]
		for s in quest.steps:
			flags.append(s.flag)
		for f in flags:
			if str(f).begins_with("trainer_"):
				assert_true(FileAccess.file_exists("res://data/trainers/%s.json" % str(f).substr(8)), f)
			elif str(f) == "caught_cailleach":
				assert_true(text.contains('"flag": "caught_cailleach"'), f)
			else:
				assert_true(text.contains('"flag": "%s"' % f), "%s is set in dialogue" % f)

func test_trainers_are_scaled() -> void:
	var n := 0
	for f in DirAccess.get_files_at("res://data/trainers"):
		if f.begins_with("whl_") or f.begins_with("obn_") or f.begins_with("tob_"):
			var t = JsonUtil.read("res://data/trainers/" + f)
			assert_eq(int(t.scaled_floor), 69, f)
			n += 1
	assert_true(n >= 6, "six or more trainers")

func test_plaques_are_unique_and_plentiful() -> void:
	var seen := {}
	for id in ZONES:
		var n := 0
		for s in _zone(id).signs:
			if s.has("plaque"):
				assert_true(not seen.has(s.plaque), s.plaque)
				seen[s.plaque] = true
				n += 1
		assert_true(n >= (3 if id == "loch_lomond" else 8), "%s has enough plaques (%d)" % [id, n])
