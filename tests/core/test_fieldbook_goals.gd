extends TestCase
## Wildlore 1.5 Fieldbook goals: the zone digest, Rumours, Garside's milestones, region stamps and the Visitor's Book.

## A tiny world: Macc (town, cheshire) with two rooms (one upstairs), a forest route next door, the Peak over the
## hill with a moor and a cave, and far-off Scotland nobody has been near.
func _zones() -> Array:
	return [
		{"id": "macc", "name": "Macc", "kind": "town", "region": "cheshire", "town_id": "macc",
			"warps": [{"to": "macc_shop"}, {"to": "macc_house"}], "edges": {"east": {"to": "forest"}}, "encounters": {}},
		{"id": "macc_shop", "name": "Shop", "kind": "interior", "region": "", "warps": [{"to": "macc"}], "edges": {}, "encounters": {}},
		{"id": "macc_house", "name": "House", "kind": "interior", "region": "", "warps": [{"to": "macc"}, {"to": "macc_upstairs"}], "edges": {}, "encounters": {}},
		{"id": "macc_upstairs", "name": "Upstairs", "kind": "interior", "region": "", "warps": [{"to": "macc_house"}], "edges": {}, "encounters": {}},
		{"id": "forest", "name": "Macc Forest", "kind": "route", "region": "cheshire", "warps": [],
			"edges": {"west": {"to": "macc"}, "east": {"to": "moor"}},
			"encounters": {"grass": [{"species": "fox"}, {"species": "owl", "time": ["dusk", "night"]}]}},
		{"id": "moor", "name": "Goyt Valley", "kind": "route", "region": "peak", "warps": [{"to": "cave"}],
			"edges": {"west": {"to": "forest"}},
			"encounters": {"grass": [{"species": "hare", "weather": ["fog"], "time": ["dusk"]}, {"species": "owl"}],
				"water": [{"species": "trout", "time": ["night"]}]}},
		{"id": "cave", "name": "Bat Cave", "kind": "interior", "region": "", "warps": [{"to": "moor"}], "edges": {},
			"encounters": {"grass": [{"species": "bat"}]}},
		{"id": "glen", "name": "Glen", "kind": "route", "region": "scotland", "warps": [], "edges": {},
			"encounters": {"grass": [{"species": "deer"}]}},
		{"id": "lab", "name": "Dev", "kind": "route", "region": "dev", "warps": [], "edges": {}, "encounters": {"grass": [{"species": "glitch"}]}},
	]

func _map() -> Dictionary:
	return {"towns": {"macc": {"x": 10, "y": 10}}, "places": {"forest": {"x": 20, "y": 10}, "moor": {"x": 40, "y": 10}, "glen": {"x": 10, "y": 900}}}

func _idx() -> Dictionary:
	return ZoneIndex.build(_zones(), _map())

func _info() -> Dictionary:
	return {"fox": {"name": "Foxlet", "types": ["kin"], "base": {"hp": 40, "atk": 40}},
		"owl": {"name": "Owlet", "types": ["night"], "base": {"hp": 100, "atk": 100, "def": 100, "spd": 100, "lore": 100}},
		"hare": {"name": "Harelet", "types": ["gale"], "base": {"hp": 60, "atk": 60, "def": 60, "spd": 60, "lore": 60, "ward": 60}},
		"trout": {"name": "Troutle", "types": ["brook"], "base": {}}, "bat": {"name": "Echo", "types": ["night"], "base": {}},
		"deer": {"name": "Deerling", "types": ["hedgerow"], "base": {}}}

func _data(caught := [], seen := [], flags := {}) -> GameStateData:
	var d := GameStateData.new()
	for s in seen + caught:
		d.seen[s] = true
	for s in caught:
		d.caught[s] = true
	for k in flags:
		d.set_flag(k, flags[k])
	return d

# --- the zone digest ---------------------------------------------------------------------------------------

func test_index_regions_rooms_and_positions() -> void:
	var idx := _idx()
	assert_false(idx.zones.has("lab"), "the dev region is left out")
	assert_eq(idx.zones.cave.region, "peak", "a cave takes the region of the way in")
	assert_eq(idx.zones.macc_upstairs.region, "cheshire", "upstairs inherits through the house")
	assert_eq(idx.town_rooms.macc, ["macc_house", "macc_shop", "macc_upstairs"], "rooms reached through doors alone")
	assert_eq(idx.room_town.macc_upstairs, "macc")
	assert_false(idx.room_town.has("cave"), "a route's cave belongs to no town")
	assert_eq(idx.zones.cave.pos, Vector2(40, 10), "no map spot: borrows its neighbour's")
	assert_has(idx.adj.cheshire, "peak")
	assert_false(idx.adj.has("scotland"), "nothing joins Scotland in this world")
	assert_eq(idx.region_species.peak, ["hare", "owl", "trout", "bat"])

# --- Rumours ------------------------------------------------------------------------------------------------

