class_name Wallet
extends RefCounted
## Purses: sterling (`data.money`, the old save field), euros (`data.euros`) and, for the overseas territories, any
## other currency in `data.purses` (empty until you earn some). The Republic of Ireland deals in euros; Great Britain,
## Northern Ireland and the Isle of Man in sterling; each overseas territory in its own money (see CURRENCIES). Every
## earn and spend goes through here, so a new shop, trainer or job just works by its zone. Prices are authored in
## sterling and shown in the local currency at the shops' own list rate (list_rate); the bureau and the tourist rate
## float with Forex. The Crown Dependency and South Atlantic pounds are at par with sterling, but a shop on the other
## side of the sea won't take them (and the mainland won't take Jersey notes either), while their own shops take
## sterling at par.
## Pure logic (no autoload names): the save data, the story commands and the validator's tools all load it.

const GBP := "gbp"
const EUR := "eur"
## Every currency the game knows. `list` is the shops' own reckoning per authored pound (0 = by the anchor);
## `tag` tells the pound variants apart in a purse line.
const CURRENCIES := {
	"gbp": {"symbol": "£", "name": "sterling", "list": 1.0},
	"eur": {"symbol": "€", "name": "euros", "list": 1.15},
	"usd": {"symbol": "US$", "name": "US dollars", "list": 1.30},
	"nzd": {"symbol": "NZ$", "name": "New Zealand dollars", "list": 2.20},
	"bmd": {"symbol": "BD$", "name": "Bermudian dollars", "list": 1.30},
	"kyd": {"symbol": "CI$", "name": "Cayman Islands dollars", "list": 1.30 / 1.2},
	"xcd": {"symbol": "EC$", "name": "Eastern Caribbean dollars", "list": 1.30 * 2.7},
	"gip": {"symbol": "£", "name": "Gibraltar pounds", "list": 1.0, "tag": "Gibraltar"},
	"fkp": {"symbol": "£", "name": "Falkland Islands pounds", "list": 1.0, "tag": "Falklands"},
	"shp": {"symbol": "£", "name": "Saint Helena pounds", "list": 1.0, "tag": "St Helena"},
	"jep": {"symbol": "£", "name": "Jersey pounds", "list": 1.0, "tag": "Jersey"},
	"ggp": {"symbol": "£", "name": "Guernsey pounds", "list": 1.0, "tag": "Guernsey"},
}
## Pounds at par with sterling: a fixed 1:1, a small fee at the bureau. Their shops take sterling at par, but the mainland won't take their notes.
const PAR_POUNDS := ["gip", "fkp", "shp", "jep", "ggp"]
## Zone region (or, in the Channel Islands, zone) text to currency, first match wins. Overseas regions are named
## `overseas_<territory>`; matching is by substring so every spelling of a territory id works. Tristan da Cunha,
## South Georgia and the British Antarctic Territory use sterling, so they are not listed.
const REGION_RULES := [
	["gibraltar", "gip"], ["akrotiri", "eur"], ["dhekelia", "eur"], ["sovereign_base", "eur"],
	["falkland", "fkp"], ["stanley", "fkp"], ["helena", "shp"], ["ascension", "shp"], ["jamestown", "shp"],
	["tristan", "gbp"], ["south_georgia", "gbp"], ["sandwich", "gbp"], ["antarctic", "gbp"], ["bat", "gbp"],
	["bermuda", "bmd"], ["cayman", "kyd"], ["turks", "usd"], ["caicos", "usd"], ["virgin", "usd"], ["bvi", "usd"],
	["anguilla", "xcd"], ["montserrat", "xcd"], ["pitcairn", "nzd"], ["biot", "usd"], ["diego", "usd"],
	["chagos", "usd"], ["indian_ocean", "usd"], ["jersey", "jep"], ["guernsey", "ggp"],
]
## Channel Islands zones: Guernsey's bailiwick (Sark and Alderney use the Guernsey pound), else Jersey's.
const GUERNSEY_BITS := ["guernsey", "peter_port", "cornet", "hauteville", "sark", "alderney", "little_chapel", "herm"]
const HAD_EUROS_FLAG := "wallet_had_euros"
## Set on an old save loaded in Ireland: the one-off welcome conversion, waiting to be announced.
const WELCOME_FLAG := "wallet_welcome"
const WELCOME_SHARE := 0.5  # of the sterling purse, converted at the day's middle rate with no commission

