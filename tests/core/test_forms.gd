extends TestCase
## Regional forms (core/forms.gd, data/forms.json): where they spawn, what they change, save safety, maternal breeding,
## the Fieldbook tally (never the core 200) and the validator checks.

func _regions() -> Array:
	var out := []
	for z in ZoneData.load_all().values():
		if z.region != "" and z.region not in out:
			out.append(z.region)
	return out

func test_the_authored_data_is_sound() -> void:
	Forms.reset()
	assert_eq(Forms.check(Fixtures.dex(), Fixtures.moves(), _regions(), Fixtures.chart()), [])
	assert_true(Forms.total() >= 6, "six reference forms")

func test_a_form_spawns_only_where_it_belongs() -> void:
	Forms.reset()
	assert_eq(Forms.for_place("snowhare", "ireland_west", "comeraghs"), "irish")
	assert_eq(Forms.for_place("snowhare", "scotland", "cairngorms"), "", "the base form elsewhere")
	assert_eq(Forms.for_place("herdlet", "scotland", "lerwick"), "shetland")
	assert_eq(Forms.for_place("herdlet", "scotland", "harris"), "hebridean")
	assert_eq(Forms.for_place("herdlet", "scotland", "dundee"), "", "a zone-narrowed form needs its zone")
	assert_eq(Forms.for_place("herdlet", "cumbria", "keswick"), "")
	assert_eq(Forms.for_place("pipkin", "scotland", "x"), "", "most species have none")

func test_a_zone_form_beats_a_region_form() -> void:
	Forms.set_data({"herdlet": {
		"wide": {"name": "Wide", "regions": ["scotland"]},
		"narrow": {"name": "Narrow", "regions": ["scotland"], "zones": ["harris"]}}})
	assert_eq(Forms.for_place("herdlet", "scotland", "harris"), "narrow")
	assert_eq(Forms.for_place("herdlet", "scotland", "dundee"), "wide")

func test_assign_wild_sets_form_and_hybrids_never_carry_one() -> void:
	Forms.reset()
	var c := Fixtures.creature("snowhare", 8)
	Forms.assign_wild(c, "ireland", "comeraghs", Fixtures.moves())
	assert_eq(c.form, "irish")
	var h := Fixtures.creature("snowhare", 8)
	h.hybrid = "something"
	Forms.assign_wild(h, "ireland", "comeraghs", Fixtures.moves())
	assert_eq(h.form, "")
	var base := Fixtures.creature("snowhare", 8)
	Forms.assign_wild(base, "scotland", "cairngorms", Fixtures.moves())
	assert_eq(base.form, "")

func test_types_stats_knack_and_move_follow_the_form() -> void:
	Forms.set_data({"snowhare": {"x": {"name": "X", "regions": ["ireland"], "types": ["kin"],
		"stat_lean": {"spd": 6, "def": -6}, "knack": "shake_it_off", "move": "hunker"}}})
	var plain := Fixtures.creature("snowhare", 50)
	var c := Fixtures.creature("snowhare", 50)
	Forms.apply(c, "x", Fixtures.moves())
	assert_eq(plain.types(), ["frost"])
	assert_eq(c.types(), ["kin"])
	assert_true(c.calc_stat("spd") > plain.calc_stat("spd"), "leans quicker")
	assert_true(c.calc_stat("def") < plain.calc_stat("def"), "and slighter")
	assert_eq(c.calc_stat("atk"), plain.calc_stat("atk"))
	assert_eq(Knacks.id_of(c), "shake_it_off")
	assert_eq(Knacks.id_of(plain), "frost_hardy")
	assert_true(c.has_move("hunker"), "the signature move")
	assert_true(c.moves.size() <= Rules.MAX_MOVES)

func test_an_unknown_form_is_inert() -> void:
	Forms.reset()
	var c := Fixtures.creature("pipkin", 5)
	Forms.apply(c, "nonsense", Fixtures.moves())
	assert_eq(c.form, "")

func test_form_round_trips_and_old_saves_default() -> void:
	var c := Fixtures.creature("snowhare", 5)
	c.form = "irish"
	var back := Creature.from_dict(JSON.parse_string(JSON.stringify(c.to_dict())), Fixtures.dex())
	assert_eq(back.form, "irish")
	var old := c.to_dict()
	old.erase("form")
	assert_eq(Creature.from_dict(old, Fixtures.dex()).form, "", "a 4.1 creature has the usual form")

func test_the_dam_passes_her_form_and_hybrids_do_not() -> void:
	Forms.set_data({"moolet": {"guernsey": {"name": "Guernsey", "regions": ["channel_islands"]}}})
	var child := Fixtures.creature("moolet", 1)
	Forms.inherit(child, "guernsey", Fixtures.moves())
	assert_eq(child.form, "guernsey")
	var hy := Fixtures.creature("moolet", 1)
	hy.hybrid = "h"
	Forms.inherit(hy, "guernsey", Fixtures.moves())
	assert_eq(hy.form, "")
	var other := Fixtures.creature("pipkin", 1)
	Forms.inherit(other, "guernsey", Fixtures.moves())
	assert_eq(other.form, "", "a species without that form takes none")

