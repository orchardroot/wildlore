extends TestCase
## Travel scenes: the setting, who never sees them (Off, the playtest bot), the scene's clock and skip,
## the trains that meet you at the platform, and that every journey still lands exactly where it always did.

const TMP := "user://test_settings_journey.json"

## A story host that plays travel scenes: it records them and says whether one played.
class SceneHost extends FakeStoryHost:
	var plays := true
	func journey_out(kind: String, info: Dictionary) -> bool:
		log.append(["journey_out", kind, info.duplicate()])
		return plays
	func journey_in(kind: String, info: Dictionary) -> void:
		log.append(["journey_in", kind, warps.size()])

func _settings_begin() -> String:
	var saved := Settings.path
	Settings.path = TMP
	if FileAccess.file_exists(TMP):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	return saved

func _settings_end(saved: String) -> void:
	if FileAccess.file_exists(TMP):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	Settings.path = saved
	Settings.travel_scenes = "on"

func _write(d: Dictionary) -> void:
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string(JSON.stringify(d))
	f.close()

# --- the setting ---------------------------------------------------------------------------------------------

func test_travel_scenes_setting_defaults_on_and_round_trips() -> void:
	var saved := _settings_begin()
	Settings.travel_scenes = "off"
	_write({"text_speed": "fast"})  # a settings file from before the row existed
	Settings.load_settings()
	assert_eq(Settings.travel_scenes, "off", "a missing key keeps what is set")
	Settings.travel_scenes = "on"
	Settings.load_settings()
	assert_eq(Settings.travel_scenes, "on", "and the default is On")
	_write({"travel_scenes": "sideways"})
	Settings.load_settings()
	assert_eq(Settings.travel_scenes, "on", "nonsense falls back to On")
	Settings.travel_scenes = "short"
	Settings.save_settings()
	Settings.travel_scenes = "on"
	Settings.load_settings()
	assert_eq(Settings.travel_scenes, "short", "saved and read back")
	Settings.text_speed = "normal"
	_settings_end(saved)

func test_settings_screen_has_a_travel_scenes_row() -> void:
	var src := FileAccess.get_file_as_string("res://ui/settings_screen.gd")
	assert_true(src.contains("\"travel_scenes\", \"Travel scenes\""), "the row is listed")
	assert_eq(Journey.MODES, ["on", "short", "off"])

func test_mode_follows_the_setting_and_the_bot_never_sees_a_scene() -> void:
	for m in ["on", "short", "off"]:
		Settings.travel_scenes = m
		assert_eq(Journey.mode(), m)
	Settings.travel_scenes = "on"
	Engine.set_meta("autopilot", RefCounted.new())
	assert_eq(Journey.mode(), "off", "the playtest bot skips scenes entirely")
	Engine.remove_meta("autopilot")
	assert_eq(Journey.mode(), "on")

func test_off_and_autopilot_play_nothing() -> void:
	var ow := Node.new()  # an overworld stand-in (not in the tree, so nothing could play over it anyway)
	Settings.travel_scenes = "off"
	assert_false(Journey.will_play(ow), "Off: no scene")
	Settings.travel_scenes = "on"
	Engine.set_meta("autopilot", RefCounted.new())
	assert_false(Journey.will_play(ow), "the bot: no scene")
	Engine.remove_meta("autopilot")
	assert_false(Journey.will_play(null), "nothing to play over")
	assert_false(Journey.will_play(ow), "nor over a scene that isn't showing")
	ow.free()

func test_journeys_fit_the_time_budget() -> void:
	for kind in Journey.KINDS:
		var on := Journey.total_seconds(kind, "on")
		var short := Journey.total_seconds(kind, "short")
		assert_true(on >= 5.0 and on <= 8.0, "%s On takes 5 to 8 s (%.1f)" % [kind, on])
		assert_true(short >= 1.5 and short < on, "%s Short is shorter (%.1f)" % [kind, short])
		assert_eq(Journey.total_seconds(kind, "off"), 0.0)

