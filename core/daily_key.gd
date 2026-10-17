class_name DailyKey
extends RefCounted
## Once-a-day things (post-game rematches, the pub quiz prize) key on the REAL date (Calendar.today_key), so the
## 24-minute in-game day can't be farmed. A claim is a flag holding a stamp "YYYY-MM-DD@<day_count>@<play_seconds>".
## Marathon fallback: four hours of play in one session after a claim, and an in-game midnight since, frees it again.
## Anything that isn't a stamp (the in-game day numbers 1.4 saves hold) counts as "not today". Pure logic.

const MARATHON_SECONDS := 4.0 * 3600.0

static var _session_data_id := 0
static var _session_start := 0.0

## Marks the start of a play session for `data` (a load or New Game makes a fresh data object, so any new object
## starts one by itself the first time it's asked about).
static func begin_session(data: GameStateData) -> void:
	_session_data_id = data.get_instance_id()
	_session_start = data.play_seconds

static func _session_start_for(data: GameStateData) -> float:
	if data.get_instance_id() != _session_data_id:
		begin_session(data)
	return _session_start

## The value to store in a daily flag when it's used today.
static func stamp(data: GameStateData) -> String:
	_session_start_for(data)
	return "%s@%d@%d" % [Calendar.today_key(), data.day_count, int(data.play_seconds)]

## True while a stored stamp still counts as today.
static func is_today(data: GameStateData, value: Variant) -> bool:
	if typeof(value) != TYPE_STRING:
		return false
	var parts: PackedStringArray = str(value).split("@")
	if parts[0] != Calendar.today_key():
		return false
	if parts.size() >= 3:
		var at := float(parts[2])
		var marathon := at >= _session_start_for(data) - 1.0 and data.play_seconds - at >= MARATHON_SECONDS
		if marathon and int(parts[1]) != data.day_count:
			return false
	return true

static func done_today(data: GameStateData, key: String) -> bool:
	return is_today(data, data.flag(key))
