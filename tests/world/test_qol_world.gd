extends TestCase

func _water_zone() -> ZoneData:
	return ZoneData.from_dict({"id": "w", "rows": [",,,", "...", "~~~"], "spawn": [1, 1], "encounters": {
		"grass": [{"species": "spikkin", "min": 2, "max": 4}],
		"water": [{"species": "spikkin", "min": 2, "max": 4}]}})

func test_step_chance_per_kind() -> void:
	assert_eq(Encounters.step_chance("tall_grass"), 10.0)
	assert_eq(Encounters.step_chance("bog"), 10.0)
	assert_eq(Encounters.step_chance("deep_water"), 5.0)
	assert_eq(Encounters.step_chance("path"), 0.0)

func test_roll_uses_the_per_kind_chance() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	assert_true(Encounters.roll(_water_zone(), "deep_water", "day", "clear", r).has("species"), "water can trigger")
	assert_true(Encounters.roll(_water_zone(), "tall_grass", "day", "clear", r).has("species"), "grass can trigger")
	assert_eq(Encounters.roll(_water_zone(), "path", "day", "clear", r), {})

func test_grace_is_five_steps() -> void:
	var g := Encounters.new()
	g.after_battle()
	for i in 4:
		g.stepped()
	assert_true(g.in_grace(), "still in grace after 4 steps")
	g.stepped()
	assert_false(g.in_grace())

func test_run_toggle_latches() -> void:
	assert_false(Player.next_run_latch("toggle", false, false))
	assert_true(Player.next_run_latch("toggle", false, true), "press latches on")
	assert_false(Player.next_run_latch("toggle", true, true), "press again latches off")
	assert_true(Player.next_run_latch("toggle", true, false), "no press keeps it")
	assert_false(Player.next_run_latch("hold", true, true), "hold mode never latches")

func test_is_running_by_mode() -> void:
	assert_true(Player.is_running("hold", false, true))
	assert_false(Player.is_running("hold", true, false), "hold ignores the latch")
	assert_true(Player.is_running("toggle", true, false))
	assert_false(Player.is_running("toggle", false, true), "held key alone does nothing in toggle mode")

func test_bike_resumes_outdoors_only_if_allowed() -> void:
	assert_true(Player.resume_bike(true, ""))
	assert_false(Player.resume_bike(true, "No cycling indoors."))
	assert_false(Player.resume_bike(false, ""))

func test_autosave_after_catch_only() -> void:
	assert_true(Encounters.autosave_after({"result": "caught"}))
	assert_false(Encounters.autosave_after({"result": "win"}))
	assert_false(Encounters.autosave_after({"result": "lose"}))

func test_run_mode_setting_defaults_and_roundtrips() -> void:
	var s: Node = Settings
	assert_eq(s.run_mode, "hold")
	var old_path: String = s.path
	s.path = "user://test_settings_runmode.json"
	s.run_mode = "toggle"
	s.save_settings()
	s.run_mode = "hold"
	s.load_settings()
	assert_eq(s.run_mode, "toggle")
	s.run_mode = "hold"
	s.save_settings()
	s.path = old_path
	s.load_settings()

func test_legend_catch_autosaves_once_at_the_end_of_the_script() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_spirit", true)
	StoryData.clear_cache()
	await Commands.new(h, "lambton_spot").run(StoryData.script("penshaw", "lambton"))
	assert_eq(h.autosave_flags.size(), 0, "knocked out, not caught: no save")
	h.battle_results = [{"result": "caught"}]
	await Commands.new(h, "lambton_spot").run(StoryData.script("penshaw", "lambton"))
	assert_eq(h.autosave_flags.size(), 1, "caught: one save, after the script")
