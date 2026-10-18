extends TestCase
## Rewilding: six sites, four stages, a day to settle, gated encounters, rewards once, and a world that changes.

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 10
	return d

func _host() -> FakeStoryHost:
	var h := FakeStoryHost.new()
	h.data.day_count = 10
	return h

func _talk(h: FakeStoryHost, site: String) -> void:
	await Commands.new(h).run([{"do": "rewild", "site": site}])

# --- the sites ---------------------------------------------------------------

func test_six_sites_one_per_nation() -> void:
	var nations := {}
	for s in Rewild.sites():
		nations[str(s.nation)] = true
	assert_eq(Rewild.sites().size(), 6)
	for n in ["england", "wales", "scotland", "northern_ireland", "ireland", "mann"]:
		assert_true(nations.has(n), "a site in %s" % n)

func test_each_site_sits_in_a_real_zone_with_its_warden() -> void:
	for s in Rewild.sites():
		var z := ZoneData.load_id(str(s.zone))
		var r := Rewild.rect(s)
		assert_true(z.width > 0, "%s: zone %s exists" % [s.id, s.zone])
		assert_true(z.in_bounds(r.position) and z.in_bounds(r.end - Vector2i.ONE), "%s: rect inside the zone" % s.id)
		var warden := {}
		for n in z.npcs:
			var sc := StoryData.script(z.id, str(n.get("script", "")))
			if JSON.stringify(sc).contains("\"site\":\"%s\"" % s.id):
				warden = n
		assert_false(warden.is_empty(), "%s: a warden NPC runs the rewild command" % s.id)
		assert_eq(Rewild.tasks(s).size(), 3, "%s: three tasks" % s.id)
		assert_eq(s.rewards.size(), 3, "%s: three rewards" % s.id)

func test_every_task_names_real_things() -> void:
	var items := ItemDB.load_default()
	var dex := Dex.load_default()
	for s in Rewild.sites():
		for t in Rewild.tasks(s):
			match str(t.kind):
				"items":
					for id in t.items:
						assert_true(items.has(str(id)), "%s: item %s" % [s.id, id])
				"battle":
					assert_true(StoryData.trainer_exists(str(t.trainer)), "%s: trainer %s" % [s.id, t.trainer])
				"plant", "litter":
					assert_true(int(t.spots) > 0)
		for stage in s.encounters:
			for e in stage:
				assert_true(dex.has(str(e.species)), "%s: species %s" % [s.id, e.species])

# --- stages and settling -----------------------------------------------------

func test_starts_damaged() -> void:
	var d := _data()
	assert_eq(Rewild.stage(d, "goyt_moss"), 0)
	assert_false(Rewild.pending(d, "goyt_moss"))

func test_first_stage_comes_at_once() -> void:
	var d := _data()
	Rewild.contribute(d, "goyt_moss")
	assert_eq(Rewild.stage(d, "goyt_moss"), 1)
	assert_false(Rewild.pending(d, "goyt_moss"))

func test_later_stages_settle_over_one_in_game_day() -> void:
	var d := _data()
	d.set_flag("rewild_goyt_moss", 1)
	Rewild.contribute(d, "goyt_moss")
	assert_eq(Rewild.stage(d, "goyt_moss"), 1, "not yet")
	assert_true(Rewild.pending(d, "goyt_moss"))
	assert_eq(Rewild.settle(d), [], "same day: still settling")
	d.day_count += 1
	assert_eq(Rewild.settle(d), ["goyt_moss"])
	assert_eq(Rewild.stage(d, "goyt_moss"), 2)
	assert_false(Rewild.pending(d, "goyt_moss"))

func test_no_contributing_while_settling_or_wild() -> void:
	var d := _data()
	d.set_flag("rewild_goyt_moss", 1)
	Rewild.contribute(d, "goyt_moss")
	assert_false(Rewild.can_contribute(d, "goyt_moss"))
	d.set_flag("rewild_goyt_moss", 3)
	d.flags.erase("rewild_goyt_moss_due")
	assert_false(Rewild.can_contribute(d, "goyt_moss"))

# --- encounters ---------------------------------------------------------------

func test_gated_encounters_need_the_stage() -> void:
	var z := ZoneData.from_dict({"id": "e", "rows": [",,,"], "encounters": {"grass": [
		{"species": "spikkin", "min": 2, "max": 2, "weight": 10},
		{"species": "volet", "min": 2, "max": 2, "weight": 10, "requires_flag": "rewild_x", "flag_at_least": 1},
		{"species": "ratty", "min": 2, "max": 2, "weight": 10, "requires_flag": "rewild_x", "flag_at_least": 3},
	]}})
	assert_eq(Encounters.candidates(z, "grass", "day", "clear").size(), 1, "no flags: only the ungated")
	assert_eq(Encounters.candidates(z, "grass", "day", "clear", {"rewild_x": 1}).size(), 2)
	assert_eq(Encounters.candidates(z, "grass", "day", "clear", {"rewild_x": 3}).size(), 3)