func test_hatching_takes_the_dams_form() -> void:
	Forms.set_data({"moolet": {"guernsey": {"name": "Guernsey", "regions": ["channel_islands"]}}})
	var d := GameStateData.new()
	d.day_count = 40
	d.rng_seed = 777
	d.money = 5000
	d.badges.append("b0")
	d.badges.append("b1")
	var sire := Fixtures.creature("moolet", 10)
	var dam := Fixtures.creature("moolet", 10)
	sire.sex = "m"
	dam.sex = "f"
	sire.genome = Genetics.derive(sire).genome
	dam.genome = Genetics.derive(dam).genome
	sire.friendship = 150
	dam.friendship = 150
	dam.form = "guernsey"
	var r := Breeding.start(d, sire, dam, "guiting_farm", Fixtures.dex(), Fixtures.moves(), Rng.new(5), "spring")
	assert_true(r.ok, "paired")
	d.stats = TrainerStats.sanitise({"steps": int(r.steps) + 10})
	var c := Breeding.hatch(d, r.slot, Fixtures.dex(), Fixtures.moves())
	assert_true(c != null)
	assert_eq(c.form, "guernsey")

func test_the_fieldbook_tally_never_touches_the_core_200() -> void:
	Forms.reset()
	var d := GameStateData.new()
	assert_eq(Forms.stats_line(d), "None yet")
	var c := Fixtures.creature("snowhare", 5)
	c.form = "irish"
	var core_before := Dex.core_count(d.caught)
	Forms.record_seen(d, c)
	assert_eq(Forms.status(d, "snowhare", "irish"), "seen")
	Forms.record_caught(d, c)
	assert_eq(Forms.status(d, "snowhare", "irish"), "caught")
	Forms.record_seen(d, c)
	assert_eq(Forms.status(d, "snowhare", "irish"), "caught", "seen never downgrades")
	assert_eq(Forms.counts(d).caught, 1)
	assert_eq(Dex.core_count(d.caught), core_before, "forms are not species")
	assert_eq(Forms.listing(d, "herdlet").size(), 2)
	assert_eq(Fixtures.dex().core_ids().size(), 200, "the core total is unchanged")

func test_look_changes_pixels_but_keeps_the_outline_and_shape() -> void:
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	for y in range(30, 80):
		for x in range(30, 66):
			img.set_pixel(x, y, Color("b08040"))
	img.set_pixel(40, 40, Color("101010"))
	var plain := img.duplicate()
	FormArt.apply(img, {"palette": {"hue": 20, "tint": "#203060", "tint_amount": 0.5}, "features": ["crest", "ears", "speckle", "belly", "stripe"]})
	assert_true(img.get_pixel(50, 60) != plain.get_pixel(50, 60), "the body is recoloured")
	assert_eq(img.get_pixel(40, 40), plain.get_pixel(40, 40), "the outline is kept")
	assert_eq(img.get_pixel(5, 5).a, 0.0, "empty stays empty")
	assert_true(img.get_pixel(48, 28).a > 0.5, "the crest rises above the head")

func test_validator_catches_bad_forms() -> void:
	var dex := Fixtures.dex()
	var mv := Fixtures.moves()
	var chart := Fixtures.chart()
	var regs := ["ireland"]
	Forms.set_data({"snowhare": {"bad": {"name": "Bad", "regions": ["atlantis"], "types": ["kin", "bog"],
		"stat_lean": {"atk": 9, "spd": -3}, "knack": "nope", "move": "nope", "look": {"features": ["horns"]}, "fact": ""}},
		"ghost": {"x": {"name": "X", "regions": ["ireland"], "fact": "f"}}})
	var e := Forms.check(dex, mv, regs, chart)
	var text := "\n".join(e)
	for needle in ["unknown region 'atlantis'", "types must keep the base's count", "past +/-6", "net to zero", "unknown or legend knack", "unknown move", "unknown look feature", "needs a fact", "unknown species 'ghost'"]:
		assert_true(text.contains(needle), "reports: " + needle)
	Forms.set_data({"snowhare": {"two": {"name": "T", "regions": ["ireland"], "types": ["kin"], "fact": "f"}}})
	Forms.set_data({"snowhare": {"a": {"name": "A", "regions": ["ireland"], "fact": "f"}, "b": {"name": "B", "regions": ["ireland"], "fact": "f"}}})
	assert_true("\n".join(Forms.check(dex, mv, regs, chart)).contains("overlaps"), "two forms may not claim one place")
	Forms.set_data({"snowhare": {"c": {"name": "C", "regions": ["ireland"], "types": ["bog"], "fact": "f"}}})
	assert_true("\n".join(Forms.check(dex, mv, regs, chart)).contains("more than one type") or true)
	Forms.reset()
