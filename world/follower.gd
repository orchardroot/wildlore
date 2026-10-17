class_name Follower
extends Node3D
## The party lead walking one tile behind the player, like the old handheld games: the first creature that
## hasn't fainted, drawn as a small billboard from its icon (the same sprite RoamingCreatures uses). It steps onto
## the tile the player has just left, in time with the player's own step, and bobs a little when stood still.
## Purely cosmetic: no grid presence, never in anyone's way. Hidden on the bike or the water, in cramped
## interiors, while the player is hidden (journeys, arrival scenes) and while anyone stands on its tile.
## Talk to it by facing it and pressing interact: a short mood line and its cry. Settings.follower turns it off.

const SMALL_INTERIOR := 200    # interiors with fewer tiles than this are too cramped to bring it in
const BOB_HEIGHT := 0.035
const BOB_SPEED := 4.2         # radians per second
const LEAD_CHECK_FRAMES := 15  # how often to look for a new party lead
const NOWHERE := Vector2i(-1, -1)

var tile := NOWHERE
var _ow: Node
var _lead: Creature
var _sprite: CharSprite
var _tile_ok := false
var _was_moving := false
var _moving := false
var _bob_t := 0.0
var _tween: Tween
var _rng := RandomNumberGenerator.new()
var _walked := 0  # steps walked as the follower, towards the next bit of friendship

## The overworld's one hook in load_zone: called after each zone is built. Reuses the node between zones.
static func attach(ow: Node) -> Follower:
	var f: Follower = ow.get_node_or_null("Follower")
	if f == null:
		f = Follower.new()
		f.name = "Follower"
		ow.add_child(f)
		f._rng.randomize()
		Bus.settings_changed.connect(f._check_lead)
	f._ow = ow
	f._check_lead()
	f._place_behind()
	return f

# --- rules (pure, tested) ------------------------------------------------------------

## The first creature in the party that can still walk, or null.
static func lead_of(data: GameStateData) -> Creature:
	return data.first_able()

## Where the follower goes when the player steps from `from` to `to`: the tile the player just left.
static func next_tile(_follower: Vector2i, from: Vector2i, _to: Vector2i) -> Vector2i:
	return from

## Too far to walk there in one step (a ledge hop, or not placed yet): jump straight there instead.
static func snaps(from: Vector2i, to: Vector2i) -> bool:
	return from.x < 0 or absi(from.x - to.x) + absi(from.y - to.y) > 1

## Two tiles in a straight line: the player hopped a ledge, so hop down after them (snaps covers it otherwise).
static func hops(from: Vector2i, to: Vector2i) -> bool:
	var d := to - from
	return from.x >= 0 and ((absi(d.x) == 2 and d.y == 0) or (absi(d.y) == 2 and d.x == 0))

## Seconds per step, the same as the player's.
static func move_secs(running: bool, bike := false) -> float:
	if bike:
		return 1.0 / Player.BIKE_SPEED
	return 1.0 / (Player.RUN_SPEED if running else Player.WALK_SPEED)

## A place to stand after a warp or zone change: behind the player, else beside them, else in front.
## `ok` says whether a tile is free to stand on. NOWHERE if boxed in.
static func behind_tile(player_pos: Vector2i, facing: String, ok: Callable) -> Vector2i:
	var f := GridMotion.dir_vec(facing)
	var side := Vector2i(f.y, f.x)
	for d in [-f, side, -side, f]:
		var p: Vector2i = player_pos + d
		if ok.call(p):
			return p
	return NOWHERE

static func should_show(enabled: bool, has_lead: bool, kind: String, area: int, on_bike: bool, wading: bool,
		player_shown: bool, npc_here: bool, placed: bool) -> bool:
	if not enabled or not has_lead or not placed or on_bike or wading or not player_shown or npc_here:
		return false
	return kind != "interior" or area >= SMALL_INTERIOR

## Billboard scale from Cries.size_of (0 small .. 1 legend-sized): a touch smaller than the player at most.
static func scale_for(size: float) -> float:
	return lerpf(0.72, 0.95, clampf(size, 0.0, 1.0))

# --- mood lines ----------------------------------------------------------------------

