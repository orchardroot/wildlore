class_name MarketSim
extends RefCounted
## Plays naive strategies against the real markets (Markets, Forex) over a typical playthrough, many seeds over,
## to check the balance: shares drift a little up, Doggerel loses on average with huge swings, the bureau's
## spread eats round trips, and nothing prints money. tools/dev/market_sim.gd prints the table for 1,000 runs;
## tests/core/test_market_balance.gd checks a smaller run. Pure logic.

const DAYS := 90          # about a playthrough: a game minute is a real second, so 90 in-game days is ~36 hours
const VISIT_EVERY := 6    # a market visit every few in-game days
const START := 5000       # pounds in the purse
const STRATEGIES := ["index", "vane_hold", "momentum", "random", "coin_hodl", "coin_flip", "fx_round", "fx_timer"]
## When the story turns land in a typical run (in-game day).
const STORY_DAYS := {"badge_urban": 12, "bev_bike_given": 14, "badge_stone": 20, "ch3_ddraig_woke": 22, "ashcombe1_done": 30,
	"ashcombe2_done": 34, "visited_dublin": 38, "badge_kin": 42, "kerrigan1_done": 46, "badge_tide": 50, "ch7_judged": 54,
	"badge_iron": 58, "ch8_vane": 62, "ch9_started": 64, "badge_frost": 70, "strachan2_done": 72, "moot_won": 84, "game_complete": 88}

static func events_until(day: int) -> Dictionary:
	var ev := {}
	for k in STORY_DAYS:
		if int(STORY_DAYS[k]) <= day:
			ev[k] = STORY_DAYS[k]
	for n in range(1, 11):
		if n * 8 <= day:
			ev["badge:%d" % n] = n * 8
	return ev

static func _setup(d: GameStateData, day: int) -> void:
	d.day_count = day
	d.markets["ev"] = events_until(day)
	d.badges = []
	for n in range(1, 11):
		if n * 8 <= day:
			d.badges.append("b%d" % n)

## Everything in sterling at the day's middle prices.
static func worth(d: GameStateData) -> float:
	var m := Forex.mid_for(d)
	return d.money + (d.euros + Markets.portfolio_value(d, Wallet.EUR)) / m + Markets.portfolio_value(d, Wallet.GBP)

static func _sell_all(d: GameStateData) -> void:
	for id in d.markets.h.keys():
		Markets.sell(d, str(id), int(d.markets.h[id].n))
	if Markets.coin_held(d) > 0:
		Markets.coin_sell(d, Markets.coin_held(d))

static func _buy_value(d: GameStateData, id: String, pounds: int) -> void:
	var n := mini(Markets.max_buy(d, id), floori(pounds / maxf(0.01, Markets.price_for(d, id))))
	if n > 0:
		Markets.buy(d, id, n)

## One run: the change in wealth (sterling) as a fraction of the start.
static func run(strategy: String, seed_value: int) -> float:
	var d := GameStateData.new()
	d.rng_seed = seed_value
	d.money = START
	d.zone_id = "london"
	d.markets = Markets.fresh()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("sim:%d" % seed_value)
	var gbp: Array = Markets.listings("london")
	var visit := VISIT_EVERY
	while visit < DAYS:
		_setup(d, visit)
		Markets.settle(d)
		match strategy:
			"index":
				if visit == VISIT_EVERY:
					for id in gbp:
						_buy_value(d, str(id), START / gbp.size() - 20)
			"vane_hold":
				if visit == VISIT_EVERY:
					_buy_value(d, "VNI", 1500)
			"momentum":
				_sell_all(d)
				var best := ""
				var best_m := -INF
				for id in gbp:
					var m := Markets.change(seed_value, str(id), visit, d.markets.ev)
					if m > best_m:
						best_m = m
						best = str(id)
				_buy_value(d, best, 2000)
			"random":
				var id: String = gbp[rng.randi_range(0, gbp.size() - 1)]
				if rng.randf() < 0.5 or Markets.holding(d, id).n == 0:
					_buy_value(d, id, 500)
				else:
					Markets.sell(d, id, int(Markets.holding(d, id).n))
			"coin_hodl":
				if visit == VISIT_EVERY or Markets.coin_held(d) == 0:
					var n := Markets.coin_max_buy(d)
					if n > 0 and visit == VISIT_EVERY:
						Markets.coin_buy(d, n)
			"coin_flip":
				if Markets.coin_held(d) > 0:
					Markets.coin_sell(d, Markets.coin_held(d))
				var n2 := Markets.coin_max_buy(d)
				if n2 > 0:
					Markets.coin_buy(d, n2)
			"fx_round":
				if d.euros > 0:
					Forex.exchange(d, d.euros, Wallet.EUR)
				Forex.exchange(d, 500, Wallet.GBP)
			"fx_timer":
				var mid := Forex.mid_for(d)
				if mid > 1.20 and d.money > 1000:
					Forex.exchange(d, 1000, Wallet.GBP)
				elif mid < 1.15 and d.euros > 0:
					Forex.exchange(d, d.euros, Wallet.EUR)
		visit += VISIT_EVERY
	_setup(d, DAYS)
	Markets.settle(d)
	_sell_all(d)
	if d.euros > 0:
		Forex.exchange(d, d.euros, Wallet.EUR)
	return worth(d) / START - 1.0

## {strategy: {mean, median, p5, p95, lose (fraction of runs that lost), best}} over `runs` seeds.
static func table(runs: int, first_seed := 1) -> Dictionary:
	var res := {}
	for s in STRATEGIES:
		res[s] = []
	for i in runs:
		for s in STRATEGIES:
			res[s].append(run(s, first_seed + i))
	var out := {}
	for s in STRATEGIES:
		var v: Array = res[s]
		v.sort()
		var sum := 0.0
		var lose := 0
		for x in v:
			sum += x
			if x < 0.0:
				lose += 1
		out[s] = {"mean": sum / v.size(), "median": v[v.size() / 2], "p5": v[int(v.size() * 0.05)], "p95": v[int(v.size() * 0.95)],
			"lose": float(lose) / v.size(), "best": v.back(), "worst": v[0]}
	return out
