class_name Forecasting
extends RefCounted
## The forecaster's chart challenge (4.5, Land and Sky): read a synoptic chart and say which way the wind blows and
## what the sky will do. The wind follows from where the pressure centre sits (Buys Ballot's law: anticlockwise round
## a low, clockwise round a high, in the northern hemisphere); the weather follows from the isobar spacing, the
## nearest front, the air and the season. A round is three practice charts from data/forecasting.json plus "today's
## chart", the one behind the weather the game is actually running (it matches the Shipping Forecast synopses in
## world/forecast.gd), two questions each. Pure logic: ui/forecasting_screen.gd shows it and story/forecast_run.gd
## pays out. Flags: forecast_best (best score), forecast_passes (rounds passed), forecast_prize (the DailyKey stamp
## of the day's prize), landsky_pressure (a round finished, for the Almanac's Land and Sky page).

const PATH := "res://data/forecasting.json"
## Compass points clockwise from north; a centre may also be "over" (right over Britain).
const BEARINGS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
const WINDS := ["northerly", "north-easterly", "easterly", "south-easterly", "southerly", "south-westerly", "westerly", "north-westerly"]
const LIGHT := "light and variable"
const CENTRES := ["low", "high"]
const SPACINGS := ["tight", "moderate", "loose"]
const FRONTS := ["none", "warm", "cold"]
const AIRS := ["moist", "dry"]
const SEASONS := ["spring", "summer", "autumn", "winter", "any"]
const WEATHERS := ["clear", "sunshine", "drizzle", "downpour", "fog", "gale", "frost"]
const WEATHER_NAMES := {"clear": "Clear", "sunshine": "Sunshine", "drizzle": "Drizzle", "downpour": "Downpour",
	"fog": "Fog", "gale": "Gale", "frost": "Frost"}
## What the isobar spacing means on the Beaufort scale.
const FORCE := {"tight": "force 7 to 9, gale", "moderate": "force 4 to 6", "loose": "force 1 to 3"}
const PRACTICE := 3        # practice charts in a round, then today's
const PER_CHART := 2       # the wind, then the weather
const OPTIONS := 4
const FLAG_BEST := "forecast_best"
const FLAG_PASSES := "forecast_passes"
const FLAG_PRIZE := "forecast_prize"
const FLAG_MET := "landsky_pressure"

static var _db: Dictionary = {}

static func _all() -> Dictionary:
	if _db.is_empty():
		var d = JsonUtil.read(PATH)
		_db = d if d is Dictionary else {"charts": [], "today": {}}
	return _db

static func charts() -> Array:
	return _all().get("charts", [])

static func chart(id: String) -> Dictionary:
	for c in charts():
		if str(c.get("id", "")) == id:
			return c
	return {}

## The chart behind the weather the game is running now (clear for anything unknown).
static func today(weather: String) -> Dictionary:
	var t: Dictionary = _all().get("today", {})
	return t.get(weather, t.get("clear", {}))

static func pass_mark() -> int:
	return int(_all().get("pass", 5))

static func total() -> int:
	return (PRACTICE + 1) * PER_CHART

# --- the rules ---------------------------------------------------------------------

## Where the wind comes from with a `centre` ("low" or "high") lying at `bearing` from Britain. Round a low the
## air turns anticlockwise, so the wind is from a quarter turn anticlockwise of the centre's bearing: a low to the
## north-west gives a south-westerly. Round a high it is a quarter turn clockwise: a high to the north gives an
## easterly. Right over Britain the isobars are far apart and it is light and variable.
static func wind_for(centre: String, bearing: String) -> String:
	var i := BEARINGS.find(bearing)
	if i < 0:
		return LIGHT
	return WINDS[posmod(i + (6 if centre == "low" else 2), 8)]

## The chart's wind in the forecast's words: "south-westerly, force 7 to 9, gale".
static func wind_line(c: Dictionary) -> String:
	var w := wind_for(str(c.get("centre", "")), str(c.get("bearing", "")))
	if w == LIGHT:
		return LIGHT + ", force 1 to 3"
	return "%s, %s" % [w, FORCE.get(str(c.get("spacing", "moderate")), FORCE.moderate)]

