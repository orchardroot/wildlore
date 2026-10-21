extends TestCase
## Good Stock genetics kit (core/genetics.gd, data/genes.json): inheritance ratios over many seeded crosses, sex
## linkage, linkage, deterministic derivation for creatures that already exist, and old saves loading unchanged.

const N := 20000

func _beast(sex: String, genome := {}, uid := 0, pedigree := {}) -> Creature:
	return _mk("moolet", sex, genome, uid, pedigree)

func _mk(species_id: String, sex: String, genome := {}, uid := 0, pedigree := {}) -> Creature:
	var c := Fixtures.creature(species_id, 10)
	c.sex = sex
	c.uid = uid
	c.pedigree = pedigree
	c.genome = _full(genome)
	return c

## A plain wild-type genome with some loci overridden.
func _full(over: Dictionary) -> Dictionary:
	var g := {"coat": ["+", "+"], "tint": ["W", "W"], "mark": ["b", "b"], "knack": ["K", "K"], "ginger": ["o", "o"],
		"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"]}
	g.merge(over, true)
	return g

func _tally(sire: Creature, dam: Creature, locus: String, seed_value := 7) -> Dictionary:
	var rng := Rng.new(seed_value)
	var out := {}
	for i in N:
		var kit := Genetics.cross(sire, dam, rng)
		if kit.sport:
			continue  # ratios are for ordinary matings; sports are counted on their own
		var k := Genetics.hand_key(locus, kit.genome[locus])
		out[k] = out.get(k, 0) + 1
	return out

func _pct(n: int, total := N - 312) -> float:
	return 100.0 * n / total

func test_genes_file_matches_the_code_and_covers_every_line() -> void:
	assert_eq(Genetics.check(Fixtures.dex()), [])

func test_recessive_coat_is_a_quarter_from_two_carriers() -> void:
	var t := _tally(_beast("m", {"coat": ["+", "c"]}), _beast("f", {"coat": ["+", "c"]}), "coat")
	assert_near(_pct(t.get("cc", 0)), 25.0, 1.5)
	assert_near(_pct(t.get("+c", 0)), 50.0, 2.0)

func test_codominant_tint_is_one_two_one() -> void:
	var g := {"coat": ["c", "c"], "tint": ["W", "D"]}
	var t := _tally(_beast("m", g), _beast("f", g), "tint")
	assert_near(_pct(t.get("WW", 0)), 25.0, 2.0)
	assert_near(_pct(t.get("WD", 0)), 50.0, 2.0)
	assert_near(_pct(t.get("DD", 0)), 25.0, 2.0)

func test_incomplete_dominant_mark_shows_three_ways() -> void:
	var g := {"mark": ["B", "b"]}
	var t := _tally(_beast("m", g), _beast("f", g), "mark")
	assert_near(_pct(t.get("BB", 0)), 25.0, 2.0)
	assert_near(_pct(t.get("Bb", 0)), 50.0, 2.0)
	assert_near(_pct(t.get("bb", 0)), 25.0, 2.0)

func test_carrier_dam_gives_half_the_sons_ginger_and_no_daughters() -> void:
	var sire := _beast("m", {"ginger": ["o", "Y"]})
	var dam := _beast("f", {"ginger": ["O", "o"]})
	var rng := Rng.new(11)
	var sons := 0
	var ginger_sons := 0
	var ginger_daughters := 0
	for i in N:
		var kit := Genetics.cross(sire, dam, rng)
		if kit.sport:
			continue  # a sport can rewrite any allele
		var gh: Array = kit.genome.ginger
		if kit.sex == "m":
			sons += 1
			assert_eq(gh[1], "Y")
			if gh[0] == "O":
				ginger_sons += 1
		else:
			assert_eq(kit.sex, "f")
			if gh == ["O", "O"]:
				ginger_daughters += 1
	assert_near(_pct(ginger_sons, sons), 50.0, 2.0)
	assert_eq(ginger_daughters, 0)
	assert_near(_pct(sons), 50.0, 2.0)

func test_fowl_are_the_other_way_round() -> void:
	# ZW: a ginger hen over a plain cock gives carrier sons and plain daughters (Punnett's auto-sexing hens).
	var cock := _mk("cooplet", "m", {"ginger": ["o", "o"]})
	var hen := _mk("cooplet", "f", {"ginger": ["O", "W"]})
	assert_eq(Genetics.kindred_of(hen), "fowl")
	var rng := Rng.new(5)
	for i in 2000:
		var kit := Genetics.cross(cock, hen, rng)
		if kit.sport:
			continue
		if kit.sex == "m":
			assert_eq(kit.genome.ginger.count("O"), 1)
		else:
			assert_eq(kit.genome.ginger, ["o", "W"])

func test_ginger_shows_by_sex() -> void:
	var tom := _beast("m", {"ginger": ["O", "Y"]})
	var queen := _beast("f", {"ginger": ["O", "o"]})
	assert_true(Genetics.showing(tom).hue > 0.0)
	assert_false(Genetics.showing(tom).tortie)
	assert_true(Genetics.showing(queen).tortie)
	assert_eq(Genetics.showing(queen).hue, 0.0)

