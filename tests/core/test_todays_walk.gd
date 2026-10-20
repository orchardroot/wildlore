extends TestCase
## Today's Walk: one featured species (triple weight in one zone), one bonus pub (double quiz prize) and one weather
## bounty, picked from the real date. No streaks, nothing lost by missing a day.

## A small world: two visited towns' regions and one far-off region nobody has been to.
func _index() -> Dictionary:
	return {
		"zones": {
			"macc_route": {"name": "Macc Forest", "region": "cheshire", "species": ["pipkin", "spikkin"]},
			"peak_route": {"name": "Kinder Edge", "region": "peak", "species": ["pipkin", "holtling"]},
			"far_route": {"name": "Far Glen", "region": "scotland", "species": ["kindlet"]},
		},
		"towns": {"macclesfield": "cheshire", "buxton": "peak", "inverness": "scotland"},
		"names": {"york_bettys": "Bettys Tea Rooms", "macc_route": "Macc Forest"},
	}

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.set_flag("visited_macclesfield", true)
	d.set_flag("visited_buxton", true)
	return d

func _cfg() -> Dictionary:
	return TodaysWalk.config()

func test_the_walk_is_the_same_all_day_and_changes_with_the_date() -> void:
	var d := _data()
	var a := TodaysWalk.pick("2026-10-17", d, _index(), _cfg(), null)
	var b := TodaysWalk.pick("2026-10-17", d, _index(), _cfg(), null)
	assert_eq(a, b, "deterministic for a date")
	var differs := false
	for day in range(1, 29):
		if TodaysWalk.pick("2026-11-%02d" % day, d, _index(), _cfg(), null) != a:
			differs = true
	assert_true(differs, "other days bring other walks")
	assert_eq(a.key, "2026-10-17")

func test_featured_species_comes_from_a_visited_region_and_lives_in_the_zone() -> void:
	var d := _data()
	var ix := _index()
	for day in range(1, 31):
		var w := TodaysWalk.pick("2026-10-%02d" % day, d, ix, _cfg(), null)
		assert_true(w.zone in ["macc_route", "peak_route"], "never the unvisited Highlands: %s" % w.zone)
		assert_true(w.species in ix.zones[w.zone].species, "the species really lives in %s" % w.zone)

func test_featured_species_prefers_uncaught() -> void:
	var d := _data()
	d.mark_caught("pipkin")
	d.mark_caught("spikkin")
	for day in range(1, 31):
		assert_eq(TodaysWalk.pick("2026-10-%02d" % day, d, _index(), _cfg(), null).species, "holtling", "the one still to catch")
	d.mark_caught("holtling")
	var w := TodaysWalk.pick("2026-10-01", d, _index(), _cfg(), null)
	assert_true(w.species in ["pipkin", "spikkin", "holtling"], "all caught: any of them will do")

func test_bonus_pub_prefers_visited_towns() -> void:
	var d := _data()
	d.set_flag("visited_york", true)
	for day in range(1, 15):
		assert_eq(TodaysWalk.pick("2026-10-%02d" % day, d, _index(), _cfg(), null).pub, "york")
	var fresh := GameStateData.new()
	assert_eq(TodaysWalk.pick("2026-10-01", fresh, _index(), _cfg(), null).pub, "", "no pubs visited: no pub (2.1)")

func test_bounty_weather_and_reward_are_known() -> void:
	var items := ItemDB.load_default()
	for day in range(1, 31):
		var w := TodaysWalk.pick("2026-10-%02d" % day, _data(), _index(), _cfg(), items)
		assert_true(_cfg().weathers.has(w.weather), w.weather)
		assert_true(items.has(w.reward), "a reward that exists: %s" % w.reward)
		assert_true(int(w.reward_n) >= 1)

