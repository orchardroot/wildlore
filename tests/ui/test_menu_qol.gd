extends TestCase
## Menu quality-of-life helpers: Fieldbook paging and filters, habitat conditions, evolution lines,
## the pause card's "Now" line, the Ark shortcut, and the "Where next?" objectives.

const OBJ_PATH := "res://data/objectives.json"

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	for k in flags:
		d.set_flag(k, flags[k])
	return d

func test_page_jump_clamps_at_the_ends() -> void:
	assert_eq(MenuLogic.page_index(5, 10, 200), 15)
	assert_eq(MenuLogic.page_index(195, 10, 200), 199, "stops at the last entry")
	assert_eq(MenuLogic.page_index(199, 10, 200), 0, "from the very end, wraps to the start")
	assert_eq(MenuLogic.page_index(4, -10, 200), 0, "stops at the first entry")
	assert_eq(MenuLogic.page_index(0, -10, 200), 199, "from the very start, wraps to the end")
	assert_eq(MenuLogic.page_index(0, 10, 0), 0, "empty list")

func test_fieldbook_filter() -> void:
	var ids := ["a", "b", "c", "d"]
	var seen := {"a": true, "b": true, "c": true}
	var caught := {"a": true}
	assert_eq(MenuLogic.fieldbook_filter(ids, seen, caught, "all"), ids)
	assert_eq(MenuLogic.fieldbook_filter(ids, seen, caught, "caught"), ["a"])
	assert_eq(MenuLogic.fieldbook_filter(ids, seen, caught, "seen"), ["a", "b", "c"], "seen includes caught")
	assert_eq(MenuLogic.next_filter("all"), "caught")
	assert_eq(MenuLogic.next_filter("caught"), "seen")
	assert_eq(MenuLogic.next_filter("seen"), "rumours")
	assert_eq(MenuLogic.next_filter("rumours"), "all")

func test_habitat_labels_show_time_and_weather() -> void:
	var zones := [
		{"id": "moor", "name": "Bowland Moor", "encounters": {"grass": [
			{"species": "owl", "time": ["night"]},
			{"species": "frog", "weather": ["downpour", "drizzle"]},
			{"species": "fox", "time": ["night", "dusk"], "weather": ["fog"]},
			{"species": "hare"},
			{"species": "both", "time": ["day"]}], "water": [{"species": "both"}]}},
		{"id": "wood", "name": "Wood", "encounters": {"grass": [{"species": "owl", "time": ["dawn"]}, {"species": "owl", "weather": ["fog"]}]}},
	]
	var idx := MenuLogic.habitat_labels(zones)
	assert_eq(MenuLogic.habitats(idx, "owl"), ["Bowland Moor (night)", "Wood (dawn or fog)"])
	assert_eq(MenuLogic.habitats(idx, "frog"), ["Bowland Moor (drizzle/downpour)"], "weathers in the usual order")
	assert_eq(MenuLogic.habitats(idx, "fox"), ["Bowland Moor (dusk/night, fog)"])
	assert_eq(MenuLogic.habitats(idx, "hare"), ["Bowland Moor"], "no conditions, no brackets")
	assert_eq(MenuLogic.habitats(idx, "both"), ["Bowland Moor"], "any unconditional entry wins")

func test_evolution_text() -> void:
	assert_eq(MenuLogic.evolution_text(null, ""), "")
	assert_eq(MenuLogic.evolution_text({"to": "bramblehog", "level": 16}, "Bramblehog"), "Evolves into Bramblehog at Lv 16")
	assert_eq(MenuLogic.evolution_text({"to": "bramblehog", "level": 16}, ""), "Evolves at Lv 16", "unseen target stays hidden")
	assert_eq(MenuLogic.evolution_text({"to": "sootwing", "level": 20, "time": "night"}, "Sootwing"), "Evolves into Sootwing at Lv 20, at night")
	assert_eq(MenuLogic.evolution_text({"to": "bufomire", "level": 22, "weather": "downpour"}, ""), "Evolves at Lv 22, in a downpour")
	assert_eq(MenuLogic.evolution_text({"to": "jetwhitby", "item": "whitby_jet"}, "Jetwhitby", "Whitby Jet"), "Evolves into Jetwhitby with a Whitby Jet")
	assert_eq(MenuLogic.evolution_text({"to": "x", "item": "oak_apple"}, "", "Oak Apple"), "Evolves with an Oak Apple")

