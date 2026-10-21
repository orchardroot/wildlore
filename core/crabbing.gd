class_name Crabbing
extends RefCounted
## Crabbing off the harbour wall: a kit (a handline and a bucket), bait, patience. Crabs climb on to the bait one by
## one, hold on for a while, then drop off again; haul in when the line is fullest. Everything caught is counted,
## measured and put back (that is the whole point of crabbing). In summer a harbour can hold a competition.
## Pure rules (data/crabbing.json); ui/crabbing_screen.gd plays it and world/crabbing_scene.gd starts it.

const PATH := "res://data/crabbing.json"
const KIT := "crab_kit"
const BAIT := "crab_bait"
const MAX_ON_LINE := 5
const FLAG_COMP := "crab_comp_"        # crab_comp_<harbour> = the DailyKey stamp of today's entry
const FLAG_TIP := "crab_tip_"          # crab_tip_<spot> = the stamp of today's standing reward
const FLAG_BEST := "crab_best_mm"
const TIP_AT := 10                     # crabs released in one go before a harbour thinks better of you

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"spots": [], "species": [], "comp": {}, "bucket": 14}
	return _cfg

static func bucket_size() -> int:
	return int(cfg().get("bucket", 14))

static func is_spot(zone_id: String) -> bool:
	return zone_id in cfg().spots

static func is_water(tile: String) -> bool:
	return tile in ["water", "sea"]

static func has_kit(data: GameStateData) -> bool:
	return int(data.bag.get(KIT, 0)) > 0

static func bait(data: GameStateData) -> int:
	return int(data.bag.get(BAIT, 0))

## Why you can't crab at `tile` in `zone_id` right now, or "".
static func refusal(data: GameStateData, zone_id: String, tile: String) -> String:
	if not is_water(tile) or not is_spot(zone_id):
		return "Nothing here to crab."
	if not has_kit(data):
		return "Good wall for crabbing. You'd want a line and a bucket, and a rasher of bacon rind."
	if bait(data) <= 0:
		return "A line and a bucket, and not a scrap of bait. The crabs are not taking charity."
	return ""

# ---- the line

## How a crab line behaves: seconds between crabs climbing on, seconds the full line holds, and the most it can hold.
## Easier crabbing is slower and holds on longer.
static func plan(easy: bool, rng: Rng) -> Dictionary:
	var interval := rng.roll_range(1.1, 1.5) * (1.6 if easy else 1.0)
	var hold := 1.6 if not easy else 3.6
	return {"interval": interval, "hold": hold, "max": MAX_ON_LINE - rng.roll_int(0, 2)}

## Crabs on the bait `t` seconds after the line went down: they climb on one per interval to the maximum, hold, then
## fall away one per interval until none are left.
static func on_line(t: float, p: Dictionary) -> int:
	var interval: float = p.interval
	var top: int = p.max
	var up_end := interval * top
	if t <= up_end:
		return int(t / interval)
	var down_start: float = up_end + float(p.hold)
	if t <= down_start:
		return top
	return maxi(0, top - int((t - down_start) / interval) - 1)

## The seconds at which the line first empties again (when waiting longer is pointless).
static func empty_at(p: Dictionary) -> float:
	return float(p.interval) * (float(p.max) + float(p.max)) + float(p.hold)

# ---- what comes up

static func species() -> Array:
	return cfg().species

static func species_pool(season: String) -> Array:
	return species().filter(func(s): return s.get("season", []).is_empty() or season in s.season)

static func pick_species(season: String, rng: Rng) -> Dictionary:
	var pool := species_pool(season)
	var total := 0.0
	for s in pool:
		total += float(s.weight)
	var roll := rng.roll() * total
	for s in pool:
		roll -= float(s.weight)
		if roll < 0.0:
			return s
	return pool[pool.size() - 1]

## `n` crabs off the line: [{id, name, mm}].
static func catch_for(n: int, season: String, rng: Rng) -> Array:
	var out: Array = []
	for i in n:
		var s := pick_species(season, rng)
		# sizes bunch towards the small end: most crabs on a harbour wall are youngsters
		var u := rng.roll() * rng.roll()
		out.append({"id": str(s.id), "name": str(s.name), "mm": int(roundf(lerpf(float(s.min), float(s.max), u)))})
	return out

static func biggest(bucket: Array) -> Dictionary:
	var best: Dictionary = {}
	for c in bucket:
		if best.is_empty() or int(c.mm) > int(best.mm):
			best = c
	return best

## "3 Shore Crabs, 1 Hermit Crab"
static func tally(bucket: Array) -> Array:
	var counts := {}
	var order: Array = []
	for c in bucket:
		if not counts.has(c.name):
			counts[c.name] = 0
			order.append(c.name)
		counts[c.name] += 1
	return order.map(func(nm): return "%d %s" % [counts[nm], nm])

static func fact_for(id: String) -> String:
	for s in species():
		if s.id == id:
			return str(s.fact)
	return ""

## Putting them back: counts them on the tally, remembers the biggest, and (once a real day per spot, for a decent
## morning's crabbing) the harbour thinks a little better of you. Returns {released, line}.
static func release(data: GameStateData, spot: String, bucket: Array) -> Dictionary:
	if bucket.is_empty():
		return {"released": 0, "line": ""}
	TrainerStats.add(data, "crabs_caught", bucket.size())
	var big := biggest(bucket)
	var line := ""
	if int(big.mm) > int(data.flags.get(FLAG_BEST, 0)):
		data.set_flag(FLAG_BEST, int(big.mm))
		line = "A new personal best: a %s, %d mm across." % [str(big.name).to_lower(), int(big.mm)]
	if bucket.size() >= TIP_AT and not DailyKey.done_today(data, FLAG_TIP + spot):
		data.set_flag(FLAG_TIP + spot, DailyKey.stamp(data))
		var nation := Standing.nation_for_zone(spot)
		var s := Standing.add(data, nation, 1)
		line = (line + " " if line != "" else "") + (s + "." if s != "" else "The wall regulars nod to you.")
	return {"released": bucket.size(), "line": line}

# ---- the competition

static func comp() -> Dictionary:
	return cfg().comp

static func comp_open() -> bool:
	return Calendar.season_today() == "summer"

static func comp_done_today(data: GameStateData, harbour: String) -> bool:
	return DailyKey.done_today(data, FLAG_COMP + harbour)

static func comp_enter(data: GameStateData, harbour: String) -> void:
	data.set_flag(FLAG_COMP + harbour, DailyKey.stamp(data))

## A bucket's score: one point a crab and one more for every 20 mm of the biggest.
static func score(bucket: Array) -> int:
	if bucket.is_empty():
		return 0
	return bucket.size() + int(biggest(bucket).mm) / 20

## The rivals' scores, in the order listed: [{who, score}].
static func rival_scores(rng: Rng) -> Array:
	var out: Array = []
	for r in comp().rivals:
		var s := int(roundf(float(r.mean) + (rng.roll() - 0.5) * 2.0 * float(r.spread)))
		out.append({"who": str(r.who), "score": maxi(0, s)})
	return out

## 0-based place for `mine` among the rivals (a tie goes to you; it is your competition, in a sense).
static func place(mine: int, rivals: Array) -> int:
	var p := 0
	for r in rivals:
		if int(r.score) > mine:
			p += 1
	return p

## Prize for a place, in sterling (0 below the podium).
static func prize(place_index: int) -> int:
	var pr: Array = comp().prizes
	return int(pr[place_index]) if place_index < pr.size() else 0
