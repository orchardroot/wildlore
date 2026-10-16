class_name RoamingCreatures
extends Node3D
## Wild creatures glimpsed in the tall grass: two or three per zone, picked from what you could meet there right
## now (the zone's grass encounters for the time and weather). They potter about on tall-grass tiles only,
## rustling it as they go, and dart away (or duck down out of sight) when the player comes within two tiles.
## Purely visual: no grid presence, never in the way, and they don't touch the game's RNG or encounters.
## Off on Low quality, indoors and in dark caves.

const MAX_CREATURES := 3
const MIN_TILES := 6          # less tall grass than this and nobody lives there
const MANY_TILES := 30        # this much grass or more has room for three
const SPOOK_RANGE := 2        # tiles
const START_GAP := 4          # creatures start at least this far from the player...
const START_NEAR := 9         # ...and, where the grass allows, no further than this (so you see them)
const STRAY := 15             # a creature this far from the player moves somewhere nearer, out of sight
const WALK_TIME := 0.55       # seconds per tile, pottering
const DART_TIME := 0.16       # seconds per tile, fleeing
const SINK := 0.16            # how far down into the grass they sit, so only the top half shows
const DIRS := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

var _ow: Node
var _zone: ZoneData
var _rng := RandomNumberGenerator.new()
var _tiles: Array = []
var _critters: Array = []     # of Dictionary {node, sprite, rustle, pos, busy, wait, hidden}

## The overworld's one hook: called after each zone is built. Reuses the node between zones.
static func attach(ow: Node) -> RoamingCreatures:
	var rc: RoamingCreatures = ow.get_node_or_null("RoamingCreatures")
	if rc == null:
		rc = RoamingCreatures.new()
		rc.name = "RoamingCreatures"
		ow.add_child(rc)
		Bus.settings_changed.connect(rc._rebuild)
	rc._ow = ow
	rc._rebuild()
	return rc

# --- rules (pure, tested) ------------------------------------------------------------

## A creature may stand here: tall grass with tufts drawn (not a "prop": "none" stubble field, where a creature
## sunk into the grass would look buried), nothing standing in it, not a doorway or a warp.
static func can_roam(z: ZoneData, p: Vector2i) -> bool:
	return z.in_bounds(p) and z.tile_at(p) == "tall_grass" and not z.blocked.has(p) and z.warp_at(p).is_empty() \
		and str(z.legend_extra.get(z.char_at(p), {}).get("prop", "")) != "none"

static func roam_tiles(z: ZoneData) -> Array:
	var out := []
	for y in z.height:
		for x in z.width:
			if can_roam(z, Vector2i(x, y)):
				out.append(Vector2i(x, y))
	return out

## How many roam a zone with this much tall grass. None on Low quality.
static func count_for(quality: String, tile_count: int) -> int:
	if quality == "low" or tile_count < MIN_TILES:
		return 0
	return MAX_CREATURES if tile_count >= MANY_TILES else 2

## `n` species from the zone's grass encounters that suit the time and weather (weighted, repeats allowed).
static func pick_species(z: ZoneData, phase: String, weather: String, n: int, rng: RandomNumberGenerator) -> Array:
	var list := Encounters.candidates(z, "grass", phase, weather)
	var out := []
	if list.is_empty():
		return out
	for i in n:
		out.append(str(Encounters.pick_entry(list, rng.randf()).species))
	return out

static func spooked(p: Vector2i, player_pos: Vector2i) -> bool:
	return maxi(absi(p.x - player_pos.x), absi(p.y - player_pos.y)) <= SPOOK_RANGE

## The neighbouring grass tile that gets furthest from the player (only if it gains ground); `p` if none does.
static func flee_step(z: ZoneData, p: Vector2i, player_pos: Vector2i, taken: Dictionary) -> Vector2i:
	var best := p
	var best_d := _dist2(p, player_pos)
	for d in DIRS:
		var q: Vector2i = p + d
		if not can_roam(z, q) or taken.has(q) or q == player_pos:
			continue
		var dq := _dist2(q, player_pos)
		if dq > best_d:
			best = q
			best_d = dq
	return best

## A pottering step: the `pick`th free grass neighbour (wrapping), or stay put.
static func wander_step(z: ZoneData, p: Vector2i, taken: Dictionary, pick: int) -> Vector2i:
	var free := []
	for d in DIRS:
		var q: Vector2i = p + d
		if can_roam(z, q) and not taken.has(q):
			free.append(q)
	return p if free.is_empty() else free[posmod(pick, free.size())]

static func _dist2(a: Vector2i, b: Vector2i) -> int:
	return (a - b).length_squared()

# --- in the world ----------------------------------------------------------------------

func _active() -> bool:
	return _ow != null and _ow.zone != null and Settings.quality != "low" and _ow.zone.kind != "interior" and not _ow.zone.dark

