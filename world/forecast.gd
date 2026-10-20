class_name Forecast
extends RefCounted
## The Shipping Forecast, read by the wireless sets in home interiors (sign "kind": "radio").
## Pure text: the radio's own sea area (its first) gets the real weather the game is running right now; the others
## are drawn, once per game day, from the weather table of a stand-in zone out on that coast, so a gale on the
## Hebrides is something the Hebrides really do get. Everything here is deterministic for a given day.

## Sea area -> a zone whose weather table stands in for it.
const AREAS := {
	"Irish Sea": "liverpool", "Malin": "derry", "Hebrides": "portree", "Fair Isle": "kirkwall",
	"Forth": "edinburgh", "Tyne": "newcastle", "Humber": "york", "Thames": "london",
	"Dover": "london", "Wight": "glastonbury", "Portland": "bath", "Plymouth": "penzance",
	"Lundy": "cardiff", "Fastnet": "cork", "Shannon": "galway", "Rockall": "fort_william",
}

## What each weather sounds like at sea: the wind ({dir} is filled in per area), the weather, the visibility.
const SPEECH := {
	"clear": ["{dir} 3 or 4, occasionally 5 later.", "Fair.", "Good."],
	"sunshine": ["Variable 3 or less.", "Fair.", "Good, occasionally very good."],
	"drizzle": ["{dir} 4 or 5.", "Drizzle.", "Moderate, occasionally poor."],
	"downpour": ["{dir} 5 to 7, occasionally gale 8 later.", "Rain.", "Moderate or poor."],
	"fog": ["Variable 2 or 3.", "Fog.", "Very poor."],
	"gale": ["{dir} 7 to severe gale 9, occasionally storm 10 later.", "Squally showers.", "Moderate or good, occasionally poor."],
	"frost": ["{dir} 5 or 6.", "Wintry showers.", "Good, occasionally poor."],
}
const DIRECTIONS := {
	"clear": ["Northwesterly", "Westerly", "Northerly"],
	"drizzle": ["Southwesterly", "Westerly", "Southerly"],
	"downpour": ["Southwesterly", "Southerly", "Westerly"],
	"gale": ["Westerly", "Southwesterly", "Northwesterly"],
	"frost": ["Northerly", "Northeasterly", "Easterly"],
}
const SYNOPSES := {
	"clear": "High, Biscay, 1024, moving slowly east",
	"sunshine": "High, Fair Isle, 1032, slow-moving, with a ridge across the whole of the country",
	"drizzle": "Low, Shannon, 1002, moving slowly northeast",
	"downpour": "Low, Rockall, 990, moving east, deepening",
	"fog": "High, Dogger, 1026, almost stationary",
	"gale": "Low, Hebrides, 976, deepening rapidly, expected Fair Isle 968 by midnight",
	"frost": "High, Scandinavia, 1036, moving slowly southwest",
}
static func _speech(weather: String) -> Array:
	return SPEECH.get(weather, SPEECH.clear)

## "Irish Sea: southwesterly 5 to 7, occasionally gale 8 later. Rain. Moderate or poor." The same line all day.
static func area_line(area: String, weather: String, day: int) -> String:
	var w: String = weather if SPEECH.has(weather) else "clear"
	var s := _speech(w)
	var wind: String = s[0]
	if wind.contains("{dir}"):
		var dirs: Array = DIRECTIONS.get(w, DIRECTIONS.clear)
		var dir: String = dirs[absi(hash("%s/%d" % [area, day])) % dirs.size()]
		# the line reads as one sentence run: "Irish Sea: southwesterly 5 to 7"
		wind = wind.replace("{dir}", dir.to_lower())
	else:
		wind = wind.substr(0, 1).to_lower() + wind.substr(1)
	return "%s: %s %s %s" % [area, wind, s[1], s[2]]

## Weighted pick from {weather: weight} with u in [0, 1). Empty or all-zero tables give "clear".
static func pick(table: Dictionary, u: float) -> String:
	var total := 0.0
	for w in table:
		total += maxf(float(table[w]), 0.0)
	if total <= 0.0:
		return "clear"
	var r := u * total
	var last := "clear"
	for w in table:
		var wt := maxf(float(table[w]), 0.0)
		if wt <= 0.0:
			continue
		last = w
		r -= wt
		if r < 0.0:
			return w
	return last

## The weather table of the zone standing in for a sea area ({} for an unknown area).
static func area_table(area: String) -> Dictionary:
	if not AREAS.has(area):
		return {}
	return ZoneData.load_id(AREAS[area]).weather

static func synopsis(weather: String) -> String:
	return "The general synopsis at midnight: %s." % SYNOPSES.get(weather, SYNOPSES.clear)

## The dialogue lines of a whole forecast. `areas` nearest first (the first gets `actual` weather, the rest are
## drawn from `tables`: {area: weather table}, once per `day`).
static func broadcast(areas: Array, actual: String, day: int, tables: Dictionary) -> Array:
	var weathers := {}
	for i in areas.size():
		var a: String = areas[i]
		if i == 0:
			weathers[a] = actual if SPEECH.has(actual) else "clear"
		else:
			var u := float(absi(hash("%s#%d" % [a, day])) % 10000) / 10000.0
			weathers[a] = pick(tables.get(a, {}), u)
	var lines: Array = ["And now the Shipping Forecast, issued by the Met Office on behalf of the Maritime and Coastguard Agency."]
	var gales := []
	for a in areas:
		if weathers[a] == "gale":
			gales.append(a)
	if not gales.is_empty():
		lines.append("There are warnings of gales in %s." % ", ".join(PackedStringArray(gales)))
	lines.append(synopsis(weathers[areas[0]]))
	for i in areas.size():
		var line := area_line(areas[i], weathers[areas[i]], day)
		lines.append(("The area forecasts for the next 24 hours. " + line) if i == 0 else line)
	lines.append("That completes the Shipping Forecast.")
	return lines

## The lines for a radio sign now: the real weather and the real tables.
static func for_radio(sign: Dictionary, actual: String, day: int) -> Array:
	var areas: Array = sign.get("areas", [])
	if areas.is_empty():
		return [str(sign.get("text", "Static."))]
	var tables := {}
	for i in range(1, areas.size()):
		tables[areas[i]] = area_table(areas[i])
	return broadcast(areas, actual, day, tables)

## The weather the game is running right now (the --weather dev switch pins it, as for the sky).
static func current_weather() -> String:
	var forced: String = Game.args.get("weather", "")
	return forced if forced != "" else Game.data.weather

## "Outlook" lines for the radio, from the game's own clock: how long the current spell has left and what the
## sea area usually turns to next (its likeliest other weather), plus what the weather brings out on land.
## `minutes_left`: game minutes until the spell runs out (< 0 if unknown); `table`: the first area's weather table.
static func outlook(actual: String, minutes_left: int, table: Dictionary) -> Array:
	var w: String = actual if SPEECH.has(actual) else "clear"
	var out := []
	var hint := WeatherWild.hint(w)
	if hint != "":
		out.append(hint)
	if minutes_left < 0:
		return out
	var next := ""
	var best := 0.0
	for k in table:
		if k != w and float(table[k]) > best:
			best = float(table[k])
			next = str(k)
	var hours := maxi(1, int(round(minutes_left / 60.0)))
	var span := "about an hour" if hours == 1 else "about %d hours" % hours
	var line := "Outlook: this spell has %s left" % span
	if next != "":
		line += ", and %s is the likeliest to follow" % MoveFX.weather_phrase(next)
	out.append(line + ".")
	return out
