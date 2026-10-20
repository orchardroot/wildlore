class_name Markets
extends RefCounted
## The Stock Exchange and the Doggerel kiosk. Prices move once per in-game day: a seeded walk per company (drift,
## volatility, the season, a wet or dry day, the odd news jolt) plus shocks from the story, the Stones and the
## rewilding, each applied from the day the player first finds it (sync() stamps the day; the stamps are saved).
## The same seed, day and stamps always give the same prices, so only holdings and stamps live in the save.
##
## The save's `markets` dictionary: {h: {id: {n, cost, since}}, coin: {n, cost, gen}, ev: {key: day}, settled: day,
## realised: {gbp, eur}, trades: n}. Pure logic (no autoload names): the simulator and the tests run it headless.

const PATH := "res://data/markets.json"
const SEASON_DAYS := 30      # in-game days to a market season (spring, summer, autumn, winter, round again)
const DIVIDEND_EVERY := 30   # a quarter's dividend every this many in-game days
const NEWS_CHANCE := 0.03    # a company's own news day
## Commission on a share deal: a flat fee plus a slice of the value.
const FEE_FLAT := {"gbp": 4, "eur": 5}
const FEE_RATE := 0.008
## How much of one company you may hold (by value at the time you buy), growing with each Stone.
const CAP_BASE := 1500
const CAP_PER_BADGE := 1500
## Doggerel: the kiosk's margin either side, a flat "network fee", and how much of it you may hold.
const COIN_SPREAD := 0.03
const COIN_FEE := 1
const COIN_CAP_BASE := 250
const COIN_CAP_PER_BADGE := 250
const RUG_LEFT := 0.0        # what a coin is worth to its holders after the rug is pulled
const ODD_LOT := 1

static var _db: Dictionary = {}

static func db() -> Dictionary:
	if _db.is_empty():
		var d = JsonUtil.read(PATH)
		_db = d if d is Dictionary else {"companies": [], "boards": {}, "coin": {}, "news": {}}
	return _db

static func companies() -> Array:
	return db().get("companies", [])

static func company(id: String) -> Dictionary:
	for c in companies():
		if str(c.id) == id:
			return c
	return {}

static func board(id: String) -> Dictionary:
	return db().get("boards", {}).get(id, {})

static func board_ids() -> Array:
	return db().get("boards", {}).keys()

## The shares a board deals in: its own currency's listings, the board's home companies first.
static func listings(board_id: String) -> Array:
	var b := board(board_id)
	var cur := str(b.get("currency", Wallet.GBP))
	var home := []
	var rest := []
	for c in companies():
		if str(c.get("currency", Wallet.GBP)) != cur:
			continue
		(home if str(c.get("home", "")) == board_id else rest).append(str(c.id))
	return home + rest

static func coin() -> Dictionary:
	return db().get("coin", {})

static func news_templates() -> Dictionary:
	return db().get("news", {})

# --- save state -----------------------------------------------------------------------------------

static func fresh() -> Dictionary:
	return {"h": {}, "coin": {"n": 0, "cost": 0, "gen": 0}, "ev": {}, "settled": -1, "realised": {"gbp": 0, "eur": 0}, "trades": 0}

## Whatever came out of a save, made safe: JSON floats back to ints, missing parts filled in.
static func sanitise(raw: Variant) -> Dictionary:
	var out := fresh()
	if not (raw is Dictionary):
		return out
	var h = raw.get("h", {})
	if h is Dictionary:
		for id in h:
			var e = h[id]
			if e is Dictionary and int(e.get("n", 0)) > 0:
				out.h[str(id)] = {"n": int(e.get("n", 0)), "cost": int(e.get("cost", 0)), "since": int(e.get("since", 0))}
	var c = raw.get("coin", {})
	if c is Dictionary:
		out.coin = {"n": maxi(0, int(c.get("n", 0))), "cost": maxi(0, int(c.get("cost", 0))), "gen": int(c.get("gen", 0))}
	var ev = raw.get("ev", {})
	if ev is Dictionary:
		for k in ev:
			out.ev[str(k)] = int(ev[k])
	out.settled = int(raw.get("settled", -1))
	var r = raw.get("realised", {})
	if r is Dictionary:
		out.realised = {"gbp": int(r.get("gbp", 0)), "eur": int(r.get("eur", 0))}
	out.trades = int(raw.get("trades", 0))
	return out

