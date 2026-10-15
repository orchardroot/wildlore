extends TestCase
## Plan 7 post-game: Keeper, Garside and Kit rematches, the Orkney and Isle of Man secrets, the Fieldbook diploma.

class RecHost extends FakeStoryHost:
	var fought: Array = []
	var legends: Array = []

	func battle(foe_party: Array, opts: Dictionary) -> Dictionary:
		if opts.has("trainer"):
			fought.append(str(opts.trainer.id))
		elif opts.get("no_run", false):
			legends.append([str(foe_party[0].species.id), int(foe_party[0].level)])
		return super.battle(foe_party, opts)

const KEEPERS := [
	["maud", "buxton_spa", "maud"], ["ray", "liverpool_club", "keeper_ray"], ["eluned", "llanberis_quarry", "keeper_eluned"],
	["rhys", "cardiff_arena", "keeper_rhys"], ["morwen", "glastonbury_tor", "keeper_morwen"], ["nuala", "galway_docks", "keeper_nuala"],
	["declan", "dublin_hall", "keeper_declan"], ["isla", "inverness_rink", "keeper_isla"], ["ruairi", "belfast_yard", "keeper_ruairi"],
	["hester", "york_minster_crypt", "keeper_hester"],
]

func _host(complete := true) -> RecHost:
	var h := RecHost.new()
	h.dex = Dex.load_default()
	h.moves = MoveDB.load_default()
	if complete:
		h.data.set_flag("game_complete", true)
	return h

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func _said_has(h: FakeStoryHost, needle: String) -> bool:
	for line in h.said:
		if String(line[1]).contains(needle):
			return true
	return false

func _bag(h: FakeStoryHost, item: String) -> int:
	return Bag.new(h.data.bag).count(item)

func _npc(zone_id: String, npc_id: String) -> Dictionary:
	for n in ZoneData.load_id(zone_id).npcs:
		if n.get("id", "") == npc_id:
			return n
	return {}

# ---------------------------------------------------------------- rematch trainers

func test_rematch_trainers_have_six_creatures_at_95_to_100() -> void:
	var ids := ["prof_garside_rematch", "kit_rematch_vs_spikkin", "kit_rematch_vs_holtling", "kit_rematch_vs_kindlet"]
	for k in KEEPERS:
		ids.append("keeper_%s_rematch" % k[0])
	for id in ids:
		var t := StoryData.trainer(id)
		assert_eq(t.party.size(), 6, id)
		for m in t.party:
			assert_true(m.level >= 95 and m.level <= 100, "%s level %d" % [id, m.level])
		assert_true(t.money > 0, id + " pays on a win")
		assert_true(t.intro.size() > 0 and t.win != "", id + " has an intro and a defeat line")

# ---------------------------------------------------------------- rematches

func test_keeper_rematch_only_after_game_complete() -> void:
	for k in KEEPERS:
		var h := _host(false)
		h.data.set_flag("trainer_keeper_" + k[0], true)
		h.choices = [0]
		await _run(h, k[1], k[2], "keeper_" + k[0])
		assert_eq(h.fought.size(), 0, "%s: no rematch before the ending" % k[0])
		h.data.set_flag("game_complete", true)
		h.choices = [0]
		await _run(h, k[1], k[2], "keeper_" + k[0])
		assert_eq(h.fought, ["keeper_%s_rematch" % k[0]], k[0])
		assert_eq(h.last_battle.opts.ai, "keeper")

func test_declining_a_rematch_does_not_use_up_the_day() -> void:
	var h := _host()
	h.data.set_flag("trainer_keeper_maud", true)
	h.choices = [1]
	await _run(h, "buxton_spa", "maud", "keeper_maud")
	assert_eq(h.fought.size(), 0)
	h.choices = [0]
	await _run(h, "buxton_spa", "maud", "keeper_maud")
	assert_eq(h.fought, ["keeper_maud_rematch"])

func test_keeper_rematch_once_per_in_game_day() -> void:
	var h := _host()
	h.data.set_flag("trainer_keeper_isla", true)
	for i in 2:
		h.choices = [0]
		await _run(h, "inverness_rink", "keeper_isla", "keeper_isla")
	assert_eq(h.fought.size(), 1, "second ask on the same day is refused")
	assert_true(_said_has(h, "Once a day"))
	h.data.day_count += 1
	h.choices = [0]
	await _run(h, "inverness_rink", "keeper_isla", "keeper_isla")
	assert_eq(h.fought.size(), 2, "a new day, a new rematch")
	# each Keeper has their own daily allowance
	h.data.set_flag("trainer_keeper_maud", true)
	h.choices = [0]
	await _run(h, "buxton_spa", "maud", "keeper_maud")
	assert_eq(h.fought.size(), 3)