# --- the scene -------------------------------------------------------------------------------------------------

func _scene(kind: String, mode := "on") -> JourneyScene:
	var s := JourneyScene.new()
	s.setup(kind, {"from": "macclesfield", "to": "york", "route": "liverpool_douglas", "card": "A gull."}, mode)
	return s

func test_scene_always_ends_on_its_own() -> void:
	for kind in Journey.KINDS:
		for mode in ["on", "short"]:
			var s := _scene(kind, mode)
			s.build_view(Vector2(1280, 720))
			s.play_now()
			var t := 0.0
			while not s.done and t < 30.0:
				s.advance(1.0 / 60.0)
				t += 1.0 / 60.0
			assert_true(s.done, "%s %s ended" % [kind, mode])
			assert_near(t, Journey.scene_seconds(kind, mode), 0.05, "%s %s ran its length" % [kind, mode])
			assert_false(s.skipped)
			s.free()

func test_confirm_or_cancel_skips_and_nothing_else_does() -> void:
	for action in ["confirm", "cancel"]:
		var s := _scene("train")
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = true
		assert_true(s.wants_skip(ev), action + " skips")
		s.skip()
		assert_true(s.done and s.skipped, action)
		s.free()
	var s2 := _scene("ferry")
	for action in ["move_left", "menu", "run"]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = true
		assert_false(s2.wants_skip(ev), action + " doesn't skip")
	var up := InputEventAction.new()
	up.action = "confirm"
	up.pressed = false
	assert_false(s2.wants_skip(up), "a release doesn't skip")
	s2.free()

func test_skipping_before_it_plays_ends_it_straight_away() -> void:
	var s := _scene("train")
	s.skip()  # during the platform part, before the window scene
	s.play_now()
	assert_true(s.done)
	s.free()

func test_scene_views_stay_small() -> void:
	for kind in Journey.KINDS:
		for town in ["inverness", "london", "galway", "llanberis", "penzance", "buxton", "nottingham"]:
			for phase in ["day", "night"]:
				var s := JourneyScene.new()
				s.setup(kind, {"from": "macclesfield", "to": town, "route": "holyhead_dublin", "card": "Sea."}, "on")
				s.phase = phase
				s.weather = "downpour" if town == "galway" else "clear"
				s.build_view(Vector2(1280, 720))
				var n := _count(s)
				assert_true(n > 10 and n < 420, "%s to %s at %s: %d nodes" % [kind, town, phase, n])
				s.play_now()
				for i in 30:
					s.advance(0.1)  # slides layers about without erroring
				s.free()

func _count(n: Node) -> int:
	var c := 1
	for k in n.get_children():
		c += _count(k)
	return c

func test_scenery_suits_where_you_are_going() -> void:
	assert_eq(Journey.scheme_for("inverness"), "highland")
	assert_eq(Journey.scheme_for("fort_william"), "highland")
	assert_eq(Journey.scheme_for("galway"), "ireland")
	assert_eq(Journey.scheme_for("llanberis"), "wales")
	assert_eq(Journey.scheme_for("london"), "city")
	assert_eq(Journey.scheme_for("manchester"), "city")
	assert_eq(Journey.scheme_for("buxton"), "moor")
	assert_eq(Journey.scheme_for("penzance"), "coast")
	assert_eq(Journey.scheme_for("nottingham"), "lowland")
	assert_eq(Journey.scheme_for("atlantis"), "lowland")
	for town in Travel.world_map().get("towns", {}):
		assert_true(JourneyScene.SCHEMES.has(Journey.scheme_for(town)), town)

# --- trains at the platform ------------------------------------------------------------------------------------

func _station_zone() -> ZoneData:
	var rows := [".".repeat(60), "_".repeat(60), "!".repeat(60), ".".repeat(60)]
	return ZoneData.from_dict({"id": "t", "name": "T", "kind": "town", "rows": rows, "props": [], "warps": [], "edges": {},
		"npcs": [], "encounters": {}, "signs": [], "spawn": [1, 0], "weather": {}, "station": {"x": 30, "y": 1}})

