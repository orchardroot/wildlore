extends TestCase

var items := ItemDB.load_default()

func _hurt(id := "kindlet", dmg := 10) -> Creature:
	var c := Fixtures.creature(id, 10)
	c.take_damage(dmg)
	return c

func test_count_add_remove() -> void:
	var store := {}
	var bag := Bag.new(store)
	assert_eq(bag.count("cup_of_tea"), 0)
	bag.add("cup_of_tea", 3)
	assert_eq(store.cup_of_tea, 3, "wraps the dictionary")
	assert_true(bag.remove("cup_of_tea", 2))
	assert_eq(bag.count("cup_of_tea"), 1)
	assert_false(bag.remove("cup_of_tea", 2))
	assert_eq(bag.count("cup_of_tea"), 1, "failed remove changes nothing")
	assert_true(bag.remove("cup_of_tea"))
	assert_false(store.has("cup_of_tea"), "empty stacks are dropped")

func test_items_of_kind() -> void:
	var bag := Bag.new({"cup_of_tea": 1, "wicker_snare": 4, "flask_of_tea": 2})
	var ids := bag.items_of_kind("heal", items)
	ids.sort()
	assert_eq(ids, ["cup_of_tea", "flask_of_tea"])
	assert_eq(bag.items_of_kind("snare", items), ["wicker_snare"])

func test_heal_consumes() -> void:
	var c := _hurt("kindlet", 12)
	var before := c.hp
	var bag := Bag.new({"cup_of_tea": 1})
	var r := bag.use_on("cup_of_tea", c, items)
	assert_true(r.ok)
	assert_eq(c.hp, mini(before + 20, c.max_hp()))
	assert_eq(bag.count("cup_of_tea"), 0)
	assert_true(str(r.text) != "")

func test_heal_clamps_to_max() -> void:
	var c := _hurt("kindlet", 3)
	Bag.new({"flask_of_tea": 1}).use_on("flask_of_tea", c, items)
	assert_eq(c.hp, c.max_hp())

func test_heal_refused_on_full_hp() -> void:
	var c := Fixtures.creature("kindlet", 10)
	var bag := Bag.new({"cup_of_tea": 1})
	var r := bag.use_on("cup_of_tea", c, items)
	assert_false(r.ok)
	assert_eq(bag.count("cup_of_tea"), 1, "not consumed")

func test_heal_refused_on_fainted() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.take_damage(c.hp)
	var bag := Bag.new({"cup_of_tea": 1})
	assert_false(bag.use_on("cup_of_tea", c, items).ok)
	assert_eq(c.hp, 0)
	assert_eq(bag.count("cup_of_tea"), 1)

func test_cure() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.status = "asleep"
	c.status_turns = 2
	var bag := Bag.new({"smelling_salts": 1})
	assert_true(bag.use_on("smelling_salts", c, items).ok)
	assert_eq(c.status, "")
	assert_eq(c.status_turns, 0)
	assert_eq(bag.count("smelling_salts"), 0)

func test_cure_refused_when_nothing_to_cure() -> void:
	var c := Fixtures.creature("kindlet", 10)
	var bag := Bag.new({"buxton_water": 1})
	assert_false(bag.use_on("buxton_water", c, items).ok)
	assert_eq(bag.count("buxton_water"), 1)

func test_cure_wrong_status_refused() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.status = "stung"
	var bag := Bag.new({"smelling_salts": 1, "buxton_water": 1})
	assert_false(bag.use_on("smelling_salts", c, items).ok)
	assert_eq(c.status, "stung")
	assert_true(bag.use_on("buxton_water", c, items).ok)
	assert_eq(c.status, "")

func test_revive_only_fainted() -> void:
	var live := _hurt("kindlet", 5)
	var bag := Bag.new({"kendal_mint_cake": 2})
	assert_false(bag.use_on("kendal_mint_cake", live, items).ok)
	assert_eq(bag.count("kendal_mint_cake"), 2)
	var down := Fixtures.creature("kindlet", 10)
	down.take_damage(down.hp)
	down.status = "stung"
	assert_true(bag.use_on("kendal_mint_cake", down, items).ok)
	assert_eq(down.hp, maxi(1, down.max_hp() / 2))
	assert_eq(down.status, "")
	assert_eq(bag.count("kendal_mint_cake"), 1)

func test_pp_restores_all_moves() -> void:
	var c := Fixtures.creature("kindlet", 12)
	for m in c.moves:
		m.pp = 0
	var bag := Bag.new({"bakewell_tart": 1})
	assert_true(bag.use_on("bakewell_tart", c, items).ok)
	for m in c.moves:
		assert_eq(m.pp, mini(10, m.max_pp))

func test_pp_caps_at_max_and_refused_when_full() -> void:
	var c := Fixtures.creature("kindlet", 12)
	var bag := Bag.new({"bakewell_tart": 2})
	assert_false(bag.use_on("bakewell_tart", c, items).ok)
	c.moves[0].pp = c.moves[0].max_pp - 1
	assert_true(bag.use_on("bakewell_tart", c, items).ok)
	assert_eq(c.moves[0].pp, c.moves[0].max_pp)

func test_unusable_kinds_and_missing_items() -> void:
	var c := _hurt()
	var bag := Bag.new({"wicker_snare": 1, "fieldbook": 1})
	assert_false(bag.use_on("wicker_snare", c, items).ok)
	assert_false(bag.use_on("fieldbook", c, items).ok)
	assert_false(bag.use_on("cup_of_tea", c, items).ok, "none in the bag")
	assert_false(bag.use_on("nope", c, items).ok)
	assert_eq(bag.count("wicker_snare"), 1)

func test_add_respects_max_stack() -> void:
	var b := Bag.new({})
	assert_eq(b.add("tea", 90), 90)
	assert_eq(b.add("tea", 20), 9)
	assert_eq(b.count("tea"), Bag.MAX_STACK)
	assert_eq(b.add("tea"), 0)
