extends TestCase
## South Pennines / West Yorkshire appendix lines: Tootlet > Bombardon (brass bands), Hobling > Hobthrust
## (Pennine hob lore) and Forcelet > Rhubarbarian (the Rhubarb Triangle).

const LINES := [
	{"id": "tootlet", "types": ["iron"], "to": "bombardon", "knack": "brass_neck"},
	{"id": "bombardon", "types": ["iron", "storm"], "to": null, "knack": "brass_neck"},
	{"id": "hobling", "types": ["spirit"], "to": "hobthrust", "knack": "we_are_flitting"},
	{"id": "hobthrust", "types": ["spirit", "bog"], "to": null, "knack": "we_are_flitting"},
	{"id": "forcelet", "types": ["hearth", "hedgerow"], "to": "rhubarbarian", "knack": "forced_in_the_dark"},
	{"id": "rhubarbarian", "types": ["hearth", "hedgerow"], "to": null, "knack": "forced_in_the_dark"},
]

var dex := Dex.load_default()

func test_species_load_with_their_types_in_the_appendix() -> void:
	for l in LINES:
		assert_true(dex.has(l.id), l.id)
		var sp := dex.get_species(l.id)
		assert_eq(sp.types, l.types, l.id)
		assert_true(sp.get("appendix", false) == true, "%s is in the appendix" % l.id)
		assert_true(Dex.in_appendix(l.id), l.id)
		assert_false(l.id in dex.core_ids(), "%s doesn't count towards the 200" % l.id)
		assert_true(str(sp.dex.text) != "" and str(sp.dex.fact) != "", "%s has text and a fact" % l.id)
		assert_false(str(sp.dex.text).contains("—") or str(sp.dex.fact).contains("—"), "no em-dashes: " + l.id)
		assert_eq(str(sp.get("sprite", "")), l.id)
		assert_true(sp.get("habitat") is Array, l.id)

func test_evolutions_chain() -> void:
	for l in LINES:
		var evo = dex.get_species(l.id).evolves
		if l.to == null:
			assert_eq(evo, null, l.id)
		else:
			assert_eq(str(evo.to), l.to, l.id)
			assert_true(int(evo.level) >= 26 and int(evo.level) <= 34, "%s evolves at %d" % [l.id, evo.level])
	assert_eq(int(dex.get_species("tootlet").evolves.level), 30)
	assert_eq(int(dex.get_species("hobling").evolves.level), 32)
	assert_eq(int(dex.get_species("forcelet").evolves.level), 28)

func test_stat_totals_are_viable() -> void:
	for l in LINES:
		var t := 0
		var sp := dex.get_species(l.id)
		for k in sp.base:
			t += int(sp.base[k])
		if l.to == null:
			assert_true(t >= 470 and t <= 490, "%s final total %d" % [l.id, t])
		else:
			assert_true(t >= 300 and t <= 330, "%s basic total %d" % [l.id, t])

func test_every_learnset_move_exists() -> void:
	var moves := MoveDB.load_default()
	for l in LINES:
		var ls: Array = dex.get_species(l.id).learnset
		assert_true(ls.size() >= 10, "%s has a real movepool" % l.id)
		for entry in ls:
			assert_true(moves.has(str(entry[1])), "%s learns unknown move %s" % [l.id, entry[1]])

func test_sprites_exist() -> void:
	for l in LINES:
		for which in ["front", "back", "icon"]:
			var p := "res://art/sprites/creatures/%s_%s.png" % [l.id, which]
			assert_true(FileAccess.file_exists(p), p)
		assert_true(FileAccess.file_exists("res://art/recipes/creatures/%s.json" % l.id), l.id + " recipe")

func test_ids_are_in_dex_order() -> void:
	var order: Array = JsonUtil.read("res://data/dex_order.json")
	for l in LINES:
		assert_true(l.id in order, l.id)
	assert_true(order.find("tootlet") > order.find("sulphurhen"), "after the fungi")

func test_knacks_map_the_lines() -> void:
	assert_eq(Knacks.check(dex).filter(func(e): return LINES.any(func(l): return str(e).contains(l.id))), [])
	for l in LINES:
		assert_eq(Knacks.id_for_species(dex.get_species(l.id)), l.knack, l.id)
		assert_true(Knacks.name_of(l.knack) != "", l.knack)
