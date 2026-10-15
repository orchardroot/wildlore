extends TestCase
## Plan 6 story beats against the fake host: Garside's call south, Keeper Hester, the four last legends, the Moot
## gauntlet, the London gates, the Directors' reunions, Vane, the ending and credits, and the side quests.

## A fake host that remembers every trainer fought, in order, and what the flags said when the credits opened.
class RecHost extends FakeStoryHost:
	var fought: Array = []
	var game_complete_at_credits := false

	func battle(foe_party: Array, opts: Dictionary) -> Dictionary:
		if opts.has("trainer"):
			fought.append(str(opts.trainer.id))
		return super.battle(foe_party, opts)

	func open_menu(menu: String) -> Variant:
		if menu == "credits":
			game_complete_at_credits = data.flag("game_complete") == true
		return super.open_menu(menu)

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func _said_has(h: FakeStoryHost, needle: String) -> bool:
	for line in h.said:
		if String(line[1]).contains(needle):
			return true
	return false

func _npc(zone_id: String, npc_id: String) -> Dictionary:
	for n in ZoneData.load_id(zone_id).npcs:
		if n.get("id", "") == npc_id:
			return n
	return {}

func _bag(h: FakeStoryHost, item: String) -> int:
	return Bag.new(h.data.bag).count(item)

func _moot_host() -> RecHost:
	var h := RecHost.new()
	h.data.set_flag("kit8_done", true)
	h.choices = [0]
	return h

# ---------------------------------------------------------------- chapter 10

func test_aberdeen_call_reaches_v04_saves_once_and_the_end_card_is_gone() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("v04_complete", true)  # a v0.4 save that saw the old end card
	h.data.set_flag("ch9_done", true)
	await _run(h, "aberdeen", "abdn_postie", "abdn_postie")
	assert_eq(h.data.flag("ch10_started"), true)
	assert_true(_said_has(h, "York. The Spirit Stone. And then the Moot."))
	assert_true(_said_has(h, "Northumberland"), "the call points south")
	assert_false(_said_has(h, "End of Wildlore"))
	h.said.clear()
	await _run(h, "aberdeen", "abdn_postie", "abdn_postie")
	assert_false(_said_has(h, "York. The Spirit Stone"), "the call comes once")
	assert_eq(h.said.size(), 2)

func test_hester_gives_the_spirit_stone_the_token_and_garsides_call() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "york_minster_crypt", "keeper_hester", "keeper_hester")
	assert_true("spirit" in h.data.badges)
	assert_eq(h.data.flag("badge_spirit"), true)
	assert_eq(h.data.flag("ch10_spirit"), true)
	assert_eq(h.last_battle.opts.trainer.id, "keeper_hester")
	assert_eq(h.last_battle.opts.ai, "keeper")
	assert_eq(_bag(h, "moot_token"), 1)
	assert_true(_said_has(h, "All ten. The Moot will call you."))
	h.said.clear()
	await _run(h, "york_minster_crypt", "keeper_hester", "keeper_hester")
	assert_eq(h.data.badges.count("spirit"), 1)
	assert_eq(_bag(h, "moot_token"), 1, "one token")
	assert_eq(h.said.size(), 2, "afterwards only goodbyes")

func test_losing_to_hester_gives_nothing() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "york_minster_crypt", "keeper_hester", "keeper_hester")
	assert_false("spirit" in h.data.badges)
	assert_eq(_bag(h, "moot_token"), 0)
	assert_false(h.data.flag("ch10_spirit") == true)

func test_the_buxton_to_sheffield_gate_clears_with_the_spirit_stone() -> void:
	for id in ["sheffield_warden_1", "sheffield_warden_2", "sheffield_warden_3"]:
		assert_eq(str(_npc("buxton", id).hide_if), "badge_spirit")

# ---------------------------------------------------------------- legends

func _legend_case(zone: String, script: String, npc: String, species: String, level: int, music: String, gate: String) -> void:
	var h := FakeStoryHost.new()
	await _run(h, zone, script, npc)
	assert_true(h.last_battle.is_empty(), "%s: no battle before %s" % [species, gate])
	assert_true(h.texts().size() > 0, "%s: a scripted moment plays first" % species)
	h.data.set_flag(gate, true)
	await _run(h, zone, script, npc)
	assert_eq(h.last_battle.foes[0].species.id, species)
	assert_eq(h.last_battle.foes[0].level, level)
	assert_true(h.last_battle.opts.no_run)
	assert_eq(h.last_battle.opts.music, music)
	assert_false(h.data.flag("caught_" + species) == true, "knocked out is not caught")
	h.last_battle = {}
	h.battle_results = [{"result": "caught"}]
	await _run(h, zone, script, npc)
	assert_eq(h.data.flag("caught_" + species), true)
	h.last_battle = {}
	await _run(h, zone, script, npc)
	assert_eq(h.last_battle.size(), 0)
	# and the NPC hides itself once caught
	assert_eq(str(_npc(zone, npc).hide_if), "caught_" + species)

