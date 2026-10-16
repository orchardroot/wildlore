extends TestCase
## Lavender Sachets: weaker wild creatures stay away while one is going.

func _data(lead_level := 20) -> GameStateData:
	var d := GameStateData.new()
	d.party = [Fixtures.creature("kindlet", lead_level)]
	return d

func test_no_sachet_blocks_nothing() -> void:
	var d := _data()
	assert_eq(Repel.steps_left(d), 0, "old saves have no flag: nothing active")
	assert_false(Repel.blocks(d, 5))

func test_using_a_sachet() -> void:
	var d := _data()
	d.bag = {"lavender_sachet": 2}
	var r := Repel.use(d, "lavender_sachet", ItemDB.load_default())
	assert_true(r.ok)
	assert_eq(Repel.steps_left(d), 100)
	assert_eq(int(d.bag.lavender_sachet), 1)
	var again := Repel.use(d, "lavender_sachet", ItemDB.load_default())
	assert_false(again.ok, "one at a time: the last one is still going")
	assert_eq(int(d.bag.lavender_sachet), 1)

func test_using_none() -> void:
	var d := _data()
	assert_false(Repel.use(d, "lavender_sachet", ItemDB.load_default()).ok)
	assert_eq(Repel.steps_left(d), 0)

func test_suppresses_weaker_wild_creatures_only() -> void:
	var d := _data(20)
	d.set_flag(Repel.FLAG, 50)
	assert_true(Repel.blocks(d, 19))
	assert_false(Repel.blocks(d, 20), "same level still turns up")
	assert_false(Repel.blocks(d, 25))

func test_lead_is_first_creature_still_standing() -> void:
	var d := _data(30)
	d.party.append(Fixtures.creature("spikkin", 10))
	d.party[0].hp = 0
	d.set_flag(Repel.FLAG, 50)
	assert_true(Repel.blocks(d, 9))
	assert_false(Repel.blocks(d, 15))

func test_wears_off() -> void:
	var d := _data()
	d.set_flag(Repel.FLAG, 2)
	assert_false(Repel.step(d))
	assert_eq(Repel.steps_left(d), 1)
	assert_true(Repel.step(d), "the last step says so")
	assert_eq(Repel.steps_left(d), 0)
	assert_false(Repel.blocks(d, 1))
	assert_false(Repel.step(d), "nothing to wear off any more")

func test_steps_survive_a_save() -> void:
	var d := _data()
	d.set_flag(Repel.FLAG, 42)
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(Repel.steps_left(back), 42)

func test_sachet_is_stocked_from_buxton() -> void:
	var items := ItemDB.load_default()
	assert_eq(str(items.get_item("lavender_sachet").get("kind", "")), "repel")
	assert_true("lavender_sachet" in items.shops.buxton_corner_shop.stock)
	assert_true("lavender_sachet" in items.shops.york_corner_shop.stock)

## The wear-off prompt: says so, then offers another if there's one in the bag.
func test_worn_off_offers_another() -> void:
	var h := FakeStoryHost.new()
	h.data.party = [Fixtures.creature("kindlet", 20)]
	h.data.bag = {"lavender_sachet": 1}
	h.choices = [0]
	await Commands.new(h).run([{"do": "sachet_worn"}])
	assert_eq(h.texts()[0], Repel.WORN_LINE)
	assert_eq(Repel.steps_left(h.data), 100)
	assert_false(h.data.bag.has("lavender_sachet"))

func test_worn_off_decline_or_none_left() -> void:
	var h := FakeStoryHost.new()
	h.data.bag = {"lavender_sachet": 1}
	h.choices = [1]
	await Commands.new(h).run([{"do": "sachet_worn"}])
	assert_eq(Repel.steps_left(h.data), 0)
	assert_eq(int(h.data.bag.lavender_sachet), 1)
	var h2 := FakeStoryHost.new()
	await Commands.new(h2).run([{"do": "sachet_worn"}])
	assert_eq(h2.texts(), [Repel.WORN_LINE], "no sachets left: no question")
