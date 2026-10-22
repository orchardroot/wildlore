extends TestCase
## Isles of Invention: the Timeline (Invention), the gadgets (Gadgets) and the science fair puzzles (ScienceFair).

func _fixture() -> Dictionary:
	return {"eras": [
		{"id": "steam", "name": "Steam", "years": "old", "need": 2, "cost": "Soot.", "gadget": {"id": "steam_whistle", "name": "Whistle", "text": "Peep."}},
		{"id": "ai", "name": "AI", "years": "now", "need": 1, "cost": "Power.", "gadget": {"id": "field_guide", "name": "Guide", "text": "Guess."}}],
		"entries": [
		{"id": "rocket", "era": "steam", "year": 1829, "title": "Rocket", "text": "Fast.", "where": "Rainhill", "flags": ["plaque_a", "plaque_b"]},
		{"id": "bridge", "era": "steam", "year": 1779, "title": "Bridge", "text": "Iron.", "where": "Gorge", "flags": ["plaque_c"]},
		{"id": "plain", "era": "ai", "year": 0, "title": "Plain", "text": "Words.", "where": "London", "flags": ["q_x_done"]}]}

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func after_each() -> void:
	Invention.reset()

func test_entries_in_year_order_with_now_last() -> void:
	Invention.use(_fixture())
	assert_eq(Invention.entries().map(func(e): return e.id), ["bridge", "rocket", "plain"])
	assert_eq(Invention.year_text(Invention.entry("plain")), "Now")
	Invention.reset()

func test_any_flag_finds_an_entry_and_old_saves_count() -> void:
	Invention.use(_fixture())
	var d := _data({"plaque_b": true})
	assert_true(Invention.found(d, Invention.entry("rocket")), "the second flag is enough")
	assert_false(Invention.found(d, Invention.entry("bridge")))
	assert_eq(Invention.found_count(d), 1)
	assert_false(Invention.gadget_open(d, "steam"), "needs two")
	d.set_flag("plaque_c", true)
	assert_true(Invention.gadget_open(d, "steam"))
	assert_eq(Invention.open_gadgets(d), ["steam_whistle"])
	Invention.reset()

func test_news_once_per_entry_and_names_the_gadget_it_opens() -> void:
	Invention.use(_fixture())
	var d := _data({"plaque_a": true})
	var n := Invention.news_for_flag(d, "plaque_a")
	assert_eq(str(n.entry.id), "rocket")
	assert_true(n.gadget.is_empty(), "one of two found: no gadget yet")
	d.set_flag("plaque_b", true)
	assert_true(Invention.news_for_flag(d, "plaque_b").is_empty(), "already found through plaque_a")
	d.set_flag("plaque_c", true)
	assert_eq(str(Invention.news_for_flag(d, "plaque_c").gadget.id), "steam_whistle")
	assert_true(Invention.news_for_flag(d, "nothing_of_ours").is_empty())
	Invention.reset()

func test_check_flags_unset_flags_and_years() -> void:
	var f := _fixture()
	f.entries[0]["year"] = 3000
	Invention.use(f)
	var errs := Invention.check({"plaque_a": true, "plaque_b": true, "q_x_done": true})
	assert_true(errs.any(func(e): return "plaque_c" in e), "an unset flag is caught")
	assert_true(errs.any(func(e): return "3000" in e), "a silly year is caught")
	Invention.reset()

func test_real_timeline_is_clean() -> void:
	Invention.reset()
	assert_eq(Invention.check(Quests.all_settable()), [])
	assert_true(Invention.entries().size() >= 25)
	for er in Invention.eras():
		assert_true(Invention.era_entries(str(er.id)).size() >= int(er.need), str(er.id))

# --- gadgets -------------------------------------------------------------------------

func test_whistle_once_a_day_and_never_over_a_sachet() -> void:
	var d := _data()
	d.day_count = 5
	var r := Gadgets.whistle(d)
	assert_true(r.ok)
	assert_eq(Repel.steps_left(d), Gadgets.WHISTLE_STEPS)
	d.set_flag(Repel.FLAG, 0)
	assert_false(Gadgets.whistle(d).ok, "once a day")
	d.day_count = 6
	d.set_flag(Repel.FLAG, 30)
	assert_false(Gadgets.whistle(d).ok, "not over one still going")
	assert_eq(Repel.steps_left(d), 30)
	d.set_flag(Repel.FLAG, 0)
	assert_true(Gadgets.whistle(d).ok, "the next day")

func test_gadgets_never_touch_money() -> void:
	var d := _data()
	d.money = 1234
	d.euros = 56
	for day in 30:
		d.day_count = day
		d.set_flag(Repel.FLAG, 0)
		Gadgets.whistle(d)
	Gadgets.guide(d, [{"species": "a", "weight": 1}], func(s): return s)
	Gadgets.web_lines(d, ["a"], {"zones": {}}, func(s): return s)
	assert_eq(d.money, 1234)
	assert_eq(d.euros, 56)
	assert_true(d.purses.is_empty())

