extends TestCase
## NPC routines: weekday, hour and season pick a spot; the shipped ones keep clear of doors.

const NPC := {"id": "a", "x": 1, "y": 1, "routine": [
	{"days": [0], "from": "09:30", "to": "12:00", "x": 5, "y": 5, "facing": "up"},
	{"from": "22:00", "to": "02:00", "x": 7, "y": 7},
	{"seasons": ["summer"], "from": "12:00", "to": "16:00", "x": 9, "y": 9}]}

func test_no_routine_stays_put() -> void:
	var d := {"id": "b", "x": 1, "y": 1}
	assert_eq(Routines.placed(d, 0, "summer", 600), d)

func test_sunday_morning_is_church() -> void:
	var p := Routines.placed(NPC, 0, "winter", 10 * 60)
	assert_eq([p.x, p.y, p.facing], [5, 5, "up"])
	assert_eq(Routines.placed(NPC, 1, "winter", 10 * 60).x, 1, "not on a Monday")
	assert_eq(Routines.placed(NPC, 0, "winter", 12 * 60).x, 1, "to is exclusive")

func test_slot_may_cross_midnight() -> void:
	assert_eq(Routines.placed(NPC, 3, "winter", 23 * 60).x, 7)
	assert_eq(Routines.placed(NPC, 3, "winter", 60).x, 7)
	assert_eq(Routines.placed(NPC, 3, "winter", 2 * 60).x, 1)

func test_summer_only_beach() -> void:
	assert_eq(Routines.placed(NPC, 3, "summer", 13 * 60).x, 9)
	assert_eq(Routines.placed(NPC, 3, "winter", 13 * 60).x, 1)

func test_stamp_changes_with_the_half_hour_and_day() -> void:
	assert_true(Routines.stamp(1, "summer", 600) != Routines.stamp(1, "summer", 631))
	assert_true(Routines.stamp(1, "summer", 600) != Routines.stamp(2, "summer", 600))

func test_weekday_follows_the_date_override() -> void:
	Calendar.set_override("2026-10-18")  # a Sunday
	assert_eq(Calendar.weekday_today(), 0)
	Calendar.set_override("2026-10-21")
	assert_eq(Calendar.weekday_today(), 3)
	Calendar.set_override("")

func test_shipped_routines_are_valid_and_clear_of_doors() -> void:
	var n := 0
	for z in ZoneData.load_all().values():
		for d in z.npcs:
			if d.has("routine"):
				n += 1
				assert_eq(Routines.errors(d, z, Routines.blocked_tiles_except(z, d)), [], str(d.id))
				assert_eq(str(d.get("move", "still")), "still", str(d.id))
	assert_true(n >= 1)
