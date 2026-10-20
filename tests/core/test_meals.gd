extends TestCase
## Regional dishes: eating one heals a bit and gives one modest buff (never stacked), and every dish is cookable
## and teachable somewhere.

var items := ItemDB.load_default()

func _dishes() -> Array:
	var out := []
	for id in items.ids():
		if str(items.get_item(id).get("kind", "")) == "meal":
			out.append(id)
	return out

func _fed(dish: String) -> GameStateData:
	var d := GameStateData.new()
	var c := Fixtures.creature("kindlet", 10)
	c.take_damage(15)
	d.party = [c]
	d.bag = {dish: 2}
	return d

func test_twenty_plus_dishes_and_all_are_sound() -> void:
	var ids := _dishes()
	assert_true(ids.size() >= 20, "20+ regional dishes, got %d" % ids.size())
	for id in ids:
		var it := items.get_item(id)
		assert_true(str(it.get("effect_text", "")) != "", "%s documents its effect" % id)
		assert_eq(Meals.problems(it), [], id)

func test_every_dish_has_a_recipe_taught_somewhere() -> void:
	var taught := {}
	for z in DirAccess.get_files_at("res://data/dialogue"):
		if not z.ends_with(".json"):
			continue
		var txt := FileAccess.get_file_as_string("res://data/dialogue/" + z)
		for r in Crafting.all():
			if txt.contains("\"%s\"" % r.id):
				taught[str(r.out)] = true
	for id in _dishes():
		var made := Crafting.all().filter(func(r): return str(r.out) == id)
		assert_false(made.is_empty(), "%s has a recipe" % id)
		assert_true(taught.has(id) or str(made[0].from) == "mum", "%s is taught by someone" % id)

func test_eating_heals_the_lead_and_sets_the_buff() -> void:
	var d := _fed("lancashire_hotpot")
	var before: int = d.party[0].hp
	var r := Meals.eat(d, "lancashire_hotpot", items)
	assert_true(r.ok, str(r))
	assert_true(d.party[0].hp > before)
	assert_eq(Meals.active(d), "lancashire_hotpot")
	assert_eq(int(d.bag.get("lancashire_hotpot", 0)), 1)

func test_buffs_do_not_stack() -> void:
	var d := _fed("lancashire_hotpot")
	d.bag["home_cawl"] = 1
	assert_true(Meals.eat(d, "lancashire_hotpot", items).ok)
	var again := Meals.eat(d, "home_cawl", items)
	assert_false(again.ok)
	assert_eq(int(d.bag.get("home_cawl", 0)), 1, "not used up")
	assert_eq(Meals.active(d), "lancashire_hotpot")

func test_stat_buff_is_taken_once_at_battle_start() -> void:
	var d := _fed("lancashire_hotpot")
	Meals.eat(d, "lancashire_hotpot", items)
	var buff := Meals.take_battle_buff(d, items, "wild")
	assert_eq(buff.get("buff"), "stat")
	assert_true(str(buff.text) != "")
	assert_true(Meals.take_battle_buff(d, items, "wild").is_empty(), "gone after one battle")
	assert_eq(Meals.active(d), "")

func test_catch_buff_waits_for_a_wild_battle_and_purse_for_a_keeper() -> void:
	var d := GameStateData.new()
	d.set_flag(Meals.FLAG, "home_boxty")
	var catch_dish := items.get_item("home_boxty")
	assert_eq(catch_dish.meal.buff, "catch")
	assert_true(Meals.take_battle_buff(d, items, "trainer").is_empty(), "a keeper battle doesn't spend a catch buff")
	assert_eq(Meals.active(d), "home_boxty")
	var b := Meals.take_battle_buff(d, items, "wild")
	assert_true(float(b.mult) > 1.0 and float(b.mult) <= 1.3, "modest")
	d.set_flag(Meals.FLAG, "irish_stew")
	assert_eq(items.get_item("irish_stew").meal.buff, "purse")
	assert_true(Meals.take_battle_buff(d, items, "wild").is_empty(), "wild fights pay nothing")
	var p := Meals.take_battle_buff(d, items, "trainer")
	assert_true(int(p.pct) > 0 and int(p.pct) <= 30)

func test_lure_counts_steps_and_wears_off() -> void:
	var d := _fed("home_cawl")
	d.bag["colcannon"] = 1
	var lure := ""
	for id in _dishes():
		if items.get_item(id).meal.buff == "lure":
			lure = id
	assert_true(lure != "", "at least one lure dish")
	d.bag[lure] = 1
	Meals.eat(d, lure, items)
	assert_true(Meals.lure_mult(d.flags) > 1.0 and Meals.lure_mult(d.flags) <= 1.5)
	var n := Meals.steps_left(d)
	assert_true(n >= 30)
	for i in n - 1:
		assert_false(Meals.step(d))
	assert_true(Meals.step(d), "the last step says so")
	assert_eq(Meals.lure_mult(d.flags), 1.0)
	assert_eq(Meals.active(d), "")

func test_old_saves_have_no_meal() -> void:
	var d := GameStateData.new()
	assert_eq(Meals.active(d), "")
	assert_eq(Meals.lure_mult(d.flags), 1.0)
	assert_false(Meals.step(d))

func test_eat_refuses_without_the_dish_or_a_party() -> void:
	var d := GameStateData.new()
	assert_false(Meals.eat(d, "lancashire_hotpot", items).ok)