## The sky a chart gives: tight isobars mean a gale; a cold front means heavy showers and a warm front steady
## drizzle (a low with neither is grey and damp); under a high, damp air makes fog, a winter night a frost, summer
## sunshine, and otherwise it is simply clear.
static func rule_weather(c: Dictionary) -> String:
	if str(c.get("centre", "")) == "low":
		if str(c.get("spacing", "")) == "tight":
			return "gale"
		return "downpour" if str(c.get("front", "")) == "cold" else "drizzle"
	if str(c.get("air", "")) == "moist":
		return "fog"
	match str(c.get("season", "")):
		"winter":
			return "frost"
		"summer":
			return "sunshine"
	return "clear"

## "Low, Rockall, 976, deepening, moving east": the synopsis line of the chart, as the radio would read it.
static func synopsis(c: Dictionary) -> String:
	var centre := str(c.get("centre", "low")).capitalize()
	return "%s, %s, %d, %s" % [centre, str(c.get("place", "")), int(c.get("pressure", 1000)), str(c.get("trend", "slow-moving"))]

static func weather_name(w: String) -> String:
	return str(WEATHER_NAMES.get(w, w.capitalize()))

# --- a round ------------------------------------------------------------------------

## `n` practice charts with no repeats and, when the pool allows, at least one low and one high.
static func pick_round(rng: Rng, n := PRACTICE) -> Array:
	var pool: Array = charts().duplicate()
	var out := []
	while out.size() < n and not pool.is_empty():
		var i := rng.roll_int(0, pool.size() - 1)
		out.append(pool[i])
		pool.remove_at(i)
	# the last pick swaps for the other kind if the round came out all one way
	if out.size() >= 2 and not pool.is_empty():
		var kinds := {}
		for c in out:
			kinds[str(c.get("centre", ""))] = true
		if kinds.size() == 1:
			var want := "high" if kinds.has("low") else "low"
			var others := pool.filter(func(c): return str(c.get("centre", "")) == want)
			if not others.is_empty():
				out[out.size() - 1] = others[rng.roll_int(0, others.size() - 1)]
	return out

