class_name Forex
extends RefCounted
## The pound against the euro: euros per pound, once per in-game day. A seeded, mean-reverting random walk (on the
## log of the rate) round about 1.10 to 1.25, with the odd seeded news day and nudges from the story (applied from
## the day the player first finds the flag set, see Markets.sync, and fading back as the walk reverts).
## The same seed and day always give the same rate, so nothing about it needs saving.
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

static func mid_for(data: GameStateData) -> float:
	return mid(data.rng_seed, data.day_count, Markets.events_of(data))

## The last `n` days' middle rates, oldest first, ending on `day`.
static func history(seed_value: int, day: int, n: int, events := {}) -> Array:
	var out := []
	for d in range(day - n + 1, day + 1):
		out.append(mid(seed_value, maxi(0, d), events))
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

## Changes `amount` of `from_cur` at the bureau. {ok, paid, got, cur (what you got)}.
static func exchange(data: GameStateData, amount: int, from_cur: String) -> Dictionary:
	var to := Wallet.other(from_cur)
	var got := quote(amount, from_cur, mid_for(data))
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