func test_evolution_text_w45_conditions() -> void:
	assert_eq(MenuLogic.evolution_text({"to": "x", "level": 30, "season": "autumn", "time": "night"}, ""), "Evolves at Lv 30, at night and in autumn")
	assert_eq(MenuLogic.evolution_text({"to": "x", "level": 34, "zone": ["bath", "cayman"]}, "", "", {"bath": "Bath"}), "Evolves at Lv 34, in Bath or Cayman")
	assert_eq(MenuLogic.evolution_text({"to": "x", "level": 34, "flag": "lang_cert_cy_1", "flag_text": "once you have passed a Welsh lesson"}, ""), "Evolves at Lv 34, once you have passed a Welsh lesson")

func test_now_text() -> void:
	assert_eq(MenuLogic.now_text(19 * 60, "drizzle"), "Dusk, drizzle")
	assert_eq(MenuLogic.now_text(12 * 60, "clear"), "Day, clear skies")
	assert_eq(MenuLogic.now_text(2 * 60, "fog", true), "Night, indoors")
	assert_eq(MenuLogic.now_text(6 * 60, ""), "Dawn", "weather unknown: time only")

func test_ark_shortcut_after_a_sanctuary() -> void:
	assert_false(MenuLogic.ark_unlocked(_data()), "a fresh game has no Ark shortcut")
	assert_true(MenuLogic.ark_unlocked(_data({"_nurse_choice": 2})), "any chat with a Sanctuary nurse unlocks it")
	var d := _data()
	d.ark.append(Fixtures.creature("pipkin", 3))
	assert_true(MenuLogic.ark_unlocked(d), "anyone already in the Ark can be reached")

func test_picker_stays_open_while_items_last() -> void:
	assert_true(MenuLogic.stay_in_picker(true, 2))
	assert_false(MenuLogic.stay_in_picker(true, 0), "that was the last one")
	assert_true(MenuLogic.stay_in_picker(false, 1), "a miss stays put so another member can be tried")

func test_objectives_walk_the_story_in_order() -> void:
	var o: Dictionary = JsonUtil.read(OBJ_PATH)
	var story: Array = o.story
	assert_true(story.size() >= 20, "covers the whole main story")
	var d := _data()
	assert_eq(MenuLogic.next_objective(d, 200, o).text, str(story[0].text), "a new game starts at the first one")
	for i in story.size() - 1:
		d.set_flag(str(story[i].flag_done), true)
		assert_eq(MenuLogic.next_objective(d, 200, o).text, str(story[i + 1].text), "after " + str(story[i].flag_done))
	d.set_flag("game_complete", true)
	var pg: Dictionary = MenuLogic.next_objective(d, 200, o)
	assert_true(pg.get("postgame", false), "after the ending, post-game hints")

func test_skipped_optional_beats_do_not_nag() -> void:
	var o: Dictionary = JsonUtil.read(OBJ_PATH)
	var story: Array = o.story
	var d := _data({str(story[5].flag_done): true})
	assert_eq(MenuLogic.next_objective(d, 200, o).text, str(story[6].text), "points past the furthest beat reached")

func test_objective_flag_values_count_when_truthy() -> void:
	var o: Dictionary = JsonUtil.read(OBJ_PATH)
	var d := _data({str(o.story[0].flag_done): "spikkin"})
	assert_eq(MenuLogic.next_objective(d, 200, o).text, str(o.story[1].text), "the starter flag holds a species id")

func test_postgame_hints() -> void:
	var o := {"story": [{"flag_done": "game_complete", "text": "end", "town": "london"}],
		"postgame": [{"flag_done": "caught_bran", "text": "raven", "town": "london"},
			{"all": ["caught_a", "caught_b"], "text": "{legends} of 2 legends", "town": ""},
			{"flag_done": "diploma", "text": "{caught} of {total} caught", "town": "macclesfield"},
			{"text": "all done", "town": ""}]}
	var d := _data({"game_complete": true})
	assert_eq(MenuLogic.next_objective(d, 200, o).text, "raven")
	d.set_flag("caught_bran", true)
	d.set_flag("caught_a", true)
	assert_eq(MenuLogic.next_objective(d, 200, o).text, "1 of 2 legends")
	d.set_flag("caught_b", true)
	d.mark_caught("pipkin")
	assert_eq(MenuLogic.next_objective(d, 200, o).text, "1 of 200 caught")
	d.set_flag("diploma", true)
	for side in SideStories.sides():  # every Keeper's side story heard (they'd come before the milestone)
		d.set_flag(SideStories.done_flag(str(side.id)), true)
	assert_true("Catch 24 more" in MenuLogic.next_objective(d, 200, o).text, "the catch-all gives way to the next Fieldbook milestone")
	assert_eq(MenuLogic.next_objective(d, 200, o).town, "macclesfield")

