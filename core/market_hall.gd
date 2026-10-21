class_name MarketHall
extends RefCounted
## The Market Halls: 25 real covered markets where a stall-holder buys your trade goods at the Trade Ledger's price.
## data/market_halls.json: {halls: {<hall zone id>: {name, town, trader}}}. Pure logic (no autoload names): the
## screen (ui/market_hall_screen.gd) and the tests drive it. Nothing is saved here; selling is just the purse and bag.

const PATH := "res://data/market_halls.json"
## What a stall-holder will take: produce, dishes and fish. Kit, charms and key items stay in your pocket.
const GOODS_KINDS := ["material", "meal", "fish", "produce"]

static var _db: Dictionary = {}

static func halls() -> Dictionary:
	if _db.is_empty():
		var d = JsonUtil.read(PATH)
		_db = d.get("halls", {}) if d is Dictionary else {}
	return _db

static func hall(id: String) -> Dictionary:
	return halls().get(id, {})

## True for an item a stall-holder trades in.
static func is_trade_good(item: Dictionary) -> bool:
	return str(item.get("kind", "")) in GOODS_KINDS and int(item.get("price", 0)) > 0

## The price board for what you carry: [{id, name, n, buy, sell, note}] in item-id order. `store` is the bag's
## {id: count}; `lookup` maps an id to its item dictionary (ItemDB.get_item). Prices are sterling, from Trade.
static func board(data: GameStateData, store: Dictionary, lookup: Callable, hall_id: String) -> Array:
	var town := str(hall(hall_id).get("town", hall_id))
	var out := []
	var ids := store.keys()
	ids.sort()
	for id in ids:
		var n := int(store[id])
		var it: Dictionary = lookup.call(id)
		if n <= 0 or it.is_empty() or not is_trade_good(it):
			continue
		out.append({"id": id, "name": str(it.get("name", id)), "n": n, "buy": Trade.buy_price(data, id, town),
			"sell": Trade.sell_price(data, id, town), "note": Trade.price_note(data, id, town)})
	return out

## What a stall-holder pays for a stack, in sterling: each unit sold makes the next poorer (Trade.sell_total), as at a shop.
static func payout(data: GameStateData, hall_id: String, item_id: String, qty: int) -> int:
	return Trade.sell_total(data, item_id, str(hall(hall_id).get("town", hall_id)), maxi(0, qty))

## The payout for a stack, with the sale noted so the glut builds in that town (and fades over in-game days). The caller
## takes the stack from the bag and pays the purse. Without this the halls were a tap: every unit at the top price.
static func settle(data: GameStateData, hall_id: String, item_id: String, qty: int) -> int:
	var total := payout(data, hall_id, item_id, qty)
	Trade.record_sale(data, item_id, str(hall(hall_id).get("town", hall_id)), qty)
	return total

## problems() for the files on disk: only the halls' rooms and towns are read.
static func check_files() -> Array:
	var zones := {}
	var dialogue := {}
	for id in halls():
		for zid in [id, str(halls()[id].get("town", ""))]:
			if zid != "" and not zones.has(zid):
				var z = JsonUtil.read("res://data/zones/%s.json" % zid)
				if z is Dictionary:
					zones[zid] = z
		var d = JsonUtil.read("res://data/dialogue/%s.json" % id)
		dialogue[id] = d if d is Dictionary else {}
	return problems(zones, dialogue)

## Problems with the hall data: each hall has a town and a name, its room exists, the room has a stall-holder who
## runs the `market` command for it and one plaque. `zones` is {id: raw zone dictionary}; `dialogue` {zone: {script: [...]}}.
static func problems(zones: Dictionary, dialogue: Dictionary) -> Array:
	var errs := []
	for id in halls():
		var h: Dictionary = halls()[id]
		if str(h.get("name", "")) == "" or not zones.has(str(h.get("town", ""))):
			errs.append("market hall %s: needs a name and a real town" % id)
		if not zones.has(id):
			errs.append("market hall %s: no such room" % id)
			continue
		var z: Dictionary = zones[id]
		var runs := false
		for n in z.get("npcs", []):
			var sc = dialogue.get(id, {}).get(str(n.get("script", "")), [])
			if JSON.stringify(sc).contains("\"market\"") and JSON.stringify(sc).contains("\"" + id + "\""):
				runs = true
		if not runs:
			errs.append("market hall %s: no stall-holder runs the market command" % id)
		var plaques := 0
		for s in z.get("signs", []):
			if s is Dictionary and str(s.get("plaque", "")) != "":
				plaques += 1
		if plaques < 1:
			errs.append("market hall %s: no fact plaque" % id)
	if halls().size() != 25:
		errs.append("expected 25 market halls, found %d" % halls().size())
	return errs
