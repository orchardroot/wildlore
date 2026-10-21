class_name WeeklyChallenge
extends RefCounted
## The weekly seeded challenge: every real week (Monday to Sunday) has one fixed seed and one set of rules, the same
## for everybody, and a run is summed up in a short result code to post and compare. No network: the code is
## deterministic (same week and same tallies, same code) and carries a checksum so a mistyped one is caught.
## Pure logic; the Stats page shows it.

const NATIONS := ["wales", "scotland", "ireland", "england", "mann", "channel_islands", "northern_ireland"]
const NATION_NAMES := {"wales": "Wales", "scotland": "Scotland", "ireland": "Ireland", "england": "England", "mann": "the Isle of Man",
	"channel_islands": "the Channel Islands", "northern_ireland": "Northern Ireland"}
const LEVEL_CAPS := [20, 30, 40, 50]
const TWISTS := ["one creature per type", "no healing items in battle", "no held items", "nothing caught twice", "walk it, no trains or ferries"]
const ALPHABET := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"  # Crockford base 32: no I, L, O or U to misread

## Whole weeks (Monday start) since 1969-12-29, from a "YYYY-MM-DD" key.
static func week_number(date_key: String) -> int:
	var p := date_key.split("-")
	if p.size() != 3:
		return 0
	var unix := Time.get_unix_time_from_datetime_dict({"year": int(p[0]), "month": int(p[1]), "day": int(p[2]), "hour": 12, "minute": 0, "second": 0})
	return (int(unix) / 86400 + 3) / 7  # 1970-01-01 was a Thursday

static func this_week() -> int:
	return week_number(Calendar.today_key())

## 32-bit FNV-1a, so seeds never depend on the engine's string hash.
static func fnv(text: String) -> int:
	var h := 2166136261
	for b in text.to_utf8_buffer():
		h = ((h ^ b) * 16777619) & 0xFFFFFFFF
	return h

static func seed_for(week: int) -> int:
	return fnv("wildlore-week-%d" % week)

## The rules for a week: {week, seed, nation, level_cap, twist}.
static func rules(week: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for(week)
	return {"week": week, "seed": seed_for(week), "nation": NATIONS[rng.randi() % NATIONS.size()],
		"level_cap": LEVEL_CAPS[rng.randi() % LEVEL_CAPS.size()], "twist": TWISTS[rng.randi() % TWISTS.size()]}

## "Wales only, level cap 30, one creature per type".
static func describe(r: Dictionary) -> String:
	return "%s only, level cap %d, %s" % [NATION_NAMES.get(r.nation, "England"), r.level_cap, r.twist]

## The tallies a result is made of, read off the save.
static func tallies(data: GameStateData) -> Dictionary:
	return {"caught": TrainerStats.get_count(data, "caught"), "wins": TrainerStats.get_count(data, "wins_wild") + TrainerStats.get_count(data, "wins_trainer"),
		"steps": TrainerStats.get_count(data, "steps")}

## "WL2900-<8 chars>-<2>": week, the tallies packed in base 32, a two-character checksum.
static func result_code(week: int, t: Dictionary) -> String:
	var caught := clampi(int(t.get("caught", 0)), 0, 1023)
	var wins := clampi(int(t.get("wins", 0)), 0, 4095)
	var steps := clampi(int(t.get("steps", 0)) / 100, 0, 16383)  # hundreds of steps
	var packed := (caught << 26) | (wins << 14) | steps
	var body := ""
	for i in 8:
		body = ALPHABET[(packed >> (5 * i)) & 31] + body
	return "WL%d-%s-%s" % [week, body, _check(week, body)]

static func _check(week: int, body: String) -> String:
	var h := fnv("%d|%s|%d" % [week, body, seed_for(week)])
	return ALPHABET[h & 31] + ALPHABET[(h >> 5) & 31]

## Reads a code back: {week, caught, wins, steps} (steps to the nearest hundred), or {} if it is not a genuine code.
static func read_code(code: String) -> Dictionary:
	var s := code.strip_edges().to_upper()
	var parts := s.split("-")
	if parts.size() != 3 or not parts[0].begins_with("WL") or not parts[0].substr(2).is_valid_int() or parts[1].length() != 8 or parts[2].length() != 2:
		return {}
	var week := int(parts[0].substr(2))
	if parts[2] != _check(week, parts[1]):
		return {}
	var packed := 0
	for ch in parts[1]:
		packed = (packed << 5) | ALPHABET.find(ch)
	return {"week": week, "caught": (packed >> 26) & 1023, "wins": (packed >> 14) & 4095, "steps": (packed & 16383) * 100}
