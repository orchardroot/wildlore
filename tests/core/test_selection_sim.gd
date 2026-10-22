extends TestCase
## The moor model (core/selection_sim.gd): natural selection you can watch. Seeded, so every run is the same.

func _run(scenario: String, steps: int, seed_value: int, climate := "snowy") -> SelectionSim:
	var s := SelectionSim.new(scenario, seed_value, climate)
	for i in steps:
		s.step()
	return s

func test_starts_with_a_mixed_population_and_a_backdrop() -> void:
	var s := SelectionSim.new("moor", 1)
	assert_eq(s.pop.size(), SelectionSim.N)
	var f := s.dark_fraction()
	assert_true(f > 0.2 and f < 0.8, "the moor starts mixed: %s" % f)
	assert_eq(s.history.size(), 1, "the first point is the start")
	assert_true(s.backdrop().has("text"))

func test_the_same_seed_gives_the_same_story() -> void:
	var a := _run("moor", 24, 7)
	var b := _run("moor", 24, 7)
	assert_eq(a.history, b.history)

func test_mild_winters_favour_the_dark_coat_and_snowy_ones_the_pale() -> void:
	var mild := 0.0
	var snowy := 0.0
	for seed_value in 6:
		mild += _run("moor", 40, seed_value, "mild").dark_fraction()
		snowy += _run("moor", 40, seed_value, "snowy").dark_fraction()
	assert_true(mild / 6.0 > 0.8, "ten mild years: dark takes over (%s)" % (mild / 6.0))
	assert_true(snowy / 6.0 < mild / 6.0 - 0.3, "snowy winters hold the pale coat (%s)" % (snowy / 6.0))

func test_moor_breeds_once_a_year_and_names_the_season() -> void:
	var s := SelectionSim.new("moor", 3)
	var seasons := []
	for i in 4:
		seasons.append(str(s.backdrop().season))
		s.step()
	assert_eq(seasons, ["spring", "summer", "autumn", "winter"])
	assert_eq(s.year(), 1)

func test_manchester_rises_with_the_soot_and_falls_after_clean_air() -> void:
	var peak := 0.0
	var end := 0.0
	for seed_value in 4:
		var s := SelectionSim.new("manchester", seed_value)
		assert_eq(s.year(), 1840)
		assert_true(s.dark_fraction() == 0.0, "no dark moths before 1848")
		while s.year() < 1900:
			s.step()
		peak += s.dark_fraction()
		while not s.finished():
			s.step()
		end += s.dark_fraction()
	assert_true(peak / 4.0 > 0.6, "dark common by 1900 (%s)" % (peak / 4.0))
	assert_true(end / 4.0 < 0.3, "pale back by 2000 (%s)" % (end / 4.0))

func test_eaten_counts_add_up_and_the_display_sample_is_stable() -> void:
	var s := SelectionSim.new("moor", 5)
	s.step()
	assert_true(s.last_eaten.dark + s.last_eaten.pale > 0, "something was eaten")
	assert_eq(s.sample().size(), SelectionSim.SHOWN)
	for x in s.sample():
		assert_true(x is bool)

func test_text_has_no_em_dash() -> void:
	for id in SelectionSim.SCENARIOS:
		var sc: Dictionary = SelectionSim.SCENARIOS[id]
		for t in [sc.name, sc.blurb]:
			assert_false(str(t).contains("—"), id)