func test_lambton_only_after_the_spirit_stone_and_never_twice() -> void:
	await _legend_case("penshaw", "lambton", "lambton_spot", "lambton", 86, "legend", "badge_spirit")

func test_shuck_only_after_the_spirit_stone_and_never_twice() -> void:
	await _legend_case("whitby", "shuck", "shuck_spot", "shuck", 86, "legend_hound2", "badge_spirit")

func test_herne_only_after_the_moot_and_never_twice() -> void:
	await _legend_case("sherwood", "herne", "herne_spot", "herne", 90, "legend_green", "moot_won")

func test_bran_only_after_the_ending_and_never_twice() -> void:
	await _legend_case("london", "bran", "bran_spot", "bran", 92, "legend_crow", "game_complete")

func test_the_spirit_stone_alone_does_not_unlock_herne_or_bran() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_spirit", true)
	await _run(h, "sherwood", "herne", "herne_spot")
	await _run(h, "london", "bran", "bran_spot")
	assert_true(h.last_battle.is_empty())
	h.data.set_flag("moot_won", true)
	await _run(h, "london", "bran", "bran_spot")
	assert_true(h.last_battle.is_empty(), "Bran waits for the ending, not just the Moot")

func test_legend_talk_tiles_are_walkable_and_reachable() -> void:
	# [zone, x, y] the tile the player talks from
	for t in [["penshaw", 22, 13], ["whitby", 53, 17], ["sherwood", 50, 49], ["london", 70, 20]]:
		var z := ZoneData.load_id(t[0])
		var p := Vector2i(t[1], t[2])
		assert_true(z.walkable(p), "%s %s is walkable" % [t[0], p])
		assert_true(z.reachable(z.spawn, ZoneData.GATE_ABILITIES).has(p), "%s %s is reachable" % [t[0], p])

# ---------------------------------------------------------------- the Moot

func test_kit_8_picks_the_right_variant_and_fights_once() -> void:
	for st in ["spikkin", "holtling", "kindlet"]:
		var h := FakeStoryHost.new()
		h.data.set_flag("starter", st)
		await _run(h, "stonehenge", "kit_moot", "kit")
		assert_eq(h.last_battle.opts.trainer.id, "kit_8_vs_" + st)
		assert_eq(h.data.flag("trainer_kit_8_vs_" + st), true)
		assert_eq(h.data.flag("kit8_done"), true)
		h.last_battle = {}
		await _run(h, "stonehenge", "kit_moot", "kit")
		assert_true(h.last_battle.is_empty(), "Kit fights once")

func test_losing_to_kit_leaves_the_gate_shut_to_the_winds() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("starter", "kindlet")
	h.battle_results = [{"result": "lose"}]
	await _run(h, "stonehenge", "kit_moot", "kit")
	assert_false(h.data.flag("kit8_done") == true)

func test_the_winds_send_you_to_kit_first() -> void:
	var h := RecHost.new()
	h.choices = [0]
	await _run(h, "stonehenge", "moot_wind", "wind_aelwen")
	assert_true(h.fought.is_empty())
	assert_true(_said_has(h, "friend of yours at the gate"))

func test_the_moot_runs_one_gauntlet_in_order_and_crowns_the_champion() -> void:
	var h := _moot_host()
	await _run(h, "stonehenge", "moot_wind", "wind_wilf")
	assert_eq(h.fought, ["wind_aelwen", "wind_fergus", "wind_aoife", "wind_wilf", "champion_garside"])
	assert_eq(h.data.flag("moot_won"), true)
	assert_eq(h.data.flag("champion"), true)
	assert_eq(h.data.flag("ch12_moot"), true)
	assert_true(["music", "legend_crow"] in h.log, "Bran's Raven arrives")
	assert_true(_said_has(h, "Vane has taken the ten Wardstones"))
	assert_true(_said_has(h, "Fly"), "flight is explained")
	assert_true(_said_has(h, "Someone had to keep the old places safe"), "Garside's reveal comes from her intro")
	# talking again does not start another gauntlet
	h.fought.clear()
	h.said.clear()
	await _run(h, "stonehenge", "moot_wind", "wind_aoife")
	assert_true(h.fought.is_empty())
	assert_eq(h.said.size(), 1)

