extends TestCase
## Crossbreeds (core/crossbreeds.gd, data/taxa.json): closeness that mirrors real biology, authored hybrids first,
## everything derived from the parent pair (determinism), clean names across every pair, capped stats, fertility,
## the hatch and the save round trip.

func before_each() -> void:
	Genetics._hybrids = {}
	Crossbreeds.clear_cache()

func _mk(species_id: String, sex: String, uid := 0) -> Creature:
	var c := Fixtures.creature(species_id, 10)
	c.sex = sex
	c.uid = uid
	return c

func _data(steps := 0) -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 40
	d.rng_seed = 777
	d.money = 5000
	d.stats = TrainerStats.sanitise({"steps": steps})
	return d

func _fond(c: Creature) -> Creature:
	c.friendship = 150
	c.genome = Genetics.derive(c).genome
	return c

func test_the_data_and_every_cross_pass_the_validator() -> void:
	assert_eq(Crossbreeds.check(Fixtures.dex(), Fixtures.moves()), [])

func test_closeness_follows_the_real_animals() -> void:
	assert_eq(Crossbreeds.closeness("moolet", "coolet").tier, "species", "Dexter and Highland: one species")
	assert_eq(Crossbreeds.closeness("fawnlet", "sikawhistle").tier, "genus", "red and sika deer: Cervus")
	assert_eq(Crossbreeds.closeness("donkey", "connie").tier, "genus", "donkey and horse: Equus")
	assert_eq(Crossbreeds.closeness("kidgruff", "herdlet").tier, "family", "goat and sheep: on record, rarely")
	assert_eq(Crossbreeds.closeness("scuttlet", "leveret").tier, "", "rabbit and hare never")
	assert_true(str(Crossbreeds.closeness("scuttlet", "leveret").why).contains("48"))
	assert_eq(Crossbreeds.closeness("stoatlet", "martling").tier, "", "mustelids of different genera")
	assert_eq(Crossbreeds.closeness("moolet", "herdlet").tier, "", "cattle and sheep: same family, never on record")
	assert_eq(Crossbreeds.closeness("binfox", "moggle").tier, "", "different families")
	assert_eq(Crossbreeds.closeness("grizzlet", "kindlet").tier, "", "red and grey squirrels do not interbreed")
	assert_eq(Crossbreeds.closeness("bodminax", "moggle").tier, "", "a folklore line has no real animal to cross")

func test_fertility_is_like_the_real_thing() -> void:
	assert_true(Crossbreeds.fertile_tier("species", "Bos"))
	assert_true(Crossbreeds.fertile_tier("genus", "Felis"), "hybrid wildcats breed")
	assert_false(Crossbreeds.fertile_tier("genus", "Equus"), "mules don't")
	assert_false(Crossbreeds.fertile_tier("family", "Capra"))

func test_authored_hybrids_keep_precedence() -> void:
	assert_eq(Genetics.can_pair(_mk("donkey", "m", 1), _mk("connie", "f", 2)).hybrid, "mule")
	assert_eq(Genetics.can_pair(_mk("moggle", "m", 1), _mk("wildkit", "f", 2)).kind, "hybrid")
	for id in Crossbreeds.all_ids(Fixtures.dex()):
		var p := Crossbreeds.parse(id)
		assert_false(Crossbreeds.authored(p[0], p[1]), id)
	assert_false(Crossbreeds.all_ids(Fixtures.dex()).has("x_donkey_connie"))

func test_a_close_pair_with_no_authored_hybrid_makes_a_crossbreed() -> void:
	var r := Genetics.can_pair(_mk("moolet", "m", 1), _mk("coolet", "f", 2))
	assert_true(r.ok, str(r.why))
	assert_eq(r.kind, "crossbreed")
	assert_eq(r.crossbreed, "x_moolet_coolet")
	var far := Genetics.can_pair(_mk("scuttlet", "m", 1), _mk("leveret", "f", 2))
	assert_false(far.ok)
	assert_true(str(far.why).contains("hare"), "Dot explains the family rule")

func test_there_are_enough_crossbreeds_and_both_orders_differ() -> void:
	var ids := Crossbreeds.all_ids(Fixtures.dex())
	assert_true(ids.size() >= 8, str(ids))
	assert_has(ids, "x_moolet_coolet")
	assert_has(ids, "x_coolet_moolet")
	var a := Fixtures.dex().get_species("x_moolet_coolet")
	var b := Fixtures.dex().get_species("x_coolet_moolet")
	assert_true(a.name != b.name, "the sire's name leads, as a liger's does")

