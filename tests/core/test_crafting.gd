extends TestCase
## Crafting: the recipe file is sound, recipes unlock by flag, and a craft takes the inputs and gives the output.

func test_recipe_file_is_valid() -> void:
	var items := ItemDB.load_default()
	var errors := Crafting.validate(items)
	assert_eq(errors.size(), 0, "recipe errors: %s" % str(errors))
	assert_true(Crafting.all().size() >= 25, "about 25 recipes")

func test_validate_catches_mistakes() -> void:
	var items := ItemDB.load_default()
	var bad := [
		{"id": "a", "out": "cup_of_tea", "in": {"nettles": 1}},
		{"id": "a", "out": "cup_of_tea", "in": {"nettles": 1}},
		{"id": "b", "out": "no_such_thing", "in": {"nettles": 1}},
		{"id": "c", "out": "cup_of_tea", "in": {"unobtainium": 1}},
		{"id": "d", "out": "cup_of_tea", "in": {}},
		{"id": "e", "out": "rowan_sprig", "in": {"rowan_berry": 2}},
	]
	var e := Crafting.validate(items, bad)
	assert_eq(e.size(), 4, str(e))
	assert_true(str(e).contains("duplicated"))
	assert_true(str(e).contains("no_such_thing"))
	assert_true(str(e).contains("unobtainium"))
	assert_false(str(e).contains("'e'"), "a contract charm is allowed before charms.json lands")

func test_every_input_and_output_exists() -> void:
	var items := ItemDB.load_default()
	for r in Crafting.all():
		for k in r.in:
			assert_true(items.has(str(k)), "%s needs unknown %s" % [r.id, k])
		assert_true(items.has(str(r.out)) or str(r.out) in Crafting.CONTRACT_CHARMS, "%s makes unknown %s" % [r.id, r.out])

func test_mum_teaches_eight_and_folk_teach_the_rest() -> void:
	assert_eq(Crafting.taught_by("mum").size(), 8)
	var teachers := {}
	for r in Crafting.all():
		teachers[str(r.from)] = true
	assert_true(teachers.size() >= 11, "Mum and ten or more folk around the isles")

func test_known_by_flag() -> void:
	var d := GameStateData.new()
	assert_true(Crafting.known(d).is_empty(), "an old save knows nothing")
	assert_true(Crafting.learn(d, "bakewell_tart"))
	assert_false(Crafting.learn(d, "bakewell_tart"), "already known")
	assert_eq(d.flag("recipe_bakewell_tart"), true)
	assert_eq(Crafting.known(d).size(), 1)

func test_craft_takes_inputs_and_gives_output() -> void:
	var d := GameStateData.new()
	var items := ItemDB.load_default()
	d.bag = {"blackberries": 3, "hazelnuts": 2}
	var r := Crafting.get_recipe("bakewell_tart")
	assert_true(Crafting.can_make(d, r))
	var res := Crafting.craft(d, r, items)
	assert_true(res.ok)
	assert_eq(res.text, "You made Bakewell Tart.")
	assert_eq(int(d.bag.get("bakewell_tart", 0)), 1)
	assert_eq(int(d.bag.get("blackberries", 0)), 1)
	assert_false(d.bag.has("hazelnuts"), "used up")
	assert_false(Crafting.can_make(d, r))
	var again := Crafting.craft(d, r, items)
	assert_false(again.ok)
	assert_eq(int(d.bag.get("blackberries", 0)), 1, "nothing taken when it fails")

func test_craft_with_money_and_a_basic_item() -> void:
	var d := GameStateData.new()
	var items := ItemDB.load_default()
	var r := Crafting.get_recipe("bara_brith")
	d.bag = {"sloes": 2, "cup_of_tea": 1}
	d.money = 10
	assert_eq(Crafting.blocker(d, r), "money")
	assert_false(Crafting.craft(d, r, items).ok)
	d.money = 100
	assert_true(Crafting.craft(d, r, items).ok)
	assert_eq(d.money, 70)
	assert_false(d.bag.has("cup_of_tea"))
	assert_eq(int(d.bag.bara_brith), 1)

func test_craft_makes_batches_and_respects_full_stacks() -> void:
	var d := GameStateData.new()
	var items := ItemDB.load_default()
	var r := Crafting.get_recipe("nettle_tea")
	d.bag = {"nettles": 4, "cup_of_tea": 98}
	assert_eq(Crafting.blocker(d, r), "full")
	d.bag.cup_of_tea = 1
	var res := Crafting.craft(d, r, items)
	assert_eq(res.text, "You made Cup of Tea x2.")
	assert_eq(int(d.bag.cup_of_tea), 3)

func test_recipe_command_teaches() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "recipe", "id": ["parkin", "bakewell_tart"]}])
	assert_true(Crafting.is_known(h.data, "parkin"))
	assert_true(Crafting.is_known(h.data, "bakewell_tart"))
	assert_true(str(h.said).contains("Parkin"), str(h.said))
	h.said.clear()
	await Commands.new(h).run([{"do": "recipe", "id": "parkin"}])
	assert_true(h.said.is_empty(), "nothing to say about a recipe you know")

func test_craft_command_opens_the_bench() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "craft", "bench": "kitchen"}])
	assert_has(h.log, ["menu", "craft:kitchen"])

func test_story_validator_knows_the_commands() -> void:
	var dex := Fixtures.dex()
	var items := ItemDB.load_default()
	assert_eq(StoryValidator.validate_commands([{"do": "craft", "bench": "kitchen"}, {"do": "recipe", "id": "parkin"}], "t", dex, items, {}).size(), 0)
	assert_eq(StoryValidator.validate_commands([{"do": "recipe", "id": "nope"}], "t", dex, items, {}).size(), 1)
	assert_eq(StoryValidator.validate_commands([{"do": "craft", "bench": "garage"}], "t", dex, items, {}).size(), 1)

func test_every_recipe_has_a_teacher_in_the_world() -> void:
	var taught := {}
	var dialogue := StoryData.all_dialogue()
	var lists: Array = []
	for f in dialogue:
		for sid in dialogue[f]:
			if dialogue[f][sid] is Array:
				lists.append(dialogue[f][sid])
	while not lists.is_empty():
		for c in lists.pop_back():
			if not c is Dictionary:
				continue
			if str(c.get("do", "")) == "recipe":
				var ids = c.get("id")
				for id in (ids if ids is Array else [ids]):
					taught[str(id)] = true
			for k in ["then", "else"]:
				if c.get(k) is Array:
					lists.append(c[k])
	for r in Crafting.all():
		assert_true(taught.has(str(r.id)), "nobody teaches %s" % r.id)
