extends TestCase
## 2.0 QA: bugs that live between the 2.0 features (shows, parish, rewilding, coats and home, postcards, battle depth).

class FakeGame extends Node:
	var data := GameStateData.new()
	var dex: Dex
	var items: ItemDB

func _parish() -> Parish:
	var g := FakeGame.new()
	g.dex = Fixtures.dex()
	g.data.zone_id = "macclesfield"
	var p := Parish.new()
	p._game = g
	p._kind = "trainer"
	return p

func test_a_trainer_win_earns_a_little_standing() -> void:
	var p := _parish()
	p._on_battle_ended({"result": "win", "money": 100})
	assert_eq(Standing.points(p._data(), "england"), Standing.FOR_TRAINER)

func test_show_and_moot_bouts_earn_no_standing() -> void:
	# a County Show can be re-entered all day and the Open Moot without end: their wins must not farm standing
	var p := _parish()
	for i in 20:
		p._on_battle_ended({"result": "win", "money": 0, "exhibition": true})
	assert_eq(Standing.points(p._data(), "england"), 0)

## Mid-game, with a side story waiting, a rewilding site half done, a job on and a Fieldbook milestone due,
## "Where next?" still names the next story beat.
func test_where_next_keeps_the_story_first_mid_game() -> void:
	var d := GameStateData.new()
	for f in ["starter", "badge_brook", "bev_bike_given", "badge_urban", "badge_stone", "trainer_keeper_maud",
			"trainer_keeper_ray", "trainer_keeper_eluned"]:
		d.set_flag(f, true)
	d.badges = ["brook", "urban", "stone"]
	for i in 60:
		d.caught["c%d" % i] = true
	var site := str(Rewild.sites()[0].id)
	Rewild.contribute(d, site)
	d.set_flag(Rewild.flag_key(site) + "_met", true)
	Jobs.accept(d, str(Jobs.offers(d, "macclesfield")[0].id), "macclesfield")
	assert_false(SideStories.next_hint(d).is_empty(), "a side story is waiting")
	assert_true(Rewild.hint(d) != "", "a rewilding site wants a hand")
	var o := MenuLogic.next_objective(d, 124)
	assert_eq(str(o.get("town", "")), "yr_wyddfa", str(o))
	assert_false(bool(o.get("postgame", false)))
