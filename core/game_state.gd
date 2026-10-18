extends Node
## Autoload Game: the current save's data plus the game databases, the clock, saving and dev boot switches.

var data := GameStateData.new()
var dex: Dex
var moves: MoveDB
var chart: TypeChart
var items = null  # ItemDB once data_api/item_db.gd exists
var rng: Rng
var args: Dictionary = {}
var clock_running := false
var save_dir := SaveSystem.DEFAULT_DIR
var autosave_enabled := true
var skip_next_autosave := false  # set by the title: the first zone after New Game or Load must not overwrite "auto"
var _in_battle := false
var _toast: SaveToast

## Emitted after each autosave that really wrote the file (the "Saved" toast listens).
signal autosaved

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dex = Dex.load_default()
	moves = MoveDB.load_default()
	chart = TypeChart.load_default()
	if ResourceLoader.exists("res://data_api/item_db.gd"):
		items = load("res://data_api/item_db.gd").load_default()
	args = DevArgs.parse(DevArgs.user_args())
	Calendar.set_override(str(args.get("date", "")))  # --date=MM-DD or YYYY-MM-DD: screenshot any season, festival or day
	var seed_value: int = args.seed if args.seed >= 0 else int(Time.get_unix_time_from_system())
	rng = Rng.new(seed_value)
	data.rng_seed = seed_value
	if DevArgs.is_dev_session(args, DevArgs.user_args()):
		# screenshots, dev boots and the bot never touch the player's real saves
		autosave_enabled = false
		save_dir = "user://saves_dev"
	Bus.battle_started.connect(_on_battle_started)
	Bus.battle_ended.connect(_on_battle_ended)
	Bus.zone_entered.connect(_on_zone_entered)
	TrainerStats.connect_bus(self)
	Bus.creature_caught.connect(func(_id: String): TodaysWalk.note_catch(data, Forecast.current_weather()))
	if "--quiet-window" in DevArgs.user_args():
		# screenshot runs (tools/shot.sh): never grab focus, sit off-screen, make no sound
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
		DisplayServer.window_set_position(Vector2i(0, -4000))
		AudioServer.set_bus_mute(0, true)
	call_deferred("_dev_boot")

func _process(delta: float) -> void:
	data.play_seconds += delta
	if clock_running and not Router.busy:
		_minute_acc += delta
		while _minute_acc >= 1.0:
			_minute_acc -= 1.0
			data.clock_minutes = GameClock.wrap(data.clock_minutes + 1)
			if data.clock_minutes == 0:
				data.day_count += 1
	if args.get("fps", false):
		_fps_acc += delta
		if _fps_acc >= 1.0:
			_fps_acc = 0.0
			print("FPS %d" % Engine.get_frames_per_second())

var _minute_acc := 0.0
var _fps_acc := 0.0

func new_game() -> void:
	data = GameStateData.new()
	data.rng_seed = rng.roll_int(0, 2147483647)
	if args.clock >= 0:
		data.clock_minutes = args.clock
	var start := _start_zone()
	data.zone_id = start
	data.last_sanctuary = GameStateData.default_sanctuary() if start != "testbed" else {"zone": start, "pos": [-1, -1]}

func phase() -> String:
	return GameClock.phase(data.clock_minutes)

func save(slot := "auto") -> Error:
	return SaveSystem.save(slot, data.to_dict(), save_dir)

## Saves to the "auto" slot unless a battle is running or autosave is off (the playtest bot, tests).
func autosave() -> void:
	if autosave_enabled and not _in_battle:
		save("auto")
		autosaved.emit()
		_show_saved_toast()

func _show_saved_toast() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if _toast == null or not is_instance_valid(_toast):
		_toast = SaveToast.new()
		add_child(_toast)
	_toast.flash()

func _on_battle_started(_kind: String) -> void:
	_in_battle = true

func _on_battle_ended(_result: Dictionary) -> void:
	_in_battle = false

func _on_zone_entered(_zone_id: String) -> void:
	TodaysWalk.today(data, items)  # a new real day picks Today's Walk (behind the zone fade, not mid-walk)
	if skip_next_autosave:
		skip_next_autosave = false
		return
	autosave()

## The slot Continue should load: the newest readable one.
func newest_slot() -> String:
	return SaveSystem.newest_slot(save_dir)