func test_ids_parse_and_unknown_ones_do_not_resolve() -> void:
	assert_eq(Crossbreeds.parse("x_moolet_coolet"), ["moolet", "coolet"])
	assert_eq(Crossbreeds.parse("x_nothing_here"), [])
	assert_eq(Crossbreeds.parse("moolet"), [])
	var dex := Dex.load_default()
	assert_false(dex.has("x_binfox_moggle"), "a cross that cannot happen has no species")
	assert_false(dex.has("x_nothing_here"))
	assert_false(dex.ids().has("x_moolet_coolet"))
	assert_true(dex.has("x_moolet_coolet"))
	assert_false(dex.ids().has("x_moolet_coolet"), "resolving never adds it to the Fieldbook order")

func test_everything_is_deterministic() -> void:
	var one := Crossbreeds.species("x_kidgruff_herdlet", Fixtures.dex()).duplicate(true)
	Crossbreeds.clear_cache()
	var two := Crossbreeds.species("x_kidgruff_herdlet", Dex.load_default())
	assert_eq(one, two)
	var r1: Dictionary = CrossbreedArt.recipe(one)
	var r2: Dictionary = CrossbreedArt.recipe(two)
	assert_eq(r1, r2)

func test_names_are_clean_for_every_pair_of_breeding_lines() -> void:
	var dex := Fixtures.dex()
	var lines := []
	for l in Genetics.genes().get("lines", {}):
		if dex.has(l) and Genetics.breeds(str(Genetics.genes().lines[l])):
			lines.append(str(l))
	var fallbacks := 0
	var n := 0
	for a in lines:
		for b in lines:
			if a == b:
				continue
			var name := Crossbreeds.name_for(a, b, dex)
			n += 1
			for bad in Crossbreeds.DENY:
				assert_false(Crossbreeds.fold(name).contains(bad), "%s x %s: %s" % [a, b, name])
			if name.contains("-"):
				fallbacks += 1
			else:
				assert_eq(Crossbreeds.name_fault(name, dex), "", "%s x %s: %s" % [a, b, name])
	assert_true(n > 10000, "every ordered pair of breeding lines: %d" % n)
	assert_true(fallbacks * 100 < n, "the rule set copes with nearly every pair (%d fallbacks)" % fallbacks)

func test_every_real_crossbreed_has_its_own_portmanteau() -> void:
	var seen := {}
	for id in Crossbreeds.all_ids(Fixtures.dex()):
		var name := str(Fixtures.dex().get_species(id).name)
		assert_false(name.contains("-"), "%s fell back to %s" % [id, name])
		assert_eq(Crossbreeds.name_fault(name, Fixtures.dex()), "", id)
		assert_false(seen.has(name), "%s repeats %s" % [id, name])
		seen[name] = true

func test_the_deny_list_bites() -> void:
	for bad in ["Twatling", "Bumble", "Shitake", "Arsenal", "Cockle"]:
		assert_true(Crossbreeds.name_fault(bad).begins_with("deny"), bad)
	assert_eq(Crossbreeds.name_fault("Dexlan"), "")
	assert_eq(Crossbreeds.name_fault("Xkrtpl"), "shape")

func test_stats_types_and_moves_are_capped_and_from_the_parents() -> void:
	var dex := Fixtures.dex()
	for id in Crossbreeds.all_ids(dex):
		var sp := dex.get_species(id)
		var p := Crossbreeds.parse(id)
		var s := Crossbreeds.final_stage(p[0], dex)
		var d := Crossbreeds.final_stage(p[1], dex)
		var tot := Crossbreeds._total(sp.base)
		assert_true(tot < maxi(Crossbreeds._total(s.base), Crossbreeds._total(d.base)), "%s %d" % [id, tot])
		assert_true(tot <= Crossbreeds.STORY_CAP, id)
		assert_true(sp.types.size() >= 1 and sp.types.size() <= 2, id)
		for t in sp.types:
			assert_true(t in s.types or t in d.types, "%s %s" % [id, t])
		assert_true(sp.learnset.size() <= Crossbreeds.MAX_MOVES, id)
		var from := {}
		for e in sp.learnset:
			assert_true(Fixtures.moves().has(str(e[1])), "%s %s" % [id, e[1]])
			for side in [s, d]:
				for f in side.learnset:
					if str(f[1]) == str(e[1]):
						from[side.id] = true
		assert_eq(from.size(), 2, "%s learns from both parents" % id)
		assert_eq(sp.evolves, null)
		assert_true(sp.dex.fact != "" and not str(sp.dex.fact).contains("—"), id)

func test_a_blend_never_lifts_a_weak_pair_above_its_better_parent() -> void:
	var b := Crossbreeds.blend_stats({"hp": 100, "atk": 100, "def": 100, "lore": 100, "ward": 100, "spd": 100},
		{"hp": 100, "atk": 100, "def": 100, "lore": 100, "ward": 100, "spd": 100}, "species")
	assert_true(Crossbreeds._total(b) < 600)
	assert_true(Crossbreeds._total(b) <= Crossbreeds.STORY_CAP)

