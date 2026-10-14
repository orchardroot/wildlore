class_name BattleFX
extends Node3D
## Plays EventPlayer cues on the diorama and HUD: lunges, hits, particle bursts, camera swoops, the snare throw.

const STATUS_COLOURS := {
	"soaked": Color("5aa7e0"), "chilled": Color("bfeaf5"), "muddled": Color("e08fc0"),
	"hexed": Color("9a6fd0"), "stung": Color("c8d84a"), "asleep": Color("8aa0c8"),
}

var dio: Diorama
var hud: BattleHUD
var _quad_mat: StandardMaterial3D

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func _actor(side: int, pos := 0) -> CreatureActor:
	return dio.actor(side, pos)

## A puff of little billboard sparks thrown out from `pos` (world space), falling under `gravity` and fading.
## Hand-animated quads rather than a particle node, so they always appear exactly where they are aimed.
func burst(pos: Vector3, colour: Color, amount := 16, speed := 3.5, size := 0.16, life := 0.6, gravity := -4.0, up := Vector3.UP) -> void:
	if _quad_mat == null:
		_quad_mat = StandardMaterial3D.new()
		_quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_quad_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		_quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_quad_mat.vertex_color_use_as_albedo = true
		_quad_mat.no_depth_test = true
	var q := QuadMesh.new()
	q.size = Vector2(size, size)
	var rng := RandomNumberGenerator.new()
	var cone := 1.0 if up == Vector3.UP else 0.35
	for i in amount:
		var m := MeshInstance3D.new()
		m.mesh = q
		var mat: StandardMaterial3D = _quad_mat.duplicate()
		mat.albedo_color = colour.lightened(rng.randf_range(0.0, 0.35))
		m.material_override = mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dio.add_child(m)
		m.global_position = pos
		var dir := (up + Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * cone).normalized()
		var vel := dir * rng.randf_range(speed * 0.5, speed)
		var tw := m.create_tween()
		tw.tween_method(func(t: float):
			if is_instance_valid(m):
				m.global_position = pos + vel * t + Vector3(0, 0.5 * gravity * t * t, 0)
				mat.albedo_color.a = 1.0 - t / life, 0.0, life, life)
		tw.tween_callback(m.queue_free)

func _chest(side: int, pos := 0) -> Vector3:
	return _actor(side, pos).world_centre()

## Plays one cue. `battle` is only used to look up the creature a switch brings in (and, in doubles, where an
## item's target stands). Double-battle cues carry "pos" (and attacks "target_side" / "target_pos" / "spread").
func play(cue: Dictionary, battle: Battle) -> void:
	var side := int(cue.get("side", 0))
	var pos := int(cue.get("pos", 0))
	match str(cue.cue):
		"attack":
			await _attack(side, str(cue.move_type), pos, int(cue.get("target_side", 1 - side)), int(cue.get("target_pos", 0)), bool(cue.get("spread", false)))
		"hit":
			await _hit(side, int(cue.hp), str(cue.strength), pos)
		"dodge":
			await _actor(side, pos).dodge()
		"shrug":
			await _actor(side, pos).nod()
		"stat_up", "stat_down":
			var up: bool = cue.cue == "stat_up"
			Audio.sfx("stat_up" if up else "stat_down")
			burst(_actor(side, pos).global_position + Vector3(0, 0.3 if up else 2.0, 0), Color("7fe07a") if up else Color("e07a7a"), 14, 2.0, 0.14, 0.9, 1.5 if not up else -1.0, Vector3.UP if up else Vector3.DOWN)
			await _wait(0.55)
		"status":
			var col: Color = STATUS_COLOURS.get(str(cue.status), Color.WHITE)
			burst(_chest(side, pos), col, 18, 2.5, 0.16, 0.8, -1.0)
			hud.set_status(side, str(cue.status), pos)
			await _wait(0.5)
		"cure":
			burst(_chest(side, pos), Color("fff2b0"), 14, 2.5, 0.14, 0.7, -2.0)
			hud.set_status(side, "", pos)
			await _wait(0.4)
		"idle":
			await _actor(side, pos).nod()
		"faint":
			Audio.sfx("faint")
			await _actor(side, pos).faint()
		"switch":
			await _switch(side, battle.parties[side][int(cue.index)], pos)
		"run":
			Audio.sfx("run")
			await _actor(Battle.PLAYER).slip_away()
		"heal":
			Audio.sfx("heal")
			var at := 0
			if battle.double:
				at = maxi(0, battle.active[side].find(int(cue.get("target", 0))))
			burst(_actor(side, at).global_position + Vector3(0, 0.2, 0), Color("8fe89a"), 18, 2.2, 0.15, 1.0, 1.0, Vector3.UP)
			await _wait(0.5)
		"catch":
			await _catch(bool(cue.success), int(cue.wobbles))
		"end", "none":
			pass

