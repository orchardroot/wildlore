extends TestCase
## The AI and the 2.0 moves: heal when low, never protect twice running, call weather that helps its own side.

const MF := preload("res://tests/battle/test_move_fx.gd")
const EXTRA := [
	{"id": "t_brook", "name": "Splash", "type": "brook", "category": "special", "power": 60, "accuracy": 100, "pp": 30, "effect": {"id": "none"}},
	{"id": "t_kindle", "name": "Kindle", "type": "hearth", "category": "special", "power": 60, "accuracy": 100, "pp": 30, "effect": {"id": "none"}},
	{"id": "t_pour", "name": "Pour", "type": "storm", "category": "status", "power": 0, "accuracy": 100, "pp": 10, "effect": {"id": "set_weather", "weather": "downpour", "target": "self"}},
	{"id": "t_sun", "name": "Sun", "type": "hearth", "category": "status", "power": 0, "accuracy": 100, "pp": 10, "effect": {"id": "set_weather", "weather": "sunshine", "target": "self"}},
]

static func db() -> MoveDB:
	var d := MF.db()
	if not d.has("t_brook"):
		for m in EXTRA:
			d.add(MoveDB.normalise(m))
	return d

static func mon(id: String, moves: Array, types := ["kin"], spd := 50) -> Creature:
	db()
	return MF.mon(id, moves, spd, 150, types)

func test_heals_when_low_not_when_healthy() -> void:
	var me := mon("me", ["t_hit", "t_heal"])
	var b := MF.fight([mon("foe", ["t_hit"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "trainer").slot, 0, "healthy: attack")
	me.hp = me.max_hp() / 4
	assert_eq(BattleAI.choose(b, Battle.FOE, "trainer").slot, 1, "low: patch up")

func test_never_protects_twice_running() -> void:
	var me := mon("me", ["t_wait", "t_guard"])
	var b := MF.fight([mon("foe", ["t_hit"], ["kin"], 90)], [me])
	me.hp = me.max_hp() / 4
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 1, "low and slower: guard")
	b.take_turn({"type": "move", "slot": 0}, {"type": "move", "slot": 1})
	assert_true(b.guarded_last_turn(me))
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0, "not twice in a row")

func test_calls_weather_that_helps_its_side() -> void:
	var me := mon("me", ["t_brook", "t_pour"], ["brook"])
	var b := MF.fight([mon("foe", ["t_kindle"], ["hearth"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 1, "a downpour: brook up, hearth down")
	b.weather = "downpour"
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0, "already pouring: just attack")

func test_wont_call_weather_that_helps_the_foe() -> void:
	var me := mon("me", ["t_brook", "t_sun"], ["brook"])
	var b := MF.fight([mon("foe", ["t_kindle"], ["hearth"])], [me])
	assert_eq(BattleAI.choose(b, Battle.FOE, "keeper").slot, 0)

func test_no_frost_moves_into_thick_fleece() -> void:
	db()
	var me := MF.mon("me", ["t_hit", "t_wait"], 50, 150, ["kin"])
	var sheep := MF.mon("sheep", ["t_wait"], 50, 150, ["kin"], {"knack": "thick_fleece"})
	var frosty := {"id": "f", "name": "F", "type": "frost", "category": "special", "power": 90, "accuracy": 100, "pp": 5, "effect": {"id": "none"}}
	var b := MF.fight([sheep], [me])
	assert_eq(BattleAI.score(b, me, sheep, MoveDB.normalise(frosty)), 0.0)

func test_multi_hit_and_weather_power_count() -> void:
	var me := mon("me", ["t_flurry"])
	var foe := mon("foe", ["t_hit"])
	var b := MF.fight([foe], [me])
	var flurry := db().get_move("t_flurry")
	assert_true(BattleAI.score(b, me, foe, flurry) > 15.0 * 1.5 * 2.5, "about three hits")
	var chat := db().get_move("t_chat")
	var dry := BattleAI.score(b, me, foe, chat)
	b.weather = "drizzle"
	assert_near(BattleAI.score(b, me, foe, chat), dry * 2.0, 0.01)
