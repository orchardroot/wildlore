extends TestCase

const FIX := [
	{"id": "j_catch", "nation": "england", "town": "macclesfield", "badges": 0, "poster": "Mrs A", "title": "Catch a croakle",
		"text": "t", "step": {"type": "catch", "species": "croakle"}, "pay": 1},
	{"id": "j_type", "nation": "england", "town": "", "badges": 0, "poster": "Mr B", "title": "Any bog", "text": "t",
		"step": {"type": "catch", "ctype": "bog", "n": 2}, "pay": 2, "reward": {"items": {"sloes": 2}}},
	{"id": "j_bring", "nation": "england", "town": "macclesfield", "badges": 0, "poster": "C", "title": "Jam", "text": "t",
		"step": {"type": "bring", "item": "blackberries", "n": 3}, "pay": 1, "reward": {"recipe": "parkin"}},
	{"id": "j_show", "nation": "england", "town": "", "badges": 1, "poster": "D", "title": "Show", "text": "t",
		"step": {"type": "show", "ctype": "brook"}, "pay": 2},
	{"id": "j_beat", "nation": "england", "town": "", "badges": 0, "poster": "E", "title": "Beat", "text": "t",
		"step": {"type": "beat", "zone": "macc_forest", "n": 2}, "pay": 1},
	{"id": "j_visit", "nation": "england", "town": "", "badges": 0, "poster": "F", "title": "Bats", "text": "t",
		"step": {"type": "visit", "zone": "macclesfield", "time": ["night"], "weather": "rain"}, "pay": 1},
	{"id": "j_forage", "nation": "england", "town": "", "badges": 0, "poster": "G", "title": "Pick", "text": "t",
		"step": {"type": "forage", "zone": "macc_forest", "n": 2}, "pay": 1},
	{"id": "j_wales", "nation": "wales", "town": "", "badges": 0, "poster": "H", "title": "Welsh", "text": "t",
		"step": {"type": "catch", "ctype": "stone"}, "pay": 3, "reward": {"standing": 9}},
	{"id": "j_late", "nation": "england", "town": "", "badges": 8, "poster": "I", "title": "Late", "text": "t",
		"step": {"type": "catch", "ctype": "fae"}, "pay": 3},
]

func _data() -> GameStateData:
	Jobs.use(FIX)
	Calendar.set_override("2026-10-18")
	var d := GameStateData.new()
	d.rng_seed = 7
	return d

func _done() -> void:
	Jobs.reset()
	Calendar.set_override("")

func test_offers_are_local_badge_gated_and_stable() -> void:
	var d := _data()
	var offers := Jobs.offers(d, "macclesfield")
	assert_true(offers.size() >= 2 and offers.size() <= 3, "2 or 3 offers")
	for j in offers:
		assert_eq(j.nation, "england")
		assert_true(str(j.id) != "j_late" and str(j.id) != "j_show", "badge-gated jobs stay off the board")
	var ids := offers.map(func(j): return j.id)
	assert_eq(Jobs.offers(d, "macclesfield").map(func(j): return j.id), ids, "same board all day")
	for j in Jobs.offers(d, "llanberis"):
		assert_eq(j.nation, "wales")
	assert_has(ids, "j_catch", "this town's own jobs come first")
	_done()

func test_board_refreshes_on_a_new_real_day() -> void:
	var d := _data()
	var e := Jobs.epoch(d)
	assert_eq(Jobs.epoch(d), e)
	Calendar.set_override("2026-10-19")
	assert_eq(Jobs.epoch(d), e + 1)
	assert_eq(Jobs.epoch(d), e + 1)
	_done()

func test_accept_up_to_three() -> void:
	var d := _data()
	assert_eq(Jobs.accept(d, "j_catch", "macclesfield"), "")
	assert_true(Jobs.accept(d, "j_catch", "macclesfield") != "", "not twice")
	assert_eq(Jobs.accept(d, "j_type", "macclesfield"), "")
	assert_eq(Jobs.accept(d, "j_bring", "macclesfield"), "")
	assert_true(Jobs.accept(d, "j_beat", "macclesfield") != "", "only three at once")
	assert_eq(Jobs.active(d).size(), 3)
	assert_true(d.flag("job_1") is Dictionary)
	Jobs.abandon(d, 1)
	assert_eq(Jobs.active(d).size(), 2)
	assert_eq(Jobs.accept(d, "j_beat", "macclesfield"), "")
	_done()

