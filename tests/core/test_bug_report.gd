extends TestCase
## The Report a bug link: pre-filled GitHub issue URL with version, zone and platform, and the player's own words.

func test_url_carries_the_facts() -> void:
	var u := BugReport.url("3.4.0", "macclesfield", "macOS", "stuck behind a bench")
	assert_true(u.begins_with("https://github.com/orchardroot/wildlore-these-isles/issues/new?"), "repo issue form")
	assert_true(u.contains("3.4.0"), "version")
	assert_true(u.contains("macclesfield"), "zone")
	assert_true(u.contains("macOS"), "platform")
	assert_true(u.contains("stuck%20behind%20a%20bench"), "text is percent-encoded")

func test_awkward_text_is_encoded_and_trimmed() -> void:
	var u := BugReport.url("1", "z", "Linux", "a&b=c#d\nline two " + "x".repeat(1000))
	assert_false(u.contains("a&b"), "ampersand escaped")
	assert_false(u.contains("#d"), "hash escaped")
	assert_true(u.length() < 3000, "kept to a sane length")

func test_empty_text_still_makes_a_url() -> void:
	assert_true(BugReport.url("1", "z", "Windows", "").begins_with("https://"))
