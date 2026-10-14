extends TestCase

func test_default_items_load() -> void:
	var db := ItemDB.load_default()
	for id in ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare", "iron_snare", "night_snare", "water_snare", "whitby_jet", "fieldbook", "map"]:
		assert_true(db.has(id), id)
	assert_eq(db.duplicates, [])

func test_numbers_are_ints() -> void:
	var tea := ItemDB.load_default().get_item("cup_of_tea")
	assert_eq(typeof(tea.amount), TYPE_INT)
	assert_eq(typeof(tea.price), TYPE_INT)
	assert_eq(tea.amount, 20)
	assert_eq(tea.price, 100)

func test_unknown_item_is_empty() -> void:
	var db := ItemDB.load_default()
	assert_false(db.has("nope"))
	assert_eq(db.get_item("nope"), {})

func test_duplicates_reported() -> void:
	var db := ItemDB.from_array([{"id": "a", "kind": "key"}, {"id": "a", "kind": "key"}])
	assert_eq(db.duplicates, ["a"])
	assert_eq(db.ids(), ["a"])

func test_normalise_defaults() -> void:
	var it := ItemDB.normalise({"id": "x", "kind": "heal", "price": 5.0})
	assert_eq(it.price, 5)
	assert_eq(it.amount, 0)
	assert_eq(it.cures, [])
	assert_false(it.battle)

func test_shops_load() -> void:
	var db := ItemDB.load_default()
	assert_true(db.shops.has("macc_corner_shop"))
	assert_true(db.shops.has("buxton_corner_shop"))
	assert_has(db.shops.macc_corner_shop.stock, "cup_of_tea")
