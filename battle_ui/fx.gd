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

func _actor(side: int) -> CreatureActor:
	return dio.actors[side]

func burst(pos: Vector3, colour: Color, amount := 16, speed := 3.5, size := 0.16, life := 0.6, gravity := -4.0, up := Vector3.UP) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = life
	p.direction = up
	p.spread = 180.0 if up == Vector3.UP else 35.0
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.gravity = Vector3(0, gravity, 0)
	var q := QuadMesh.new()
	q.size = Vector2(size, size)
	if _quad_mat == null:
		_quad_mat = StandardMaterial3D.new()
		_quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_quad_mat.vertex_color_use_as_albedo = true
		_quad_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = _quad_mat
	p.mesh = q
	var g := Gradient.new()
	g.colors = PackedColorArray([colour.lightened(0.35), colour, Color(colour, 0.0)])
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	p.color_ramp = g
	p.emitting = true
	dio.add_child(p)
	p.global_position = pos
	get_tree().create_timer(life + 0.3).timeout.connect(p.queue_free)

func _chest(side: int) -> Vector3:
	return _actor(side).world_centre()

## Plays one cue. `battle` is only used to look up the creature a switch brings in.
func play(cue: Dictionary, battle: Battle) -> void:
	var side := int(cue.get("side", 0))
	match str(cue.cue):
		"attack":
			await _attack(side, str(cue.move_type))
		"hit":
			await _hit(side, int(cue.hp), str(cue.strength))
		"dodge":
			await _actor(side).dodge()
		"shrug":
			await _actor(side).nod()
		"stat_up", "stat_down":
			var up: bool = cue.cue == "stat_up"
			Audio.sfx("stat_up" if up else "stat_down")
			burst(_actor(side).global_position + Vector3(0, 0.3 if up else 2.0, 0), Color("7fe07a") if up else Color("e07a7a"), 14, 2.0, 0.14, 0.9, 1.5 if not up else -1.0, Vector3.UP if up else Vector3.DOWN)
			await _wait(0.55)
		"status":
			var col: Color = STATUS_COLOURS.get(str(cue.status), Color.WHITE)
			burst(_chest(side), col, 18, 2.5, 0.16, 0.8, -1.0)
			hud.set_status(side, str(cue.status))
			await _wait(0.5)
		"cure":
			burst(_chest(side), Color("fff2b0"), 14, 2.5, 0.14, 0.7, -2.0)
			hud.set_status(side, "")
			await _wait(0.4)
		"idle":
			await _actor(side).nod()
		"faint":
			Audio.sfx("faint")
			await _actor(side).faint()
		"switch":
			await _switch(side, battle.parties[side][int(cue.index)])
		"run":
			Audio.sfx("run")
			await _actor(Battle.PLAYER).slip_away()
		"heal":
			Audio.sfx("heal")
			burst(_actor(side).global_position + Vector3(0, 0.2, 0), Color("8fe89a"), 18, 2.2, 0.15, 1.0, 1.0, Vector3.UP)
			await _wait(0.5)
		"catch":
			await _catch(bool(cue.success), int(cue.wobbles))
		"end", "none":
			pass

func _attack(side: int, type_id: String) -> void:
	var other := 1 - side
	dio.swoop_to_attacker(side)
	await _wait(0.4)
	Audio.sfx("attack")
	var col := TypeColours.of(type_id) if type_id != "" else Color("f4ecd8")
	var actor := _actor(side)
	burst(actor.global_position + Vector3(0, 1.0, 0), col, 10, 2.0, 0.14, 0.5, -1.0)
	get_tree().create_timer(0.2).timeout.connect(func(): burst(_chest(other), col, 22, 4.5, 0.2, 0.55))
	await actor.lunge(_actor(other).home)

func _hit(side: int, hp: int, strength: String) -> void:
	Audio.sfx("hit")
	dio.swoop_to_target(side)
	dio.shake = {"strong": 1.0, "normal": 0.55, "weak": 0.25}.get(strength, 0.5)
	var a := _actor(side)
	burst(_chest(side), Color("fff2d0") if strength != "strong" else Color("ffd070"), 12 if strength == "weak" else 24, 4.0, 0.2, 0.4)
	var before := hud.shown_hp(side)
	var frac := absf(before - hp) / maxf(1.0, hud.max_hp(side))
	hud.tween_hp(side, hp, clampf(0.35 + frac * 1.4, 0.35, 1.4))
	await a.hit(strength)
	await _wait(maxf(0.0, clampf(0.35 + frac * 1.4, 0.35, 1.4) - 0.45))

func _switch(side: int, c: Creature) -> void:
	var a := _actor(side)
	if a.sprite.visible:
		await a.pop_out()
	a.show_creature(c, side == Battle.PLAYER)
	hud.set_creature(side, c)
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
