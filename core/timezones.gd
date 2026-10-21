class_name Timezones
extends RefCounted
## Local time in the Overseas Territories. The game clock is UK time (GameClock minutes since midnight); the real date
## (Calendar) decides who is on summer time. Zones and the region -> zone map live in data/timezones.json. Rules:
## "eu" = last Sunday of March to last Sunday of October, switching at 01:00 UTC; "us" = second Sunday of March to
## first Sunday of November, switching at 02:00 local. Nowhere else changes its clocks. Pure logic (no autoloads).

const PATH := "res://data/timezones.json"
const HOME := "uk"
const JET_LAG_HOURS := 3  # a difference this big (either way) earns a jet-lag line and a nap to clear it

static var _cache: Dictionary = {}

static func _db() -> Dictionary:
	if _cache.is_empty():
		var d = JsonUtil.read(PATH)
		_cache = d if d is Dictionary else {"zones": {}, "regions": {}, "flight_minutes": {}}
	return _cache

static func reset() -> void:
	_cache = {}

## Zone id for a zone's region: "uk" for the UK, Ireland, the Channel Islands and anywhere not listed.
static func zone_for_region(region: String) -> String:
	return str(_db().regions.get(region, HOME))

static func label(zone_id: String) -> String:
	return str(_db().zones.get(zone_id, {}).get("label", "UK"))

static func is_abroad(zone_id: String) -> bool:
	return zone_id != HOME and _db().zones.has(zone_id)

## Days since 1970-01-01 for a civil date.
static func _days(y: int, m: int, d: int) -> int:
	var yy := y - (1 if m <= 2 else 0)
	var era := (yy if yy >= 0 else yy - 399) / 400
	var yoe := yy - era * 400
	var doy := (153 * (m + (-3 if m > 2 else 9)) + 2) / 5 + d - 1
	var doe := yoe * 365 + yoe / 4 - yoe / 100 + doy
	return era * 146097 + doe - 719468

## Day of month of the nth (1-based; 0 = last) Sunday of a month.
static func sunday(y: int, m: int, nth: int) -> int:
	var dim: int = [31, 29 if (y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]
	var wd := posmod(_days(y, m, 1) + 4, 7)  # 0 = Sunday (1970-01-01 was a Thursday)
	var first := 1 + posmod(7 - wd, 7)
	if nth > 0:
		return first + 7 * (nth - 1)
	return first + 7 * ((dim - first) / 7)

## Is summer time in force at this UTC instant (minutes since the epoch)? `rule` is "eu" or "us"; `std` is the zone's
## standard offset in minutes (the US rule switches at 02:00 local time).
static func dst_at(rule: String, std: int, utc: int, y: int) -> bool:
	match rule:
		"eu":
			var s := _days(y, 3, sunday(y, 3, 0)) * 1440 + 60
			var e := _days(y, 10, sunday(y, 10, 0)) * 1440 + 60
			return utc >= s and utc < e
		"us":
			var s := _days(y, 3, sunday(y, 3, 2)) * 1440 + 120 - std
			var e := _days(y, 11, sunday(y, 11, 1)) * 1440 + 120 - (std + 60)
			return utc >= s and utc < e
	return false

## Offset from UTC, in minutes, of a zone at a UTC instant.
static func offset_at(zone_id: String, utc: int, y: int) -> int:
	var z: Dictionary = _db().zones.get(zone_id, _db().zones.get(HOME, {}))
	var std := int(z.get("std", 0))
	var rule := str(z.get("dst", ""))
	return std + (60 if rule != "" and dst_at(rule, std, utc, y) else 0)

## UK clock minutes on a date -> minutes since midnight in `zone_id`. The UK wall time is read as if it were UTC to
## find out whether summer time is on, so the hour either side of a UK switch can be off by an hour; nobody minds.
static func to_zone(uk_minutes: int, zone_id: String, y: int, m: int, d: int) -> int:
	var local_uk := _days(y, m, d) * 1440 + GameClock.wrap(uk_minutes)
	var utc := local_uk - offset_at(HOME, local_uk, y)
	return GameClock.wrap(utc + offset_at(zone_id, utc, y))

## Minutes since midnight in `zone_id` right now: the save's UK clock on the (real or --date) calendar date.
static func local_minutes(data: GameStateData, zone_id: String) -> int:
	if zone_id == HOME or not _db().zones.has(zone_id):
		return GameClock.wrap(data.clock_minutes)
	var t := Calendar.today()
	return to_zone(data.clock_minutes, zone_id, Calendar.year(), t.x, t.y)

## Local minus UK time in minutes, today, at the current UK clock (-1439..1439, usually a whole hour or half).
static func difference(data: GameStateData, zone_id: String) -> int:
	var d := local_minutes(data, zone_id) - GameClock.wrap(data.clock_minutes)
	if d > 720:
		d -= 1440
	elif d < -720:
		d += 1440
	return d

## Flight (or sailing) time in minutes to a territory id, rough real durations; 0 if unlisted.
static func flight_minutes(territory_id: String) -> int:
	return int(_db().flight_minutes.get(territory_id, 0))

static func duration_text(minutes: int) -> String:
	return "%dh %02dm" % [minutes / 60, minutes % 60]

## "Arrive 03:40 local time (11h 30m)" for leaving now (UK clock) for a territory.
static func arrival_text(data: GameStateData, territory_id: String, zone_id: String) -> String:
	var fl := flight_minutes(territory_id)
	if fl <= 0:
		return ""
	var t := Calendar.today()
	var there := to_zone(data.clock_minutes + fl, zone_id, Calendar.year(), t.x, t.y)
	return "Arrive %s local time (%s)" % [GameClock.text(there), duration_text(fl)]

## The pause menu clock: local time abroad with UK time beside it, just UK time at home.
static func clock_text(data: GameStateData, zone_id: String) -> String:
	var uk := GameClock.text(data.clock_minutes)
	if not is_abroad(zone_id):
		return uk
	return "%s %s (UK %s)" % [GameClock.text(local_minutes(data, zone_id)), label(zone_id), uk]

## The line on landing, or "" for a short hop.
static func jet_lag_line(diff_minutes: int) -> String:
	var h := diff_minutes / 60
	if absi(h) < JET_LAG_HOURS:
		return ""
	if h > 0:
		return "Your body insists it is %d hours earlier. A nap at the Sanctuary will sort you out." % h
	return "Your body insists it is %d hours later. A nap at the Sanctuary will sort you out." % -h

## Problems with the data, for the validator and tests.
static func validate(region_exists: Callable) -> Array:
	var errors := []
	for r in _db().regions:
		if not _db().zones.has(_db().regions[r]):
			errors.append("timezones: region %s names unknown zone %s" % [r, _db().regions[r]])
		if not region_exists.call(str(r)):
			errors.append("timezones: region %s is on no zone" % r)
	return errors
