extends TestCase
## Wildlore 2.1: the seasons change what you meet (an optional "season" list on encounter entries), the Rumours
## tab says when, and the early roster maths (starters, two-stage finals, Holtling off the wild tables).

func _zone() -> ZoneData:
	return ZoneData.from_dict({"id": "s", "rows": [",,,", "...", "~~~"], "spawn": [1, 1], "encounters": {
		"grass": [
			{"species": "scuttlet", "weight": 30},
			{"species": "sphagnet", "weight": 10, "season": ["autumn"]},
			{"species": "buntling", "weight": 10, "season": ["autumn", "winter"], "time": ["day"]},
		]}})

# --- encounters ------------------------------------------------------------------------------------------

func test_season_filters_candidates() -> void:
	var ids := func(list: Array) -> Array: return list.map(func(e): return str(e.species))
	assert_eq(ids.call(Encounters.candidates(_zone(), "grass", "day", "clear", {}, "spring")), ["scuttlet"])
	assert_eq(ids.call(Encounters.candidates(_zone(), "grass", "day", "clear", {}, "autumn")), ["scuttlet", "sphagnet", "buntling"])
	assert_eq(ids.call(Encounters.candidates(_zone(), "grass", "night", "clear", {}, "winter")), ["scuttlet"], "time still applies")

func test_season_defaults_to_today() -> void:
	Calendar.set_override("10-18")
	assert_eq(Encounters.candidates(_zone(), "grass", "day", "clear").size(), 3, "October is autumn")
	Calendar.set_override("05-01")
	assert_eq(Encounters.candidates(_zone(), "grass", "day", "clear").size(), 1, "May is spring")
	Calendar.set_override("")

func test_validator_catches_bad_season() -> void:
	var z := ZoneData.from_dict({"id": "v", "rows": ["..."], "spawn": [1, 0], "encounters": {
		"grass": [{"species": "scuttlet", "season": ["autumn"]}, {"species": "pipkin", "season": ["autum"]},
			{"species": "hootlet", "season": "winter"}]}})
	var errs := z.validate({"v": z})
	assert_eq(errs.filter(func(e): return "season" in e).size(), 2, str(errs))

# --- rumours ---------------------------------------------------------------------------------------------

func test_rumour_when_says_the_season() -> void:
	assert_eq(Rumours.when_phrase([], [], ["autumn"]), "in autumn")
	assert_eq(Rumours.when_phrase(["dusk"], ["fog"], ["winter"]), "in the fog at dusk in winter")
	assert_eq(Rumours.when_phrase([], [], ["spring", "summer"]), "in spring and summer")
	assert_eq(Rumours.when_phrase([], [], ["winter", "autumn"]), "in autumn and winter", "season order")
	assert_eq(Rumours.when_phrase(["dusk"], [], ["spring", "summer", "autumn"]), "at dusk except in winter")
	assert_eq(Rumours.when_phrase([], [], ["spring", "summer", "autumn", "winter"]), "", "all year is no limit")
	assert_eq(Rumours.when_phrase(["night"], []), "after dark", "no season: as before")

func test_rumour_text_mentions_season_from_the_index() -> void:
	var idx := ZoneIndex.build([{"id": "wood", "name": "Wood", "kind": "route", "region": "cheshire", "warps": [], "edges": {},
		"encounters": {"grass": [{"species": "puffcap", "season": ["autumn"]}]}}], {"places": {"wood": {"x": 1, "y": 1}}})
	assert_eq(idx.zones.wood.enc[0].season, ["autumn"])
	var d := GameStateData.new()
	var out := Rumours.build(d, idx, {"puffcap": {"name": "Puffcap", "types": ["hedgerow"], "base": {}}}, "wood")
	assert_eq(out.size(), 1)
	assert_true("autumn" in str(out[0].text), str(out[0].text))

# --- the roster ------------------------------------------------------------------------------------------

