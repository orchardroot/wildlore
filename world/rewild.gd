class_name Rewild
extends RefCounted
## Rewilding: six damaged sites, one per nation, that the player helps restore in four stages (Damaged, Planted,
## Recovering, Wild). A warden at each site asks for one thing per stage (see data/rewild.json); stage 1 comes at
## once, the later ones settle over one in-game day. Each stage reshapes the site's rectangle of its zone (ground
## colour, tall grass, pools and trees on a lattice that can never wall anything off) and lets new creatures in.
##
## Flags: rewild_<site> (stage, 0..3), rewild_<site>_due (in-game day of a contribution still settling),
## rewild_<site>_rewarded (highest stage paid out), rewild_<site>_met, rewild_<site>_s<stage>_<i> (a planted spot),
## rewild_complete (all six Wild, the crook given). Pure logic: no autoloads (menus and the validator load it).

const PATH := "res://data/rewild.json"
const STAGE_NAMES := ["Damaged", "Planted", "Recovering", "Wild"]
const WILD := 3
const COMPLETE_FLAG := "rewild_complete"
const KEY_ITEM := "rewilders_crook"
## Tiles a site may reshape (paths, water, walls and buildings stay as they are).
const OPEN_TILES := ["grass", "tall_grass", "flowers"]
const WATER_TILES := ["water", "deep_water", "shallow"]
const SPOT_GAP := 3  # tiles between marked spots
const KEY_BASE := 0xE000  # legend chars for reshaped tiles (private use, never in a zone file)

static var _db: Dictionary = {}

static func _all() -> Dictionary:
	if _db.is_empty():
		var d = JsonUtil.read(PATH)
		_db = d if d is Dictionary else {"sites": [], "looks": {}}
	return _db

static func sites() -> Array:
	return _all().get("sites", [])

static func site(id: String) -> Dictionary:
	for s in sites():
		if str(s.id) == id:
			return s
	return {}

static func sites_in(zone_id: String) -> Array:
	return sites().filter(func(s): return str(s.zone) == zone_id)

static func rect(s: Dictionary) -> Rect2i:
	var r: Array = s.get("rect", [0, 0, 0, 0])
	return Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3]))

static func tasks(s: Dictionary) -> Array:
	return s.get("tasks", [])

## The task that takes site `s` from `stage` to the next ({} once Wild).
static func task(s: Dictionary, stage_now: int) -> Dictionary:
	var t := tasks(s)
	return t[stage_now] if stage_now >= 0 and stage_now < t.size() else {}

static func looks(biome: String) -> Array:
	return _all().get("looks", {}).get(biome, [])

static func stage_name(stage_now: int) -> String:
	return STAGE_NAMES[clampi(stage_now, 0, WILD)]

# --- state ---------------------------------------------------------------------

static func flag_key(id: String) -> String:
	return "rewild_" + id

static func _int_flag(data: GameStateData, key: String, default := 0) -> int:
	var v: Variant = data.flag(key)
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else default

static func stage(data: GameStateData, id: String) -> int:
	return clampi(_int_flag(data, flag_key(id)), 0, WILD)

## A contribution made, waiting for the next in-game day to take.
static func pending(data: GameStateData, id: String) -> bool:
	return data.flag(flag_key(id) + "_due") != null

static func can_contribute(data: GameStateData, id: String) -> bool:
	return stage(data, id) < WILD and not pending(data, id)

## The player has done this stage's task: Planted comes at once, later stages wait a day (settle).
static func contribute(data: GameStateData, id: String) -> void:
	if not can_contribute(data, id):
		return
	if stage(data, id) == 0:
		data.set_flag(flag_key(id), 1)
	else:
		data.set_flag(flag_key(id) + "_due", data.day_count)

## Every site whose contribution has seen an in-game midnight moves on a stage. Returns their ids.
static func settle(data: GameStateData) -> Array:
	var out := []
	for s in sites():
		var id := str(s.id)
		if pending(data, id) and data.day_count > _int_flag(data, flag_key(id) + "_due"):
			data.flags.erase(flag_key(id) + "_due")
			data.set_flag(flag_key(id), mini(WILD, stage(data, id) + 1))
			out.append(id)
	return out

