extends TestCase
## The Potteries (wave 21): the Roaches and Stoke-on-Trent off Macclesfield's south lane, their quests,
## trainers, items and the three regional creature lines.

const ZONES := ["the_roaches", "stoke", "luds_church"]
const LINES := {"saggit": "bottlekiln", "rustelver": "ochreel", "bertilak": ""}

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func _npc(zone_id: String, npc_id: String) -> Dictionary:
	for n in ZoneData.load_id(zone_id).npcs:
		if n.get("id", "") == npc_id:
			return n
	return {}

func _bag(h: FakeStoryHost, item: String) -> int:
	return Bag.new(h.data.bag).count(item)

# ---------------------------------------------------------------- the map

func test_the_lane_south_of_macclesfield_leads_to_the_roaches_then_stoke() -> void:
	var macc := ZoneData.load_id("macclesfield")
	var roaches := ZoneData.load_id("the_roaches")
	var stoke := ZoneData.load_id("stoke")
	assert_eq(str(macc.edges.south.to), "the_roaches")
	assert_eq(str(macc.edges.east.to), "macc_forest", "the old exit is untouched")
	assert_eq(str(roaches.edges.north.to), "macclesfield")
	assert_eq(str(roaches.edges.south.to), "stoke")
	assert_eq(stoke.edges.keys(), ["north"], "Stoke is a cul-de-sac: no shortcut to anywhere else")
	assert_eq(roaches.edges.keys().size(), 2)

func test_the_way_south_is_closed_until_kit_is_beaten() -> void:
	var blockers := 0
	for n in ZoneData.load_id("macclesfield").npcs:
		if str(n.get("script", "")) == "potteries_gate":
			blockers += 1
			assert_eq(str(n.hide_if), "kit1_fought")
	assert_eq(blockers, 2)
	# with the blockers standing, the lane is shut: every walkable tile on the south edge is behind them
	var macc := ZoneData.load_id("macclesfield")
	var blocked := {Vector2i(33, 36): true, Vector2i(34, 36): true}
	var seen := macc.reachable(macc.spawn, [], blocked)
	for x in macc.width:
		assert_false(seen.has(Vector2i(x, macc.height - 1)), "the south edge is unreachable past the sheep at x=%d" % x)
	assert_true(macc.reachable(macc.spawn).has(Vector2i(33, macc.height - 1)), "and open once they've gone")

func test_new_zones_are_scaled_from_par_8() -> void:
	for id in ZONES:
		assert_eq(ZoneData.load_id(id).scaled_floor, 8, id)
	for f in DirAccess.get_files_at("res://data/trainers"):
		if f.begins_with("roaches_") or f.begins_with("stoke_") or f.begins_with("rudyard_"):
			assert_eq(int(StoryData.trainer(f.get_basename()).get("scaled_floor", -1)), 8, f)

func test_encounters_are_fair_for_an_early_team() -> void:
	for id in ZONES:
		for kind in ZoneData.load_id(id).encounters:
			for e in ZoneData.load_id(id).encounters[kind]:
				assert_true(int(e.min) >= 8 and int(e.max) <= 11, "%s %s %s" % [id, kind, e.species])

func test_stoke_is_a_proper_town() -> void:
	var z := ZoneData.load_id("stoke")
	assert_eq(z.town_id, "stoke")
	assert_true(z.station != Vector2i(-1, -1), "on the rail network")
	var interiors := 0
	for w in z.warps:
		interiors += 1
	assert_true(interiors >= 8, "plenty of places to go in")
	assert_true(Travel.world_map().towns.has("stoke"))
	assert_true(Travel.world_map().places.has("the_roaches"))
	var plaques := 0
	for s in z.signs:
		if s.has("plaque"):
			plaques += 1
	assert_true(plaques >= 8, "at least 8 heritage plaques in town")

func test_plaques_are_unique_and_titled() -> void:
	var seen := {}
	for id in ["stoke", "the_roaches", "luds_church"]:
		for s in ZoneData.load_id(id).signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "duplicate plaque %s" % s.plaque)
				seen[s.plaque] = true
				assert_true(str(s.plaque).begins_with("potteries_"))
				assert_true(str(s.get("title", "")) != "" and str(s.text).length() > 60)
				assert_false("—" in str(s.text), "no em-dashes")
	assert_true(seen.size() >= 19)

