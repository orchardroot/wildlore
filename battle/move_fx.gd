class_name MoveFX
extends RefCounted
## The 2.0 move effects and weather bonuses as pure helpers. Battle turns them into events.
##
## Effect ids (move "effect"):
##   drain {frac}: the user heals frac% of the damage it dealt.  recoil {frac}: the user takes frac% of it.
##   multi_hit {hits} or {min, max}: strikes several times (2 to 5: 35/35/15/15%).
##   heal_self {frac}: the user heals frac% of its max HP.  protect: blocks foes' moves this turn, fails twice running.
##   flinch {chance}: the target loses its turn, only if the user moved first.
##   set_weather {weather, turns?}: the battle weather for 5 turns (counting this one), then back to the zone's.
##   cure_team: clears the status of every creature on the user's side.
## A move may also carry "weather_bonus": {"weather": [...], "mult": x, "sure_hit": bool}: in that weather its
## power (or, for a healing move, its healing) is multiplied by mult, and with sure_hit it never misses.

const DEFAULT_TURNS := 5
## Effects that only ever act on the user's side (or the field), whatever the data says.
const SELF_EFFECTS := ["heal_self", "protect", "set_weather", "cure_team"]

## Weather names for messages and the HUD: [noun as a label, phrase "in ..."].
const WEATHER_WORDS := {
	"clear": ["Clear skies", "clear skies"], "drizzle": ["Drizzle", "drizzle"], "downpour": ["Downpour", "a downpour"],
	"fog": ["Fog", "fog"], "gale": ["Gale", "a gale"], "frost": ["Frost", "a frost"], "sunshine": ["Sunshine", "sunshine"],
}

static func bonus_applies(move: Dictionary, weather: String) -> bool:
	var wb: Dictionary = move.get("weather_bonus", {})
	return not wb.is_empty() and weather in wb.get("weather", [])

## A damaging move's power in this weather.
static func power_in(move: Dictionary, weather: String) -> int:
	var p := int(move.get("power", 0))
	if bonus_applies(move, weather) and str(move.get("category", "")) != "status":
		return int(round(p * float(move.weather_bonus.get("mult", 1.0))))
	return p

## True when the weather makes this move unmissable.
static func sure_in(move: Dictionary, weather: String) -> bool:
	return bonus_applies(move, weather) and bool(move.weather_bonus.get("sure_hit", false))

## Percent of max HP a heal_self move restores in this weather (never above 100).
static func heal_frac(move: Dictionary, weather: String) -> int:
	var frac := int(move.get("effect", {}).get("frac", 50))
	if bonus_applies(move, weather):
		frac = int(round(frac * float(move.weather_bonus.get("mult", 1.0))))
	return clampi(frac, 1, 100)

## How many times a multi_hit move strikes: a fixed "hits", or min..max (2 to 5 weighted toward the low end).
static func roll_hits(fx: Dictionary, rng: Rng) -> int:
	if fx.has("hits"):
		return maxi(1, int(fx.hits))
	var lo := int(fx.get("min", 2))
	var hi := int(fx.get("max", 5))
	if lo == 2 and hi == 5:
		var r := rng.roll()
		if r < 0.35:
			return 2
		if r < 0.7:
			return 3
		return 4 if r < 0.85 else 5
	return rng.roll_int(lo, hi)

## Average number of hits, for the AI's sums.
static func average_hits(fx: Dictionary) -> float:
	if fx.get("id", "") != "multi_hit":
		return 1.0
	if fx.has("hits"):
		return float(fx.hits)
	var lo := int(fx.get("min", 2))
	var hi := int(fx.get("max", 5))
	return 3.1 if lo == 2 and hi == 5 else (lo + hi) / 2.0

static func weather_label(w: String) -> String:
	return str(WEATHER_WORDS.get(w, [w.capitalize(), w])[0])

static func weather_phrase(w: String) -> String:
	return str(WEATHER_WORDS.get(w, [w, w])[1])

## "drizzle or fog", "a downpour", for move descriptions.
static func weather_list(ws: Array) -> String:
	var bits: Array = ws.map(func(w): return weather_phrase(str(w)))
	if bits.size() <= 1:
		return "".join(bits)
	return ", ".join(bits.slice(0, bits.size() - 1)) + " or " + str(bits.back())

## Data errors for one move's 2.0 effect and weather bonus (the validator calls this).
static func check(m: Dictionary) -> Array:
	var e := []
	var id := str(m.get("id", "?"))
	var fx: Dictionary = m.get("effect", {})
	match str(fx.get("id", "")):
		"drain", "recoil":
			if int(fx.get("frac", 0)) < 1 or int(fx.get("frac", 0)) > 100:
				e.append("move %s: %s needs frac 1..100" % [id, fx.id])
			if str(m.get("category", "")) == "status":
				e.append("move %s: %s needs a damaging move" % [id, fx.id])
		"multi_hit":
			if fx.has("hits"):
				if int(fx.hits) < 2 or int(fx.hits) > 5:
					e.append("move %s: multi_hit hits must be 2..5" % id)
			elif int(fx.get("min", 2)) < 1 or int(fx.get("max", 5)) < int(fx.get("min", 2)) or int(fx.get("max", 5)) > 5:
				e.append("move %s: multi_hit needs 1 <= min <= max <= 5" % id)
		"heal_self":
			if int(fx.get("frac", 0)) < 1 or int(fx.get("frac", 0)) > 100:
				e.append("move %s: heal_self needs frac 1..100" % id)
		"set_weather":
			if str(fx.get("weather", "")) not in Rules.WEATHERS:
				e.append("move %s: unknown weather '%s'" % [id, fx.get("weather", "")])
	var wb: Variant = m.get("weather_bonus", {})
	if not (wb is Dictionary):
		e.append("move %s: weather_bonus must be an object" % id)
	elif not wb.is_empty():
		for w in wb.get("weather", []):
			if str(w) not in Rules.WEATHERS:
				e.append("move %s: weather_bonus has unknown weather '%s'" % [id, w])
		if not wb.has("mult") and not bool(wb.get("sure_hit", false)):
			e.append("move %s: weather_bonus needs a mult or sure_hit" % id)
	return e
