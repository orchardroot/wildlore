extends TestCase

var chart := TypeChart.load_default()
var moves := MoveDB.load_default()

func _sp(id: String, extra := {}) -> Dictionary:
	var sp := {"id": id, "name": id.capitalize(), "types": ["kin"],
		"base": {"hp": 50, "atk": 50, "def": 50, "lore": 50, "ward": 50, "spd": 50},
		"growth": "medium", "catch_rate": 45, "base_xp": 60, "learnset": [[1, "scrap"]],
		"evolves": null, "habitat": [], "dex": {"text": "t", "fact": "f"}, "sprite": id}
	sp.merge(extra, true)
	return sp

func _item(extra := {}) -> Dictionary:
	var it := {"id": "tea", "name": "Tea", "kind": "heal", "price": 10, "battle": true, "field": true, "amount": 20, "desc": "Nice."}
	it.merge(extra, true)
	return it

func _errors(item_list: Array, species := [], shops := {}) -> Array:
	var db := ItemDB.from_array(item_list)
	db.shops = shops
	return DataValidator.validate(chart, Dex.from_array(species), moves, db)

func _has(errors: Array, needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false

func test_real_items_valid() -> void:
	assert_eq(DataValidator.validate(chart, Dex.load_default(), moves, ItemDB.load_default()), [])

func test_old_call_still_works() -> void:
	assert_eq(DataValidator.validate(chart, Dex.from_array([]), moves), [])

func test_valid_item_passes() -> void:
	assert_eq(_errors([_item()]), [])

func test_duplicate_item() -> void:
	assert_true(_has(_errors([_item(), _item()]), "'tea' defined more than once"))

func test_missing_name_or_desc() -> void:
	assert_true(_has(_errors([_item({"name": ""})]), "missing name"))
	assert_true(_has(_errors([_item({"desc": ""})]), "missing desc"))

func test_unknown_kind() -> void:
	assert_true(_has(_errors([_item({"kind": "sword"})]), "unknown kind"))

func test_negative_price() -> void:
	assert_true(_has(_errors([_item({"price": -1})]), "price"))

func test_amount_needed() -> void:
	assert_true(_has(_errors([_item({"amount": 0})]), "amount"))
	assert_true(_has(_errors([_item({"kind": "revive", "amount": 0})]), "amount"))
	assert_true(_has(_errors([_item({"kind": "pp", "amount": 0})]), "amount"))

func test_revive_amount_is_a_percentage() -> void:
	assert_true(_has(_errors([_item({"kind": "revive", "amount": 150})]), "amount"))

func test_cure_statuses() -> void:
	assert_eq(_errors([_item({"kind": "cure", "amount": 0, "cures": ["asleep"]})]), [])
	assert_true(_has(_errors([_item({"kind": "cure", "amount": 0, "cures": []})]), "cures"))
	assert_true(_has(_errors([_item({"kind": "cure", "amount": 0, "cures": ["grumpy"]})]), "unknown status 'grumpy'"))

func test_snare_ids() -> void:
	assert_eq(_errors([_item({"kind": "snare", "amount": 0, "snare": "iron"})]), [])
	assert_eq(_errors([_item({"kind": "snare", "amount": 0, "snare": "fae"})]), [])
	assert_true(_has(_errors([_item({"kind": "snare", "amount": 0, "snare": "gold"})]), "unknown snare 'gold'"))

func test_evo_targets_exist() -> void:
	var evo := _item({"kind": "evo", "amount": 0, "evolves": {"a": "b"}})
	assert_eq(_errors([evo], [_sp("a"), _sp("b")]), [])
	assert_true(_has(_errors([evo], [_sp("a")]), "unknown species 'b'"))
	assert_true(_has(_errors([evo], [_sp("b")]), "unknown species 'a'"))

func test_shop_stock_must_exist() -> void:
	var shops := {"s": {"id": "s", "name": "S", "stock": ["tea", "ghost"]}}
	assert_true(_has(_errors([_item()], [], shops), "shop s: unknown item 'ghost'"))
	shops = {"s": {"id": "s", "name": "S", "stock": ["tea"]}}
	assert_eq(_errors([_item()], [], shops), [])

func test_shop_needs_name_and_stock() -> void:
	assert_true(_has(_errors([_item()], [], {"s": {"id": "s", "name": "", "stock": ["tea"]}}), "shop s: missing name"))
	assert_true(_has(_errors([_item()], [], {"s": {"id": "s", "name": "S", "stock": []}}), "shop s: empty stock"))

func test_shop_cannot_sell_unpriced_items() -> void:
	var key := _item({"id": "k", "kind": "key", "price": 0, "amount": 0})
	assert_true(_has(_errors([key], [], {"s": {"id": "s", "name": "S", "stock": ["k"]}}), "shop s: 'k' has no price"))

func test_species_item_evolution() -> void:
	var sp := [_sp("a", {"evolves": {"to": "b", "item": "stone"}}), _sp("b")]
	var stone := _item({"id": "stone", "kind": "evo", "price": 0, "amount": 0, "evolves": {"a": "b"}})
	assert_eq(_errors([stone], sp), [])
	assert_true(_has(_errors([], sp), "unknown item 'stone'"))
	var no_rule := [_sp("a", {"evolves": {"to": "b"}}), _sp("b")]
	assert_true(_has(_errors([], no_rule), "needs a level or an item"))

func test_species_item_evolution_must_be_evo_kind() -> void:
	var sp := [_sp("a", {"evolves": {"to": "b", "item": "tea"}}), _sp("b")]
	assert_true(_has(_errors([_item()], sp), "not an evolution item"))

func test_species_level_evolution_unchanged() -> void:
	assert_eq(_errors([], [_sp("a", {"evolves": {"to": "b", "level": 10}}), _sp("b")]), [])