static func events_of(data: GameStateData) -> Dictionary:
	return data.markets.get("ev", {})

## The keys sync() watches: every story flag a company or the pound reacts to.
static func story_keys() -> Array:
	var out := []
	for c in companies():
		for k in c.get("story", {}):
			if str(k) not in out:
				out.append(str(k))
	for k in Forex.STORY:
		if str(k) not in out:
			out.append(str(k))
	return out

## Notes the day each story flag, Stone and rewilding stage was first seen, so the markets react from then on.
## Returns the keys newly stamped (for the ticker).
static func sync(data: GameStateData) -> Array:
	if not data.markets.has("ev"):
		data.markets["ev"] = {}
	var ev: Dictionary = data.markets.ev
	var out := []
	var stamp := func(k: String):
		if not ev.has(k):
			ev[k] = data.day_count
			out.append(k)
	for k in story_keys():
		if data.flag(k) != null and data.flag(k) != false:
			stamp.call(k)
	for i in range(1, data.badges.size() + 1):
		stamp.call("badge:%d" % i)
	var stages := 0
	for s in Rewild.sites():
		stages += Rewild.stage(data, str(s.id))
	for i in range(1, stages + 1):
		stamp.call("rewild:%d" % i)
	return out

# --- the weather and the season (the same for everyone) ----------------------------------------------

static var _wseed := -1
static var _wet := PackedFloat64Array()
static var _wrng: RandomNumberGenerator

## How wet a day is across the isles: about -1.5 (glorious) to 1.5 (biblical), and it lingers a few days.
static func wet(seed_value: int, day: int) -> float:
	day = maxi(0, day)
	if seed_value != _wseed:
		_wseed = seed_value
		_wet = PackedFloat64Array([0.0])
		_wrng = RandomNumberGenerator.new()
		_wrng.seed = hash("wet:%d" % seed_value)
	while _wet.size() <= day:
		_wet.append(clampf(0.6 * _wet[_wet.size() - 1] + _wrng.randfn(0.0, 0.8), -1.5, 1.5))
	return _wet[day]

## 0 spring, 1 summer, 2 autumn, 3 winter (by in-game day).
static func season_of(day: int) -> int:
	return posmod(maxi(0, day) / SEASON_DAYS, 4)

# --- share prices -----------------------------------------------------------------------------------

static var _pseed := -1
static var _paths := {}   # id -> {"x": PackedFloat64Array (log price before shocks), "news": PackedFloat64Array, "rng"}

static func _extend(seed_value: int, c: Dictionary, day: int) -> Dictionary:
	if seed_value != _pseed:
		_pseed = seed_value
		_paths = {}
	var id := str(c.id)
	if not _paths.has(id):
		var r := RandomNumberGenerator.new()
		r.seed = hash("%s:%d" % [id, seed_value])
		_paths[id] = {"x": PackedFloat64Array([log(float(c.start)) + r.randfn(0.0, 0.04)]), "news": PackedFloat64Array([0.0]), "rng": r}
	var p: Dictionary = _paths[id]
	var x: PackedFloat64Array = p.x
	var nw: PackedFloat64Array = p.news
	var rng: RandomNumberGenerator = p.rng
	var vol := float(c.get("vol", 0.02))
	var season: Array = c.get("season", [0, 0, 0, 0])
	var wet_k := float(c.get("wet", 0.0))
	while x.size() <= day:
		var t := x.size()
		var jolt := 0.0
		if rng.randf() < NEWS_CHANCE:
			jolt = rng.randfn(0.0, vol * 3.0)
		var r := float(c.get("drift", 0.0)) + float(season[season_of(t)]) + wet_k * wet(seed_value, t) \
			- vol * vol * 0.5 + rng.randfn(0.0, vol) + jolt
		x.append(x[t - 1] + r)
		nw.append(jolt)
	p.x = x
	p.news = nw
	return p

## The story, Stone and rewilding shocks to a company's log price that have landed by `day`.
static func shock(c: Dictionary, day: int, events: Dictionary) -> float:
	var s := 0.0
	var story: Dictionary = c.get("story", {})
	var per_badge := float(c.get("badge", 0.0))
	var per_stage := float(c.get("rewild", 0.0))
	for k in events:
		if int(events[k]) > day:
			continue
		var key := str(k)
		if story.has(key):
			s += float(story[key])
		elif per_badge != 0.0 and key.begins_with("badge:"):
			s += per_badge
		elif per_stage != 0.0 and key.begins_with("rewild:"):
			s += per_stage
	return s