func test_apply_adds_the_sites_encounters_gated() -> void:
	var d := _data()
	var z := ZoneData.load_id("goyt_valley")
	var before := Encounters.candidates(z, "grass", "day", "clear", d.flags).size()
	Rewild.apply(d, z)
	assert_eq(Encounters.candidates(z, "grass", "day", "clear", d.flags).size(), before, "stage 0: nothing new")
	d.set_flag("rewild_goyt_moss", 3)
	var all := Encounters.candidates(z, "grass", "day", "clear", d.flags).map(func(e): return str(e.species))
	assert_has(all, "volet")
	assert_has(all, "snowhare")

# --- the look of the place ------------------------------------------------------

func test_stages_change_the_ground() -> void:
	for s in Rewild.sites():
		var looks := []
		for stage in 4:
			var d := _data()
			d.set_flag("rewild_" + str(s.id), stage)
			var z := ZoneData.load_id(str(s.zone))
			Rewild.apply(d, z)
			var r := Rewild.rect(s)
			var sig := ""
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					sig += z.tile_at(Vector2i(x, y)).substr(0, 2)
			looks.append(sig)
			var lay: Dictionary = z.get_meta("rewild")[0]
			assert_false(lay.decor.is_empty(), "%s stage %d has props" % [s.id, stage])
		assert_true(looks[0] != looks[3], "%s: Wild looks different from Damaged" % s.id)

func test_wild_never_cuts_anywhere_off() -> void:
	var all := ["hedge_lay", "brook_wade", "fell_scramble", "bog_cross"]
	for s in Rewild.sites():
		var raw := ZoneData.load_id(str(s.zone))
		var start := raw.spawn
		var was := raw.reachable(start, all)
		for stage in 4:
			var d := _data()
			d.set_flag("rewild_" + str(s.id), stage)
			var z := ZoneData.load_id(str(s.zone))
			Rewild.apply(d, z)
			var now := z.reachable(start, all)
			for p in was:
				if z.walkable(p) or raw.tile_at(p) == z.tile_at(p):
					assert_true(now.has(p), "%s stage %d: %s still reachable" % [s.id, stage, p])
			for sp in Rewild.spots(z, s):
				assert_true(z.walkable(sp), "%s: spot %s stays walkable" % [s.id, sp])

func test_spots_are_distinct_open_tiles_in_the_rect() -> void:
	for s in Rewild.sites():
		var z := ZoneData.load_id(str(s.zone))
		var sp := Rewild.spots(z, s)
		assert_eq(sp.size(), 5, "%s: five spots" % s.id)
		var seen := {}
		for p in sp:
			assert_true(Rewild.rect(s).has_point(p), "%s: spot inside" % s.id)
			assert_false(seen.has(p))
			seen[p] = true

# --- the warden -----------------------------------------------------------------

func test_first_talk_asks_for_the_first_task() -> void:
	var h := _host()
	await _talk(h, "goyt_moss")
	assert_true(h.data.flag("rewild_goyt_moss_met") == true)
	assert_true(" ".join(h.texts()).contains("sphagnum"))
	assert_eq(Rewild.stage(h.data, "goyt_moss"), 0)

func test_planting_every_spot_then_talking_plants_the_site() -> void:
	var h := _host()
	var s := Rewild.site("goyt_moss")
	var z := ZoneData.load_id("goyt_valley")
	for p in Rewild.spots(z, s):
		assert_true(Rewild.mark_spot(h.data, z, p) != "")
	assert_true(Rewild.task_done(h.data, "goyt_moss"))
	await _talk(h, "goyt_moss")
	assert_eq(Rewild.stage(h.data, "goyt_moss"), 1)
	assert_eq(int(h.data.bag.get("heather_honey", 0)), 2, "stage reward")

func test_items_task_takes_the_items() -> void:
	var h := _host()
	h.data.set_flag("rewild_goyt_moss", 1)
	h.data.set_flag("rewild_goyt_moss_rewarded", 1)
	h.data.bag["sheep_wool"] = 5
	h.choices = [0]
	await _talk(h, "goyt_moss")
	assert_eq(int(h.data.bag.get("sheep_wool", 0)), 2)
	assert_true(Rewild.pending(h.data, "goyt_moss"))

