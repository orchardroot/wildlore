class_name Forex
extends RefCounted
## The pound against the euro (and the US and New Zealand dollars): units per pound, once per in-game day. A seeded, mean-reverting random walk (on the
## log of the rate) round about 1.10 to 1.25, with the odd seeded news day and nudges from the story (applied from
## the day the player first finds the flag set, see Markets.sync, and fading back as the walk reverts).
## The same seed and day always give the same rate, so nothing about it needs saving. The dollar walks are the same
## idea round their own means; the Bermudian, Cayman and Eastern Caribbean dollars are pegged to the US dollar, and
## the pounds of Gibraltar, the Falklands, Saint Helena, Jersey and Guernsey to sterling at par (PEGS).
## Pure logic (no autoload names).

const MEAN := 1.175
const REVERT := 0.06          # of the gap to the mean closed each day
const DAILY_SD := 0.0055      # of the log rate
const NEWS_CHANCE := 0.035    # a day with a jolt and a headline
const NEWS_SD := 0.018
const LOW := 1.06
const HIGH := 1.29
## The bureau's margin either side of the middle rate, and the tourist rate a shop gives for the wrong money.
const SPREAD := 0.03
const TOURIST := 0.12
## Story nudges to the log rate (+ = more euros to the pound).
const STORY := {"visited_dublin": -0.012, "badge_kin": -0.01, "ch8_vane": -0.02, "moot_won": 0.012, "game_complete": 0.035}

## The other floating currencies: {mean, sd (of the log rate), low, high} in units per pound.
const WALKS := {
	"usd": {"mean": 1.33, "sd": 0.0048, "low": 1.16, "high": 1.49},
	"nzd": {"mean": 2.25, "sd": 0.0058, "low": 2.02, "high": 2.52},
	"try": {"mean": 55.0, "sd": 0.008, "low": 46.0, "high": 66.0},  # the Turkish lira, in the north of Cyprus
}
## Pegged currencies: units of the anchor per unit of this currency's own, as units per anchor
## (1 KYD = 1.20 USD; 2.70 XCD to the USD; BMD 1:1). Pounds at par are 1.0 per sterling.
const PEGS := {"bmd": ["usd", 1.0], "kyd": ["usd", 1.0 / 1.2], "xcd": ["usd", 2.7]}
## The bureau's fee on a pound at par (Jersey notes for sterling and so on): small, but not nothing.
const PAR_SPREAD := 0.015

static var _walks := {}   # code: {seed, path, news, rng} for the dollar walks
static var _seed := -1
static var _path := PackedFloat64Array()   # the log rate, before story nudges
static var _news := PackedFloat64Array()   # the day's news jolt (0 if none)
static var _rng: RandomNumberGenerator

static func _extend(seed_value: int, day: int) -> void:
	if seed_value != _seed:
		_seed = seed_value
		_path = PackedFloat64Array()
		_news = PackedFloat64Array()
		_rng = RandomNumberGenerator.new()
		_rng.seed = hash("fx:%d" % seed_value)
		_path.append(log(MEAN) + _rng.randfn(0.0, 0.025))
		_news.append(0.0)
	var mu := log(MEAN)
	while _path.size() <= day:
		var x: float = _path[_path.size() - 1]
		var jolt := 0.0
		if _rng.randf() < NEWS_CHANCE:
			jolt = _rng.randfn(0.0, NEWS_SD)
		x += REVERT * (mu - x) + _rng.randfn(0.0, DAILY_SD) + jolt
		x = clampf(x, log(LOW), log(HIGH))
		_path.append(x)
		_news.append(jolt)

## Euros per pound on `day` (middle rate). `events` maps story keys to the day they were first seen.
static func mid(seed_value: int, day: int, events := {}) -> float:
	day = maxi(0, day)
	_extend(seed_value, day)
	var x: float = _path[day]
	for k in STORY:
		if events.has(k) and int(events[k]) <= day:
			x += float(STORY[k]) * pow(1.0 - REVERT, day - int(events[k]))
	return clampf(exp(x), LOW, HIGH)

static func _walk(cur: String, seed_value: int, day: int) -> PackedFloat64Array:
	var spec: Dictionary = WALKS[cur]
	var w: Dictionary = _walks.get(cur, {})
	if w.is_empty() or int(w.seed) != seed_value:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("fx:%s:%d" % [cur, seed_value])
		var path := PackedFloat64Array()
		path.append(log(float(spec.mean)) + rng.randfn(0.0, 0.025))
		w = {"seed": seed_value, "path": path, "rng": rng}
		_walks[cur] = w
	var path: PackedFloat64Array = w.path
	var rng: RandomNumberGenerator = w.rng
	var mu := log(float(spec.mean))
	while path.size() <= day:
		var x: float = path[path.size() - 1]
		var jolt := rng.randfn(0.0, NEWS_SD) if rng.randf() < NEWS_CHANCE else 0.0
		x += REVERT * (mu - x) + rng.randfn(0.0, float(spec.sd)) + jolt
		path.append(clampf(x, log(float(spec.low)), log(float(spec.high))))
	w.path = path
	return path

