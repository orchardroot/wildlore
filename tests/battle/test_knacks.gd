extends TestCase
## Knacks: one passive per evolution line (data/knacks.json, battle/knacks.gd), and each hook Battle calls.

const MF := preload("res://tests/battle/test_move_fx.gd")
const USE := {"type": "move", "slot": 0}
const FROST := [{"id": "t_frost", "name": "Frost Bite", "type": "frost", "category": "special", "power": 60, "accuracy": 100, "pp": 30, "effect": {"id": "none"}},
	{"id": "t_chill", "name": "Chill", "type": "frost", "category": "status", "power": 0, "accuracy": 100, "pp": 30, "effect": {"id": "status", "status": "chilled"}},
	{"id": "t_growl", "name": "Growl", "type": "kin", "category": "status", "power": 0, "accuracy": 100, "pp": 30, "effect": {"id": "stat", "stat": "atk", "stages": -1}},
	{"id": "t_big", "name": "Big Hit", "type": "kin", "category": "physical", "power": 250, "accuracy": 100, "pp": 30, "effect": {"id": "none"}}]

static func db() -> MoveDB:
	var d := MF.db()
	if not d.has("t_frost"):
		for m in FROST:
			d.add(MoveDB.normalise(m))
	return d

static func mon(id: String, knack: String, moves: Array, spd := 50, hp := 120, types := ["kin"]) -> Creature:
	db()
	return MF.mon(id, moves, spd, hp, types, {"knack": knack} if knack != "" else {})

func test_every_species_has_a_knack_and_lines_share_one() -> void:
	var dex := Fixtures.dex()
	assert_eq(Knacks.check(dex), [])
	var kinds := {}
	for sid in dex.ids():
		kinds[Knacks.id_for_species(dex.get_species(sid))] = true
	assert_true(kinds.size() >= 30, "at least 30 kinds of knack (%d)" % kinds.size())
	assert_eq(Knacks.id_for_species(dex.get_species("kindlet")), Knacks.id_for_species(dex.get_species("pyredrey")))
	assert_eq(Knacks.name_of("thick_fleece"), "Thick Fleece")
	assert_true(Knacks.desc_of("thick_fleece") != "")

func test_thick_fleece_keeps_the_frost_out() -> void:
	var b := MF.fight([mon("me", "", ["t_frost", "t_chill"], 90)], [mon("sheep", "thick_fleece", ["t_wait"], 10)])
	var ev := b.take_turn(USE, USE)
	var k := MF.first(ev, "knack")
	assert_eq(k.side, 1)
	assert_eq(k.knack, "thick_fleece")
	assert_true(MF.first(ev, "damage").is_empty())
	ev = b.take_turn({"type": "move", "slot": 1}, USE)
	assert_eq(MF.first(ev, "knack").knack, "thick_fleece")
	assert_eq(b.current(1).status, "")

func test_knack_text_reads_naturally() -> void:
	var b := MF.fight([mon("Bramblet", "", ["t_frost"], 90)], [mon("sheep", "thick_fleece", ["t_wait"], 10)])
	var ev := b.take_turn(USE, USE)
	var lines := EventPlayer.lines_for(MF.first(ev, "knack"), EventPlayer.make_ctx(b, {"name": "Keeper Maud"}))
	assert_eq(lines, ["Keeper Maud's Sheep's Thick Fleece kept the frost out!"])
	var mine := MF.fight([mon("bramblet", "thick_fleece", ["t_wait"], 10)], [mon("foe", "", ["t_frost"], 90)])
	ev = mine.take_turn(USE, USE)
	assert_eq(EventPlayer.lines_for(MF.first(ev, "knack"), EventPlayer.make_ctx(mine)), ["Bramblet's Thick Fleece kept the frost out!"])

func test_moaner_lowers_foe_attack_on_entry() -> void:
	var b := MF.fight([mon("me", "", ["t_wait"])], [mon("grump", "moaner", ["t_wait"])])
	assert_eq(MF.first(b.opening, "knack").knack, "moaner")
	assert_eq(MF.first(b.opening, "stat").side, 0)
	assert_eq(b.current(0).stages.atk, -1)

func test_stiff_upper_lip_stops_drops_and_flinches() -> void:
	var b := MF.fight([mon("me", "", ["t_growl", "t_bite"], 90)], [mon("lip", "stiff_upper_lip", ["t_hit"], 10, 250)])
	var ev := b.take_turn(USE, USE)
	assert_eq(MF.first(ev, "knack").side, 1)
	assert_eq(b.current(1).stages.atk, 0)
	ev = b.take_turn({"type": "move", "slot": 1}, USE)
	assert_true(MF.first(ev, "cant_act").is_empty())
	assert_eq(MF.all_of(ev, "move").size(), 2)
	var moaned := MF.fight([mon("lip", "stiff_upper_lip", ["t_wait"])], [mon("grump", "moaner", ["t_wait"])])
	assert_eq(moaned.current(0).stages.atk, 0, "a moan doesn't get to it either")

