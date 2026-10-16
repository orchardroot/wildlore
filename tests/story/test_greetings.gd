extends TestCase
## {greeting}: a friendly local hello that depends on where you are (and, on Man, the time of day).

func test_region_greetings() -> void:
	assert_eq(StoryData.greeting("macclesfield", 600), "Alright!")
	assert_eq(StoryData.greeting("liverpool", 600), "Alright, la!")
	assert_eq(StoryData.greeting("york", 600), "Ey up!")
	assert_eq(StoryData.greeting("glasgow", 600), "Hiya!")
	assert_eq(StoryData.greeting("dublin", 600), "How's the form?")

func test_town_overrides_beat_the_region() -> void:
	assert_eq(StoryData.greeting("belfast", 600), "Bout ye?")
	assert_eq(StoryData.greeting("portree", 600), "Halò!")
	assert_eq(StoryData.greeting("birmingham", 600), "Alright, bab!")
	assert_eq(StoryData.greeting("dingle", 600), "Dia dhuit!")

func test_interiors_use_their_town() -> void:
	assert_eq(StoryData.greeting("belfast_shop", 600), "Bout ye?")
	assert_eq(StoryData.greeting("fort_william_sanctuary", 600), "Halò!")

func test_manx_morning_and_afternoon() -> void:
	assert_eq(StoryData.greeting("douglas", 9 * 60), "Moghrey mie!")
	assert_eq(StoryData.greeting("douglas", 15 * 60), "Fastyr mie!")

func test_unknown_zone_is_plain_hello() -> void:
	assert_eq(StoryData.greeting("no_such_place", 600), "Hello!")

func test_say_substitutes_greeting() -> void:
	var h := FakeStoryHost.new()
	h.data.zone_id = "belfast"
	await Commands.new(h).run([{"do": "say", "who": "Taxi Driver", "text": "{greeting} Where to?"}])
	assert_eq(h.said, [["Taxi Driver", "Bout ye? Where to?"]])
