extends TestCase
## The examine kit (Examine, ZoneData.examine) and locked and hidden warps (ZoneData.warp_state).

func _spot(extra := {}) -> Dictionary:
	var ex := {"x": 2, "y": 1, "text": ["A clock.", "It ticks."]}
	ex.merge(extra)
	return ex

func test_plain_spot_just_reads() -> void:
	var d := GameStateData.new()
	var r := Examine.read(d, "z", _spot(), null)
	assert_eq(r.lines, ["A clock.", "It ticks."])
	assert_false(r.gave)
	assert_false(ZoneData.flag_on(d.flag("ex_z_2_1")), "nothing to find, nothing recorded")

func test_find_is_given_once() -> void:
	var d := GameStateData.new()
	var ex := _spot({"find": {"item": "sloes", "n": 2}, "money": 3})
	var money := d.money
	var r := Examine.read(d, "z", ex, null)
	assert_true(r.gave)
	assert_eq(int(d.bag.get("sloes", 0)), 2)
	assert_eq(d.money, money + 3)
	assert_true(d.flag("ex_z_2_1"), "default flag ex_<zone>_<x>_<y>")
	var again := Examine.read(d, "z", ex, null)
	assert_false(again.gave)
	assert_eq(int(d.bag.get("sloes", 0)), 2)
	assert_eq(d.money, money + 3)

func test_named_flag_and_evidence() -> void:
	var d := GameStateData.new()
	Examine.read(d, "z", _spot({"flag": "found_it", "evidence": "otter_tag"}), null)
	assert_true(d.flag("found_it"))
	assert_true(d.flag(Examine.evidence_flag("otter_tag")))

func test_needs_gates_the_find_not_the_text() -> void:
	var d := GameStateData.new()
	var ex := _spot({"money": 5, "needs": "has_lamp"})
	var money := d.money
	var r := Examine.read(d, "z", ex, null)
	assert_eq(r.lines, ["A clock.", "It ticks."])
	assert_eq(d.money, money, "locked out")
	d.bag["has_lamp"] = 1
	Examine.read(d, "z", ex, null)
	assert_eq(d.money, money + 5, "an item satisfies needs")

func test_warp_states() -> void:
	var d := GameStateData.new()
	var old := {"x": 1, "y": 1, "to": "a"}
	var locked := {"x": 1, "y": 1, "to": "a", "locked": {"needs": "key_a", "line": "Locked."}}
	var hidden := {"x": 1, "y": 1, "to": "a", "hidden": {"reveal": "seen_it"}}
	assert_eq(ZoneData.warp_state(old, d), "open")
	assert_eq(ZoneData.warp_state(locked, d), "locked")
	assert_eq(ZoneData.warp_state(hidden, d), "hidden")
	d.bag["key_a"] = 1
	d.set_flag("seen_it", true)
	assert_eq(ZoneData.warp_state(locked, d), "open")
	assert_eq(ZoneData.warp_state(hidden, d), "open")
	var both := {"locked": {"needs": "k2"}, "hidden": {"reveal": "r2"}}
	assert_eq(ZoneData.warp_state(both, d), "hidden", "hidden wins until revealed")

func test_validator_checks_spots() -> void:
	var z := ZoneData.from_dict({"id": "ex", "kind": "interior", "spawn": [1, 1], "rows": ["xxxx", "x||x", "x||x", "xxxx"],
		"examine": [{"x": 9, "y": 9, "text": ["Nope."]}, {"x": 1, "y": 1, "text": []}]})
	var errs := "\n".join(z.validate({"ex": z}))
	assert_true(errs.contains("out of bounds"), errs)
	assert_true(errs.contains("no text"), errs)

func test_validator_flags_a_walled_in_spot() -> void:
	var z := ZoneData.from_dict({"id": "ex", "kind": "interior", "spawn": [1, 1], "rows": ["xxxxxx", "x|xxxx", "xxxx|x", "xxxxxx"],
		"examine": [{"x": 4, "y": 2, "text": ["Out of reach."]}]})
	assert_true("\n".join(z.validate({"ex": z})).contains("blocked off"))

func test_validator_flags_empty_lock() -> void:
	var z := ZoneData.from_dict({"id": "ex", "kind": "interior", "spawn": [1, 1], "rows": ["xxxx", "x||x", "xxxx"],
		"warps": [{"x": 2, "y": 1, "to": "ex", "tx": 1, "ty": 1, "locked": {}}]})
	assert_true("\n".join(z.validate({"ex": z})).contains("names nothing"))

func test_real_england_rooms_have_spots() -> void:
	var all := ZoneData.load_all()
	var n := 0
	for id in all:
		if all[id].kind == "interior" and not all[id].examine.is_empty():
			n += 1
	assert_true(n >= 40, "at least 40 interiors have examine lines, got %d" % n)

func test_chester_key_opens_the_rows_stair() -> void:
	var rows := ZoneData.load_id("chester_rows")
	var lock: Dictionary = {}
	for w in rows.warps:
		if w.has("locked"):
			lock = w
	assert_false(lock.is_empty(), "a locked warp in the Rows")
	var d := GameStateData.new()
	assert_eq(ZoneData.warp_state(lock, d), "locked")
	var smith := ZoneData.load_id("chester_clockmaker")
	Examine.read(d, "chester_clockmaker", smith.examine[0], null)
	assert_eq(ZoneData.warp_state(lock, d), "open", "the clockmaker's key fits")

func test_williamson_tunnels_are_hidden_until_found() -> void:
	var h := ZoneData.load_id("liverpool_h5")
	var hidden: Dictionary = {}
	for w in h.warps:
		if w.has("hidden"):
			hidden = w
	assert_false(hidden.is_empty(), "a hidden warp in Nan's house")
	var d := GameStateData.new()
	assert_eq(ZoneData.warp_state(hidden, d), "hidden")
	for ex in h.examine:
		Examine.read(d, "liverpool_h5", ex, null)
	assert_eq(ZoneData.warp_state(hidden, d), "open")