func test_puddle_jumper_is_quicker_in_the_rain() -> void:
	var dry := MF.fight([mon("frog", "puddle_jumper", ["t_hit"], 40, 250)], [mon("foe", "", ["t_hit"], 50, 250)])
	assert_eq(MF.first(dry.take_turn(USE, USE), "move").side, 1)
	var wet := MF.fight([mon("frog", "puddle_jumper", ["t_hit"], 40, 250)], [mon("foe", "", ["t_hit"], 50, 250)], {"weather": "downpour"})
	assert_eq(MF.first(wet.take_turn(USE, USE), "move").side, 0)

func test_early_riser_at_dawn() -> void:
	var b := MF.fight([mon("lark", "early_riser", ["t_wait"])], [mon("foe", "", ["t_wait"])], {"time": "dawn"})
	assert_eq(b.current(0).stages.spd, 1)
	var noon := MF.fight([mon("lark", "early_riser", ["t_wait"])], [mon("foe", "", ["t_wait"])], {"time": "day"})
	assert_eq(noon.current(0).stages.spd, 0)

func test_bog_standard_heals_in_a_downpour() -> void:
	var me := mon("bog", "bog_standard", ["t_wait"])
	var b := MF.fight([me], [mon("foe", "", ["t_wait"])], {"weather": "downpour"})
	me.hp = 10
	var ev := b.take_turn(USE, USE)
	var k := MF.first(ev, "knack")
	assert_eq(int(k.hp), 10 + me.max_hp() / 8)
	assert_eq(me.hp, 10 + me.max_hp() / 8)

func test_tough_as_old_boots_hangs_on_from_full() -> void:
	var me := mon("boots", "tough_old_boots", ["t_wait"], 10, 40)
	var b := MF.fight([me], [mon("foe", "", ["t_big"], 90)])
	var ev := b.take_turn(USE, USE)
	assert_eq(me.hp, 1)
	assert_eq(MF.first(ev, "knack").knack, "tough_old_boots")
	b.take_turn(USE, USE)
	assert_true(me.is_fainted(), "not from 1 HP")

func test_cocky_after_a_knockout() -> void:
	var me := mon("cock", "cocky", ["t_big"], 90)
	var b := MF.fight([me], [mon("foe", "", ["t_wait"], 10, 20), mon("foe2", "", ["t_wait"])])
	var ev := b.take_turn(USE, USE)
	assert_eq(MF.first(ev, "knack").knack, "cocky")
	assert_eq(me.stages.atk, 1)

func test_legend_calls_its_weather_on_entry() -> void:
	var b := MF.fight([mon("me", "", ["t_wait"])], [mon("nessie", "loch_mist", ["t_wait"])], {"weather": "clear"})
	assert_eq(b.weather, "fog")
	assert_eq(b.weather_turns, 5)
	assert_eq(MF.first(b.opening, "weather").weather, "fog")

func test_make_do_and_mend_heals_on_switching_out() -> void:
	var me := mon("mender", "make_do_and_mend", ["t_wait"])
	var b := MF.fight([me, mon("bench", "", ["t_wait"])], [mon("foe", "", ["t_wait"])])
	me.hp = 20
	var ev := b.take_turn({"type": "switch", "index": 1}, USE)
	assert_eq(ev[0].type, "knack")
	assert_eq(ev[0].name, "Mender")
	assert_eq(me.hp, 20 + me.max_hp() / 4)

func test_prickly_pricks_physical_attackers() -> void:
	var foe := mon("foe", "", ["t_hit"], 90, 200)
	var b := MF.fight([mon("hog", "prickly", ["t_wait"], 10, 250)], [foe])
	var ev := b.take_turn(USE, USE)
	var k := MF.first(ev, "knack")
	assert_eq(k.other_side, 1)
	assert_eq(foe.hp, foe.max_hp() - foe.max_hp() / 8)
	assert_eq(EventPlayer.lines_for(k, EventPlayer.make_ctx(b)), ["The rival Foe got pricked on Hog's spines!"])

func test_weather_eye_makes_weather_last_longer() -> void:
	var b := MF.fight([mon("eye", "weather_eye", ["t_rain"], 90)], [mon("foe", "", ["t_wait"], 10)])
	var ev := b.take_turn(USE, USE)
	assert_eq(int(MF.first(ev, "weather").turns), 8)

func test_knacks_can_be_switched_off() -> void:
	var b := MF.fight([mon("me", "", ["t_wait"])], [mon("grump", "moaner", ["t_wait"])], {"knacks": false})
	assert_true(b.opening.is_empty())
	assert_eq(b.current(0).stages.atk, 0)

func test_legend_knacks_are_their_own() -> void:
	var dex := Fixtures.dex()
	for sid in dex.ids():
		var sp := dex.get_species(sid)
		if bool(sp.get("legend", false)):
			assert_true(bool(Knacks.get_def(Knacks.id_for_species(sp)).get("legend", false)), "%s has a legend's knack" % sid)
