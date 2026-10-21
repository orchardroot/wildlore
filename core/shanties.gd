class_name Shanties
extends RefCounted
## Sea shanties in harbour pubs: a shantyman sings the line and the crew heaves together on the marked beats. You
## press Confirm on each pull. Each song is a few lines from data/shanties.json (traditional, public domain, one
## fact each). Pure rules; ui/shanty_screen.gd plays it and story/shanty_run.gd (the `sing` command) starts it.

const PATH := "res://data/shanties.json"
const LINE_BEATS := 4
const LEAD_IN := 1.5                 # seconds of count-in before the first beat
const FLAG_DONE := "shanty_done_"    # shanty_done_<id> = the DailyKey stamp of today's paid song
const FLAG_FIRST := "shanty_first_"  # shanty_first_<id> = sung through once
const PASS_SHARE := 0.7              # the share of pulls in time that counts as a good heave

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"shanties": [], "pubs": []}
	return _cfg

static func shanties() -> Array:
	return cfg().shanties

static func shanty(id: String) -> Dictionary:
	for s in shanties():
		if str(s.id) == id:
			return s
	return {}

static func is_pub(zone_id: String) -> bool:
	return cfg().get("pubs", []).has(zone_id)

## Seconds between beats and how far out (seconds) a pull still counts. Easier singing is slower with a wider window.
static func beat(easy: bool) -> Dictionary:
	return {"interval": 0.75 if easy else 0.55, "window": 0.40 if easy else 0.22}

## The time (seconds from the start) of every pull in a song, in order, with its line number.
static func targets(s: Dictionary, interval: float) -> Array:
	var out: Array = []
	var lines: Array = s.get("lines", [])
	for i in lines.size():
		for b in lines[i].get("pulls", []):
			out.append({"t": LEAD_IN + (float(i * LINE_BEATS) + float(b)) * interval, "line": i})
	return out

## Seconds in the whole song, to the end of the last line.
static func length(s: Dictionary, interval: float) -> float:
	return LEAD_IN + float(s.get("lines", []).size() * LINE_BEATS) * interval

## "perfect", "good" or "miss" for a pull `err` seconds from its beat.
static func judge(err: float, window: float) -> String:
	var e := absf(err)
	if e <= window * 0.4:
		return "perfect"
	if e <= window:
		return "good"
	return "miss"

## Index of the nearest pull not yet judged that a press at time `t` could be for, or -1 if none is within `window`.
## `results` holds "" for a pull still waiting.
static func target_for(tg: Array, results: Array, t: float, window: float) -> int:
	var best := -1
	var best_err := window
	for i in tg.size():
		if str(results[i]) != "":
			continue
		var e := absf(t - float(tg[i].t))
		if e <= best_err:
			best_err = e
			best = i
	return best

static func hits_of(results: Array) -> int:
	var n := 0
	for r in results:
		if str(r) == "perfect" or str(r) == "good":
			n += 1
	return n

## True when enough pulls were in time for the crew to call it a good heave.
static func clean(hits: int, pulls: int) -> bool:
	return pulls > 0 and float(hits) / float(pulls) >= PASS_SHARE

static func paid_today(data: GameStateData, id: String) -> bool:
	return DailyKey.done_today(data, FLAG_DONE + id)

## Books a finished song: counts the pulls in time, stamps the day when it was clean. Returns {first, tip}.
static func finish(data: GameStateData, s: Dictionary, hits: int, pulls: int) -> Dictionary:
	TrainerStats.add(data, "pulls_sung", hits)
	var out := {"first": false, "tip": 0}
	if not clean(hits, pulls):
		return out
	var id := str(s.id)
	if not data.flags.has(FLAG_FIRST + id):
		data.set_flag(FLAG_FIRST + id, 1)
		out.first = true
	if not paid_today(data, id):
		data.set_flag(FLAG_DONE + id, DailyKey.stamp(data))
		out.tip = int(s.get("tip", 0))
	return out
