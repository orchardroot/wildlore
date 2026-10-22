extends TestCase
## Land and Sky (LandSky): the Almanac page of geology, weather and climate ideas that fills from flags already in
## the save, so old saves need nothing; the data names only flags something in the game can set.

## Flags set by code rather than by data: the chart challenge (Forecasting) and the rewilding sites (Rewild).
func _code_flags() -> Dictionary:
	return {"landsky_pressure": true, "rewild_goyt_moss": true, "rewild_complete": true}

func test_data_is_sound_and_every_flag_is_settable() -> void:
	var settable := Quests.all_settable()
	settable.merge(_code_flags())
	assert_eq(LandSky.check(settable), [])
	assert_true(LandSky.ideas().size() >= 12)

func test_plaque_flags_name_real_plaques() -> void:
	var plaques := {}
	for p in Gazetteer.all():
		plaques[str(p.id)] = true
	for i in LandSky.ideas():
		for f in i.flags:
			if str(f).begins_with(Gazetteer.PREFIX):
				assert_true(plaques.has(str(f).substr(Gazetteer.PREFIX.length())), "%s: plaque %s" % [i.id, f])

func test_an_idea_is_met_by_any_of_its_flags() -> void:
	var d := GameStateData.new()
	assert_eq(LandSky.met_count(d), 0)
	assert_eq(LandSky.rows(d).size(), 1, "one line saying nothing is noted yet")
	assert_eq(str(LandSky.rows(d)[0][0]), "Nothing noted yet")
	d.set_flag("plaque_landsky_old_man_of_hoy", true)
	assert_true(LandSky.met(d, LandSky.idea("stacks")))
	assert_eq(LandSky.met_count(d), 1)
	d.set_flag("landsky_stacks", true)
	assert_eq(LandSky.met_count(d), 1, "two flags of one idea count once")
	d.set_flag("rewild_goyt_moss", 2)
	assert_true(LandSky.met(d, LandSky.idea("peat")), "a rewilding stage (an int) counts")
	d.set_flag("rewild_complete", false)
	assert_false(LandSky.met(d, LandSky.idea("rewilding")), "a false flag doesn't")
	var rows := LandSky.rows(d)
	assert_eq(rows.size(), 2)
	assert_eq(str(rows[0][0]), "Sea stacks")
	assert_eq(str(rows[1][0]), "Peat and carbon")
	assert_eq(LandSky.blurb(d), "2 of %d ideas met" % LandSky.ideas().size())

func test_notes_fit_one_ledger_line() -> void:
	for i in LandSky.ideas():
		assert_true(str(i.note).length() <= 90, "%s note is %d characters" % [i.id, str(i.note).length()])
		assert_true(str(i.title).length() <= 30, "%s title" % i.id)

func test_almanac_page_sprouts_once_something_is_met() -> void:
	var d := GameStateData.new()
	assert_false(Almanac.sprouted(d, "landsky"))
	assert_false(Almanac.pages(d).any(func(p): return p.id == "landsky"))
	d.set_flag("landsky_jet", true)
	assert_true(Almanac.sprouted(d, "landsky"))
	var page: Dictionary = Almanac.pages(d).filter(func(p): return p.id == "landsky")[0]
	assert_eq(str(page.name), "Land and Sky")
	assert_eq(str(page.menu), "ledger:landsky")
	assert_eq(str(page.blurb), "1 of %d ideas met" % LandSky.ideas().size())
	var rows := Almanac.ledger(d, "landsky")
	assert_eq(rows.size(), 1)
	assert_eq(str(rows[0][0]), "The jet stream")