func test_the_centre_starts_the_same_gauntlet() -> void:
	var h := _moot_host()
	await _run(h, "stonehenge", "moot_centre", "champion_garside")
	assert_eq(h.fought, ["wind_aelwen", "wind_fergus", "wind_aoife", "wind_wilf", "champion_garside"])
	assert_eq(h.data.flag("moot_won"), true)
	assert_eq(h.data.flag("champion"), true)

func test_the_gauntlet_is_one_script_not_five() -> void:
	var n := 0
	for c in StoryData.script("stonehenge", "moot_wind"):
		n += JSON.stringify(c).count("\"gauntlet\"")
	assert_eq(n, 1)

func test_a_gauntlet_loss_leaves_the_moot_unwon() -> void:
	var h := _moot_host()
	h.battle_results = [{"result": "win"}, {"result": "win"}, {"result": "lose"}]
	await _run(h, "stonehenge", "moot_wind", "wind_aelwen")
	assert_eq(h.fought.size(), 3, "it stops at the lost fight")
	assert_false(h.data.flag("moot_won") == true)
	assert_false(h.data.flag("champion") == true)
	assert_eq(h.warps.back(), ["stonehenge", 30, 8, "down"], "back to the gate, next to Kit")
	assert_false(_said_has(h, "Vane has taken"))
	# and you can have another go from the first Wind
	var h2 := _moot_host()
	h2.data = h.data
	await _run(h2, "stonehenge", "moot_wind", "wind_aelwen")
	assert_eq(h2.fought[0], "wind_aelwen")
	assert_eq(h2.data.flag("moot_won"), true)

func test_not_ready_starts_nothing() -> void:
	var h := _moot_host()
	h.choices = [1]
	await _run(h, "stonehenge", "moot_wind", "wind_aelwen")
	assert_true(h.fought.is_empty())
	assert_false(h.data.flag("moot_won") == true)

func test_the_moot_exit_tile_is_walkable_by_the_gate() -> void:
	var z := ZoneData.load_id("stonehenge")
	assert_true(z.walkable(Vector2i(30, 8)))
	assert_eq(int(_npc("stonehenge", "kit").x), 28)

# ---------------------------------------------------------------- gates

func test_gates_hide_on_the_right_flags_and_keep_off_the_edge_rows() -> void:
	# [zone, npc id, x, y, hide_if]
	var gates := [
		["stonehenge", "moot_gate_a", 2, 9, "badge_spirit"], ["stonehenge", "moot_gate_b", 29, 9, "badge_spirit"],
		["stonehenge", "moot_gate_c", 30, 9, "badge_spirit"], ["stonehenge", "moot_gate_d", 31, 9, "badge_spirit"],
		["stonehenge", "moot_gate_e", 57, 9, "badge_spirit"],
		["london", "london_tower_gate", 37, 20, "moot_won"], ["london", "london_tube_gate", 24, 26, "moot_won"],
		["underground", "reunion_a", 14, 24, "trainer_reunion_pryce_ashcombe"],
		["underground", "reunion_b", 24, 8, "trainer_reunion_kerrigan_strachan"],
	]
	for g in gates:
		var n := _npc(g[0], g[1])
		assert_false(n.is_empty(), "%s exists" % g[1])
		assert_eq(int(n.x), g[2])
		assert_eq(int(n.y), g[3])
		assert_eq(str(n.hide_if), g[4])
		var z := ZoneData.load_id(g[0])
		assert_true(int(n.x) > 0 and int(n.x) < z.width - 1 and int(n.y) > 0 and int(n.y) < z.height - 1, "%s is inside the edge strip" % g[1])
		assert_false(StoryData.script(g[0], str(n.script)).is_empty(), "%s has a script" % g[1])