func test_the_landmarks_build() -> void:
	for style in ["bottle_kiln", "potbank"]:
		assert_has(Landmarks.SPECIAL, style)
		var meshes: Array = Meshes.building(3 if style == "bottle_kiln" else 8, 3 if style == "bottle_kiln" else 4, style, 1, 7)
		assert_true((meshes[0] as ArrayMesh).get_surface_count() > 0, style)

# ---------------------------------------------------------------- creatures

func test_the_new_lines_are_appendix_species_with_art_and_a_home() -> void:
	var dex := Dex.load_default()
	var order: Array = JsonUtil.read("res://data/dex_order.json")
	for base in LINES:
		for id in [base, LINES[base]]:
			if id == "":
				continue
			assert_true(dex.has(id), id)
			assert_true(bool(dex.get_species(id).get("appendix", false)), "%s is in the appendix" % id)
			assert_has(order, id)
			for part in ["front", "back", "icon"]:
				assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [id, part]), "%s %s" % [id, part])
		var placed := false
		for zid in ZONES:
			for kind in ZoneData.load_id(zid).encounters:
				for e in ZoneData.load_id(zid).encounters[kind]:
					placed = placed or str(e.species) == base
		assert_true(placed, "%s turns up in the wild" % base)
	assert_eq(dex.core_ids().size(), 200, "the Fieldbook proper is untouched")

# ---------------------------------------------------------------- quests

func test_every_quest_flag_is_set_somewhere() -> void:
	var setters := {}
	var dialogue := StoryData.all_dialogue()
	for f in dialogue:
		for sid in dialogue[f]:
			_collect(dialogue[f][sid], setters)
	var quests: Array = JsonUtil.read("res://data/quests/potteries.json").quests
	assert_eq(quests.size(), 4)
	for q in quests:
		var flags: Array = [q.start_flag, q.done_flag]
		for st in q.steps:
			flags.append(st.flag)
			assert_true(FileAccess.file_exists("res://data/zones/%s.json" % st.zone), st.zone)
		for fl in flags:
			assert_true(str(fl).begins_with("q_potteries_"), fl)
			assert_true(setters.has(fl), "%s is set by some script" % fl)

func _collect(v: Variant, out: Dictionary) -> void:
	if v is Array:
		for x in v:
			_collect(x, out)
	elif v is Dictionary:
		if str(v.get("do", "")) == "set" or str(v.get("do", "")) == "legend":
			out[str(v.get("flag", ""))] = true
		for k in v:
			_collect(v[k], out)

func test_firing_day_runs_end_to_end() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "stoke", "fireman", "gladstone_fireman")
	assert_true(h.data.flag("q_potteries_firing_started") == true)
	await _run(h, "stoke", "boatman", "canal_boatman")
	assert_true(h.last_battle.is_empty(), "no coal before the saggars")
	await _run(h, "stoke_middleport", "bottom_knocker", "bottom_knocker")
	assert_true(h.data.flag("q_potteries_firing_1") == true)
	await _run(h, "stoke", "boatman", "canal_boatman")
	assert_eq(str(h.last_battle.opts.trainer.id), "stoke_alf", "Alf wants a fight first")
	assert_true(h.data.flag("q_potteries_firing_2") == true)
	await _run(h, "stoke_spode", "clay_cellar", "spode_clay")
	assert_true(h.data.flag("q_potteries_firing_3") == true)
	var before := h.data.party.size()
	await _run(h, "stoke", "fireman", "gladstone_fireman")
	assert_true(h.data.flag("q_potteries_firing_done") == true)
	assert_eq(_bag(h, "kiln_brick"), 1)
	assert_eq(h.data.party.size(), before + 1, "a Saggit joins")
	assert_eq(str(h.data.party[-1].species.id), "saggit")

