extends TestCase

func _state() -> GameStateData:
	var s := GameStateData.new()
	var a := Fixtures.creature("kindlet", 8)
	a.status = "stung"
	a.take_damage(3)
	s.party = [a, Fixtures.creature("holtling", 5)]
	s.ark = [Fixtures.creature("spikkin", 3)]
	s.bag = {"tea": 3, "wicker_snare": 5}
	s.money = 1234
	s.set_flag("met_garside")
	s.set_flag("starter", "kindlet")
	s.zone_id = "macc_forest"
	s.pos = Vector2i(12, 7)
	s.facing = "left"
	s.mark_seen("scuttlet")
	s.mark_caught("kindlet")
	s.badges = ["brook"]
	s.clock_minutes = 1290
	s.last_sanctuary = {"zone": "macclesfield", "pos": [10, 11]}
	return s

func test_game_state_round_trip() -> void:
	var s := _state()
	var text := JSON.stringify(s.to_dict())
	var back := GameStateData.from_dict(JSON.parse_string(text), Fixtures.dex())
	assert_eq(back.to_dict(), s.to_dict())
	assert_eq(back.pos, Vector2i(12, 7))
	assert_eq(back.party[0].status, "stung")
	assert_eq(back.bag.tea, 3)
	assert_eq(typeof(back.bag.tea), TYPE_INT)
	assert_eq(back.flag("starter"), "kindlet")
	assert_true(back.caught.has("kindlet"))
	assert_eq(back.clock_minutes, 1290)

func test_add_creature_overflows_to_ark() -> void:
	var s := GameStateData.new()
	for i in 6:
		assert_eq(s.add_creature(Fixtures.creature("spikkin", 2)), "party")
	assert_eq(s.add_creature(Fixtures.creature("spikkin", 2)), "ark")
	assert_eq(s.party.size(), 6)
	assert_eq(s.ark.size(), 1)

func test_first_able_skips_fainted() -> void:
	var s := GameStateData.new()
	var a := Fixtures.creature("kindlet", 5)
	a.hp = 0
	s.party = [a, Fixtures.creature("holtling", 5)]
	assert_eq(s.first_able().species.id, "holtling")
	s.party[1].hp = 0
	assert_eq(s.first_able(), null)

func test_heal_party_restores_hp_pp_status() -> void:
	var s := GameStateData.new()
	var a := Fixtures.creature("kindlet", 5)
	a.hp = 0
	a.status = "hexed"
	a.moves[0].pp = 0
	s.party = [a]
	s.heal_party()
	assert_eq(a.hp, a.max_hp())
	assert_eq(a.status, "")
	assert_eq(a.moves[0].pp, a.moves[0].max_pp)

func test_default_last_sanctuary_is_not_origin() -> void:
	var d := GameStateData.new()
	assert_false(d.last_sanctuary.pos == [0, 0])
	var s := GameStateData.from_dict({"last_sanctuary": {}}, Dex.load_default())
	assert_eq(str(s.last_sanctuary.zone), "macclesfield")
	assert_false(s.last_sanctuary.pos == [0, 0])

func _mk(sp: String, fainted := false) -> Creature:
	var c := Creature.create(Dex.load_default().get_species(sp), 5, Rng.new(1), MoveDB.load_default())
	if fainted:
		c.hp = 0
	return c

func test_ark_rules() -> void:
	var d := GameStateData.new()
	d.party = [_mk("spikkin")]
	assert_true(d.deposit(0) != "", "can't deposit the only creature")
	d.party.append(_mk("scuttlet", true))
	assert_true(d.deposit(0) != "", "can't deposit the last able creature")
	assert_eq(d.deposit(1), "")
	assert_eq(d.ark.size(), 1)
	assert_eq(d.withdraw(0), "")
	assert_eq(d.party.size(), 2)
	for i in 4:
		d.party.append(_mk("pipkin"))
	d.ark.append(_mk("croakle"))
	assert_true(d.withdraw(0) != "", "party full")
	assert_eq(d.ark.size(), 1)
