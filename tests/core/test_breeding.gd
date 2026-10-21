extends TestCase
## The breeding loop (core/breeding.gd): pairing rules, baskets that hatch by steps walked and the season, the log the
## Stud Book reads, the three conservation goals, and old saves with no breeding flags at all.

func _data(steps := 0) -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 40
	d.rng_seed = 777
	d.money = 5000
	d.stats = TrainerStats.sanitise({"steps": steps})
	d.badges.append("b0")
	d.badges.append("b1")
	return d

func _pair(line := "moolet", fond := true) -> Array:
	var sire := Fixtures.creature(line, 10)
	var dam := Fixtures.creature(line, 10)
	sire.sex = "m"
	dam.sex = "f"
	sire.genome = {}
	dam.genome = {}
	sire.genome = Genetics.derive(sire).genome
	dam.genome = Genetics.derive(dam).genome
	if fond:
		sire.friendship = 150
		dam.friendship = 150
	return [sire, dam]

func _start(d: GameStateData, p: Array, zone := "guiting_farm", season := "spring") -> Dictionary:
	return Breeding.start(d, p[0], p[1], zone, Fixtures.dex(), Fixtures.moves(), Rng.new(5), season)

func test_data_is_sound() -> void:
	assert_eq(Breeding.check(Fixtures.dex()), [])

func test_old_save_has_no_baskets() -> void:
	var d := _data()
	assert_eq(Breeding.baskets(d), [])
	assert_eq(Breeding.free_slot(d), 0)
	assert_eq(Breeding.ready(d), [])

func test_both_parents_must_be_fond() -> void:
	var p := _pair("moolet", false)
	var r := Breeding.check_pair(_data(), p[0], p[1], "guiting_farm", Fixtures.dex())
	assert_false(r.ok)
	assert_true(str(r.why) != "")

func test_a_fond_pair_of_the_same_line_may_breed() -> void:
	var p := _pair()
	var r := Breeding.check_pair(_data(), p[0], p[1], "guiting_farm", Fixtures.dex())
	assert_true(r.ok, str(r.why))
	assert_eq(r.kind, "same_line")

func test_two_males_are_refused_in_dots_words() -> void:
	var p := _pair()
	p[1].sex = "m"
	var r := Breeding.check_pair(_data(), p[0], p[1], "guiting_farm", Fixtures.dex())
	assert_false(r.ok)
	assert_true(str(r.why).length() > 10)

func test_fainted_parents_wait() -> void:
	var p := _pair()
	p[0].hp = 0
	assert_false(Breeding.check_pair(_data(), p[0], p[1], "guiting_farm", Fixtures.dex()).ok)

func test_one_pairing_per_farm_per_day() -> void:
	var d := _data()
	var p := _pair()
	assert_true(_start(d, p).ok)
	var q := _pair()
	var again := Breeding.check_pair(d, q[0], q[1], "guiting_farm", Fixtures.dex())
	assert_false(again.ok, "same farm, same day")
	d.day_count += 1
	assert_true(Breeding.check_pair(d, q[0], q[1], "guiting_farm", Fixtures.dex()).ok, "tomorrow is another day")

func test_three_baskets_at_once() -> void:
	var d := _data()
	for i in 3:
		d.day_count += 1
		assert_true(_start(d, _pair()).ok)
	d.day_count += 1
	var q := _pair()
	var r := Breeding.check_pair(d, q[0], q[1], "guiting_farm", Fixtures.dex())
	assert_false(r.ok)
	assert_eq(Breeding.baskets(d).size(), 3)
	assert_eq(Breeding.free_slot(d), -1)

func test_the_basket_is_walked_off_in_steps() -> void:
	var d := _data(10000)
	var r := _start(d, _pair())
	assert_true(r.ok)
	var kind: Dictionary = Genetics.genes().kindreds.beast
	assert_true(r.steps >= int(kind.steps[0]) and r.steps <= int(kind.steps[1]), "in season: the kindred's own range")
	assert_eq(Breeding.ready(d), [], "not a step walked yet")
	d.stats["steps"] = 10000 + int(r.steps) - 1
	assert_eq(Breeding.ready(d), [])
	d.stats["steps"] = 10000 + int(r.steps)
	assert_eq(Breeding.ready(d), [r.slot])
	assert_eq(Breeding.steps_left(d, r.slot), 0)

