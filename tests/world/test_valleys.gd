extends TestCase
## Wider Isles, R6: the South Wales valleys (the Rhondda, Merthyr Tydfil, Blaenavon), hung off Cardiff's north side.
## The join, the scaling, the quests' flags and flows, the plaques, the new creatures and the landmarks.

const ZONES := ["rhondda", "merthyr", "blaenavon"]
const TRAINERS := ["rhn_collier", "rhn_tenor", "rhn_prop", "mer_ironworker", "mer_chartist", "mer_angler", "mer_agent",
	"bla_cheese", "bla_rail", "bla_runner", "bla_legend"]
const NEW_SPECIES := ["cobblet", "seamknocker", "steamlet", "penydarren"]
const STYLES := ["winding_gear", "valley_terrace", "steam_loco", "ironworks"]

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

# ------------------------------------------------------------------ geography

func test_cardiff_opens_north_on_to_the_rhondda_and_nowhere_else_new() -> void:
	var c := ZoneData.load_id("cardiff")
	assert_eq(str(c.edges.north.to), "rhondda")
	assert_eq(str(c.edges.east.to), "severn_crossing", "the old edges are untouched")
	assert_eq(str(c.edges.west.to), "beacons")
	var r := ZoneData.load_id("rhondda")
	assert_eq(str(r.edges.south.to), "cardiff")
	assert_eq(str(r.edges.north.to), "merthyr")
	assert_eq(r.edges.size(), 2, "the Rhondda joins Cardiff and Merthyr only")
	var m := ZoneData.load_id("merthyr")
	assert_eq(str(m.edges.south.to), "rhondda")
	assert_eq(str(m.edges.east.to), "blaenavon")
	assert_eq(m.edges.size(), 2)
	var b := ZoneData.load_id("blaenavon")
	assert_eq(b.edges.keys(), ["west"], "Blaenavon is the end of the line")

func test_every_gap_lands_on_walkable_ground_and_comes_back() -> void:
	var c := ZoneData.load_id("cardiff")
	var r := ZoneData.load_id("rhondda")
	var m := ZoneData.load_id("merthyr")
	var b := ZoneData.load_id("blaenavon")
	for x in range(45, 48):
		var arr := c.edge_arrival("north", Vector2i(x, 0), r)
		assert_true(r.walkable(arr), "north off Cardiff at %d lands on the Rhondda's road" % x)
		assert_true(c.walkable(Vector2i(x, 0)), "the gap in Cardiff's wall is open at %d" % x)
		assert_eq(r.edge_arrival("south", arr, c), Vector2i(x, 0), "and the way back lines up")
	for x in range(29, 32):
		var arr2 := r.edge_arrival("north", Vector2i(x, 0), m)
		assert_true(m.walkable(arr2), "north off the Rhondda at %d lands in Merthyr" % x)
		assert_eq(m.edge_arrival("south", arr2, r), Vector2i(x, 0))
	for y in range(26, 29):
		var arr3 := m.edge_arrival("east", Vector2i(m.width - 1, y), b)
		assert_true(b.walkable(arr3), "east out of Merthyr at row %d lands in Blaenavon" % y)
		assert_eq(b.edge_arrival("west", arr3, m), Vector2i(m.width - 1, y))

func test_new_zones_are_scaled_from_cardiffs_band() -> void:
	for id in ZONES:
		var z := ZoneData.load_id(id)
		assert_eq(z.scaled_floor, 36, id + " is scaled from par 36")
		assert_eq(z.region, "south_wales")
	for t in TRAINERS:
		var d: Dictionary = _json("res://data/trainers/%s.json" % t)
		assert_eq(int(d.get("scaled_floor", -1)), 36, t + " is scaled")
	assert_eq((_json("res://data/trainers/bla_legend.json") as Dictionary).party.size(), 6, "the local legend has a full team")

func test_the_towns_are_proper_towns() -> void:
	for id in ["merthyr", "blaenavon"]:
		var z := ZoneData.load_id(id)
		assert_eq(z.town_id, id)
		var to := []
		for w in z.warps:
			to.append(str(w.to))
		assert_has(to, id + "_sanctuary")
		assert_has(to, id + "_shop")
		var places := 0
		for t in to:
			if t != id + "_sanctuary" and t != id + "_shop":
				places += 1
		assert_true(places >= 5, "%s has places to go in" % id)
	assert_true(ZoneData.load_id("merthyr").station != Vector2i(-1, -1), "Merthyr has a station")
	var map: Dictionary = _json("res://data/world_map.json")
	assert_true(map.towns.has("merthyr") and map.towns.has("blaenavon"), "both towns are on the map")
	assert_true(map.places.has("rhondda"), "the Rhondda is on the map")
	var dark := ZoneData.load_id("blaenavon_bigpit_below")
	assert_true(dark.dark, "Big Pit below is a dark zone")