static func all_wild(data: GameStateData) -> bool:
	return not sites().is_empty() and sites().all(func(s): return stage(data, str(s.id)) >= WILD)

## Stages reached that have not paid out yet (each pays once).
static func unrewarded(data: GameStateData, id: String) -> Array:
	var out := []
	for st in range(_int_flag(data, flag_key(id) + "_rewarded") + 1, stage(data, id) + 1):
		out.append(st)
	return out

static func wild_count(data: GameStateData) -> int:
	return sites().filter(func(s): return stage(data, str(s.id)) >= WILD).size()

# --- paying for a stage ----------------------------------------------------------

static func can_pay(data: GameStateData, t: Dictionary) -> bool:
	match str(t.get("kind", "")):
		"items":
			for id in t.get("items", {}):
				if int(data.bag.get(str(id), 0)) < int(t.items[id]):
					return false
			return true
		"money":
			return data.money >= int(t.get("amount", 0))
	return false

static func pay(data: GameStateData, t: Dictionary) -> void:
	match str(t.get("kind", "")):
		"items":
			var bag := Bag.new(data.bag)
			for id in t.get("items", {}):
				bag.remove(str(id), int(t.items[id]))
		"money":
			data.money -= int(t.get("amount", 0))

## The first creature in the party of `type` (it only has a look round: it stays with you), or null.
static func shown(data: GameStateData, type: String) -> Creature:
	for c in data.party:
		if type in c.species.get("types", []) and not c.is_fainted():
			return c
	return null

# --- marked spots (planting and litter) -------------------------------------------

static func spot_flag(id: String, stage_now: int, i: int) -> String:
	return "rewild_%s_s%d_%d" % [id, stage_now, i]

## The marked spots of site `s` in zone `z`: open tiles in the rectangle, never on the tree lattice, spread out.
## Worked out from the zone as built (Rewild.apply keeps the answer, since it reshapes the tiles afterwards).
static func spots(z: ZoneData, s: Dictionary) -> Array:
	var key := "rewild_spots_" + str(s.id)
	if z.has_meta(key):
		return z.get_meta(key)
	var n := 0
	for t in tasks(s):
		n = maxi(n, int(t.get("spots", 0)))
	var r := rect(s)
	var keep := _keep(z)
	var cands := []
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var p := Vector2i(x, y)
			if _open(z, p, keep) and not _lattice(r, p) and inside(s, p):
				cands.append(p)
	cands.sort_custom(func(a, b): return _u(str(s.id), "spot", a) < _u(str(s.id), "spot", b))
	var out := []
	for gap in [SPOT_GAP, 2, 1]:
		for p in cands:
			if out.size() >= n:
				break
			if out.has(p):
				continue
			if out.all(func(q): return maxi(absi(q.x - p.x), absi(q.y - p.y)) >= gap):
				out.append(p)
	return out

static func spots_done(data: GameStateData, id: String, z: ZoneData) -> int:
	var st := stage(data, id)
	var n := 0
	for i in spots(z, site(id)).size():
		if data.flag(spot_flag(id, st, i)) == true:
			n += 1
	return n

## The current task's spots are all seen to (plant and litter tasks).
static func task_done(data: GameStateData, id: String, z: ZoneData = null) -> bool:
	var s := site(id)
	var t := task(s, stage(data, id))
	if str(t.get("kind", "")) not in ["plant", "litter"]:
		return false
	var need := int(t.get("spots", 0))
	var st := stage(data, id)
	var n := 0
	for i in need:
		if data.flag(spot_flag(id, st, i)) == true:
			n += 1
	return n >= need

## The spot (if any) of a live plant or litter task on tile p: {"site", "index", "task"}, else {}.
static func spot_at(data: GameStateData, z: ZoneData, p: Vector2i) -> Dictionary:
	for s in sites_in(z.id):
		var id := str(s.id)
		if not can_contribute(data, id):
			continue
		var t := task(s, stage(data, id))
		if str(t.get("kind", "")) not in ["plant", "litter"]:
			continue
		var i := spots(z, s).find(p)
		if i >= 0 and i < int(t.get("spots", 0)):
			return {"site": s, "index": i, "task": t}
	return {}

