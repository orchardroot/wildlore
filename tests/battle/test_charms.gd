extends TestCase
## Charms (held items): the data, every effect in the battle engine, giving and taking, old saves.

const CONTRACT := ["hag_stone", "horseshoe", "four_leaf_clover", "brigid_cross", "leek", "rowan_sprig",
	"selkie_pearl", "miners_lamp", "thistle_brooch", "shamrock_pin", "oak_acorn", "lucky_chip"]
const SLOT0 := {"type": "move", "slot": 0}

func _mk(types: Array, level := 50, move_ids := ["scrap"]) -> Creature:
	var c := Creature.create(Fixtures.species("t_" + "_".join(types), types), level, FixedRng.new(), Fixtures.moves())
	c.moves.clear()
	for id in move_ids:
		c.moves.append(c.make_move_slot(id, Fixtures.moves()))
	return c

func _dmg(att: Creature, def: Creature, move_id: String) -> int:
	return DamageCalc.compute(att, def, Fixtures.moves().get_move(move_id), Fixtures.chart(), "clear", FixedRng.new(), 0.0).damage

func _of(events: Array, type: String) -> Array:
	return events.filter(func(e): return e.type == type)

# --- data ----------------------------------------------------------------------

func test_contract_ids_are_charms_with_real_types() -> void:
	var items := ItemDB.load_default()
	var types: Array = JsonUtil.read("res://data/types.json").types
	for id in CONTRACT:
		var it := items.get_item(id)
		assert_eq(str(it.get("kind", "")), "charm", id)
		assert_true(str(it.get("effect_text", "")) != "", "%s says what it does" % id)
		var fx: Dictionary = it.get("charm", {})
		assert_has(Charms.EFFECTS, str(fx.get("effect", "")), id)
		if fx.has("type"):
			assert_has(types, str(fx.type), id)
	assert_eq(Charms.table().size(), CONTRACT.size())

func test_charms_have_no_em_dashes() -> void:
	for id in Charms.table():
		var it: Dictionary = Charms.item(id)
		for k in ["name", "desc", "effect_text", "msg"]:
			assert_false("—" in str(it.get(k, "")), "%s.%s" % [id, k])

func test_shops_sell_three_basic_charms_at_sensible_prices() -> void:
	var items := ItemDB.load_default()
	var sold := {}
	for sid in items.shops:
		for id in items.shops[sid].stock:
			if Charms.is_charm(str(id)):
				sold[id] = int(sold.get(id, 0)) + 1
	assert_eq(sold.keys().size(), 3)
	for id in ["oak_acorn", "hag_stone", "rowan_sprig"]:
		assert_true(int(sold.get(id, 0)) >= 2, "%s in a few shops" % id)
		var p := int(items.get_item(id).price)
		assert_true(p >= 2500 and p <= 5000, "%s costs %d" % [id, p])

# --- damage charms -------------------------------------------------------------

func test_hag_stone_softens_spirit_hits_only() -> void:
	var att := _mk(["kin"], 60)
	var def := _mk(["brawn"], 60)
	var plain := _dmg(att, def, "poltergeist")
	var plain_kin := _dmg(att, def, "scrap")
	def.held = "hag_stone"
	assert_near(_dmg(att, def, "poltergeist"), plain * 0.75, 1.0)
	assert_eq(_dmg(att, def, "scrap"), plain_kin)

func test_rowan_sprig_softens_night_hits() -> void:
	var att := _mk(["kin"], 60)
	var def := _mk(["kin"], 60)
	var plain := _dmg(att, def, "moonlit_pounce")
	def.held = "rowan_sprig"
	assert_near(_dmg(att, def, "moonlit_pounce"), plain * 0.75, 1.0)

