extends TestCase
## `when` "has_<species>": a show-me check for quests ("have you caught a peregrine yet?").

func _said(h: FakeStoryHost, cond: String) -> bool:
	await Commands.new(h).run([{"do": "when", "cond": cond, "then": [{"do": "say", "text": "yes"}], "else": [{"do": "say", "text": "no"}]}])
	return h.texts() == ["yes"]

func test_has_species_follows_the_caught_list() -> void:
	var h := FakeStoryHost.new()
	assert_false(await _said(h, "has_peregrin"), "nothing caught yet")
	h.data.mark_caught("peregrin")
	var h2 := FakeStoryHost.new()
	h2.data = h.data
	assert_true(await _said(h2, "has_peregrin"))
	var h3 := FakeStoryHost.new()
	h3.data = h.data
	assert_false(await _said(h3, "has_kidgruff"), "only the species caught")

func test_seen_is_not_caught() -> void:
	var h := FakeStoryHost.new()
	h.data.mark_seen("peregrin")
	assert_false(await _said(h, "has_peregrin"))

func test_validator_accepts_known_species_only() -> void:
	var ok := StoryValidator.validate_commands([{"do": "when", "cond": "has_peregrin", "then": [{"do": "say", "text": "x"}]}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(ok, [])
	var bad := StoryValidator.validate_commands([{"do": "when", "cond": "has_nonesuch"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(bad.size(), 1)
