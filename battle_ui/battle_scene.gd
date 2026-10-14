extends Node3D
## The battle scene. Router.battle() instantiates this, calls setup(foe_party, opts) and awaits `finished`.
## All sequencing lives in BattleFlow; this node is its `ui`: it plays events on the diorama and asks for choices.
## opts: kind ("wild"|"trainer"|"keeper"), stage, weather, ai, trainer {name, money, defeat}, music.
## Dev: pass --battle-auto after `--` and the battle plays itself (for screenshots).

signal finished(result: Dictionary)

var dio: Diorama
var sky: SkyAndLight
var hud: BattleHUD
var menus: BattleMenus
var msg: BattleMessage
var fx: BattleFX
var flow: BattleFlow
var auto := false
var opts := {}
var _intro_done := false
var _hidden_2d: CanvasItem
var _dev_stage := ""  # --stage=moor overrides the stage (screenshots)
var _dev_menu := ""  # --battle-menu=fight|bag|team opens that menu straight away (screenshots)

func _ready() -> void:
	auto = "--battle-auto" in OS.get_cmdline_user_args()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--stage="):
			_dev_stage = a.get_slice("=", 1)
		if a.begins_with("--battle-menu="):
			_dev_menu = a.get_slice("=", 1)
	Meshes.materials()
	dio = Diorama.new()
	add_child(dio)
	sky = SkyAndLight.new()
	add_child(sky)
	fx = BattleFX.new()
	add_child(fx)
	fx.dio = dio
	var post := CanvasLayer.new()
	post.layer = 1
	add_child(post)
	var tilt := ColorRect.new()
	tilt.set_anchors_preset(Control.PRESET_FULL_RECT)
	tilt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://art/shaders/tilt_shift.gdshader")
	tilt.material = mat
	tilt.visible = Settings.quality != "low"
	post.add_child(tilt)
	var ui := CanvasLayer.new()
	ui.layer = 2
	add_child(ui)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = load("res://ui/theme.tres")
	ui.add_child(root)
	hud = BattleHUD.new()
	root.add_child(hud)
	fx.hud = hud
	msg = BattleMessage.new()
	root.add_child(msg)
	menus = BattleMenus.new()
	root.add_child(menus)

func _exit_tree() -> void:
	if _hidden_2d and is_instance_valid(_hidden_2d):
		_hidden_2d.show()

func setup(foe_party: Array, p_opts: Dictionary) -> void:
	# Started from a 2D screen (the title, via --battle): hide it. The overworld is hidden by Router.
	var cs := get_tree().current_scene
	if cs is CanvasItem and cs != self:
		_hidden_2d = cs
		cs.hide()
	opts = p_opts.duplicate()
	opts["time"] = opts.get("time", GameClock.phase(Game.data.clock_minutes))
	dio.build(_dev_stage if _dev_stage != "" else str(opts.get("stage", "grass")))
	sky.set_weather(str(opts.get("weather", "clear")), dio.is_interior())
	sky.follow = dio
	dio.camera.environment = sky.env
	flow = BattleFlow.new(Game.data, Game.dex, Game.moves, Game.chart, Game.items, Game.rng, foe_party, opts, self)
	flow.species_caught.connect(func(id: String): Bus.creature_caught.emit(id))
	_run()

func _run() -> void:
	var result: Dictionary = await flow.run()
	await get_tree().create_timer(0.35).timeout
	finished.emit(result)

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

# --- the flow's ui interface --------------------------------------------------------

func intro(f: BattleFlow) -> void:
	Audio.play_music(str(opts.get("music", "battle")))
	dio.intro_swoop()
	var foe := f.battle.current(Battle.FOE)
	var me := f.battle.current(Battle.PLAYER)
	if foe != null:
		dio.actors[Battle.FOE].show_creature(foe, false)
		hud.set_creature(Battle.FOE, foe)
		dio.actors[Battle.FOE].pop_in()
	await _wait(0.7)
	if me != null:
		dio.actors[Battle.PLAYER].show_creature(me, true)
		hud.set_creature(Battle.PLAYER, me)
		dio.actors[Battle.PLAYER].pop_in()
	await _wait(0.9)
	_intro_done = true

func say(lines: Array, hold := 0.0) -> void:
	hud.plates[Battle.PLAYER].refresh_names()
	for l in lines:
		await msg.say(str(l), hold)

func play_events(events: Array, ctx: Dictionary) -> void:
	var b: Battle = ctx.battle
	for ev in events:
		var cue := EventPlayer.fx_for(ev, ctx)
		var lines := EventPlayer.lines_for(ev, ctx)
		if ev.type == "item" and int(ev.get("target", 0)) == b.active[Battle.PLAYER]:
			hud.tween_hp(Battle.PLAYER, int(ev.get("shown_hp", b.current(Battle.PLAYER).hp)), 0.7)
		if ev.type == "catch" and cue.cue == "catch" and lines.size() > 1:
			await msg.say(lines[0])
			await fx.play(cue, b)
			for i in range(1, lines.size()):
				await msg.say(lines[i])
			continue
		var flag := [true]
		_cue_task(cue, b, flag)
		for l in lines:
			await msg.say(l)
		while flag[0]:
			await get_tree().process_frame
	_sync_hud(b)
	if not b.over:
		dio.swoop_home()

func _cue_task(cue: Dictionary, b: Battle, flag: Array) -> void:
	await fx.play(cue, b)
	flag[0] = false

