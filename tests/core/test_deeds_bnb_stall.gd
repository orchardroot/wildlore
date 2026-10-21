extends TestCase
## The B&B and market stall Deed files (session B of wave 35): each parses, follows the Deeds contract, and names
## real zones, doors, counter NPCs and items. Reads the files directly so it stands without core/deeds.gd.

const IDS := ["bnb_keswick", "bnb_portree", "stall_bath", "stall_carlisle"]

func _read(path: String) -> Dictionary:
	var d = JsonUtil.read(path)
	return d if d is Dictionary else {}

func test_each_deed_follows_the_contract() -> void:
	var items := ItemDB.load_default()
	for id in IDS:
		var d := _read("res://data/deeds/%s.json" % id)
		assert_eq(str(d.get("id", "")), id)
		assert_true(str(d.get("kind", "")) in ["bnb", "stall"], id + " kind")
		assert_true(str(d.get("name", "")) != "", id + " name")
		var cost: Array = d.get("cost", [])
		assert_eq(cost.size(), 3, id + " cost bands")
		assert_true(cost[0] <= cost[1] and cost[1] <= cost[2], id + " cost rises")
		assert_true(d.get("tiers", []).size() >= 3 and d.get("tiers", []).size() <= 4, id + " tiers")
		assert_true(d.get("events", []).size() >= 5, id + " events")
		assert_true(float(d.get("rates", 0)) > 0.0, id + " rates")
		for e in d.events:
			assert_true(str(e.get("line", "")) != "" and not "—" in str(e.line), id + " event line")
		for inp in d.get("inputs", []):
			assert_true(items.has(str(inp.item)), id + " input " + str(inp.item))
			assert_true(int(items.get_item(str(inp.item)).get("price", 0)) > 0, id + " input has a price")
		assert_true(bool(d.get("manager_slot", false)), id + " manager slot")

func test_zones_doors_and_counters_are_real() -> void:
	for id in IDS:
		var d := _read("res://data/deeds/%s.json" % id)
		var town := _read("res://data/zones/%s.json" % d.zone)
		var room := _read("res://data/zones/%s.json" % d.interior)
		assert_true(not town.is_empty() and not room.is_empty(), id + " zones exist")
		var door_ok := false
		for w in town.get("warps", []):
			if str(w.to) == str(d.interior) and int(w.x) == int(d.door.x) and int(w.y) == int(d.door.y):
				door_ok = true
		assert_true(door_ok, id + " door leads to the interior")
		var script := ""
		for n in room.get("npcs", []):
			if str(n.get("script", "")).ends_with("_desk") or str(n.get("script", "")).ends_with("_pitch"):
				script = str(n.script)
		assert_true(script != "", id + " has a counter NPC")
		var dlg := _read("res://data/dialogue/%s.json" % d.interior)
		var calls := false
		for c in dlg.get(script, []):
			if str(c.get("do", "")) == "deed" and str(c.get("id", "")) == id:
				calls = true
		assert_true(calls, id + " counter opens its Deed screen")