func test_plaques_are_unique_plentiful_and_respectful() -> void:
	var seen := {}
	var count := {}
	var aberfan := 0
	for zid in ZONES + ["rhondda_heritage", "rhondda_institute", "rhondda_chapel", "rhondda_bakehouse", "merthyr_cyfarthfa", "merthyr_ynysfach",
			"merthyr_pub", "blaenavon_bigpit"]:
		count[zid] = 0
		for s in ZoneData.load_id(zid).signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
				assert_true(str(s.get("title", "")) != "")
				assert_false("—" in str(s.text), "no em-dashes")
				count[zid] += 1
				if "aberfan" in str(s.plaque) or "Aberfan" in str(s.text):
					aberfan += 1
	assert_eq(aberfan, 1, "exactly one Aberfan plaque, and it says nothing more than it should")
	assert_true(count.rhondda >= 3 + 1, "the route has its plaques")
	assert_true(count.merthyr >= 8, "8+ plaques in Merthyr")
	assert_true(count.blaenavon >= 8, "8+ plaques in Blaenavon")

func test_landmarks_and_zones_build() -> void:
	for style in STYLES:
		var out: Array = Meshes.building(7, 5, style, 4, 7, "south_wales")
		assert_true(out[0] is ArrayMesh and (out[0] as ArrayMesh).get_surface_count() > 0, style + " has a mesh")
	for id in ZONES:
		var root := ZoneBuilder.build(ZoneData.load_id(id))
		assert_true(root.get_child_count() > 0, id + " builds")
		root.free()

# ------------------------------------------------------------------ quests

func test_every_quest_flag_is_set_by_some_script() -> void:
	var text := ""
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if f.begins_with("rhondda") or f.begins_with("merthyr") or f.begins_with("blaenavon"):
			text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
	var quests: Array = (_json("res://data/quests/valleys.json") as Dictionary).quests
	assert_eq(quests.size(), 3)
	for q in quests:
		var flags: Array = [q.start_flag, q.done_flag]
		for s in q.steps:
			flags.append(s.flag)
		for fl in flags:
			assert_true(str(fl).begins_with("q_valleys_"), fl)
			assert_true(text.contains("\"%s\"" % fl), "%s is set in the dialogue" % fl)

func test_big_pit_descent() -> void:
	var h := FakeStoryHost.new()
	h.choices = [0]  # wrong answer at the lamp room: nothing handed over
	await _run(h, "blaenavon_bigpit", "bla_gwilym", "bla_gwilym")
	assert_eq(h.data.flag("q_valleys_pit_started"), true)
	assert_false(h.data.flag("q_valleys_pit_1") == true, "no lamp for the wrong answer")
	h.choices = [1]
	await _run(h, "blaenavon_bigpit", "bla_gwilym", "bla_gwilym")
	assert_eq(h.data.flag("q_valleys_pit_1"), true)
	assert_eq(Bag.new(h.data.bag).count("big_pit_lamp"), 1)
	h.choices = [0]  # go down
	await _run(h, "blaenavon_bigpit", "bla_gwilym", "bla_gwilym")
	assert_eq(h.warps.size(), 1, "down the cage")
	await _run(h, "blaenavon_bigpit_below", "pit_knock", "pit_knock")
	assert_true(h.last_battle.is_empty(), "nothing knocks back before Idris has spoken")
	await _run(h, "blaenavon_bigpit_below", "bla_idris", "bla_idris")
	assert_eq(h.data.flag("q_valleys_pit_2"), true)
	await _run(h, "blaenavon_bigpit_below", "pit_knock", "pit_knock")
	assert_eq(h.last_battle.foes[0].species.id, "cobblet")
	assert_false(h.data.flag("q_valleys_pit_3") == true, "beaten is not caught")
	h.battle_results = [{"result": "caught"}]
	await _run(h, "blaenavon_bigpit_below", "pit_knock", "pit_knock")
	assert_eq(h.data.flag("q_valleys_pit_caught"), true)
	assert_eq(h.data.flag("q_valleys_pit_3"), true)
	await _run(h, "blaenavon_bigpit", "bla_gwilym", "bla_gwilym")
	assert_eq(h.data.flag("q_valleys_pit_done"), true)
	assert_eq(Bag.new(h.data.bag).count("davy_lamp"), 1)