func test_catch_progress_and_auto_complete() -> void:
	var d := _data()
	Jobs.accept(d, "j_type", "macclesfield")
	Jobs.accept(d, "j_catch", "macclesfield")
	var dex := Fixtures.dex()
	assert_eq(Jobs.note_catch(d, "pipkin", dex), [])  # not brook, not a croakle
	var ready := Jobs.note_catch(d, "croakle", dex)  # croakle is bog-type: both jobs move
	assert_has(ready, 2)
	assert_eq(Jobs.slot(d, 1).n, 1)
	ready = Jobs.note_catch(d, "croakle", dex)
	assert_has(ready, 1)
	var money := d.money
	var res := Jobs.complete(d, 1, ItemDB.load_default())
	assert_eq(int(res.money), Jobs.money_for(Jobs.get_job("j_type"), 0))
	assert_eq(d.money, money + int(res.money))
	assert_eq(Bag.new(d.bag).count("sloes"), 2)
	assert_eq(Standing.points(d, "england"), 3)
	assert_eq(Jobs.slot(d, 1), {})
	assert_true(Jobs.done_today(d, "j_type"))
	_done()

func test_bring_needs_the_goods_and_takes_them() -> void:
	var d := _data()
	Jobs.accept(d, "j_bring", "macclesfield")
	assert_false(Jobs.is_ready(d, 1, Fixtures.dex()))
	Bag.new(d.bag).add("blackberries", 4)
	assert_true(Jobs.is_ready(d, 1, Fixtures.dex()))
	var res := Jobs.complete(d, 1, ItemDB.load_default())
	assert_eq(Bag.new(d.bag).count("blackberries"), 1)
	assert_true(Crafting.is_known(d, "parkin"))
	assert_true(str(res.recipe) != "")
	_done()

func test_show_scales_level_with_badges() -> void:
	var d := _data()
	d.badges = ["brook", "urban"]
	Jobs.accept(d, "j_show", "macclesfield")
	var lvl := int(Jobs.slot(d, 1).lvl)
	assert_eq(lvl, Jobs.show_level(2))
	d.party = [Fixtures.creature("dipling", lvl - 1)]
	assert_false(Jobs.is_ready(d, 1, Fixtures.dex()))
	d.party = [Fixtures.creature("dipling", lvl)]
	assert_true(Jobs.is_ready(d, 1, Fixtures.dex()))
	assert_true(Jobs.show_level(10) <= 75, "never asks for absurd levels")
	assert_true(Jobs.show_level(0) <= 8)
	_done()

func test_beat_forage_and_visit() -> void:
	var d := _data()
	Jobs.accept(d, "j_beat", "macclesfield")
	Jobs.accept(d, "j_forage", "macclesfield")
	Jobs.accept(d, "j_visit", "macclesfield")
	Jobs.note_win(d, "goyt_valley")
	assert_eq(Jobs.slot(d, 1).n, 0)
	assert_eq(Jobs.note_win(d, "macc_forest"), [])
	assert_eq(Jobs.note_win(d, "macc_forest"), [1])
	Jobs.note_forage(d, "macc_forest")
	Jobs.note_forage(d, "macc_forest")
	assert_true(Jobs.is_ready(d, 2, Fixtures.dex()))
	assert_eq(Jobs.note_visit(d, "macclesfield", "day", "drizzle"), [])
	assert_eq(Jobs.note_visit(d, "macclesfield", "night", "clear"), [])
	assert_eq(Jobs.note_visit(d, "macclesfield", "night", "downpour"), [3])
	assert_eq(Jobs.auto_ready(d, Fixtures.dex()), [1], "beat completes by itself; forage and visit go back to a board")
	var got := Jobs.hand_in(d, "england", ItemDB.load_default(), Fixtures.dex())
	assert_eq(got.size(), 3)
	assert_eq(Jobs.active(d).size(), 0)
	_done()

func test_hand_in_only_in_the_jobs_nation() -> void:
	var d := _data()
	Jobs.accept(d, "j_wales", "llanberis")
	Jobs.note_catch(d, "slatelet", Fixtures.dex())
	assert_eq(Jobs.hand_in(d, "england", ItemDB.load_default(), Fixtures.dex()).size(), 0)
	var res: Array = Jobs.hand_in(d, "wales", ItemDB.load_default(), Fixtures.dex())
	assert_eq(res.size(), 1)
	assert_eq(Standing.points(d, "wales"), 9)
	assert_eq(str(res[0].tier_line), "")
	_done()

