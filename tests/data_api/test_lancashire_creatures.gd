extends TestCase
## 3.0 Wider Isles: the Lancashire coast's regional lines (Fieldbook appendix): Weedjen > Greenteeth (Jenny
## Greenteeth), Bulbkin > Illuminade (the Blackpool Illuminations) and Ironwatch (Crosby's iron figures).

const LINES := {"weedjen": "greenteeth", "bulbkin": "illuminade"}
const IDS := ["weedjen", "greenteeth", "bulbkin", "illuminade", "ironwatch"]

var dex := Dex.load_default()

func test_species_load_with_types() -> void:
	assert_eq(dex.get_species("weedjen").types, ["bog"])
	assert_eq(dex.get_species("greenteeth").types, ["bog", "spirit"])
	assert_eq(dex.get_species("bulbkin").types, ["storm", "urban"])
	assert_eq(dex.get_species("illuminade").types, ["storm", "urban"])
	assert_eq(dex.get_species("ironwatch").types, ["iron", "spirit"])

func test_all_in_the_appendix_after_the_200() -> void:
	for id in IDS:
		assert_true(Dex.in_appendix(id), id)
		assert_true(dex.ids().find(id) >= 200, id + " comes after the original 200")
	assert_eq(dex.core_ids().size(), 200)

func test_evolutions() -> void:
	assert_eq(dex.get_species("weedjen").evolves.to, "greenteeth")
	assert_eq(int(dex.get_species("weedjen").evolves.level), 30)
	assert_eq(dex.get_species("bulbkin").evolves.to, "illuminade")
	assert_eq(int(dex.get_species("bulbkin").evolves.level), 28)
	for id in ["greenteeth", "illuminade", "ironwatch"]:
		assert_eq(dex.get_species(id).evolves, null, id)

func test_stat_totals_fit_their_stage() -> void:
	for id in IDS:
		var sp := dex.get_species(id)
		var total := 0
		for s in Rules.STATS:
			total += int(sp.base[s])
		if sp.evolves != null:
			assert_true(total >= 280 and total <= 330, "%s basic total %d" % [id, total])
		else:
			assert_true(total >= 470 and total <= 500, "%s final total %d" % [id, total])

func test_sprites_exist() -> void:
	for id in IDS:
		for which in ["front", "back", "icon"]:
			assert_true(ResourceLoader.exists("res://art/sprites/creatures/%s_%s.png" % [id, which]), "%s %s" % [id, which])

func test_learnsets_use_real_moves() -> void:
	var moves := MoveDB.load_default()
	for id in IDS:
		for row in dex.get_species(id).learnset:
			assert_false(moves.get_move(str(row[1])).is_empty(), "%s learns %s" % [id, row[1]])

func test_each_has_a_knack() -> void:
	for id in IDS:
		assert_true(Knacks.id_for_species(dex.get_species(id)) != "", id)

func test_placed_via_habitat() -> void:
	for id in ["weedjen", "bulbkin", "ironwatch"]:  # the evolved forms are only met by evolving
		assert_false(dex.get_species(id).get("habitat", []).is_empty(), id)
	assert_true("chat_moss" in dex.get_species("weedjen").habitat)
	assert_true("blackpool" in dex.get_species("bulbkin").habitat)
	assert_true("sefton_coast" in dex.get_species("ironwatch").habitat)

func test_weedjen_lurks_on_chat_moss() -> void:
	var z = JsonUtil.read("res://data/zones/chat_moss.json")
	var found := false
	for e in z.encounters.grass:
		found = found or str(e.species) == "weedjen"
	assert_true(found)
