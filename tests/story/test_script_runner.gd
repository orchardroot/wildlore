extends TestCase

func _cmds(host: FakeStoryHost) -> Commands:
	return Commands.new(host)

func test_say_substitutes_names() -> void:
	var h := FakeStoryHost.new()
	h.data.player_name = "Alex"
	h.data.rival_name = "Kit"
	await _cmds(h).run([{"do": "say", "who": "{rival}", "text": "Oi, {player}!"}])
	assert_eq(h.said, [["Kit", "Oi, Alex!"]])

func test_choice_sets_flag_and_if_branches() -> void:
	var script := [
		{"do": "choice", "text": "Tea?", "options": ["Yes", "No"], "set": "tea"},
		{"do": "if", "flag": "tea", "eq": 0, "then": [{"do": "say", "text": "yes"}], "else": [{"do": "say", "text": "no"}]},
	]
	var h := FakeStoryHost.new()
	h.choices = [0]
	await _cmds(h).run(script)
	assert_eq(h.data.flag("tea"), 0)
	assert_eq(h.texts(), ["yes"])
	var h2 := FakeStoryHost.new()
	h2.choices = [1]
	await _cmds(h2).run(script)
	assert_eq(h2.texts(), ["no"])

func test_set_and_truthy_if() -> void:
	var h := FakeStoryHost.new()
	await _cmds(h).run([
		{"do": "set", "flag": "met"},
		{"do": "set", "flag": "count", "value": 3},
		{"do": "if", "flag": "met", "then": [{"do": "say", "text": "met"}]},
		{"do": "if", "flag": "never", "then": [{"do": "say", "text": "bad"}], "else": [{"do": "say", "text": "never"}]},
	])
	assert_eq(h.data.flag("met"), true)
	assert_eq(h.data.flag("count"), 3)
	assert_eq(h.texts(), ["met", "never"])

func test_nested_if() -> void:
	var script := [
		{"do": "if", "flag": "a", "then": [
			{"do": "if", "flag": "b", "then": [{"do": "say", "text": "a+b"}], "else": [{"do": "say", "text": "a only"}]},
		], "else": [{"do": "say", "text": "neither"}]},
		{"do": "say", "text": "done"},
	]
	var h := FakeStoryHost.new()
	h.data.set_flag("a")
	await _cmds(h).run(script)
	assert_eq(h.texts(), ["a only", "done"])
	var h2 := FakeStoryHost.new()
	h2.data.set_flag("a")
	h2.data.set_flag("b")
	await _cmds(h2).run(script)
	assert_eq(h2.texts(), ["a+b", "done"])
	var h3 := FakeStoryHost.new()
	await _cmds(h3).run(script)
	assert_eq(h3.texts(), ["neither", "done"])

func test_end_stops_everything() -> void:
	var h := FakeStoryHost.new()
	await _cmds(h).run([
		{"do": "say", "text": "one"},
		{"do": "if", "flag": "x", "eq": null, "then": [{"do": "end"}]},
		{"do": "say", "text": "two"},
	])
	assert_eq(h.texts(), ["one"])

func test_give_item_and_creature() -> void:
	var h := FakeStoryHost.new()
	await _cmds(h).run([
		{"do": "give_item", "item": "cup_of_tea", "n": 2},
		{"do": "give_creature", "species": "kindlet", "level": 5},
	])
	assert_eq(h.data.bag.get("cup_of_tea"), 2)
	assert_eq(h.data.party.size(), 1)
	assert_eq(h.data.party[0].species.id, "kindlet")
	assert_eq(h.data.party[0].level, 5)
	assert_true(h.data.caught.has("kindlet"))

func test_give_creature_overflows_to_ark() -> void:
	var h := FakeStoryHost.new()
	for i in 6:
		h.data.party.append(Fixtures.creature("kindlet", 3))
	await _cmds(h).run([{"do": "give_creature", "species": "spikkin", "level": 4}])
	assert_eq(h.data.party.size(), 6)
	assert_eq(h.data.ark.size(), 1)

func test_heal_sets_sanctuary_and_heals() -> void:
	var h := FakeStoryHost.new()
	var c := Fixtures.creature("kindlet", 5)
	c.take_damage(5)
	h.data.party = [c]
	h.zone = "macc_sanctuary"
	h.anchor = Vector2i(4, 5)
	await _cmds(h).run([{"do": "heal"}])
	assert_eq(c.hp, c.max_hp())
	assert_eq(h.data.last_sanctuary, {"zone": "macc_sanctuary", "pos": [4, 5]})