func test_out_of_season_costs_double_steps_and_a_heat_lamp() -> void:
	var a := _data()
	var b := _data()
	var in_season := _start(a, _pair(), "guiting_farm", "spring")
	var late := _start(b, _pair(), "guiting_farm", "autumn")
	assert_eq(late.steps, in_season.steps * 2)
	assert_eq(late.fee, Breeding.LAMP_FEE)
	assert_eq(in_season.fee, 0)
	assert_eq(b.money, 5000 - Breeding.LAMP_FEE)

func test_cannot_afford_the_lamp_means_no_basket() -> void:
	var d := _data()
	d.money = 3
	var r := _start(d, _pair(), "guiting_farm", "autumn")
	assert_false(r.ok)
	assert_eq(Breeding.baskets(d), [])

func test_hatching_makes_a_level_one_hatchling_with_the_basket_genome() -> void:
	var d := _data()
	var p := _pair()
	var r := _start(d, p)
	var basket: Dictionary = Breeding.baskets(d)[0]
	d.stats["steps"] = int(d.stats.steps) + int(r.steps)
	var c := Breeding.hatch(d, r.slot, Fixtures.dex(), Fixtures.moves())
	assert_true(c != null)
	assert_eq(c.level, 1)
	assert_eq(c.genome, basket.genome)
	assert_eq(c.species.id, "moolet", "a same-line pair hatches the line's first stage")
	assert_true(c.uid != 0 and c.uid != p[0].uid and c.uid != p[1].uid)
	assert_eq(Breeding.baskets(d), [], "the basket is empty again")
	assert_eq(c.hp, c.max_hp())

func test_hatching_early_gives_nothing() -> void:
	var d := _data()
	var r := _start(d, _pair())
	assert_true(Breeding.hatch(d, r.slot, Fixtures.dex(), Fixtures.moves()) == null)
	assert_eq(Breeding.baskets(d).size(), 1)

func test_hatchling_values_stay_in_the_inborn_ceiling() -> void:
	var d := _data()
	var p := _pair()
	for s in Rules.STATS:
		p[0].ivs[s] = 15
		p[1].ivs[s] = 15
	var r := _start(d, p)
	d.stats["steps"] = int(d.stats.steps) + int(r.steps)
	var c := Breeding.hatch(d, r.slot, Fixtures.dex(), Fixtures.moves())
	for s in Rules.STATS:
		assert_true(c.ivs[s] <= Rules.IV_MAX and c.ivs[s] >= 0)

func test_the_log_records_what_the_stud_book_needs() -> void:
	var d := _data()
	var p := _pair()
	var r := _start(d, p)
	d.stats["steps"] = int(d.stats.steps) + int(r.steps)
	var c := Breeding.hatch(d, r.slot, Fixtures.dex(), Fixtures.moves())
	var logs := Breeding.logs(d)
	assert_eq(logs.size(), 1)
	var e: Dictionary = logs[0]
	assert_eq(e.kind, "same_line")
	assert_eq(int(e.child_uid), c.uid)
	assert_eq(e.child.coat, Genetics.hand_key("coat", c.genome.coat))
	assert_true(e.sire.has("coat") and e.dam.has("mark"))

func test_uids_never_collide() -> void:
	var d := _data()
	var seen := {}
	for i in 50:
		var c := Fixtures.creature("moolet", 5)
		Breeding.ensure_uid(d, c)
		assert_true(c.uid != 0)
		assert_false(seen.has(c.uid))
		seen[c.uid] = true
	var c2 := Fixtures.creature("moolet", 5)
	c2.uid = 99
	Breeding.ensure_uid(d, c2)
	assert_eq(c2.uid, 99, "an identity, once given, stays")

func test_collect_puts_hatchlings_in_the_party_or_the_ark() -> void:
	var d := _data()
	var r := _start(d, _pair())
	d.stats["steps"] = int(d.stats.steps) + int(r.steps)
	var got := Breeding.collect(d, Fixtures.dex(), Fixtures.moves())
	assert_eq(got.size(), 1)
	assert_eq(got[0].where, "party")
	assert_eq(d.party.size(), 1)
	assert_true(d.caught.has("moolet"))

