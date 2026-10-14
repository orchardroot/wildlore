class_name GameClock
extends RefCounted
## In-game time of day. Minutes since midnight, 0..1439. One real second is one game minute in the overworld.

const DAY := 1440

static func phase(minutes: int) -> String:
	var m := GameClock.wrap(minutes)
	if m >= 5 * 60 and m < 8 * 60:
		return "dawn"
	if m >= 8 * 60 and m < 18 * 60:
		return "day"
	if m >= 18 * 60 and m < 21 * 60:
		return "dusk"
	return "night"

static func wrap(minutes: int) -> int:
	return posmod(minutes, DAY)

static func text(minutes: int) -> String:
	var m := GameClock.wrap(minutes)
	return "%02d:%02d" % [m / 60, m % 60]

## "HH:MM" -> minutes; -1 if malformed.
static func parse(hhmm: String) -> int:
	var parts := hhmm.split(":")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return -1
	return GameClock.wrap(int(parts[0]) * 60 + int(parts[1]))
