class_name RailTraffic
extends Node3D
## The occasional passing train. Every 40-90 s one runs along a line that is open at both ends (map edge or
## tunnel, calling at the station if it passes one), or comes in to a buffer stop, waits and goes back out.
## Level crossings shut while a train is near (can_enter asks `closed`), and a train waits short of a crossing
## somebody is standing on, so nobody is ever run over or boxed in. Otherwise it is scenery, and sound:
## a rumble that swells as it nears and a rush as it passes, the two-tone alarm while a crossing is shut, and a
## brake squeal coming into a platform, all fading with distance from the camera's focus (the player).

const SPEED := 6.0          # tiles per second at line speed (the player walks at 4)
const ACCEL := 2.5          # tiles per second squared, speeding up and braking
const CAR_LEN := 1.54       # one car, buffer to buffer
const CAR_GAP := 0.1
const CARS := 3
const DWELL := 7.0          # seconds standing at a platform or the buffers
const WAIT := Vector2(40.0, 90.0)
const FIRST_WAIT := Vector2(8.0, 45.0)
const CLOSE_AHEAD := 10.0   # a crossing shuts this many tiles before the train reaches it
const HOLD_SHORT := 0.9     # how far short of an occupied crossing a train stops
const LIVERIES := [Color("4150a8"), Color("a3262a"), Color("2f6b4a"), Color("3b6fa8"), Color("6a3f8f")]
const DIRS := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const HEAR_NEAR := 3.0      # full volume within this many tiles
const HEAR_RANGE := 36.0    # silent beyond this
const RUSH_AT := 9.0        # the rush of it going by, when it first comes this close at speed
const PLATFORM_REACH := 3.5 # a train standing with its middle this close to the station tile is "at the platform"

var zone: ZoneData
var routes: Array = []
var rng := RandomNumberGenerator.new()
## Returns the tiles people stand on or are stepping into ({Vector2i: true}). Set by setup (or a test).
var occupied_fn: Callable = func() -> Dictionary: return {}
var timer := 0.0
var run: Dictionary = {}    # the train on the line now, {} when none
var _closed := {}
var _cars: Array = []
var _mat: ShaderMaterial
## Things the sound should play this frame ("brake"); tick queues them, _process plays and clears them.
var sound_events: Array = []
var _snd: AudioStreamPlayer
var _rumble := -1
var _alarm := -1
var _rushed := false

## `first_wait` < 0 picks a random first wait (the --train=<seconds> dev switch sets it for screenshots).
func setup(z: ZoneData, occupied: Callable, first_wait := -1.0) -> void:
	zone = z
	occupied_fn = occupied
	rng.seed = hash(z.id) ^ int(Time.get_ticks_usec())  # its own dice: the game's rng stays deterministic
	routes = RailTraffic.find_routes(z)
	timer = first_wait if first_wait >= 0.0 else rng.randf_range(FIRST_WAIT.x, FIRST_WAIT.y)
	set_process(not routes.is_empty())

## Is the level crossing at p shut (a train is near)?
func closed(p: Vector2i) -> bool:
	return _closed.has(p)

func _process(delta: float) -> void:
	tick(minf(delta, 0.1))
	if _mat:
		_mat.set_shader_parameter("glow", Meshes.glow.emission_energy_multiplier if Meshes.glow else 0.0)
	_sound()

## Advances the timetable by `delta` seconds (tests drive this directly).
func tick(delta: float) -> void:
	if routes.is_empty():
		return
	if run.is_empty():
		timer -= delta
		if timer <= 0.0:
			start(routes[rng.randi() % routes.size()], rng.randf() < 0.5)
		return
	_move(delta)
	_update_closed()
	if run.done:
		run = {}
		_closed.clear()
		timer = rng.randf_range(WAIT.x, WAIT.y)
	_place_cars()