func test_sterile_crossbreeds_cannot_pair_and_fertile_ones_breed_back() -> void:
	var dex := Fixtures.dex()
	var geep := _mk("kidgruff", "m", 7)
	geep.species = dex.get_species("x_kidgruff_herdlet")
	geep.hybrid = "x_kidgruff_herdlet"
	assert_true(Crossbreeds.sterile(geep))
	assert_true(str(Genetics.can_pair(geep, _mk("herdlet", "f", 8)).why).contains("can't have young"))
	var calf := _mk("moolet", "m", 9)
	calf.species = dex.get_species("x_moolet_coolet")
	calf.hybrid = "x_moolet_coolet"
	assert_false(Crossbreeds.sterile(calf))
	assert_eq(Genetics.kindred_of(calf), "beast")
	var r := Genetics.can_pair(calf, _mk("coolet", "f", 10))
	assert_true(r.ok, str(r.why))
	assert_eq(r.kind, "same_line")
	assert_eq(Breeding.offspring_species(calf, _mk("coolet", "f", 10), "same_line", dex).id, "coolet")

func test_a_crossbreed_hatches_and_goes_in_the_book() -> void:
	var d := _data()
	var sire := _fond(_mk("moolet", "m"))
	var dam := _fond(_mk("coolet", "f"))
	var r := Breeding.start(d, sire, dam, "guiting_farm", Fixtures.dex(), Fixtures.moves(), Rng.new(5), "spring")
	assert_true(r.ok, str(r.get("why", "")))
	assert_eq(r.kind, "crossbreed")
	d.stats = TrainerStats.sanitise({"steps": 99999})
	var before := FieldbookGoals.caught_count(d)
	var got := Breeding.collect(d, Fixtures.dex(), Fixtures.moves())
	assert_eq(got.size(), 1)
	var c: Creature = got[0].creature
	assert_eq(str(c.species.id), "x_moolet_coolet")
	assert_eq(c.hybrid, "x_moolet_coolet")
	assert_eq(c.level, Breeding.HYBRID_LEVEL)
	assert_eq(Crossbreeds.met(d), ["x_moolet_coolet"])
	assert_eq(FieldbookGoals.caught_count(d), before, "never counted in the Fieldbook proper")

func test_far_crosses_rarely_take_and_cost_the_day() -> void:
	var took := 0
	for i in 200:
		var d := _data()
		var sire := _fond(_mk("kidgruff", "m"))
		var dam := _fond(_mk("herdlet", "f"))
		var r := Breeding.start(d, sire, dam, "guiting_farm", Fixtures.dex(), Fixtures.moves(), Rng.new(1000 + i), "spring")
		if r.ok:
			took += 1
		else:
			assert_true(Breeding.paired_today(d, "guiting_farm"), "a cross that didn't take still uses the day")
			assert_eq(Breeding.baskets(d), [])
	assert_true(took >= 10 and took <= 60, "about 15 in 100 take: %d of 200" % took)

func test_a_crossbreed_survives_the_save_round_trip() -> void:
	var c := Creature.create(Fixtures.dex().get_species("x_herdlet_loaghtan"), 5, FixedRng.new(), Fixtures.moves())
	c.hybrid = "x_herdlet_loaghtan"
	c.sex = "f"
	c.genome = Genetics.derive(c).genome
	var d := c.to_dict()
	Crossbreeds.clear_cache()
	var back := Creature.from_dict(JSON.parse_string(JSON.stringify(d)), Dex.load_default())
	assert_eq(str(back.species.id), "x_herdlet_loaghtan")
	assert_eq(back.species.name, c.species.name)
	assert_eq(back.max_hp(), c.max_hp())
	assert_eq(back.calc_stat("atk"), c.calc_stat("atk"))
	assert_eq(back.hybrid, c.hybrid)
	assert_eq(back.genome, c.genome)

func test_the_art_is_blended_from_both_parents() -> void:
	CrossbreedArt.clear_cache()
	var sp := Fixtures.dex().get_species("x_moolet_coolet")
	var front := CrossbreedArt.texture(sp, "front")
	assert_true(front != null)
	assert_eq(front.get_width(), front.get_height() * 2, "two idle frames")
	assert_true(CrossbreedArt.texture(sp, "icon") != null)
	assert_eq(CreatureArt.texture(sp, false), front, "the battle art is the blend, not a placeholder")
	var r := CrossbreedArt.recipe(sp)
	assert_eq(str(r.id), "%s_x_%s" % [sp.crossbreed.sire_sprite, sp.crossbreed.dam_sprite])

func test_the_fieldbook_lesson_teaches_ligers_and_mules() -> void:
	assert_true(Crossbreeds.LESSON.contains("liger"))
	assert_true(Crossbreeds.LESSON.contains("63"))
	assert_false(Crossbreeds.LESSON.contains("—"))
	var line := Crossbreeds.parents_line(Fixtures.dex().get_species("x_moolet_coolet"))
	assert_true(line.contains("Dexter cattle") and line.contains("Highland cattle"), line)
