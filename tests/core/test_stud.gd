extends TestCase
## Shows, stud fees and the paddock (core/stud.gd, the Breed Class, data/deeds/paddock_wirral.json): the judging
## rewards stock bred to type, fees and the genotype test are sinks, standing at stud needs a win, and the stud farm
## strategy can't print money.

func _data(badges := 4) -> GameStateData:
	var d := GameStateData.new()
	d.money = 5000
	d.day_count = 10
	d.rng_seed = 99
	for i in badges:
		d.badges.append("b%d" % i)
	return d

func _mk(sex := "f", genome := {}, pedigree := {}) -> Creature:
	var c := Fixtures.creature("moolet", 10)
	c.sex = sex
	var g := {"coat": ["+", "+"], "tint": ["W", "W"], "mark": ["b", "b"], "knack": ["K", "K"], "ginger": ["o", "o"],
		"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"]}
	g.merge(genome, true)
	c.genome = g
	c.pedigree = pedigree
	return c

func test_a_bred_champion_outscores_a_plain_catch() -> void:
	var plain := _mk("f")
	var champ := _mk("f", {"coat": ["c", "c"], "tint": ["S", "S"], "mark": ["B", "B"], "frame1": ["+", "+"], "frame2": ["+", "+"],
		"frame3": ["+", "+"], "frame4": ["+", "+"]}, {"sire": {"uid": 2, "sire": {"uid": 4}, "dam": {"uid": 5}}, "dam": {"uid": 3, "sire": {"uid": 6}, "dam": {"uid": 7}}})
	var a := Stud.judge(plain, "s")
	var b := Stud.judge(champ, "s")
	assert_true(int(b.score) > int(a.score) + 40, "%s vs %s" % [b.score, a.score])
	assert_true(int(b.score) <= 100 and int(a.score) >= 0)
	assert_eq(Stud.judge(champ, "s").score, b.score, "the marks are seeded, a retry can't re-roll them")
	var rivals := ShowClasses.rivals("s")
	assert_true(ShowClasses.place(int(b.score), rivals) <= 2, "bred to type wins a rosette")

func test_the_breed_class_pays_and_tallies_like_the_others() -> void:
	var d := _data()
	var before := d.money
	var pr := ShowClasses.award(d, ShowClasses.BREED, 1, Wallet.GBP)
	assert_eq(int(pr.money), 40)
	assert_eq(d.money - before, 40)
	assert_eq(ShowClasses.wins(d, ShowClasses.BREED), 1)
	assert_true(ShowClasses.prize(ShowClasses.BREED, 4).is_empty())

func test_fees_are_a_sink_and_keyed_on_badges() -> void:
	var d := _data(0)
	var low := Stud.fee(d)
	var d10 := _data(10)
	assert_true(Stud.fee(d10) > low * 5)
	var before := d.money
	assert_true(Stud.pay_fee(d, low, Wallet.GBP))
	assert_eq(before - d.money, low)
	assert_eq(Stud.paid_on(d, d.day_count), low)
	d.money = 1
	assert_false(Stud.pay_fee(d, low, Wallet.GBP), "can't pay what you haven't got")
	assert_eq(Stud.paid_on(d, d.day_count), low, "and nothing was booked")

func test_standing_at_stud_needs_a_win_and_pays_under_the_fee() -> void:
	var d := _data()
	var sire := _mk("m")
	assert_true(Stud.stud_out_blocker(d, sire) != "", "no rosette, no engagements")
	assert_eq(Stud.stand_at_stud(d, sire, Wallet.GBP), 0)
	ShowClasses.award(d, ShowClasses.BREED, 1, Wallet.GBP)
	assert_eq(Stud.stud_out_blocker(d, sire), "")
	var got := Stud.stand_at_stud(d, sire, Wallet.GBP)
	assert_true(got > 0 and got < Stud.fee(d), "pays less than a stud fee costs")
	assert_eq(Stud.stand_at_stud(d, sire, Wallet.GBP), 0, "once a day")

func test_genotype_test_is_dear_early_cheap_late_and_once_only() -> void:
	assert_true(Stud.test_fee(_data(0)) > Stud.test_fee(_data(10)))
	assert_true(Stud.test_fee(_data(10)) >= Stud.TEST_FLOOR)
	var d := _data()
	var c := _mk("f")
	var before := d.money
	assert_eq(Stud.genotype_test(d, c, Wallet.GBP), "")
	assert_eq(before - d.money, Stud.test_fee(d))
	assert_true(Stud.tested(d, c) and c.uid != 0)
	assert_true(Stud.genotype_test(d, c, Wallet.GBP) != "", "already read")
	assert_eq(before - d.money, Stud.test_fee(d), "not charged twice")
	var broke := _data()
	broke.money = 0
	assert_true(Stud.genotype_test(broke, _mk("m"), Wallet.GBP) != "")

func test_uids_are_handed_out_once_and_never_collide() -> void:
	var d := _data()
	var a := _mk("f")
	var b := _mk("f")
	var ua := Stud.ensure_uid(d, a)
	assert_eq(Stud.ensure_uid(d, a), ua, "stable")
	assert_true(Stud.ensure_uid(d, b) != ua)

func test_the_stud_farm_cannot_print_money() -> void:
	for badges in [0, 4, 10]:
		var r30 := Stud.stud_farm(badges, 30)
		var r90 := Stud.stud_farm(badges, 90)
		var main := Stud.main_line(90)
		assert_true(r90.net < 1.5 * main * 90, "net %s over 90 days at %d badges vs main line" % [r90.net, badges])
		assert_true(r90.per_day <= maxf(r30.per_day, 0.0) + 0.5, "it never compounds: %s vs %s a day" % [r90.per_day, r30.per_day])
		assert_true(r90.gross < r90.fees + 1.5 * main * 90, "gross is bounded by what it costs")

func test_the_paddock_deed_follows_the_contract() -> void:
	var d := Deeds.get_deed("paddock_wirral")
	assert_eq(str(d.kind), "paddock")
	var town = JsonUtil.read("res://data/zones/%s.json" % d.zone)
	assert_eq(str(town.rows[int(d.door.y)][int(d.door.x)]), "D")
	var warped := false
	for w in town.warps:
		if int(w.x) == int(d.door.x) and int(w.y) == int(d.door.y) and str(w.to) == str(d.interior):
			warped = true
	assert_true(warped)
	var room = JsonUtil.read("res://data/zones/%s.json" % d.interior)
	assert_eq(str(room.warps[0].to), str(d.zone))
	var lines = JsonUtil.read("res://data/dialogue/%s.json" % d.interior).get("wirral_paddock_keeper", [])
	var has := false
	for c in lines:
		if str(c.get("do")) == "deed" and str(c.id) == "paddock_wirral":
			has = true
	assert_true(has, "the counter opens the Deed screen")
	var ids := []
	for e in d.events:
		ids.append(str(e.id))
	for want in ["fox", "visiting_judge", "heat_wave"]:
		assert_true(want in ids, want)
