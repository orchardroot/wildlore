extends TestCase
## 1.5: the two Keeper level cliffs (Rhys 35 to Morwen 50, Nuala 54 to Ruairi 68) are bridged by extra trainers
## stood beside the path and a nudge to the wild levels on the way.

const KEEPER_MAX := {"keeper_maud": 12, "keeper_ray": 22, "keeper_eluned": 28, "keeper_rhys": 35, "keeper_morwen": 50,
	"keeper_declan": 50, "keeper_nuala": 54, "keeper_ruairi": 68, "keeper_isla": 79, "keeper_hester": 88}

## trainer -> [zone, lowest level, highest level]
const BRIDGES := {
	"severn_pilot": ["severn_crossing", 38, 41], "bath_rower": ["bath", 38, 42], "mendip_climber": ["mendips", 41, 44],
	"mendip_potholer": ["mendips", 42, 45], "glaston_dowser": ["glastonbury", 44, 47],
	"conn_turfcutter": ["connemara", 58, 61], "boyne_rambler": ["boyne_valley", 60, 63], "mo_shepherd": ["mournes", 61, 64],
	"mo_climber": ["mournes", 62, 65], "mo_ranger": ["mournes", 63, 66], "bel_docker": ["belfast", 64, 67],
}
const GAP1 := ["severn_crossing", "bath", "mendips", "glastonbury", "glastonbury_tor"]
const GAP2 := ["connemara", "sligo", "boyne_valley", "newgrange", "mournes", "belfast", "belfast_yard"]

static func _top(id: String) -> int:
	var top := 0
	for m in StoryData.trainer(id).party:
		top = maxi(top, int(m.level))
	return top

func _trainers_in(zone: String) -> Array:
	var out := []
	for n in ZoneData.load_id(zone).npcs:
		if str(n.get("trainer", "")) != "":
			out.append(str(n.trainer))
	return out

func test_keepers_are_never_lowered() -> void:
	for k in KEEPER_MAX:
		assert_true(_top(k) >= KEEPER_MAX[k], "%s still tops out at %d or more" % [k, KEEPER_MAX[k]])

func test_bridge_trainers_stand_on_their_route_at_the_right_levels() -> void:
	for id in BRIDGES:
		var b: Array = BRIDGES[id]
		var def := StoryData.trainer(id)
		assert_false(def.is_empty(), id + " exists")
		assert_true(_trainers_in(b[0]).has(id), "%s stands in %s" % [id, b[0]])
		assert_true(def.party.size() >= 3, id + " has a proper team")
		for m in def.party:
			assert_true(int(m.level) >= b[1] and int(m.level) <= b[2], "%s: %s at %d is in %d..%d" % [id, m.species, m.level, b[1], b[2]])
		assert_true(int(def.money) > 0 and def.intro.size() > 0 and str(def.win) != "", id + " pays and talks")

func test_bridge_trainers_never_move() -> void:
	# a beaten trainer stays put, so the validator's corks rule only has to look at still ones
	for id in BRIDGES:
		for n in ZoneData.load_id(BRIDGES[id][0]).npcs:
			if str(n.get("trainer", "")) == id:
				assert_eq(str(n.get("move", "still")), "still", id)

## The strongest trainer on the way to each Keeper sits within four levels of them, so the last step is a step.
func test_the_last_trainer_before_each_cliff_keeper_is_close() -> void:
	for gap in [[GAP1, "keeper_morwen"], [GAP2, "keeper_ruairi"]]:
		var top := 0
		for z in gap[0]:
			for id in _trainers_in(z):
				if not str(id).begins_with("keeper_"):
					top = maxi(top, _top(id))
		assert_true(_top(gap[1]) - top <= 4, "%s: best trainer on the way is %d" % [gap[1], top])

func test_wild_levels_climb_towards_the_keeper() -> void:
	for gap in [[["severn_crossing", "mendips", "glastonbury"], 35, 50], [["connemara", "boyne_valley", "mournes", "belfast"], 54, 68]]:
		var last := 0
		for z in gap[0]:
			var hi := 0
			var enc: Dictionary = ZoneData.load_id(z).encounters
			for kind in enc:
				for e in enc[kind]:
					hi = maxi(hi, int(e.get("max", 0)))
			assert_true(hi >= last, "%s doesn't dip (%d after %d)" % [z, hi, last])
			assert_true(hi > gap[1] and hi < gap[2], "%s wild top %d sits between the Keepers" % [z, hi])
			last = hi
