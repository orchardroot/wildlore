class_name ItemDB
extends RefCounted
## All items, keyed by id, plus the shops that stock them. Items load from every JSON array in data/items/,
## shops from data/shops/ (one object per file).

const DEFAULT_DIR := "res://data/items"
const SHOP_DIR := "res://data/shops"

var duplicates: Array = []
var shops: Dictionary = {}  # shop id -> {"id", "name", "stock": [item ids]}
var _items: Dictionary = {}
var _order: Array = []

static func load_default() -> ItemDB:
	var db := load_dir(DEFAULT_DIR)
	for path in JsonUtil.list_json(SHOP_DIR):
		var shop = JsonUtil.read(path)
		if shop is Dictionary:
			db.shops[str(shop.get("id", path.get_file().get_basename()))] = shop
	return db

static func load_dir(dir: String) -> ItemDB:
	var all := []
	for path in JsonUtil.list_json(dir):
		var arr = JsonUtil.read(path)
		if arr is Array:
			all.append_array(arr)
	return from_array(all)

static func from_array(arr: Array) -> ItemDB:
	var db := ItemDB.new()
	for it in arr:
		db._add(normalise(it))
	return db

static func normalise(it: Dictionary) -> Dictionary:
	var out := it.duplicate(true)
	out["price"] = int(it.get("price", 0))
	out["amount"] = int(it.get("amount", 0))
	out["battle"] = bool(it.get("battle", false))
	out["field"] = bool(it.get("field", false))
	out["cures"] = it.get("cures", []).duplicate()
	out["evolves"] = it.get("evolves", {}).duplicate()
	out["snare"] = str(it.get("snare", ""))
	out["desc"] = str(it.get("desc", ""))
	return out

func _add(it: Dictionary) -> void:
	var id: String = it.get("id", "")
	if _items.has(id):
		duplicates.append(id)
	else:
		_order.append(id)
	_items[id] = it

func get_item(id: String) -> Dictionary:
	return _items.get(id, {})

func has(id: String) -> bool:
	return _items.has(id)

func ids() -> Array:
	return _order.duplicate()
