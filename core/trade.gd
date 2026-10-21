class_name Trade
extends RefCounted
## STUB: session A owns the real Trade Ledger. Same signatures; base price to buy, half to sell.

static var _db: ItemDB

static func _base(item_id: String) -> int:
	if _db == null:
		_db = ItemDB.load_default()
	return int(_db.get_item(item_id).get("price", 0))

static func buy_price(_data: GameStateData, item_id: String, _zone_id: String) -> int:
	return _base(item_id)

static func sell_price(_data: GameStateData, item_id: String, _zone_id: String) -> int:
	return _base(item_id) / 2

static func price_note(_data: GameStateData, _item_id: String, _zone_id: String) -> String:
	return ""