func test_short_of_items_changes_nothing() -> void:
	var h := _host()
	h.data.set_flag("rewild_goyt_moss", 1)
	h.data.set_flag("rewild_goyt_moss_rewarded", 1)
	h.data.bag["sheep_wool"] = 1
	h.choices = [0]
	await _talk(h, "goyt_moss")
	assert_eq(int(h.data.bag.get("sheep_wool", 0)), 1)
	assert_false(Rewild.pending(h.data, "goyt_moss"))

func test_money_task() -> void:
	var h := _host()
	h.data.set_flag("rewild_coed_padarn", 1)
	h.data.set_flag("rewild_coed_padarn_rewarded", 1)
	h.data.money = 1000
	h.choices = [0]
	await _talk(h, "coed_padarn")
	assert_eq(h.data.money, 200)
	assert_true(Rewild.pending(h.data, "coed_padarn"))

func test_show_task_keeps_the_creature() -> void:
	var h := _host()
	h.data.set_flag("rewild_derrygimlagh_met", true)
	h.data.party = [Fixtures.creature("sphagnet", 20)]
	await _talk(h, "derrygimlagh")
	assert_eq(Rewild.stage(h.data, "derrygimlagh"), 1)
	assert_eq(h.data.party.size(), 1, "it stays with you")

func test_battle_task_needs_a_win() -> void:
	var h := _host()
	h.data.set_flag("rewild_dundreggan_met", true)
	h.battle_results = [{"result": "ran"}]
	h.choices = [0]
	await _talk(h, "dundreggan")
	assert_eq(Rewild.stage(h.data, "dundreggan"), 0, "no win, no stage")
	h.choices = [0]
	await _talk(h, "dundreggan")
	assert_eq(Rewild.stage(h.data, "dundreggan"), 1)

func test_settled_stage_is_rewarded_once() -> void:
	var h := _host()
	h.data.set_flag("rewild_goyt_moss", 1)
	h.data.set_flag("rewild_goyt_moss_rewarded", 1)
	h.data.set_flag("rewild_goyt_moss_due", 10)
	h.data.day_count = 11
	await _talk(h, "goyt_moss")
	assert_eq(Rewild.stage(h.data, "goyt_moss"), 2)
	assert_eq(int(h.data.bag.get("honeycomb", 0)), 1)
	await _talk(h, "goyt_moss")
	assert_eq(int(h.data.bag.get("honeycomb", 0)), 1, "only once")

func test_all_six_wild_gives_the_crook_once() -> void:
	var h := _host()
	for s in Rewild.sites():
		h.data.set_flag("rewild_" + str(s.id), 3)
		h.data.set_flag("rewild_%s_rewarded" % s.id, 3)
		h.data.set_flag("rewild_%s_met" % s.id, true)
	assert_true(Rewild.all_wild(h.data))
	await _talk(h, "goyt_moss")
	assert_eq(int(h.data.bag.get("rewilders_crook", 0)), 1)
	await _talk(h, "river_bush")
	assert_eq(int(h.data.bag.get("rewilders_crook", 0)), 1)

# --- pointing the way -----------------------------------------------------------

func test_hint_names_the_next_step() -> void:
	var d := _data()
	assert_eq(Rewild.hint(d), "", "nothing until the first Stone")
	d.set_flag("badge_brook", true)
	assert_true(Rewild.hint(d).contains("Goyt's Moss"))
	for s in Rewild.sites():
		d.set_flag("rewild_" + str(s.id), 3)
	d.set_flag("rewild_goyt_moss", 1)
	d.set_flag("rewild_goyt_moss_met", true)
	assert_true(Rewild.hint(d).contains("Sheep Wool") or Rewild.hint(d).contains("sheep wool"), Rewild.hint(d))
	Rewild.contribute(d, "goyt_moss")
	assert_true(Rewild.hint(d).contains("settling"), "only one left and it's settling")
	d.flags.erase("rewild_goyt_moss_due")
	d.set_flag("rewild_goyt_moss", 3)
	assert_eq(Rewild.hint(d), "")

func test_where_next_mentions_rewilding_after_the_story() -> void:
	var d := _data()
	d.set_flag("game_complete", true)
	d.set_flag("badge_brook", true)
	for side in SideStories.sides():  # every side story heard (they'd come first)
		d.set_flag(SideStories.done_flag(str(side.id)), true)
	var o := {"story": [], "postgame": [{"text": "all done", "town": ""}]}
	var hint := MenuLogic.next_objective(d, 10, o)
	assert_true(str(hint.text).contains("Goyt's Moss"), str(hint))

func test_stats_count_the_wild_sites() -> void:
	var d := _data()
	d.set_flag("rewild_goyt_moss", 3)
	var row: Array = TrainerStats.lines(d).filter(func(r): return r[0] == "Land rewilded")
	assert_eq(row.size(), 1)
	assert_eq(row[0][1], "1 of 6 sites Wild")