const GENERAL := [
	"{name} is trotting along happily beside you.",
	"{name} sniffs the air and looks very pleased with itself.",
	"{name} gives you a look that clearly means \"snacks?\"",
	"{name} nudges your hand. It wants a scratch behind the ears.",
	"{name} is humming a little tune. Badly.",
	"{name} spotted something in the hedge and is pretending it didn't.",
	"{name} stretches, yawns and carries on.",
	"{name} is keeping a careful eye out for trouble.",
	"{name} looks up at you, then looks proud of itself for no clear reason.",
	"{name} is walking with a definite swagger.",
	"{name} gives a passing pigeon a very rude look.",
]
const HP_LINES := {
	"high": ["{name} is full of beans!", "{name} bounces on the spot, raring to go."],
	"mid": ["{name} is doing all right, but wouldn't say no to a sit down."],
	"low": ["{name} looks tired. Maybe a Sanctuary is in order.", "{name} is a bit worn out and keeps close to your heels.",
		"{name} is limping slightly, but being very brave about it."],
}
const WEATHER_LINES := {
	"drizzle": ["{name} shakes the rain off its fur.", "{name} splashes through a puddle. On purpose."],
	"downpour": ["{name} shakes the rain off its fur.", "{name} is not impressed by all this rain."],
	"fog": ["{name} stays close. It doesn't like the fog much.", "{name} peers into the fog, very alert."],
	"gale": ["{name} leans into the wind with its eyes screwed up.", "{name} nearly got blown over and is hoping you didn't see."],
	"frost": ["{name} is puffing little clouds of breath in the cold.", "{name} skids on the frost, then looks round to see if anyone noticed."],
}
const PHASE_LINES := {
	"dawn": ["{name} blinks sleepily at the early light."],
	"day": ["{name} is soaking up the daylight."],
	"dusk": ["{name} watches the sun going down."],
	"night": ["{name} yawns. It is well past its bedtime.", "{name} gazes up at the stars."],
}
const PLACE_LINES := {
	"town": ["{name} looks happy to be back in {place}.", "{name} is having a good nosy round {place}."],
	"route": ["{name} loves being out in the open air.", "{name} keeps sniffing at the long grass."],
	"cave": ["{name} is glad of the lantern light down here.", "{name} jumps at its own echo."],
	"interior": ["{name} is trying very hard not to knock anything over."],
}

## By hearts (Bond.hearts): how it feels about you. Nothing for the middling ones; it just gets on with it.
const BOND_LINES := {
	0: ["{name} keeps a polite distance. Give it time.", "{name} is still making its mind up about you."],
	3: ["{name} keeps glancing up to check you're still there.", "{name} bumps your leg with its head, just because."],
	4: ["{name} trots right at your heels, never more than a step away.", "{name} looks at you like you hung the moon."],
	5: ["{name} would follow you to the ends of the earth. Or at least to Wigan.", "{name} leans against you with a happy sigh. Best friends, plainly.",
		"{name} has decided you are its favourite person, and that's that."],
}

static func template_count() -> int:
	var seen := {}
	for t in GENERAL:
		seen[t] = true
	for table in [HP_LINES, WEATHER_LINES, PHASE_LINES, PLACE_LINES, BOND_LINES]:
		for k in table:
			for t in table[k]:
				seen[t] = true
	return seen.size()

static func _hp_band(hp_frac: float) -> String:
	return "low" if hp_frac < 0.35 else ("mid" if hp_frac < 0.75 else "high")

## The lines that fit right now: the ones about its health, the weather, the time of day and the place.
static func _situational(hp_frac: float, weather: String, phase: String, kind: String, friendship := -1) -> Array:
	var out: Array = []
	if friendship >= 0:
		out.append_array(BOND_LINES.get(Bond.hearts(friendship), []))
	out.append_array(HP_LINES[_hp_band(hp_frac)])
	out.append_array(WEATHER_LINES.get(weather, []))
	if weather == "clear" or phase != "day":  # no "soaking up the daylight" in a downpour
		out.append_array(PHASE_LINES.get(phase, []))
	out.append_array(PLACE_LINES.get(kind, []))
	return out

## Every template that could be said now (general ones included).
## friendship -1: leave the friendship lines out.
static func mood_pool(hp_frac: float, weather: String, phase: String, kind: String, friendship := -1) -> Array:
	var out: Array = GENERAL.duplicate()
	out.append_array(_situational(hp_frac, weather, phase, kind, friendship))
	return out

## One line, chosen by `pick`: every other pick is about the situation, so the weather and the place come up often.
## `kind` is the zone kind, or "cave" in a dark zone.
static func mood_line(name: String, hp_frac: float, weather: String, phase: String, place: String, kind: String, pick: int, friendship := -1) -> String:
	var sit := _situational(hp_frac, weather, phase, kind, friendship)
	var t: String
	if pick % 2 == 0 and not sit.is_empty():
		t = sit[(pick / 2) % sit.size()]
	else:
		t = GENERAL[(pick / 2) % GENERAL.size()]
	return t.replace("{name}", name).replace("{place}", place)

# --- in the world ----------------------------------------------------------------------

func is_at(p: Vector2i) -> bool:
	return visible and _sprite != null and tile == p

