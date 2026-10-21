extends TestCase
## The County Show's produce class and sheepdog trials (core/show_classes.gd, core/sheepdog.gd).

func _items() -> ItemDB:
	return ItemDB.from_array([
		{"id": "leek", "name": "Leek", "kind": "produce", "price": 40},
		{"id": "marrow", "name": "Marrow", "kind": "produce", "price": 60},
		{"id": "potion", "name": "Potion", "kind": "heal", "price": 20}])

## A sensible bot: takes the rearmost unpenned sheep and pushes it towards its next gate from behind.
func _bot(st: Dictionary) -> Vector2:
	var target = null
	for s in st.sheep:
		if int(s.stage) >= Sheepdog.GATES.size() and s.p.x >= Sheepdog.PEN_X:
			continue
		if target == null or int(s.stage) < int(target.stage) or (int(s.stage) == int(target.stage) and s.p.x < target.p.x):
			target = s
	if target == null:
		return Vector2.ZERO
	var stage: int = target.stage
	var aim := Vector2(Sheepdog.PEN_X + 0.8 if stage >= Sheepdog.GATES.size() else Sheepdog.GATES[stage] + 0.6, st.gate_y)
	var push: Vector2 = (aim - target.p).normalized()
	var behind: Vector2 = target.p - push * 1.6
	if st.dog.distance_to(behind) > 0.4:
		return (behind - st.dog).normalized()
	return push

func _play(seed_text: String, easy: bool) -> Dictionary:
	var st := Sheepdog.start(seed_text, 40, easy)
	while not Sheepdog.done(st):
		Sheepdog.step(st, _bot(st), 1.0 / 30.0)
	return st

func test_entrants_are_produce_only() -> void:
	var d := GameStateData.new()
	d.bag = {"leek": 2, "potion": 3, "marrow": 0}
	var e := ShowClasses.entrants(d, _items())
	assert_eq(e.size(), 1)
	assert_eq(e[0].id, "leek")

func test_judging_is_stable_and_in_range() -> void:
	var it: Dictionary = _items().get_item("leek")
	var a := ShowClasses.judge(it, "2026-10-21/cheshire")
	assert_eq(a, ShowClasses.judge(it, "2026-10-21/cheshire"), "a retry can't re-roll")
	for day in 40:
		var j := ShowClasses.judge(it, "d%d" % day)
		for k in ["size", "condition", "score"]:
			assert_true(j[k] >= 0 and j[k] <= 100, k)

func test_places_and_prizes() -> void:
	assert_eq(ShowClasses.place(90, [50, 60, 70, 80]), 1)
	assert_eq(ShowClasses.place(60, [50, 60, 70, 80]), 4, "ties go to the grower")
	assert_eq(ShowClasses.place(10, [50, 60, 70, 80]), 5)
	assert_eq(ShowClasses.prize(ShowClasses.PRODUCE, 1).colour, "red")
	assert_eq(ShowClasses.prize(ShowClasses.DOG, 3).colour, "yellow")
	assert_true(ShowClasses.prize(ShowClasses.PRODUCE, 4).is_empty())

func test_every_place_comes_round() -> void:
	var it: Dictionary = _items().get_item("marrow")
	var seen := {}
	for day in 200:
		var k := "2026-11-%d/x" % day
		seen[ShowClasses.place(int(ShowClasses.judge(it, k).score), ShowClasses.rivals(k))] = true
	assert_true(seen.has(1) and seen.has(5), "you can win and you can lose")

func test_award_pays_once_per_call_and_cannot_print_money() -> void:
	var d := GameStateData.new()
	d.money = 0
	ShowClasses.award(d, ShowClasses.PRODUCE, 1, Wallet.GBP)
	ShowClasses.award(d, ShowClasses.DOG, 1, Wallet.GBP)
	assert_eq(d.money, 70, "the best possible day is a few pounds")
	assert_true(d.money <= 100)
	assert_eq(ShowClasses.wins(d, ShowClasses.DOG), 1)

func test_one_entry_a_class_a_day() -> void:
	var d := GameStateData.new()
	assert_false(ShowClasses.entered_today(d, ShowClasses.DOG))
	ShowClasses.mark_entered(d, ShowClasses.DOG)
	assert_true(ShowClasses.entered_today(d, ShowClasses.DOG))
	assert_false(ShowClasses.entered_today(d, ShowClasses.PRODUCE))

func test_sheep_stay_in_the_field_and_gates_hold() -> void:
	var st := Sheepdog.start("t", 0, false)
	for i in 600:
		Sheepdog.step(st, Vector2(1, 0), 1.0 / 30.0)
		for s in st.sheep:
			assert_true(s.p.x >= 0.0 and s.p.x <= Sheepdog.W and s.p.y >= 0.0 and s.p.y <= Sheepdog.H)
			if int(s.stage) == 0:
				assert_true(s.p.x < Sheepdog.GATES[0] + 0.15, "hurdle holds outside the gap")

func test_an_idle_dog_pens_nothing() -> void:
	var st := Sheepdog.start("idle", 0, false)
	for i in 3000:
		Sheepdog.step(st, Vector2.ZERO, 1.0 / 30.0)
	assert_eq(Sheepdog.penned(st), 0)
	assert_eq(Sheepdog.place_for(st), 0)
	assert_true(Sheepdog.done(st), "the clock runs out")

func test_the_trial_can_be_won_and_easy_is_easier() -> void:
	var wins := 0
	var easy_pen := 0
	var norm_pen := 0
	for i in 12:
		var n := _play("seed%d" % i, false)
		var e := _play("seed%d" % i, true)
		norm_pen += Sheepdog.penned(n)
		easy_pen += Sheepdog.penned(e)
		if Sheepdog.penned(n) >= 3:
			wins += 1
	assert_true(wins >= 9, "a sensible dog places in most trials: %d of 12" % wins)
	assert_true(easy_pen >= norm_pen, "easy mode never hurts: %d vs %d" % [easy_pen, norm_pen])