## A share's price (in its own currency) on `day`. Never below a penny.
static func price(seed_value: int, id: String, day: int, events := {}) -> float:
	var c := company(id)
	if c.is_empty():
		return 0.0
	day = maxi(0, day)
	var p := _extend(seed_value, c, day)
	return maxf(0.01, exp(p.x[day] + shock(c, day, events)))

static func price_for(data: GameStateData, id: String) -> float:
	return price(data.rng_seed, id, data.day_count, events_of(data))

static func history(seed_value: int, id: String, day: int, n: int, events := {}) -> Array:
	var out := []
	for d in range(day - n + 1, day + 1):
		out.append(price(seed_value, id, maxi(0, d), events))
	return out

## Today's move as a fraction of yesterday's price.
static func change(seed_value: int, id: String, day: int, events := {}) -> float:
	if day <= 0:
		return 0.0
	var y := price(seed_value, id, day - 1, events)
	return price(seed_value, id, day, events) / y - 1.0 if y > 0.0 else 0.0

static func currency_of(id: String) -> String:
	return str(company(id).get("currency", Wallet.GBP))

# --- dealing ---------------------------------------------------------------------------------------

static func commission(value: int, cur: String) -> int:
	return int(FEE_FLAT.get(cur, 4)) + roundi(maxi(0, value) * FEE_RATE)

## The most you may hold in one company, by value, in that company's currency.
static func cap(badges: int, cur: String) -> int:
	return Wallet.localise(CAP_BASE + CAP_PER_BADGE * maxi(0, badges), cur)

static func holding(data: GameStateData, id: String) -> Dictionary:
	return data.markets.get("h", {}).get(id, {"n": 0, "cost": 0, "since": 0})

## The most shares of `id` you could buy now: money (after commission) and the position cap both count.
static func max_buy(data: GameStateData, id: String) -> int:
	var cur := currency_of(id)
	var p := price_for(data, id)
	if p <= 0.0:
		return 0
	var held := int(holding(data, id).n)
	var by_cap := floori((cap(data.badges.size(), cur) - held * p) / p)
	var n := mini(by_cap, floori(Wallet.balance(data, cur) / p))
	while n > 0 and buy_cost(n, p, cur) > Wallet.balance(data, cur):
		n -= 1
	return maxi(0, n)

## The whole bill for `n` shares at `p`: their value rounded up, plus commission.
static func buy_cost(n: int, p: float, cur: String) -> int:
	var value := ceili(n * p - 0.000001)
	return value + commission(value, cur)

## What selling `n` shares at `p` pays out, after commission (never below nothing).
static func sell_proceeds(n: int, p: float, cur: String) -> int:
	var value := floori(n * p + 0.000001)
	return maxi(0, value - commission(value, cur))

## Buys `n` shares at today's price. {ok, why, n, cost (with fee), fee, cur}.
static func buy(data: GameStateData, id: String, n: int) -> Dictionary:
	var cur := currency_of(id)
	var out := {"ok": false, "why": "", "n": n, "cost": 0, "fee": 0, "cur": cur}
	if company(id).is_empty() or n <= 0:
		out.why = "Nothing to buy."
		return out
	if n > max_buy(data, id):
		var p := price_for(data, id)
		out.why = "That's over your limit for one company." if Wallet.balance(data, cur) >= buy_cost(n, p, cur) else "You'd need more %s for that." % Wallet.NAMES[cur]
		return out
	settle(data)  # any dividend due on what you hold is paid before the new shares join it
	var p2 := price_for(data, id)
	var cost := buy_cost(n, p2, cur)
	if not Wallet.spend(data, cost, cur):
		out.why = "You'd need more %s for that." % Wallet.NAMES[cur]
		return out
	var h: Dictionary = data.markets.h
	var e: Dictionary = h.get(id, {"n": 0, "cost": 0, "since": data.day_count})
	h[id] = {"n": int(e.n) + n, "cost": int(e.cost) + cost, "since": data.day_count}
	data.markets["trades"] = int(data.markets.get("trades", 0)) + 1
	out.ok = true
	out.cost = cost
	out.fee = commission(ceili(n * p2 - 0.000001), cur)
	return out

