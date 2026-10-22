class_name LifeLessons
extends RefCounted
## "Things worth knowing" (4.5, session K): the life lessons woven into NPCs (scam texts, payslips, a bad week,
## the casino's maths). The teaching lives in each NPC's script (`life_<id>` in the zone's dialogue); finishing one
## sets the flag `lesson_<id>` and pays a small thank-you. This reads those flags for the Almanac page. Pure logic,
## nothing stored beyond the flags, so old saves need nothing.

const PATH := "res://data/life_lessons.json"
const FLAG_PREFIX := "lesson_"

static var _cache: Array = []

## Every lesson: [{id, title, takeaway, zone}], in file order.
static func all() -> Array:
	if _cache.is_empty():
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_cache = parsed.get("lessons", [])
	return _cache

static func flag_of(id: String) -> String:
	return FLAG_PREFIX + id

static func learnt(d: GameStateData, id: String) -> bool:
	return d.flag(flag_of(id)) == true

static func count(d: GameStateData) -> int:
	var n := 0
	for l in all():
		if learnt(d, str(l.id)):
			n += 1
	return n

## Ledger rows [title, takeaway] for the lessons learnt so far; unlearnt ones show as a gap to look for.
static func rows(d: GameStateData) -> Array:
	var out := []
	for l in all():
		if learnt(d, str(l.id)):
			out.append([str(l.title), str(l.takeaway)])
	var left := all().size() - out.size()
	if out.is_empty():
		out.append(["Nothing yet", "Somebody in a pub or a chapel has a lesson"])
	elif left > 0:
		out.append(["", "%d more to find, in towns across the isles" % left])
	return out
