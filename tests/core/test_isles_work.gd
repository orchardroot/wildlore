extends TestCase
## How these isles work: topics learnt by a flag set in dialogue or by a plaque read, counted for the Gazetteer page,
## and checked by the validator (learnable, short lines, no em-dashes). Plus the real data and the Derry to Donegal
## delivery that teaches the open border.

func _list() -> Array:
	return IslesWork.parse({"topics": [
		{"id": "uk", "title": "The UK", "where": "Westminster", "lines": ["Great Britain is an island."]},
		{"id": "cta", "title": "The Common Travel Area", "where": "Holyhead", "lines": ["Since 1923."], "also": ["plaque_isles_cta"]},
	]})

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_learnt_by_its_flag_or_a_plaque() -> void:
	var l := _list()
	assert_eq(IslesWork.count(_data(), l), 0)
	assert_eq(IslesWork.progress_line(_data(), l), "Nothing yet")
	assert_true(IslesWork.is_learnt(_data({"isles_uk": true}), l[0]))
	assert_false(IslesWork.is_learnt(_data({"isles_uk": true}), l[1]))
	assert_true(IslesWork.is_learnt(_data({"plaque_isles_cta": true}), l[1]), "a plaque read counts")
	assert_eq(IslesWork.progress_line(_data({"isles_uk": true, "isles_cta": true}), l), "2 of 2 understood")

func test_parse_defaults_missing_lists() -> void:
	var l := IslesWork.parse({"topics": [{"id": "x"}]})
	assert_eq(l[0].lines, [])
	assert_eq(l[0].also, [])
	assert_eq(IslesWork.parse("nonsense"), [])

func test_validate_catches_problems() -> void:
	var bad := IslesWork.parse({"topics": [
		{"id": "a", "title": "A", "where": "W", "lines": ["fine"]},
		{"id": "a", "title": "", "where": "W", "lines": []},
		{"id": "b", "title": "B — dash", "where": "W", "lines": ["x".repeat(IslesWork.MAX_LINE + 1)]},
	]})
	var e := IslesWork.validate(bad, {"isles_a": true})
	var joined := "\n".join(e)
	assert_true("listed twice" in joined)
	assert_true("needs a title" in joined)
	assert_true("has no lines" in joined)
	assert_true("em-dash" in joined)
	assert_true("over %d characters" % IslesWork.MAX_LINE in joined)
	assert_true("can't be learnt" in joined, "b: nothing sets isles_b")
	assert_eq(IslesWork.validate(_list(), {"isles_uk": true, "plaque_isles_cta": true}), [])

func test_real_topics_are_all_learnable_and_clean() -> void:
	IslesWork.reset()
	var l := IslesWork.all()
	assert_true(l.size() >= 12, "a dozen or more topics")
	assert_eq(IslesWork.validate(l, Quests.all_settable()), [])
	var ids := l.map(func(t): return str(t.id))
	for want in ["uk_gb_isles", "devolution", "ireland", "troubles", "open_border", "cta", "brexit", "windsor", "crown_deps", "overseas", "commonwealth", "chagos"]:
		assert_true(want in ids, "topic %s" % want)

func test_border_quest_is_wired() -> void:
	Quests.reset()
	var q := {}
	for x in Quests.all():
		if str(x.id) == "isles_border_run":
			q = x
	assert_false(q.is_empty(), "the Derry to Donegal delivery exists")
	assert_eq(str(q.town), "derry")
	assert_eq(q.steps.map(func(s): return str(s.zone)), ["glenveagh", "donegal_town", "derry"])
	var settable := Quests.all_settable()
	for f in [q.start_flag, q.done_flag] + q.steps.map(func(s): return s.flag):
		assert_true(settable.has(str(f)), "%s is set somewhere" % f)
