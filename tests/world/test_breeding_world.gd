extends TestCase
## The rare-breeds farm and the Roslin lab: the zones are wired in, the plaques are the checked ones, the three
## conservation quests can be started, taught and paid end to end, and the dialogue keeps to the house rules.

const PLAQUES := ["breed_mendel", "breed_bateson", "breed_punnett", "breed_saunders", "breed_ancon", "breed_franklin",
	"breed_crick_watson", "breed_dolly", "breed_rare_breeds", "breed_soay", "breed_kerry", "breed_loaghtan", "breed_wildcat"]

func _run(script_file: String, sid: String, h: FakeStoryHost, owner := "") -> void:
	await Commands.new(h, owner).run(StoryData.script(script_file, sid))

func _bred(d: GameStateData, line: String, sire: int, dam: int) -> void:
	var c := Fixtures.creature(line, 3)
	Breeding.ensure_uid(d, c)
	Breeding.log_hatch(d, c, sire, dam)
	d.ark.append(c)

func test_the_doors_are_wired_both_ways() -> void:
	var zones := ZoneData.load_all()
	for pair in [["cotswolds", "guiting_farm"], ["guiting_farm", "guiting_barn"], ["edinburgh", "roslin_lab"]]:
		var a: ZoneData = zones[pair[0]]
		var b: ZoneData = zones[pair[1]]
		assert_true(a.warps.any(func(w): return str(w.to) == pair[1]), "%s opens onto %s" % pair)
		assert_true(b.warps.any(func(w): return str(w.to) == pair[0]), "%s opens back onto %s" % [pair[1], pair[0]])

func test_all_thirteen_plaques_are_there_once() -> void:
	var ids := Gazetteer.all().map(func(p): return str(p.id))
	for id in PLAQUES:
		assert_eq(ids.count(id), 1, id)
	assert_eq(ids.filter(func(i): return i.begins_with("breed_")).size(), PLAQUES.size())

func test_plaque_dates_that_were_checked() -> void:
	var by := {}
	for p in Gazetteer.all():
		by[str(p.id)] = str(p.text)
	for want in [["breed_mendel", "1866"], ["breed_mendel", "1900"], ["breed_bateson", "1905"], ["breed_bateson", "1906"],
			["breed_franklin", "1952"], ["breed_franklin", "1958"], ["breed_crick_watson", "25 April"], ["breed_crick_watson", "1953"],
			["breed_dolly", "5 July 1996"], ["breed_dolly", "February 1997"], ["breed_ancon", "1791"], ["breed_saunders", "1905"],
			["breed_rare_breeds", "1973"], ["breed_rare_breeds", "1971"], ["breed_soay", "1985"], ["breed_soay", "1930"]]:
		assert_true(by[want[0]].contains(want[1]), "%s says %s" % want)

func test_farm_dialogue_keeps_the_house_rules() -> void:
	var banned := ["Day Care", "Daycare", "Ditto", "egg group", "IV ", "IVs", "nature"]
	for f in ["guiting_farm", "guiting_barn", "roslin_lab"]:
		var raw := JSON.stringify(StoryData.all_dialogue().get(f, {}))
		assert_false("—" in raw, "%s: no em-dashes" % f)
		for b in banned:
			assert_false(raw.contains(b), "%s: no '%s'" % [f, b])

func test_every_quest_flag_is_set_somewhere() -> void:
	var set_flags := {}
	var files := StoryData.all_dialogue()
	for f in files:
		for sid in files[f]:
			_collect_sets(files[f][sid], set_flags)
	var quests: Dictionary = JsonUtil.read("res://data/quests/breed.json")
	assert_eq(quests.quests.size(), 3)
	for q in quests.quests:
		for f in [q.start_flag, q.done_flag] + q.steps.map(func(s): return s.flag):
			assert_true(str(f).begins_with("q_breed_"), f)
			assert_true(set_flags.has(f), "set somewhere: " + f)

func _collect_sets(cmds: Variant, out: Dictionary) -> void:
	if not cmds is Array:
		return
	for c in cmds:
		if not c is Dictionary:
			continue
		if str(c.get("do", "")) == "set":
			out[str(c.flag)] = true
		for k in ["then", "else"]:
			_collect_sets(c.get(k, []), out)

func test_dot_asks_to_pair_through_the_pairing_menu() -> void:
	var h := FakeStoryHost.new()
	h.zone = "guiting_farm"
	h.choices = [0]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_true(h.log.has(["menu", "pairing:guiting_farm"]))
	assert_eq(h.data.flag("breed_met_dot"), true)

func test_dot_collects_a_walked_off_basket() -> void:
	var h := FakeStoryHost.new()
	h.zone = "guiting_farm"
	h.data.rng_seed = 9
	var sire := Fixtures.creature("moolet", 10)
	var dam := Fixtures.creature("moolet", 10)
	sire.sex = "m"
	dam.sex = "f"
	sire.friendship = 200
	dam.friendship = 200
	var r := Breeding.start(h.data, sire, dam, "guiting_farm", h.dex, h.moves, Rng.new(3), "spring")
	assert_true(r.ok)
	h.data.stats["steps"] = int(h.data.stats.steps) + int(r.steps)
	h.data.set_flag("breed_met_dot", true)
	h.choices = [1]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.party.size(), 1)
	assert_true(h.texts().any(func(t): return str(t).contains("hatched")))

func test_soay_goal_end_to_end() -> void:
	var h := FakeStoryHost.new()
	h.zone = "guiting_farm"
	h.data.set_flag("breed_met_dot", true)
	h.data.set_flag("breed_met_keir", true)
	h.data.badges.append("b0")
	# Dot sets the task
	h.choices = [3, 0]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.flag("q_breed_soay_started"), true)
	# not yet told by Keir: she sends you off
	h.choices = [3, 0]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_true(h.data.flag("q_breed_soay_done") != true)
	h.choices = [5, 0]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_eq(h.data.flag("q_breed_soay_1"), true)
	# too few young: still told how far
	_bred(h.data, "loaghtan", 1, 2)
	h.choices = [3, 0]
	var before := h.data.money
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_true(h.data.flag("q_breed_soay_done") != true)
	assert_eq(h.data.money, before)
	# a proper spread
	_bred(h.data, "loaghtan", 1, 2)
	_bred(h.data, "loaghtan", 3, 4)
	_bred(h.data, "loaghtan", 5, 6)
	h.choices = [3, 0]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.flag("q_breed_soay_done"), true)
	assert_true(h.data.money > before)
	assert_eq(h.data.flag("breed_goal_soay"), true)
	# paid once
	var after := h.data.money
	h.choices = [3, 0]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.money, after)

func test_kerry_waits_for_the_flock_and_the_wildcat_waits_for_kerry() -> void:
	var h := FakeStoryHost.new()
	h.zone = "guiting_farm"
	h.data.set_flag("breed_met_dot", true)
	h.data.set_flag("breed_met_keir", true)
	h.choices = [3, 1]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_true(h.data.flag("q_breed_kerry_started") != true, "one list at a time")
	h.choices = [5, 2]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_true(h.data.flag("q_breed_wildcat_started") != true, "Dr Keir's list is the third")
	h.data.set_flag("q_breed_soay_done", true)
	h.choices = [3, 1]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.flag("q_breed_kerry_started"), true)
	h.data.set_flag("q_breed_kerry_done", true)
	h.choices = [5, 2]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_eq(h.data.flag("q_breed_wildcat_started"), true)
