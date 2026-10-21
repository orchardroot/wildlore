class_name Festivals
extends RefCounted
## Real-date occasions you can DO something about (data/festivals.json). Each has a person in a fitting town, there
## only inside the event's window (the player's own calendar, see Calendar and the --date dev switch), a quest
## (data/quests/festivals.json, script fest_<id> in data/dialogue/festivals.json) and a limited-time creature that
## joins the town's wild table for the window. The pause card, the noticeboard and `when fest_<id>` read it.
## Pure logic: the validator loads it.

const PATH := "res://data/festivals.json"
const SCRIPT_FILE := "festivals"  # data/dialogue/festivals.json
const COND_PREFIX := "fest_"
const SOON_DAYS := 21  # "What's on" also lists what starts within this many days
const MONTH_DAYS := [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
const MONTHS := ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

static var _events: Array = []
static var _loaded := false

static func events() -> Array:
	if not _loaded:
		var d: Variant = JsonUtil.read(PATH)
		_events = d.get("events", []) if d is Dictionary else []
		_loaded = true
	return _events

static func get_event(id: String) -> Dictionary:
	for e in events():
		if str(e.get("id", "")) == id:
			return e
	return {}

## Day of a (non-leap) year, 0..364: enough to count days between dates.
static func _doy(m: int, d: int) -> int:
	return MONTH_DAYS[clampi(m, 1, 12) - 1] + d - 1

## The event's window as [month, day, month, day] for a year. Most are fixed dates; one with a `rule` moves with the
## calendar (Up Helly Aa: the last Tuesday of January): {"nth": "last", "weekday": 2, "month": 1, "from": -3, "to": 1}
## is the window from 3 days before to 1 day after that weekday (0 = Sunday).
static func window_of(e: Dictionary, year := -1) -> Array:
	var r: Variant = e.get("rule")
	if not r is Dictionary:
		return e.get("window", [])
	var y := year if year > 0 else Calendar.year()
	var m := int(r.get("month", 1))
	var last := _month_length(m, y)
	var d := last
	while _weekday(y, m, d) != int(r.get("weekday", 0)):
		d -= 1
	var a := Time.get_date_dict_from_unix_time(_unix(y, m, d) + int(r.get("from", 0)) * 86400)
	var b := Time.get_date_dict_from_unix_time(_unix(y, m, d) + int(r.get("to", 0)) * 86400)
	return [int(a.month), int(a.day), int(b.month), int(b.day)]

static func _unix(y: int, m: int, d: int) -> int:
	return int(Time.get_unix_time_from_datetime_dict({"year": y, "month": m, "day": d, "hour": 12, "minute": 0, "second": 0}))

static func _weekday(y: int, m: int, d: int) -> int:
	return int(Time.get_date_dict_from_unix_time(_unix(y, m, d)).weekday)

static func _month_length(m: int, y: int) -> int:
	var next := Time.get_date_dict_from_unix_time(_unix(y + (1 if m == 12 else 0), 1 if m == 12 else m + 1, 1) - 86400)
	return int(next.day)

## Is (month, day) inside the event's window? A window may wrap the new year.
static func in_window(e: Dictionary, month: int, day: int, year := -1) -> bool:
	var w: Array = window_of(e, year)
	if w.size() != 4:
		return false
	var s := _doy(int(w[0]), int(w[1]))
	var f := _doy(int(w[2]), int(w[3]))
	var t := _doy(month, day)
	return (t >= s and t <= f) if s <= f else (t >= s or t <= f)

static func is_active(e: Dictionary, today := Vector2i(-1, -1)) -> bool:
	var t := today if today.x > 0 else Calendar.today()
	return in_window(e, t.x, t.y)

## Is the event with this id on today?
static func active(id: String) -> bool:
	var e := get_event(id)
	return not e.is_empty() and is_active(e)

## Days until the window opens (0 when it is open now).
static func days_until(e: Dictionary, today := Vector2i(-1, -1)) -> int:
	var t := today if today.x > 0 else Calendar.today()
	if in_window(e, t.x, t.y):
		return 0
	var w: Array = window_of(e)
	return posmod(_doy(int(w[0]), int(w[1])) - _doy(t.x, t.y), 365)

static func _date_text(m: int, d: int) -> String:
	return "%d %s" % [d, MONTHS[clampi(m, 1, 12)]]

## Lines for "What's on": what is on now ("On now: ..., until 7 November.") then what starts soon, soonest first.
## At most `limit`; empty when nothing is near.
static func whats_on(today := Vector2i(-1, -1), limit := 4) -> Array:
	var rows := []
	for e in events():
		var n := days_until(e, today)
		if n <= SOON_DAYS:
			rows.append([n, e])
	rows.sort_custom(func(a, b): return a[0] < b[0])
	var out := []
	for r in rows.slice(0, limit):
		var e: Dictionary = r[1]
		var town := Travel.town_name(str(e.town))
		var w: Array = window_of(e)
		if r[0] == 0:
			out.append("On now: %s in %s, until %s." % [str(e.whatson), town, _date_text(int(w[2]), int(w[3]))])
		else:
			out.append("Coming up: %s in %s, from %s (%s)." % [str(e.whatson), town, _date_text(int(w[0]), int(w[1])), "tomorrow" if r[0] == 1 else "in %d days" % r[0]])
	return out

## The people on in this zone today, as NPC definitions (the overworld spawns them with the zone's own).
static func npcs_for(zone_id: String, today := Vector2i(-1, -1), list: Array = []) -> Array:
	var out := []
	for e in (list if not list.is_empty() else events()):
		if str(e.get("town", "")) != zone_id or not is_active(e, today):
			continue
		out.append({"id": "fest_" + str(e.id), "sprite": str(e.get("sprite", "")), "name": str(e.get("who", "")),
			"x": int(e.get("x", 0)), "y": int(e.get("y", 0)), "facing": str(e.get("facing", "down")), "move": "still",
			"script": str(e.script), "script_file": SCRIPT_FILE})
	return out

## Extra wild-table entries for this zone and kind while an event is on: its creature, at the level range of the
## zone's own first entry and about `share` of the table's weight. [] when none (or the zone has no such table).
static func extra_encounters(zone_id: String, kind: String, table: Array, today := Vector2i(-1, -1), list: Array = []) -> Array:
	var out := []
	if table.is_empty():
		return out
	for e in (list if not list.is_empty() else events()):
		var sp: Dictionary = e.get("spawn", {})
		if str(e.get("town", "")) != zone_id or kind not in sp.get("kinds", []) or not is_active(e, today):
			continue
		var total := 0.0
		for t in table:
			total += float(t.get("weight", 1))
		out.append({"species": str(sp.species), "min": int(table[0].get("min", 5)), "max": int(table[0].get("max", 5)),
			"weight": maxf(4.0, total * float(sp.get("share", 0.18)))})
	return out

## `when fest_<id>`: is that event on?
static func cond(c: String) -> bool:
	return c.begins_with(COND_PREFIX) and active(c.substr(COND_PREFIX.length()))

static func is_cond(c: String) -> bool:
	return c.begins_with(COND_PREFIX) and not get_event(c.substr(COND_PREFIX.length())).is_empty()

## --- Every year -----------------------------------------------------------------------------------------------
## Each occasion comes round again. The quest flags (`q_festivals_<id>_*`) hold this year's run; a ledger flag
## `festivals_year_<id>` says which year's run they are. When the occasion is on and the ledger is behind, the run is
## put away (the souvenir flag keeps what was kept for good) and the quest starts afresh. Saves from 3.1 have no ledger:
## their flags count as the 2026 run, so a quest finished then stays done that year.
const LEDGER := "festivals_year_"
const SOUVENIR := "festivals_souv_"
const LEGACY_YEAR := 2026
const DONE_PREFIX := "festivals_done_"  # festivals_done_<id>_<year>: a record of each year finished

## The year an occasion running today belongs to: a window across New Year (Hogmanay) belongs to the year it opened.
static func run_year(e: Dictionary, today := Vector2i(-1, -1), year := -1) -> int:
	var t := today if today.x > 0 else Calendar.today()
	var y := year if year > 0 else Calendar.year()
	var w: Array = window_of(e, y)
	if w.size() == 4 and _doy(int(w[0]), int(w[1])) > _doy(int(w[2]), int(w[3])) and t.x <= int(w[2]):
		return y - 1
	return y

static func quest_of(e: Dictionary) -> Dictionary:
	return Quests.get_quest(str(e.get("quest", "")))

## Flags that belong to one run: the quest's own and the answer to its question.
static func run_flags(e: Dictionary) -> Array:
	var out: Array = Quests.flags_of(quest_of(e))
	out.append("festivals_%s_ans" % str(e.id))
	return out

static func souvenir_flag(id: String) -> String:
	return SOUVENIR + id

## Brings a save up to the year for every occasion that is on today: the old run is archived and cleared. Returns the
## ids that started a new year. Safe to call every time a zone loads.
static func rollover(d: GameStateData, today := Vector2i(-1, -1), year := -1) -> Array:
	var out := []
	for e in events():
		if not is_active(e, today):
			continue
		var id := str(e.id)
		var run := run_year(e, today, year)
		var done_flag := str(quest_of(e).get("done_flag", ""))
		var led: Variant = d.flag(LEDGER + id)
		var had := int(led) if led != null else LEGACY_YEAR
		if led == null and done_flag != "" and d.flag(done_flag) == true:  # a 3.1 run: its souvenir is already yours
			d.set_flag(souvenir_flag(id))
		if run <= had:
			if led == null:
				d.set_flag(LEDGER + id, had)
			continue
		if done_flag != "" and d.flag(done_flag) == true:
			d.set_flag(souvenir_flag(id))
			d.set_flag("%s%s_%d" % [DONE_PREFIX, id, had])
		for f in run_flags(e):
			d.flags.erase(f)
		d.set_flag(LEDGER + id, run)
		out.append(id)
	return out

## The year a festival quest's log entry is about, or 0 for any other quest.
static func quest_year(d: GameStateData, q: Dictionary) -> int:
	for e in events():
		if str(e.get("quest", "")) == str(q.get("id", "")):
			var led: Variant = d.flag(LEDGER + str(e.id))
			return int(led) if led != null else LEGACY_YEAR
	return 0

## How many years you have finished this occasion, the 3.1 one-shot included.
static func years_done(d: GameStateData, e: Dictionary) -> int:
	var n := 0
	var id := str(e.id)
	for k in d.flags:
		if str(k).begins_with("%s%s_" % [DONE_PREFIX, id]):
			n += 1
	var done_flag := str(quest_of(e).get("done_flag", ""))
	if done_flag != "" and d.flag(done_flag) == true:
		var led: Variant = d.flag(LEDGER + id)
		if not d.flags.has("%s%s_%d" % [DONE_PREFIX, id, int(led) if led != null else LEGACY_YEAR]):
			n += 1
	return n

## Problems with the data (the validator's job).
static func validate(zones: Dictionary, dex: Dex, quests: Array) -> Array:
	var errors := []
	var ids := {}
	for e in events():
		var tag := "festival %s" % e.get("id", "?")
		var id := str(e.get("id", ""))
		if id == "" or ids.has(id):
			errors.append(tag + ": id missing or duplicated")
		ids[id] = true
		if not zones.has(str(e.get("town", ""))):
			errors.append(tag + ": unknown town")
		var w: Array = window_of(e)
		if w.size() != 4 or int(w[0]) < 1 or int(w[0]) > 12 or int(w[2]) < 1 or int(w[2]) > 12:
			errors.append(tag + ": bad window")
		if StoryData.script(SCRIPT_FILE, str(e.get("script", ""))).is_empty():
			errors.append(tag + ": script '%s' missing from dialogue/festivals" % e.get("script", ""))
		if not dex.has(str(e.get("spawn", {}).get("species", ""))):
			errors.append(tag + ": unknown spawn species")
		if Quests.get_quest(str(e.get("quest", "")), quests).is_empty():
			errors.append(tag + ": quest '%s' missing" % e.get("quest", ""))
		if str(e.get("whatson", "")) == "":
			errors.append(tag + ": no whatson line")
	return errors