func test_when_phrases() -> void:
	assert_eq(Rumours.when_phrase(["dusk"], ["fog"]), "in the fog at dusk")
	assert_eq(Rumours.when_phrase(["night"], []), "after dark")
	assert_eq(Rumours.when_phrase(["night", "dusk"], []), "from dusk till late", "order doesn't matter")
	assert_eq(Rumours.when_phrase([], ["drizzle", "downpour"]), "in the rain", "rain is said once")
	assert_eq(Rumours.when_phrase([], []), "")
	assert_eq(Rumours.when_phrase(["dawn", "day", "dusk", "night"], []), "", "all day is no limit")

func test_unseen_is_described_not_named() -> void:
	var info: Dictionary = _info().owl
	assert_eq(Rumours.describe(info, false), "something big and inky black")
	assert_eq(Rumours.describe(_info().fox, false), "something small and sandy brown")
	assert_eq(Rumours.describe(info, true), "an Owlet")
	for t in Rumours.TEMPLATES:
		var line := Rumours.text("owl", info, false, "Goyt Valley", "grass", ["dusk"], ["fog"])
		assert_false("Owlet" in line, "never named before it's seen")
	assert_true(Rumours.TEMPLATES.size() >= 25, "plenty of variety")

func test_every_template_fills_in() -> void:
	# force each template in turn through text() by checking the raw substitutions on all of them
	for t in Rumours.TEMPLATES:
		for seen in [false, true]:
			for when in [[["dusk"], ["fog"]], [[], []]]:
				var tpl: String = t[1]
				var line := tpl.replace("{Who}", "A birder").replace("{who}", "a birder").replace("{What_cap}", "X").replace("{what}", "x") \
					.replace("{where}", "in the grass").replace("{place}", "P").replace("{when_or}", " w").replace("{when}", " w").replace("{Thing}", "T")
				assert_false("{" in line or "}" in line, "unfilled placeholder in: " + tpl)
				assert_false("—" in tpl, "no em-dashes")
	var line := Rumours.text("hare", _info().hare, false, "Goyt Valley", "grass", ["dusk"], ["fog"])
	assert_true("Goyt Valley" in line, line)
	assert_true("in the fog at dusk" in line, line)
	assert_false("{" in line, line)
	assert_eq(line, Rumours.text("hare", _info().hare, false, "Goyt Valley", "grass", ["dusk"], ["fog"]), "the same gossip each time")

func test_rumours_in_reach_nearest_first() -> void:
	var idx := _idx()
	var d := _data(["fox"], ["owl"], {"visited_macc": true})
	var list := Rumours.build(d, idx, _info(), "macc")
	var ids := list.map(func(r): return r.species)
	assert_false("fox" in ids, "caught ones aren't gossiped about")
	assert_false("deer" in ids, "Scotland is out of reach")
	assert_has(ids, "hare", "the Peak is next door, so in reach")
	assert_eq(ids[0], "owl", "nearest first: the owl is in the forest next door")
	assert_eq(list[0].zone, "forest", "one rumour, at the nearest place")
	assert_true("Owlet" in list[0].text, "seen, so named")
	var bat: Dictionary = list.filter(func(r): return r.species == "bat")[0]
	assert_true("down in the dark" in bat.text or not "long grass" in bat.text, "caves aren't long grass")

func test_no_regions_visited_still_hears_about_here() -> void:
	var list := Rumours.build(_data(), _idx(), _info(), "glen")
	assert_eq(list.map(func(r): return r.species), ["deer"])

# --- milestones and stamps -----------------------------------------------------------------------------------

func _caught_n(n: int, flags := {}) -> GameStateData:
	var ids := []
	for i in n:
		ids.append("sp%d" % i)
	return _data(ids, [], flags)

func test_milestones_pending_and_next() -> void:
	assert_eq(FieldbookGoals.pending(_caught_n(10)), 0)
	assert_eq(FieldbookGoals.next_goal(_caught_n(10)), 25)
	assert_eq(FieldbookGoals.pending(_caught_n(25)), 25)
	assert_eq(FieldbookGoals.pending(_caught_n(60, {"fieldbook_25": true})), 50)
	assert_eq(FieldbookGoals.pending(_caught_n(60, {"fieldbook_25": true, "fieldbook_50": true})), 0)
	assert_eq(FieldbookGoals.next_goal(_caught_n(60)), 100)
	assert_eq(FieldbookGoals.pending(_caught_n(200, {"fieldbook_25": true, "fieldbook_50": true, "fieldbook_100": true,
		"fieldbook_150": true, "fieldbook_diploma_given": true})), 0, "the old diploma flag counts for 200")
	assert_eq(FieldbookGoals.next_goal(_caught_n(200)), 0)
	assert_true("Garside" in FieldbookGoals.hint(_caught_n(30)))
	assert_true("Catch 20 more" in FieldbookGoals.hint(_caught_n(30, {"fieldbook_25": true})), FieldbookGoals.hint(_caught_n(30, {"fieldbook_25": true})))