func test_compass_words() -> void:
	assert_eq(Gadgets.compass(Vector2i(5, 5), Vector2i(5, 1)), "north")
	assert_eq(Gadgets.compass(Vector2i(5, 5), Vector2i(9, 6)), "east")
	assert_eq(Gadgets.compass(Vector2i(5, 5), Vector2i(2, 8)), "south-west")
	assert_eq(Gadgets.compass(Vector2i(5, 5), Vector2i(5, 5)), "right here")

func test_reckoner_counts_the_place_and_points_at_the_nearest() -> void:
	var plaques := [
		{"id": "a", "zone": "town", "x": 10, "y": 2, "town": "town"},
		{"id": "b", "zone": "town", "x": 3, "y": 9, "town": "town"},
		{"id": "c", "zone": "town_room", "x": 1, "y": 1, "town": "town"},
		{"id": "d", "zone": "elsewhere", "x": 1, "y": 1, "town": "elsewhere"}]
	var read := {"b": false, "a": false, "c": true}
	var lines := Gadgets.reckoner_lines("town", Vector2i(10, 6), plaques, func(id): return bool(read.get(id, false)), {"town_room": "town"})
	assert_eq(lines[0], "2 of 3 plaques round here still unread.")
	assert_eq(lines[1], "Nearest: 4 steps north of you.")
	read["a"] = true
	read["b"] = true
	assert_true("All 3" in Gadgets.reckoner_lines("town_room", Vector2i(1, 2), plaques, func(id): return bool(read.get(id, false)), {"town_room": "town"})[0])

func test_web_lists_seen_not_caught_with_homes() -> void:
	var d := _data()
	d.seen = {"a": true, "b": true}
	d.caught = {"b": true}
	var idx := {"zones": {"z1": {"name": "Moor", "enc": [{"species": "a"}]}, "z2": {"name": "Bog", "enc": [{"species": "a"}, {"species": "b"}]}}}
	var lines := Gadgets.web_lines(d, ["a", "b", "c"], idx, func(s): return s.to_upper())
	assert_eq(lines, ["A: Bog, Moor"])

func test_field_guide_only_names_what_you_have_seen() -> void:
	var d := _data()
	d.seen = {"a": true}
	var g := Gadgets.guide(d, [{"species": "a", "weight": 3}, {"species": "b", "weight": 1}], func(s): return s)
	assert_eq(g.top.size(), 1)
	assert_eq(str(g.top[0][0]), "a")
	assert_eq(roundi(g.top[0][1]), 75)
	assert_true(g.lines.any(func(l): return "never seen: 25" in l), "the unseen share is owned up to")

func test_nearest_sea_areas() -> void:
	var idx := {"zones": {"liverpool": {"pos": Vector2(616, 816)}, "london": {"pos": Vector2(836, 1071)}, "derry": {"pos": Vector2(284, 603)}}, "room_town": {}}
	var near := Gadgets.nearest_areas(Vector2(620, 820), {"Irish Sea": "liverpool", "Thames": "london", "Malin": "derry"}, idx, 2)
	assert_eq(near, ["Irish Sea", "Thames"])

# --- the science fair ----------------------------------------------------------------

func test_binary_lamps() -> void:
	assert_eq(ScienceFair.lamps_value([true, false, true, true, false]), 22)
	assert_eq(ScienceFair.place_values(5), [16, 8, 4, 2, 1])
	var p := {"kind": "binary", "bits": 5, "target": 22}
	assert_true(ScienceFair.solved(p, [true, false, true, true, false]))
	assert_false(ScienceFair.solved(p, [true, false, true, true, true]))

func test_shift_cipher_round_trips() -> void:
	assert_eq(ScienceFair.shift_text("ENIGMA", 3), "HQLJPD")
	assert_eq(ScienceFair.shift_text("XYZ", 3), "ABC")
	var rng := Rng.new(7)
	for i in 20:
		var p := ScienceFair.make("cipher", rng)
		assert_true(ScienceFair.solved(p, int(p.shift)), str(p))
		assert_false(ScienceFair.solved(p, (int(p.shift) + 1) % 26))

func test_dna_pairs() -> void:
	assert_eq(ScienceFair.partner("ATCG"), "TAGC")
	var p := {"kind": "dna", "strand": "GATTACA"}
	assert_true(ScienceFair.solved(p, "CTAATGT"))
	assert_false(ScienceFair.solved(p, "CTAATGA"))

func test_every_puzzle_is_solvable() -> void:
	var rng := Rng.new(42)
	for i in 30:
		for k in ScienceFair.KINDS:
			var p := ScienceFair.make(k, rng, i % 2 == 0)
			assert_false(p.is_empty(), k)
			if k == "binary":
				assert_true(int(p.target) >= 1 and int(p.target) < (1 << int(p.bits)))
			if k == "dna":
				assert_true(ScienceFair.solved(p, ScienceFair.partner(str(p.strand))))