## Starts a train on `route` (through routes can run either way; `flip` runs it backwards). `call` makes a
## train in to a terminus call at the station on the way too (the one you catch, or step off).
func start(route: Dictionary, flip := false, call_here := false) -> void:
	var path: Array = route.path.duplicate()
	var entry: Dictionary = route.from
	var exit: Dictionary = route.to
	if flip and route.kind == "through":
		path.reverse()
		entry = route.to
		exit = route.from
	var n := path.size()
	var length := train_length()
	var stops := []  # [s of the train's front, kind]
	if route.kind == "terminus":
		var ci := RailTraffic.call_index(zone, path) if call_here else -1
		if ci >= 0:
			stops.append([clampf(ci + length * 0.5, length - 0.5, n - 1.5), "platform"])
		stops.append([RailTraffic.buffers_stop(zone, path), "buffers"])
	else:
		var call := RailTraffic.call_index(zone, path)
		if call >= 0:
			stops.append([clampf(call + length * 0.5, length - 0.5, n - 0.6), "platform"])
	var crossings := []
	for i in n:
		if zone.tile_at(path[i]) == "level_crossing":
			crossings.append(i)
	run = {"path": path, "kind": route.kind, "head": -1.5, "v": 0.0, "sign": 1.0, "stops": stops,
		"crossings": crossings, "dwell": 0.0, "done": false, "length": length}
	_ensure_cars()
	var clip := RailTraffic.clip_rect(zone, path, entry, exit)
	_mat.set_shader_parameter("clip_min", clip[0])
	_mat.set_shader_parameter("clip_max", clip[1])
	run.v = SPEED  # it comes in at line speed (braking for anything close by)
	_place_cars()

## Where the front of a train stops coming in to the buffers at the end of `path`.
static func buffers_stop(z: ZoneData, path: Array) -> float:
	var n := path.size()
	var on_end: bool = z.rail_cap_at(path[n - 1]).get("type", "") == "buffer_stop"
	return (n - 1) - 0.2 if on_end else n - 0.2

# --- the train you catch (travel scenes, see Journey) ----------------------------------------------------------

## Sends in a train for the player to board: one that calls at the station, already `lead` tiles short of
## its stop so it pulls in within a few seconds. A train already standing there just waits a little longer.
## False when no train stops here (no line, or none by the platform).
func call_at_station(lead := 9.0) -> bool:
	if at_platform():
		run.dwell = maxf(run.dwell, 2.0)
		return true
	var runs := RailTraffic.platform_runs(zone, routes)
	if runs.is_empty():
		return false
	var pick: Dictionary = runs[rng.randi() % runs.size()]
	start(pick.route, pick.flip, pick.get("call", false))
	run.head = maxf(run.head, float(run.stops[0][0]) - lead)
	_update_closed()
	_place_cars()
	return true

## Arriving by train: one already standing at the platform, as if it had just pulled in. It leaves after its
## usual wait. False when no train stops here.
func stand_at_station() -> bool:
	var runs := RailTraffic.platform_runs(zone, routes)
	if runs.is_empty():
		return false
	var pick: Dictionary = runs[rng.randi() % runs.size()]
	start(pick.route, pick.flip, pick.get("call", false))
	run.head = float(run.stops[0][0])
	run.v = 0.0
	run.dwell = DWELL
	run.stops.remove_at(0)
	_update_closed()
	_place_cars()
	return true

## Is a train standing by the station platform now?
func at_platform() -> bool:
	if zone == null or run.is_empty() or run.done or run.dwell <= 0.0 or zone.station == Vector2i(-1, -1):
		return false
	var mid := RailTraffic.point_at(run.path, run.head - run.length * 0.5)
	return mid.distance_to(Vector2(zone.station) + Vector2(0.5, 0.5)) <= PLATFORM_REACH

## Where on the line the middle of the standing train is (world x/z), for the player to walk to.
func train_middle() -> Vector2:
	if run.is_empty():
		return Vector2(zone.station) + Vector2(0.5, 0.5)
	return RailTraffic.point_at(run.path, run.head - run.length * 0.5)

## The runs that stop by the station platform: [{"route", "flip", "call"}]. Through trains calling there (either
## way), trains in to a terminus whose buffers are by the platform, or calling at it on the way to the buffers.
static func platform_runs(z: ZoneData, all_routes: Array) -> Array:
	var out := []
	if z.station == Vector2i(-1, -1):
		return out
	var stn := Vector2(z.station) + Vector2(0.5, 0.5)
	for r in all_routes:
		if r.kind == "through":
			if RailTraffic.call_index(z, r.path) >= 0:
				out.append({"route": r, "flip": false})
				var back: Array = r.path.duplicate()
				back.reverse()
				if RailTraffic.call_index(z, back) >= 0:
					out.append({"route": r, "flip": true})
		elif RailTraffic.point_at(r.path, buffers_stop(z, r.path) - train_length() * 0.5).distance_to(stn) <= PLATFORM_REACH:
			out.append({"route": r, "flip": false})
		elif RailTraffic.call_index(z, r.path) >= 0:
			out.append({"route": r, "flip": false, "call": true})  # the platform is part way along
	return out