func test_where_next_mentions_the_milestone_after_the_story() -> void:
	var o := {"story": [{"flag_done": "starter", "text": "Go."}], "postgame": [{"text": "You've seen it all.", "town": ""}]}
	var d := _caught_n(30, {"game_complete": true})
	var got := MenuLogic.next_objective(d, 200, o)
	assert_true("Garside" in str(got.text), "a waiting reward comes first: " + str(got.text))
	assert_eq(got.town, "macclesfield")
	d.set_flag("fieldbook_25")
	got = MenuLogic.next_objective(d, 200, o)
	assert_true("Catch 20 more" in str(got.text), str(got.text))
	var story := MenuLogic.next_objective(_caught_n(30), 200, o)
	assert_eq(story.text, "Go.", "the story still leads before the end")

func test_region_stamps() -> void:
	var idx := _idx()
	var d := _data(["fox", "owl"])
	var prog := FieldbookGoals.region_progress(d, idx)
	assert_eq(prog.map(func(p): return p.region), ["cheshire", "peak", "scotland"], "REGION_NAMES order")
	assert_true(prog[0].complete, "Cheshire: fox and owl")
	assert_eq([prog[1].caught, prog[1].total], [1, 4])
	assert_eq(FieldbookGoals.complete_regions(d, idx), ["cheshire"])
	assert_eq(FieldbookGoals.untold_regions(d, idx), ["cheshire"])
	d.set_flag("region_news_cheshire")
	assert_eq(FieldbookGoals.untold_regions(d, idx), [])

func test_garside_milestone_conditions() -> void:
	var host := FakeHost.new()
	host.data = _caught_n(25)
	var c := Commands.new(host)
	assert_true(c._when("caught_25"))
	assert_false(c._when("caught_50"))
	for n in FieldbookGoals.MILESTONES:
		assert_has(StoryValidator.CONDITIONS, "caught_%d" % n)

class FakeHost:
	var data: GameStateData

# --- the Visitor's Book -------------------------------------------------------------------------------------

func test_rooms_counted_and_tourist_board_pays_once() -> void:
	var idx := _idx()
	var d := _data()
	d.money = 100
	assert_eq(VisitorsBook.count(d, "macc", idx), Vector2i(0, 3))
	assert_eq(VisitorsBook.note(d, "macc", "town", idx), {}, "towns aren't rooms")
	assert_eq(VisitorsBook.note(d, "macc_shop", "interior", idx), {})
	assert_eq(d.flag("seen_macc_shop"), true)
	assert_eq(VisitorsBook.note(d, "macc_house", "interior", idx), {})
	assert_eq(VisitorsBook.count(d, "macc", idx), Vector2i(2, 3))
	var pay := VisitorsBook.note(d, "macc_upstairs", "interior", idx)
	assert_eq(pay.town, "macc", "the last room pays out")
	assert_eq(d.money, 100 + VisitorsBook.MONEY)
	assert_eq(int(d.bag.get(VisitorsBook.FOOD, 0)), 1)
	assert_eq(VisitorsBook.note(d, "macc_upstairs", "interior", idx), {}, "already seen")
	d.flags.erase("seen_macc_shop")
	assert_eq(VisitorsBook.note(d, "macc_shop", "interior", idx), {}, "the tourist board only pays once")
	assert_eq(d.money, 100 + VisitorsBook.MONEY)
	assert_eq(VisitorsBook.note(d, "cave", "interior", idx), {}, "a cave on a route is a room, but no town's")
	assert_eq(VisitorsBook.rooms_seen(d), 4)
	assert_eq(VisitorsBook.towns_complete(d), 1)
	assert_true("Macc" in VisitorsBook.payout_lines("Macc", "Cream Tea", 500)[0])

func test_real_world_rooms() -> void:
	var idx := ZoneIndex.get_index()
	assert_true(idx.town_rooms.get("bath", []).size() >= 5, "Bath has rooms")
	assert_eq(idx.room_town.get("macc_fieldstation", ""), "macclesfield")
	for town in idx.town_rooms:
		for r in idx.town_rooms[town]:
			assert_eq(idx.zones[r].kind, "interior")
	var reach := Rumours.regions_in_reach(_data([], [], {"visited_macclesfield": true}), idx, "macclesfield")
	assert_has(reach, "cheshire")
	assert_has(reach, "peak", "the Peak is over the hill from Macc")
	var stats := TrainerStats.lines(_data())
	assert_true(stats.any(func(r): return r[0] == "Visitor's Book"), "a Stats row")

func test_weather_phrases_stay_short() -> void:
	assert_eq(Rumours.when_phrase([], ["fog", "drizzle"]), "in the rain or fog")
	assert_eq(Rumours.when_phrase(["day", "dusk"], ["clear", "sunshine", "gale"]), "on clear days or when the sun's out in the afternoons")