func test_type_boosters() -> void:
	var def := _mk(["kin"], 60)
	for pair in [["leek", "thorn_volley"], ["selkie_pearl", "spate_surge"], ["miners_lamp", "millstone_drop"]]:
		var att := _mk(["brawn"], 60)
		var plain := _dmg(att, def, pair[1])
		att.held = pair[0]
		assert_near(_dmg(att, def, pair[1]), plain * 1.2, 1.0, pair[0])
		assert_eq(_dmg(att, def, "scrap"), _dmg(_mk(["brawn"], 60), def, "scrap"), "%s: other types untouched" % pair[0])

func test_resist_and_boost_say_so_in_battle() -> void:
	var me := _mk(["kin"], 30, ["bramble_lash", "shadow_nip"])
	me.held = "leek"
	var foe := _mk(["kin"], 30, ["glare"])
	foe.held = "rowan_sprig"
	var b := Fixtures.battle([me], [foe])
	var ev := b.take_turn(SLOT0, SLOT0)
	ev.append_array(b.take_turn({"type": "move", "slot": 1}, SLOT0))
	var items := _of(ev, "charm").map(func(e): return e.item)
	assert_has(items, "leek")
	assert_has(items, "rowan_sprig")
	var ctx := EventPlayer.make_ctx(b)
	var lines := []
	for e in _of(ev, "charm"):
		lines.append_array(EventPlayer.lines_for(e, ctx))
	assert_has(lines, "The wild T Kin's Rowan Sprig kept the dark at bay!")

# --- horseshoe -----------------------------------------------------------------

func test_horseshoe_survives_one_knockout_a_battle() -> void:
	var me := _mk(["kin"], 5, ["glare"])
	me.held = "horseshoe"
	me.friendship = 0  # no friendship help muddling the test
	var foe := _mk(["kin"], 60, ["scrap"])
	var b := Fixtures.battle([me, _mk(["kin"], 5)], [foe])
	var ev := b.take_turn(SLOT0, SLOT0)
	assert_eq(me.hp, 1)
	assert_eq(_of(ev, "charm")[0].item, "horseshoe")
	assert_eq(_of(ev, "faint").size(), 0)
	b.take_turn(SLOT0, SLOT0)
	assert_true(me.is_fainted(), "only once a battle")

func test_horseshoe_needs_more_than_one_hp() -> void:
	var me := _mk(["kin"], 5, ["glare"])
	me.held = "horseshoe"
	me.hp = 1
	var b := Fixtures.battle([me, _mk(["kin"], 5)], [_mk(["kin"], 60, ["scrap"])])
	b.take_turn(SLOT0, SLOT0)
	assert_true(me.is_fainted())

func test_wild_horseshoe_works_too() -> void:
	var foe := _mk(["kin"], 5, ["glare"])
	foe.held = "horseshoe"
	var b := Fixtures.battle([_mk(["kin"], 60, ["scrap"])], [foe])
	b.take_turn(SLOT0, SLOT0)
	assert_eq(foe.hp, 1)

# --- four-leaf clover ----------------------------------------------------------

func test_clover_on_the_lead_helps_snares() -> void:
	var foe := _mk(["kin"], 10)
	foe.hp = foe.max_hp() / 2
	var lead := _mk(["kin"], 10)
	var b := Fixtures.battle([lead, _mk(["kin"], 10)], [foe])
	var base := Catching.chance(foe, "wicker", "day", b.catch_bonus())
	lead.held = "four_leaf_clover"
	assert_near(b.catch_bonus(), 1.3)
	assert_near(Catching.chance(foe, "wicker", "day", b.catch_bonus()), base * 1.3)
	lead.held = ""
	b.parties[0][1].held = "four_leaf_clover"
	assert_near(b.catch_bonus(), 1.0, 0.0001, "only the lead's counts")

func test_clover_says_so_when_you_throw() -> void:
	var lead := _mk(["kin"], 10)
	lead.held = "four_leaf_clover"
	var b := Fixtures.battle([lead], [_mk(["kin"], 10)])
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, SLOT0)
	assert_eq(ev[0].type, "charm")
	assert_eq(EventPlayer.lines_for(ev[0], EventPlayer.make_ctx(b))[0], "T Kin's Four-Leaf Clover brought a bit of luck!")

