extends TestCase
## County Shows and the Open Moot (core/tournament.gd): the show of the day, the level cap, rulesets, eligibility,
## the bracket draw, re-levelled teams, rosettes and the Moot streak.

func _dex() -> Dex:
	return Fixtures.dex()

func _data(badges := 2) -> GameStateData:
	var d := GameStateData.new()
	for i in badges:
		d.badges.append("b%d" % i)
	return d

func _mon(id: String, lvl: int) -> Creature:
	return Fixtures.creature(id, lvl)

# ---------------------------------------------------------------- the show of the day

func test_shows_load_and_name_real_towns() -> void:
	var shows := Tournament.shows()
	assert_true(shows.size() >= 5, "a handful of shows")
	for s in shows:
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % s.town), "%s town exists" % s.id)

func test_show_of_the_day_is_stable_and_only_in_visited_towns() -> void:
	var visited := ["macclesfield", "york"]
	var a := Tournament.show_for("2026-10-18", visited)
	assert_eq(a, Tournament.show_for("2026-10-18", visited), "same all day")
	var seen := {}
	for day in range(1, 29):
		var s := Tournament.show_for("2026-11-%02d" % day, visited)
		assert_true(str(s.town) in visited, "only towns you've been to")
		seen[s.id] = true
	assert_eq(seen.size(), 2, "both visited show towns come round")

func test_show_of_the_day_falls_back_to_cheshire() -> void:
	assert_eq(Tournament.show_for("2026-10-18", []).id, "cheshire")

func test_today_remembers_the_pick_for_the_day() -> void:
	var d := _data()
	d.set_flag("visited_macclesfield", true)
	var s := Tournament.today(d)
	assert_eq(s.id, "cheshire")
	d.set_flag("visited_york", true)  # visiting somewhere new mid-day doesn't move today's show
	assert_eq(Tournament.today(d).id, "cheshire")

# ---------------------------------------------------------------- caps and rules

func test_level_cap_is_the_next_keepers_band() -> void:
	assert_eq(Tournament.level_cap(2, false), 28, "after two badges, Eluned's band")
	assert_eq(Tournament.level_cap(3, false), 35)
	assert_eq(Tournament.level_cap(10, false), 91, "all ten: the Champion's")
	assert_eq(Tournament.level_cap(10, true), 100, "post-game: open")

func test_ruleset_is_stable_for_a_seed_and_the_type_class_is_one_you_have() -> void:
	var party := [_mon("pipkin", 10), _mon("kindlet", 10)]
	var types := {}
	for c in party:
		for t in c.types():
			types[t] = true
	var kinds := {}
	for i in 60:
		var r := Tournament.ruleset("seed%d" % i, party)
		assert_eq(r, Tournament.ruleset("seed%d" % i, party))
		kinds[r.id] = true
		if r.id == "type":
			assert_true(types.has(r.type), "a class someone in the team can enter")
	for k in Tournament.RULES:
		assert_true(kinds.has(k), "rule %s comes up" % k)

func test_rule_names() -> void:
	assert_eq(Tournament.rule_name({"id": "type", "type": "kin"}), "Kin class")
	assert_eq(Tournament.rule_name({"id": "doubles"}), "Doubles")

func test_eligibility_by_type_and_lightweights() -> void:
	var kindlet := _mon("kindlet", 10)
	var pipkin := _mon("pipkin", 10)
	var party := [kindlet, pipkin]
	var t: String = kindlet.types()[0]
	var r := Tournament.eligible(party, {"id": "type", "type": t}, 3)
	assert_true(0 in r.picks)
	for i in r.picks:
		assert_true(t in party[i].types())
	var none := Tournament.eligible([], {"id": "singles"}, 3)
	assert_eq(none.picks, [])
	assert_true(str(none.why) != "", "a kind reason when nobody can enter")
	var light := Tournament.eligible(party, {"id": "lightweights"}, 3)
	for i in light.picks:
		assert_true(party[i].species.evolves != null, "still growing")

func test_doubles_needs_two_and_picks_are_capped() -> void:
	var one := Tournament.eligible([_mon("pipkin", 10)], {"id": "doubles"}, 3)
	assert_eq(one.picks, [])
	assert_true(str(one.why).contains("two"))
	var many := []
	for i in 6:
		many.append(_mon("pipkin", 10))
	assert_eq(Tournament.eligible(many, {"id": "singles"}, 3).picks, [0, 1, 2])
	var fainted := _mon("kindlet", 10)
	fainted.hp = 0
	assert_eq(Tournament.eligible([fainted, _mon("pipkin", 5)], {"id": "singles"}, 3).picks, [0, 1], "everyone's healed first, so fainted is fine")

