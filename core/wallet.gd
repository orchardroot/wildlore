class_name Wallet
extends RefCounted
## Two purses: sterling (`data.money`, the old save field) and euros (`data.euros`). The Republic of Ireland deals in
## euros; Great Britain, Northern Ireland and the Isle of Man in sterling. Every earn and spend goes through here,
## so a new Irish shop, trainer or job just works by its zone. Prices are authored in sterling and shown in the
## local currency at the shops' own list rate (LIST_RATE); the bureau and the tourist rate float with Forex.
## Pure logic (no autoload names): the save data, the story commands and the validator's tools all load it.

const GBP := "gbp"
const EUR := "eur"
const SYMBOL := {"gbp": "£", "eur": "€"}
const NAMES := {"gbp": "sterling", "eur": "euros"}
## Authored sterling prices become euro price tags at this rate (a steady shop reckoning, not the day's rate).
const LIST_RATE := 1.15
const HAD_EUROS_FLAG := "wallet_had_euros"
## Set on an old save loaded in Ireland: the one-off welcome conversion, waiting to be announced.
const WELCOME_FLAG := "wallet_welcome"
const WELCOME_SHARE := 0.5  # of the sterling purse, converted at the day's middle rate with no commission

static func currency_of_nation(nation: String) -> String:
	return EUR if nation == "ireland" else GBP

## The currency a zone (or one of its rooms) deals in.
static func currency_for_zone(zone_id: String) -> String:
	if zone_id == "" or zone_id == "testbed":
		return GBP
	return currency_of_nation(Standing.nation_for_zone(zone_id))

## The currency where the player stands.
static func local(data: GameStateData) -> String:
	return currency_for_zone(str(data.zone_id))

static func other(cur: String) -> String:
	return GBP if cur == EUR else EUR

static func symbol(cur: String) -> String:
	return str(SYMBOL.get(cur, "£"))

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
	return data.euros if cur == EUR else data.money

static func _put(data: GameStateData, cur: String, v: int) -> void:
	if cur == EUR:
		data.euros = maxi(0, v)
		if v > 0:
			data.set_flag(HAD_EUROS_FLAG, true)
	else:
		data.money = maxi(0, v)

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

## An authored sterling amount as the local price tag: unchanged in sterling, at the list rate in euros.
static func localise(gbp_amount: int, cur: String) -> int:
	if cur != EUR or gbp_amount <= 0:
		return gbp_amount
	return maxi(1, roundi(gbp_amount * LIST_RATE))

## Back the other way, roughly: what a local amount is worth in sterling (for the lifetime stats).
static func in_sterling(amount: int, cur: String) -> int:
	return amount if cur != EUR else roundi(amount / LIST_RATE)

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

# --- paying with the wrong money -------------------------------------------------------------------

## How much of `foreign` currency a shop takes to cover `short` of its own, at the poor tourist rate.
## `mid` is the day's euros per pound (Forex.mid).
static func foreign_cost(short: int, cur: String, mid: float) -> int:
	if short <= 0:
		return 0
	if cur == EUR:  # pounds for euros: you get fewer euros per pound than the bureau gives
		return ceili(short / Forex.tourist_eur_per_gbp(mid, true) - 0.000001)
	return ceili(short * Forex.tourist_eur_per_gbp(mid, false) - 0.000001)  # euros for pounds

## The most a shop dealing in `cur` can be paid: your own purse plus the other one at the tourist rate.
static func spendable(data: GameStateData, cur: String, mid: float) -> int:
	var own := balance(data, cur)
	var foreign := balance(data, other(cur))
	if foreign <= 0:
		return own
	var extra := 0
	if cur == EUR:
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
	if int(res.get("local", 0)) <= 0:
		return "%s at the tourist rate" % f
	return "%s and %s at the tourist rate" % [fmt(int(res.local), cur), f]

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

## The header line for a menu: the local purse, and the other one beside it once you've had euros.
static func purse_text(data: GameStateData, cur: String) -> String:
	if not had_euros(data):
		return fmt(balance(data, GBP), GBP)
	return "%s   %s" % [fmt(balance(data, cur), cur), fmt(balance(data, other(cur)), other(cur))]