func _traffic(z: ZoneData) -> RailTraffic:
	var t := RailTraffic.new()
	t.setup(z, func() -> Dictionary: return {}, 60.0)
	return t

func test_the_train_you_catch_pulls_in_within_a_few_seconds() -> void:
	var t := _traffic(_station_zone())
	assert_false(t.at_platform())
	assert_true(t.call_at_station(), "a train is sent in")
	var secs := 0.0
	while not t.at_platform() and secs < 10.0:
		t.tick(1.0 / 30.0)
		secs += 1.0 / 30.0
	assert_true(t.at_platform(), "it stopped at the platform")
	assert_true(secs > 1.0 and secs <= Journey.BOARD_MAX, "and quickly (%.1f s)" % secs)
	var mid: float = t.run.head - t.run.length * 0.5
	assert_near(RailTraffic.point_at(t.run.path, mid).x, 30.5, 0.4, "the middle of the train by the platform")
	t.free()

func test_the_arrival_train_is_already_standing_then_leaves() -> void:
	var t := _traffic(_station_zone())
	assert_true(t.stand_at_station())
	assert_true(t.at_platform(), "standing there from the first frame")
	var secs := 0.0
	while not t.run.is_empty() and secs < 30.0:
		t.tick(1.0 / 30.0)
		secs += 1.0 / 30.0
	assert_true(t.run.is_empty(), "then it goes on its way (%.1f s)" % secs)
	t.free()

