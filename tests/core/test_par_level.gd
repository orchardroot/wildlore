extends TestCase

func test_par_starts_low_and_follows_the_furthest_step() -> void:
	assert_eq(ParLevel.par({}), ParLevel.START)
	assert_eq(ParLevel.par({"starter": true}), 7)
	assert_eq(ParLevel.par({"starter": true, "badge_brook": true}), 14)
	# out of order: the furthest step wins
	assert_eq(ParLevel.par({"badge_tide": true, "starter": true}), 60)
	assert_eq(ParLevel.par({"game_complete": true}), 97)

func test_false_and_zero_flags_do_not_count() -> void:
	assert_eq(ParLevel.par({"starter": false, "badge_brook": 0}), ParLevel.START)

func test_steps_are_story_ordered_and_rising() -> void:
	var last := 0
	for s in ParLevel.STEPS:
		assert_true(int(s[1]) > last, "%s par should rise" % s[0])
		last = int(s[1])

func test_steps_match_the_where_next_card() -> void:
	var obj: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/objectives.json"))
	var story := []
	for s in obj.story:
		story.append(str(s.flag_done))
	for s in ParLevel.STEPS:
		assert_true(str(s[0]) in story, "%s is a Where next? step" % s[0])

func test_offset_never_goes_negative() -> void:
	assert_eq(ParLevel.offset({}, 14), 0)
	assert_eq(ParLevel.offset({"badge_brook": true}, 14), 0)
	assert_eq(ParLevel.offset({"badge_urban": true}, 14), 8)

func test_lift_respects_the_cap() -> void:
	assert_eq(ParLevel.lift(12, {"badge_urban": true}, 14), 20)
	assert_eq(ParLevel.lift(99, {"game_complete": true}, 14), Rules.MAX_LEVEL)

func test_stage_follows_level_evolutions() -> void:
	var dex := Fixtures.dex()
	assert_eq(ParLevel.stage(dex, "kindlet", 5), "kindlet")
	assert_eq(ParLevel.stage(dex, "kindlet", 16), "emberdrey")
	assert_eq(ParLevel.stage(dex, "kindlet", 60), "pyredrey")
	assert_eq(ParLevel.stage(dex, "no_such_thing", 60), "no_such_thing")

func test_stage_stops_at_an_item_evolution() -> void:
	var dex := Fixtures.dex()
	for id in dex.ids():
		var evo: Variant = dex.get_species(id).get("evolves")
		if evo is Dictionary and evo.has("item"):
			assert_eq(ParLevel.stage(dex, id, 100), id)
			return

func test_scaled_zone_lifts_wild_levels() -> void:
	var z := ZoneData.new()
	z.encounters = {"grass": [{"species": "kindlet", "min": 10, "max": 10, "weight": 1}]}
	z.scaled_floor = 14
	var rng := Rng.new(1)
	var got := {}
	for i in 200:
		got = Encounters.roll(z, "tall_grass", "day", "clear", rng, "", {"badge_urban": true})
		if not got.is_empty():
			break
	assert_false(got.is_empty())
	assert_eq(int(got.level), 18)
	assert_true(got.get("scaled", false))

func test_fixed_zone_is_unchanged() -> void:
	var z := ZoneData.new()
	z.encounters = {"grass": [{"species": "kindlet", "min": 10, "max": 10, "weight": 1}]}
	var rng := Rng.new(1)
	var got := {}
	for i in 200:
		got = Encounters.roll(z, "tall_grass", "day", "clear", rng, "", {"game_complete": true})
		if not got.is_empty():
			break
	assert_eq(int(got.level), 10)
	assert_false(got.get("scaled", false))

func test_scaled_trainer_lifts_and_evolves() -> void:
	var def := {"scaled_floor": 14, "party": [{"species": "kindlet", "level": 12}]}
	var foes := TrainerParty.build(def, Fixtures.dex(), FixedRng.new(), Fixtures.moves(), 0, {"badge_tide": true})
	assert_eq(foes[0].level, 58)
	assert_eq(str(foes[0].species.id), "pyredrey")

func test_unscaled_trainer_ignores_flags() -> void:
	var def := {"party": [{"species": "kindlet", "level": 12}]}
	var foes := TrainerParty.build(def, Fixtures.dex(), FixedRng.new(), Fixtures.moves(), 0, {"game_complete": true})
	assert_eq(foes[0].level, 12)
	assert_eq(str(foes[0].species.id), "kindlet")