## `right` plus three others from `pool`, shuffled: {options, answer}.
static func _options(right: String, pool: Array, rng: Rng) -> Dictionary:
	var others: Array = pool.filter(func(x): return str(x) != right)
	var opts := [right]
	while opts.size() < OPTIONS and not others.is_empty():
		opts.append(others.pop_at(rng.roll_int(0, others.size() - 1)))
	for i in range(opts.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = opts[i]
		opts[i] = opts[j]
		opts[j] = t
	return {"options": opts, "answer": opts.find(right)}

## The wind question for a chart: {q, options, answer, why}.
static func wind_question(c: Dictionary, rng: Rng) -> Dictionary:
	var right := wind_for(str(c.get("centre", "")), str(c.get("bearing", "")))
	var o := _options(right, WINDS + [LIGHT], rng)
	return {"q": "Which way is the wind blowing over Britain?", "options": o.options, "answer": o.answer,
		"why": str(c.get("why_wind", "")), "kind": "wind"}

## The weather question for a chart: {q, options, answer, why}; options are the pretty names.
static func weather_question(c: Dictionary, rng: Rng) -> Dictionary:
	var right := str(c.get("weather", "clear"))
	var o := _options(right, WEATHERS, rng)
	return {"q": "And what does the sky do?", "options": o.options.map(func(w): return weather_name(str(w))),
		"answer": o.answer, "why": str(c.get("why_weather", "")), "kind": "weather"}

## A whole round: [{chart, questions: [wind, weather], today: bool}], practice first, today's chart last.
static func build_round(rng: Rng, actual_weather: String) -> Array:
	var out := []
	for c in pick_round(rng):
		out.append({"chart": c, "questions": [wind_question(c, rng), weather_question(c, rng)], "today": false})
	var t := today(actual_weather)
	if not t.is_empty():
		out.append({"chart": t, "questions": [wind_question(t, rng), weather_question(t, rng)], "today": true})
	return out

static func passed(score: int) -> bool:
	return score >= pass_mark()

## The forecaster's verdict on a finished round.
static func reaction(score: int, total_marks: int) -> String:
	if score >= total_marks:
		return "Full marks. I'd offer you a job, but the chair's taken and the kettle's temperamental."
	if passed(score):
		return "A pass. You'd get the gist of a chart on the evening news, which is more than most."
	if score > 0:
		return "Not quite. Back to the wind, low on your left: say it in the shower until it sticks."
	return "Nought. The weather is hard. That's why we have a supercomputer and a lot of tea."

# --- state and prizes ---------------------------------------------------------------

static func _int_flag(data: GameStateData, key: String) -> int:
	var v: Variant = data.flag(key)
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else 0

static func best(data: GameStateData) -> int:
	return _int_flag(data, FLAG_BEST)

static func passes(data: GameStateData) -> int:
	return _int_flag(data, FLAG_PASSES)

## Books a finished round: the best score, the passes and the Land and Sky note. {passed, first_pass, best}.
static func record(data: GameStateData, score: int) -> Dictionary:
	var ok := passed(score)
	var first := ok and passes(data) == 0
	data.set_flag(FLAG_MET, true)
	if score > best(data):
		data.set_flag(FLAG_BEST, score)
	if ok:
		data.set_flag(FLAG_PASSES, passes(data) + 1)
	return {"passed": ok, "first_pass": first, "best": best(data)}

## The day's prize in sterling for a passed round (full marks pays more), once a real day; 0 when not earned.
static func prize(data: GameStateData, score: int, total_marks: int) -> int:
	if not passed(score) or DailyKey.done_today(data, FLAG_PRIZE):
		return 0
	data.set_flag(FLAG_PRIZE, DailyKey.stamp(data))
	return int(_all().get("prize_full", 600)) if score >= total_marks else int(_all().get("prize", 300))

# --- data checks ----------------------------------------------------------------------

## Problems with data/forecasting.json: shapes, known values, the weather agreeing with the rules, no em-dashes.
static func check() -> Array:
	var e := []
	var ids := {}
	var list: Array = charts()
	if list.size() < PRACTICE + 1:
		e.append("forecasting: fewer than %d practice charts" % (PRACTICE + 1))
	for c in list:
		e.append_array(_check_chart(c, true))
		var id := str(c.get("id", ""))
		if ids.has(id):
			e.append("forecasting: chart id '%s' twice" % id)
		ids[id] = true
	var t: Dictionary = _all().get("today", {})
	for w in WEATHERS:
		if not t.has(w):
			e.append("forecasting: no today chart for '%s'" % w)
		else:
			e.append_array(_check_chart(t[w], false))
			if str(t[w].get("weather", "")) != w:
				e.append("forecasting: today chart for '%s' gives '%s'" % [w, t[w].get("weather", "")])
	return e

static func _check_chart(c: Dictionary, by_rule: bool) -> Array:
	var e := []
	var tag := "forecasting: chart '%s'" % str(c.get("id", "?"))
	if str(c.get("centre", "")) not in CENTRES:
		e.append(tag + " has centre '%s'" % c.get("centre", ""))
	if str(c.get("bearing", "")) not in BEARINGS + ["over"]:
		e.append(tag + " has bearing '%s'" % c.get("bearing", ""))
	if str(c.get("spacing", "")) not in SPACINGS:
		e.append(tag + " has spacing '%s'" % c.get("spacing", ""))
	if str(c.get("front", "")) not in FRONTS:
		e.append(tag + " has front '%s'" % c.get("front", ""))
	if str(c.get("air", "")) not in AIRS:
		e.append(tag + " has air '%s'" % c.get("air", ""))
	if str(c.get("season", "")) not in SEASONS:
		e.append(tag + " has season '%s'" % c.get("season", ""))
	if str(c.get("weather", "")) not in WEATHERS:
		e.append(tag + " has weather '%s'" % c.get("weather", ""))
	elif by_rule and str(c.weather) != rule_weather(c):
		e.append(tag + " says '%s' but the rules give '%s'" % [c.weather, rule_weather(c)])
	if str(c.get("centre", "")) == "high" and str(c.get("front", "none")) != "none":
		e.append(tag + " is a high with a front")
	if int(c.get("pressure", 0)) < 940 or int(c.get("pressure", 0)) > 1060:
		e.append(tag + " has an unlikely pressure %d" % int(c.get("pressure", 0)))
	for k in ["title", "place", "trend", "why_wind", "why_weather"]:
		if str(c.get(k, "")).strip_edges() == "":
			e.append(tag + " has no %s" % k)
		if "—" in str(c.get(k, "")):
			e.append(tag + " has an em-dash in %s" % k)
	return e
