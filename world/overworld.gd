extends Node3D
## Hosts one zone at a time: builds it, places the player and NPCs, handles steps, warps, edges,
## signs, interaction, wild encounters, weather and the HD-2D look.

signal stepped(p: Vector2i, tile: String)

var zone: ZoneData
var player: Player
var rig: CameraRig
var sky: SkyAndLight
var weather := "clear"
var encounters := Encounters.new()
var npcs: Array = []
var _zone_node: Node3D
var _tilt: ColorRect

func _ready() -> void:
	sky = SkyAndLight.new()
	add_child(sky)
	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.setup(self, Game.data.flags.get("player_sprite", "player_a"))
	player.step_finished.connect(_on_step)
	rig = CameraRig.new()
	add_child(rig)
	rig.target = player
	sky.follow = player
	var layer := CanvasLayer.new()
	layer.layer = 1
	add_child(layer)
	_tilt = ColorRect.new()
	_tilt.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tilt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://art/shaders/tilt_shift.gdshader")
	_tilt.material = mat
	layer.add_child(_tilt)
	_apply_quality()
	Bus.settings_changed.connect(_apply_quality)

func _apply_quality() -> void:
	_tilt.visible = Settings.quality != "low"

## pos (-1, -1) means the zone's spawn point.
func load_zone(zone_id: String, pos: Vector2i, facing: String) -> void:
	if not Game.zone_exists(zone_id):
		push_error("Overworld: no zone '%s'" % zone_id)
		zone_id = "testbed"
	zone = ZoneData.load_id(zone_id)
	if _zone_node:
		_zone_node.queue_free()
	_zone_node = ZoneBuilder.build(zone)
	add_child(_zone_node)
	for n in npcs:
		n.queue_free()
	npcs.clear()
	_spawn_npcs()
	if pos.x < 0:
		pos = zone.spawn
	player.place(pos, facing, ground_y(pos))
	Game.data.zone_id = zone_id
	Game.data.pos = pos
	Game.data.facing = facing
	weather = "clear" if zone.kind == "interior" else Weather.pick(zone.weather, Game.rng)
	if Game.args.get("weather", "") != "":
		weather = Game.args.weather
	sky.set_weather(weather, zone.kind == "interior")
	rig.configure(zone.width, zone.height, zone.kind == "interior")
	if zone.music != "":
		Audio.play_music(zone.music)

func ground_y(p: Vector2i) -> float:
	return ZoneBuilder.ground_y(zone, p) if zone.in_bounds(p) else 0.0

## "ok", "blocked", "edge" (walking off into a neighbour) or "ledge" (hop down).
func can_enter(p: Vector2i, dir: Vector2i) -> String:
	if not zone.in_bounds(p):
		var side := GridMotion.edge_side(p, zone.width, zone.height)
		return "edge" if zone.edges.has(side) else "blocked"
	if zone.tile_at(p) == "ledge_south":
		var landing := p + Vector2i(0, 1)
		return "ledge" if dir == Vector2i(0, 1) and zone.walkable(landing) and not occupied(landing) else "blocked"
	if not zone.walkable(p, dir) or occupied(p) or not zone.sign_at(p).is_empty():
		return "blocked"
	return "ok"

func occupied(p: Vector2i) -> bool:
	return npc_at(p) != null

func npc_at(p: Vector2i) -> Node:
	for n in npcs:
		if is_instance_valid(n) and n.grid_pos == p:
			return n
	return null

func _spawn_npcs() -> void:
	if not ResourceLoader.exists("res://world/npc.gd"):
		return
	var npc_script: Script = load("res://world/npc.gd")
	for def in zone.npcs:
		var n: Node3D = npc_script.new()
		add_child(n)
		n.setup(def, self)
		npcs.append(n)

func _on_step(p: Vector2i) -> void:
	Game.data.pos = p
	Game.data.facing = player.facing
	if not zone.in_bounds(p):
		_cross_edge(p)
		return
	var w := zone.warp_at(p)
	if not w.is_empty():
		Audio.sfx("door")
		Router.goto_zone(str(w.to), Vector2i(int(w.tx), int(w.ty)), str(w.get("facing", player.facing)))
		return
	var tile := zone.tile_at(p)
	stepped.emit(p, tile)
	if tile == "tall_grass":
		Audio.sfx("step_grass")
	_check_trainers()
	if Router.busy:
		return
	if encounters.in_grace():
		encounters.stepped()
		return
	var enc := Encounters.roll(zone, tile, Game.phase(), weather, Game.rng)
	if not enc.is_empty() and Game.data.first_able() != null:
		var foe := Creature.create(Game.dex.get_species(enc.species), enc.level, Game.rng, Game.moves)
		Game.data.mark_seen(enc.species)
		var result: Dictionary = await Router.battle([foe], {"kind": "wild", "weather": weather, "time": Game.phase(), "stage": _stage()})
		_after_battle(result)

func _cross_edge(p: Vector2i) -> void:
	var side := GridMotion.edge_side(p, zone.width, zone.height)
	var target_id: String = zone.edges[side].get("to", "")
	var target := ZoneData.load_id(target_id)
	var back := p - GridMotion.dir_vec(player.facing)
	var arrival := zone.edge_arrival(side, back, target)
	Router.goto_zone(target_id, arrival, player.facing)

func _check_trainers() -> void:
	for n in npcs:
		if is_instance_valid(n) and n.has_method("check_sight"):
			if n.check_sight(player.grid_pos):
				return

func _stage() -> String:
	if zone.kind == "interior":
		return "spa_interior" if zone.id.contains("spa") else "town"
	if zone.region == "peak" or zone.id.contains("fiddle"):
		return "moor"
	if zone.id.contains("forest"):
		return "forest"
	return "grass" if zone.kind == "route" else "town"

## Called by Router after any battle that ran over this overworld.
func on_battle_finished(result: Dictionary) -> void:
	encounters.after_battle()

func _after_battle(result: Dictionary) -> void:
	if result.get("result") == "lose":
		await whiteout()

## Lost a battle: back to the last Sanctuary, healed, a bit poorer.
func whiteout() -> void:
	Game.data.money = Game.data.money / 2
	Game.data.heal_party()
	var ls: Dictionary = Game.data.last_sanctuary
	var pos := Vector2i(int(ls.pos[0]), int(ls.pos[1]))
	await Router.goto_zone(str(ls.zone), pos, "down")
	await say(["You hurry back to safety, a little dazed.", "Your team is patched up and ready to go again."])

func interact(p: Vector2i) -> void:
	var s := zone.sign_at(p)
	if not s.is_empty():
		await say([str(s.text)])
		return
	var n := npc_at(p)
	if n and n.has_method("interact"):
		await n.interact(player)

func open_pause() -> void:
	Audio.sfx("confirm")
	await Router.open_menu("pause")

## Shows lines in the dialogue box (or prints them if the UI isn't there yet).
func say(lines: Array, who := "") -> void:
	if not ResourceLoader.exists("res://ui/dialogue_box.tscn"):
		for l in lines:
			print("SAY: ", l)
		return
	var was := Router.busy
	Router.busy = true
	var box: Node = load("res://ui/dialogue_box.tscn").instantiate()
	add_child(box)
	for l in lines:
		await box.show_text(str(l), who)
	box.queue_free()
	Router.busy = was