## Make the plates match the creatures, in case an event batch left them slightly off (item cures, caught foes...).
func _sync_hud(b: Battle) -> void:
	for side in 2:
		var c := b.current(side)
		if c == null:
			continue
		hud.set_status(side, c.status)
		if absf(hud.shown_hp(side) - c.hp) > 0.5 and not (side == Battle.FOE and b.caught != null):
			hud.tween_hp(side, c.hp, 0.25)

func choose_action(f: BattleFlow) -> Dictionary:
	var b := f.battle
	var me := b.current(Battle.PLAYER)
	while true:
		msg.prompt("What will %s do?" % me.display_name())
		if auto:
			await _wait(0.9)
			var best := 0
			var power := -1
			for i in me.moves.size():
				var p := int(Game.moves.get_move(me.moves[i].id).get("power", 0))
				if p > power and int(me.moves[i].pp) > 0:
					power = p
					best = i
			return {"kind": "fight", "slot": best}
		var cmd := ""
		if _dev_menu != "":
			cmd = _dev_menu
			_dev_menu = ""
			if Game.data.bag.is_empty():
				Game.data.bag.merge({"cup_of_tea": 3, "wicker_snare": 5, "smelling_salts": 1})
			if Game.data.party.size() < 3:
				Game.data.party.append(Creature.create(Game.dex.get_species("holtling"), 8, Game.rng, Game.moves))
				Game.data.party[1].take_damage(9)
				Game.data.party.append(Creature.create(Game.dex.get_species("spikkin"), 6, Game.rng, Game.moves))
				Game.data.party[2].hp = 0
		else:
			cmd = await menus.command(f.is_wild())
		match cmd:
			"fight":
				var slot := await menus.moves(me, Game.moves)
				if slot >= 0:
					return {"kind": "fight", "slot": slot}
			"bag":
				var entries := f.battle_items()
				if entries.is_empty():
					await msg.say("Nothing in your bag is any use in a scrap.")
					continue
				var i := await menus.bag(entries)
				if i < 0:
					continue
				var e: Dictionary = entries[i]
				if e.kind == "snare":
					return {"kind": "item", "item": e.id}
				var t := await menus.party(b.parties[Battle.PLAYER], b.active[Battle.PLAYER], "item", Game.items.get_item(e.id))
				if t >= 0:
					return {"kind": "item", "item": e.id, "target": t}
			"team":
				var s := await menus.party(b.parties[Battle.PLAYER], b.active[Battle.PLAYER], "switch")
				if s >= 0:
					return {"kind": "switch", "index": s}
			"run":
				return {"kind": "run"}
	return {}

func choose_replacement(f: BattleFlow) -> int:
	var b := f.battle
	var party: Array = b.parties[Battle.PLAYER]
	if auto:
		for i in party.size():
			if not party[i].is_fainted():
				return i
	msg.prompt("Who will you send out next?")
	var r := -1
	while r < 0:
		r = await menus.party(party, b.active[Battle.PLAYER], "forced")
	return r

func choose_forget(c: Creature, move_id: String, _f: BattleFlow) -> int:
	if auto:
		return -1
	msg.prompt("%s is trying to learn a new move." % c.display_name())
	return await menus.forget(c, move_id, Game.moves)

func xp_gained(c: Creature, evs: Array) -> void:
	Audio.sfx("xp")
	await hud.animate_xp(c, evs)
	if evs.any(func(e): return e.type == "level_up"):
		Audio.sfx("level_up")
		var a: CreatureActor = dio.actors[Battle.PLAYER]
		fx.burst(a.global_position + Vector3(0, 0.4, 0), Color("ffe08a"), 28, 3.5, 0.18, 1.0, 1.0, Vector3.UP)

## The evolution sequence: the sprite flickers between old and new, faster and faster. Cancel stops it.
func evolve_anim(c: Creature, to_sp: Dictionary) -> bool:
	var a: CreatureActor = dio.actors[Battle.PLAYER]
	var active := flow.battle.current(Battle.PLAYER)
	var old_tex := CreatureArt.texture(c.species, true)
	var new_tex := CreatureArt.texture(to_sp, true)
	a.show_creature(c, true)
	dio.swoop(a.global_position + Vector3(0, 1.1, 0), 6.5, -0.2, 14.0, 0.6)
	Audio.sfx("evolve")
	var cancelled := false
	var delay := 0.32
	for i in 14:
		a.sprite.texture = new_tex if i % 2 == 0 else old_tex
		a.sprite.modulate = Color(3.2, 3.2, 3.6) if i % 2 == 0 else Color(1.12, 1.12, 1.12)
		fx.burst(a.global_position + Vector3(0, 1.1, 0), Color("fff6c0"), 6, 2.0, 0.12, 0.5, 0.5)
		await _wait(delay)
		delay = maxf(0.07, delay * 0.82)
		if not auto and (Input.is_action_pressed("cancel") or Input.is_action_pressed("ui_cancel")):
			cancelled = true
			break
	if cancelled:
		a.show_creature(active, true)
		dio.swoop_home()
		return false
	a.sprite.texture = new_tex
	a.sprite.modulate = Color(3.2, 3.2, 3.6)
	fx.burst(a.global_position + Vector3(0, 1.1, 0), Color("ffe9a0"), 40, 5.0, 0.2, 1.0, -2.0)
	create_tween().tween_property(a.sprite, "modulate", Color(1.12, 1.12, 1.12), 0.5)
	await _wait(0.6)
	if c != active:
		a.show_creature(active, true)
	dio.swoop_home()
	return true
