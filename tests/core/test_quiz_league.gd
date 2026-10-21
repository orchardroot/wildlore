extends TestCase
## The pub quiz league: a table per nation, deterministic rivals, one fixture per pub per real day, a title paid once
## and the Dublin cup final. Plus the quiz command wiring.

func _fresh() -> GameStateData:
	Calendar.set_override("2026-10-17")
	return GameStateData.new()

func test_every_nation_has_a_league_with_rivals() -> void:
	assert_eq(QuizLeague.nations().size(), 5)
	for n in QuizLeague.nations():
		assert_true(Standing.is_nation(n), "real nation " + n)
		assert_eq(QuizLeague.league(n).teams.size(), 5, n + " has five rivals")
		assert_false("—" in JSON.stringify(QuizLeague.league(n)), "no em-dashes")

func test_rivals_are_deterministic_and_in_range() -> void:
	for n in QuizLeague.nations():
		for t in QuizLeague.league(n).teams:
			for f in 6:
				var s := QuizLeague.rival_score(n, t, f)
				assert_true(s >= 0 and s <= 5)
				assert_eq(s, QuizLeague.rival_score(n, t, f), "same every time")

func test_a_round_counts_once_per_pub_per_real_day() -> void:
	var d := _fresh()
	assert_true(QuizLeague.record(d, "ireland", "dublin", 4).counted)
	assert_false(QuizLeague.record(d, "ireland", "dublin", 5).counted, "same pub, same day")
	assert_true(QuizLeague.record(d, "ireland", "galway", 3).counted, "another pub counts")
	assert_eq(QuizLeague.played(d, "ireland"), 2)
	assert_eq(QuizLeague.points(d, "ireland"), 7)
	Calendar.set_override("2026-10-18")
	assert_true(QuizLeague.record(d, "ireland", "dublin", 1).counted, "next real day")
	Calendar.set_override("")

func test_unknown_nation_does_nothing() -> void:
	var d := _fresh()
	assert_false(QuizLeague.record(d, "overseas", "x", 5).counted)
	assert_eq(QuizLeague.summary(d, "overseas"), "")

func _play_season(d: GameStateData, nation: String, score: int) -> Dictionary:
	var last := {}
	for i in QuizLeague.season():
		Calendar.set_override("2026-11-%02d" % (i + 1))
		last = QuizLeague.record(d, nation, "pub", score)
	return last

func test_perfect_season_wins_the_title_once() -> void:
	var d := _fresh()
	var money := d.money + d.euros
	var r := _play_season(d, "wales", 5)
	assert_true(r.closed and r.title)
	assert_true(QuizLeague.has_title(d, "wales"))
	assert_eq(QuizLeague.rank(d, "wales"), 1)
	assert_true(d.money + d.euros > money, "the trophy pays")
	var after := d.money + d.euros
	Calendar.set_override("2027-01-01")
	assert_false(QuizLeague.record(d, "wales", "pub", 5).counted, "season closed: no second title")
	assert_eq(d.money + d.euros, after)
	Calendar.set_override("")

func test_poor_season_misses_the_title() -> void:
	var d := _fresh()
	var r := _play_season(d, "england", 0)
	assert_true(r.closed)
	assert_false(r.title)
	assert_false(QuizLeague.has_title(d, "england"))
	assert_true(QuizLeague.rank(d, "england") > 1)
	Calendar.set_override("")

func test_ties_go_to_the_rivals() -> void:
	var d := _fresh()
	var rows := QuizLeague.table(d, "scotland")
	assert_eq(rows.size(), 6)
	assert_false(rows[0].me, "nought all: the rivals are listed ahead")
	Calendar.set_override("")

func test_cup_needs_two_titles_and_pays_once() -> void:
	var d := _fresh()
	assert_false(QuizLeague.cup_open(d))
	assert_false(QuizLeague.cup_result(d, 7, 7).won, "locked without titles")
	d.set_flag("qleague_title_wales", true)
	assert_false(QuizLeague.cup_open(d))
	d.set_flag("qleague_title_scotland", true)
	assert_true(QuizLeague.cup_open(d))
	assert_false(QuizLeague.cup_result(d, 4, 7).won, "four of seven is not enough")
	assert_true(QuizLeague.cup_open(d), "losing costs nothing")
	var r := QuizLeague.cup_result(d, 5, 7)
	assert_true(r.won and r.money > 0)
	assert_true(QuizLeague.cup_won(d))
	assert_false(QuizLeague.cup_open(d), "paid once")
	assert_false(QuizLeague.cup_result(d, 7, 7).won)
	Calendar.set_override("")

func test_league_cannot_print_money() -> void:
	# Titles are flagged, the cup is flagged, and a season closes: ten thousand rounds can't beat total_prizes().
	var d := _fresh()
	var before := d.money + d.euros
	for round in 200:
		Calendar.set_override("2030-%02d-%02d" % [1 + round / 28, 1 + round % 28])
		for n in QuizLeague.nations():
			QuizLeague.record(d, n, "pub_" + n, 5)
		QuizLeague.cup_result(d, 7, 7)
	var gained := d.money + d.euros - before
	assert_true(gained <= Wallet.localise(QuizLeague.total_prizes(), Wallet.EUR) * 2, "capped, got %d" % gained)
	Calendar.set_override("")

func test_quiz_command_feeds_the_league() -> void:
	var h := FakeStoryHost.new()
	h.zone = "dublin"
	h.menu_results = {"quiz:dublin:ireland": {"score": 4, "total": 5}}
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland", "who": "Quizmaster"}])
	assert_eq(QuizLeague.played(h.data, "ireland"), 1)
	assert_eq(QuizLeague.points(h.data, "ireland"), 4)

func test_cup_final_through_the_command() -> void:
	var h := FakeStoryHost.new()
	h.zone = "dublin"
	h.data.set_flag("qleague_title_wales", true)
	h.data.set_flag("qleague_title_england", true)
	h.choices = [0]
	h.menu_results = {"quiz:dublin:ireland::final": {"score": 6, "total": 7}}
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland", "who": "Quizmaster"}])
	assert_has(h.log, ["menu", "quiz:dublin:ireland::final"])
	assert_true(QuizLeague.cup_won(h.data))