func test_losing_a_rematch_whites_out_and_costs_the_day() -> void:
	var h := _host()
	h.data.set_flag("trainer_keeper_ray", true)
	h.data.money = 1000
	h.data.last_sanctuary = {"zone": "macclesfield", "pos": [3, 4]}
	h.battle_results = [{"result": "lose"}]
	h.choices = [0]
	await _run(h, "liverpool_club", "keeper_ray", "keeper_ray")
	assert_eq(h.data.money, 500)
	assert_eq(h.warps.size(), 1)
	assert_eq(h.data.flag("trainer_keeper_ray_rematch"), null, "no win recorded")

func test_garside_rematch_after_game_complete_once_a_day() -> void:
	var h := _host(false)
	h.choices = [1, 0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(h.fought.size(), 0, "not before the ending")
	h.data.set_flag("game_complete", true)
	h.choices = [1, 0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(h.fought, ["prof_garside_rematch"])
	h.choices = [1, 0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(h.fought.size(), 1)
	h.data.day_count += 1
	h.choices = [1, 0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(h.fought.size(), 2)

func test_kit_rematch_matches_the_starter_and_runs_once_a_day() -> void:
	for sp in ["spikkin", "holtling", "kindlet"]:
		var h := _host()
		h.data.set_flag("kit_vs_" + sp, true)
		h.choices = [0]
		await _run(h, "macc_fieldstation", "kit_station", "kit")
		assert_eq(h.fought, ["kit_rematch_vs_" + sp])
		h.choices = [0]
		await _run(h, "macc_fieldstation", "kit_station", "kit")
		assert_eq(h.fought.size(), 1, sp + ": once a day")
	var h2 := _host(false)
	h2.data.set_flag("kit_vs_spikkin", true)
	h2.choices = [0]
	await _run(h2, "macc_fieldstation", "kit_station", "kit")
	assert_eq(h2.fought.size(), 0)

func test_old_station_lines_survive_before_the_ending() -> void:
	var h := _host(false)
	await _run(h, "macc_fieldstation", "kit_station", "kit")
	assert_true(_said_has(h, "Garside's giving out creatures"))

func test_mum_mentions_the_rematches() -> void:
	var h := _host()
	await _run(h, "macc_home", "mum", "mum")
	assert_true(_said_has(h, "rematch"))

# ---------------------------------------------------------------- Orkney

func test_orkney_stones_only_after_game_complete_and_at_night() -> void:
	var n := _npc("kirkwall", "brodgar_night")
	assert_eq(str(n.get("show_if", "")), "game_complete")
	# before the ending, even at night: nothing
	var h := _host(false)
	h.data.clock_minutes = 23 * 60
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends.size(), 0)
	assert_eq(_bag(h, "brodgar_pebble"), 0)
	# after the ending but by day: nothing
	var h2 := _host()
	h2.data.clock_minutes = 12 * 60
	await _run(h2, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h2.legends.size(), 0)
	assert_eq(_bag(h2, "brodgar_pebble"), 0)
	assert_true(_said_has(h2, "Perhaps after dark"))
	assert_false(h2.data.flag("brodgar_secret_done") == true, "daylight does not use it up")

func test_orkney_secret_gives_pebble_and_megalorn_once() -> void:
	var h := _host()
	h.data.clock_minutes = 23 * 60
	h.battle_results = [{"result": "caught"}]
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends, [["megalorn", 95]])
	assert_eq(_bag(h, "brodgar_pebble"), 1)
	assert_eq(h.data.flag("brodgar_secret_done"), true)
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends.size(), 1, "the Ring says its piece once")
	assert_eq(_bag(h, "brodgar_pebble"), 1)
	h.data.clock_minutes = 2 * 60
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends.size(), 1)

func test_orkney_secret_survives_a_knock_out_and_ends_on_a_catch() -> void:
	var h := _host()
	h.data.clock_minutes = 23 * 60
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")  # megalorn knocked out ("win")
	assert_false(h.data.flag("brodgar_secret_done") == true, "not used up by a knock-out")
	h.battle_results = [{"result": "caught"}]
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends.size(), 2, "met again")
	assert_eq(_bag(h, "brodgar_pebble"), 1, "the pebble is given once")
	assert_eq(h.data.flag("brodgar_secret_done"), true)
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_eq(h.legends.size(), 2, "never caught twice")

