extends TestCase

func _move(id: String) -> Dictionary:
	return Fixtures.moves().get_move(id)

func test_worked_example_super_effective_with_stab() -> void:
	# Kindlet L10 lore 16 vs Spikkin L10 ward 16, Kindle power 40:
	# floor(floor(6 * 40 * 16 / 16) / 50) + 2 = 6; x2 (SE) x1.5 (STAB) x1.0 (max roll) = 18
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("kindle"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 18)
	assert_eq(r.effectiveness, 2.0)
	assert_false(r.crit)

func test_downpour_multiplies_water() -> void:
	# Holtling L10 lore 16 vs Kindlet L10 ward 14, Rill Shot 40: base 7. Clear: 7 x 3 = 21. Downpour: 7 x 4.5 = 31.
	var a := Fixtures.creature("holtling", 10)
	var d := Fixtures.creature("kindlet", 10)
	assert_eq(DamageCalc.compute(a, d, _move("rill_shot"), Fixtures.chart(), "clear", FixedRng.new()).damage, 21)
	assert_eq(DamageCalc.compute(a, d, _move("rill_shot"), Fixtures.chart(), "downpour", FixedRng.new()).damage, 31)

func test_immunity_deals_nothing() -> void:
	var ghost := Creature.create(Fixtures.species("ghost", ["spirit"]), 10, FixedRng.new(), Fixtures.moves())
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), ghost, _move("scrap"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 0)
	assert_eq(r.effectiveness, 0.0)

func test_status_move_deals_nothing() -> void:
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("glare"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 0)

func test_minimum_one_damage() -> void:
	var tank := Creature.create(Fixtures.species("tank", ["stone"], 255), 100, FixedRng.new(), Fixtures.moves())
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 1), tank, _move("scrap"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 1)

func test_crit_and_low_roll() -> void:
	var r := FixedRng.new()
	r.f = 0.0  # crit, and the lowest 0.85 roll
	var res := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("kindle"), Fixtures.chart(), "clear", r)
	assert_true(res.crit)
	assert_eq(res.damage, 22)  # 6 x 2 x 1.5 x 1.5 x 0.85 = 22.95

func test_soaked_defender_takes_more_storm() -> void:
	var zap := {"id": "zap", "type": "storm", "category": "special", "power": 40, "accuracy": 100}
	var a := Fixtures.creature("kindlet", 10)
	var d := Fixtures.creature("spikkin", 10)
	var dry: int = DamageCalc.compute(a, d, zap, Fixtures.chart(), "clear", FixedRng.new()).damage
	d.status = "soaked"
	var wet: int = DamageCalc.compute(a, d, zap, Fixtures.chart(), "clear", FixedRng.new()).damage
	assert_true(wet > dry)