func load_slot(slot := "auto") -> bool:
	var d := SaveSystem.load_slot(slot, save_dir)
	if d.is_empty() or d.get("_too_new", false):
		return false
	data = GameStateData.from_dict(d, dex)
	return true

func has_save(slot := "auto") -> bool:
	var d := SaveSystem.load_slot(slot, save_dir)
	return not d.is_empty() and not d.get("_too_new", false)

func zone_exists(id: String) -> bool:
	return FileAccess.file_exists("res://data/zones/%s.json" % id)

func _start_zone() -> String:
	return "macc_home" if zone_exists("macc_home") else ("macclesfield" if zone_exists("macclesfield") else "testbed")

func _dev_boot() -> void:
	if args.get("playtest", "") != "":
		var bot: Node = load("res://tools/playtest/bot.gd").new()
		get_tree().root.add_child(bot)
		bot.start(args.playtest)
		return
	if args.shot != "":
		_take_shot()
	var dev_menu := DevMenu.arg(DevArgs.user_args())
	if dev_menu != "":
		DevMenu.boot(self, dev_menu)  # --menu=<name>[:arg], see ui/dev_menu.gd
	elif args.battle_species != "":
		new_game()
		var party := [Creature.create(dex.get_species("kindlet"), 10, rng, moves)]
		data.party = party
		for a in DevArgs.user_args():
			if a.begins_with("--held="):  # dev: the lead holds this charm (screenshots of charm messages)
				party[0].held = a.substr(7)
		var foe := [Creature.create(dex.get_species(args.battle_species), args.battle_level, rng, moves)]
		var opts := {"kind": "wild"}
		if args.get("double", false):
			# A double battle: two of ours against the dev twins, with the --battle species leading theirs.
			var twins := StoryData.trainer("dev_double")
			data.party = [party[0], Creature.create(dex.get_species("holtling"), 10, rng, moves), Creature.create(dex.get_species("spikkin"), 9, rng, moves)]
			for m in twins.party.slice(1):
				foe.append(Creature.create(dex.get_species(m.species), args.battle_level, rng, moves))
			opts = {"kind": "trainer", "ai": "trainer", "double": true, "trainer": twins}
		if args.weather != "":
			opts["weather"] = args.weather
		Router.battle(foe, opts)
	elif args.get("journey", "") != "" and args.boot_zone == "":
		DevJourney.show_scene(self, args.journey)  # --journey=<kind>:<town>, see core/dev_journey.gd
	elif args.boot_zone != "":
		new_game()
		if args.clock >= 0:
			data.clock_minutes = args.clock
		data.party = [Creature.create(dex.get_species("kindlet"), 10, rng, moves)]
		for a in DevArgs.user_args():
			if a.begins_with("--flag="):  # dev: story flags set before the zone loads (a postcard waiting, a side story)
				for f in a.substr(7).split(",", false):
					data.set_flag(f, true)
			elif a.begins_with("--badges="):  # dev: this many Stones held
				for i in int(a.substr(9)):
					data.badges.append("dev_%d" % i)
		if args.ride != "":
			data.bag["bike"] = 1
			data.badges = ["brook", "urban", "stone", "iron"] if args.ride == "lantern" else ["brook", "urban", "stone"]
		await Router.goto_zone(args.boot_zone, args.boot_pos, "down")
		if args.ride == "bike":
			Router.overworld.player.set_bike(true)
		if PhotoMode.dev_wanted():
			await get_tree().create_timer(1.5).timeout
			PhotoMode.start(Router.overworld)
		if args.get("journey", "") != "":
			await get_tree().create_timer(1.0).timeout
			await DevJourney.run(self, args.journey)
		if args.get("intro", "") != "":
			await get_tree().create_timer(0.8).timeout
			BattleIntro.dev_show(Router, Router.overworld, str(args.intro), float(args.get("intro_at", 0.5)))

func _take_shot() -> void:
	await get_tree().create_timer(float(args.shot_delay), true, false, true).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path: String = args.shot
	if not path.is_absolute_path():
		path = ProjectSettings.globalize_path("res://").path_join(path)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	img.save_png(path)
	print("shot: ", path)
	get_tree().quit()