func test_the_london_tower_and_tube_are_gated_until_the_moot() -> void:
	var z := ZoneData.load_id("london")
	# each door can only be reached from the tile the Warden stands on
	for t in [[Vector2i(37, 19), Vector2i(37, 20)], [Vector2i(24, 25), Vector2i(24, 26)]]:
		var door: Vector2i = t[0]
		var gate: Vector2i = t[1]
		var warped := false
		for w in z.warps:
			if Vector2i(int(w.x), int(w.y)) == door:
				warped = true
		assert_true(warped, "a warp at %s" % door)
		var blocked := {gate: true}
		assert_false(z.reachable(z.spawn, ZoneData.GATE_ABILITIES, blocked).has(door), "%s is shut with the Warden in place" % door)
		assert_true(z.reachable(z.spawn, ZoneData.GATE_ABILITIES).has(door), "%s opens without him" % door)
	assert_eq(str(_npc("london", "london_tower_gate").hide_if), "moot_won")
	for s in ["gate_london_tower", "gate_london_tube"]:
		var h := FakeStoryHost.new()
		await _run(h, "london", s, "london_tower_gate")
		assert_true(_said_has(h, "Moot"), "%s points the way to the Moot" % s)
		assert_true(h.warps.is_empty() and h.last_battle.is_empty())

func test_the_moot_gate_is_shut_to_the_north_until_the_spirit_stone() -> void:
	var z := ZoneData.load_id("stonehenge")
	var blocked := {}
	for n in z.npcs:
		if str(n.get("hide_if", "")) == "badge_spirit":
			blocked[Vector2i(int(n.x), int(n.y))] = true
	assert_eq(blocked.size(), 5)
	var north := Vector2i(30, 0)
	assert_false(z.reachable(north, ZoneData.GATE_ABILITIES, blocked).has(Vector2i(30, 29)), "the circle is out of reach with the Wardens in place")
	assert_true(z.reachable(north, ZoneData.GATE_ABILITIES).has(Vector2i(30, 29)), "and open without them")
	var h := FakeStoryHost.new()
	await _run(h, "stonehenge", "gate_moot", "moot_gate_b")
	assert_true(_said_has(h, "York"))

func test_every_hide_flag_is_set_by_something_reachable_before_its_blocker() -> void:
	# badge_spirit: Hester (York, before Sheffield, Salisbury Plain and the Moot gate)
	var h := FakeStoryHost.new()
	await _run(h, "york_minster_crypt", "keeper_hester", "keeper_hester")
	assert_eq(h.data.flag("badge_spirit"), true)
	# moot_won: the gauntlet, inside the Moot (the London gates are further on)
	var m := _moot_host()
	await _run(m, "stonehenge", "moot_wind", "wind_wilf")
	assert_eq(m.data.flag("moot_won"), true)
	# the reunion flags: the battle command sets trainer_<id> itself
	var r := FakeStoryHost.new()
	await _run(r, "underground", "reunion_a", "reunion_a")
	await _run(r, "underground", "reunion_b", "reunion_b")
	assert_eq(r.data.flag("trainer_reunion_pryce_ashcombe"), true)
	assert_eq(r.data.flag("trainer_reunion_kerrigan_strachan"), true)
	assert_eq(r.warps[0], ["underground", 14, 25, "up"], "the zone reloads so the Directors are gone")
	assert_eq(r.warps[1], ["underground", 24, 9, "up"])

func test_the_directors_reunions_are_double_battles() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "underground", "reunion_a", "reunion_a")
	assert_eq(h.last_battle.opts.trainer.id, "reunion_pryce_ashcombe")
	assert_eq(h.last_battle.opts.get("double", false), true)
	await _run(h, "underground", "reunion_b", "reunion_b")
	assert_eq(h.last_battle.opts.trainer.id, "reunion_kerrigan_strachan")
	assert_eq(h.last_battle.opts.get("double", false), true)

func test_losing_a_reunion_leaves_the_director_in_place() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "underground", "reunion_a", "reunion_a")
	assert_false(h.data.flag("trainer_reunion_pryce_ashcombe") == true)

# ---------------------------------------------------------------- the finale and the ending