func test_choir_needs_four_voices() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "rhondda_chapel", "rhn_conductor", "rhn_conductor")
	assert_eq(h.data.flag("q_valleys_choir_started"), true)
	h.choices = [1]  # wrong: Greensleeves
	await _run(h, "rhondda_bakehouse", "rhn_baker", "rhn_baker")
	assert_false(h.data.flag("q_valleys_choir_1") == true)
	h.choices = [0]
	await _run(h, "rhondda_bakehouse", "rhn_baker", "rhn_baker")
	assert_eq(h.data.flag("q_valleys_choir_1"), true)
	h.choices = [0]
	await _run(h, "merthyr_pub", "mer_landlord", "mer_landlord")
	assert_eq(h.data.flag("q_valleys_choir_2"), true, "Joseph Parry wrote Myfanwy")
	h.choices = [2]
	await _run(h, "blaenavon_workmens", "bla_caretaker", "bla_caretaker")
	assert_eq(h.data.flag("q_valleys_choir_3"), true, "Hen Wlad Fy Nhadau")
	await _run(h, "rhondda_chapel", "rhn_conductor", "rhn_conductor")
	assert_false(h.data.flag("q_valleys_choir_done") == true, "three voices is not four")
	h.data.set_flag("q_valleys_pit_done", true)
	h.choices = [0]
	await _run(h, "blaenavon_bigpit", "bla_gwilym", "bla_gwilym")
	assert_eq(h.data.flag("q_valleys_choir_4"), true, "Calon Lan")
	await _run(h, "rhondda_chapel", "rhn_conductor", "rhn_conductor")
	assert_eq(h.data.flag("q_valleys_choir_done"), true)
	assert_eq(Bag.new(h.data.bag).count("eisteddfod_medal"), 1)

func test_trevithicks_wager() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "merthyr_ynysfach", "mer_ironguide", "mer_ironguide")
	assert_eq(h.data.flag("q_valleys_wager_started"), true)
	await _run(h, "rhondda_heritage", "rhn_heritage_guide", "rhn_heritage_guide")
	assert_eq(h.data.flag("q_valleys_wager_1"), true)
	assert_eq(Bag.new(h.data.bag).count("steam_coal"), 1)
	await _run(h, "merthyr_ynysfach", "mer_ironguide", "mer_ironguide")
	assert_false(h.data.flag("q_valleys_wager_2") == true, "coal alone won't fire a boiler")
	h.data.mark_caught("steamlet")
	await _run(h, "merthyr_ynysfach", "mer_ironguide", "mer_ironguide")
	assert_eq(h.data.flag("q_valleys_wager_2"), true)
	await _run(h, "merthyr", "mer_agent", "mer_agent")
	assert_eq(h.last_battle.opts.trainer.id, "mer_agent")
	assert_eq(h.data.flag("q_valleys_wager_3"), true)
	await _run(h, "merthyr_ynysfach", "mer_ironguide", "mer_ironguide")
	assert_eq(h.data.flag("q_valleys_wager_done"), true)
	assert_eq(Bag.new(h.data.bag).count("wager_guinea"), 1)

# ------------------------------------------------------------------ creatures and items

func test_new_creatures_are_appendix_lines_with_sprites_and_homes() -> void:
	var order: Array = _json("res://data/dex_order.json")
	var knacks: Dictionary = (_json("res://data/knacks.json") as Dictionary).species
	var placed := {}
	for id in ZONES:
		for kind in ZoneData.load_id(id).encounters:
			for e in ZoneData.load_id(id).encounters[kind]:
				placed[str(e.species)] = true
	var dex := Dex.load_default()
	for sp in NEW_SPECIES:
		assert_true(dex.has(sp), sp + " loads")
		assert_eq(dex.get_species(sp).get("appendix"), true, sp + " is in the appendix")
		assert_has(order, sp)
		assert_true(knacks.has(sp), sp + " has a knack")
		for side in ["front", "back", "icon"]:
			assert_true(ResourceLoader.exists("res://art/sprites/creatures/%s_%s.png" % [sp, side]), "%s %s sprite" % [sp, side])
		assert_true(placed.has(sp), sp + " lives in the valleys")
		var total := 0
		for v in dex.get_species(sp).base.values():
			total += int(v)
		assert_true(total >= 300 and total <= 500, "%s base total %d is in line with its stage" % [sp, total])
	assert_true(order.find("cobblet") > 199, "appended after the original 200")

func test_regional_items_are_sold_locally() -> void:
	var items := ItemDB.load_default()
	for id in ["cawl", "glamorgan_sausage", "blaenavon_cheddar", "davy_lamp", "wager_guinea", "eisteddfod_medal", "steam_coal", "big_pit_lamp", "penydarren_pig"]:
		assert_true(items.has(id), id)
	for shop in ["merthyr_market_stall", "blaenavon_cheese_stall", "rhondda_bakehouse"]:
		var d: Dictionary = _json("res://data/shops/%s.json" % shop)
		for id in d.stock:
			assert_true(items.has(str(id)), "%s stocks %s" % [shop, id])
	assert_has((_json("res://data/shops/blaenavon_cheese_stall.json") as Dictionary).stock, "blaenavon_cheddar")
