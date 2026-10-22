extends TestCase
## Wave 45 L, these isles abroad: Y Wladfa (Gaiman), Cape Breton (Baddeck), Boston, Appalachia (Bristol, Tennessee)
## and Brittany (Roscoff). Each is a compact town reached through the overseas registry, with the nation "abroad",
## its own money, its own clock, a language hook where one is spoken, plaques, trainers, a quest and local creatures.

const PLACES := {
	"patagonia": {"zone": "gaiman", "region": "abroad_patagonia", "cur": "ars", "tz": "argentina", "lang": "cy", "floor": 95, "unlock": "champion"},
	"cape_breton": {"zone": "baddeck", "region": "abroad_cape_breton", "cur": "cad", "tz": "atlantic", "lang": "gd", "floor": 95, "unlock": "champion"},
	"boston": {"zone": "boston", "region": "abroad_boston", "cur": "usd", "tz": "us_eastern", "lang": "", "floor": 95, "unlock": "champion"},
	"appalachia": {"zone": "bristol_tn", "region": "abroad_appalachia", "cur": "usd", "tz": "us_eastern", "lang": "", "floor": 95, "unlock": "champion"},
	"brittany": {"zone": "roscoff", "region": "abroad_brittany", "cur": "eur", "tz": "france", "lang": "br", "floor": 43, "unlock": "badge_storm"},
}
const SPECIES := ["choiquet", "choique", "mooslet", "bullmoose", "hellbendlet", "hellbender", "ankou"]
const QUESTS := ["abroad_gaiman_tea", "abroad_baddeck_frolic", "abroad_boston_letter", "abroad_bristol_tune", "abroad_roscoff_johnny"]

func _at(zone: String, y: int, m: int, d: int, uk_hhmm: String) -> String:
	return GameClock.text(Timezones.to_zone(GameClock.parse(uk_hhmm), zone, y, m, d))

func test_registry_entries_land_on_walkable_ground() -> void:
	var all := ZoneData.load_all()
	for id in PLACES:
		var p: Dictionary = PLACES[id]
		var e := Overseas.get_entry(id)
		assert_false(e.is_empty(), id + " is in the registry")
		assert_eq(str(e.arrival.zone), p.zone)
		assert_eq(str(e.unlock_flag), p.unlock)
		var z: ZoneData = all[p.zone]
		assert_true(z.walkable(Vector2i(int(e.arrival.x), int(e.arrival.y))), id + " arrival tile is walkable")
		assert_true(Timezones.flight_minutes(id) > 0, id + " has a journey time")
	assert_true(Overseas.is_ferry(Overseas.get_entry("brittany")))
	assert_eq(str(Overseas.get_entry("brittany").port), "plymouth")

func test_towns_are_scaled_valid_and_furnished() -> void:
	var all := ZoneData.load_all()
	for id in PLACES:
		var p: Dictionary = PLACES[id]
		var z: ZoneData = all[p.zone]
		assert_eq(z.region, p.region)
		assert_eq(z.kind, "town")
		assert_eq(z.scaled_floor, int(p.floor), p.zone + " scaled")
		assert_eq(z.edges.size(), 0, p.zone + " is reached by air or sea only")
		for err in z.validate(all):
			assert_true(false, str(err))
		for kind in z.encounters:
			for enc in z.encounters[kind]:
				assert_true(int(enc.min) >= int(p.floor), "%s %s at the floor" % [p.zone, enc.species])
		var rooms := []
		for w in z.warps:
			rooms.append(str(w.to))
		assert_has(rooms, p.zone + "_sanctuary")
		assert_has(rooms, p.zone + "_shop")
		assert_true(rooms.size() >= 4, "%s has %d rooms" % [p.zone, rooms.size()])
		for rid in rooms:
			assert_eq(all[rid].kind, "interior", rid)
			for err in all[rid].validate(all):
				assert_true(false, str(err))

func test_plaques_are_plentiful_and_prefixed() -> void:
	var all := ZoneData.load_all()
	for id in PLACES:
		var z: ZoneData = all[PLACES[id].zone]
		var n := 0
		for s in z.signs:
			if s.has("plaque"):
				n += 1
				assert_true(str(s.plaque).begins_with("abroad_"), str(s.plaque))
				assert_false(str(s.text).contains("—"), str(s.plaque) + " has no em-dash")
		assert_true(n >= 8, "%s has %d plaques" % [z.id, n])

