extends TestCase
## 4.5 wave 45 session M, "Borders and neighbours": La Linea de la Concepcion across the frontier from Gibraltar (and
## the Playa de Levante), and Cyprus north from Dhekelia: Pyla in the buffer zone, then Nicosia both sides of the
## Green Line through the Ledra Street crossing.

const SPAIN := ["la_linea", "la_linea_levante"]
const CYPRUS := ["pyla", "nicosia_south", "nicosia_north"]
const NEW_SPECIES := ["chamelet", "chameleer", "agrino"]
const STYLES := ["andaluz_house", "andaluz_church", "frontier_post", "fort_ruin", "venetian_gate", "venetian_wall", "selimiye",
	"han", "kioski_house", "orthodox_church", "checkpoint_booth", "un_tower"]

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _run(h: FakeStoryHost, zone: String, script: String) -> void:
	StoryData.clear_cache()
	h.zone = zone
	await Commands.new(h, script).run(StoryData.script(zone, script))

# ------------------------------------------------------------------ geography

func test_the_frontier_and_the_road_north_are_walkable_cul_de_sacs() -> void:
	var g := ZoneData.load_id("gibraltar")
	var l := ZoneData.load_id("la_linea")
	assert_eq(str(g.edges.north.to), "la_linea")
	assert_eq(str(l.edges.south.to), "gibraltar")
	for x in [26, 27, 28]:
		assert_true(g.walkable(Vector2i(x, 0)), "Gibraltar's road north is open at %d" % x)
		assert_true(l.walkable(Vector2i(x, l.height - 1)), "La Linea's frontier gate is open at %d" % x)
	var lv := ZoneData.load_id("la_linea_levante")
	assert_eq(str(l.edges.east.to), "la_linea_levante")
	assert_eq(lv.edges.size(), 1, "the beach is a dead end")
	var d := ZoneData.load_id("dhekelia")
	var p := ZoneData.load_id("pyla")
	var s := ZoneData.load_id("nicosia_south")
	var n := ZoneData.load_id("nicosia_north")
	assert_eq(str(d.edges.north.to), "pyla")
	assert_eq(str(p.edges.south.to), "dhekelia")
	assert_eq(str(p.edges.north.to), "nicosia_south")
	assert_eq(str(s.edges.north.to), "nicosia_north")
	assert_eq(n.edges.size(), 1, "the north is the end of the road")
	for x in [30, 31, 32]:
		assert_true(d.walkable(Vector2i(x, 0)), "Dhekelia's lane north at %d" % x)
		var arrive := d.edge_arrival("north", Vector2i(x, 0), p)
		assert_true(p.walkable(arrive), "arriving in Pyla at %s" % arrive)
		assert_true(s.walkable(Vector2i(x, 0)) and n.walkable(Vector2i(x, n.height - 1)), "Ledra Street crossing at %d" % x)

func test_every_new_zone_is_scaled_with_wild_things() -> void:
	for zid in SPAIN + CYPRUS:
		var z := ZoneData.load_id(zid)
		assert_eq(z.scaled_floor, 95, zid)
		assert_true(z.region.begins_with("overseas_"), zid)
		var wild := 0
		for table in z.encounters.values():
			for e in table:
				wild += 1
				assert_true(int(e.min) >= 95 and int(e.max) <= 98, "%s %s" % [zid, e.species])
		assert_true(wild >= 8, "%s has wild things: %d" % [zid, wild])

func test_plaques_doors_and_trainers() -> void:
	var plaques := {}
	var doors := 0
	for zid in SPAIN + CYPRUS:
		var z := ZoneData.load_id(zid)
		doors += z.warps.size()
		for sg in z.signs:
			if str(sg.get("plaque", "")) != "":
				var id := str(sg.plaque)
				assert_false(plaques.has(id), "unique plaque " + id)
				plaques[id] = true
				assert_true(id.begins_with("la_linea_") or id.begins_with("cyprus_"), id)
				assert_true(str(sg.text).length() > 80 and not str(sg.text).contains("—"), id)
	assert_true(plaques.size() >= 30, "plaques: %d" % plaques.size())
	assert_true(doors >= 15, "doors: %d" % doors)
	var n := 0
	for f in DirAccess.get_files_at("res://data/trainers"):
		var id := str(f).get_basename()
		if id.begins_with("lal_") or id.begins_with("pyl_") or id.begins_with("ns_") or id.begins_with("nn_"):
			var t: Dictionary = _json("res://data/trainers/" + f)
			assert_eq(int(t.scaled_floor), 95, id)
			n += 1
	assert_true(n >= 12, "trainers: %d" % n)

# ------------------------------------------------------------------ money, clocks, words