static func platform_run(z: ZoneData, all_routes: Array) -> Dictionary:
	var runs := platform_runs(z, all_routes)
	return {} if runs.is_empty() else runs[0]

static func train_length() -> float:
	return CARS * CAR_LEN + (CARS - 1) * CAR_GAP

func _move(delta: float) -> void:
	if run.dwell > 0.0:
		run.dwell -= delta
		if run.dwell <= 0.0 and run.kind == "terminus":
			run.sign = -1.0  # back out the way it came
		return
	var n: int = run.path.size()
	var length: float = run.length
	var occ: Dictionary = occupied_fn.call()
	# the nearest place ahead it must stop: a platform, the buffers, or short of a crossing someone is on
	var limit := INF
	var limit_kind := ""
	if run.sign > 0.0:
		for st in run.stops:
			if st[0] >= run.head - 0.01 and st[0] - run.head < limit:
				limit = st[0] - run.head
				limit_kind = st[1]
		for c in run.crossings:
			var stop_at: float = c - 0.5 - HOLD_SHORT
			if occ.has(run.path[c]) and stop_at >= run.head - 0.01 and stop_at - run.head < limit:
				limit = stop_at - run.head
				limit_kind = "hold"
	else:
		for c in run.crossings:
			var stop_at: float = c + 0.5 + HOLD_SHORT + length  # where the head is when the tail stops short
			if occ.has(run.path[c]) and stop_at <= run.head + 0.01 and run.head - stop_at < limit:
				limit = run.head - stop_at
				limit_kind = "hold"
	var want := minf(SPEED, sqrt(2.0 * ACCEL * maxf(limit, 0.0)))
	if limit_kind in ["platform", "buffers"] and want < SPEED - 0.05 and not run.get("braking", false):
		run.braking = true
		sound_events.append("brake")
	run.v = minf(want, run.v + ACCEL * delta)
	var step := minf(run.v * delta, maxf(limit, 0.0))
	run.head += step * run.sign
	if limit - step < 0.02 and limit_kind in ["platform", "buffers"]:
		run.v = 0.0
		run.dwell = DWELL
		run.braking = false
		run.stops = run.stops.filter(func(s): return s[1] != limit_kind)
	elif limit - step < 0.02 and limit_kind == "hold":
		run.v = 0.0
	if run.sign > 0.0 and run.head - length > n - 1 + 1.5:
		run.done = true
	elif run.sign < 0.0 and run.head < -1.5:
		run.done = true

## Crossings shut from CLOSE_AHEAD tiles in front of the train until it has cleared them.
func _update_closed() -> void:
	_closed.clear()
	if run.is_empty() or run.done:
		return
	var head: float = run.head
	var tail: float = head - run.length
	var lo := tail - 0.8 - (CLOSE_AHEAD if run.sign < 0.0 or run.kind == "terminus" else 0.0)
	var hi := head + 0.8 + (CLOSE_AHEAD if run.sign > 0.0 else 0.0)
	for c in run.crossings:
		if c >= lo and c <= hi:
			_closed[run.path[c]] = true

func _ensure_cars() -> void:
	if not _cars.is_empty():
		return
	Meshes.materials()
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://art/shaders/train.gdshader")
	var livery: Color = LIVERIES[absi(hash(zone.id)) % LIVERIES.size()]
	var cab := Landmarks.train_car(livery, true)
	var mid := Landmarks.train_car(livery, false)
	for k in CARS:
		var mi := MeshInstance3D.new()
		mi.name = "TrainCar%d" % k
		mi.mesh = cab if k == 0 or k == CARS - 1 else mid
		mi.material_override = _mat
		add_child(mi)
		_cars.append(mi)