func test_done_jobs_leave_the_board_until_tomorrow() -> void:
	var d := _data()
	Jobs.accept(d, "j_catch", "macclesfield")
	Jobs.note_catch(d, "croakle", Fixtures.dex())
	Jobs.complete(d, 1, ItemDB.load_default())
	assert_true(Jobs.accept(d, "j_catch", "macclesfield") != "", "done today")
	Calendar.set_override("2026-10-19")
	assert_eq(Jobs.accept(d, "j_catch", "macclesfield"), "")
	_done()

func test_money_scales_with_progress() -> void:
	var j := {"pay": 2}
	assert_true(Jobs.money_for(j, 8) > Jobs.money_for(j, 0) * 3)
	assert_true(Jobs.money_for({"pay": 3}, 10) <= 4000)

func test_landlord_parcel_at_local_once_a_day() -> void:
	var d := _data()
	assert_eq(Jobs.landlord_parcel(d, "wales"), "")
	Standing.add(d, "wales", 60)
	assert_eq(Jobs.landlord_parcel(d, "wales"), "bara_brith")
	assert_eq(Jobs.landlord_parcel(d, "wales"), "")
	Calendar.set_override("2026-10-19")
	assert_eq(Jobs.landlord_parcel(d, "wales"), "bara_brith")
	_done()

func test_old_save_has_no_jobs() -> void:
	var back := GameStateData.from_dict({"player_name": "Sam"}, Fixtures.dex())
	assert_eq(Jobs.active(back), [])
	var d := _data()
	Jobs.accept(d, "j_beat", "macclesfield")
	Jobs.note_win(d, "macc_forest")
	back = GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(int(Jobs.slot(back, 1).n), 1)
	Jobs.note_win(back, "macc_forest")
	assert_eq(int(Jobs.slot(back, 1).n), 2)
	_done()

func test_real_jobs_validate() -> void:
	Jobs.reset()
	var errors := Jobs.validate(ItemDB.load_default(), Fixtures.dex(), ZoneData.load_all())
	for e in errors:
		fail(e)
	assert_true(Jobs.all().size() >= 85, "about 90 jobs")

func test_every_town_has_work_when_you_arrive() -> void:
	Jobs.reset()
	for town in MapLogic.real_towns():
		var nation := Standing.nation_for_zone(town)
		var d := GameStateData.new()
		for i in Jobs.ARRIVAL_BADGES[nation]:
			d.badges.append("b%d" % i)
		assert_true(Jobs.offers(d, town).size() >= 2, "%s has jobs on arrival" % town)
		var local := Jobs.all().filter(func(j): return str(j.get("town", "")) == town)
		assert_true(local.size() >= 1, "%s has a job of its own" % town)

func test_step_text_reads_well() -> void:
	Jobs.use(FIX)
	var items := ItemDB.load_default()
	var dex := Fixtures.dex()
	assert_eq(Jobs.step_text(Jobs.get_job("j_bring"), {}, items, dex), "Bring 3 Blackberries")
	assert_eq(Jobs.step_text(Jobs.get_job("j_type"), {}, items, dex), "Catch 2 Bog-type creatures")
	assert_eq(Jobs.step_text(Jobs.get_job("j_catch"), {}, items, dex), "Catch a Croakle")
	assert_eq(Jobs.step_text(Jobs.get_job("j_beat"), {}, items, dex), "Win 2 wild battles in Macclesfield Forest")
	assert_eq(Jobs.step_text(Jobs.get_job("j_show"), {"lvl": 20}, items, dex), "Show a Brook-type at level 20 or above")
	_done()

func test_board_says_why_a_job_wont_hand_in() -> void:
	var d := _data()
	var items := ItemDB.load_default()
	Jobs.accept(d, "j_bring", "macclesfield")
	Jobs.accept(d, "j_wales", "llanberis")
	Jobs.note_catch(d, "slatelet", Fixtures.dex())
	assert_eq(Jobs.progress_text(d, 1, Fixtures.dex()), "Have 0 of 3")
	var why := Jobs.held_back(d, "england", items, Fixtures.dex())
	assert_eq(why.size(), 2)
	assert_true("still needs 3 Blackberries" in str(why[0]), str(why[0]))
	assert_true("hand it in at a board in Wales" in str(why[1]), str(why[1]))
	assert_eq(Jobs.held_back(d, "wales", items, Fixtures.dex()).size(), 1, "the Welsh job hands in there, so only the jam is held back")
	_done()