## Sells `n` shares at today's price. {ok, why, n, got, fee, profit, cur}.
static func sell(data: GameStateData, id: String, n: int) -> Dictionary:
	var cur := currency_of(id)
	var out := {"ok": false, "why": "", "n": n, "got": 0, "fee": 0, "profit": 0, "cur": cur}
	var e := holding(data, id)
	if n <= 0 or n > int(e.n):
		out.why = "You don't hold that many."
		return out
	settle(data)
	var p := price_for(data, id)
	var got := sell_proceeds(n, p, cur)
	var basis := roundi(int(e.cost) * float(n) / float(e.n))
	Wallet.earn(data, got, cur)
	var left := int(e.n) - n
	if left <= 0:
		data.markets.h.erase(id)
	else:
		data.markets.h[id] = {"n": left, "cost": int(e.cost) - basis, "since": int(e.since)}
	_realise(data, cur, got - basis)
	data.markets["trades"] = int(data.markets.get("trades", 0)) + 1
	out.ok = true
	out.got = got
	out.fee = commission(floori(n * p + 0.000001), cur)
	out.profit = got - basis
	return out

static func _realise(data: GameStateData, cur: String, amount: int) -> void:
	var r: Dictionary = data.markets.get("realised", {"gbp": 0, "eur": 0})
	r[cur] = int(r.get(cur, 0)) + amount
	data.markets["realised"] = r

## What your shares (and Doggerel) in `cur` are worth today at the middle price.
static func portfolio_value(data: GameStateData, cur: String) -> int:
	var v := 0.0
	for id in data.markets.get("h", {}):
		if currency_of(str(id)) == cur:
			v += int(data.markets.h[id].n) * price_for(data, str(id))
	if cur == str(coin().get("currency", Wallet.GBP)):
		v += coin_held(data) * coin_price_for(data)
	return floori(v)

## Pays the dividends that have fallen due since the last look, and empties a rug-pulled coin purse.
## Returns lines for the screen: [{kind: "dividend"|"rug", id, amount, cur, text}].
static func settle(data: GameStateData) -> Array:
	var out := []
	var today := data.day_count
	var last := int(data.markets.get("settled", -1))
	if last < 0:
		last = today
	var events := events_of(data)
	for id in data.markets.get("h", {}).keys():
		var c := company(str(id))
		var e: Dictionary = data.markets.h[id]
		var yield_y := float(c.get("div", 0.0))
		if c.is_empty() or yield_y <= 0.0:
			continue
		var total := 0
		for d in range(maxi(last, int(e.since)) + 1, today + 1):
			if d % DIVIDEND_EVERY == 0:
				total += floori(int(e.n) * price(data.rng_seed, str(id), d, events) * yield_y / 4.0)
		if total > 0:
			var cur := currency_of(str(id))
			Wallet.earn(data, total, cur)
			_realise(data, cur, total)
			out.append({"kind": "dividend", "id": str(id), "amount": total, "cur": cur,
				"text": "%s paid a dividend: %s." % [str(c.name), Wallet.fmt(total, cur)]})
	var ch: Dictionary = data.markets.get("coin", {})
	if int(ch.get("n", 0)) > 0 and int(ch.get("gen", 0)) != coin_state(data.rng_seed, today).gen:
		var lost := int(ch.get("cost", 0))
		_realise(data, str(coin().get("currency", Wallet.GBP)), -lost)
		out.append({"kind": "rug", "id": str(coin().get("id", "")), "amount": lost, "cur": str(coin().get("currency", Wallet.GBP)),
			"text": "The %s you held is gone: the developers pulled the rug. Your %d coins are now a lovely souvenir." % [coin_name(int(ch.get("gen", 0))), int(ch.n)]})
		data.markets["coin"] = {"n": 0, "cost": 0, "gen": coin_state(data.rng_seed, today).gen}
	data.markets["settled"] = today
	return out

# --- Doggerel ------------------------------------------------------------------------------------

static var _cseed := -1
static var _cgens: Array = []         # [{start, end (the rug day)}]
static var _cprice := PackedFloat64Array()
static var _cflag := PackedInt32Array()   # per day: 0 calm, 1 moon, -1 slump, 2 rug
static var _crng: RandomNumberGenerator

