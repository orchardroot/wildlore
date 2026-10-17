extends TestCase

func test_standing_command_adds_and_announces_a_tier() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "standing", "nation": "wales", "amount": 12}])
	assert_eq(Standing.points(h.data, "wales"), 12)
	assert_true(str(h.said).contains("Known Face"), "a new tier is announced")

func test_validator_knows_the_command() -> void:
	var ok := StoryValidator.validate_commands([{"do": "standing", "nation": "mann", "amount": 2}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(ok, [])
	var bad := StoryValidator.validate_commands([{"do": "standing", "nation": "narnia", "amount": 0}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(bad.size(), 2)
