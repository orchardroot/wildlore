class_name Rules
extends RefCounted
## Shared game constants. Data files and the battle engine both validate against these.

const STATS := ["hp", "atk", "def", "lore", "ward", "spd"]
const STAGE_STATS := ["atk", "def", "lore", "ward", "spd", "acc"]
const STATUSES := ["soaked", "chilled", "muddled", "hexed", "stung", "asleep"]
const GROWTH_RATES := ["fast", "medium", "slow"]
const CATEGORIES := ["physical", "special", "status"]
const EFFECTS := ["none", "stat", "status"]
const WEATHERS := ["clear", "drizzle", "downpour", "fog", "gale", "frost", "sunshine"]
const MAX_LEVEL := 100
const MAX_MOVES := 4
const IV_MAX := 15
const TRAINING_STAT_CAP := 100
const TRAINING_TOTAL_CAP := 300

## nature -> [raised stat, lowered stat]; empty means neutral. "steady" must stay first (tests rely on it).
const NATURES := {
	"steady": [], "chipper": [],
	"brash": ["atk", "def"], "stubborn": ["atk", "lore"],
	"hardy": ["def", "lore"], "wary": ["def", "spd"],
	"canny": ["lore", "atk"], "dreamy": ["lore", "spd"],
	"gentle": ["ward", "atk"], "stoic": ["ward", "spd"],
	"cheeky": ["spd", "def"], "plucky": ["spd", "ward"],
}

## Total XP needed to be at `level`.
static func xp_for_level(growth: String, level: int) -> int:
	if level <= 1:
		return 0
	var cube := level * level * level
	match growth:
		"fast":
			return int(cube * 0.8)
		"slow":
			return int(cube * 1.25)
		_:
			return cube