func test_money_changes_at_the_frontier_and_the_green_line() -> void:
	assert_eq(Wallet.currency_for_zone("gibraltar"), "gip")
	assert_eq(Wallet.currency_for_zone("la_linea"), "eur")
	assert_eq(Wallet.currency_for_zone("la_linea_tapas"), "eur", "rooms take the street's money")
	assert_eq(Wallet.currency_for_zone("dhekelia"), "eur")
	assert_eq(Wallet.currency_for_zone("pyla"), "eur")
	assert_eq(Wallet.currency_for_zone("nicosia_south"), "eur")
	assert_eq(Wallet.currency_for_zone("nicosia_north"), "try")
	assert_eq(Wallet.currency_for_zone("nicosia_buyuk_han"), "try")
	var r := Forex.per_gbp("try", 7, 40)
	assert_true(r > 40.0 and r < 70.0, "lira per pound %f" % r)
	assert_true(Wallet.localise(100, "try") > 1000, "lira prices are big numbers")

func test_local_clocks_and_languages() -> void:
	assert_eq(Timezones.zone_for_region("overseas_la_linea"), "spain")
	assert_eq(Timezones.label("spain"), "Spain")
	assert_eq(Timezones.zone_for_region("overseas_cyprus"), "eet")
	assert_eq(Timezones.zone_for_region("overseas_north_cyprus"), "eet", "both halves of Nicosia keep one clock")
	var zi: Dictionary = ZoneIndex.get_index()
	assert_eq(Langs.code_for("la_linea", zi), "es")
	assert_eq(Langs.code_for("nicosia_south", zi), "el")
	assert_eq(Langs.code_for("nicosia_north", zi), "tr")
	assert_eq(Langs.code_for("pyla", zi), "", "Pyla is both, so neither")
	assert_eq(Standing.nation_for_zone("nicosia_north"), "overseas")

# ------------------------------------------------------------------ creatures and styles

func test_new_creatures_and_building_styles() -> void:
	var order: Array = _json("res://data/dex_order.json")
	for id in NEW_SPECIES:
		assert_true(id in order, id + " is in the dex order")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % id), id + " front sprite")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_back.png" % id), id + " back sprite")
	var line: Dictionary = _json("res://data/creatures/chamelet.json")
	assert_eq(str(line.species[0].evolves.to), "chameleer")
	for sp in line.species + _json("res://data/creatures/agrino.json").species:
		assert_true(bool(sp.appendix), sp.id)
	for st in STYLES:
		assert_true(st in Landmarks.SPECIAL and st in BordersStyles.STYLES, st)
		var m: Array = Meshes.building(6, 4, st, 3, 1)
		assert_true(not m.is_empty(), st + " builds")

# ------------------------------------------------------------------ quests

func test_lunch_at_the_frontier() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "la_linea", "lal_carmen")
	assert_eq(h.data.flag("q_overseas_la_linea_1"), true)
	await _run(h, "la_linea_tapas", "lal_pilar")
	assert_eq(h.data.flag("q_overseas_la_linea_2"), true)
	await _run(h, "la_linea", "lal_carmen")
	assert_false(h.data.flag("q_overseas_la_linea_done") == true, "the van driver first")
	h.data.set_flag("trainer_lal_driver")
	await _run(h, "la_linea", "lal_carmen")
	assert_eq(h.data.flag("q_overseas_la_linea_done"), true)
	assert_true(int(h.data.bag.get("tortillitas_camarones", 0)) >= 3)

func test_halloumi_or_hellim() -> void:
	var h := FakeStoryHost.new()
	var q := "q_overseas_cyprus_"
	await _run(h, "pyla", "pyl_un")
	assert_eq(h.data.flag(q + "started"), true)
	await _run(h, "nicosia_south", "ns_cheese")
	assert_false(h.data.flag(q + "3") == true, "taste both first")
	await _run(h, "pyla_kafeneio", "pyl_andreas")
	await _run(h, "pyla_kahvehane", "pyl_huseyin")
	assert_eq(h.data.flag(q + "1"), true)
	assert_eq(h.data.flag(q + "2"), true)
	await _run(h, "nicosia_south", "ns_cheese")
	assert_eq(h.data.flag(q + "3"), true)
	await _run(h, "nicosia_buyuk_han", "nn_cheese")
	assert_false(h.data.flag(q + "4") == true, "the critic first")
	h.data.set_flag("trainer_nn_critic")
	await _run(h, "nicosia_buyuk_han", "nn_cheese")
	assert_eq(h.data.flag(q + "4"), true)
	await _run(h, "pyla", "pyl_un")
	assert_eq(h.data.flag(q + "done"), true)
	assert_true(int(h.data.bag.get("sheftali_kebab", 0)) >= 2)

func test_every_quest_flag_is_set_somewhere() -> void:
	var text := ""
	for z in SPAIN + CYPRUS + ["la_linea_tapas", "pyla_kafeneio", "pyla_kahvehane", "nicosia_buyuk_han", "nicosia_taverna"]:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % z)
	for f in ["overseas_la_linea", "overseas_cyprus"]:
		for q in _json("res://data/quests/%s.json" % f).quests:
			var flags: Array = [q.start_flag, q.done_flag]
			for st in q.steps:
				flags.append(st.flag)
			for fl in flags:
				assert_true(text.contains("\"%s\"" % fl), "%s is set by a script" % fl)
