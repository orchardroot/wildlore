extends TestCase
## Wave 38 session C: the four Scotland, Ireland and Northern Ireland lease zones keep to the lease contract
## (data/leases/<id>.json, docs/briefs/wave38.md): a cul-de-sac off a free edge of an existing outdoor zone.

const IDS := ["coire_dubh", "dubh_lochan", "clonbeg", "glenashen"]
const OPPOSITE := {"north": "south", "south": "north", "east": "west", "west": "east"}

func _lease(id: String) -> Dictionary:
	var d = JsonUtil.read("res://data/leases/%s.json" % id)
	return d if d is Dictionary else {}

func test_lease_records_follow_the_contract() -> void:
	for id in IDS:
		var l := _lease(id)
		assert_false(l.is_empty(), "%s has a lease record" % id)
		for k in ["id", "name", "nation", "kind", "anchor", "side", "zone", "reserve", "upkeep", "unlock_flag", "trust_wants", "blurb"]:
			assert_true(l.has(k), "%s has %s" % [id, k])
		assert_eq(str(l.id), id)
		assert_eq(str(l.unlock_flag), "game_complete")
		assert_true(int(l.reserve) >= 30000 and int(l.reserve) <= 150000, "%s reserve in the 30k to 150k band" % id)
		assert_true(int(l.upkeep) > 0)
		assert_false("—" in str(l.blurb) + str(l.name), "%s has no em-dash" % id)

func test_zone_is_a_cul_de_sac_off_a_free_anchor_edge() -> void:
	for id in IDS:
		var l := _lease(id)
		var anchor := ZoneData.load_id(str(l.anchor))
		var zone := ZoneData.load_id(str(l.zone))
		assert_true(anchor != null and zone != null, "%s zones load" % id)
		assert_true(anchor.kind != "interior", "%s anchors on an outdoor zone" % id)
		assert_false(anchor.edges.has(str(l.side)), "%s: the anchor's %s edge is free today" % [id, l.side])
		assert_eq(zone.edges.keys(), [OPPOSITE[str(l.side)]], "%s has exactly one way out" % id)
		var back: Dictionary = zone.edges[OPPOSITE[str(l.side)]]
		assert_eq(str(back.to), str(l.anchor))
		assert_eq(str(back.lease), id)
		assert_true(zone.warps.is_empty(), "%s has no doors to anywhere else" % id)

func test_anchor_gap_lines_up_with_the_zone_opening() -> void:
	for id in IDS:
		var l := _lease(id)
		var zone := ZoneData.load_id(str(l.zone))
		var side: String = OPPOSITE[str(l.side)]
		var g: Dictionary = l.gap
		for i in range(int(g.from), int(g.from) + int(g.len)):
			var p := Vector2i(i, 0) if side == "north" else Vector2i(zone.width - 1, i) if side == "east" else Vector2i(0, i)
			assert_true(zone.walkable(p), "%s opening tile %s is walkable" % [id, p])

func test_zones_have_plaques_ranger_and_returning_creatures() -> void:
	for id in IDS:
		var l := _lease(id)
		var zone := ZoneData.load_id(str(l.zone))
		var plaques := 0
		for s in zone.signs:
			if s.has("plaque"):
				plaques += 1
				assert_true(str(s.plaque).begins_with("lease_"), "%s plaque ids are namespaced" % id)
		assert_true(plaques >= 3, "%s has at least three plaques" % id)
		var stages := {}
		for e in zone.encounters.get("grass", []):
			stages[int(e.get("flag_at_least", 0)) if e.has("requires_flag") else 0] = true
			if e.has("requires_flag"):
				assert_eq(str(e.requires_flag), str(l.stage_flag))
		assert_eq(stages.keys().size(), 4, "%s: creatures return at every stage" % id)
		assert_eq(Rewild.looks(str(l.rewild.biome)).size(), 4, "%s rewild biome has four looks" % id)
		assert_eq(l.rewild.lines.size(), 4)