static func _coin_extend(seed_value: int, day: int) -> void:
	if seed_value != _cseed:
		_cseed = seed_value
		_cgens = []
		_cprice = PackedFloat64Array()
		_cflag = PackedInt32Array()
		_crng = RandomNumberGenerator.new()
		_crng.seed = hash("coin:%d" % seed_value)
	var c := coin()
	var vol := float(c.get("vol", 0.12))
	while _cprice.size() <= day:
		var t := _cprice.size()
		if _cgens.is_empty() or t > int(_cgens.back().end):
			var life := int(c.get("life_min", 10)) + floori(-log(maxf(0.0001, _crng.randf())) * float(c.get("life_mean", 26)))
			_cgens.append({"start": t, "end": t + life})
			_cprice.append(float(c.get("start", 1.0)) * exp(_crng.randfn(0.0, 0.3)))
			_cflag.append(0)
			continue
		var g: Dictionary = _cgens.back()
		var r := float(c.get("drift", -0.016)) - vol * vol * 0.5 + _crng.randfn(0.0, vol)
		var f := 0
		var u := _crng.randf()
		if u < float(c.get("moon_chance", 0.05)):
			r += float(c.get("moon", 0.45)) * (0.5 + _crng.randf())
			f = 1
		elif u > 0.96:
			r -= 0.35 * (0.5 + _crng.randf())
			f = -1
		var p := _cprice[t - 1] * exp(r)
		if t == int(g.end):
			p *= 0.02
			f = 2
		_cprice.append(clampf(p, 0.0001, 100000.0))
		_cflag.append(f)

static func _gen_at(day: int) -> int:
	for i in range(_cgens.size() - 1, -1, -1):
		if day >= int(_cgens[i].start):
			return i
	return 0

## {gen, name, price, start, flag (0 calm, 1 moon, -1 slump, 2 rug: the day it was pulled)} for `day`.
static func coin_state(seed_value: int, day: int) -> Dictionary:
	day = maxi(0, day)
	_coin_extend(seed_value, day)
	var g := _gen_at(day)
	return {"gen": g, "name": coin_name(g), "price": _cprice[day], "start": int(_cgens[g].start), "flag": _cflag[day]}

static func coin_name(gen: int) -> String:
	var eds: Array = coin().get("editions", ["Doggerel"])
	if gen < eds.size():
		return str(eds[gen])
	return "%s %d" % [str(eds[0]), gen + 1]

## A pulled coin trades at nothing; otherwise the day's price.
static func coin_price(seed_value: int, day: int) -> float:
	var s := coin_state(seed_value, day)
	return RUG_LEFT if int(s.flag) == 2 else float(s.price)

static func coin_price_for(data: GameStateData) -> float:
	return coin_price(data.rng_seed, data.day_count)

static func coin_history(seed_value: int, day: int, n: int) -> Array:
	var out := []
	for d in range(day - n + 1, day + 1):
		out.append(float(coin_state(seed_value, maxi(0, d)).price))
	return out

static func coin_held(data: GameStateData) -> int:
	var ch: Dictionary = data.markets.get("coin", {})
	if int(ch.get("gen", 0)) != coin_state(data.rng_seed, data.day_count).gen:
		return 0
	return int(ch.get("n", 0))

static func coin_cap(badges: int) -> int:
	return COIN_CAP_BASE + COIN_CAP_PER_BADGE * maxi(0, badges)

static func coin_ask(p: float) -> float:
	return p * (1.0 + COIN_SPREAD)

static func coin_bid(p: float) -> float:
	return p * (1.0 - COIN_SPREAD)

static func coin_buy_cost(n: int, p: float) -> int:
	return ceili(n * coin_ask(p) - 0.000001) + COIN_FEE

static func coin_sell_proceeds(n: int, p: float) -> int:
	return maxi(0, floori(n * coin_bid(p) + 0.000001) - COIN_FEE)

