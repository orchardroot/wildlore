extends TestCase
## `when` "party_has_<species>": a quest can ask you to show someone a creature you're carrying. A creature
## that has since evolved still counts as the one asked for.

func _said(h: FakeStoryHost, cond: String) -> bool:
	await Commands.new(h).run([{"do": "when", "cond": cond, "then": [{"do": "say", "text": "yes"}], "else": [{"do": "say", "text": "no"}]}])
	return h.texts() == ["yes"]

func test_party_has_species() -> void:
	var h := FakeStoryHost.new()
	assert_false(await _said(h, "party_has_snowhare"), "empty party")
	h.data.party.append(Fixtures.creature("snowhare", 15))
	var h2 := FakeStoryHost.new()
	h2.data.party = h.data.party
	assert_true(await _said(h2, "party_has_snowhare"))

func test_an_evolved_creature_still_counts() -> void:
	var h := FakeStoryHost.new()
	h.data.party.append(Fixtures.creature("sphagnet", 30))
	h.data.party.append(Fixtures.creature("peatmonarch", 30))
	var h2 := FakeStoryHost.new()
	h2.data.party = [Fixtures.creature("peatmonarch", 30)]
	assert_true(await _said(h2, "party_has_sphagnet"), "a Peatmonarch was a Sphagnet once")
	var h3 := FakeStoryHost.new()
	h3.data.party = [Fixtures.creature("sphagnet", 10)]
	assert_false(await _said(h3, "party_has_peatmonarch"), "not the other way round")

func test_ark_does_not_count() -> void:
	var h := FakeStoryHost.new()
	h.data.party = [Fixtures.creature("pipkin", 10)]
	assert_false(await _said(h, "party_has_snowhare"))

func test_validator_knows_party_has() -> void:
	var ok := StoryValidator.validate_commands([{"do": "when", "cond": "party_has_snowhare", "then": [{"do": "say", "text": "x"}]}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(ok, [])
	var bad := StoryValidator.validate_commands([{"do": "when", "cond": "party_has_unicorn"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(bad.size(), 1, "an unknown species is an error")
