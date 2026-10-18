extends TestCase
## The countryside gives back: now and then a beaten wild creature leaves a material behind for Mum's bench.

func _rng(f: float) -> FixedRng:
	var r := FixedRng.new()
	r.f = f
	return r

func _items() -> ItemDB:
	return ItemDB.load_default()

func test_a_lucky_win_leaves_a_material() -> void:
	var bag := Bag.new({})
	var lines := Gleaning.after_wild_win(bag, [Fixtures.creature("scuttlet", 5)], _rng(0.0), _items(), "spring")
	assert_eq(bag.count("sheep_wool"), 1)
	assert_eq(lines, ["The wild Scuttlet left behind a tuft of Sheep Wool. Into the bag it goes."])

func test_usually_nothing() -> void:
	var bag := Bag.new({})
	assert_eq(Gleaning.after_wild_win(bag, [Fixtures.creature("scuttlet", 5)], _rng(1.0), _items(), "spring"), [])
	assert_eq(bag.store, {})

func test_autumn_hedgerows_give_blackberries() -> void:
	var bag := Bag.new({})
	Gleaning.after_wild_win(bag, [Fixtures.creature("spikkin", 5)], _rng(0.0), _items(), "autumn")
	assert_eq(bag.count("blackberries"), 1)
	Gleaning.after_wild_win(bag, [Fixtures.creature("spikkin", 5)], _rng(0.0), _items(), "spring")
	assert_eq(bag.count("hawthorn_berry"), 1)

func test_every_type_gives_a_real_material() -> void:
	var items := ItemDB.load_default()
	for t in Rumours.TYPE_COLOURS:
		var id := Gleaning.material_for(t, "summer")
		assert_eq(str(items.get_item(id).get("kind", "")), "material", t + " -> " + id)

func test_a_full_stack_says_nothing() -> void:
	var bag := Bag.new({"sheep_wool": Bag.MAX_STACK})
	assert_eq(Gleaning.after_wild_win(bag, [Fixtures.creature("scuttlet", 5)], _rng(0.0), _items(), "spring"), [])