func test_battle_win_sets_flag_and_leaves_payout_to_the_battle() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 100
	h.data.party = [Fixtures.creature("kindlet", 10)]
	var cmds := _cmds(h)
	await cmds.run([{"do": "battle", "trainer": "testbed_tester"}, {"do": "say", "text": "after"}])
	assert_eq(h.data.flag("trainer_testbed_tester"), true)
	assert_eq(h.data.money, 100, "the battle scene pays prize money, not the script")
	assert_eq(h.last_battle.opts.kind, "trainer")
	assert_eq(h.last_battle.opts.ai, "trainer")
	assert_eq(h.last_battle.opts.trainer.id, "testbed_tester")
	assert_eq(h.last_battle.foes.size(), 2)
	assert_eq(h.last_battle.foes[0].species.id, "spikkin")
	assert_eq(h.last_battle.foes[1].moves.size(), 1, "fixed moves are used")
	assert_eq(h.last_battle.foes[1].moves[0].id, "scrap")
	assert_eq(h.said.size(), 2, "win line then the following command")
	assert_eq(h.said[0][0], "Dev Dougie")

func test_battle_lose_triggers_whiteout_path() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 101
	var c := Fixtures.creature("kindlet", 5)
	c.take_damage(4)
	h.data.party = [c]
	h.data.last_sanctuary = {"zone": "macclesfield", "pos": [3, 4]}
	h.battle_results = [{"result": "lose", "caught": null}]
	await _cmds(h).run([{"do": "battle", "trainer": "testbed_tester"}, {"do": "say", "text": "never shown"}])
	assert_false(h.data.flags.has("trainer_testbed_tester"), "trainer stays undefeated")
	assert_eq(h.data.money, 50, "lose half, rounded down")
	assert_eq(c.hp, c.max_hp())
	assert_eq(h.warps, [["macclesfield", 3, 4, "down"]])
	assert_false("never shown" in h.texts(), "script aborts after whiteout")
	assert_true(h.texts().any(func(t): return t.contains("Sanctuary")))

func test_whiteout_returns_to_sanctuary() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 9
	h.data.last_sanctuary = {"zone": "buxton", "pos": [-1, -1]}
	await _cmds(h).whiteout()
	assert_eq(h.warps, [["buxton", -1, -1, "down"]])
	assert_eq(h.data.money, 4)

func test_move_face_wait_warp_and_misc() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h, "garside").run([
		{"do": "face_player", "npc": "garside"},
		{"do": "move", "path": ["up", "left"]},
		{"do": "face", "npc": "kit", "dir": "down"},
		{"do": "wait", "seconds": 0.5},
		{"do": "fade_out"}, {"do": "music", "id": "m"}, {"do": "sfx", "id": "s"},
		{"do": "warp", "zone": "macclesfield", "x": 2, "y": 3, "facing": "up"},
		{"do": "fade_in"},
		{"do": "shop", "id": "buxton_corner_shop"},
		{"do": "badge", "id": "stone"},
	])
	assert_eq(h.log[0], ["face_player", "garside"])
	assert_eq(h.log[1], ["move", "garside", ["up", "left"]], "npc defaults to the script's owner")
	assert_eq(h.log[2], ["face", "kit", "down"])
	assert_eq(h.warps, [["macclesfield", 2, 3, "up"]])
	assert_has(h.log, ["menu", "shop:buxton_corner_shop"])
	assert_has(h.data.badges, "stone")

func test_starter_gives_the_chosen_creature() -> void:
	var h := FakeStoryHost.new()
	h.menu_results = {"starter": "holtling"}
	await _cmds(h).run([{"do": "starter"}])
	assert_eq(h.data.flag("starter"), "holtling")
	assert_eq(h.data.party.size(), 1)
	assert_eq(h.data.party[0].species.id, "holtling")
	assert_eq(h.data.party[0].level, 5)
	assert_true(h.data.caught.has("holtling"))

func test_whiteout_command() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 10
	h.data.last_sanctuary = {"zone": "buxton", "pos": [5, 6]}
	await _cmds(h).run([{"do": "whiteout"}, {"do": "say", "text": "after"}])
	assert_eq(h.warps, [["buxton", 5, 6, "down"]])
	assert_eq(h.data.money, 5)
	assert_false("after" in h.texts(), "whiteout ends the script")