static var _zone_cur := {}

static func currency_of_nation(nation: String) -> String:
	return EUR if nation == "ireland" else GBP

## The overseas currency of a zone region (`overseas_<territory>`, or `channel_islands` with the zone's own id), or ""
## when the region has no opinion (the mainland).
static func currency_for_region(region: String, zone := "") -> String:
	if region == "channel_islands":
		for bit in GUERNSEY_BITS:
			if zone.contains(bit):
				return "ggp"
		return "jep"
	if not region.begins_with("overseas"):
		return ""
	for rule in REGION_RULES:
		if region.contains(rule[0]):
			return rule[1]
	return ""

## The currency a zone (or one of its rooms) deals in.
static func currency_for_zone(zone_id: String) -> String:
	if zone_id == "" or zone_id == "testbed":
		return GBP
	if _zone_cur.has(zone_id):
		return _zone_cur[zone_id]
	var out := _work_out(zone_id)
	_zone_cur[zone_id] = out
	return out

static func _work_out(zone_id: String) -> String:
	if FileAccess.file_exists("res://data/zones/%s.json" % zone_id):
		var zi: Dictionary = ZoneIndex.get_index()
		var town := str(zi.room_town.get(zone_id, ""))
		var home := town if town != "" else zone_id
		var region := str(zi.zones.get(home, {}).get("region", ""))
		var cur := currency_for_region(region, home)
		if cur != "":
			return cur
	return currency_of_nation(Standing.nation_for_zone(zone_id))

## The currency where the player stands.
static func local(data: GameStateData) -> String:
	return currency_for_zone(str(data.zone_id))

## The one other money a shop dealing in `cur` will take, at the tourist rate: euros on the British mainland,
## sterling for the rest (at par, with no tourist penalty, where the local money is a pound at par). The mainland never
## takes a local pound: the other money there is euros.
static func other(cur: String) -> String:
	return GBP if cur != GBP else EUR

static func symbol(cur: String) -> String:
	return str(CURRENCIES.get(cur, CURRENCIES.gbp).symbol)

static func name_of(cur: String) -> String:
	return str(CURRENCIES.get(cur, CURRENCIES.gbp).name)

## The shops' reckoning: local price tag per authored pound.
static func list_rate(cur: String) -> float:
	return float(CURRENCIES.get(cur, CURRENCIES.gbp).list)

## A purse tag for the pound variants ("Jersey"), "" for everything else.
static func tag(cur: String) -> String:
	return str(CURRENCIES.get(cur, {}).get("tag", ""))

## "£1,234" or "€1,234" (a minus sign in front when negative).
static func fmt(n: int, cur := GBP) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + symbol(cur) + s + out

## Pence and cents: "£4.20", "€0.07".
static func fmt_price(v: float, cur := GBP) -> String:
	var cents := roundi(absf(v) * 100.0)
	var whole := fmt(cents / 100, cur)
	return ("-" if v < 0.0 and cents > 0 else "") + whole + ".%02d" % (cents % 100)

static func balance(data: GameStateData, cur: String) -> int:
	if cur == EUR:
		return data.euros
	if cur == GBP or not CURRENCIES.has(cur):
		return data.money
	return int(data.purses.get(cur, 0))

static func _put(data: GameStateData, cur: String, v: int) -> void:
	if cur == EUR:
		data.euros = maxi(0, v)
		if v > 0:
			data.set_flag(HAD_EUROS_FLAG, true)
	elif cur == GBP or not CURRENCIES.has(cur):
		data.money = maxi(0, v)
	elif v > 0:
		data.purses[cur] = v
	else:
		data.purses.erase(cur)  # an empty purse isn't kept in the save