static func coin_max_buy(data: GameStateData) -> int:
	var p := coin_price_for(data)
	if p <= 0.0:
		return 0
	var cur := str(coin().get("currency", Wallet.GBP))
	var room := floori((coin_cap(data.badges.size()) - coin_held(data) * p) / coin_ask(p))
	var n := mini(room, floori((Wallet.balance(data, cur) - COIN_FEE) / coin_ask(p)))
	while n > 0 and coin_buy_cost(n, p) > Wallet.balance(data, cur):
		n -= 1
	return maxi(0, n)

static func coin_buy(data: GameStateData, n: int) -> Dictionary:
	var cur := str(coin().get("currency", Wallet.GBP))
	settle(data)
	var out := {"ok": false, "why": "", "n": n, "cost": 0, "cur": cur}
	var p := coin_price_for(data)
	if p <= 0.0:
		out.why = "Trading is suspended. The website is just a picture of a beach."
		return out
	if n <= 0 or n > coin_max_buy(data):
		out.why = "That's over your limit, or your purse." if n > 0 else "Nothing to buy."
		return out
	var cost := coin_buy_cost(n, p)
	if not Wallet.spend(data, cost, cur):
		out.why = "You'd need more sterling for that."
		return out
	var ch: Dictionary = data.markets.coin
	data.markets["coin"] = {"n": coin_held(data) + n, "cost": int(ch.get("cost", 0)) + cost, "gen": coin_state(data.rng_seed, data.day_count).gen}
	data.markets["trades"] = int(data.markets.get("trades", 0)) + 1
	out.ok = true
	out.cost = cost
	return out

static func coin_sell(data: GameStateData, n: int) -> Dictionary:
	var cur := str(coin().get("currency", Wallet.GBP))
	settle(data)
	var out := {"ok": false, "why": "", "n": n, "got": 0, "profit": 0, "cur": cur}
	var held := coin_held(data)
	var p := coin_price_for(data)
	if n <= 0 or n > held:
		out.why = "You don't hold that many."
		return out
	if p <= 0.0:
		out.why = "There's nobody left to sell to."
		return out
	var got := coin_sell_proceeds(n, p)
	var ch: Dictionary = data.markets.coin
	var basis := roundi(int(ch.cost) * float(n) / float(held))
	Wallet.earn(data, got, cur)
	data.markets["coin"] = {"n": held - n, "cost": int(ch.cost) - basis, "gen": int(ch.gen)}
	_realise(data, cur, got - basis)
	data.markets["trades"] = int(data.markets.get("trades", 0)) + 1
	out.ok = true
	out.got = got
	out.profit = got - basis
	return out

# --- the ticker -----------------------------------------------------------------------------------

static func _pick(list: Array, key: String) -> String:
	return str(list[posmod(hash(key), list.size())]) if not list.is_empty() else ""

## Today's headlines, most newsworthy first: story news stamped today, company news days, the pound, the weather,
## Doggerel. Always at least one line.
static func headlines(data: GameStateData, include_coin := true) -> Array:
	var seed_value := data.rng_seed
	var day := data.day_count
	var t := news_templates()
	var out := []
	var ev := events_of(data)
	var story: Dictionary = t.get("story", {})
	for k in ev:
		if int(ev[k]) == day and story.has(str(k)):
			out.append(str(story[k]))
	for c in companies():
		var p := _extend(seed_value, c, day)
		var j: float = p.news[day] if day > 0 else 0.0
		if absf(j) > float(c.get("vol", 0.02)) * 1.5:
			out.append(_pick(t.get("up" if j > 0.0 else "down", []), "%s:%d" % [c.id, day]).replace("{name}", str(c.name)))
	var fx := Forex.news(seed_value, day, t)
	if fx != "":
		out.append(fx)
	var w := wet(seed_value, day)
	if absf(w) > 1.0:
		out.append(_pick(t.get("wet" if w > 0.0 else "dry", []), "w:%d:%d" % [seed_value, day]))
	if include_coin:
		var cs := coin_state(seed_value, day)
		var key: String = {2: "coin_rug", 1: "coin_moon", -1: "coin_dump"}.get(int(cs.flag), "")
		if key != "":
			var nm := str(cs.name) if int(cs.flag) != 2 else coin_name(maxi(0, int(cs.gen)))
			out.append(_pick(t.get(key, []), "c:%d:%d" % [seed_value, day]).replace("{coin}", nm))
	if out.is_empty():
		out.append(_pick(t.get("quiet", []), "q:%d:%d" % [seed_value, day]))
	return out
