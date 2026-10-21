extends TestCase
## Guilds (core/guilds.gd): ranks earned off existing counters, perks only for members, the Ramblers versus Heritage
## Trust choice, resigning at a cost (and being remembered), old saves, and that every hall desk is wired.

func _data(cash := 1000) -> GameStateData:
	var d := GameStateData.new()
	d.money = cash
	return d

func test_old_save_has_no_guilds() -> void:
	var d := _data()
	for id in Guilds.IDS:
		assert_false(Guilds.is_member(d, id))
		assert_eq(Guilds.rank(d, id), 0)
	assert_eq(Guilds.cast_bonus(d), 0)
	assert_eq(Guilds.sell_bonus(d), 0.0)
	assert_eq(Guilds.rates_mult(d), 1.0)

func test_ranks_are_earned_by_doing_but_perks_need_membership() -> void:
	var d := _data()
	TrainerStats.add(d, "fish_caught", 40)
	assert_eq(Guilds.earned(d, "anglers"), 2)
	assert_eq(Guilds.cast_bonus(d), 0, "not a member yet")
	assert_eq(Guilds.join(d, "anglers"), "")
	assert_eq(Guilds.cast_bonus(d), 4)
	assert_eq(Guilds.rank_title(d, "anglers"), "Regular on the Bank")
	assert_true(Guilds.to_next(d, "anglers") > 0)

func test_perks_wired_into_systems() -> void:
	var d := _data()
	TrainerStats.add(d, "fish_caught", 8)
	Guilds.join(d, "anglers")
	assert_eq(Fishing.casts_left(d), Fishing.daily_casts() + 2)
	Fishing.spend_cast(d)
	assert_eq(Fishing.casts_left(d), Fishing.daily_casts() + 1)
	TrainerStats.add(d, "goods_sold", 2500)
	Guilds.join(d, "traders")
	assert_true(Trades.sell_mult(d) > 1.0 and Trades.sell_mult(d) < 1.1)
	assert_eq(Guilds.carry_bonus(d), 20)
	assert_eq(Trades.repel_steps(d, 100), 100, "no Rambler membership")
	d.money += 0
	TrainerStats.add(d, "darts_won", 3)
	Guilds.join(d, "folk")
	var before := Standing.points(d, "england")
	Standing.add(d, "england", 2)
	assert_eq(Standing.points(d, "england") - before, 3, "a good turn earns the Folk Club's extra point")
	Standing.add(d, "england", 1)
	assert_eq(Standing.points(d, "england") - before, 4, "single points are not topped up")

func test_ramblers_versus_trust_holds_the_top_rank() -> void:
	var d := _data()
	var all := Gazetteer.all()
	for i in 60:
		d.set_flag(Gazetteer.flag_key(str(all[i].id)), true)
	assert_eq(Guilds.earned(d, "ramblers"), 3)
	Guilds.join(d, "ramblers")
	assert_eq(Guilds.rank(d, "ramblers"), 3)
	Guilds.join(d, "trust")
	assert_eq(Guilds.blocked_by(d, "ramblers"), "trust")
	assert_eq(Guilds.rank(d, "ramblers"), 2, "the Trust holds the top rank back")
	assert_eq(Guilds.resign(d, "trust"), "")
	assert_eq(Guilds.rank(d, "ramblers"), 3, "reversible")

func test_resigning_costs_and_they_remember() -> void:
	var d := _data(150)
	assert_eq(Guilds.join(d, "folk"), "", "free the first time")
	assert_eq(d.money, 150)
	assert_eq(Guilds.resign(d, "folk"), "")
	assert_eq(d.money, 150 - Guilds.RESIGN_FEE)
	assert_eq(Guilds.join_fee(d, "folk"), Guilds.REJOIN_FEE)
	assert_eq(Guilds.join(d, "folk"), "")
	assert_eq(d.money, 0)
	assert_true(Guilds.resign(d, "folk") != "", "can't afford to leave")
	assert_true(Guilds.is_member(d, "folk"))

func test_every_guild_has_a_hall_desk() -> void:
	for id in Guilds.IDS:
		assert_eq(Guilds.RANKS[id].size(), 3)
		assert_eq(Guilds.PERKS[id].size(), 3)
		var z = JsonUtil.read("res://data/zones/%s.json" % Guilds.HALLS[id])
		var found := false
		for n in z.npcs:
			found = found or n.get("script") == "guild_" + id
		assert_true(found, "desk in " + Guilds.HALLS[id])
		var dlg = JsonUtil.read("res://data/dialogue/%s.json" % Guilds.HALLS[id])
		assert_true(dlg.has("guild_" + id))
		for line in dlg["guild_" + id]:
			assert_false(str(line.get("text", "")).contains("—"))
