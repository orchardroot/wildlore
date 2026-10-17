extends TestCase
## Professor Garside's Fieldbook milestones (25, 50, 100, 150 caught; 200 is the diploma) and her region news.

func _host(n_caught: int) -> FakeStoryHost:
	var h := FakeStoryHost.new()
	h.dex = Dex.load_default()
	h.data.set_flag("starter", "spikkin")
	h.data.set_flag("garside_met", true)
	h.data.set_flag("snares_given", true)
	var ids: Array = h.dex.ids()
	for i in n_caught:
		h.data.mark_caught(ids[i])
	return h

func _talk(h: FakeStoryHost) -> void:
	StoryData.clear_cache()
	await Commands.new(h, "garside").run(StoryData.script("macc_fieldstation", "garside"))

func _bag(h: FakeStoryHost, item: String) -> int:
	return Bag.new(h.data.bag).count(item)

func test_25_gives_an_acorn_and_iron_snares_once() -> void:
	var h := _host(30)
	await _talk(h)
	assert_eq(_bag(h, "oak_acorn"), 1)
	assert_eq(_bag(h, "iron_snare"), 5)
	assert_eq(h.data.flag("fieldbook_25"), true)
	assert_eq(_bag(h, "four_leaf_clover"), 0, "not at 30")
	await _talk(h)
	assert_eq(_bag(h, "oak_acorn"), 1, "only once")

func test_nothing_before_25() -> void:
	var h := _host(24)
	await _talk(h)
	assert_eq(h.data.flag("fieldbook_25"), null)
	assert_eq(_bag(h, "oak_acorn"), 0)

func test_a_late_visit_collects_every_milestone_due() -> void:
	var h := _host(160)
	await _talk(h)
	for it in ["oak_acorn", "four_leaf_clover", "brigid_cross", "horseshoe"]:
		assert_eq(_bag(h, it), 1, it)
	assert_eq(_bag(h, "silver_snare"), 3)
	for n in [25, 50, 100, 150]:
		assert_eq(h.data.flag("fieldbook_%d" % n), true)
	assert_eq(FieldbookGoals.pending(h.data), 0)

func test_region_news_once() -> void:
	var h := _host(0)
	for sp in ZoneIndex.get_index().region_species.cheshire:
		h.data.mark_caught(sp)
	await _talk(h)
	var news := h.said.filter(func(l): return "Every creature in Cheshire" in str(l[1]))
	assert_eq(news.size(), 1)
	assert_eq(h.data.flag("region_news_cheshire"), true)
	h.said.clear()
	await _talk(h)
	assert_eq(h.said.filter(func(l): return "Every creature in Cheshire" in str(l[1])).size(), 0, "heard it already")

func test_no_milestones_before_the_starter() -> void:
	var h := FakeStoryHost.new()
	h.dex = Dex.load_default()
	for id in h.dex.ids().slice(0, 30):
		h.data.mark_caught(id)
	await _talk(h)
	assert_eq(_bag(h, "oak_acorn"), 0)
