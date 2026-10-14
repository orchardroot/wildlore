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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dex = Dex.load_default()
	moves = MoveDB.load_default()
	chart = TypeChart.load_default()
	if ResourceLoader.exists("res://data_api/item_db.gd"):
		items = load("res://data_api/item_db.gd").load_default()
	args = DevArgs.parse(DevArgs.user_args())
	var seed_value: int = args.seed if args.seed >= 0 else int(Time.get_unix_time_from_system())
	rng = Rng.new(seed_value)
	data.rng_seed = seed_value
	call_deferred("_dev_boot")

func _process(delta: float) -> void:
	data.play_seconds += delta
	if clock_running and not Router.busy:
		_minute_acc += delta
		while _minute_acc >= 1.0:
			_minute_acc -= 1.0
			data.clock_minutes = GameClock.wrap(data.clock_minutes + 1)
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
	data.last_sanctuary = {"zone": start, "pos": [-1, -1]}

func phase() -> String:
	return GameClock.phase(data.clock_minutes)

func save(slot := "auto") -> Error:
	return SaveSystem.save(slot, data.to_dict())

func load_slot(slot := "auto") -> bool:
	var d := SaveSystem.load_slot(slot)
	if d.is_empty() or d.get("_too_new", false):
		return false
	data = GameStateData.from_dict(d, dex)
	return true

func has_save(slot := "auto") -> bool:
	var d := SaveSystem.load_slot(slot)
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
		var foe := [Creature.create(dex.get_species(args.battle_species), args.battle_level, rng, moves)]
		var opts := {"kind": "wild"}
		if args.weather != "":
			opts["weather"] = args.weather
		Router.battle(foe, opts)
	elif args.boot_zone != "":
		new_game()
		if args.clock >= 0:
			data.clock_minutes = args.clock
		data.party = [Creature.create(dex.get_species("kindlet"), 10, rng, moves)]
		Router.goto_zone(args.boot_zone, args.boot_pos, "down")

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
