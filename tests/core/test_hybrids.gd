extends TestCase
## Good Stock hybrids (data/hybrids.json, Dex loading, Genetics.hybrid_for/can_pair/check_hybrids): every entry is
## honest and capped, hybrids stay out of the Fieldbook proper, and the real pairs (and refusals) behave.

static var _dex: Dex

## A Dex with the real hybrids.json (test_genetics swaps fake hybrids in and out of the shared cache).
func dex() -> Dex:
	if _dex == null:
		Genetics._hybrids = {}
		_dex = Dex.load_default()
	return _dex

func _mk(species_id: String, sex: String, uid := 0) -> Creature:
	Genetics._hybrids = {}
	var c := Creature.create(dex().get_species(species_id), 10, FixedRng.new(), Fixtures.moves())
	c.sex = sex
	c.uid = uid
	return c

func test_hybrids_file_passes_its_checks() -> void:
	Genetics._hybrids = {}
	assert_eq(Genetics.check_hybrids(dex(), Fixtures.moves()), [])
	assert_eq(Genetics.check(dex()), [])

func test_every_entry_is_tagged_and_the_wildlife_ones_are_real() -> void:
	Genetics._hybrids = {}
	var hs := Genetics.hybrids()
	assert_true(hs.size() >= 10)
	for h in hs.values():
		assert_true(h.real in ["real", "folklore", "invented"], h.id)
	assert_eq(hs.mule.real, "real")
	assert_eq(hs.wildcat_hybrid.real, "real")
	assert_eq(hs.loch_foal.real, "folklore")
	assert_eq(hs.beast_kitten.real, "invented")

func test_dex_loads_hybrids_outside_the_fieldbook_proper() -> void:
	var dex := dex()
	var ids := dex.hybrid_ids()
	assert_eq(ids.size(), Genetics.hybrids().size())
	for id in ids:
		assert_true(dex.has(id), id)
		assert_false(dex.ids().has(id), "not in the dex order: " + id)
		assert_false(dex.core_ids().has(id))
		assert_false(Dex.in_appendix(id))
		assert_true(Dex.is_hybrid(id))
	assert_eq(Dex.core_count({"mule": true, "wildkit": true, "donkey": true}), 1, "hybrids and the appendix are not counted")
	var mule := dex.get_species("mule")
	assert_true(mule.hybrid)
	assert_eq(mule.line, "mule")
	assert_eq(Creature.create(dex().get_species("mule"), 20, FixedRng.new(), Fixtures.moves()).species.id, "mule")

func test_moggle_and_donkey_are_appendix_species_that_breed() -> void:
	var dex := dex()
	for id in ["moggle", "donkey"]:
		assert_true(Dex.in_appendix(id), id)
		assert_eq(Genetics.kindred_of(_mk(id, "m")), "beast")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % id))

func test_a_hybrid_never_beats_its_better_parent() -> void:
	var dex := dex()
	for h in Genetics.hybrids().values():
		var best := 0
		for sid in dex.ids():
			var sp := dex.get_species(sid)
			if sp.line in h.sire_lines or sp.line in h.dam_lines:
				best = maxi(best, Genetics._total(sp.base))
		assert_true(Genetics._total(h.base) < best, h.id)

func test_the_listed_pairs_pair_and_say_what_they_make() -> void:
	var r := Genetics.can_pair(_mk("moggle", "m", 1), _mk("wildkit", "f", 2))
	assert_true(r.ok)
	assert_eq(r.kind, "hybrid")
	assert_eq(r.hybrid, "wildcat_hybrid")
	assert_eq(Genetics.can_pair(_mk("donkey", "m", 1), _mk("connie", "f", 2)).hybrid, "mule")
	assert_eq(Genetics.can_pair(_mk("connie", "m", 1), _mk("donkey", "f", 2)).hybrid, "hinny")
	assert_near(float(Genetics.can_pair(_mk("orcalet", "m", 1), _mk("dolphlet", "f", 2)).odds), 0.2, 0.001)

func test_folklore_crosses_work_with_sexless_uncanny_parents() -> void:
	assert_true(Genetics.can_pair(_mk("kelpie", "", 1), _mk("connie", "f", 2)).ok, "the water-horse")
	assert_true(Genetics.can_pair(_mk("selklet", "", 1), _mk("pupplash", "f", 2)).ok, "the selkie")
	assert_false(Genetics.can_pair(_mk("grinalkin", "", 1), _mk("connie", "f", 2)).ok, "other spirits still do not")

func test_mules_hinnies_and_beast_kittens_cannot_have_young() -> void:
	for id in ["mule", "hinny", "beast_kitten", "puck_hare", "loch_foal"]:
		var m := _mk(id, "m", 5)
		m.hybrid = id
		var why: String = Genetics.can_pair(m, _mk("connie", "f", 6)).why
		assert_true(why.contains("can't have young"), id)

func test_a_fertile_hybrid_breeds_back_to_either_parent() -> void:
	var wc := _mk("wildkit", "m", 3)
	wc.species = dex().get_species("wildcat_hybrid")
	wc.hybrid = "wildcat_hybrid"
	var r := Genetics.can_pair(wc, _mk("wildkit", "f", 4))
	assert_true(r.ok)
	assert_eq(r.kind, "same_line")
	assert_true(Genetics.can_pair(wc, _mk("moggle", "f", 5)).ok)

func test_the_famous_refusals_stay_refused() -> void:
	assert_false(Genetics.can_pair(_mk("leveret", "m", 1), _mk("bunnet", "f", 2)).ok if dex().has("bunnet") else false)
	assert_false(Genetics.can_pair(_mk("wildkit", "m", 1), _mk("cooplet", "f", 2)).ok, "beast and fowl")
	assert_false(Genetics.can_pair(_mk("wildkit", "m", 1), _mk("stoatlet", "f", 2)).ok, "different mustelid or cat")

func test_text_is_clean() -> void:
	for h in Genetics.hybrids().values():
		for t in [h.name, h.dex.text, h.dex.fact]:
			assert_false(str(t).contains("—"), h.id)