func _rebuild() -> void:
	for c in _critters:
		c.node.queue_free()
	_critters.clear()
	if not _active():
		return
	_zone = _ow.zone
	_rng.seed = hash(_zone.id) ^ Game.data.clock_minutes
	_tiles = roam_tiles(_zone)
	var n := count_for(Settings.quality, _tiles.size())
	var player_pos: Vector2i = _ow.player.grid_pos
	var taken := {}
	for sp in pick_species(_zone, Game.phase(), str(_ow.weather), n, _rng):
		var start := _start_tile(player_pos, taken)
		if start.x < 0:
			break
		taken[start] = true
		_critters.append(_make(str(sp), start))

## A free grass tile START_GAP or more from the player, preferably within START_NEAR. (-1, -1) if none turns up.
func _start_tile(player_pos: Vector2i, taken: Dictionary, lo := START_GAP) -> Vector2i:
	var fallback := Vector2i(-1, -1)
	for i in 40:
		var p: Vector2i = _tiles[_rng.randi() % _tiles.size()]
		var gap := maxi(absi(p.x - player_pos.x), absi(p.y - player_pos.y))
		if taken.has(p) or gap < lo:
			continue
		if gap <= START_NEAR + lo - START_GAP:
			return p
		fallback = p
	return fallback

func _make(species: String, p: Vector2i) -> Dictionary:
	var root := Node3D.new()
	add_child(root)
	root.position = _world(p)
	var spr := CharSprite.new()
	root.add_child(spr)
	spr.setup("creature:" + species)
	spr.position.y = -SINK
	spr.scale = Vector3.ONE * 0.85
	spr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return {"node": root, "sprite": spr, "rustle": _rustle(root), "pos": p, "busy": false,
		"wait": _rng.randf_range(1.0, 4.0), "hidden": false}

func _world(p: Vector2i) -> Vector3:
	return Vector3(p.x + 0.5, _ow.ground_y(p), p.y + 0.5)

## A few blades of grass flicked up as the creature pushes through.
func _rustle(parent: Node3D) -> CPUParticles3D:
	var r := CPUParticles3D.new()
	r.emitting = false
	r.one_shot = true
	r.amount = 6
	r.lifetime = 0.45
	r.explosiveness = 0.9
	r.direction = Vector3(0, 1, 0)
	r.spread = 50.0
	r.initial_velocity_min = 0.6
	r.initial_velocity_max = 1.1
	r.gravity = Vector3(0, -4.0, 0)
	r.position = Vector3(0, 0.25, 0)
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.1)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color("6e9c45")
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	q.material = m
	r.mesh = q
	parent.add_child(r)
	return r

func _process(delta: float) -> void:
	if _critters.is_empty() or Router.busy or _ow == null or _ow.zone != _zone:
		return
	var player_pos: Vector2i = _ow.player.grid_pos
	for c in _critters:
		if c.busy:
			continue
		if spooked(c.pos, player_pos):
			var to := flee_step(_zone, c.pos, player_pos, _taken(c))
			if to != c.pos:
				_show(c, true)
				_move(c, to, DART_TIME)
			else:
				_show(c, false)  # cornered: duck down into the grass until the coast is clear
			continue
		_show(c, true)
		c.wait -= delta
		if c.wait <= 0.0:
			c.wait = _rng.randf_range(1.5, 4.5)
			var p: Vector2i = c.pos
			if maxi(absi(p.x - player_pos.x), absi(p.y - player_pos.y)) > STRAY:
				# left far behind in a big zone: turn up again in grass nearer the player, just out of view
				var near := _start_tile(player_pos, _taken(c), START_NEAR)
				if near.x >= 0 and maxi(absi(near.x - player_pos.x), absi(near.y - player_pos.y)) < STRAY:
					c.pos = near
					c.node.position = _world(near)
				continue
			var to := wander_step(_zone, c.pos, _taken(c), _rng.randi())
			if to != c.pos:
				_move(c, to, WALK_TIME)

## Tiles other creatures and NPCs stand on.
func _taken(me: Dictionary) -> Dictionary:
	var out := {}
	for c in _critters:
		if c != me:
			out[c.pos] = true
	for n in _ow.npcs:
		if is_instance_valid(n):
			out[n.grid_pos] = true
	return out

func _show(c: Dictionary, on: bool) -> void:
	if c.hidden == (not on):
		return
	c.hidden = not on
	if not on:
		c.rustle.restart()
	var tw: Tween = c.node.create_tween()
	tw.tween_property(c.sprite, "position:y", -SINK if on else -0.9, 0.15)

func _move(c: Dictionary, to: Vector2i, secs: float) -> void:
	c.busy = true
	var dx: int = to.x - c.pos.x
	if dx != 0:
		c.sprite.flip_h = dx > 0
	c.pos = to
	c.sprite.walking = true
	c.rustle.restart()
	var tw: Tween = c.node.create_tween()
	tw.tween_property(c.node, "position", _world(to), secs)
	tw.finished.connect(func():
		c.sprite.walking = false
		c.busy = false)
