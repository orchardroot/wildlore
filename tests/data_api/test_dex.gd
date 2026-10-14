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
