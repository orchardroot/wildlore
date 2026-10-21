extends TestCase
## Creature jobs: the lead's type decides, a job pays once, and every authored spot is on open ground.

func _zone() -> ZoneData:
	return ZoneData.from_dict({"id": "jz", "name": "J", "kind": "route", "rows": ["....", "....", "...."], "spawn": [0, 0],
		"props": [{"type": "creature_job", "job": "ford", "x": 1, "y": 1, "item": "seaweed"}]})

func _lead(types: Array) -> GameStateData:
	var d := GameStateData.new()
	var c := Creature.new()
	c.species = Fixtures.species("lead", types)
	d.party.append(c)
	return d

func test_can_do_by_type() -> void:
	assert_true(CreatureJobs.can_do("ford", ["brook"]))
	assert_true(CreatureJobs.can_do("nudge", ["hedgerow", "kin"]))
	assert_false(CreatureJobs.can_do("cross", ["brook"]))

func test_wrong_type_gets_a_hint_and_nothing_is_spent() -> void:
	var z := _zone()
	var d := _lead(["stone"])
	var r := CreatureJobs.attempt(d, z, z.props[0], ItemDB.load_default())
	assert_false(r.ok)
	assert_true(str(r.lines.back()).contains("brook"))
	assert_false(CreatureJobs.is_done(d, "jz", Vector2i(1, 1)))

func test_right_type_pays_once() -> void:
	var z := _zone()
	var d := _lead(["brook"])
	var r := CreatureJobs.attempt(d, z, z.props[0], ItemDB.load_default())
	assert_true(r.ok)
	assert_eq(int(d.bag.get("seaweed", 0)), 1)
	assert_true(CreatureJobs.is_done(d, "jz", Vector2i(1, 1)))
	var again := CreatureJobs.attempt(d, z, z.props[0], ItemDB.load_default())
	assert_false(again.ok)
	assert_eq(int(d.bag.get("seaweed", 0)), 1, "no second payout")

func test_no_able_lead() -> void:
	var z := _zone()
	var r := CreatureJobs.attempt(GameStateData.new(), z, z.props[0], ItemDB.load_default())
	assert_false(r.ok)

func test_the_job_props_are_blocked_so_you_face_them() -> void:
	assert_false(_zone().walkable(Vector2i(1, 1)))

func test_authored_spots_are_clean_and_plentiful() -> void:
	var items := ItemDB.load_default()
	var n := 0
	var kinds := {}
	for z in ZoneData.load_all().values():
		assert_eq(CreatureJobs.errors(z, items), [], z.id)
		for pr in z.props:
			if str(pr.get("type", "")) == CreatureJobs.TYPE:
				n += 1
				kinds[str(pr.job)] = true
	assert_true(n >= 30, "30+ spots, got %d" % n)
	assert_eq(kinds.size(), CreatureJobs.KINDS.size(), "every job kind is used")