# ---------------------------------------------------------------- foes

func test_relevel_keeps_to_the_level_and_devolves_when_too_young() -> void:
	var dex := _dex()
	# find an evolved species with a level-based evolution
	var evolved := ""
	var base := ""
	var at := 0
	for id in dex.ids():
		var sp := dex.get_species(id)
		if sp.evolves is Dictionary and sp.evolves.has("level"):
			evolved = str(sp.evolves.to)
			base = id
			at = int(sp.evolves.level)
			break
	var def := {"id": "x", "name": "X", "party": [{"species": evolved, "level": 60}]}
	var low := Tournament.foe_party(def, at - 2, {"id": "singles"}, dex, 3)
	assert_eq(low.size(), 1)
	assert_eq(low[0].level, at - 2)
	assert_eq(low[0].species, base, "too young to have evolved")
	var high := Tournament.foe_party(def, at + 5, {"id": "singles"}, dex, 3)
	assert_eq(high[0].species, evolved)

func test_foe_party_follows_the_rule() -> void:
	var dex := _dex()
	var def := StoryData.trainer("dee_angler")
	var light := Tournament.foe_party(def, 40, {"id": "lightweights"}, dex, 3)
	assert_true(light.size() >= 1)
	for m in light:
		assert_true(dex.get_species(m.species).evolves != null, m.species + " can still evolve")
	var t: String = dex.get_species(str(def.party[0].species)).types[0]
	for m in Tournament.foe_party(def, 40, {"id": "type", "type": t}, dex, 3):
		assert_true(t in dex.get_species(m.species).types)
	assert_true(Tournament.foe_party(def, 40, {"id": "singles"}, dex, 1).size() == 1, "size limit")

func test_draw_is_seeded_distinct_and_fits_the_rule() -> void:
	var dex := _dex()
	var pool := Tournament.trainer_pool(false)
	assert_true(pool.size() > 100)
	for id in pool:
		assert_false(str(id).begins_with("keeper_") or str(id).begins_with("dev") or str(id).contains("rematch"), id)
	var a := Tournament.draw("2026-10-18/cheshire", pool, 3, {"id": "doubles"}, dex, 30)
	assert_eq(a.size(), 3)
	assert_eq(a, Tournament.draw("2026-10-18/cheshire", pool, 3, {"id": "doubles"}, dex, 30))
	assert_true(a[0].id != a[1].id and a[1].id != a[2].id and a[0].id != a[2].id)
	for t in a:
		assert_true(t.party.size() >= 2, "doubles: two to send out")
		for m in t.party:
			assert_eq(int(m.level), 30)
	var moot := Tournament.trainer_pool(true)
	assert_has(moot, "keeper_maud")
	assert_true(moot.size() > pool.size())

func test_moot_bracket_is_five_with_a_keeper_last() -> void:
	var b := Tournament.moot_bracket("2026-10-18/moot/1", {"id": "singles"}, _dex(), [58, 59, 60, 61, 62])
	assert_eq(b.size(), 5)
	assert_true(str(b[4].id).begins_with("keeper_"), "a Keeper keeps the heel stone")
	for i in 4:
		assert_false(str(b[i].id).begins_with("keeper_"))
		assert_true(b[i].party.size() >= 3, "Moot teams are three strong at least")
	assert_eq(int(b[4].party[0].level), 62)
	var typed := Tournament.moot_bracket("x", {"id": "type", "type": "frost"}, _dex(), [50, 50, 50, 50, 50])
	assert_eq(typed.size(), 5, "even a narrow class fills the bracket")

func test_foe_levels_by_round() -> void:
	assert_eq(Tournament.show_level(0, 25, 28), 23, "round one a touch under you")
	assert_eq(Tournament.show_level(2, 25, 28), 25)
	assert_eq(Tournament.show_level(2, 40, 28), 28, "never past the cap")
	assert_eq(Tournament.moot_level(4, 100), 100)
	assert_eq(Tournament.moot_level(0, 60), 58)

# ---------------------------------------------------------------- prizes

func test_rosettes_by_placement() -> void:
	assert_eq(Tournament.rosettes_for(0), 0)
	assert_eq(Tournament.rosettes_for(1), 1, "yellow")
	assert_eq(Tournament.rosettes_for(2), 2, "blue")
	assert_eq(Tournament.rosettes_for(3), 3, "red")
	assert_eq(Tournament.rosette_colour(3), "red")
	assert_eq(Tournament.rosette_colour(2), "blue")
	assert_eq(Tournament.rosette_colour(1), "yellow")