func test_mark_and_knack_are_linked_at_fifteen_percent() -> void:
	# coupling phase: copy 0 is B-k, copy 1 is b-K; B-K and b-k are recombinants
	var sire := _beast("m", {"mark": ["B", "b"], "knack": ["k", "K"]})
	var dam := _beast("f", {"mark": ["b", "b"], "knack": ["K", "K"]})
	var rng := Rng.new(3)
	var recombinant := 0
	for i in N:
		var g: Dictionary = Genetics.cross(sire, dam, rng).genome
		if (g.mark[0] == "B") != (g.knack[0] == "k"):
			recombinant += 1
	assert_near(_pct(recombinant), 15.0, 2.0)

func test_sports_are_one_in_sixty_four() -> void:
	var sire := _beast("m")
	var dam := _beast("f")
	var rng := Rng.new(99)
	var sports := 0
	for i in N:
		if Genetics.cross(sire, dam, rng).sport:
			sports += 1
	var expected := N / 64.0
	assert_true(absf(sports - expected) < expected * 0.2, "%d sports, expected about %d" % [sports, expected])

func test_a_sport_really_changes_an_allele() -> void:
	var sire := _beast("m")
	var dam := _beast("f")
	var rng := Rng.new(2)
	var seen := 0
	for i in 5000:
		var kit := Genetics.cross(sire, dam, rng)
		if kit.sport:
			seen += 1
			assert_true(Genetics.LOCI.has(kit.sport_locus))
	assert_true(seen > 0)

func test_young_inherit_inborn_values_with_selection_and_a_cap() -> void:
	var sire := _beast("m")
	var dam := _beast("f")
	for s in Rules.STATS:
		sire.ivs[s] = 14
		dam.ivs[s] = 8
	var rng := Rng.new(8)
	for i in 500:
		var kit := Genetics.cross(sire, dam, rng)
		for s in Rules.STATS:
			assert_true(kit.ivs[s] >= 0 and kit.ivs[s] <= Rules.IV_MAX)
			assert_true(kit.ivs[s] <= 14 + 2 + 1, "capped near the better parent")
	var total := 0
	for i in 500:
		total += Genetics.cross(sire, dam, rng).ivs.hp
	assert_true(total / 500.0 < 14.0, "regresses toward the mean")

func test_derive_is_deterministic_and_stable_across_evolution() -> void:
	var a := Fixtures.creature("kindlet", 5)
	var first := Genetics.derive(a)
	for i in 10:
		assert_eq(Genetics.derive(a), first)
	var evolved := Fixtures.creature("emberdrey", 30)
	evolved.nature = a.nature
	evolved.ivs = a.ivs.duplicate()
	assert_eq(Genetics.line_of(evolved), "kindlet")
	assert_eq(Genetics.derive(evolved), first)

func test_derive_respects_the_coat_it_already_wears() -> void:
	var c := Fixtures.creature("moolet", 5)
	c.variant = "winter"
	var g: Dictionary = Genetics.derive(c).genome
	assert_eq(g.coat, ["c", "c"])
	assert_eq(g.tint, ["W", "W"])
	c.genome = g
	assert_eq(Genetics.showing(c).variant, "winter")
	c.variant = "storm"
	assert_eq(Genetics.derive(c).genome.tint, ["D", "D"])

func test_derive_draws_wild_frequencies() -> void:
	var carriers := 0
	var knack := 0
	var total := 3000
	for i in total:
		var c := Fixtures.creature("moolet", 5)
		c.ivs["hp"] = i % 16
		c.ivs["atk"] = (i / 16) % 16
		c.ivs["def"] = (i / 256) % 16
		var g: Dictionary = Genetics.derive(c).genome
		if g.coat.has("c"):
			carriers += 1
		if g.knack.has("k"):
			knack += 1
		assert_true(g.knack.has("K"))
	assert_near(_pct(carriers, total), 12.5, 2.5)
	assert_near(_pct(knack, total), 10.0, 2.5)

func test_old_saves_load_unchanged_and_gain_a_stable_genome() -> void:
	var old := Fixtures.creature("moolet", 12).to_dict()
	for k in ["genome", "sex", "uid", "pedigree", "hybrid"]:
		old.erase(k)
	var dex := Fixtures.dex()
	var c := Creature.from_dict(old, dex)
	assert_eq(c.level, 12)
	assert_eq(c.species.id, "moolet")
	assert_false(c.genome.is_empty())
	assert_eq(c.sex in ["m", "f"], true)
	assert_eq(c.uid, 0)
	var saved := c.to_dict()
	var again := Creature.from_dict(saved, dex)
	assert_eq(again.genome, c.genome)
	assert_eq(again.sex, c.sex)
	assert_eq(Creature.from_dict(old, dex).genome, c.genome, "the same old save always gets the same genome")

func test_creatures_that_do_not_breed_get_no_sex() -> void:
	var c := Creature.from_dict(Fixtures.creature("grinalkin", 5).to_dict(), Fixtures.dex())
	assert_eq(c.sex, "")
	assert_false(c.genome.is_empty())

