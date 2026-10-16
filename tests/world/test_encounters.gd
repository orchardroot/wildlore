extends TestCase

func _zone() -> ZoneData:
	return ZoneData.from_dict({"id": "e", "rows": [",,,", "...", "~~~"], "spawn": [1, 1], "encounters": {
		"grass": [
			{"species": "spikkin", "min": 2, "max": 4, "weight": 30},
			{"species": "kindlet", "min": 3, "max": 3, "weight": 70, "time": ["night"]},
			{"species": "holtling", "min": 5, "max": 5, "weight": 50, "weather": ["fog"]},
		]}})

func _hit_rng(f: float) -> FixedRng:
	var r := FixedRng.new()
	r.f = f
	return r

func test_no_encounter_off_grass() -> void:
	assert_eq(Encounters.roll(_zone(), "grass", "day", "clear", _hit_rng(0.0)), {})
	assert_eq(Encounters.roll(_zone(), "path", "day", "clear", _hit_rng(0.0)), {})

func test_step_chance_gate() -> void:
	assert_eq(Encounters.roll(_zone(), "tall_grass", "day", "clear", _hit_rng(0.5)), {})

func test_time_and_weather_filters() -> void:
	# by day in clear weather only spikkin qualifies
	var r := Encounters.roll(_zone(), "tall_grass", "day", "clear", _hit_rng(0.0))
	assert_eq(r.species, "spikkin")
	assert_eq(r.level, 2)
	assert_eq(Encounters.candidates(_zone(), "grass", "night", "clear").size(), 2)
	assert_eq(Encounters.candidates(_zone(), "grass", "day", "fog").size(), 2)

func test_weights() -> void:
	var r := FixedRng.new()
	r.f = 0.05  # passes the 10% gate, then lands in the first 5% of the weight range
	assert_eq(Encounters.roll(_zone(), "tall_grass", "night", "clear", r).species, "spikkin")
	r.f = 0.09  # 9% of 100 weight = 9, still spikkin (0..30)
	assert_eq(Encounters.pick_entry(Encounters.candidates(_zone(), "grass", "night", "clear"), 0.5).species, "kindlet")

func test_grace_period() -> void:
	var g := Encounters.new()
	g.after_battle()
	assert_true(g.in_grace())
	for i in 4:
		g.stepped()
	assert_true(g.in_grace())
	g.stepped()
	assert_false(g.in_grace())