func test_show_prizes_top_up_to_three_a_day() -> void:
	var d := _data()
	assert_eq(Tournament.pay_show(d, 1), 1)
	assert_eq(Bag.new(d.bag).count(Tournament.ROSETTE), 1)
	assert_eq(Tournament.pay_show(d, 1), 0, "the same placement again pays nothing more")
	assert_eq(Tournament.pay_show(d, 3), 2, "a better one tops it up")
	assert_eq(Tournament.pay_show(d, 3), 0)
	assert_eq(Bag.new(d.bag).count(Tournament.ROSETTE), 3)

func test_moot_streak_and_title() -> void:
	var d := _data(10)
	for i in 5:
		Tournament.note_moot_fight(d, true)
	assert_eq(Tournament.streak(d), 5)
	Tournament.note_moot_fight(d, false)
	assert_eq(Tournament.streak(d), 0)
	assert_eq(Tournament.best_streak(d), 5, "the best is kept")
	assert_false(Tournament.moot_champion(d))
	for i in 3:
		Tournament.note_moot_win(d)
	assert_true(Tournament.moot_champion(d), "three wins: Moot Champion")

func test_wares_rotate_and_moot_stock_needs_the_title_of_champion() -> void:
	var d := _data()
	var w := Tournament.wares("2026-10-18", d)
	assert_eq(w.size(), Tournament.WARES_A_DAY)
	assert_eq(w, Tournament.wares("2026-10-18", d))
	for x in w:
		assert_false(Tournament.config().moot_wares.has(x), "no Moot stock before the champion")
	d.set_flag("champion", true)
	var post := Tournament.wares("2026-10-18", d)
	assert_eq(post.size(), Tournament.WARES_A_DAY + 1, "one Moot piece once you're champion")

func test_buying_spends_rosettes_and_gives_the_thing() -> void:
	var d := _data()
	var items := ItemDB.load_default()
	var ware := {"item": "hazel_snare", "n": 3, "cost": 2}
	assert_false(bool(Tournament.buy(d, ware, items).ok), "no rosettes, no snares")
	Bag.new(d.bag).add(Tournament.ROSETTE, 3)
	var r := Tournament.buy(d, ware, items)
	assert_true(bool(r.ok))
	assert_eq(Bag.new(d.bag).count("hazel_snare"), 3)
	assert_eq(Bag.new(d.bag).count(Tournament.ROSETTE), 1)
	var rec := Tournament.buy(d, {"recipe": "parkin", "cost": 1}, items)
	assert_true(bool(rec.ok))
	assert_true(Crafting.is_known(d, "parkin"))
	assert_eq(Bag.new(d.bag).count(Tournament.ROSETTE), 0, "the last rosette used up")
	Bag.new(d.bag).add(Tournament.ROSETTE, 3)
	assert_false(bool(Tournament.buy(d, {"recipe": "parkin", "cost": 1}, items).ok), "can't learn it twice")

func test_stats_lines() -> void:
	var d := _data()
	var lines := Tournament.stat_lines(d)
	assert_eq(lines.size(), 2)
	d.set_flag(Tournament.MOOT_WINS, 3)
	lines = Tournament.stat_lines(d)
	assert_eq(lines.size(), 3)
	assert_eq(lines[2][1], "Moot Champion")

func test_the_rosette_is_a_key_item() -> void:
	var it := ItemDB.load_default().get_item(Tournament.ROSETTE)
	assert_eq(str(it.get("kind", "")), "key")

func test_the_stats_page_shows_the_rows() -> void:
	var labels := TrainerStats.lines(_data()).map(func(r): return r[0])
	assert_has(labels, "County Shows won")
	assert_has(labels, "Best Open Moot streak")

func test_the_wireless_names_todays_show() -> void:
	var d := _data()
	d.set_flag("visited_macclesfield", true)
	var line := Tournament.radio_line(d)
	assert_true(line.contains("Cheshire Show"), line)
	assert_false(line.contains("—"), "no em-dash")
	var lines := TodaysWalk.radio_lines(d, null, ItemDB.load_default())
	assert_true(lines.has(line), "read out after Today's Walk")

## The dialogue box holds about three lines (some 200 characters at the default font): longer and the last line
## drops off the bottom of the screen.
const BOX_CHARS := 200

func test_show_lines_fit_the_dialogue_box() -> void:
	for s in Tournament.shows():
		var d := _data()
		d.set_flag(Tournament.TODAY, {"key": Calendar.today_key(), "id": str(s.id)})
		for line in Tournament.radio_lines(d):
			assert_true(str(line).length() <= BOX_CHARS, "%s on the wireless: %d chars" % [s.id, str(line).length()])
		for line in TournamentRun.welcome_lines(s):
			assert_true(str(line).length() <= BOX_CHARS, "%s welcome: %d chars" % [s.id, str(line).length()])