func test_nation_money_clock_and_language() -> void:
	var index: Dictionary = ZoneIndex.get_index()
	for id in PLACES:
		var p: Dictionary = PLACES[id]
		assert_eq(Standing.nation_for_zone(p.zone), "abroad", p.zone)
		assert_eq(Standing.nation_for_zone(p.zone + "_sanctuary"), "abroad", p.zone + " rooms")
		assert_eq(Wallet.currency_for_zone(p.zone), p.cur, p.zone)
		assert_eq(Wallet.currency_for_zone(p.zone + "_shop"), p.cur, p.zone + " shop")
		assert_eq(Timezones.zone_for_region(p.region), p.tz)
		assert_eq(Langs.code_for(p.zone, index), p.lang, p.zone)
	assert_true(Standing.is_nation("abroad"))
	assert_eq(Standing.name_of("abroad"), "Kin Abroad")
	assert_eq(Wallet.symbol("ars"), "AR$")
	assert_eq(Wallet.symbol("cad"), "C$")
	for cur in ["ars", "cad"]:
		var r := Forex.per_gbp(cur, 7, 40)
		var w: Dictionary = Forex.WALKS[cur]
		assert_true(r >= float(w.low) and r <= float(w.high), cur + " rate in range")

func test_local_clocks() -> void:
	# UK noon in January (GMT) and July (BST)
	assert_eq(_at("argentina", 2026, 1, 15, "12:00"), "09:00", "Argentina is UTC-3 all year")
	assert_eq(_at("argentina", 2026, 7, 15, "12:00"), "08:00")
	assert_eq(_at("atlantic", 2026, 1, 15, "12:00"), "08:00", "AST in winter")
	assert_eq(_at("atlantic", 2026, 7, 15, "12:00"), "08:00", "ADT in summer")
	assert_eq(_at("us_eastern", 2026, 1, 15, "12:00"), "07:00", "EST")
	assert_eq(_at("us_eastern", 2026, 7, 15, "12:00"), "07:00", "EDT")
	assert_eq(_at("france", 2026, 7, 15, "12:00"), "13:00", "CEST")
	assert_eq(_at("us_eastern", 2026, 3, 15, "12:00"), "08:00", "the US has sprung forward before the UK")

func test_no_bonfire_night_abroad() -> void:
	assert_false(Calendar.festival_here("bonfire_night", "abroad_boston"))
	assert_true(Calendar.festival_here("halloween", "abroad_boston"))
	assert_true(Calendar.festival_here("bonfire_night", "cheshire"))

func test_the_brittany_ferry_runs_both_ways() -> void:
	var there := Travel.ferry_arrival("plymouth_roscoff", "plymouth")
	assert_eq(str(there.zone), "roscoff")
	var back := Travel.ferry_arrival("plymouth_roscoff", "roscoff")
	assert_eq(str(back.zone), "plymouth")
	var hand: Array = JsonUtil.read("res://data/dialogue/plymouth.json")["ply_brittany_ferry"]
	assert_true(JSON.stringify(hand).contains("badge_storm"), "the Plymouth ferry hand waits for the Storm badge")

func test_new_creatures_are_appendix_placed_and_drawn() -> void:
	var dex := Dex.load_default()
	var order: Array = JsonUtil.read("res://data/dex_order.json")
	for id in SPECIES:
		assert_true(dex.has(id), id)
		var sp: Dictionary = dex.get_species(id)
		assert_true(bool(sp.get("appendix", false)), id + " is in the appendix")
		assert_has(order, id)
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % id), id + " front sprite")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_back.png" % id), id + " back sprite")
		assert_false(sp.get("habitat", []).is_empty(), id + " lives somewhere")

func test_quest_flags_are_all_set_somewhere() -> void:
	var text := ""
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if f.ends_with(".json"):
			text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
	for qid in QUESTS:
		var file = JsonUtil.read("res://data/quests/%s.json" % qid)
		assert_true(file is Dictionary, qid)
		var q: Dictionary = file.quests[0]
		var flags := [str(q.start_flag), str(q.done_flag)]
		for s in q.steps:
			flags.append(str(s.flag))
		for fl in flags:
			assert_true(fl.begins_with("q_abroad_"), fl)
			assert_true(text.contains('"%s"' % fl), fl + " is set by some dialogue")
