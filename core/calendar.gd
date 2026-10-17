class_name Calendar
extends RefCounted
## Seasons and festivals from the real date (the player's own calendar, not the in-game clock). Pure logic:
## the overworld dresses towns and tints the trees from these, and dialogue `when` conditions read them.
## The --date=MM-DD dev switch overrides the date for screenshots.

const SEASONS := ["spring", "summer", "autumn", "winter"]
const FESTIVALS := ["halloween", "bonfire_night", "christmas", "st_patricks", "st_davids", "burns_night"]
## National days, kept in their own nation (everyone gets Halloween, Bonfire Night and Christmas).
const FESTIVAL_NATION := {"st_patricks": "ireland", "st_davids": "wales", "burns_night": "scotland"}

static var _override := Vector2i(-1, -1)

## Meteorological seasons: spring is March to May, summer June to August, and so on.
static func season_for(month: int, _day: int) -> String:
	match month:
		3, 4, 5:
			return "spring"
		6, 7, 8:
			return "summer"
		9, 10, 11:
			return "autumn"
	return "winter"

## The festival on a date, or "".
static func festival_for(month: int, day: int) -> String:
	if month == 10 and day >= 24:
		return "halloween"
	if month == 11 and day <= 7:
		return "bonfire_night"
	if month == 12:
		return "christmas"
	if month == 1 and day == 25:
		return "burns_night"
	if month == 3 and day == 1:
		return "st_davids"
	if month == 3 and day == 17:
		return "st_patricks"
	return ""

## "ireland", "wales", "scotland" or "england" (everything else, the Isle of Man included) for a zone region.
static func nation_for_region(region: String) -> String:
	if region.begins_with("ireland"):
		return "ireland"
	if region.ends_with("wales"):
		return "wales"
	if region == "scotland":
		return "scotland"
	return "england"

## True when a festival is kept in a region (national days only in their own nation).
static func festival_here(festival: String, region: String) -> bool:
	if festival == "":
		return false
	return not FESTIVAL_NATION.has(festival) or FESTIVAL_NATION[festival] == nation_for_region(region)

## "MM-DD" pins the date (the --date dev switch); "" or anything unreadable goes back to the real date.
static func set_override(mm_dd: String) -> void:
	_override = Vector2i(-1, -1)
	var parts := mm_dd.split("-")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return
	var m := int(parts[0])
	var d := int(parts[1])
	if m >= 1 and m <= 12 and d >= 1 and d <= 31:
		_override = Vector2i(m, d)

## Today as (month, day).
static func today() -> Vector2i:
	if _override.x > 0:
		return _override
	var d := Time.get_date_dict_from_system()
	return Vector2i(int(d.month), int(d.day))

static func season_today() -> String:
	var t := today()
	return season_for(t.x, t.y)

static func festival_today() -> String:
	var t := today()
	return festival_for(t.x, t.y)

## How strongly the trees show the season, each 0..1: (spring blossom, autumn colour, winter frost).
## Autumn deepens from a first touch of gold in early September to full russet by late November.
static func foliage_tint(month: int, day: int) -> Vector3:
	var f := clampf((day - 1) / 30.0, 0.0, 1.0)
	match month:
		3:
			return Vector3(0.3 + 0.4 * f, 0, 0)
		4:
			return Vector3(1, 0, 0)
		5:
			return Vector3(1.0 - 0.6 * f, 0, 0)
		9:
			return Vector3(0, 0.25 + 0.35 * f, 0)
		10:
			return Vector3(0, 0.6 + 0.3 * f, 0)
		11:
			return Vector3(0, 0.9 + 0.1 * f, 0)
		12, 2:
			return Vector3(0, 0, 0.85)
		1:
			return Vector3(0, 0, 1)
	return Vector3.ZERO

## A zone's weather odds for the season: in winter a frost is twice as likely (and a small chance where the
## zone never usually has one). Returns a copy; an empty table stays empty.
static func seasonal_weather(table: Dictionary, season: String) -> Dictionary:
	if season != "winter" or table.is_empty():
		return table
	var out := table.duplicate()
	var total := 0.0
	for k in table:
		total += float(table[k])
	var frost := float(table.get("frost", 0))
	out["frost"] = frost * 2.0 if frost > 0.0 else total * 0.05
	return out
