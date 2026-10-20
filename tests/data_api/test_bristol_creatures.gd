extends TestCase
## 3.0 Wider Isles, Bristol: three regional lines in the Fieldbook appendix (Brunel's engineer, the
## Balloon Fiesta, the city's street art).

const IDS := ["gaugelet", "broadgauge", "wickerling", "montgolfire", "stencilette"]
const TYPES := {"gaugelet": ["iron"], "broadgauge": ["iron", "storm"], "wickerling": ["hearth"],
	"montgolfire": ["hearth", "gale"], "stencilette": ["urban", "spirit"]}

var dex := Dex.load_default()

func test_bristol_species_load_in_the_appendix() -> void:
	for id in IDS:
		assert_true(dex.has(id), id)
		assert_true(Dex.in_appendix(id), "%s is an appendix species" % id)
		assert_true(id in dex.appendix_ids(), id)
		assert_false(id in dex.core_ids(), "%s doesn't count towards the 200" % id)
		var sp := dex.get_species(id)
		assert_eq(Array(sp.types), TYPES[id], id)
		assert_true(str(sp.dex.text) != "" and str(sp.dex.fact) != "", "%s has dex text and a fact" % id)
		assert_false("—" in str(sp.dex.text) or "—" in str(sp.dex.fact), "%s: no em-dashes" % id)

func test_bristol_evolution_lines() -> void:
	assert_eq(dex.get_species("gaugelet").evolves.to, "broadgauge")
	assert_eq(int(dex.get_species("gaugelet").evolves.level), 32)
	assert_eq(dex.get_species("wickerling").evolves.to, "montgolfire")
	assert_eq(int(dex.get_species("wickerling").evolves.level), 30)
	assert_eq(dex.get_species("broadgauge").evolves, null)
	assert_eq(dex.get_species("montgolfire").evolves, null)
	assert_eq(dex.get_species("stencilette").evolves, null)

func test_bristol_stat_totals_are_viable() -> void:
	var bst := func(id: String) -> int:
		var b: Dictionary = dex.get_species(id).base
		var t := 0
		for s in Rules.STATS:
			t += int(b[s])
		return t
	for id in ["gaugelet", "wickerling"]:
		assert_true(bst.call(id) >= 280 and bst.call(id) <= 330, "%s basic: %d" % [id, bst.call(id)])
	for id in ["broadgauge", "montgolfire"]:  # two-stage finals sit at 470 to 490, like every other line
		assert_true(bst.call(id) >= 470 and bst.call(id) <= 490, "%s: %d" % [id, bst.call(id)])
	assert_true(bst.call("stencilette") >= 450 and bst.call("stencilette") <= 500, "stencilette: %d" % bst.call("stencilette"))

func test_bristol_moves_exist_and_knacks_are_set() -> void:
	var moves := MoveDB.load_default()
	for id in IDS:
		for entry in dex.get_species(id).learnset:
			assert_true(moves.has(str(entry[1])), "%s learns unknown move %s" % [id, entry[1]])
		assert_true(Knacks.id_for_species(dex.get_species(id)) != "", "%s has a knack" % id)

func test_bristol_sprites_exist() -> void:
	for id in IDS:
		for part in ["front", "back", "icon"]:
			var p := "res://art/sprites/creatures/%s_%s.png" % [id, part]
			assert_true(FileAccess.file_exists(p) or ResourceLoader.exists(p), p)
		assert_true(FileAccess.file_exists("res://art/recipes/creatures/%s.json" % id), "recipe for " + id)

func test_bristol_species_live_in_bristol() -> void:
	var placed := []
	for id in IDS:
		placed.append_array(dex.get_species(id).habitat)
	assert_has(placed, "bristol")
	assert_has(placed, "avon_gorge")