func test_holtling_is_not_wild() -> void:
	var zones := ZoneData.load_all()
	for zid in zones:
		if zid == "testbed":
			continue
		for kind in zones[zid].encounters:
			for e in zones[zid].encounters[kind]:
				assert_false(str(e.species) == "holtling", "%s has a wild Holtling" % zid)
				if int(e.get("min", 0)) < 50:  # the odd old one turns up late in the game, which is fine
					assert_false(str(e.species) in ["kindlet", "spikkin"], "%s has a wild starter" % zid)

func test_starters_have_their_own_knacks_and_signatures() -> void:
	var dex := Fixtures.dex()
	var owners := {}
	for sid in dex.ids():
		var k := Knacks.id_for_species(dex.get_species(sid))
		if not owners.has(k):
			owners[k] = []
		owners[k].append(sid)
	for line in [["spikkin", "bramblehog", "thornsow"], ["holtling", "rillotter", "spatelord"], ["kindlet", "emberdrey", "pyredrey"]]:
		var k := Knacks.id_for_species(dex.get_species(line[0]))
		owners[k].sort()
		var want: Array = line.duplicate()
		want.sort()
		assert_eq(owners[k], want, "%s's knack is its line's alone" % line[0])
	var sig := {"spikkin": "protect", "holtling": "drain", "kindlet": "priority"}
	for s in sig:
		var at9 := (dex.get_species(s).learnset as Array).filter(func(l): return int(l[0]) == 9)
		assert_eq(at9.size(), 1, s + " learns one move at 9")
		var m := Fixtures.moves().get_move(str(at9[0][1]))
		match sig[s]:
			"protect":
				assert_eq(str(m.effect.id), "protect", s)
			"drain":
				assert_eq(str(m.effect.id), "drain", s)
			"priority":
				assert_true(int(m.priority) > 0 and str(m.type) == "hearth", s)

func test_two_stage_finals_and_three_stage_middles() -> void:
	var dex := Fixtures.dex()
	for sid in dex.ids():
		var sp := dex.get_species(sid)
		if sp.evolves == null or not (sp.evolves is Dictionary):
			continue
		var nxt := dex.get_species(str(sp.evolves.to))
		var total := func(s: Dictionary) -> int:
			var t := 0
			for k in s.base:
				t += int(s.base[k])
			return t
		assert_true(total.call(nxt) > total.call(sp), "%s grows into something stronger" % sid)
		# wave 45: the new appendix forms grow out of single-stage species that already sat at 434 to 496, so they run higher
		if Dex.in_appendix(str(nxt.id)) and nxt.evolves == null and total.call(nxt) <= 540 and total.call(nxt) > 490:
			continue
		if Dex.in_appendix(str(nxt.id)) and total.call(sp) >= 434 and total.call(nxt) <= 540 and nxt.evolves == null:
			continue
		if nxt.evolves == null:
			var three := false
			for o in dex.ids():
				var os := dex.get_species(o)
				if os.evolves is Dictionary and str(os.evolves.to) == sid:
					three = true
			if not three:
				assert_true(total.call(nxt) >= 470 and total.call(nxt) <= 490, "%s total %d" % [nxt.id, total.call(nxt)])
			elif total.call(sp) < 500:
				assert_true(total.call(sp) >= 425 and total.call(sp) <= 440, "%s total %d" % [sid, total.call(sp)])

func test_loading_never_leaves_hp_above_max() -> void:
	var c := Fixtures.creature("scuttlet", 10)
	var d := c.to_dict()
	d.hp = 999
	var back := Creature.from_dict(d, Fixtures.dex())
	assert_eq(back.hp, back.max_hp())

# --- dead items ------------------------------------------------------------------------------------------

func test_connemara_marble_brings_a_connie_on_early() -> void:
	var c := Fixtures.creature("connie", 12)
	assert_eq(Progression.evolution_target_with_item(c, "connemara_marble"), "connemarr", "an early item works at any level")
	assert_eq(Progression.evolution_target_with_item(c, "whitby_jet"), "")
	assert_eq(Progression.evolution_target(c), "", "and the levelled evolution still waits for its level")
	assert_eq(Progression.evolution_target_with_item(Fixtures.creature("volet", 12), "connemara_marble"), "")

func test_slate_shard_is_retired() -> void:
	assert_true(ItemDB.load_default().get_item("slate_shard").is_empty())