func _attack(side: int, type_id: String, pos := 0, t_side := -1, t_pos := 0, spread := false) -> void:
	var other := 1 - side if t_side < 0 else t_side
	dio.swoop_to_attacker(side, pos, t_pos)
	await _wait(0.4)
	Audio.sfx("attack")
	var col := TypeColours.of(type_id) if type_id != "" else Color("f4ecd8")
	var actor := _actor(side, pos)
	burst(actor.global_position + Vector3(0, 1.0, 0), col, 10, 2.0, 0.14, 0.5, -1.0)
	var hit_pos := [0, 1] if spread else [t_pos]
	get_tree().create_timer(0.2).timeout.connect(func():
		for p in hit_pos:
			burst(_chest(other, p), col, 22, 4.5, 0.2, 0.55))
	var aim := _actor(other, t_pos).home
	if spread:
		aim = _actor(other, 0).home.lerp(_actor(other, 1).home, 0.5)
	await actor.lunge(aim)

func _hit(side: int, hp: int, strength: String, pos := 0) -> void:
	Audio.sfx("hit")
	dio.swoop_to_target(side, pos)
	dio.shake = {"strong": 1.0, "normal": 0.55, "weak": 0.25}.get(strength, 0.5)
	var a := _actor(side, pos)
	burst(_chest(side, pos), Color("fff2d0") if strength != "strong" else Color("ffd070"), 12 if strength == "weak" else 24, 4.0, 0.2, 0.4)
	var before := hud.shown_hp(side, pos)
	var frac := absf(before - hp) / maxf(1.0, hud.max_hp(side, pos))
	hud.tween_hp(side, hp, clampf(0.35 + frac * 1.4, 0.35, 1.4), pos)
	await a.hit(strength)
	await _wait(maxf(0.0, clampf(0.35 + frac * 1.4, 0.35, 1.4) - 0.45))

func _switch(side: int, c: Creature, pos := 0) -> void:
	var a := _actor(side, pos)
	if a.sprite.visible:
		await a.pop_out()
	a.show_creature(c, side == Battle.PLAYER)
	hud.set_creature(side, c, pos)
	Audio.sfx("send_out")
	burst(a.global_position + Vector3(0, 1.0, 0), Color("fff2d0"), 20, 3.0, 0.16, 0.6, -1.0)
	await a.pop_in()

func _snare_mesh() -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = 0.24
	s.height = 0.48
	s.radial_segments = 8
	s.rings = 4
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("b88b4a")
	m.roughness = 1.0
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var mi := MeshInstance3D.new()
	mi.mesh = s
	mi.material_override = m
	var band := MeshInstance3D.new()
	var bm := TorusMesh.new()
	bm.inner_radius = 0.2
	bm.outer_radius = 0.27
	bm.rings = 10
	bm.ring_segments = 5
	band.mesh = bm
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color("6b4a32")
	band.material_override = bmat
	mi.add_child(band)
	return mi

func _catch(success: bool, wobbles: int) -> void:
	var foe := _actor(Battle.FOE)
	var me := _actor(Battle.PLAYER)
	var snare := _snare_mesh()
	dio.add_child(snare)
	var start := me.global_position + Vector3(0.6, 1.2, 0.2)
	var end := foe.world_centre()
	snare.position = start
	dio.swoop_to_target(Battle.FOE)
	Audio.sfx("throw")
	var arc := create_tween()
	arc.tween_method(func(t: float):
		snare.position = start.lerp(end, t) + Vector3(0, sin(t * PI) * 2.0, 0)
		snare.rotation.z = t * TAU * 2.0, 0.0, 1.0, 0.7)
	await arc.finished
	burst(end, Color("fff2d0"), 14, 3.0, 0.16, 0.5, -1.0)
	foe.absorb(true)
	var ground := foe.global_position + Vector3(0, 0.26, 0)
	var drop := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	drop.tween_property(snare, "position", ground, 0.55)
	await drop.finished
	await _wait(0.25)
	for i in wobbles:
		Audio.sfx("wobble")
		var w := create_tween()
		w.tween_property(snare, "rotation:z", 0.5, 0.14).set_trans(Tween.TRANS_SINE)
		w.tween_property(snare, "rotation:z", -0.5, 0.28).set_trans(Tween.TRANS_SINE)
		w.tween_property(snare, "rotation:z", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
		await w.finished
		await _wait(0.4)
	if success:
		Audio.sfx("caught")
		burst(ground + Vector3(0, 0.3, 0), Color("ffd870"), 30, 4.0, 0.2, 0.9, -3.0)
		foe.sprite.visible = false
		foe.shadow.visible = false
		var dim := create_tween()
		dim.tween_property(snare, "scale", Vector3(1.15, 0.85, 1.15), 0.12)
		dim.tween_property(snare, "scale", Vector3.ONE, 0.15)
		await dim.finished
		await _wait(0.5)
		var away := create_tween()
		away.tween_property(snare, "scale", Vector3.ONE * 0.01, 0.3)
		await away.finished
	else:
		Audio.sfx("broke_free")
		burst(ground + Vector3(0, 0.3, 0), Color("ffffff"), 22, 4.0, 0.18, 0.5, -2.0)
		snare.visible = false
		await foe.absorb(false)
	snare.queue_free()