func test_heirloom_tricks_come_from_parents_and_the_line() -> void:
	var d := _data()
	var p := _pair()
	var r := _start(d, p)
	var basket: Dictionary = Breeding.baskets(d)[0]
	assert_true(basket.heirlooms.size() <= 2)
	var learnable: Array = Fixtures.dex().get_species("moolet").learnset.map(func(e): return e[1])
	for m in basket.heirlooms:
		assert_true(m in learnable)
		assert_true(p[0].has_move(m) or p[1].has_move(m))
	assert_true(r.ok)

# ---------------------------------------------------------------- conservation goals

func test_three_goals_with_real_lines() -> void:
	var ids := Breeding.goals().map(func(g): return str(g.id))
	assert_eq(ids, ["soay", "kerry", "wildcat"])

func _bred(d: GameStateData, line: String, sire_uid: int, dam_uid: int, kind := "same_line") -> Creature:
	var c := Fixtures.creature(line, 3)
	Breeding.ensure_uid(d, c)
	c.pedigree = {"sire": {"uid": sire_uid}, "dam": {"uid": dam_uid}}
	Breeding.log_hatch(d, c, sire_uid, dam_uid, kind)
	d.ark.append(c)
	return c

func test_goal_starts_unmet_and_counts_bred_creatures() -> void:
	var d := _data()
	assert_false(Breeding.goal_status(d, "soay").met)
	_bred(d, "loaghtan", 1, 2)
	var st := Breeding.goal_status(d, "soay")
	assert_eq(st.have, 1)
	assert_false(st.met)

func test_a_caught_creature_does_not_count_as_bred() -> void:
	var d := _data()
	for i in 4:
		d.ark.append(Fixtures.creature("loaghtan", 5))
	assert_eq(Breeding.goal_status(d, "soay").have, 0)

func test_soay_goal_wants_a_spread_not_one_family() -> void:
	var d := _data()
	for i in 4:
		_bred(d, "loaghtan", 1, 2)
	assert_false(Breeding.goal_status(d, "soay").met, "four from one pairing is one family, not a flock")
	var e := _data()
	_bred(e, "loaghtan", 1, 2)
	_bred(e, "loaghtan", 1, 2)
	_bred(e, "loaghtan", 3, 4)
	assert_false(Breeding.goal_status(e, "soay").met, "three is not four")
	_bred(e, "loaghtan", 5, 6)
	assert_true(Breeding.goal_status(e, "soay").met)

func test_kerry_goal_wants_two_unrelated_pairings() -> void:
	var d := _data()
	for i in 4:
		_bred(d, "moolet", 1, 2)
	assert_false(Breeding.goal_status(d, "kerry").met, "one pairing, however many young")
	_bred(d, "moolet", 7, 8)
	assert_true(Breeding.goal_status(d, "kerry").met)

func test_wildcat_goal_wants_pure_wildkit_not_hybrids() -> void:
	var d := _data()
	_bred(d, "wildkit", 1, 2)
	_bred(d, "wildkit", 1, 2)
	_bred(d, "wildkit", 3, 4, "hybrid")
	assert_false(Breeding.goal_status(d, "wildcat").met, "a hybrid is not a pure line")
	_bred(d, "wildkit", 3, 4)
	assert_true(Breeding.goal_status(d, "wildcat").met)

func test_claiming_pays_once_and_scales_with_badges() -> void:
	var d := _data()
	for i in 3:
		_bred(d, "wildkit", i * 2 + 1, i * 2 + 2)
	var before := d.money
	var r := Breeding.claim_goal(d, "wildcat")
	assert_true(r.ok)
	var paid := d.money - before
	assert_true(paid > 0)
	assert_eq(d.flag("breed_goal_wildcat"), true)
	assert_false(Breeding.claim_goal(d, "wildcat").ok, "once only")
	assert_eq(d.money - before, paid)
	var rich := _data()
	for i in 8:
		rich.badges.append("x%d" % i)
	for i in 3:
		_bred(rich, "wildkit", i * 2 + 1, i * 2 + 2)
	var before2 := rich.money
	Breeding.claim_goal(rich, "wildcat")
	assert_true(rich.money - before2 > paid, "the Trust's grant grows with how far you have got")

func test_claiming_when_unmet_pays_nothing() -> void:
	var d := _data()
	var before := d.money
	assert_false(Breeding.claim_goal(d, "kerry").ok)
	assert_eq(d.money, before)