# --- brigid's cross ------------------------------------------------------------

func test_brigid_cross_blocks_status() -> void:
	var me := _mk(["kin"], 20, ["glare"])
	me.held = "brigid_cross"
	var foe := _mk(["kin"], 20, ["drench"])
	var b := Fixtures.battle([me], [foe])
	var ev := b.take_turn(SLOT0, SLOT0)
	assert_eq(me.status, "")
	assert_eq(_of(ev, "status").size(), 0)
	assert_eq(_of(ev, "charm")[0].item, "brigid_cross")

# --- thistle brooch ------------------------------------------------------------

func test_thistle_brooch_pricks_physical_attackers() -> void:
	var me := _mk(["kin"], 30, ["glare"])
	me.held = "thistle_brooch"
	var foe := _mk(["kin"], 30, ["scrap"])
	var b := Fixtures.battle([me], [foe])
	var ev := b.take_turn(SLOT0, SLOT0)
	assert_eq(foe.hp, foe.max_hp() - foe.max_hp() / 8)
	var e: Dictionary = _of(ev, "charm")[0]
	assert_eq(int(e.other_side), Battle.FOE)
	assert_eq(EventPlayer.lines_for(e, EventPlayer.make_ctx(b))[0], "The wild T Kin was pricked by T Kin's Thistle Brooch!")
	assert_eq(EventPlayer.fx_for(e, EventPlayer.make_ctx(b)).side, Battle.FOE)

func test_thistle_brooch_ignores_special_moves() -> void:
	var me := _mk(["kin"], 30, ["glare"])
	me.held = "thistle_brooch"
	var foe := _mk(["kin"], 30, ["rill_shot"])
	var b := Fixtures.battle([me], [foe])
	b.take_turn(SLOT0, SLOT0)
	assert_eq(foe.hp, foe.max_hp())

# --- shamrock pin --------------------------------------------------------------

func test_shamrock_pin_heals_each_turn() -> void:
	var me := _mk(["kin"], 30, ["glare"])
	me.held = "shamrock_pin"
	me.hp = 10
	var b := Fixtures.battle([me], [_mk(["kin"], 30, ["glare"])])
	var ev := b.take_turn(SLOT0, SLOT0)
	assert_eq(me.hp, 10 + me.max_hp() / 16)
	assert_eq(ev.back().type, "charm")
	assert_eq(EventPlayer.fx_for(ev.back(), EventPlayer.make_ctx(b)).cue, "heal")

func test_shamrock_pin_quiet_at_full_hp() -> void:
	var me := _mk(["kin"], 30, ["glare"])
	me.held = "shamrock_pin"
	var b := Fixtures.battle([me], [_mk(["kin"], 30, ["glare"])])
	assert_eq(_of(b.take_turn(SLOT0, SLOT0), "charm").size(), 0)

# --- oak acorn -----------------------------------------------------------------

func test_oak_acorn_raises_defence_at_the_start() -> void:
	var me := _mk(["kin"], 30)
	me.held = "oak_acorn"
	var b := Fixtures.battle([me], [_mk(["kin"], 30)])
	assert_eq(me.stages.def, 1)
	assert_eq(b.opening.size(), 1)
	assert_eq(EventPlayer.fx_for(b.opening[0], EventPlayer.make_ctx(b)).cue, "stat_up")

func test_oak_acorn_once_when_switched_in() -> void:
	var bench := _mk(["kin"], 30, ["glare"])
	bench.held = "oak_acorn"
	var b := Fixtures.battle([_mk(["kin"], 30, ["glare"]), bench], [_mk(["kin"], 30, ["glare"])], {"kind": "trainer"})
	assert_eq(b.opening.size(), 0)
	var ev := b.take_turn({"type": "switch", "index": 1}, SLOT0)
	assert_eq(bench.stages.def, 1)
	assert_eq(_of(ev, "charm").size(), 1)
	b.take_turn({"type": "switch", "index": 0}, SLOT0)
	ev = b.take_turn({"type": "switch", "index": 1}, SLOT0)
	assert_eq(bench.stages.def, 0, "only the first time out")
	assert_eq(_of(ev, "charm").size(), 0)

