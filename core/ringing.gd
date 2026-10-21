class_name Ringing
extends RefCounted
## Change ringing in a church tower: six bells, rung in rounds (1 2 3 4 5 6, treble to tenor) and then in "call
## changes", where the conductor names pairs of neighbouring bells to swap places. You ring one bell: the row sounds
## left to right at a steady beat, and you pull when it is your bell's turn. Each piece is a short touch from
## data/ringing.json (real method names, one fact each). The conductor calls a change one row ahead, so nothing is a
## surprise. Pure rules; ui/ringing_screen.gd plays it and story/ringing_run.gd (the `ring` command) starts it.

const PATH := "res://data/ringing.json"
const BELLS := 6
const FLAG_DONE := "ring_done_"      # ring_done_<piece> = the DailyKey stamp of today's paid pull
const FLAG_FIRST := "ring_first_"    # ring_first_<piece> = rung through once
const PASS_SHARE := 0.7              # the share of rows struck in time that counts as a clean touch

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"pieces": []}
	return _cfg

static func pieces() -> Array:
	return cfg().pieces

static func piece(id: String) -> Dictionary:
	for p in pieces():
		if str(p.id) == id:
			return p
	return {}

static func rounds() -> Array:
	var r: Array = []
	for i in BELLS:
		r.append(i + 1)
	return r

## Swaps the neighbours at 0-based places `a` and `a + 1` in each pair of `call` (a list of `a`s); pairs that
## overlap or fall off the end are skipped, so a bad call can never scramble a row.
static func apply_call(row: Array, call: Array) -> Array:
	var out := row.duplicate()
	var used := {}
	for a in call:
		var i := int(a)
		if i < 0 or i + 1 >= out.size() or used.has(i) or used.has(i + 1):
			continue
		used[i] = true
		used[i + 1] = true
		var t = out[i]
		out[i] = out[i + 1]
		out[i + 1] = t
	return out

## Every row of a piece, starting in rounds: calls[i] turns row i into row i + 1.
static func rows_for(p: Dictionary) -> Array:
	var rows: Array = [rounds()]
	for call in p.get("calls", []):
		rows.append(apply_call(rows.back(), call))
	return rows

## 0-based place of `bell` in `row` (so the stroke on which it sounds).
static func place_of(row: Array, bell: int) -> int:
	return row.find(bell)

## "3 to 4" for the conductor's call (1-based bell places, as ringers say it); "Rounds" for no call.
static func call_text(call: Array) -> String:
	if call.is_empty():
		return "Stand: keep it in rounds"
	var parts: Array = []
	for a in call:
		parts.append("%d to %d" % [int(a) + 1, int(a) + 2])
	return "Change: " + ", ".join(PackedStringArray(parts))

## Beat and window: seconds between strokes, and how far out (in seconds) a pull still counts. Easier ringing is
## slower with a wider window; the strokes are also marked on screen either way.
static func beat(easy: bool) -> Dictionary:
	return {"interval": 0.85 if easy else 0.6, "window": 0.42 if easy else 0.24}

## "perfect", "good" or "miss" for a pull `err` seconds from its stroke.
static func judge(err: float, window: float) -> String:
	var e := absf(err)
	if e <= window * 0.4:
		return "perfect"
	if e <= window:
		return "good"
	return "miss"

## True when the share of rows struck in time is enough for a clean touch.
static func clean(hits: int, rows: int) -> bool:
	return rows > 0 and float(hits) / float(rows) >= PASS_SHARE

## The pence-free whole-pound tip for a touch: the ringers pass the bag round. Once a real day per piece.
static func tip(p: Dictionary, hits: int, rows: int) -> int:
	return int(p.get("tip", 0)) if clean(hits, rows) else 0

static func paid_today(data: GameStateData, id: String) -> bool:
	return DailyKey.done_today(data, FLAG_DONE + id)

## Books a finished touch: counts the rows pulled in time, stamps the day when it was clean. Returns {first, tip}.
static func finish(data: GameStateData, p: Dictionary, hits: int, rows: int) -> Dictionary:
	TrainerStats.add(data, "rows_rung", hits)
	var out := {"first": false, "tip": 0}
	if not clean(hits, rows):
		return out
	var id := str(p.id)
	if not data.flags.has(FLAG_FIRST + id):
		data.set_flag(FLAG_FIRST + id, 1)
		out.first = true
	if not paid_today(data, id):
		data.set_flag(FLAG_DONE + id, DailyKey.stamp(data))
		out.tip = tip(p, hits, rows)
	return out
