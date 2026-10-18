extends TestCase
## The pause card's "Around here" line (2.1): what's going on near you, before the ending. In priority order: a
## job ready to hand in, a County Show in this town today, a rewilding site wanting a hand, a side story in town.

const JOBS := [
	{"id": "j_bring", "nation": "england", "town": "macclesfield", "badges": 0, "poster": "C", "title": "Jam", "text": "t",
		"step": {"type": "bring", "item": "blackberries", "n": 1}, "pay": 1},
]
const SIDES := [{"id": "s1", "zone": "buxton", "after": "badge_brook", "hint": "Someone in Buxton wants a word."}]

func _data() -> GameStateData:
	Jobs.use(JOBS)
	var d := GameStateData.new()
	d.set_flag("last_town", "buxton")
	return d

func _done() -> void:
	Jobs.reset()

func test_nothing_to_say_is_empty() -> void:
	assert_eq(MenuLogic.around_here(_data(), "buxton", {}, SIDES), "")
	_done()

func test_a_ready_job_comes_first() -> void:
	var d := _data()
	d.set_flag("badge_brook", true)
	Jobs.accept(d, "j_bring", "macclesfield")
	Bag.new(d.bag).add("blackberries", 1)
	var line := MenuLogic.around_here(d, "buxton", {"name": "Buxton Show", "town": "buxton"}, SIDES)
	assert_true(line.contains("Jam") and line.contains("noticeboard"), line)
	_done()

func test_then_a_show_in_town_today() -> void:
	var d := _data()
	d.set_flag("badge_brook", true)
	assert_false(MenuLogic.around_here(d, "buxton", {"name": "Buxton Show", "town": "buxton"}, SIDES).contains("Buxton Show"),
		"not before you can enter")
	for i in Tournament.MIN_BADGES:
		d.badges.append("b%d" % i)
	var line := MenuLogic.around_here(d, "buxton", {"name": "Buxton Show", "town": "buxton"}, SIDES)
	assert_true(line.contains("Buxton Show"), line)
	assert_false(MenuLogic.around_here(d, "macclesfield", {"name": "Buxton Show", "town": "buxton"}, SIDES).contains("Buxton Show"),
		"only the show in this town")
	_done()

func test_then_a_rewilding_site_then_a_side_story() -> void:
	var d := _data()
	d.set_flag("badge_brook", true)
	var line := MenuLogic.around_here(d, "buxton", {}, SIDES)
	assert_eq(line, str(Rewild.hint_entry(d).text), "a site wants a hand")
	for s in Rewild.sites():
		d.set_flag(Rewild.flag_key(str(s.id)), Rewild.WILD)
	assert_eq(MenuLogic.around_here(d, "buxton", {}, SIDES), "Someone in Buxton wants a word.")
	assert_eq(MenuLogic.around_here(d, "macclesfield", {}, SIDES), "", "a side story elsewhere is not around here")
	_done()

func test_quiet_after_the_ending() -> void:
	var d := _data()
	d.set_flag("badge_brook", true)
	d.set_flag("game_complete", true)
	assert_eq(MenuLogic.around_here(d, "buxton", {}, SIDES), "", "the Still to do card covers it")
	_done()