## Purses beyond sterling and euros that hold something, as [name, "£5"] pairs in a steady order.
static func foreign_lines(data: GameStateData) -> Array:
	var out := []
	for cur in CURRENCIES:
		if cur != GBP and cur != EUR and balance(data, cur) > 0:
			out.append([name_of(cur), fmt(balance(data, cur), cur)])
	return out

## True once the player has ever held euros (the pause card then shows both purses).
static func had_euros(data: GameStateData) -> bool:
	return data.euros > 0 or data.flag(HAD_EUROS_FLAG) == true

## Adds `amount` (ignored if not positive). Returns what was added.
static func earn(data: GameStateData, amount: int, cur: String) -> int:
	if amount <= 0:
		return 0
	_put(data, cur, balance(data, cur) + amount)
	return amount

## Takes `amount` from that purse alone. False (and nothing taken) if it can't cover it.
static func spend(data: GameStateData, amount: int, cur: String) -> bool:
	if amount < 0 or balance(data, cur) < amount:
		return false
	_put(data, cur, balance(data, cur) - amount)
	return true

static func can_afford(data: GameStateData, amount: int, cur: String) -> bool:
	return amount >= 0 and balance(data, cur) >= amount

## An authored sterling amount as the local price tag: unchanged in sterling and the pounds at par, at the list rate
## in any other money.
static func localise(gbp_amount: int, cur: String) -> int:
	if list_rate(cur) == 1.0 or gbp_amount <= 0:
		return gbp_amount
	return maxi(1, roundi(gbp_amount * list_rate(cur)))

## Back the other way, roughly: what a local amount is worth in sterling (for the lifetime stats).
static func in_sterling(amount: int, cur: String) -> int:
	return roundi(amount / list_rate(cur))

## Pays an authored sterling amount in the currency of `zone_id`. {amount, cur}.
static func earn_here(data: GameStateData, gbp_amount: int, zone_id: String) -> Dictionary:
	var cur := currency_for_zone(zone_id)
	var amt := localise(gbp_amount, cur)
	earn(data, amt, cur)
	return {"amount": amt, "cur": cur}

## Lost a battle: half of each purse goes (the old rule, now for both).
static func halve_all(data: GameStateData) -> void:
	data.money = data.money / 2
	data.euros = data.euros / 2
	for cur in data.purses.keys():
		_put(data, cur, int(data.purses[cur]) / 2)

# --- paying with the wrong money -------------------------------------------------------------------

## The day's middle rate a shop dealing in `cur` needs for its tourist rate: foreign units per pound, euros on the
## British mainland (where the wrong money is euros).
static func shop_rate(data: GameStateData, cur: String) -> float:
	if cur == GBP or cur == EUR or not CURRENCIES.has(cur):
		return Forex.mid_for(data)
	return Forex.per_gbp_for(data, cur)

## How much of `foreign` currency a shop takes to cover `short` of its own, at the poor tourist rate.
## `mid` is the day's euros per pound (Forex.mid).
static func foreign_cost(short: int, cur: String, mid: float) -> int:
	if short <= 0:
		return 0
	if cur in PAR_POUNDS:  # sterling is welcome at par on the islands with their own pound
		return short
	if cur != GBP:  # pounds for euros (or dollars): you get fewer per pound than the bureau gives
		return ceili(short / Forex.tourist_eur_per_gbp(mid, true) - 0.000001)
	return ceili(short * Forex.tourist_eur_per_gbp(mid, false) - 0.000001)  # euros for pounds

## The most a shop dealing in `cur` can be paid: your own purse plus the other one at the tourist rate.
static func spendable(data: GameStateData, cur: String, mid: float) -> int:
	var own := balance(data, cur)
	var foreign := balance(data, other(cur))
	if other(cur) == "" or foreign <= 0:
		return own
	if cur in PAR_POUNDS:
		return own + foreign
	var extra := 0
	if cur != GBP:
		extra = floori(foreign * Forex.tourist_eur_per_gbp(mid, true) + 0.000001)
	else:
		extra = floori(foreign / Forex.tourist_eur_per_gbp(mid, false) + 0.000001)
	while extra > 0 and foreign_cost(extra, cur, mid) > foreign:  # rounding never lets you spend money you haven't got
		extra -= 1
	return own + extra

