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

## Sunshine is rare enough that the player's side gets giddy: double crit chance.
static func crit_mult(weather: String, side: int) -> float:
	return 2.0 if weather == "sunshine" and side == 0 else 1.0

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
