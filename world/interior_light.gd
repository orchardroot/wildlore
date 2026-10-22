class_name InteriorLight
extends Node3D
## Medium and High graphics: rooms lit by what is in them. A warm light over the middle of the room, a flickering
## glow in front of each hearth, brazier or candelabra, daylight through the windows by day, and in caves a
## lantern's warm pool around you. Shadowless omni lights, at most MAX_LIGHTS a room (each one costs a pass of the
## room's meshes in the Compatibility renderer). On Low the whole lot is hidden, so rooms look as they always have.

const MAX_LIGHTS := 4
const FIRES := {"fireplace": Color("ff9a4a"), "brazier": Color("ff8a3a"), "candelabra": Color("ffc070")}
const DAYLIGHT := Color("dfeaff")
const ROOM := Color("ffd9a8")
const GROUP := "interior_light"

var _fires: Array = []     # of [OmniLight3D, base energy, phase]
var _windows: Array = []   # daylight lights: off at night
var _lantern: OmniLight3D  # caves: rides with the player
var _t := 0.0

## Lights for an interior zone (none outdoors). Returns the node, or null.
static func dress(z: ZoneData, root: Node3D, player: Node3D, quality: String) -> InteriorLight:
	if z.kind != "interior":
		return null
	var il := InteriorLight.new()
	il.name = "InteriorLight"
	il.add_to_group(GROUP)
	root.add_child(il)
	for spec in plan(z):
		var l := OmniLight3D.new()
		l.light_color = spec.colour
		l.light_energy = spec.energy
		l.omni_range = spec.range
		l.omni_attenuation = 1.4
		l.shadow_enabled = false
		l.position = spec.at
		match str(spec.kind):
			"fire":
				il._fires.append([l, spec.energy, randf() * TAU])
			"window":
				il._windows.append(l)
			"lantern":
				if player:
					l.position = Vector3(0, 1.1, 0.3)
					player.add_child.call_deferred(l)
					il.tree_exiting.connect(l.queue_free)  # the lantern goes when the cave does
					il._lantern = l
					continue
		il.add_child(l)
	il.apply(quality)
	return il

## What lights a room: pure data (kind, colour, energy, range, position) so tests can read it. Fires first, then
## Up to two fires, then the room light, then the windows, cut to MAX_LIGHTS. Caves get the lantern and their fires.
static func plan(z: ZoneData) -> Array:
	var fires := []
	var windows := []
	var cave := ZoneBuilder.is_cave(z)
	for pr in z.props:
		var t := str(pr.get("type", ""))
		var p := Vector2i(int(pr.get("x", 0)), int(pr.get("y", 0)))
		if FIRES.has(t):
			fires.append({"kind": "fire", "colour": FIRES[t], "energy": 1.1, "range": 4.5,
				"at": Vector3(p.x + 0.5, ZoneBuilder.ground_y(z, p) + 0.7, p.y + 1.2)})
		elif t in ["window", "city_window"] and not cave:
			windows.append({"kind": "window", "colour": DAYLIGHT, "energy": 0.55, "range": 4.0,
				"at": Vector3(p.x + 0.5, 1.6, p.y + 1.4)})
	var out := fires.slice(0, 2)
	if cave:
		out.push_front({"kind": "lantern", "colour": Color("ffb066"), "energy": 0.9, "range": 4.0, "at": Vector3.ZERO})
	else:
		out.append({"kind": "room", "colour": ROOM, "energy": 0.45, "range": maxf(z.width, z.height) * 0.75,
			"at": Vector3(z.width * 0.5, 2.6, z.height * 0.55)})
		out.append_array(windows)
	return out.slice(0, MAX_LIGHTS)

func apply(quality: String) -> void:
	visible = quality != "low"
	if _lantern:
		_lantern.visible = visible
	set_process(visible)

func _ready() -> void:
	_sync_daylight()

func _process(delta: float) -> void:
	_t += delta
	for f in _fires:
		# a slow breathe and a quick flicker, never quite still
		(f[0] as OmniLight3D).light_energy = f[1] * (0.85 + 0.1 * sin(_t * 2.1 + f[2]) + 0.06 * sin(_t * 9.7 + f[2] * 3.0))
	if Engine.get_process_frames() % 60 == 0:
		_sync_daylight()

func _sync_daylight() -> void:
	var ph := GameClock.phase(Game.local_minutes())
	for w in _windows:
		(w as OmniLight3D).visible = ph == "day" or ph == "dawn"
		(w as OmniLight3D).light_energy = 0.55 if ph == "day" else 0.3
