class_name Fishing
extends RefCounted
## Fishing: a rod, open water you face, a patient wait and a slow bite bar. Pure rules; the overworld casts and
## FishingBar draws. What bites comes from data/fishing.json: a pool per place (British fresh and salt water,
## Scotland, Ireland, the Channel Islands, then each overseas patch of ocean), gated by season, with a few
## creatures that only ever turn up on a line (and only once you have the badges for them). Fish are ordinary
## items (data/items/fish.json) so the Trade Ledger prices them like anything else.

const PATH := "res://data/fishing.json"
const WATER_TILES := ["water", "deep_water", "sea"]
const RARE_BELOW := 6.0      # entries lighter than this are "rare" and a better rod favours them
const RARE_MULT := 1.5
const FLAG_DAY := "fish_day"
const FLAG_CASTS := "fish_casts"

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"rods": {}, "regions": {}, "groups": {}, "daily_casts": 10}
	return _cfg

static func groups() -> Dictionary:
	return cfg().groups

static func daily_casts() -> int:
	return int(cfg().get("daily_casts", 10))

## 0 with no rod, else the best rod's tier in the bag.
static func rod_tier(data: GameStateData) -> int:
	var best := 0
	var rods: Dictionary = cfg().rods
	for id in rods:
		if int(data.bag.get(id, 0)) > 0:
			best = maxi(best, int(rods[id].tier))
	return best

static func is_water(tile: String) -> bool:
	return tile in WATER_TILES

## Why you can't cast at `tile` right now, or "".
static func refusal(data: GameStateData, tile: String, _region: String) -> String:
	if not is_water(tile):
		return "Nothing here to fish."
	if rod_tier(data) == 0:
		return "Lovely water. You haven't got a rod, though, and the fish know it."
	if casts_left(data) <= 0:
		return "They've stopped biting for today. Try again tomorrow, when they've forgotten."
	return ""

## Overseas water, and the open "sea" tile anywhere, is salt; inland water is fresh.
static func water_kind(region: String, tile: String) -> String:
	return "salt" if tile == "sea" or region.begins_with("overseas_") else "fresh"

static func group(region: String) -> String:
	return str(cfg().regions.get(region, "britain"))

## The weighted entries that can bite: {id, weight} for a fish, {species, weight, min, max} for a line creature.
## `badges` gates the creatures; a better `tier` of rod favours the rare ones.
static func pool(region: String, tile: String, season: String, badges: int, tier: int) -> Array:
	var g: Dictionary = groups().get(group(region), {})
	var kind := water_kind(region, tile)
	var list: Array = g.get(kind, g.get("salt", g.get("fresh", [])))
	var out := []
	for e in list:
		var seasons: Array = e.get("season", [])
		if not seasons.is_empty() and season not in seasons:
			continue
		if badges < int(e.get("badges", 0)):
			continue
		var c: Dictionary = e.duplicate()
		if tier > 1 and float(c.weight) < RARE_BELOW:
			c["weight"] = float(c.weight) * RARE_MULT
		out.append(c)
	return out

## `u` in 0..1 chooses along the cumulative weights.
static func pick(list: Array, u: float) -> Dictionary:
	return Encounters.pick_entry(list, u)

## Seconds the float sits before something investigates.
static func wait_seconds(rng: Rng) -> float:
	return rng.roll_range(1.5, 4.0)

## The bite bar for a rod: how fast the marker sweeps (seconds per there-and-back), the half-width of the sweet spot
## (as a fraction of the bar) and how many tries the fish allows. Easy mode is wider, slower and more forgiving.
static func bar(tier: int, easy: bool) -> Dictionary:
	var half := 0.11 + 0.03 * float(maxi(tier, 1) - 1)
	var period := 2.0
	var tries := 2
	if easy:
		half *= 1.7
		period = 3.2
		tries = 3
	return {"half": half, "period": period, "tries": tries}

## Where the sweet spot sits, kept clear of the ends so it is always reachable.
static func centre(rng: Rng, half: float) -> float:
	return rng.roll_range(half + 0.05, 0.95 - half)

## The marker at `t` seconds: 0 to 1 and back, once per `period`.
static func marker(t: float, period: float) -> float:
	var x := fposmod(t / period, 1.0)
	return 2.0 * x if x <= 0.5 else 2.0 - 2.0 * x

static func hit(m: float, centre_at: float, half: float) -> bool:
	return absf(m - centre_at) <= half

## Casts left today. Old saves, and a new day, start full.
static func casts_left(data: GameStateData) -> int:
	var total := daily_casts() + Guilds.cast_bonus(data)   # the Anglers
	if int(data.flags.get(FLAG_DAY, -1)) != data.day_count:
		return total
	return maxi(0, total - int(data.flags.get(FLAG_CASTS, 0)))

static func spend_cast(data: GameStateData) -> void:
	var left := casts_left(data)
	data.set_flag(FLAG_DAY, data.day_count)
	data.set_flag(FLAG_CASTS, daily_casts() + Guilds.cast_bonus(data) - left + 1)

## A fish comes ashore: into the bag and onto the tally.
static func land(data: GameStateData, id: String) -> void:
	data.bag[id] = int(data.bag.get(id, 0)) + 1
	TrainerStats.add(data, "fish_caught")
