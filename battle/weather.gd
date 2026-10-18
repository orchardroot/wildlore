class_name Weather
extends RefCounted
## Battle effects of British weather.

const DAMAGE := {
	"drizzle": {"brook": 1.1, "tide": 1.1},
	"downpour": {"brook": 1.5, "tide": 1.5, "hearth": 0.5},
	"gale": {"gale": 1.3},
	"frost": {"frost": 1.3, "hearth": 0.8},
	"sunshine": {"hearth": 1.5, "hedgerow": 1.5, "brook": 0.8},
}

static func damage_mod(weather: String, move_type: String) -> float:
	return float(DAMAGE.get(weather, {}).get(move_type, 1.0))

static func accuracy_mod(weather: String) -> float:
	return 0.85 if weather == "fog" else 1.0

## Sunshine is rare enough that everyone gets giddy: double crit chance, for both sides (and the plate says so).
static func crit_mult(weather: String, _side: int) -> float:
	return 2.0 if weather == "sunshine" else 1.0

## What the weather does to each type, for the HUD: [{"type", "text": "Brook +50%", "up": bool}], boosts first.
static func effects(weather: String) -> Array:
	var ups := []
	var downs := []
	var table: Dictionary = DAMAGE.get(weather, {})
	for t in table:
		var pct := int(round((float(table[t]) - 1.0) * 100.0))
		var e := {"type": t, "text": "%s %s%d%%" % [str(t).capitalize(), "+" if pct > 0 else "-", absi(pct)], "up": pct > 0}
		(ups if pct > 0 else downs).append(e)
	return ups + downs

## The weather's rule that isn't about types, in a few words ("" if none).
static func note(weather: String) -> String:
	match weather:
		"sunshine": return "Critical hits twice as likely, both sides"
		"fog": return "Every move 15% less likely to land"
	return ""

## How much stronger a move hits in this weather: its type's weather multiplier times its own weather bonus.
## Status moves count only their bonus (a heal that heals more), so 1.0 means the weather leaves it alone.
static func move_mult(weather: String, move: Dictionary) -> float:
	var m := 1.0
	if str(move.get("category", "status")) != "status" and int(move.get("power", 0)) > 0:
		m = damage_mod(weather, str(move.get("type", "")))
	if MoveFX.bonus_applies(move, weather):
		m *= float(move.weather_bonus.get("mult", 1.0))
	return m

## "Stronger in Sunshine", "Weaker in a Downpour" or "" for the move menu.
static func move_tag(weather: String, move: Dictionary) -> String:
	var m := move_mult(weather, move)
	if is_equal_approx(m, 1.0):
		return ""
	var where: String = MoveFX.WEATHER_WORDS.get(weather, [weather, weather])[1]
	where = "a " + where.substr(2).capitalize() if where.begins_with("a ") else where.capitalize()
	return "%s in %s" % ["Stronger" if m > 1.0 else "Weaker", where]

## Weighted pick from {weather: weight}. Empty or all-zero tables give "clear".
static func pick(table: Dictionary, rng: Rng) -> String:
	var total := 0.0
	for w in table:
		total += float(table[w])
	if total <= 0.0:
		return "clear"
	var r := rng.roll() * total
	for w in table:
		r -= float(table[w])
		if r < 0.0:
			return w
	for w in table:
		if float(table[w]) > 0.0:
			return w
	return "clear"