## Plants (or clears) the spot on p. The line to show, or "" when p isn't a live spot.
static func mark_spot(data: GameStateData, z: ZoneData, p: Vector2i) -> String:
	var at := spot_at(data, z, p)
	if at.is_empty():
		return ""
	var s: Dictionary = at.site
	var id := str(s.id)
	var t: Dictionary = at.task
	var key := spot_flag(id, stage(data, id), int(at.index))
	var litter := str(t.kind) == "litter"
	if data.flag(key) == true:
		return "All tidy here. Nothing left to bag." if litter else "This one's in already, settling down nicely."
	data.set_flag(key, true)
	var need := int(t.get("spots", 0))
	var n := 0
	for i in need:
		if data.flag(spot_flag(id, stage(data, id), i)) == true:
			n += 1
	var line := ("You bag up a crisp packet, two cans and what was once a welly." if litter
		else "You push the %s in and firm it down with your boot." % str(t.get("thing", "sapling")))
	if n >= need:
		return line + " That's the last one. Go and tell %s." % str(s.warden)
	return line + " (%d of %d)" % [n, need]

# --- hints ---------------------------------------------------------------------------

## What to do next for the first site not yet Wild ("" before the first Stone, or once every site is Wild).
static func hint(data: GameStateData) -> String:
	return str(hint_entry(data).get("text", ""))

## The hint as a "Where next?" entry: {text, town (the site's zone, which the map knows)}, or {}.
static func hint_entry(data: GameStateData) -> Dictionary:
	if data.flag("badge_brook") != true:
		return {}
	var settling := {}
	for s in sites():
		var id := str(s.id)
		var st := stage(data, id)
		if st >= WILD:
			continue
		if pending(data, id):
			if settling.is_empty():
				settling = {"text": "%s is settling. Give it a day, then go and see %s." % [s.name, s.warden], "town": str(s.zone)}
			continue
		if data.flag(flag_key(id) + "_met") != true:
			return {"text": "%s is restoring %s and could use a hand." % [s.warden, s.name], "town": str(s.zone)}
		return {"text": "%s (%s): %s" % [s.name, stage_name(st), task_summary(data, s)], "town": str(s.zone)}
	return settling

static func task_summary(data: GameStateData, s: Dictionary) -> String:
	var t := task(s, stage(data, str(s.id)))
	match str(t.get("kind", "")):
		"plant":
			return "plant %d %ss at the canes." % [int(t.spots), str(t.get("thing", "sapling"))]
		"litter":
			return "clear %d piles of rubbish." % int(t.spots)
		"items":
			var parts := []
			for id in t.items:
				parts.append("%d %s" % [int(t.items[id]), str(id).replace("_", " ")])
			return "bring %s %s." % [s.warden, " and ".join(parts)]
		"money":
			return "chip in £%d for %s." % [int(t.amount), s.warden]
		"show":
			return "show %s a %s creature." % [s.warden, str(t.type).capitalize()]
		"battle":
			return "see off the Enclosure leftover for %s." % s.warden
	return ""

# --- reshaping the zone ---------------------------------------------------------------

## Reshapes every site in zone `z` for its stage (call before the zone is built, like FieldMoves.apply_cuts), and
## adds each site's returning creatures to the zone's tables, gated on the stage (Encounters reads requires_flag).
## The layouts (props to dress the site with) go on the zone as meta "rewild".
static func apply(data: GameStateData, z: ZoneData) -> void:
	settle(data)
	var lays := []
	var n := 0
	for s in sites_in(z.id):
		var id := str(s.id)
		z.set_meta("rewild_spots_" + id, spots(z, s))
		var lay := layout(z, s, stage(data, id), KEY_BASE + n * 32)
		n += 1
		for p in lay.tiles:
			var tk: Array = lay.tiles[p]
			z.tiles[p.y][p.x] = tk[0]
			z.chars[p.y][p.x] = tk[1]
		z.legend_extra.merge(lay.legend, true)
		var encs: Array = s.get("encounters", [])
		for i in encs.size():
			for e in encs[i]:
				var entry: Dictionary = e.duplicate()
				var kind := str(entry.get("kind", "grass"))
				entry.erase("kind")
				entry["requires_flag"] = flag_key(id)
				entry["flag_at_least"] = i + 1
				if not z.encounters.has(kind):
					z.encounters[kind] = []
				z.encounters[kind].append(entry)
		lay["site"] = id
		lay["stage"] = stage(data, id)
		lays.append(lay)
	if not lays.is_empty():
		z.set_meta("rewild", lays)