func _place_cars() -> void:
	var show: bool = not run.is_empty() and not run.done
	for k in _cars.size():
		var mi: MeshInstance3D = _cars[k]
		mi.visible = show
		if not show:
			continue
		var s: float = run.head - CAR_LEN * 0.5 - k * (CAR_LEN + CAR_GAP)
		var at := RailTraffic.point_at(run.path, s)
		var dir := RailTraffic.dir_at(run.path, s)
		var tile := Vector2i(clampi(int(floor(at.x)), 0, zone.width - 1), clampi(int(floor(at.y)), 0, zone.height - 1))
		var y := zone.height_at(tile) * ZoneBuilder.LEVEL + Landmarks.RAIL_TOP
		var yaw := atan2(-dir.y, dir.x) + (PI if k == CARS - 1 else 0.0)
		mi.transform = Transform3D(Basis(Vector3.UP, yaw), Vector3(at.x, y, at.y))

# --- sound -------------------------------------------------------------------------------------------------------

## Gain in dB for a sound `d` tiles away: full close by, then falling off, and gone past HEAR_RANGE.
static func hear_db(d: float) -> float:
	if d >= HEAR_RANGE:
		return -80.0
	var db := -18.0 * log(maxf(d, HEAR_NEAR) / HEAR_NEAR) / log(10.0)
	var edge := HEAR_RANGE - 8.0
	if d > edge:
		db -= 40.0 * (d - edge) / 8.0
	return db

## Where the listener stands, in tile x/z: the point the camera rig follows (the player). null with no camera.
func _ear() -> Variant:
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam == null:
		return null
	var p := cam.global_position
	if cam.get_parent() is Node3D:
		p = (cam.get_parent() as Node3D).global_position
	return Vector2(p.x, p.z)

func _sound() -> void:
	var ear = _ear()
	if run.is_empty() or run.done or ear == null:
		sound_events.clear()
		if _snd and _snd.playing:
			_snd.stop()
		_rumble = -1
		_alarm = -1
		_rushed = false
		return
	if _snd == null:
		_snd = AudioStreamPlayer.new()
		_snd.name = "TrainSound"
		var poly := AudioStreamPolyphonic.new()
		poly.polyphony = 4  # rumble, alarm, and a rush or a squeal on top
		_snd.stream = poly
		add_child(_snd)
	if not _snd.playing:
		_snd.play()
		_rumble = -1
		_alarm = -1
	var pb := _snd.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if pb == null:
		return
	_snd.volume_db = linear_to_db(maxf(Settings.ambience_volume, 0.0001))
	var head: float = run.head
	var length: float = run.length
	var d := minf(RailTraffic.point_at(run.path, head).distance_to(ear), RailTraffic.point_at(run.path, head - length).distance_to(ear))
	d = minf(d, RailTraffic.point_at(run.path, head - length * 0.5).distance_to(ear))
	var pace: float = run.v / SPEED
	if _rumble < 0:
		_rumble = pb.play_stream(load("res://audio/ambience/train_run.wav"), 0.0, -80.0)
	pb.set_stream_volume(_rumble, hear_db(d) + linear_to_db(0.15 + 0.85 * pace))
	pb.set_stream_pitch_scale(_rumble, 0.75 + 0.35 * pace)  # the wheels clack faster as it speeds up
	if not _rushed and d < RUSH_AT and pace > 0.6:
		_rushed = true
		pb.play_stream(load("res://audio/sfx/train_rush.wav"), 0.0, hear_db(d) - 3.0)
	var cd := INF
	for c in _closed:
		cd = minf(cd, (Vector2(c) + Vector2(0.5, 0.5)).distance_to(ear))
	if cd < INF:
		if _alarm < 0:
			_alarm = pb.play_stream(load("res://audio/ambience/crossing_alarm.wav"), 0.0, -80.0)
		pb.set_stream_volume(_alarm, hear_db(cd) - 4.0)
	elif _alarm >= 0:
		pb.stop_stream(_alarm)
		_alarm = -1
	for e in sound_events:
		if e == "brake":
			pb.play_stream(load("res://audio/sfx/brake_squeal.wav"), 0.0, hear_db(d) - 6.0)
	sound_events.clear()

# --- route finding (static, so tests can use it without a scene) -----------------

