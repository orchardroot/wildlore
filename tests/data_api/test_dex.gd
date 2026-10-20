extends TestCase

var dex := Dex.load_default()

func test_nine_starter_species() -> void:
	for id in ["spikkin", "bramblehog", "thornsow", "holtling", "rillotter", "spatelord", "kindlet", "emberdrey", "pyredrey"]:
		assert_true(dex.has(id), id)

func test_species_numbers_are_ints() -> void:
	var sp := dex.get_species("kindlet")
	for s in Rules.STATS:
		assert_eq(typeof(sp.base[s]), TYPE_INT, s)
	assert_eq(typeof(sp.catch_rate), TYPE_INT)
	assert_eq(typeof(sp.learnset[0][0]), TYPE_INT)
	assert_eq(typeof(sp.evolves.level), TYPE_INT)

func test_evolution_chain() -> void:
	assert_eq(dex.get_species("spikkin").evolves.to, "bramblehog")
	assert_eq(dex.get_species("bramblehog").evolves.to, "thornsow")
	assert_eq(dex.get_species("thornsow").evolves, null)

func test_dual_type_final_stage() -> void:
	assert_eq(dex.get_species("pyredrey").types, ["hearth", "gale"])

func test_unknown_species_is_empty() -> void:
	assert_eq(dex.get_species("nope"), {})

func test_missing_stat_becomes_zero_for_the_validator_to_catch() -> void:
	var sp := Dex.normalise({"id": "x", "base": {"hp": 10}})
	assert_eq(sp.base.atk, 0)

func test_dex_follows_dex_order_file() -> void:
	var ids := Dex.load_default().ids()
	assert_eq(ids[0], "spikkin")
	assert_eq(ids[3], "holtling")
	assert_eq(ids[6], "kindlet")
	assert_eq(ids.size(), Dex.load_default().ids().size())

# --- 2.2: the autumn fungi live in a Fieldbook appendix, after the original 200

const FUNGI := ["flyling", "amanitar", "puffkin", "grandpuff", "whiffhorn", "scorchbun", "sulphurhen"]

func test_the_original_200_stay_the_fieldbook_proper() -> void:
	assert_eq(dex.core_ids().size(), 200, "the diploma and milestones count these")
	assert_eq(dex.appendix_ids().slice(0, FUNGI.size()), FUNGI, "the appendix, in dex order, fungi first")
	assert_eq(dex.ids().size(), 200 + dex.appendix_ids().size())
	assert_eq(dex.ids().slice(200, 200 + FUNGI.size()), FUNGI, "the appendix comes after the 200")
	for id in FUNGI:
		assert_true(Dex.in_appendix(id), id)
	assert_false(Dex.in_appendix("spikkin"))

func test_core_count_ignores_the_appendix() -> void:
	assert_eq(Dex.core_count({"spikkin": true, "flyling": true, "grandpuff": true}), 1)
	assert_eq(Dex.core_count({}), 0)

func test_fungi_turn_up_only_in_autumn() -> void:
	var where := {}
	for path in JsonUtil.list_json("res://data/zones"):
		var z = JsonUtil.read(path)
		if not z is Dictionary or not z.get("encounters") is Dictionary:
			continue
		for table in z.encounters:
			for e in z.encounters[table]:
				if str(e.get("species", "")) in FUNGI:
					assert_eq(e.get("season", []), ["autumn"], "%s in %s" % [e.species, z.id])
					where[e.species] = where.get(e.species, []) + [z.id]
	for id in FUNGI:
		assert_true(where.get(id, []).size() >= 3, "%s turns up in a few places: %s" % [id, where.get(id, [])])
		var hab: Array = dex.get_species(id).habitat.duplicate()
		var got: Array = where.get(id, []).duplicate()
		hab.sort()
		got.sort()
		assert_eq(hab, got, "%s: its Fieldbook habitat is where it's met" % id)
