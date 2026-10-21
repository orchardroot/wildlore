extends TestCase
## Weekly challenge rules and result codes (WeeklyChallenge), and the Share file naming.

func test_weeks_start_on_monday() -> void:
	var mon := WeeklyChallenge.week_number("2026-10-19")
	assert_eq(WeeklyChallenge.week_number("2026-10-25"), mon, "Sunday is the same week")
	assert_eq(WeeklyChallenge.week_number("2026-10-26"), mon + 1, "next Monday")
	assert_eq(WeeklyChallenge.week_number("2026-10-18"), mon - 1, "the Sunday before")

func test_rules_are_deterministic_and_sensible() -> void:
	var a := WeeklyChallenge.rules(2900)
	assert_eq(a, WeeklyChallenge.rules(2900))
	assert_true(a.nation in WeeklyChallenge.NATIONS)
	assert_true(a.level_cap in WeeklyChallenge.LEVEL_CAPS)
	assert_true(WeeklyChallenge.describe(a).contains("level cap"))

func test_result_code_round_trips_and_catches_typos() -> void:
	var t := {"caught": 37, "wins": 120, "steps": 45600}
	var code := WeeklyChallenge.result_code(2900, t)
	assert_eq(code, WeeklyChallenge.result_code(2900, t), "same run, same code")
	assert_false(code == WeeklyChallenge.result_code(2901, t), "another week")
	var r := WeeklyChallenge.read_code(code.to_lower())
	assert_eq(r.week, 2900)
	assert_eq(r.caught, 37)
	assert_eq(r.wins, 120)
	assert_eq(r.steps, 45600)
	var bad := code.substr(0, 6) + ("0" if code[6] != "0" else "1") + code.substr(7)
	assert_eq(WeeklyChallenge.read_code(bad), {}, "a changed character fails the checksum")
	assert_eq(WeeklyChallenge.read_code("hello"), {})

func test_share_names_are_safe() -> void:
	assert_eq(Share.file_name("postcard", "St Ives (Cornwall)", "2026-10-21"), "wildlore_postcard_st_ives_cornwall_2026-10-21.png")
	assert_eq(Share.caption("Cardiff", "2026-10-21"), "Cardiff, 2026-10-21")
	assert_eq(Share.caption("", ""), "")
