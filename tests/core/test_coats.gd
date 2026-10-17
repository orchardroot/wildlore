extends TestCase
## Uncommon coats: the roll rate, which coat the season and weather give, the Fieldbook flags and the save round trip.

func test_season_by_month() -> void:
	for m in [11, 12, 1, 2]:
		assert_eq(Coats.season_coat(m), "winter", "month %d is a winter coat" % m)
	for m in [9, 10]:
		assert_eq(Coats.season_coat(m), "autumn")
	for m in [6, 7, 8]:
		assert_eq(Coats.season_coat(m), "summer")
	for m in [3, 4, 5]:
		assert_eq(Coats.season_coat(m), "spring")

func test_pick_follows_weather_and_night() -> void:
	assert_eq(Coats.pick(7, "clear", "day", 0.1), "summer")
	assert_eq(Coats.pick(12, "gale", "day", 0.9), "storm", "a gale gives a storm coat")
	assert_eq(Coats.pick(12, "clear", "night", 0.1), "moonlit", "one in four night coats is moonlit")
	assert_eq(Coats.pick(12, "clear", "night", 0.6), "winter", "the rest keep the season")
	assert_eq(Coats.pick(4, "drizzle", "dusk", 0.1), "spring", "dusk is not night")

func test_roll_rate_is_about_one_in_96() -> void:
	var rng := Rng.new(1234)
	var hits := 0
	var n := 96000
	for i in n:
		if Coats.roll(rng, 10, "clear", "day") != "":
			hits += 1
	assert_true(hits > 850 and hits < 1150, "about 1000 coats in 96000 (got %d)" % hits)

func test_roll_misses_and_hits_with_fixed_rng() -> void:
	var r := FixedRng.new()
	r.f = 0.5
	assert_eq(Coats.roll(r, 1, "clear", "day"), "", "a plain coat almost always")
	r.f = 0.001
	assert_eq(Coats.roll(r, 1, "clear", "day"), "winter")
	assert_eq(Coats.roll(r, 1, "clear", "night"), "moonlit")

func test_every_coat_has_a_name_line_and_palette() -> void:
	for v in Coats.ALL:
		assert_true(Coats.NAMES.has(v), v + " has a name")
		assert_true(Coats.intro_line(v) != "", v + " has an intro line")
		assert_false(Coats.intro_line(v).contains("—"), "no em-dashes")
		assert_eq(Coats.PALETTES[v].size(), 4, v + " has four palette stops")
	assert_eq(Coats.intro_line(""), "")

func test_variant_round_trips_and_old_saves_default() -> void:
	var c := Fixtures.creature("kindlet", 5)
	assert_eq(c.variant, "")
	c.variant = "autumn"
	var back := Creature.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())), Fixtures.dex())
	assert_eq(back.variant, "autumn")
	var old := c.to_dict()
	old.erase("variant")
	assert_eq(Creature.from_dict(old, Fixtures.dex()).variant, "", "a 1.5 creature has a plain coat")

func test_fieldbook_flags() -> void:
	var d := GameStateData.new()
	var c := Fixtures.creature("kindlet", 5)
	Coats.record_seen(d, c)
	assert_eq(d.flags.size(), 0, "plain coats aren't noted")
	c.variant = "winter"
	Coats.record_seen(d, c)
	assert_eq(d.flag("coat_kindlet_winter"), "seen")
	Coats.record_caught(d, c)
	assert_eq(d.flag("coat_kindlet_winter"), "caught")
	Coats.record_seen(d, c)
	assert_eq(d.flag("coat_kindlet_winter"), "caught", "seeing it again doesn't undo the catch")
	assert_eq(Coats.status(d, "kindlet", "winter"), "caught")
	assert_eq(Coats.status(d, "kindlet", "storm"), "")
	assert_eq(Coats.counts(d), {"seen": 1, "caught": 1})