## Every run a train can make here: [{"path": [Vector2i...], "kind": "through"|"terminus", "from": end, "to": end}].
## "through" joins two open ends (map edge or tunnel_portal); "terminus" runs from an open end to a buffer_stop.
## Lines with anything standing on the track (parked boats, say) get no trains.
static func find_routes(z: ZoneData) -> Array:
	var open := []
	var buffers := []
	for end in z.rail_ends():
		var cap := z.rail_end_cap(end)
		if cap in ["edge", "tunnel_portal"]:
			open.append(end)
		elif cap == "buffer_stop":
			buffers.append(end)
	var axis := {}
	var out := []
	for i in open.size():
		for j in range(i + 1, open.size()):
			var path := track_path(z, open[i].pos, open[j].pos, axis)
			if path.size() >= 2 and _clear(z, path):
				out.append({"path": path, "kind": "through", "from": open[i], "to": open[j]})
		for b in buffers:
			var path := track_path(z, open[i].pos, b.pos, axis)
			if path.size() >= 2 and _clear(z, path):
				out.append({"path": path, "kind": "terminus", "from": open[i], "to": b})
	return out

## Shortest run of track from a to b. Trains only move along the way the track runs (so they never hop
## between the two rows of a double track), except onto a branch that runs their way (a T junction).
static func track_path(z: ZoneData, a: Vector2i, b: Vector2i, axis_cache := {}) -> Array:
	if not z.is_rail(a) or not z.is_rail(b):
		return []
	var prev := {a: a}
	var queue: Array = [a]
	while not queue.is_empty():
		var p: Vector2i = queue.pop_front()
		if p == b:
			break
		for d in DIRS:
			var q: Vector2i = p + d
			if prev.has(q) or not z.is_rail(q):
				continue
			var along := Vector2i(absi(d.x), absi(d.y))
			if _axis(z, p, axis_cache) != along and _axis(z, q, axis_cache) != along:
				continue
			prev[q] = p
			queue.append(q)
	if not prev.has(b):
		return []
	var path := [b]
	while path[0] != a:
		path.push_front(prev[path[0]])
	return path

static func _axis(z: ZoneData, p: Vector2i, cache: Dictionary) -> Vector2i:
	if not cache.has(p):
		cache[p] = z.rail_axis(p)
	return cache[p]

static func _clear(z: ZoneData, path: Array) -> bool:
	for p in path:
		if z.blocked.has(p) and z.rail_cap_at(p).is_empty():
			return false
	return true

## Index of the path tile a through train should stop beside (nearest the station's platform tile), or -1.
static func call_index(z: ZoneData, path: Array) -> int:
	if z.station == Vector2i(-1, -1):
		return -1
	var best := -1
	var best_d := 99
	for i in path.size():
		var p: Vector2i = path[i]
		if maxi(absi(p.x - z.station.x), absi(p.y - z.station.y)) > 2:
			continue
		var d := absi(p.x - z.station.x) + absi(p.y - z.station.y)
		if d < best_d:
			best_d = d
			best = i
	return best

## World x/z (tile centres at +0.5) of distance `s` along the path; beyond either end it carries straight on.
static func point_at(path: Array, s: float) -> Vector2:
	var n := path.size()
	var i := clampi(int(floor(s)), 0, n - 2)
	var a := Vector2(path[i]) + Vector2(0.5, 0.5)
	var b := Vector2(path[i + 1]) + Vector2(0.5, 0.5)
	return a + (b - a) * (s - i)

## Direction of travel (towards the far end of the path) at distance `s`.
static func dir_at(path: Array, s: float) -> Vector2:
	var n := path.size()
	var i := clampi(int(floor(s)), 0, n - 2)
	return (Vector2(path[i + 1]) - Vector2(path[i])).normalized()

## [min, max] world x/z a train may be drawn in: the map, cut back to the mouth of any tunnel at either end.
static func clip_rect(z: ZoneData, path: Array, entry: Dictionary, exit: Dictionary) -> Array:
	var lo := Vector2(0, 0)
	var hi := Vector2(z.width, z.height)
	for end in [entry, exit]:
		var p: Vector2i = end.pos
		var d: Vector2i = end.dir
		var cap_pos := p if not z.rail_cap_at(p).is_empty() else p + d
		if str(z.rail_cap_at(cap_pos).get("type", "")) != "tunnel_portal":
			continue
		var c := Vector2(cap_pos) + Vector2(0.5, 0.5)
		if d.x < 0:
			lo.x = maxf(lo.x, c.x)
		elif d.x > 0:
			hi.x = minf(hi.x, c.x)
		elif d.y < 0:
			lo.y = maxf(lo.y, c.y)
		else:
			hi.y = minf(hi.y, c.y)
	return [lo, hi]
