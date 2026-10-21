extends TestCase
## Local time in the Overseas Territories (Timezones): offsets, the EU and US summer-time switch dates, the text bits.

func _at(zone: String, y: int, m: int, d: int, uk_hhmm: String) -> String:
	return GameClock.text(Timezones.to_zone(GameClock.parse(uk_hhmm), zone, y, m, d))

func test_switch_dates_2026() -> void:
	assert_eq(Timezones.sunday(2026, 3, 0), 29, "EU spring forward")
	assert_eq(Timezones.sunday(2026, 10, 0), 25, "EU fall back")
	assert_eq(Timezones.sunday(2026, 3, 2), 8, "US spring forward")
	assert_eq(Timezones.sunday(2026, 11, 1), 1, "US fall back")
	assert_eq(Timezones.sunday(2024, 3, 0), 31)
	assert_eq(Timezones.sunday(2024, 3, 2), 10)

func test_fixed_offsets_winter_and_summer() -> void:
	# UK noon in January (GMT) and July (BST)
	var cases := {"utc": [720, 660], "falklands": [540, 480], "south_georgia": [600, 540], "rothera": [540, 480],
		"cayman": [420, 360], "ast": [480, 420], "pitcairn": [240, 180], "biot": [1080, 1020]}
	for z in cases:
		assert_eq(_at(z, 2026, 1, 15, "12:00"), GameClock.text(cases[z][0]), z + " in winter")
		assert_eq(_at(z, 2026, 7, 15, "12:00"), GameClock.text(cases[z][1]), z + " in summer")

func test_gibraltar_and_cyprus_follow_the_eu_but_stay_ahead_of_uk() -> void:
	assert_eq(_at("cet", 2026, 1, 15, "12:00"), "13:00")
	assert_eq(_at("cet", 2026, 7, 15, "12:00"), "13:00", "BST and CEST move together")
	assert_eq(_at("eet", 2026, 1, 15, "12:00"), "14:00")
	assert_eq(_at("eet", 2026, 7, 15, "12:00"), "14:00")

func test_us_style_dst_zones() -> void:
	assert_eq(_at("bermuda", 2026, 1, 15, "12:00"), "08:00", "AST")
	assert_eq(_at("bermuda", 2026, 7, 15, "12:00"), "08:00", "ADT while the UK is on BST")
	assert_eq(_at("eastern", 2026, 1, 15, "12:00"), "07:00", "EST")
	assert_eq(_at("eastern", 2026, 7, 15, "12:00"), "07:00", "EDT")

func test_the_gap_weeks_between_the_switches() -> void:
	# 2026-03-15: US already on summer time, UK still on GMT: Bermuda is 3h behind
	assert_eq(_at("bermuda", 2026, 3, 15, "12:00"), "09:00")
	assert_eq(_at("eastern", 2026, 3, 15, "12:00"), "08:00")
	# 2026-03-04: nobody has switched
	assert_eq(_at("bermuda", 2026, 3, 4, "12:00"), "08:00")
	# 2026-10-28: UK back on GMT, US still on summer time
	assert_eq(_at("bermuda", 2026, 10, 28, "12:00"), "09:00")
	# 2026-11-02: both back
	assert_eq(_at("bermuda", 2026, 11, 2, "12:00"), "08:00")

func test_the_switch_instants() -> void:
	# EU: UK clocks go forward at 01:00 GMT on 29 March: UK 00:30 is GMT, UK 02:30 is BST
	assert_eq(_at("utc", 2026, 3, 29, "00:30"), "00:30")
	assert_eq(_at("utc", 2026, 3, 29, "02:30"), "01:30", "UTC is now an hour behind the UK")
	assert_eq(_at("utc", 2026, 3, 28, "12:00"), "12:00")
	assert_eq(_at("utc", 2026, 10, 24, "12:00"), "11:00")
	assert_eq(_at("utc", 2026, 10, 26, "12:00"), "12:00")
	# US (Bermuda): 08 March, 02:00 local = 06:00 UTC = 06:00 UK (GMT)
	assert_eq(_at("bermuda", 2026, 3, 8, "05:59"), "01:59")
	assert_eq(_at("bermuda", 2026, 3, 8, "06:00"), "03:00")
	assert_eq(_at("bermuda", 2026, 11, 1, "04:59"), "01:59", "still ADT, UK on GMT")

func test_day_wraps_across_midnight() -> void:
	assert_eq(_at("pitcairn", 2026, 1, 15, "03:00"), "19:00", "the previous evening")
	assert_eq(_at("biot", 2026, 1, 15, "20:00"), "02:00", "the next morning")

func test_regions_resolve_and_default_to_uk() -> void:
	assert_eq(Timezones.zone_for_region("overseas_gibraltar"), "cet")
	assert_eq(Timezones.zone_for_region("overseas_pitcairn"), "pitcairn")
	assert_eq(Timezones.zone_for_region("channel_islands"), "uk")
	assert_eq(Timezones.zone_for_region("scotland"), "uk")
	assert_eq(Timezones.zone_for_region(""), "uk")
	assert_true(Timezones.is_abroad("falklands"))
	assert_true(not Timezones.is_abroad("uk"))

func test_every_overseas_territory_has_a_zone_and_a_flight() -> void:
	for e in Overseas.all():
		var id := str(e.id)
		assert_true(Timezones.flight_minutes(id) > 0, id + " has a flight time")
		var z := ZoneData.load_id(str(e.arrival.zone))
		if id not in ["guernsey", "jersey"]:
			assert_true(Timezones.is_abroad(Timezones.zone_for_region(z.region)), id + " arrival zone has local time")

func test_texts() -> void:
	var d := GameStateData.new()
	d.clock_minutes = GameClock.parse("12:00")
	Calendar.set_override("2026-01-15")
	assert_eq(Timezones.clock_text(d, "uk"), "12:00")
	assert_eq(Timezones.clock_text(d, "falklands"), "09:00 Falklands (UK 12:00)")
	assert_eq(Timezones.difference(d, "falklands"), -180)
	assert_eq(Timezones.difference(d, "biot"), 360)
	assert_eq(Timezones.arrival_text(d, "falklands", "falklands"), "Arrive 03:00 local time (18h 00m)")
	assert_eq(Timezones.jet_lag_line(-180).begins_with("Your body insists it is 3 hours later"), true)
	assert_eq(Timezones.jet_lag_line(60), "")
	Calendar.set_override("")

func test_validate_is_clean() -> void:
	var regions := {}
	for f in DirAccess.get_files_at("res://data/zones"):
		if f.ends_with(".json"):
			regions[str(ZoneData.load_id(f.get_basename()).region)] = true
	assert_eq(Timezones.validate(func(r): return regions.has(r)), [])