## What site `s` looks like at `stage_now` in zone `z` (as loaded): {"tiles": {Vector2i: [tile, char]},
## "legend": {char: legend entry}, "decor": {mesh: [[x, z, yaw, scale, on_water], ...]}}. Deterministic, and each
## tile's dice are fixed per site, so a pool or a tree that appears at one stage is still there at the next.
static func layout(z: ZoneData, s: Dictionary, stage_now: int, key_base := KEY_BASE) -> Dictionary:
	var ls := looks(str(s.get("biome", "")))
	var look: Dictionary = ls[clampi(stage_now, 0, ls.size() - 1)] if not ls.is_empty() else {}
	var id := str(s.id)
	var r := rect(s)
	var keep := _keep(z)
	var spot_list: Array = spots(z, s)
	var out := {"tiles": {}, "legend": {}, "decor": {}}
	var ground := String.chr(key_base)
	var alt := String.chr(key_base + 1)
	var tall := String.chr(key_base + 2)
	out.legend[ground] = {"tile": "grass", "colour": str(look.get("ground", "#527f37"))}
	out.legend[alt] = {"tile": "grass", "colour": str(look.get("alt", look.get("ground", "#527f37")))}
	var tl: Dictionary = look.get("tall", {})
	var tall_def := {"tile": "tall_grass"}
	tall_def["colour"] = str(tl.get("colour", look.get("ground", "#4f8035")))  # no seams against the ground
	if tl.has("prop"):
		tall_def["prop"] = str(tl.prop)
	out.legend[tall] = tall_def
	var blockers: Array = look.get("blockers", [])
	for i in blockers.size():
		var b: Dictionary = blockers[i]
		var bd := {"tile": str(b.tile), "colour": str(look.get("ground", "#527f37"))}
		if b.has("prop"):
			bd["prop"] = str(b.prop)
		out.legend[String.chr(key_base + 3 + i)] = bd
	var noise := FastNoiseLite.new()
	noise.seed = id.hash()
	noise.frequency = 0.21
	var decor: Array = look.get("decor", [])
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var p := Vector2i(x, y)
			if not inside(s, p):
				continue
			if not _open(z, p, keep):
				if z.tile_at(p) in WATER_TILES:
					_scatter(out.decor, decor, id, p, true)
				continue
			var placed := false
			if _lattice(r, p) and _ring_clear(z, p, keep):
				var u := _u(id, "block", p)
				var cum := 0.0
				for i in blockers.size():
					cum += float(blockers[i].get("density", 0.0))
					if u < cum:
						out.tiles[p] = [str(blockers[i].tile), String.chr(key_base + 3 + i)]
						var dm := str(blockers[i].get("decor", ""))
						if dm != "":
							_add(out.decor, dm, p, _u(id, "yaw", p) * TAU, 0.9 + _u(id, "size", p) * 0.25, false, Vector2.ZERO)
						placed = true
						break
			if placed:
				continue
			var nv := (noise.get_noise_2d(x, y) + 1.0) * 0.5
			var is_spot := spot_list.has(p)
			if not tl.is_empty() and nv < float(tl.get("density", 0.0)) and not is_spot:
				out.tiles[p] = ["tall_grass", tall]
			else:
				var use_alt := nv > 1.0 - float(look.get("alt_amount", 0.0))
				if bool(look.get("stripes", false)):
					use_alt = (y - r.position.y) % 3 == 1  # the straight black drains of a milled bog
				out.tiles[p] = ["grass", alt if use_alt else ground]
			if not is_spot:
				_scatter(out.decor, decor, id, p, false)
	for d in decor:  # a beaver dam: one bank of sticks right across the water, not a scatter
		if bool(d.get("across", false)):
			var row := r.position.y + int(r.size.y * 0.6)
			for x in range(r.position.x, r.end.x):
				if z.tile_at(Vector2i(x, row)) in WATER_TILES:
					_add(out.decor, str(d.mesh), Vector2i(x, row), 0.0, 1.15, true, Vector2.ZERO)
	return out

