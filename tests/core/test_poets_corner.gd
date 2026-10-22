extends TestCase
## Poets' Corner (4.5): the Gazetteer's second tally, of plaques tagged "theme": "arts", grouped by nation, with its
## own two milestones. Fixture zones use real ids so the nations come out right; the real data is checked at the end.

func _zones() -> Array:
	return [
		{"id": "sligo", "name": "Sligo", "kind": "town", "region": "ireland_west", "signs": [
			{"x": 1, "y": 1, "plaque": "t_yeats", "theme": "arts", "title": "W. B. Yeats", "text": "Poet."},
			{"x": 2, "y": 1, "plaque": "t_geese", "title": "Barnacle Geese", "text": "Birds."}]},
		{"id": "swansea", "name": "Swansea", "kind": "town", "region": "south_wales", "signs": [
			{"x": 1, "y": 1, "plaque": "t_dylan", "theme": "arts", "title": "Dylan Thomas", "text": "Poet."},
			{"x": 2, "y": 1, "plaque": "t_laugharne", "theme": "arts", "title": "The Boathouse", "text": "Shed."}]},
		{"id": "whitby", "name": "Whitby", "kind": "town", "region": "yorkshire", "signs": [
			{"x": 1, "y": 1, "plaque": "t_stoker", "theme": "arts", "title": "Bram Stoker", "text": "Fangs."}]},
	]

func _list() -> Array:
	return Gazetteer.build(_zones(), {"room_town": {}})

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_build_carries_the_theme_and_only_arts_plaques_count() -> void:
	var l := _list()
	assert_eq(str(l[0].theme), "arts")
	assert_eq(str(l[1].theme), "", "an ordinary plaque has no theme")
	assert_eq(PoetsCorner.all(l).map(func(p): return p.id), ["t_yeats", "t_dylan", "t_laugharne", "t_stoker"])
	assert_eq(PoetsCorner.total(l), 4)

func test_count_and_stats_line_follow_the_gazetteer_flags() -> void:
	var l := _list()
	var d := _data()
	assert_eq(PoetsCorner.stats_line(d, l), "None yet")
	Gazetteer.record(d, "t_geese", l)
	assert_eq(PoetsCorner.count(d, l), 0, "the geese are not poets")
	Gazetteer.record(d, "t_dylan", l)
	assert_eq(PoetsCorner.count(d, l), 1)
	assert_eq(PoetsCorner.stats_line(d, l), "1 of 4")

func test_by_nation_in_the_usual_order() -> void:
	var l := _list()
	var d := _data({"plaque_t_dylan": true, "plaque_t_laugharne": true})
	var g := PoetsCorner.by_nation(d, l)
	assert_eq(g.map(func(e): return e.nation), ["england", "wales", "ireland"])
	assert_eq(int(g[1].read), 2)
	assert_eq(int(g[1].total), 2)
	assert_eq(int(g[0].read), 0)
	assert_eq(str(g[2].name), "Ireland")

func test_milestones_pay_once_and_only_for_arts_plaques() -> void:
	var l := _list()
	var ms := [{"n": 2, "flag": "pc_two", "title": "Reader", "money": 0, "items": {"commonplace_book": 1}},
		{"n": -1, "flag": "pc_all", "title": "Laureate", "money": 100, "items": {}}]
	var d := _data()
	Gazetteer.record(d, "t_geese", l)
	assert_eq(PoetsCorner.record(d, "t_geese", l, ms), [], "not an arts plaque: nothing happens")
	Gazetteer.record(d, "t_yeats", l)
	assert_eq(PoetsCorner.record(d, "t_yeats", l, ms).size(), 0, "one read: no milestone yet")
	Gazetteer.record(d, "t_dylan", l)
	var paid := PoetsCorner.record(d, "t_dylan", l, ms)
	assert_eq(paid.size(), 1)
	assert_eq(str(paid[0].title), "Reader")
	assert_eq(int(d.bag.get("commonplace_book", 0)), 1)
	assert_eq(d.flag("pc_two"), true)
	assert_eq(PoetsCorner.record(d, "t_dylan", l, ms), [], "paid once")
	assert_eq(PoetsCorner.title(d, ms), "Reader")
	Gazetteer.record(d, "t_laugharne", l)
	PoetsCorner.record(d, "t_laugharne", l, ms)
	Gazetteer.record(d, "t_stoker", l)  # the Gazetteer pays its own milestones here; count only Poets' Corner's
	var money := d.money
	paid = PoetsCorner.record(d, "t_stoker", l, ms)
	assert_eq(paid.map(func(m): return m.title), ["Laureate"], "every arts plaque read pays the last one")
	assert_eq(d.money, money + 100)
	assert_true(PoetsCorner.next_milestone(d, l, ms).is_empty())

func test_old_save_catches_up_on_its_next_arts_plaque() -> void:
	var l := _list()
	var ms := [{"n": 2, "flag": "pc_two", "title": "Reader", "money": 0, "items": {}}]
	var d := _data({"plaque_t_yeats": true, "plaque_t_dylan": true, "plaque_t_stoker": true})  # read before 4.5
	Gazetteer.record(d, "t_laugharne", l)
	assert_eq(PoetsCorner.record(d, "t_laugharne", l, ms).map(func(m): return m.flag), ["pc_two"])

func test_ledger_rows_and_next_milestone() -> void:
	var l := _list()
	var d := _data()
	var rows := PoetsCorner.ledger(d, null, l)
	assert_eq(rows.size(), 4, "three nations and the next milestone")
	assert_eq(rows[0], ["England", "0 of 1 read"])
	assert_true(str(rows[3][1]).begins_with("Next: 10 read makes you a Bookworm"), str(rows[3]))
	var nm := PoetsCorner.next_milestone(d, l)
	assert_eq(int(nm.target), 10)

func test_the_almanac_page_sprouts_with_the_first_arts_plaque() -> void:
	var d := GameStateData.new()
	var ids := Almanac.pages(d).map(func(p): return p.id)
	assert_false(ids.has("poets"), "a fresh save has no Poets' Corner page yet")
	var real := PoetsCorner.all()
	assert_true(real.size() >= 100, "the game has plenty of plaques on the arts: %d" % real.size())
	Gazetteer.record(d, str(real[0].id))
	ids = Almanac.pages(d).map(func(p): return p.id)
	assert_true(ids.find("poets") == ids.find("gazetteer") + 1, "right after the Gazetteer: " + str(ids))
	assert_true(Almanac.blurb(d, "poets").begins_with("Plaques on the arts read: 1 of"))
	assert_true(Almanac.ledger(d, "poets").size() >= 2)

func test_every_nation_of_these_isles_has_arts_plaques() -> void:
	var nations := PoetsCorner.by_nation(GameStateData.new()).map(func(e): return e.nation)
	for n in ["england", "wales", "scotland", "northern_ireland", "ireland", "mann"]:
		assert_has(nations, n)

func test_milestone_items_exist() -> void:
	var items := ItemDB.load_default()
	for m in PoetsCorner.MILESTONES:
		for id in m.items:
			assert_true(items.has(str(id)), "milestone item %s" % id)