func test_featured_weight_triples_in_the_named_zone_only() -> void:
	var list := [{"species": "pipkin", "weight": 10}, {"species": "spikkin", "weight": 30}]
	var boosted := Encounters.featured(list, "pipkin")
	assert_eq(boosted[0].weight, 30.0)
	assert_eq(boosted[1].weight, 30, "others untouched")
	assert_eq(list[0].weight, 10, "the zone's own table is untouched")
	assert_eq(Encounters.featured(list, ""), list)
	assert_eq(Encounters.featured(list, "kindlet"), list)
	# u = 0.4 lands on spikkin normally (10 of 40) and on pipkin when boosted (30 of 60)
	assert_eq(Encounters.pick_entry(list, 0.4).species, "spikkin")
	assert_eq(Encounters.pick_entry(boosted, 0.4).species, "pipkin")

func test_featured_in_reads_todays_walk_for_this_zone() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	d.set_flag(TodaysWalk.FLAG, {"key": "2026-10-17", "species": "pipkin", "zone": "macc_route", "pub": "york", "weather": "fog", "reward": "cream_tea", "reward_n": 1})
	assert_eq(TodaysWalk.featured_in(d, "macc_route"), "pipkin")
	assert_eq(TodaysWalk.featured_in(d, "peak_route"), "")
	assert_eq(TodaysWalk.bonus_pub(d), "york")
	Calendar.set_override("2026-10-18")
	assert_eq(TodaysWalk.featured_in(d, "macc_route"), "", "yesterday's walk is over")
	assert_eq(TodaysWalk.bonus_pub(d), "")
	Calendar.set_override("")

func test_today_is_picked_once_and_kept_even_after_a_catch() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	var w := TodaysWalk.today(d, null, _index())
	d.mark_caught(str(w.species))
	assert_eq(TodaysWalk.today(d, null, _index()), w, "catching the featured one doesn't move the goalposts")
	Calendar.set_override("2026-10-18")
	assert_eq(TodaysWalk.today(d, null, _index()).key, "2026-10-18")
	Calendar.set_override("")

func _walk_day(d: GameStateData) -> void:
	d.set_flag(TodaysWalk.FLAG, {"key": Calendar.today_key(), "species": "pipkin", "zone": "macc_route", "pub": "york", "weather": "rain", "reward": "cream_tea", "reward_n": 1,
		"zone_name": "Macc Forest", "pub_name": "Bettys Tea Rooms"})

func test_bounty_needs_a_catch_in_the_right_weather() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	_walk_day(d)
	var items := ItemDB.load_default()
	assert_false(TodaysWalk.bounty_ready(d))
	TodaysWalk.note_catch(d, "fog")
	assert_false(TodaysWalk.bounty_ready(d), "fog isn't rain")
	TodaysWalk.note_catch(d, "downpour")
	assert_true(TodaysWalk.bounty_ready(d), "a downpour is rain")
	var r := TodaysWalk.claim_bounty(d, items)
	assert_true(r.ok)
	assert_eq(int(d.bag.get("cream_tea", 0)), 1)
	assert_false(TodaysWalk.bounty_ready(d), "claimed")
	assert_false(TodaysWalk.claim_bounty(d, items).ok, "once a day")
	assert_eq(int(d.bag.get("cream_tea", 0)), 1)
	Calendar.set_override("2026-10-18")
	_walk_day(d)
	assert_false(TodaysWalk.bounty_ready(d), "yesterday's catch doesn't count today")
	TodaysWalk.note_catch(d, "drizzle")
	assert_true(TodaysWalk.bounty_ready(d), "a new day, a new bounty")
	Calendar.set_override("")

func test_nurse_pays_the_bounty_after_healing() -> void:
	Calendar.set_override("2026-10-17")
	var h := FakeStoryHost.new()
	_walk_day(h.data)
	TodaysWalk.note_catch(h.data, "drizzle")
	await Commands.new(h).run([{"do": "say", "who": "Nurse", "text": "Hello."}])
	assert_true(TodaysWalk.bounty_ready(h.data), "only Sanctuary nurses pay out")
	var nurse := _nurse_script()
	await Commands.new(h, "nurse").run(nurse)
	assert_false(TodaysWalk.bounty_ready(h.data), "paid")
	assert_eq(int(h.data.bag.get("cream_tea", 0)), 1)
	assert_true(h.texts().any(func(t): return str(t).contains("bounty")))
	Calendar.set_override("")