func test_vane_final_battle_then_the_wardstones_crack_and_the_credits_roll() -> void:
	var h := RecHost.new()
	await _run(h, "vane_tower_top", "vane_final", "vane")
	assert_eq(h.fought, ["vane_final"])
	assert_eq(h.last_battle.opts.ai, "keeper")
	assert_true(["music", "battle_final"] in h.log, "the final battle music plays")
	assert_eq(h.data.flag("trainer_vane_final"), true)
	assert_eq(h.data.flag("game_complete"), true)
	assert_true(h.game_complete_at_credits, "game_complete is set before the credits open")
	assert_true(_said_has(h, "The Wardstones crack."))
	for legend_name in ["Nessie", "Ddraig Goch", "Morrígan", "Cù-Sìth", "Manannán", "Green Man", "Lambton Worm", "Black Shuck", "Herne", "Bran's Raven"]:
		assert_true(_said_has(h, legend_name), "the montage names %s" % legend_name)
	assert_true(_said_has(h, "deposit"), "Vane is left grumbling about his deposit")
	assert_eq(h.warps.back(), ["macc_home", 4, 5, "up"], "home to Mum")
	var who := h.said.map(func(s): return s[0])
	assert_true("Mum" in who and h.data.rival_name in who and "Prof. Garside" in who, "Mum, Kit and Garside are all there")
	var music_i := h.log.find(["music", "ending"])
	var credits_i := h.log.find(["menu", "credits"])
	assert_true(music_i >= 0 and credits_i > music_i, "the ending music plays, then the credits")
	assert_eq(h.log.count(["menu", "credits"]), 1)
	assert_true(["fade", true] in h.log)

func test_losing_to_vane_plays_no_ending() -> void:
	var h := RecHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "vane_tower_top", "vane_final", "vane")
	assert_false(h.data.flag("game_complete") == true)
	assert_false(h.data.flag("trainer_vane_final") == true)
	assert_false(["menu", "credits"] in h.log)
	assert_false(_said_has(h, "The Wardstones crack."))

func test_vane_after_the_ending_just_grumbles_and_credits_play_once() -> void:
	var h := RecHost.new()
	h.data.set_flag("game_complete", true)
	await _run(h, "vane_tower_top", "vane_final", "vane")
	assert_true(h.fought.is_empty())
	assert_false(["menu", "credits"] in h.log)
	assert_true(h.texts().size() > 0)

func test_an_interrupted_ending_does_not_make_you_fight_vane_again() -> void:
	var h := RecHost.new()
	h.data.set_flag("trainer_vane_final", true)
	await _run(h, "vane_tower_top", "vane_final", "vane")
	assert_true(h.fought.is_empty())
	assert_eq(h.data.flag("game_complete"), true)

func test_mum_has_something_to_say_after_the_ending() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("game_complete", true)
	await _run(h, "macc_home", "mum", "mum")
	assert_true(_said_has(h, "kettle"))
	assert_eq(_bag(h, "cup_of_tea"), 0, "no free tea twice")

func test_no_story_script_is_still_a_placeholder() -> void:
	for t in [["york_minster_crypt", "keeper_hester"], ["penshaw", "lambton"], ["whitby", "shuck"], ["sherwood", "herne"],
			["stonehenge", "moot_wind"], ["stonehenge", "moot_centre"], ["stonehenge", "kit_moot"], ["london", "bran"],
			["underground", "reunion_a"], ["underground", "reunion_b"], ["vane_tower_top", "vane_final"]]:
		var s := JSON.stringify(StoryData.script(t[0], t[1]))
		assert_false(s.to_lower().contains("placeholder"), "%s/%s" % [t[0], t[1]])

# ---------------------------------------------------------------- side quests

func test_side_quests_pay_out_existing_items_once() -> void:
	var h := FakeStoryHost.new()
	# Whitby jet workshop
	h.choices = [1]
	await _run(h, "whitby", "wby_jeweller", "wby_jeweller")
	assert_eq(_bag(h, "whitby_jet"), 0, "not today")
	h.choices = [0]
	await _run(h, "whitby", "wby_jeweller", "wby_jeweller")
	assert_eq(_bag(h, "whitby_jet"), 1)
	await _run(h, "whitby", "wby_jeweller", "wby_jeweller")
	assert_eq(_bag(h, "whitby_jet"), 1, "only once")
	# Lake District Herdwick count: 8 on the map
	await _run(h, "lake_district", "ld_shepherd", "ld_shepherd")
	assert_eq(_bag(h, "kendal_mint_cake"), 0, "not before she asks")
	h.choices = [1]
	await _run(h, "lake_district", "ld_shepherd", "ld_shepherd")
	assert_eq(_bag(h, "kendal_mint_cake"), 0, "wrong count")
	h.choices = [2]
	await _run(h, "lake_district", "ld_shepherd", "ld_shepherd")
	assert_eq(_bag(h, "kendal_mint_cake"), 2)
	await _run(h, "lake_district", "ld_shepherd", "ld_shepherd")
	assert_eq(_bag(h, "kendal_mint_cake"), 2, "only once")
	# Sheffield steelworks tour
	h.choices = [1]
	await _run(h, "sheffield", "shf_steelman", "shf_steelman")
	assert_eq(_bag(h, "pork_pie"), 0, "another day")
	h.choices = [0]
	await _run(h, "sheffield", "shf_steelman", "shf_steelman")
	assert_eq(_bag(h, "pork_pie"), 2)
	await _run(h, "sheffield", "shf_steelman", "shf_steelman")
	assert_eq(_bag(h, "pork_pie"), 2, "only once")
	# Birmingham canal boat trip
	h.choices = [1]
	await _run(h, "birmingham", "brum_boater_chat", "brum_boater_chat")
	assert_eq(_bag(h, "flask_of_tea"), 0, "not today")
	h.choices = [0]
	await _run(h, "birmingham", "brum_boater_chat", "brum_boater_chat")
	assert_eq(_bag(h, "flask_of_tea"), 2)
	await _run(h, "birmingham", "brum_boater_chat", "brum_boater_chat")
	assert_eq(_bag(h, "flask_of_tea"), 2, "only once")

