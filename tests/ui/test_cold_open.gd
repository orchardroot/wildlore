extends TestCase
## The cold open before Mum's room on a New Game: a moor at night, a stone humming, something big on the
## skyline, then morning. Short, skippable, made of ordinary story commands.

const ALLOWED := ["say", "wait", "sfx", "music", "fade_in", "fade_out"]

func test_the_script_is_short_and_uses_only_plain_commands() -> void:
	var s := ColdOpen.script()
	assert_true(s.size() >= 4, "there is a cold open")
	for c in s:
		assert_has(ALLOWED, str(c.get("do", "")), "plain command")
		assert_false(str(c.get("text", "")).contains("—"), "no em-dash")
	var secs := ColdOpen.duration(s)
	assert_true(secs > 8.0 and secs < 30.0, "under 30 seconds (%.1f)" % secs)

func test_it_ends_on_morning() -> void:
	var s := ColdOpen.script()
	var last_say := ""
	for c in s:
		if c.get("do") == "say":
			last_say = str(c.text)
	assert_true(last_say.to_lower().contains("morning"), last_say)

func test_skipping_runs_the_rest_at_once() -> void:
	var h := ColdOpen.Host.new(null)
	h.skipped = true
	var t := Time.get_ticks_msec()
	await Commands.new(h).run(ColdOpen.script())
	assert_true(Time.get_ticks_msec() - t < 200, "a skipped cold open takes no time")
	assert_true(h.lines.is_empty(), "nothing was shown")

func test_only_on_a_new_game() -> void:
	var d := GameStateData.new()
	assert_true(ColdOpen.wanted(d))
	d.set_flag("mum_done", true)
	assert_false(ColdOpen.wanted(d), "not once you've been about")
	var e := GameStateData.new()
	e.set_flag(ColdOpen.SEEN_FLAG, true)
	assert_false(ColdOpen.wanted(e), "not twice")
