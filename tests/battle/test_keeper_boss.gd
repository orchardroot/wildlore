extends TestCase
## 2.1 Keepers as bosses: set-up moves weighed against the best attack, one tea for the ace, the switch rule in
## doubles, and trainer parties built with fixed moves, a held charm and the tea (TrainerParty).

const MF := preload("res://tests/battle/test_move_fx.gd")
const EXTRA := [
	{"id": "t_doze", "name": "Doze", "type": "night", "category": "status", "power": 0, "accuracy": 100, "pp": 10, "effect": {"id": "status", "status": "asleep"}},
	{"id": "t_flex", "name": "Flex", "type": "brawn", "category": "status", "power": 0, "accuracy": 100, "pp": 10, "effect": {"id": "stat", "target": "self", "stat": "atk", "stages": 1}},
	{"id": "t_big", "name": "Big Hit", "type": "kin", "category": "physical", "power": 200, "accuracy": 100, "pp": 10, "effect": {"id": "none"}},
]

var items := ItemDB.load_default()

static func db() -> MoveDB:
	var d := MF.db()
	if not d.has("t_doze"):
		for m in EXTRA:
			d.add(MoveDB.normalise(m))
	return d

static func mon(id: String, moves: Array, spd := 50, hp := 150) -> Creature:
	db()
	return MF.mon(id, moves, spd, hp)

func fight(player: Array, foe: Array, opts := {}) -> Battle:
	var o := {"item_db": items}
	o.merge(opts, true)
	return MF.fight(player, foe, o)

# --- set-up moves ---------------------------------------------------------------------------------

func test_keeper_puts_the_foe_to_sleep_when_safe() -> void:
	var me := mon("me", ["t_hit", "t_doze"])
	var b := fight([mon("you", ["t_hit"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 1, "full HP and nothing can KO it: doze first")
	assert_eq(BattleAI.choose(b, Battle.FOE, "trainer").slot, 0, "route trainers just hit")

func test_no_status_on_a_foe_that_already_has_one() -> void:
	var me := mon("me", ["t_hit", "t_doze"])
	var you := mon("you", ["t_hit"])
	you.status = "stung"
	var b := fight([you], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0)

func test_finishes_the_foe_rather_than_setting_up() -> void:
	var me := mon("me", ["t_hit", "t_doze"])
	var you := mon("you", ["t_hit"])
	you.hp = 3
	var b := fight([you], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0)

func test_no_set_up_when_the_foe_can_knock_it_out() -> void:
	var me := mon("me", ["t_hit", "t_doze"])
	var b := fight([mon("you", ["t_big"])], [me])
	me.hp = me.max_hp() / 3
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0, "hurt and in range of a big hit: attack")

func test_boosts_its_attack_twice_at_most() -> void:
	var me := mon("me", ["t_hit", "t_flex"])
	var b := fight([mon("you", ["t_hit"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 1, "a physical hitter flexes first")
	me.stages["atk"] = 2
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0, "+2 is plenty")

# --- the Keeper's tea -----------------------------------------------------------------------------

func test_keeper_drinks_its_tea_once_when_low() -> void:
	var me := mon("me", ["t_hit"])
	me.set_meta(TrainerParty.TEA, "flask_of_tea")
	var b := fight([mon("you", ["t_wait"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").type, "move", "healthy: no tea yet")
	me.hp = me.max_hp() / 4
	var low := me.hp
	var act: Dictionary = BattleAI.choose(b, Battle.FOE, "keeper")
	assert_eq(act.type, "item")
	assert_eq(act.item, "flask_of_tea")
	var ev := b.take_turn({"type": "move", "slot": 0}, act)
	var tea := MF.first(ev, "charm")
	assert_eq(int(tea.side), Battle.FOE)
	assert_eq(str(tea.item), "flask_of_tea")
	assert_eq(me.hp, low + 60)
	assert_eq(int(tea.hp), me.hp)
	assert_true(str(tea.text).contains("Flask of Tea"))
	me.hp = me.max_hp() / 4
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").type, "move", "only the one flask")

func test_trainers_never_drink_tea() -> void:
	var me := mon("me", ["t_hit"])
	me.set_meta(TrainerParty.TEA, "flask_of_tea")
	var b := fight([mon("you", ["t_wait"])], [me])
	me.hp = me.max_hp() / 4
	assert_eq(BattleAI.choose(b, Battle.FOE, "trainer").type, "move")

func test_foe_item_without_tea_does_nothing() -> void:
	var me := mon("me", ["t_hit"])
	var b := fight([mon("you", ["t_wait"])], [me])
	me.hp = 10
	b.take_turn({"type": "move", "slot": 0}, {"type": "item", "item": "cream_tea", "target": 0})
	assert_eq(me.hp, 10, "a foe can only pour the tea it was given")

# --- doubles --------------------------------------------------------------------------------------

func test_keeper_switches_out_of_a_bad_match_up_in_doubles() -> void:
	var weak := mon("weak", ["t_wait"])
	var other := mon("other", ["t_hit"])
	var bench := mon("bench", ["t_hit"])
	var b := fight([mon("a", ["t_hit"]), mon("b", ["t_hit"])], [weak, other, bench], {"double": true})
	var acts: Array = BattleAI.choose(b, Battle.FOE, "keeper")
	assert_eq(acts[0], {"type": "switch", "index": 2}, "nothing to hit with: swap in the bench")
	assert_eq(acts[1].type, "move")
	var tr: Array = BattleAI.choose(b, Battle.FOE, "trainer")
	assert_eq(tr[0].type, "move", "route trainers stand their ground")

# --- building a trainer's party -------------------------------------------------------------------

func test_trainer_party_has_fixed_moves_charm_and_tea() -> void:
	var def := {"party": [
		{"species": "dipling", "level": 10},
		{"species": "rillotter", "level": 12, "moves": ["drench", "rill_shot"], "held": "selkie_pearl", "tea": "cup_of_tea"},
	]}
	var party := TrainerParty.build(def, Fixtures.dex(), FixedRng.new(), Fixtures.moves())
	assert_eq(party.size(), 2)
	assert_eq(party[0].held, "")
	assert_false(party[0].has_meta(TrainerParty.TEA))
	assert_eq(party[1].level, 12)
	assert_eq(party[1].moves.map(func(m): return m.id), ["drench", "rill_shot"])
	assert_eq(party[1].held, "selkie_pearl")
	assert_eq(party[1].get_meta(TrainerParty.TEA), "cup_of_tea")

func test_every_keeper_ace_has_a_charm_tea_and_a_set_up_move() -> void:
	var moves := Fixtures.moves()
	for id in ["maud", "ray", "eluned", "rhys", "morwen", "declan", "nuala", "ruairi", "isla", "hester"]:
		var def := StoryData.trainer("keeper_" + id)
		var ace: Dictionary = def.party[def.party.size() - 1]
		assert_true(Charms.is_charm(str(ace.get("held", ""))), "%s's ace holds a charm" % id)
		assert_true(items.has(str(ace.get("tea", ""))), "%s has a tea" % id)
		var setup := 0
		for m in def.party:
			assert_true(m.has("moves"), "%s: %s has an authored moveset" % [id, m.species])
			for mid in m.get("moves", []):
				var mv := moves.get_move(str(mid))
				if mv.category == "status" and str(mv.effect.get("id", "")) in ["stat", "status"]:
					setup += 1
		assert_true(setup >= 1, "%s has a set-up or status move" % id)