func test_a_terminus_train_calls_at_a_platform_part_way_along() -> void:
	var rows := [".".repeat(40), "_".repeat(40), "." + "!".repeat(39), ".".repeat(40)]
	var z := ZoneData.from_dict({"id": "t", "name": "T", "kind": "town", "rows": rows, "props": [{"type": "buffer_stop", "x": 1, "y": 2}],
		"warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [1, 0], "weather": {}, "station": {"x": 25, "y": 1}})
	var t := _traffic(z)
	assert_true(t.call_at_station())
	var secs := 0.0
	while not t.at_platform() and secs < 10.0:
		t.tick(1.0 / 30.0)
		secs += 1.0 / 30.0
	assert_true(t.at_platform(), "it stops at the platform before the buffers (%.1f s)" % secs)
	while not t.run.is_empty() and secs < 60.0:
		t.tick(1.0 / 30.0)
		secs += 1.0 / 30.0
	assert_true(t.run.is_empty(), "then on to the buffers and back out")
	t.free()

func test_no_line_no_platform_train() -> void:
	var z := ZoneData.from_dict({"id": "t", "name": "T", "kind": "town", "rows": ["....", "...."], "props": [], "warps": [],
		"edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [1, 0], "weather": {}, "station": {"x": 1, "y": 1}})
	var t := _traffic(z)
	assert_false(t.call_at_station())
	assert_false(t.stand_at_station())
	assert_false(t.at_platform())
	t.free()

func test_real_stations_have_a_train_to_meet_you() -> void:
	var with_station := 0
	var served := 0
	var missing := []
	for zid in ZoneData.load_all():
		var z: ZoneData = ZoneData.load_id(zid)
		if z.station == Vector2i(-1, -1) or z.town_id == "":
			continue
		with_station += 1
		if RailTraffic.platform_run(z, RailTraffic.find_routes(z)).is_empty():
			missing.append(zid)
		else:
			served += 1
	assert_true(with_station > 20, "plenty of stations (%d)" % with_station)
	assert_true(served >= with_station - 1, "every station on a line gets a train at the platform; not: %s" % str(missing))

# --- arrivals are unchanged ------------------------------------------------------------------------------------

func _rail(host: FakeStoryHost) -> void:
	host.data.bag["rail_pass"] = 1
	host.zone = "macclesfield"
	host.menu_results = {"travel:rail": "york"}
	Commands.new(host).run([{"do": "rail"}])

func test_rail_lands_on_the_same_tile_with_or_without_a_scene() -> void:
	var a := Travel.rail_arrival("york")
	var expect := [["york", a.pos.x, a.pos.y, "down"]]
	var plain := FakeStoryHost.new()
	_rail(plain)
	assert_eq(plain.warps, expect, "no scene support (the old way)")
	assert_has(plain.log, ["sfx", "train"])
	var scene := SceneHost.new()
	_rail(scene)
	assert_eq(scene.warps, expect, "with a scene")
	assert_false(["sfx", "train"] in scene.log, "the scene does its own sounds")
	var outs := scene.log.filter(func(e): return e[0] == "journey_out")
	assert_eq(outs.size(), 1)
	assert_eq(outs[0][1], "train")
	assert_eq(outs[0][2].get("to"), "york")
	assert_eq(outs[0][2].get("from"), "macclesfield")
	assert_has(scene.log, ["journey_in", "train", 1], "the arrival plays after the warp")
	var off := SceneHost.new()
	off.plays = false  # Off, or the bot
	_rail(off)
	assert_eq(off.warps, expect, "scenes off")
	assert_has(off.log, ["sfx", "train"])
	assert_eq(off.log.filter(func(e): return e[0] == "journey_in"), [], "nothing to arrive into")

func test_ferry_lands_on_the_same_quay_and_keeps_its_card() -> void:
	var a := Travel.ferry_arrival("liverpool_douglas", "liverpool")
	var expect := [["douglas", a.pos.x, a.pos.y, "down"]]
	var card := str(Travel.ferries().liverpool_douglas.card)
	var hosts := [FakeStoryHost.new(), SceneHost.new(), SceneHost.new()]
	hosts[2].plays = false
	for h in hosts:
		h.zone = "liverpool"
		h.choices = [0]
		Commands.new(h).run([{"do": "ferry", "route": "liverpool_douglas"}])
		assert_eq(h.warps, expect)
		assert_has(h.log, ["music", "ferry"])
	assert_has(hosts[0].texts(), card, "no scene: the card is said")
	assert_false(card in hosts[1].texts(), "a scene shows the card itself")
	var out: Array = hosts[1].log.filter(func(e): return e[0] == "journey_out")
	assert_eq(out[0][2].get("card"), card)
	assert_eq(out[0][2].get("route"), "liverpool_douglas")
	assert_has(hosts[1].log, ["journey_in", "ferry", 1])
	assert_has(hosts[2].texts(), card, "scenes off: the card is said")

func test_declining_the_ferry_plays_nothing() -> void:
	var h := SceneHost.new()
	h.zone = "liverpool"
	h.choices = [1]
	Commands.new(h).run([{"do": "ferry", "route": "liverpool_douglas"}])
	assert_eq(h.warps, [])
	assert_eq(h.log.filter(func(e): return e[0] == "journey_out"), [])

func test_no_rail_pass_or_no_pick_plays_nothing() -> void:
	var h := SceneHost.new()
	h.zone = "macclesfield"
	Commands.new(h).run([{"do": "rail"}])
	assert_eq(h.warps, [])
	h.data.bag["rail_pass"] = 1
	Commands.new(h).run([{"do": "rail"}])  # the menu was closed with nothing picked
	assert_eq(h.warps, [])
	assert_eq(h.log.filter(func(e): return e[0] == "journey_out"), [])

func test_dev_switch_parses() -> void:
	var p := DevArgs.parse(PackedStringArray(["--journey=ferry:douglas", "--journey-at=0.4"]), true)
	assert_eq(p.journey, "ferry:douglas")
	assert_near(p.journey_at, 0.4)
	assert_true(DevArgs.is_dev_session(p, PackedStringArray(["--journey=ferry:douglas"])), "never touches real saves")
	var q := DevArgs.parse(PackedStringArray([]), true)
	assert_eq(q.journey, "")
