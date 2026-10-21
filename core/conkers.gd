class_name Conkers
extends RefCounted
## Conkers in autumn: you pick up a fresh horse chestnut, put it away to season (three in-game days in a dry drawer,
## no vinegar and no oven, which is cheating), and play it against a rival. You swing by stopping a moving marker on the
## centre; each good blow cracks the other conker a little. Win and your conker moves up a rung (a oner, a twoer, ...);
## lose and it breaks. Pure rules; ui/conker_screen.gd plays a match and story/shanty_run.gd (the `conkers` command)
## runs the whole thing.

const PATH := "res://data/conkers.json"
const ITEM_FRESH := "conker"
const ITEM_SEASONED := "conker_seasoned"
const FLAG_CURING := "conker_curing"      # the in-game day number the conker went in the drawer (absent = nothing curing)
const FLAG_PICKED := "conker_picked"      # the DailyKey stamp of today's pickup
const FLAG_ONER := "conker_ner"           # how many matches the current conker has won
const FLAG_DONE := "conker_done_"         # conker_done_<rival> = the DailyKey stamp of today's prize
const FLAG_FIRST := "conker_first"        # played a match once

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"rivals": []}
	return _cfg

static func rivals() -> Array:
	return cfg().rivals

static func rival(id: String) -> Dictionary:
	for r in rivals():
		if str(r.id) == id:
			return r
	return {}

static func in_season(season: String) -> bool:
	return season == "autumn"

static func season_days() -> int:
	return int(cfg().get("season_days", 3))

## Blows a conker can take: more once seasoned, and a conker that has won matches is tougher still.
static func toughness(seasoned: bool, wins: int) -> int:
	var h: Dictionary = cfg().get("hits", {})
	return int(h.get("seasoned" if seasoned else "fresh", 3)) + clampi(wins, 0, 3)

## "oner", "twoer", ... for a conker that has won `wins` matches; "" for none.
static func ner_name(wins: int) -> String:
	var words := ["", "oner", "twoer", "threeer", "fourer"]
	if wins <= 0:
		return ""
	return words[wins] if wins < words.size() else "%d-er" % wins

static func bag_count(data: GameStateData, id: String) -> int:
	return Bag.new(data.bag).count(id)

static func picked_today(data: GameStateData) -> bool:
	return DailyKey.done_today(data, FLAG_PICKED)

## Gathers a fresh conker from under the tree, once a real day. Returns false when already picked today or the bag is full.
static func pick_up(data: GameStateData) -> bool:
	if picked_today(data):
		return false
	if Bag.new(data.bag).add(ITEM_FRESH, 1) <= 0:
		return false
	data.set_flag(FLAG_PICKED, DailyKey.stamp(data))
	return true

static func curing(data: GameStateData) -> bool:
	return data.flags.has(FLAG_CURING)

## Puts a fresh conker in the drawer. One at a time.
static func start_cure(data: GameStateData) -> bool:
	if curing(data) or not Bag.new(data.bag).remove(ITEM_FRESH, 1):
		return false
	data.set_flag(FLAG_CURING, data.day_count)
	return true

static func days_left(data: GameStateData) -> int:
	if not curing(data):
		return 0
	return maxi(0, season_days() - (data.day_count - int(data.flags.get(FLAG_CURING, 0))))

## Takes a finished conker out of the drawer into the bag. Returns false if it is not ready or the bag is full.
static func collect(data: GameStateData) -> bool:
	if not curing(data) or days_left(data) > 0:
		return false
	if Bag.new(data.bag).add(ITEM_SEASONED, 1) <= 0:
		return false
	data.flags.erase(FLAG_CURING)
	return true

## Damage a swing does, from its quality: "perfect" cracks it twice, "good" once, "miss" is a swing at thin air.
static func damage(quality: String) -> int:
	return 2 if quality == "perfect" else (1 if quality == "good" else 0)

## Quality of a swing that stops the marker at `off` (0 = dead centre, 1 = the end of the bar).
static func swing_quality(off: float, wide: float) -> String:
	var o := absf(off)
	if o <= 0.12 * wide:
		return "perfect"
	if o <= 0.35 * wide:
		return "good"
	return "miss"

## A rival's swing: skill is the chance it lands true; of those, a third are perfect.
static func rival_swing(skill: float, rng: Rng) -> String:
	if not rng.chance(skill * 100.0):
		return "miss"
	return "perfect" if rng.chance(33.0) else "good"

## Books a finished match. Winning keeps the conker and moves it up a rung; losing breaks it. Returns {first, prize,
## wins} where wins is the conker's rung after the match (0 after a loss).
static func finish(data: GameStateData, r: Dictionary, won: bool) -> Dictionary:
	var out := {"first": false, "prize": 0, "wins": 0}
	if not data.flags.has(FLAG_FIRST):
		data.set_flag(FLAG_FIRST, 1)
		out.first = true
	if not won:
		data.flags.erase(FLAG_ONER)
		return out
	TrainerStats.add(data, "conkers_won")
	out.wins = int(data.flags.get(FLAG_ONER, 0)) + 1
	data.set_flag(FLAG_ONER, out.wins)
	var key: String = FLAG_DONE + str(r.id)
	if not DailyKey.done_today(data, key):
		data.set_flag(key, DailyKey.stamp(data))
		out.prize = int(r.get("prize", 0))
	return out