func _nurse_script() -> Array:
	return [
		{"do": "say", "who": "Nurse", "text": "Welcome to the Sanctuary."},
		{"do": "choice", "text": "Rest your team?", "options": ["Yes", "Ark", "No"], "set": "_nurse_choice"},
		{"do": "if", "flag": "_nurse_choice", "eq": 0, "then": [{"do": "say", "who": "Nurse", "text": "Let's see."}, {"do": "heal"}, {"do": "say", "who": "Nurse", "text": "Done."}],
			"else": [{"do": "if", "flag": "_nurse_choice", "eq": 1, "then": [{"do": "say", "who": "Nurse", "text": "The Ark."}, {"do": "ark"}], "else": [{"do": "say", "who": "Nurse", "text": "Bye."}]}]},
	]

func test_radio_reads_todays_walk() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	_walk_day(d)
	var lines := TodaysWalk.radio_lines(d, Fixtures.dex(), ItemDB.load_default(), _index())
	assert_eq(lines[0], "And now, Today's Walk.")
	var body := "\n".join(PackedStringArray(lines))
	assert_true(body.contains("Macc Forest"), body)
	assert_true(body.contains("Bettys Tea Rooms"), body)
	assert_true(body.contains("rain"), body)
	assert_true(body.contains("Cream Tea") or body.contains("cream tea"), body)
	assert_false(body.contains("{"), "every slot filled")
	assert_false(body.contains("—"), "no em-dash")
	print("OUT radio: " + " | ".join(PackedStringArray(lines)))
	print("OUT menu: " + TodaysWalk.summary(d, Fixtures.dex()))
	Calendar.set_override("")

func test_radio_pays_a_waiting_bounty() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	_walk_day(d)
	TodaysWalk.note_catch(d, "drizzle")
	var lines := TodaysWalk.radio_lines(d, Fixtures.dex(), ItemDB.load_default(), _index())
	assert_true(" ".join(PackedStringArray(lines)).contains("as promised"))
	assert_eq(int(d.bag.get("cream_tea", 0)), 1)
	var again := TodaysWalk.radio_lines(d, Fixtures.dex(), ItemDB.load_default(), _index())
	assert_true(" ".join(PackedStringArray(again)).contains("has been claimed"))
	assert_eq(int(d.bag.get("cream_tea", 0)), 1)
	Calendar.set_override("")

func test_bonus_pub_doubles_the_quiz_prize() -> void:
	Calendar.set_override("2026-10-17")
	var h := FakeStoryHost.new()
	_walk_day(h.data)
	h.menu_results = {"quiz:york:england_north": {"score": 3, "total": 5}, "quiz:dublin:ireland": {"score": 3, "total": 5}}
	var eur_before := h.data.euros
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland"}])
	var normal := Wallet.in_sterling(h.data.euros - eur_before, Wallet.EUR)  # a Dublin pub pays its kitty in euros
	var before := h.data.money
	await Commands.new(h).run([{"do": "quiz", "pub": "york", "region": "england_north"}])
	assert_eq(h.data.money - before, normal * 2, "double at today's pub")
	assert_true(h.texts().any(func(t): return str(t).contains("double")))
	Calendar.set_override("")

func test_real_world_data_gives_a_sensible_walk() -> void:
	var d := GameStateData.new()
	d.set_flag("visited_macclesfield", true)
	var ix := TodaysWalk.index()
	assert_true(ix.zones.size() > 20, "zones with wild creatures")
	var w := TodaysWalk.pick("2026-10-17", d, ix, _cfg(), ItemDB.load_default())
	assert_true(ix.zones.has(w.zone))
	assert_eq(ix.zones[w.zone].region, "cheshire", "only where you've been")
	for p in _cfg().pubs:
		assert_true(ix.names.has(str(p.zone)), "pub zone exists: %s" % p.zone)

func test_no_streaks_and_no_em_dashes_in_the_text() -> void:
	var raw := FileAccess.get_file_as_string("res://data/daily.json")
	assert_false(raw.contains("—"))
	assert_false(raw.to_lower().contains("streak"))
