extends TestCase
## The Tide Stone fight must stay reachable on foot. In 4.5.0 the Galway Docks arrival tile (8,12) was hemmed in by
## the Spanish Arch sign, the Galway hooker plaque and the door itself, so nobody (player or story bot) could get off
## the doorstep: "SOFTLOCK? beat galway_docks/keeper_nuala: no route from galway (25, 22) to galway_docks (9, 11)".

## Tiles the story bot plans round: NPCs that stand still (tests/../tools/playtest/bot.gd _routing_zones).
func _still_npcs(z: ZoneData) -> Dictionary:
	var out := {}
	for n in z.npcs:
		if str(n.get("move", "still")) == "still":
			out[Vector2i(int(n.x), int(n.y))] = true
	return out

func _npc(z: ZoneData, id: String) -> Dictionary:
	for n in z.npcs:
		if str(n.get("id", "")) == id:
			return n
	return {}

func test_the_docks_doorstep_leads_somewhere() -> void:
	var all := ZoneData.load_all()
	assert_eq(all["galway"].validate(all), [], "galway")
	assert_eq(all["galway_docks"].validate(all), [], "galway_docks")
	for w in all["galway"].warps:
		if str(w.to) == "galway_docks":
			assert_false(all["galway_docks"].doorstep_boxed_in(Vector2i(int(w.tx), int(w.ty))), "the docks arrival is boxed in")

func test_bot_can_walk_from_kit_to_keeper_nuala() -> void:
	var galway := ZoneData.load_id("galway")
	var docks := ZoneData.load_id("galway_docks")
	var zones := {"galway": galway, "galway_docks": docks}
	# the bot stands beside Kit after the kit6 beat; every still NPC (trainers included) is a wall
	var kit := _npc(galway, "kit")
	var start := Vector2i(int(kit.x), int(kit.y)) + Vector2i(0, 1)
	for z in zones.values():
		z.blocked.merge(_still_npcs(z))
	var legs := Pathfinder.route(zones, "galway", start, "galway_docks", docks.spawn, {})
	assert_true(legs.size() >= 2, "no route from Kit at %s in Galway to the docks spawn %s" % [start, docks.spawn])
	assert_eq(str(legs.back().zone), "galway_docks")
	var nuala := _npc(docks, "keeper_nuala")
	var stand := Vector2i(int(nuala.x), int(nuala.y)) + Vector2i(0, 1)
	assert_true(Pathfinder.within(docks, docks.spawn, stand, {}).size() > 0, "no route from the docks spawn to Keeper Nuala at %s" % stand)

func test_validator_flags_a_boxed_in_doorstep() -> void:
	# a doorstep with a sign on one side, the wall on the other and the door behind: the only way off is back out
	var room := {"id": "room", "kind": "interior", "spawn": [2, 1], "rows": ["xxxxx", "x|||x", "x|D|x", "xxxxx"],
		"signs": [{"x": 1, "y": 1, "text": "Plaque."}], "warps": [{"x": 2, "y": 2, "to": "street", "tx": 1, "ty": 1}]}
	var street := {"id": "street", "kind": "town", "spawn": [1, 1], "rows": ["xxxx", "x||x", "xxxx"],
		"warps": [{"x": 2, "y": 1, "to": "room", "tx": 1, "ty": 2}]}
	var all := {"room": ZoneData.from_dict(room), "street": ZoneData.from_dict(street)}
	var errs := "\n".join(all["street"].validate(all))
	assert_true(errs.contains("arrival 1,2 in 'room' is boxed in"), errs)
	assert_true(all["room"].doorstep_boxed_in(Vector2i(1, 2)))
	# landing on the tile above the door instead (the usual doorstep) is fine
	street.warps[0].tx = 2
	street.warps[0].ty = 1
	all["street"] = ZoneData.from_dict(street)
	assert_eq(all["street"].validate(all), [])
	assert_false(all["room"].doorstep_boxed_in(Vector2i(2, 1)))
