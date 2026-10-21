class_name DeedsSim
extends RefCounted
## Plays the Deeds against their own rules to check nothing prints money (a MarketSim-style harness; the test and
## tools use it). The best honest day: every input bought at the CHEAPEST region's price (the goods are hard-won
## fish, so this is generous), a full store, the best tier, a manager and every day an average one. Pure logic.

## Net sterling per in-game day for a Deed at a tier, with inputs valued at the cheapest regional buy price.
static func net_per_day(data: GameStateData, id: String, tier: int, managed: bool) -> float:
	var deed := Deeds.get_deed(id)
	var st := {"owned": true, "tier": tier, "store": {}, "till": 0, "rates_due": 0, "manager": "npc" if managed else "",
		"last_day": data.day_count, "coll": data.day_count, "paid": 0, "accrue": 0, "bill": data.day_count + 7, "stmt": data.day_count + 30, "log": []}
	data.set_flag(Deeds.FLAG_PREFIX + id, st)
	var cost := 0.0
	var units := 0
	for inp in deed.inputs:
		units += int(inp.per_day)
		cost += int(inp.per_day) * cheapest_buy(str(inp.item))
	var o: Dictionary = deed.output
	var raw := (float(o.base) + float(o.per_input) * units) * float(deed.tiers[tier].mult) * Deeds.inflation(data) * Deeds.band_scale(data)
	if managed:
		raw *= Deeds.MANAGER_BONUS
	return raw * (1.0 - float(deed.rates)) - cost

static func cheapest_buy(item_id: String) -> float:
	var base := float(Trade.base_price(item_id))
	var best := base * 99.0
	for g in Trade.config().get("groups", {}):
		best = minf(best, base * Trade.regional(item_id, str(g)))
	return best

## Total sterling outlay to hold `tier` (the Deed at today's price plus every upgrade up to it).
static func outlay(data: GameStateData, id: String, tier: int) -> float:
	var deed := Deeds.get_deed(id)
	var total := float(Deeds.price(data, id))
	for t in range(1, tier + 1):
		total += float(deed.tiers[t].cost) * Deeds.inflation(data)
	return total

## Days to earn back the outlay at a tier. The test insists this never drops under a fortnight... of play.
static func payback_days(data: GameStateData, id: String, tier: int, managed: bool) -> float:
	var net := net_per_day(data, id, tier, managed)
	return outlay(data, id, tier) / maxf(0.001, net) if net > 0.0 else 9999.0
