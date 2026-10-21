class_name Trade
extends RefCounted
## STUB of the Trade Ledger (session A owns the real one). Same signatures; base price to buy, half to sell.

static func buy_price(_data: GameStateData, item_id: String, _zone_id: String) -> int:
	return _base(item_id)

static func sell_price(data: GameStateData, item_id: String, zone_id: String) -> int:
	return buy_price(data, item_id, zone_id) / 2

static func price_note(_data: GameStateData, _item_id: String, _zone_id: String) -> String:
	return ""

static func _base(item_id: String) -> int:
	for f in DirAccess.get_files_at("res://data/items"):
		if f.ends_with(".json"):
			var d = JsonUtil.read("res://data/items/" + f)
			if d is Array:
				for it in d:
					if it is Dictionary and str(it.get("id", "")) == item_id:
						return int(it.get("price", 0))
	return 0
