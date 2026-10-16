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
var _dark: ColorRect
var traffic: RailTraffic

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
	_dark = ColorRect.new()
	_dark.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dm := ShaderMaterial.new()
	dm.shader = load("res://art/shaders/darkness.gdshader")
	_dark.material = dm
	_dark.visible = false
	layer.add_child(_dark)
	_apply_quality()
	Bus.settings_changed.connect(_apply_quality)

func _apply_quality() -> void:
	_tilt.visible = Settings.quality != "low"
	sky.apply_quality(Settings.quality)
	get_viewport().msaa_3d = Viewport.MSAA_2X if Settings.quality == "high" else Viewport.MSAA_DISABLED

## pos (-1, -1) means the zone's spawn point.
func load_zone(zone_id: String, pos: Vector2i, facing: String) -> void:
	if not Game.zone_exists(zone_id):
		# a save from a zone that no longer exists: back to the last Sanctuary (or Macclesfield)
		push_warning("Overworld: no zone '%s', going to the last Sanctuary" % zone_id)
		var ls: Dictionary = Game.data.last_sanctuary
		zone_id = str(ls.zone) if Game.zone_exists(str(ls.zone)) else "macclesfield"
		pos = Vector2i(int(ls.pos[0]), int(ls.pos[1])) if zone_id == str(ls.zone) else Vector2i(-1, -1)
	zone = ZoneData.load_id(zone_id)
	FieldMoves.apply_cuts(Game.data, zone)
	if _zone_node:
		_zone_node.queue_free()
	_build_zone_node()
	for n in npcs:
		n.queue_free()
	npcs.clear()
	_spawn_npcs()
	if pos.x < 0:
		pos = zone.spawn
	player.place(pos, facing, ground_y(pos))
	if zone.kind == "interior":
		player.set_bike(false)
	player.set_wading(zone.tile_at(pos) == "deep_water")
	Game.data.zone_id = zone_id
	Travel.note_visit(Game.data, zone)
	Game.data.pos = pos
	Game.data.facing = facing
	weather = "clear" if zone.kind == "interior" else Weather.pick(zone.weather, Game.rng)
	if Game.args.get("weather", "") != "":
		weather = Game.args.weather
	sky.set_weather(weather, zone.kind == "interior")
	rig.configure(zone.width, zone.height, zone.kind == "interior")
	if zone.music != "":
		Audio.play_music(zone.music)
	_dark.visible = zone.dark

## Dark caves: keep the light circle on the player (and faint glows on every exit) each frame.
func _process(_delta: float) -> void:
	if _dark == null or not _dark.visible or rig == null or player == null:
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var mat := _dark.material as ShaderMaterial
	var here := cam.unproject_position(player.global_position + Vector3(0, 0.6, 0))
	var r_tiles := FieldMoves.light_radius(Game.data)
	var edge := cam.unproject_position(player.global_position + Vector3(r_tiles, 0.6, 0))
	mat.set_shader_parameter("size", _dark.size)
	mat.set_shader_parameter("centre", here)
	mat.set_shader_parameter("radius", maxf(40.0, here.distance_to(edge)))
	mat.set_shader_parameter("warmth", 1.0 if FieldMoves.has(Game.data, "lantern") else 0.0)
	var lights := []
	for w in zone.warps:
		if lights.size() >= 8:
			break
		var wp := Vector3(int(w.x) + 0.5, ground_y(Vector2i(int(w.x), int(w.y))) + 0.3, int(w.y) + 0.5)
		var sp := cam.unproject_position(wp)
		var sr := sp.distance_to(cam.unproject_position(wp + Vector3(1.2, 0, 0)))
		lights.append(Vector4(sp.x, sp.y, sr, 0.0))
	while lights.size() < 8:
		lights.append(Vector4(-9999, -9999, 0, 0))
	mat.set_shader_parameter("lights", lights)
	mat.set_shader_parameter("light_count", mini(zone.warps.size(), 8))

func ground_y(p: Vector2i) -> float:
	if not zone.in_bounds(p):
		return 0.0
	if zone.tile_at(p) == "deep_water":
		return ZoneBuilder.water_y(zone, p) - 0.08  # wading: float on the surface, coracle just under
	return ZoneBuilder.ground_y(zone, p)

## "ok", "blocked", "edge" (walking off into a neighbour) or "ledge" (hop down).
func can_enter(p: Vector2i, dir: Vector2i) -> String:
	if not zone.in_bounds(p):
		var side := GridMotion.edge_side(p, zone.width, zone.height)
		return "edge" if zone.edges.has(side) else "blocked"
	if zone.tile_at(p) == "ledge_south":
		var landing := p + Vector2i(0, 1)
		return "ledge" if dir == Vector2i(0, 1) and zone.walkable(landing) and not occupied(landing) else "blocked"
	var fv := FieldMoves.verdict(Game.data, zone, p)
	if fv == "blocked":
		return "blocked"
	if fv in ["scramble", "squelch"] and player.on_bike and not occupied(p):
		player.set_bike(false)  # scree is on foot
	if fv == "wade" and player.on_bike and not occupied(p) and zone.walkable(p, dir, FieldMoves.abilities(Game.data)):
		player.set_bike(false)  # hop off and push off in the coracle
	if fv == "cut":
		return "blocked" if occupied(p) else "cut"
	if not zone.walkable(p, dir, FieldMoves.abilities(Game.data)) or occupied(p) or not zone.sign_at(p).is_empty():
		return "blocked"
	if traffic and traffic.closed(p):
		return "blocked"  # the level crossing is shut: a train is coming
	return "ok"