func test_orkney_warden_by_day_says_to_come_back_at_night() -> void:
	var h := _host()
	h.data.clock_minutes = 12 * 60
	await _run(h, "kirkwall", "brodgar_night", "brodgar_night")
	assert_true(_said_has(h, "after dark"))
	assert_true(h.said.any(func(l): return l[0] == "Night Warden"), "the warden is visible, so they speak")

func test_fairy_secret_survives_a_knock_out_and_ends_on_a_catch() -> void:
	var h := _host()
	h.choices = [0, 0, 0]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_false(h.data.flag("fairy_bridge_done") == true, "not used up by a knock-out")
	h.battle_results = [{"result": "caught"}]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends.size(), 2)
	assert_eq(_bag(h, "fairy_bridge_ribbon"), 1, "the ribbon is given once")
	assert_eq(h.data.flag("fairy_bridge_done"), true)
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends.size(), 2)

# ---------------------------------------------------------------- Isle of Man

func test_fairy_bridge_only_after_game_complete() -> void:
	assert_eq(str(_npc("douglas", "fairy_bridge").get("show_if", "")), "game_complete")
	var h := _host(false)
	h.choices = [0]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends.size(), 0)
	assert_eq(_bag(h, "fairy_bridge_ribbon"), 0)

func test_saying_hello_to_the_fairies_matters() -> void:
	var h := _host()
	h.choices = [1]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends.size(), 0, "walking past gets nothing")
	assert_eq(_bag(h, "fairy_bridge_ribbon"), 0)
	assert_false(h.data.flag("fairy_bridge_done") == true, "and you may try again")
	h.choices = [0]
	h.battle_results = [{"result": "caught"}]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends, [["tylwyth", 95]])
	assert_eq(_bag(h, "fairy_bridge_ribbon"), 1)

func test_fairy_bridge_secret_is_once_only() -> void:
	var h := _host()
	h.choices = [0, 0]
	h.battle_results = [{"result": "caught"}]
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	await _run(h, "douglas", "fairy_bridge", "fairy_bridge")
	assert_eq(h.legends.size(), 1)
	assert_eq(_bag(h, "fairy_bridge_ribbon"), 1)

func test_keepsakes_are_key_items() -> void:
	var items := ItemDB.load_default()
	for id in ["brodgar_pebble", "fairy_bridge_ribbon", "fieldbook_diploma"]:
		assert_true(items.has(id), id)
		assert_eq(str(items.get_item(id).kind), "key", id)

# ---------------------------------------------------------------- Fieldbook diploma

func test_garside_counts_the_fieldbook_before_200() -> void:
	var h := _host()
	var ids: Array = h.dex.ids()
	assert_eq(ids.size(), 200)
	for i in 199:
		h.data.mark_caught(ids[i])
	h.choices = [0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(_bag(h, "fieldbook_diploma"), 0)
	assert_true(_said_has(h, "199 caught of 200"))
	assert_true(_said_has(h, "1 still out there"))

func test_garside_awards_the_diploma_at_200_once() -> void:
	var h := _host()
	for id in h.dex.ids():
		h.data.mark_caught(id)
	h.choices = [0, 0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(_bag(h, "fieldbook_diploma"), 1)
	assert_true(_said_has(h, "I'm so proud of you"))
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(_bag(h, "fieldbook_diploma"), 1, "one diploma")
	assert_true(_said_has(h, "framed on the wall"))

func test_seen_but_not_caught_does_not_count() -> void:
	var h := _host()
	for id in h.dex.ids():
		h.data.mark_seen(id)
	h.choices = [0]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(_bag(h, "fieldbook_diploma"), 0)

# ---------------------------------------------------------------- the new commands

func test_daily_command_and_when_conditions() -> void:
	var h := FakeStoryHost.new()
	var script := [{"do": "daily", "key": "d", "then": [{"do": "say", "text": "first"}], "else": [{"do": "say", "text": "again"}]}]
	await Commands.new(h).run(script)
	await Commands.new(h).run(script)
	h.data.day_count = 5
	await Commands.new(h).run(script)
	assert_eq(h.texts(), ["first", "again", "first"])
	assert_eq(h.data.flag("d"), 5)
	h.data.clock_minutes = 22 * 60
	var night := [{"do": "when", "cond": "night", "then": [{"do": "say", "text": "dark"}], "else": [{"do": "say", "text": "light"}]}]
	h.said.clear()
	await Commands.new(h).run(night)
	h.data.clock_minutes = 9 * 60
	await Commands.new(h).run(night)
	assert_eq(h.texts(), ["dark", "light"])

func test_day_count_round_trips_through_saves() -> void:
	var s := GameStateData.new()
	s.day_count = 7
	var back := GameStateData.from_dict(s.to_dict(), Fixtures.dex())
	assert_eq(back.day_count, 7)