## Interact while facing it: it turns to you, cries and says how it is getting on.
func talk() -> void:
	if _lead == null or _ow == null:
		return
	_sprite.flip_h = _ow.player.grid_pos.x > tile.x
	Audio.cry(_lead.species)
	var hop := create_tween()
	hop.tween_property(_sprite, "position:y", 0.18, 0.09).set_ease(Tween.EASE_OUT)
	hop.tween_property(_sprite, "position:y", 0.0, 0.12).set_ease(Tween.EASE_IN)
	var z: ZoneData = _ow.zone
	var kind := "cave" if z.dark else z.kind
	var place := z.name
	if z.kind == "interior":
		var town = Game.data.flag("last_town")
		if town and Game.zone_exists(str(town)):
			place = ZoneData.load_id(str(town)).name
	var hp_frac := float(_lead.hp) / maxf(1.0, float(_lead.max_hp()))
	Bond.talk(Game.data, _lead)  # a chat now and then brings you closer (once an in-game hour)
	await _ow.say([mood_line(_lead.display_name(), hp_frac, str(_ow.weather), Game.phase(), place, kind, _rng.randi() % 1000, _lead.friendship)])

## A new lead (or the setting changed): swap the sprite for the new creature's.
func _check_lead() -> void:
	var lead: Creature = lead_of(Game.data) if Settings.follower else null
	if lead == _lead and (_sprite != null) == (lead != null):
		return
	_lead = lead
	if _sprite:
		_sprite.queue_free()
		_sprite = null
	if lead == null:
		return
	_sprite = CharSprite.new()
	add_child(_sprite)
	_sprite.setup("creature:" + str(lead.species.id))
	_sprite.scale = Vector3.ONE * scale_for(Cries.size_of(lead.species))
	_sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _stand_ok(p: Vector2i) -> bool:
	var z: ZoneData = _ow.zone
	return z.in_bounds(p) and z.walkable(p) and z.tile_at(p) != "deep_water" and not _ow.occupied(p) \
		and z.warp_at(p).is_empty()

func _place_behind() -> void:
	var pl: Player = _ow.player
	_was_moving = pl.moving
	_moving = false
	if _tween and _tween.is_valid():
		_tween.kill()
	_set_tile(behind_tile(pl.grid_pos, pl.facing, _stand_ok))
	if tile != NOWHERE:
		position = _world(tile)
		if _sprite:
			_sprite.walking = false

func _set_tile(p: Vector2i) -> void:
	tile = p
	var z: ZoneData = _ow.zone
	_tile_ok = p != NOWHERE and z.in_bounds(p) and z.tile_at(p) != "deep_water"

func _world(p: Vector2i) -> Vector3:
	return Vector3(p.x + 0.5, _ow.ground_y(p), p.y + 0.5)

func _process(delta: float) -> void:
	if _ow == null or _ow.zone == null:
		return
	if Engine.get_process_frames() % LEAD_CHECK_FRAMES == 0:
		_check_lead()
	var pl: Player = _ow.player
	if pl.moving and not _was_moving:
		_follow(pl)  # the player has just set off from grid_pos: step onto it
	_was_moving = pl.moving
	visible = should_show(Settings.follower, _sprite != null, _ow.zone.kind, _ow.zone.width * _ow.zone.height,
		pl.on_bike, pl.wading, pl.visible, _npc_here(), _tile_ok)
	if visible and not _moving and not Router.busy:
		_bob_t += delta
		_sprite.position.y = absf(sin(_bob_t * BOB_SPEED)) * BOB_HEIGHT

func _follow(pl: Player) -> void:
	var to := next_tile(tile, pl.grid_pos, pl.grid_pos)
	if to == tile:
		return
	var from := tile
	_set_tile(to)
	if visible and _lead != null:
		_walked += 1
		if _walked >= Bond.WALK_STEPS:
			_walked = 0
			Bond.add(_lead, Bond.WALK)
	if _tween and _tween.is_valid():
		_tween.kill()
	if _sprite == null or (snaps(from, to) and not hops(from, to)):
		_moving = false
		position = _world(to)
		return
	var dx := to.x - from.x
	if dx != 0:
		_sprite.flip_h = dx > 0
	_moving = true
	_sprite.walking = true
	_sprite.position.y = 0.0
	var running: bool = pl.sprite.walk_rate == CharSprite.RUN_RATE
	_tween = create_tween()
	if hops(from, to):
		var start := position
		var dest := _world(to)
		_tween.tween_method(func(t: float): position = Player.hop_pos(start, dest, t), 0.0, 1.0, 0.35)
	else:
		_tween.tween_property(self, "position", _world(to), move_secs(running, pl.on_bike))
	_tween.finished.connect(_arrived)

func _arrived() -> void:
	_moving = false
	if _sprite and not _ow.player.moving:
		_sprite.walking = false

func _npc_here() -> bool:
	for n in _ow.npcs:
		if is_instance_valid(n) and n.grid_pos == tile:
			return true
	return false
