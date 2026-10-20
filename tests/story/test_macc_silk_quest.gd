extends TestCase
## "Hole Punch", the Silk Museum's errand: the curator starts it, the weaver at Paradise Mill takes the card, the
## blue plaque on the mill answers the question, and the curator pays out. The old lines still play either side.

func _talk(h: FakeStoryHost, zone: String, script: String) -> void:
	h.said.clear()
	await Commands.new(h, script).run(StoryData.script(zone, script))

func _q() -> Dictionary:
	return Quests.get_quest("macclesfield_silk")

func test_the_whole_errand() -> void:
	var h := FakeStoryHost.new()
	var q := _q()
	await _talk(h, "macc_silkmuseum", "macc_silkmuseum_0")
	assert_true(str(h.said).contains("Charles Roe"), "the curator's history lesson still comes first")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE, "and then the errand")
	assert_eq(Quests.step_index(h.data, q), 0)
	await _talk(h, "macc_silkmuseum", "macc_silkmuseum_0")
	assert_true(str(h.said).contains("waiting on that card"), "a nudge while the card's undelivered")
	await _talk(h, "macc_paradise", "macc_paradise_0")
	assert_eq(Quests.step_index(h.data, q), 1, "card delivered: now the plaque")
	await _talk(h, "macc_silkmuseum", "macc_silkmuseum_0")
	assert_true(str(h.said).contains("blue plaque"), "sent to read it")
	Gazetteer.record(h.data, "macclesfield_paradise_mill")
	assert_eq(Quests.step_index(h.data, q), 2, "the plaque ticks the step")
	h.choices = [0]  # 1881: wrong
	await _talk(h, "macc_silkmuseum", "macc_silkmuseum_0")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE, "a wrong answer doesn't finish it")
	h.choices = [1]  # 1981
	await _talk(h, "macc_silkmuseum", "macc_silkmuseum_0")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("macc_silk_square", 0)), 1, "the reward")
	assert_true(Standing.points(h.data, "england") >= 2)
	await _talk(h, "macc_paradise", "macc_paradise_0")
	assert_true(str(h.said).contains("1981"), "the weaver's old lines afterwards")

func test_weaver_is_unchanged_before_the_quest() -> void:
	var h := FakeStoryHost.new()
	await _talk(h, "macc_paradise", "macc_paradise_0")
	assert_eq(h.said.size(), 3, "the weaver's three lines, as before")
	assert_eq(Quests.status(h.data, _q()), Quests.NOT_STARTED)