func test_rematches_ready_today() -> void:
	var o := {"rematches": [{"key": "rematch_keeper_maud", "name": "Maud"}, {"key": "rematch_kit", "name": "Kit"}]}
	var d := _data()
	assert_eq(MenuLogic.rematches_ready(d, o), [], "post-game only")
	d.set_flag("game_complete", true)
	Calendar.set_override("2026-10-17")
	assert_eq(MenuLogic.rematches_ready(d, o), ["Maud", "Kit"])
	d.set_flag("rematch_kit", DailyKey.stamp(d))
	assert_eq(MenuLogic.rematches_ready(d, o), ["Maud"], "Kit's been fought today")
	d.day_count += 1
	assert_eq(MenuLogic.rematches_ready(d, o), ["Maud"], "an in-game day is not enough")
	Calendar.set_override("2026-10-18")
	assert_eq(MenuLogic.rematches_ready(d, o), ["Maud", "Kit"], "a new real day")
	d.set_flag("rematch_keeper_maud", 4)
	assert_eq(MenuLogic.rematches_ready(d, o), ["Maud", "Kit"], "an old save's in-game day counts as not today")
	Calendar.set_override("")

## Every flag the story can set: set/choice/badge/battle/gauntlet/legend/daily commands in dialogue and
## zone scripts, sight-trainers in zones, and visited_<town> from Travel.
func _story_flags() -> Dictionary:
	var out := {}
	for dir in ["res://data/dialogue", "res://data/zones"]:
		for path in JsonUtil.list_json(dir):
			_walk(JsonUtil.read(path), out)
	for t in Travel.world_map().get("towns", {}):
		out["visited_" + str(t)] = true
	return out

func _walk(x, out: Dictionary) -> void:
	if x is Dictionary:
		match str(x.get("do", "")):
			"set":
				out[str(x.get("flag", ""))] = true
			"choice":
				if x.has("set"):
					out[str(x.set)] = true
			"badge":
				out["badge_" + str(x.get("id", ""))] = true
			"battle":
				out["trainer_" + str(x.get("trainer", ""))] = true
			"gauntlet":
				out[str(x.get("flag", "gauntlet_won"))] = true
			"legend":
				out[str(x.get("flag", "caught_" + str(x.get("species", ""))))] = true
			"daily":
				out[str(x.get("key", ""))] = true
			"starter":
				out["starter"] = true  # the starter picker stores the species id
		if x.has("trainer") and not x.has("do"):
			out["trainer_" + str(x.trainer)] = true  # a zone NPC who battles on sight
		for v in x.values():
			_walk(v, out)
	elif x is Array:
		for v in x:
			_walk(v, out)

func test_every_objective_flag_is_set_by_the_story() -> void:
	var o: Dictionary = JsonUtil.read(OBJ_PATH)
	var flags := _story_flags()
	for e in o.story + o.postgame:
		var need: Array = e.get("all", [])
		if e.has("flag_done"):
			need = need + [e.flag_done]
		for f in need:
			assert_true(flags.has(str(f)), "nothing in the story sets '%s'" % f)
	for r in o.rematches:
		assert_true(flags.has(str(r.key)), "no daily rematch keyed '%s'" % r.key)

func test_objective_point_on_the_world_map() -> void:
	const WorldMap = preload("res://ui/world_map.gd")
	var york: Dictionary = Travel.world_map().towns.york
	assert_eq(WorldMap.objective_point({"town": "york"}), Vector2(float(york.x), float(york.y)))
	assert_eq(WorldMap.objective_point({"town": "york", "map": [10, 20]}), Vector2(10, 20), "an explicit spot wins")
	assert_eq(WorldMap.objective_point({"town": ""}), Vector2(-1, -1))
	assert_true(WorldMap.objective_point({"town": "causeway"}).x >= 0, "places count too")

func test_every_objective_place_is_on_the_map() -> void:
	var o: Dictionary = JsonUtil.read(OBJ_PATH)
	var m := Travel.world_map()
	for e in o.story + o.postgame + o.rematches:
		var t := str(e.get("town", ""))
		if t != "":
			assert_true(m.towns.has(t) or m.places.has(t), "'%s' is not on the world map" % t)
		if e.has("map"):
			assert_eq(e.map.size(), 2, "map point is [x, y]")
	assert_true(o.story.all(func(e): return str(e.get("town", "")) != "" or e.has("map")), "every story step can be ringed")
	assert_eq(str(o.story.back().flag_done), "game_complete", "the story ends at the ending")
