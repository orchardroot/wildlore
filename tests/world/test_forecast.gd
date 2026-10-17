extends TestCase
## The Shipping Forecast radios and the blue plaques: the pure weather-to-text mapping, and the zone data that uses it.

const SEA_AREAS := ["Irish Sea", "Malin", "Hebrides", "Fair Isle", "Forth", "Tyne", "Humber", "Thames", "Dover", "Wight",
	"Portland", "Plymouth", "Lundy", "Fastnet", "Shannon", "Rockall"]
const WEATHERS := ["clear", "sunshine", "drizzle", "downpour", "fog", "gale", "frost"]

func _signs_of_kind(kind: String) -> Array:
	var out := []
	for path in JsonUtil.list_json(ZoneData.DIR):
		var d = JsonUtil.read(path)
		if d is Dictionary:
			for s in d.get("signs", []):
				if str(s.get("kind", "")) == kind:
					out.append({"zone": d.get("id", ""), "sign": s})
	return out

# --- the pure mapping ----------------------------------------------------------

func test_every_weather_has_a_forecast_line_with_wind_weather_and_visibility() -> void:
	for w in WEATHERS:
		var line := Forecast.area_line("Irish Sea", w, 3)
		assert_true(line.begins_with("Irish Sea: "), w + " starts with the area")
		assert_true(line.ends_with("."), w + " ends with a full stop")
		assert_true(line.contains("Good") or line.contains("Moderate") or line.contains("poor"), w + " reports visibility: " + line)

func test_the_wording_follows_the_weather() -> void:
	assert_true(Forecast.area_line("Malin", "gale", 1).contains("gale"), "gale")
	assert_true(Forecast.area_line("Malin", "gale", 1).contains("severe gale 9"), "gale is a proper one")
	assert_true(Forecast.area_line("Humber", "fog", 1).contains("Fog"), "fog")
	assert_true(Forecast.area_line("Humber", "fog", 1).contains("Very poor"), "fog is poor visibility")
	assert_true(Forecast.area_line("Thames", "downpour", 1).contains("Rain"), "downpour is rain")
	assert_true(Forecast.area_line("Thames", "downpour", 1).contains("gale 8"), "downpour gets a gale mention")
	assert_true(Forecast.area_line("Wight", "drizzle", 1).contains("Drizzle"), "drizzle")
	assert_true(Forecast.area_line("Wight", "sunshine", 1).contains("Fair"), "sunshine is fair")
	assert_true(Forecast.area_line("Wight", "frost", 1).contains("Wintry"), "frost is wintry")
	assert_true(Forecast.area_line("Wight", "clear", 1).contains("Good"), "clear is good")

func test_unknown_weather_reads_as_clear() -> void:
	assert_eq(Forecast.area_line("Dover", "", 4), Forecast.area_line("Dover", "clear", 4))
	assert_eq(Forecast.area_line("Dover", "tornado", 4), Forecast.area_line("Dover", "clear", 4))

func test_lines_are_deterministic_and_the_direction_varies_by_area() -> void:
	assert_eq(Forecast.area_line("Lundy", "gale", 7), Forecast.area_line("Lundy", "gale", 7))
	var seen := {}
	for a in SEA_AREAS:
		seen[Forecast.area_line(a, "drizzle", 2).trim_prefix(a + ": ").split(" ")[0]] = true
	assert_true(seen.size() > 1, "not every area has the same wind direction")

func test_pick_follows_the_weather_table() -> void:
	assert_eq(Forecast.pick({"fog": 5}, 0.99), "fog")
	assert_eq(Forecast.pick({"fog": 1, "gale": 1}, 0.1), "fog")
	assert_eq(Forecast.pick({"fog": 1, "gale": 1}, 0.9), "gale")
	assert_eq(Forecast.pick({}, 0.5), "clear")
	assert_eq(Forecast.pick({"fog": 0, "gale": 0}, 0.5), "clear")
	assert_eq(Forecast.pick({"fog": 0, "gale": 2}, 0.01), "gale", "zero weights are never picked")

func test_the_first_area_reports_the_actual_weather() -> void:
	var tables := {"Irish Sea": {"clear": 1}, "Malin": {"fog": 1}, "Hebrides": {"gale": 1}}
	var lines := Forecast.broadcast(["Irish Sea", "Malin", "Hebrides"], "downpour", 5, tables)
	var body := "\n".join(PackedStringArray(lines))
	assert_true(body.contains(Forecast.area_line("Irish Sea", "downpour", 5)), "the player's own area is the real weather")
	assert_true(body.contains(Forecast.area_line("Malin", "fog", 5)), "the others come from their tables")
	assert_true(body.contains(Forecast.area_line("Hebrides", "gale", 5)))