func test_herdwick_count_matches_the_map() -> void:
	var n := 0
	for npc in ZoneData.load_id("lake_district").npcs:
		if str(npc.get("sprite", "")) == "creature:herdwick":
			n += 1
	assert_eq(n, 8, "the shepherdess's right answer is Eight")

# ---------------------------------------------------------------- review fixes

func test_credits_autosave_with_game_complete_and_restore_zone_music() -> void:
	var h := RecHost.new()
	await _run(h, "vane_tower_top", "vane_final", "vane")
	assert_true(true in h.autosave_flags, "a save is made after the ending with game_complete")
	var ci := h.log.find(["menu", "credits"])
	assert_true(h.log.find(["zone_music"]) > ci, "zone music replays after the credits")

func test_trainer_music_field_wins() -> void:
	var h := FakeStoryHost.new()
	StoryData.clear_cache()
	await Commands.new(h).run([{"do": "battle", "trainer": "vane_final"}])
	assert_eq(AudioIds.battle_music(h.last_battle.opts), "battle_final")
	for id in ["wind_aelwen", "wind_fergus", "wind_aoife", "wind_wilf"]:
		assert_eq(StoryData.trainer(id).get("music"), "battle_moot", id)
	assert_eq(StoryData.trainer("champion_garside").get("music"), "battle_champion")

func test_moot_levels_rise() -> void:
	var tops := []
	for id in ["wind_aelwen", "wind_fergus", "wind_aoife", "wind_wilf", "champion_garside"]:
		var m := 0
		for p in StoryData.trainer(id).party:
			m = maxi(m, int(p.level))
		tops.append(m)
	assert_eq(tops, [86, 87, 88, 89, 91])

func test_gauntlet_bag_choice_loops_back() -> void:
	var h := FakeStoryHost.new()
	h.choices = [0, 0, 1]  # bag, bag, carry on
	await Commands.new(h).run([{"do": "gauntlet", "trainers": ["wind_aelwen", "wind_fergus"], "flag": "g"}])
	assert_eq(h.log.count(["menu", "bag"]), 2, "the bag reopens, then returns to the same choice")
	assert_eq(h.choices.size(), 0, "exactly three choices asked for one gap")
	assert_eq(h.data.flag("g"), true)
	# a single-trainer gauntlet has no gap, so never asks
	var h2 := FakeStoryHost.new()
	h2.choices = [0]
	await Commands.new(h2).run([{"do": "gauntlet", "trainers": ["wind_aelwen"], "flag": "g"}])
	assert_eq(h2.choices.size(), 1)
	assert_eq(h2.log.count(["menu", "bag"]), 0)

func test_gauntlet_prize_money_only_when_whole_gauntlet_won() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 1000
	h.battle_results = [{"result": "win"}, {"result": "lose"}]
	await Commands.new(h).run([{"do": "gauntlet", "trainers": ["wind_aelwen", "wind_fergus"], "flag": "g"}])
	assert_eq(h.last_battle.opts.trainer.get("money", 0), 0, "no prize is paid mid-gauntlet")
	assert_eq(h.data.money, 500, "a loss only halves what you had")
	var h2 := FakeStoryHost.new()
	h2.data.money = 0
	await Commands.new(h2).run([{"do": "gauntlet", "trainers": ["wind_aelwen", "wind_fergus"], "flag": "g"}])
	var want := int(StoryData.trainer("wind_aelwen").money) + int(StoryData.trainer("wind_fergus").money)
	assert_eq(h2.data.money, want, "the whole gauntlet pays out at the end")
