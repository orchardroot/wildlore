extends TestCase
## The four England and Wales lease zones against the lease contract (data/leases/<id>.json): shape, the anchor edge
## that A's Leases opens, cul-de-sac zones with no shortcut, flag-gated creatures that return with the rewild stage,
## and plain text (no em-dashes) in everything a player reads.

const IDS := ["staithe_marshes", "lee_moor", "armboth_forest", "hafod_hill_farm"]
const KEYS := ["id", "name", "nation", "kind", "anchor", "side", "zone", "reserve", "upkeep", "unlock_flag", "trust_wants", "blurb"]
const OPP := {"north": "south", "south": "north", "east": "west", "west": "east"}

func _lease(id: String) -> Dictionary:
	var d = JsonUtil.read("res://data/leases/%s.json" % id)
	return d if d is Dictionary else {}

func test_lease_files_follow_the_contract() -> void:
	for id in IDS:
		var l := _lease(id)
		assert_false(l.is_empty(), id + " exists")
		for k in KEYS:
			assert_true(l.has(k), "%s has %s" % [id, k])
		assert_eq(str(l.id), id)
		assert_eq(str(l.unlock_flag), "game_complete")
		assert_true(int(l.reserve) >= 30000 and int(l.reserve) <= 150000, id + " reserve is in the design range")
		assert_true(int(l.upkeep) > 0)
		assert_eq(Leases.flag_key(id), "lease_" + id)

func test_the_anchor_edge_leads_in_and_the_zone_is_a_cul_de_sac() -> void:
	for id in IDS:
		var l := _lease(id)
		var anchor := ZoneData.load_id(str(l.anchor))
		var z := ZoneData.load_id(str(l.zone))
		assert_true(anchor.edges.has(l.side), id + ": anchor has the edge")
		assert_eq(str(anchor.edges[l.side].to), str(l.zone))
		assert_eq(str(anchor.edges[l.side].get("lease", "")), id, id + ": edge is tagged with its lease")
		assert_eq(z.edges.size(), 1, id + ": one way in and out")
		assert_true(z.edges.has(OPP[l.side]))
		assert_eq(str(z.edges[OPP[l.side]].to), str(l.anchor))
		assert_true(z.warps.is_empty(), id + ": no warp to a shortcut")

func test_returning_creatures_wait_for_the_stage() -> void:
	for id in IDS:
		var l := _lease(id)
		var z := ZoneData.load_id(str(l.zone))
		var key := str(l.rewild.flag)
		var gated := 0
		for e in z.encounters.get("grass", []):
			if e.has("requires_flag"):
				gated += 1
				assert_eq(str(e.requires_flag), key)
				assert_true(int(e.get("flag_at_least", 1)) in [1, 2, 3])
				assert_true(str(e.species) in l.rewild.returns, id + ": " + str(e.species) + " listed as returning")
		assert_true(gated >= 3, id + ": the land fills up as it heals")
		assert_eq(l.rewild.stages.size(), 4)

func test_every_zone_has_plaques_and_plain_text() -> void:
	for id in IDS:
		var l := _lease(id)
		var z := ZoneData.load_id(str(l.zone))
		var plaques := 0
		var texts: Array = [str(l.name), str(l.blurb)]
		for s in z.signs:
			texts.append(str(s.get("text", "")))
			if s.has("plaque"):
				plaques += 1
		assert_true(plaques >= 3, id + ": at least three plaques")
		var talk = JsonUtil.read("res://data/dialogue/%s.json" % l.zone)
		for k in talk:
			for c in talk[k]:
				texts.append(JSON.stringify(c))
		for t in texts:
			assert_false("—" in t or "–" in t, id + ": no dashes in '" + t.left(40) + "'")

func test_the_stub_says_not_owned_until_the_flag() -> void:
	var d := GameStateData.new()
	assert_false(Leases.owned(d, "lee_moor"))
	d.set_flag("lease_lee_moor", true)
	assert_true(Leases.owned(d, "lee_moor"))