func test_broadcast_has_the_real_cadence() -> void:
	var tables := {"Irish Sea": {"drizzle": 1}, "Malin": {"drizzle": 1}, "Hebrides": {"drizzle": 1}}
	var lines := Forecast.broadcast(["Irish Sea", "Malin", "Hebrides"], "drizzle", 1, tables)
	assert_true(lines[0].contains("Shipping Forecast"), "opens with the title")
	assert_true(lines[0].contains("Met Office on behalf of the Maritime and Coastguard Agency"))
	assert_true(lines[lines.size() - 1].contains("That completes the Shipping Forecast"), "signs off")
	assert_true(lines.size() >= 5 and lines.size() <= 8, "intro, synopsis, areas, sign-off: %d" % lines.size())

func test_gale_warning_names_the_gale_areas() -> void:
	var tables := {"Irish Sea": {"clear": 1}, "Malin": {"gale": 1}, "Hebrides": {"gale": 1}}
	var body := "\n".join(PackedStringArray(Forecast.broadcast(["Irish Sea", "Malin", "Hebrides"], "clear", 1, tables)))
	assert_true(body.contains("gales in Malin, Hebrides"), "warning lists them")
	var calm := "\n".join(PackedStringArray(Forecast.broadcast(["Irish Sea", "Malin"], "clear", 1, {"Irish Sea": {"clear": 1}, "Malin": {"clear": 1}})))
	assert_false(calm.contains("warnings of gales"), "no warning when it is calm")

func test_synopsis_matches_the_weather() -> void:
	for w in WEATHERS:
		assert_true(Forecast.synopsis(w).begins_with("The general synopsis"), w)
	assert_true(Forecast.synopsis("gale").contains("Low"), "gales come with a low")
	assert_true(Forecast.synopsis("sunshine").contains("High"), "sun comes with a high")

func test_no_em_dashes_and_every_area_is_real() -> void:
	for a in Forecast.AREAS:
		assert_has(SEA_AREAS, a)
	assert_eq(Forecast.AREAS.size(), SEA_AREAS.size(), "all sixteen are covered")
	for w in WEATHERS:
		for a in SEA_AREAS:
			assert_false(Forecast.area_line(a, w, 9).contains("—"), "no em-dash")
	assert_false(Forecast.synopsis("gale").contains("—"))

func test_each_area_reads_its_weather_table_from_a_real_zone() -> void:
	for a in Forecast.AREAS:
		var t := Forecast.area_table(a)
		assert_false(t.is_empty(), a + " has a weather table in its stand-in zone '%s'" % Forecast.AREAS[a])

# --- the data ------------------------------------------------------------------

func test_a_dozen_radios_including_mums_house() -> void:
	var radios := _signs_of_kind("radio")
	assert_true(radios.size() >= 12, "radios: %d" % radios.size())
	var zones := {}
	for r in radios:
		zones[r.zone] = true
		var areas: Array = r.sign.get("areas", [])
		assert_true(areas.size() >= 3 and areas.size() <= 4, "%s reads 3 or 4 areas" % r.zone)
		for a in areas:
			assert_has(SEA_AREAS, a, r.zone)
		assert_true(str(r.sign.get("text", "")) != "", r.zone + " has a fallback text")
	assert_has(zones, "macc_home", "Mum has a wireless")
	var regions := {}
	for z in zones:
		var d = JsonUtil.read(ZoneData.DIR.path_join(z + ".json"))
		assert_eq(d.kind, "interior", z + " is indoors")
		regions[str(d.warps[0].to)] = true
	assert_true(regions.size() >= 12, "a spread of towns: %d" % regions.size())

func test_blue_plaques() -> void:
	var plaques := _signs_of_kind("plaque")
	assert_true(plaques.size() >= 38, "plaques: %d" % plaques.size())
	var towns := {}
	for p in plaques:
		towns[p.zone] = true
		var t := str(p.sign.get("text", ""))
		assert_true(t.begins_with("BLUE PLAQUE: ") or t.begins_with("GREEN PLAQUE: "), p.zone + ": " + t)
		assert_false(t.contains("—"), "no em-dash in " + t)
		assert_true(p.sign.has("dx"), "sits on the wall edge beside the door")
	assert_true(towns.size() >= 36, "spread over the towns: %d" % towns.size())
	for t in ["manchester", "macclesfield", "liverpool", "edinburgh", "dublin", "cardiff", "london", "whitby", "york", "belfast"]:
		assert_has(towns, t, "plaque in " + t)

func test_plaques_stand_on_building_tiles_beside_a_door() -> void:
	for p in _signs_of_kind("plaque"):
		var z := ZoneData.load_id(p.zone)
		var pos := Vector2i(int(p.sign.x), int(p.sign.y))
		assert_eq(z.tile_at(pos), "building", p.zone + ": plaque is on the wall, not on a path")
		assert_eq(z.tile_at(pos + Vector2i(0, 1)) != "building", true, p.zone + ": the wall faces open ground")
		assert_true(z.walkable(pos + Vector2i(0, 1)), p.zone + ": you can stand in front of it")
		var door := false
		for dx in [-1, 1]:
			if z.tile_at(pos + Vector2i(dx, 0)) == "door":
				door = true
		assert_true(door, p.zone + ": next to a door")
