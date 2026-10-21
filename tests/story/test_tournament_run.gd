extends TestCase
## The `tournament` story command (story/tournament_run.gd): entering a County Show, the Open Moot, the rosette stall.

class RecHost extends FakeStoryHost:
	var fights: Array = []   # [trainer id, foe levels, opts]
	var party_seen: Array = []  # what data.party held during each battle
	var saved: Array = []  # what a save written mid-bout would hold for the party

	func battle(foe_party: Array, opts: Dictionary) -> Dictionary:
		fights.append([str(opts.trainer.id), foe_party.map(func(c): return c.level), opts])
		party_seen.append(data.party.duplicate())
		saved.append(data.to_dict().party)
		return super.battle(foe_party, opts)

func _host(badges := 2) -> RecHost:
	var h := RecHost.new()
	h.dex = Dex.load_default()
	h.moves = MoveDB.load_default()
	for i in badges:
		h.data.badges.append("b%d" % i)
	h.data.money = 1000
	h.data.set_flag("visited_macclesfield", true)
	h.zone = "macclesfield"
	return h

func _give(h: RecHost, id: String, lvl: int) -> Creature:
	var c := Creature.create(h.dex.get_species(id), lvl, Rng.new(3), h.moves)
	h.data.party.append(c)
	return c

func _run(h: RecHost, id: String) -> void:
	await Commands.new(h, "npc").run([{"do": "tournament", "id": id}])

func _rosettes(h: RecHost) -> int:
	return Bag.new(h.data.bag).count(Tournament.ROSETTE)

func test_not_before_two_badges() -> void:
	var h := _host(1)
	_give(h, "pipkin", 10)
	h.choices = [0]
	await _run(h, "show")
	assert_eq(h.fights.size(), 0)
	assert_eq(h.data.money, 1000)

func test_winning_a_show_pays_a_red_rosette_and_leaves_the_team_untouched() -> void:
	var h := _host()
	var a := _give(h, "pipkin", 40)
	var b := _give(h, "kindlet", 12)
	var before_xp := a.xp
	h.choices = [0]
	await _run(h, "show")
	assert_eq(h.fights.size(), 3, "three rounds")
	assert_eq(h.data.money, 1000 - Tournament.FEE, "the entry fee")
	var cap := Tournament.level_cap(2, false)
	for f in h.fights:
		for lvl in f[1]:
			assert_true(lvl <= cap, "foes never past the cap")
		assert_true(bool(f[2].get("exhibition", false)), "no XP at a show")
	for p in h.party_seen:
		for c in p:
			assert_true(c.level <= cap, "entrants fight at the class cap")
			assert_false(c == a or c == b, "exhibition copies, not the real team")
	assert_eq(h.data.party, [a, b], "the real team is back")
	assert_eq(a.level, 40)
	assert_eq(a.xp, before_xp)
	assert_eq(_rosettes(h), 3, "a red rosette is three")
	assert_eq(Tournament.shows_won(h.data), 1)

func test_losing_a_show_round_is_no_whiteout_and_pays_by_placement() -> void:
	var h := _host()
	var a := _give(h, "pipkin", 20)
	h.choices = [0]
	h.battle_results = [{"result": "win"}, {"result": "lose"}]
	await _run(h, "show")
	assert_eq(h.fights.size(), 2)
	assert_eq(h.warps.size(), 0, "no trip back to the Sanctuary")
	assert_has(h.log, ["fade", false], "the screen comes back up after the loss (no whiteout warp to do it)")
	assert_eq(h.data.money, 1000 - Tournament.FEE, "no money lost beyond the fee")
	assert_eq(_rosettes(h), 1, "out in the semi: a yellow")
	assert_eq(h.data.party, [a])

func test_declining_costs_nothing() -> void:
	var h := _host()
	_give(h, "pipkin", 20)
	h.choices = [1]
	await _run(h, "show")
	assert_eq(h.fights.size(), 0)
	assert_eq(h.data.money, 1000)

func test_no_show_here_today_points_you_on() -> void:
	var h := _host()
	_give(h, "pipkin", 20)
	h.zone = "york"
	await _run(h, "show")
	assert_eq(h.fights.size(), 0)
	assert_true(h.texts().any(func(t): return String(t).contains("Cheshire")), "says where the show is")

func test_the_open_moot_needs_the_champion_and_runs_five() -> void:
	var h := _host(10)
	_give(h, "pipkin", 60)
	_give(h, "kindlet", 60)
	_give(h, "spikkin", 60)
	h.choices = [0]
	await _run(h, "moot")
	assert_eq(h.fights.size(), 0, "not before the Champion")
	h.data.set_flag("champion", true)
	h.choices = [0]
	await _run(h, "moot")
	assert_eq(h.fights.size(), 5)
	assert_eq(Tournament.streak(h.data), 5)
	assert_eq(Tournament.moot_wins(h.data), 1)
	assert_eq(_rosettes(h), Tournament.MOOT_ROSETTES)