# --- wild charms, the AI, giving and taking, saves -----------------------------

func test_wild_creatures_rarely_carry_one() -> void:
	var c := _mk(["kin"], 5)
	var never := FixedRng.new()
	assert_eq(Charms.maybe_wild(c, never), "")
	assert_eq(c.held, "")
	var lucky := FixedRng.new()
	lucky.f = 0.01
	var got := Charms.maybe_wild(c, lucky)
	assert_has(Charms.wild_pool(), got)
	assert_eq(c.held, got)
	assert_false("selkie_pearl" in Charms.wild_pool(), "the special ones are earned")

func test_ai_respects_charms() -> void:
	var foe := _mk(["kin"], 30, ["glare"])
	foe.held = "brigid_cross"
	var me := _mk(["kin"], 30, ["drench", "scrap"])
	var b := Fixtures.battle([foe], [me], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, Battle.FOE, "trainer"), {"type": "move", "slot": 1}, "no status at a Brigid's Cross")
	var spirit := _mk(["brawn"], 30)
	spirit.held = "hag_stone"
	var att := _mk(["kin"], 30)
	var mv := Fixtures.moves().get_move("poltergeist")
	assert_near(BattleAI.score(b, att, spirit, mv), BattleAI.score(b, att, _mk(["brawn"], 30), mv) * 0.75)

func test_give_and_take_through_the_bag() -> void:
	var c := _mk(["kin"], 5)
	var bag := Bag.new({"hag_stone": 1, "oak_acorn": 1, "cup_of_tea": 1})
	assert_false(bag.give_charm("cup_of_tea", c).ok)
	assert_true(bag.give_charm("hag_stone", c).ok)
	assert_eq(c.held, "hag_stone")
	assert_eq(bag.count("hag_stone"), 0)
	var r := bag.give_charm("oak_acorn", c)
	assert_true(r.ok)
	assert_eq(c.held, "oak_acorn")
	assert_eq(bag.count("hag_stone"), 1, "the old one comes back")
	assert_true(bag.take_charm(c).ok)
	assert_eq(c.held, "")
	assert_eq(bag.count("oak_acorn"), 1)
	assert_false(bag.take_charm(c).ok)

func test_held_is_saved_and_old_saves_hold_nothing() -> void:
	var c := Fixtures.creature("kindlet", 5)
	c.held = "leek"
	assert_eq(Creature.from_dict(c.to_dict(), Fixtures.dex()).held, "leek")
	var old := c.to_dict()
	old.erase("held")
	assert_eq(Creature.from_dict(old, Fixtures.dex()).held, "")

func test_old_save_leek_becomes_the_charm() -> void:
	var d := GameStateData.new()
	d.bag = {"leek": 1, "cup_of_tea": 2}
	var back := GameStateData.from_dict(d.to_dict(), Fixtures.dex())
	var items := ItemDB.load_default()
	assert_eq(str(items.get_item("leek").kind), "charm")
	assert_eq(Bag.new(back.bag).items_of_kind("charm", items), ["leek"])
	assert_eq(Charms.outgoing_mult(_held("leek"), "hedgerow"), 1.2)

func test_release_hands_the_charm_back() -> void:
	var d := GameStateData.new()
	var a := Fixtures.creature("kindlet", 5)
	var b := Fixtures.creature("spikkin", 5)
	b.held = "oak_acorn"
	d.party = [a, b]
	assert_eq(d.release(true, 1), "")
	assert_eq(int(d.bag.get("oak_acorn", 0)), 1)

func _held(id: String) -> Creature:
	var c := _mk(["kin"], 5)
	c.held = id
	return c