func test_the_fieldbook_count_is_unchanged() -> void:
	var dex := Fixtures.dex()
	assert_eq(dex.core_ids().size(), 200)

func test_kinship_follows_wright() -> void:
	var s := {"uid": 100}
	var d := {"uid": 200}
	var full1 := _beast("m", {}, 1, {"sire": s, "dam": d})
	var full2 := _beast("f", {}, 2, {"sire": s, "dam": d})
	var half := _beast("f", {}, 3, {"sire": s, "dam": {"uid": 300}})
	var stranger := _beast("f", {}, 4, {"sire": {"uid": 500}, "dam": {"uid": 600}})
	assert_eq(Genetics.kinship(full1, full2), 0.25)
	assert_eq(Genetics.kinship(full1, half), 0.125)
	assert_eq(Genetics.kinship(full1, stranger), 0.0)
	var parent := _beast("m", {}, 100)
	assert_eq(Genetics.kinship(parent, full1), 0.25)
	assert_eq(Genetics.kinship(_beast("m"), _beast("f")), 0.0, "unknown uids are unrelated")

func test_can_pair_rules() -> void:
	var s := {"uid": 100}
	var d := {"uid": 200}
	var brother := _beast("m", {}, 1, {"sire": s, "dam": d})
	var sister := _beast("f", {}, 2, {"sire": s, "dam": d})
	var father := _beast("m", {}, 100)
	assert_eq(Genetics.can_pair(brother, sister).ok, false)
	assert_eq(Genetics.can_pair(father, sister).ok, false)
	assert_true(Genetics.can_pair(father, sister).why.contains("Not on my farm"))
	var ok := Genetics.can_pair(_beast("m", {}, 7), _beast("f", {}, 8))
	assert_true(ok.ok)
	assert_eq(ok.kind, "same_line")
	assert_false(Genetics.can_pair(_beast("f"), _beast("m")).ok, "sire must be male")
	assert_false(Genetics.can_pair(_beast("m"), _mk("cooplet", "f")).ok, "a beast and a fowl")
	assert_false(Genetics.can_pair(_beast("m"), _mk("herdlet", "f")).ok, "two beast lines nobody listed")
	assert_false(Genetics.can_pair(_mk("grinalkin", "m"), _mk("grinalkin", "f")).ok, "spirits do not breed")

func test_mules_cannot_pair_but_fertile_hybrids_breed_back() -> void:
	Genetics._hybrids = {
		"mule": {"id": "mule", "sire_lines": ["herdlet"], "dam_lines": ["moolet"], "fertile": false},
		"liger": {"id": "liger", "sire_lines": ["herdlet"], "dam_lines": ["moolet"], "fertile": true},
	}
	var mule := _beast("m")
	mule.hybrid = "mule"
	assert_false(Genetics.can_pair(mule, _beast("f")).ok)
	var fertile := _beast("m")
	fertile.hybrid = "liger"
	assert_true(Genetics.can_pair(fertile, _beast("f")).ok)
	assert_eq(Genetics.can_pair(_mk("herdlet", "m"), _beast("f")).kind, "hybrid")
	Genetics._hybrids = {}

func test_punnett_with_unknowns_stays_inside_the_possible() -> void:
	var sire := _beast("m", {"coat": ["+", "c"]})
	var dam := _beast("f", {"coat": ["+", "c"]})
	var truth := Genetics.punnett(sire, dam, "coat")
	var hidden := Genetics.punnett(sire, dam, "coat", true)
	var sum_min := 0.0
	var sum_max := 0.0
	for e in hidden:
		sum_min += e.min
		sum_max += e.max
		var actual := 0.0
		for t in truth:
			if t.genotype == e.genotype:
				actual = t.p
		assert_true(actual >= e.min - 0.0001 and actual <= e.max + 0.0001, e.genotype)
	assert_true(sum_min <= 1.0 and sum_max >= 1.0)
	var cc: Dictionary = hidden.filter(func(e): return e.genotype == "cc")[0]
	assert_eq(cc.min, 0.0)
	assert_eq(cc.max, 0.25)

func test_punnett_known_square() -> void:
	var sq := Genetics.punnett(_beast("m", {"coat": ["+", "c"]}), _beast("f", {"coat": ["+", "c"]}), "coat")
	assert_eq(sq.size(), 3)
	assert_eq(sq[0].genotype, "++")
	assert_eq(sq[0].p, 0.25)
	assert_eq(sq[1].p, 0.5)

func test_showing_reads_the_genome() -> void:
	var c := _beast("m", {"coat": ["c", "c"], "tint": ["D", "W"], "mark": ["B", "B"], "knack": ["k", "k"],
		"frame1": ["+", "+"], "frame2": ["+", "+"], "frame3": ["+", "-"], "frame4": ["-", "-"]})
	var s := Genetics.showing(c)
	assert_eq(s.variant, "winter+storm")
	assert_eq(s.mark, 2)
	assert_eq(s.frame, 5)
	assert_eq(s.knack, "second")