func test_losing_the_moot_ends_the_streak_but_keeps_the_best() -> void:
	var h := _host(10)
	h.data.set_flag("champion", true)
	_give(h, "pipkin", 60)
	_give(h, "kindlet", 60)
	h.choices = [0]
	h.battle_results = [{"result": "win"}, {"result": "win"}, {"result": "lose"}]
	await _run(h, "moot")
	assert_eq(h.fights.size(), 3)
	assert_eq(Tournament.streak(h.data), 0)
	assert_eq(Tournament.best_streak(h.data), 2)
	assert_eq(_rosettes(h), 0)
	assert_eq(h.warps.size(), 0)

func test_three_moot_wins_make_a_moot_champion() -> void:
	var h := _host(10)
	h.data.set_flag("champion", true)
	_give(h, "pipkin", 60)
	_give(h, "kindlet", 60)
	for i in 3:
		h.choices = [0]
		await _run(h, "moot")
	assert_true(Tournament.moot_champion(h.data))
	assert_true(h.texts().any(func(t): return String(t).contains("Moot Champion")))

func test_the_stall_trades_rosettes() -> void:
	var h := _host()
	Bag.new(h.data.bag).add(Tournament.ROSETTE, 20)
	var wares := Tournament.wares(Calendar.today_key(), h.data)
	h.choices = [0]  # buy the first, then "Nothing, ta" (the default last option)
	await _run(h, "trade")
	assert_eq(_rosettes(h), 20 - int(wares[0].cost))

func test_a_save_mid_show_keeps_the_real_team() -> void:
	var h := _host()
	var a := _give(h, "pipkin", 40)
	var b := _give(h, "kindlet", 12)
	h.choices = [0]
	await _run(h, "show")
	assert_true(h.saved.size() > 0)
	for party in h.saved:
		assert_eq(party.size(), 2, "the whole real team")
		assert_eq(int(party[0].level), 40, "the real level, not the class cap")
		assert_eq(party[0], a.to_dict())
		assert_eq(party[1], b.to_dict())
	assert_true(h.data.real_party.is_empty(), "nothing held back once the show is over")

# ---------------------------------------------------------------- the gentler classes

func _produce_host() -> RecHost:
	var h := _host(0)
	h.items = ItemDB.from_array([{"id": "marrow", "name": "Marrow", "kind": "produce", "price": 60}])
	h.data.bag = {"marrow": 2}
	h.data.money = 0
	return h

func test_menu_battling_class_is_the_old_flow() -> void:
	var h := _host(1)
	_give(h, "pipkin", 10)
	h.choices = [0, 0]
	await _run(h, "show_menu")
	assert_eq(h.fights.size(), 0, "under two badges the battling class turns you away, as before")

func test_produce_class_takes_the_item_and_pays_once_a_day() -> void:
	var h := _produce_host()
	h.choices = [1, 0]
	await _run(h, "show_menu")
	assert_eq(int(h.data.bag.get("marrow", 0)), 1, "one marrow went to the tea tent")
	assert_true(ShowClasses.entered_today(h.data, ShowClasses.PRODUCE))
	var after := int(h.data.bag.get("marrow", 0))
	h.choices = [1, 0]
	await _run(h, "show_menu")
	assert_eq(int(h.data.bag.get("marrow", 0)), after, "a second entry the same day is refused")
	assert_true(h.data.money <= ShowClasses.PRODUCE_PRIZE[0])

func test_produce_class_without_produce_explains() -> void:
	var h := _produce_host()
	h.data.bag = {}
	h.choices = [1]
	await _run(h, "show_menu")
	assert_eq(h.data.money, 0)
	assert_false(ShowClasses.entered_today(h.data, ShowClasses.PRODUCE))

func test_sheepdog_clean_sweep_wins_red() -> void:
	var h := _host(0)
	_give(h, "pipkin", 10)
	h.choices = [2, 0]
	await _run(h, "show_menu")
	assert_eq(h.data.money, 1000 + ShowClasses.DOG_PRIZE[0])
	assert_eq(ShowClasses.wins(h.data, ShowClasses.DOG), 1)
	assert_eq(TrainerStats.get_count(h.data, "sheepdog_trials"), 1)
	h.choices = [2, 0]
	await _run(h, "show_menu")
	assert_eq(h.data.money, 1000 + ShowClasses.DOG_PRIZE[0], "one run a day")

func test_sheepdog_needs_a_creature() -> void:
	var h := _host(0)
	h.choices = [2, 0]
	await _run(h, "show_menu")
	assert_false(ShowClasses.entered_today(h.data, ShowClasses.DOG))