## Pays `amount` of `cur`: the local purse first, and whatever it can't cover from the other purse at the tourist
## rate. {ok, local, foreign, foreign_cur}. Nothing is taken unless the whole amount can be paid.
static func pay(data: GameStateData, amount: int, cur: String, mid: float) -> Dictionary:
	var out := {"ok": false, "local": 0, "foreign": 0, "foreign_cur": other(cur)}
	if amount < 0:
		return out
	var own := balance(data, cur)
	var short := maxi(0, amount - own)
	if short > 0 and other(cur) == "":
		return out
	var cost := foreign_cost(short, cur, mid)
	if cost > balance(data, other(cur)):
		return out
	spend(data, amount - short, cur)
	spend(data, cost, other(cur))
	out.ok = true
	out.local = amount - short
	out.foreign = cost
	return out

## "€23" or "€15 and £7 at the tourist rate": what a pay() result took, for the shopkeeper to say.
static func paid_text(res: Dictionary, cur: String) -> String:
	if int(res.get("foreign", 0)) <= 0:
		return fmt(int(res.get("local", 0)), cur)
	var f := fmt(int(res.foreign), str(res.foreign_cur))
	var rate := "" if cur in PAR_POUNDS else " at the tourist rate"  # sterling is taken at par on the pound islands
	if int(res.get("local", 0)) <= 0:
		return f + rate
	return "%s and %s%s" % [fmt(int(res.local), cur), f, rate]

# --- old saves ------------------------------------------------------------------------------------

## A save from before euros existed, loaded somewhere in the Republic: change half the sterling into euros at the
## day's middle rate, free, so the player can still buy a cup of tea. Returns the euros given (0 if nothing to do).
static func welcome_old_save(data: GameStateData) -> int:
	if currency_for_zone(str(data.zone_id)) != EUR or data.money <= 0 or data.euros > 0:
		return 0
	var gbp := int(data.money * WELCOME_SHARE)
	var eur := floori(gbp * Forex.mid_for(data))
	if gbp <= 0 or eur <= 0:
		return 0
	data.money -= gbp
	earn(data, eur, EUR)
	data.set_flag(WELCOME_FLAG, "%d:%d" % [gbp, eur])
	return eur

## The welcome line once (then forgets it), or "".
static func take_welcome_line(data: GameStateData) -> String:
	var v = data.flag(WELCOME_FLAG)
	if not (v is String) or str(v) == "":
		return ""
	data.set_flag(WELCOME_FLAG, "")
	var bits := str(v).split(":")
	return "Ireland uses the euro. A kind clerk at the Sanctuary changed %s into %s for you, no commission. Bureaux de change will do the rest." \
		% [fmt(int(bits[0]), GBP), fmt(int(bits[1]), EUR)]

## "£5 Jersey" for a pound variant, else the plain amount.
static func fmt_tagged(n: int, cur: String) -> String:
	return fmt(n, cur) + ((" " + tag(cur)) if tag(cur) != "" else "")

## The header line for a menu: the local purse, and the other one beside it once you've had euros (or are abroad
## in a money of your own).
static func purse_text(data: GameStateData, cur: String) -> String:
	if cur != GBP and cur != EUR:
		return "%s   %s" % [fmt_tagged(balance(data, cur), cur), fmt(data.money, GBP)]
	if not had_euros(data):
		return fmt(balance(data, GBP), GBP)
	return "%s   %s" % [fmt(balance(data, cur), cur), fmt(balance(data, other(cur)), other(cur))]

## A saved `purses` dictionary cleaned up: known currencies only (not sterling or euros), positive whole numbers.
static func sanitise_purses(raw) -> Dictionary:
	var out := {}
	if raw is Dictionary:
		for k in raw:
			if CURRENCIES.has(k) and k != GBP and k != EUR and (raw[k] is int or raw[k] is float) and int(raw[k]) > 0:
				out[str(k)] = int(raw[k])
	return out