## Hedge-lay: clear the bramble for good and rebuild the scenery.
func cut_bramble(p: Vector2i) -> void:
	FieldMoves.cut(Game.data, zone, p)
	Audio.sfx("cut")
	if _zone_node:
		_zone_node.queue_free()
	_build_zone_node()

## The zone's scenery, plus the trains that run through it.
func _build_zone_node() -> void:
	_zone_node = ZoneBuilder.build(zone)
	add_child(_zone_node)
	traffic = RailTraffic.new()
	traffic.name = "RailTraffic"
	_zone_node.add_child(traffic)
	traffic.setup(zone, _occupied_tiles, float(Game.args.get("train", -1.0)))

## Tiles the player and NPCs stand on or are stepping into (a train waits short of these on a crossing).
func _occupied_tiles() -> Dictionary:
	var out := {}
	if player:
		out[player.grid_pos] = true
		if player.moving:
			out[player.grid_pos + GridMotion.dir_vec(player.facing)] = true
	for n in npcs:
		if is_instance_valid(n):
			out[n.grid_pos] = true
	return out

func toggle_bike() -> void:
	var why := FieldMoves.bike_refusal(Game.data, zone, player.wading)
	if why != "" and not player.on_bike:
		Audio.sfx("bump")
		await say([why])
		return
	player.set_bike(not player.on_bike)
	if player.on_bike:
		Audio.sfx("bike_bell")

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
		# Optional flag gating: "hide_if": flag (absent once set), "show_if": flag (present once set).
		if def.has("hide_if") and Game.data.flag(str(def.hide_if)):
			continue
		if def.has("show_if") and not Game.data.flag(str(def.show_if)):
			continue
		var n: Node3D = npc_script.new()
		add_child(n)
		n.setup(def, self)
		npcs.append(n)

var _friend_steps := 0

func _on_step(p: Vector2i) -> void:
	Game.data.pos = p
	_friend_steps += 1
	if _friend_steps >= 128:  # a long walk together makes friends
		_friend_steps = 0
		for c in Game.data.party:
			c.friendship = mini(255, c.friendship + 1)
	Game.data.facing = player.facing
	if not zone.in_bounds(p):
		_cross_edge(p)
		return
	var w := zone.warp_at(p)
	if not w.is_empty():
		Audio.sfx("door")
		Router.goto_zone(str(w.to), Vector2i(int(w.tx), int(w.ty)), str(w.get("facing", player.facing)))
		return
	if zone.tile_at(p) == "door" and str(zone.building_at(p).get("style", "")) == "station":
		Audio.sfx("door")
		var here := zone
		await ScriptRunner.start(self, [{"do": "rail"}])  # the ticket office
		if not is_inside_tree() or not is_instance_valid(player) or zone != here or player.grid_pos != p:
			return  # took the train (this overworld now shows the town it went to)
		player.try_step("down")  # back out onto the platform
		return
	var tile := zone.tile_at(p)
	stepped.emit(p, tile)
	var was_wading := player.wading
	player.set_wading(tile == "deep_water")
	if player.wading and not was_wading:
		Audio.sfx("splash")
	if tile == "tall_grass":
		Audio.sfx("step_grass")
	elif tile == "scree":
		Audio.sfx("scramble")
	elif tile == "bog":
		Audio.sfx("bog_squelch")
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
	if zone.stage != "":
		return zone.stage
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
	if zone and zone.music != "":
		Audio.play_music(zone.music, 0.4)

func _after_battle(result: Dictionary) -> void:
	if result.get("result") == "lose":
		await ScriptRunner.start(self, [{"do": "whiteout"}])  # one whiteout, shared with trainer battles

func interact(p: Vector2i) -> void:
	var s := zone.sign_at(p)
	if not s.is_empty():
		await say([str(s.text)])
		return
	var n := npc_at(p)
	if n == null and zone.tile_at(p) == "counter":
		n = npc_at(p + GridMotion.dir_vec(player.facing))  # talk across a shop or Sanctuary counter
	if n and n.has_method("interact"):
		await n.interact(player)

func open_pause() -> void:
	Audio.sfx("confirm")
	var r = await Router.open_menu("pause")
	if r is Dictionary and r.has("fly"):  # flight from the map, after the Moot
		var a := Travel.fly_arrival(str(r.fly))
		Audio.sfx("raven_caw")
		player.set_bike(false)
		await Router.goto_zone(str(a.zone), a.pos, "down")

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