## Units of `cur` per pound on `day` at the middle rate: 1.0 for sterling and the pounds at par, the euro walk, the
## dollar walks, and the pegged dollars derived from their anchor.
static func per_gbp(cur: String, seed_value: int, day: int, events := {}) -> float:
	day = maxi(0, day)
	if cur == Wallet.EUR:
		return mid(seed_value, day, events)
	if WALKS.has(cur):
		return exp(_walk(cur, seed_value, day)[day])
	if PEGS.has(cur):
		return per_gbp(str(PEGS[cur][0]), seed_value, day, events) * float(PEGS[cur][1])
	return 1.0

static func per_gbp_for(data: GameStateData, cur: String) -> float:
	return per_gbp(cur, data.rng_seed, data.day_count, Markets.events_of(data))

## The bureau's margin for a pair against sterling.
static func spread_for(cur: String) -> float:
	return PAR_SPREAD if cur in Wallet.PAR_POUNDS else SPREAD

static func mid_for(data: GameStateData) -> float:
	return mid(data.rng_seed, data.day_count, Markets.events_of(data))

## The last `n` days' middle rates, oldest first, ending on `day`.
static func history(seed_value: int, day: int, n: int, events := {}) -> Array:
	var out := []
	for d in range(day - n + 1, day + 1):
		out.append(mid(seed_value, maxi(0, d), events))
	return out

## The same for any currency's units per pound.
static func history_of(cur: String, seed_value: int, day: int, n: int, events := {}) -> Array:
	var out := []
	for d in range(day - n + 1, day + 1):
		out.append(per_gbp(cur, seed_value, maxi(0, d), events))
	return out

## Euros the bureau gives for £1, and euros it asks for £1 back.
static func bureau_buy_eur(m: float) -> float:
	return m * (1.0 - SPREAD)

static func bureau_sell_eur(m: float) -> float:
	return m * (1.0 + SPREAD)

## The tourist rate in euros per pound: `paying_pounds` true when a euro shop takes your pounds (it gives fewer
## euros per pound), false when a sterling shop takes your euros (it wants more euros per pound).
static func tourist_eur_per_gbp(m: float, paying_pounds: bool) -> float:
	return m * (1.0 - TOURIST) if paying_pounds else m * (1.0 + TOURIST)

## What changing `amount` of `from_cur` gets you at the bureau today (whole units, rounded down).
static func quote(amount: int, from_cur: String, m: float) -> int:
	if amount <= 0:
		return 0
	if from_cur == Wallet.GBP:
		return floori(amount * bureau_buy_eur(m) + 0.000001)
	return floori(amount / bureau_sell_eur(m) + 0.000001)

## What changing `amount` of `from_cur` into `to_cur` gets you today: one of the two is sterling and the other is the
## local money of the bureau. Whole units, rounded down.
static func quote_pair(amount: int, from_cur: String, to_cur: String, data: GameStateData) -> int:
	if amount <= 0 or (from_cur != Wallet.GBP and to_cur != Wallet.GBP) or from_cur == to_cur:
		return 0
	var foreign := to_cur if from_cur == Wallet.GBP else from_cur
	var r := per_gbp_for(data, foreign)
	var sp := spread_for(foreign)
	if from_cur == Wallet.GBP:
		return floori(amount * r * (1.0 - sp) + 0.000001)
	return floori(amount / (r * (1.0 + sp)) + 0.000001)

## Changes `amount` of `from_cur` at the bureau, into `to_cur` (default: the old euro/sterling other purse).
## {ok, paid, got, cur (what you got)}.
static func exchange(data: GameStateData, amount: int, from_cur: String, to_cur := "") -> Dictionary:
	var to := to_cur if to_cur != "" else Wallet.other(from_cur)
	var got := quote_pair(amount, from_cur, to, data)
	if amount <= 0 or got <= 0 or not Wallet.spend(data, amount, from_cur):
		return {"ok": false, "paid": 0, "got": 0, "cur": to}
	Wallet.earn(data, got, to)
	return {"ok": true, "paid": amount, "got": got, "cur": to}

## The day's currency headline, or "" on a quiet day.
static func news(seed_value: int, day: int, templates: Dictionary) -> String:
	_extend(seed_value, maxi(0, day))
	var j: float = _news[maxi(0, day)]
	if absf(j) < 0.008:
		return ""
	var list: Array = templates.get("fx_up" if j > 0.0 else "fx_down", [])
	return str(list[posmod(hash("%d:%d" % [seed_value, day]), list.size())]) if not list.is_empty() else ""