func test_the_wallaby_waits_for_the_trail_and_must_be_caught() -> void:
	var w := _npc("the_roaches", "potteries_wallaby")
	assert_eq(str(w.show_if), "q_potteries_wallaby_3")
	assert_eq(str(w.hide_if), "q_potteries_wallaby_done")
	var h := FakeStoryHost.new()
	await _run(h, "the_roaches", "wallaby_watcher", "potteries_watcher")
	await _run(h, "the_roaches", "doxey_ranger", "doxey_ranger")
	assert_false(h.data.flag("q_potteries_wallaby_2") == true, "in order: the Hanging Stone first")
	for s in [["hanging_hiker", "hanging_hiker"], ["doxey_ranger", "doxey_ranger"], ["rudyard_boater", "rudyard_boater"]]:
		await _run(h, "the_roaches", s[0], s[1])
	assert_true(h.data.flag("q_potteries_wallaby_3") == true)
	h.data.clock_minutes = 12 * 60
	await _run(h, "the_roaches", "wild_wallaby", "potteries_wallaby")
	assert_true(h.last_battle.is_empty(), "asleep at midday: wallabies come out at dawn and dusk")
	h.data.clock_minutes = 19 * 60
	await _run(h, "the_roaches", "wild_wallaby", "potteries_wallaby")
	assert_eq(str(h.last_battle.foes[0].species.id), "roachroo")
	assert_false(h.data.flag("q_potteries_wallaby_4") == true, "knocked out is not caught")
	h.battle_results = [{"result": "caught", "caught": null}]
	await _run(h, "the_roaches", "wild_wallaby", "potteries_wallaby")
	assert_true(h.data.flag("q_potteries_wallaby_4") == true)
	await _run(h, "the_roaches", "wallaby_watcher", "potteries_watcher")
	assert_true(h.data.flag("q_potteries_wallaby_done") == true)
	assert_eq(_bag(h, "staffordshire_knot"), 1)

func test_the_hoard_question_needs_the_right_answer() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "stoke_museum", "curator", "museum_curator")
	await _run(h, "stoke_museum", "hoard_guide", "museum_guide")
	await _run(h, "the_roaches", "detectorist", "roaches_detectorist")
	h.choices = [0]
	await _run(h, "stoke_museum", "curator", "museum_curator")
	assert_false(h.data.flag("q_potteries_hoard_done") == true, "coins is wrong")
	h.choices = [1]
	await _run(h, "stoke_museum", "curator", "museum_curator")
	assert_true(h.data.flag("q_potteries_hoard_done") == true)
	assert_eq(_bag(h, "hoard_garnet"), 1)

func test_the_oatcake_round_teaches_the_recipe() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "stoke", "oatcake_hatch", "oatcake_lady")
	await _run(h, "stoke_museum", "museum_attendant", "museum_attendant")
	await _run(h, "stoke_leopard", "leopard_landlord", "leopard_landlord")
	await _run(h, "stoke", "city_fan", "stoke_city_fan")
	await _run(h, "stoke", "oatcake_hatch", "oatcake_lady")
	assert_true(h.data.flag("q_potteries_oatcakes_done") == true)
	assert_true(h.data.flag("recipe_staffordshire_oatcakes") == true)
	assert_eq(_bag(h, "oatmeal"), 4)

# ---------------------------------------------------------------- scaling of gifts and one-off encounters

func test_a_scaled_legend_and_gift_lift_with_the_story() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_urban", true)  # par 22
	await Commands.new(h).run([{"do": "legend", "species": "roachroo", "level": 10, "scaled_floor": 8, "flag": "x"}])
	assert_eq(h.last_battle.foes[0].level, 24)
	await Commands.new(h).run([{"do": "give_creature", "species": "saggit", "level": 10, "scaled_floor": 8}])
	assert_eq(h.data.party[-1].level, 24)
	assert_eq(str(h.data.party[-1].species.id), "bottlekiln", "and evolved to suit")
	var g := FakeStoryHost.new()
	await Commands.new(g).run([{"do": "give_creature", "species": "saggit", "level": 10, "scaled_floor": 8}])
	assert_eq(g.data.party[-1].level, 10, "never lower than written")