## At most one decor prop on tile p, from the look's list (land or water ones).
static func _scatter(into: Dictionary, decor: Array, id: String, p: Vector2i, water: bool) -> void:
	for i in decor.size():
		var d: Dictionary = decor[i]
		if bool(d.get("water", false)) != water or bool(d.get("across", false)):
			continue
		if _u(id, "decor%d" % i, p) < float(d.get("density", 0.0)):
			var off := Vector2(_u(id, "ox", p) - 0.5, _u(id, "oz", p) - 0.5) * 0.5
			_add(into, str(d.mesh), p, _u(id, "yaw", p) * TAU, (0.85 + _u(id, "size", p) * 0.3) * float(d.get("scale", 1.0)), water, off)
			return

static func _add(into: Dictionary, mesh: String, p: Vector2i, yaw: float, scale: float, water: bool, off: Vector2) -> void:
	if not into.has(mesh):
		into[mesh] = []
	into[mesh].append([p.x + 0.5 + off.x, p.y + 0.5 + off.y, yaw, scale, water])

## Tiles nobody may reshape or crowd: where people stand, warps and the spawn point.
static func _keep(z: ZoneData) -> Dictionary:
	var out := {z.spawn: true}
	for n in z.npcs:
		out[Vector2i(int(n.get("x", -1)), int(n.get("y", -1)))] = true
	for w in z.warps:
		out[Vector2i(int(w.get("x", -1)), int(w.get("y", -1)))] = true
	return out

static func _open(z: ZoneData, p: Vector2i, keep: Dictionary) -> bool:
	return z.tile_at(p) in OPEN_TILES and not z.blocked.has(p) and not keep.has(p)

## Odd offsets from the rectangle's corner: blockers there are always two apart, never touching.
static func _lattice(r: Rect2i, p: Vector2i) -> bool:
	return (p.x - r.position.x) % 2 == 1 and (p.y - r.position.y) % 2 == 1

## A blocker only goes where all eight neighbours are open ground no more than one step apart in height: you can
## always walk round it.
static func _ring_clear(z: ZoneData, p: Vector2i, keep: Dictionary) -> bool:
	var lo := z.height_at(p)
	var hi := lo
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var q := p + Vector2i(dx, dy)
			if not z.walkable(q) or keep.has(q) or z.tile_at(q) == "shallow":
				return false
			lo = mini(lo, z.height_at(q))
			hi = maxi(hi, z.height_at(q))
	return hi - lo <= 1

## A fixed die roll in 0..1 for this site, purpose and tile (string hash, then an integer mix so that
## neighbouring tiles don't roll alike).
static func _u(id: String, salt: String, p: Vector2i) -> float:
	var h := ("%s|%s" % [id, salt]).hash() ^ (p.x * 73856093) ^ (p.y * 19349663)
	h = ((h ^ (h >> 16)) * 0x45d9f3b) & 0xFFFFFFFF
	h = ((h ^ (h >> 16)) * 0x45d9f3b) & 0xFFFFFFFF
	h = h ^ (h >> 16)
	return float(h & 0xFFFF) / 65536.0

## The site's ragged edge: a rounded rectangle with a frayed rim, so it blends into the land round it.
static func inside(s: Dictionary, p: Vector2i) -> bool:
	var r := rect(s)
	var c := Vector2(r.position) + Vector2(r.size) * 0.5
	var dx := absf(p.x + 0.5 - c.x) / (r.size.x * 0.5)
	var dy := absf(p.y + 0.5 - c.y) / (r.size.y * 0.5)
	var d := pow(pow(dx, 4.0) + pow(dy, 4.0), 0.25)
	return d < 0.8 + (_u(str(s.id), "edge", p) - 0.5) * 0.35
