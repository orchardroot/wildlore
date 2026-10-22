class_name Forage
extends RefCounted
## Foraging on the routes: a `forage` prop (bramble, hazel, seaweed on the tideline...) gives 1 to 3 materials
## once per in-game day, weighted by the real season and the weather. Now and then there's a rare find, a charm,
## or something that was hiding in there bursts out. Also the crafting benches (`craft_bench` props).
##
## Zone JSON: {"type": "forage", "variant": "bramble", "x": 12, "y": 7}, {"type": "craft_bench", "bench": "kitchen", ...}
## A pick remembers the in-game day in the flag forage_<zone>_<x>_<y>, so it refills each midnight while you play.

const TYPE := "forage"
const BENCH := "craft_bench"
const MIN_PICK := 1
const MAX_PICK := 3
const CHARM_CHANCE := 0.01   # a charm tangled in the hedge
const RARE_CHANCE := 0.05    # a rare material
const STARTLE_CHANCE := 0.05 # a wild creature bursts out
const RAIN := ["drizzle", "downpour"]
const RAIN_MUSHROOMS := 4.0  # mushrooms come up after rain

## variant -> what it gives (base weights), its rare find and the charm you might turn up.
const VARIANTS := {
	"bramble": {"yield": {"blackberries": 6.0, "hawthorn_berry": 2.0, "nettles": 1.0}, "rare": "honeycomb", "charm": "four_leaf_clover"},
	"mushroom_ring": {"yield": {"field_mushrooms": 8.0, "hazelnuts": 1.0}, "rare": "truffle", "charm": "four_leaf_clover"},
	"seaweed": {"yield": {"seaweed": 8.0}, "rare": "sea_glass", "charm": "hag_stone"},
	"hazel": {"yield": {"hazelnuts": 6.0, "field_mushrooms": 1.0, "nettles": 1.0}, "rare": "truffle", "charm": "oak_acorn"},
	"elder": {"yield": {"elderflower": 6.0, "hawthorn_berry": 1.0, "nettles": 1.0}, "rare": "honeycomb", "charm": "four_leaf_clover"},
	"heather": {"yield": {"heather_honey": 4.0, "sheep_wool": 3.0, "peat": 2.0, "rowan_berry": 1.5}, "rare": "honeycomb", "charm": "four_leaf_clover"},
	"slate_heap": {"yield": {"slate_chip": 8.0, "sheep_wool": 1.0}, "rare": "ammonite", "charm": "four_leaf_clover"},
	"nettle_patch": {"yield": {"nettles": 7.0, "wild_garlic": 2.0}, "rare": "honeycomb", "charm": "four_leaf_clover"},
	"blackthorn": {"yield": {"sloes": 6.0, "hawthorn_berry": 2.0, "rowan_berry": 1.0}, "rare": "honeycomb", "charm": "four_leaf_clover"},
	"wild_garlic": {"yield": {"wild_garlic": 7.0, "nettles": 2.0, "field_mushrooms": 1.0}, "rare": "truffle", "charm": "four_leaf_clover"},
}

## How the season scales a material (missing = 1.0). Sloes and blackberries in autumn, elderflower and wild garlic
## in spring, honey in late summer. Out of season there's still a little about.
const SEASON := {
	"blackberries": {"spring": 0.2, "summer": 1.5, "autumn": 4.0, "winter": 0.2},
	"sloes": {"spring": 0.2, "summer": 0.3, "autumn": 4.0, "winter": 1.5},
	"hazelnuts": {"spring": 0.3, "summer": 0.5, "autumn": 4.0},
	"hawthorn_berry": {"spring": 0.3, "summer": 0.5, "autumn": 3.0, "winter": 1.5},
	"rowan_berry": {"spring": 0.2, "summer": 1.5, "autumn": 3.0, "winter": 0.5},
	"elderflower": {"spring": 4.0, "summer": 2.0, "autumn": 0.2, "winter": 0.1},
	"wild_garlic": {"spring": 4.0, "summer": 0.5, "autumn": 0.3, "winter": 0.3},
	"nettles": {"spring": 3.0, "summer": 1.5, "winter": 0.4},
	"field_mushrooms": {"spring": 0.4, "summer": 0.8, "autumn": 3.0, "winter": 0.4},
	"heather_honey": {"spring": 0.3, "summer": 3.0, "autumn": 2.0, "winter": 0.2},
	"sheep_wool": {"spring": 2.0, "summer": 1.5},
}

## A line after the haul, keyed by the main thing picked.
const QUIPS := {
	"blackberries": "Your fingers are purple now.",
	"sloes": "You try one. Your whole face folds in half.",
	"hazelnuts": "A squirrel watches you from a branch, taking notes.",
	"elderflower": "It smells of summer, and very faintly of cat.",
	"wild_garlic": "You will smell of this until Thursday.",
	"field_mushrooms": "Only the ones you're sure of. Mum would be proud.",
	"seaweed": "It's cold, slippery and already in your sleeve.",
	"heather_honey": "The bees grumble but let you have a little.",
	"nettles": "Ow. Ow. Got it. Ow.",
	"slate_chip": "It rings like a tiny bell when you tap it.",
	"peat": "Your hands smell of a Highland fireside.",
	"sheep_wool": "A sheep watches, unimpressed. It wasn't using it.",
	"hawthorn_berry": "Thorns, of course. It's a hawthorn.",
	"rowan_berry": "Bright as a pillar box. Nothing bad crosses a rowan.",
}
## What a picked-clean prop says.
const BARE := {
	"bramble": "Just thorns and a few hard red ones. Come back tomorrow.",
	"mushroom_ring": "Only a ring of darker grass. They'll pop up again overnight.",
	"seaweed": "The tide hasn't brought any more in yet. Tomorrow, maybe.",
	"hazel": "Picked clean. The squirrels look smug about it.",
	"elder": "Nothing left within reach. Tomorrow, then.",
	"heather": "The bees have gone quiet. Try again tomorrow.",
	"slate_heap": "Nothing worth having on top. The heap will settle by tomorrow.",
	"nettle_patch": "Just the old stingers left. Fresh tops tomorrow.",
	"blackthorn": "Bare spines. Come back tomorrow.",
	"wild_garlic": "You've had the best of it. Tomorrow there'll be more.",
}
## What you see when there's something to pick.
const NAMES := {
	"bramble": "bramble", "mushroom_ring": "ring of mushrooms", "seaweed": "tangle of seaweed", "hazel": "hazel",
	"elder": "elder", "heather": "patch of heather", "slate_heap": "slate heap", "nettle_patch": "nettle patch",
	"blackthorn": "blackthorn", "wild_garlic": "patch of wild garlic",
}

# --- logic --------------------------------------------------------------------

static func flag_key(zone_id: String, p: Vector2i) -> String:
	return "forage_%s_%d_%d" % [zone_id, p.x, p.y]

## Ready to pick: never picked, or last picked on an earlier in-game day.
static func is_ready(data: GameStateData, zone_id: String, p: Vector2i) -> bool:
	var last: Variant = data.flag(flag_key(zone_id, p))
	return last == null or int(last) != data.day_count

static func mark_picked(data: GameStateData, zone_id: String, p: Vector2i) -> void:
	data.set_flag(flag_key(zone_id, p), data.day_count)

## The forage prop (or crafting bench) standing on p, or {}.
static func prop_at(z: ZoneData, p: Vector2i) -> Dictionary:
	for pr in z.props:
		var t := str(pr.get("type", ""))
		if (t == TYPE or t == BENCH) and int(pr.get("x", -1)) == p.x and int(pr.get("y", -1)) == p.y:
			return pr
	return {}

static func props_in(z: ZoneData) -> Array:
	return z.props.filter(func(pr): return str(pr.get("type", "")) == TYPE)

static func is_rain(weather: String) -> bool:
	return weather in RAIN

## Material -> weight for this variant, season and weather.
static func weights(variant: String, season: String, weather: String) -> Dictionary:
	var out := {}
	var base: Dictionary = VARIANTS.get(variant, {}).get("yield", {})
	for m in base:
		var w := float(base[m]) * float(SEASON.get(m, {}).get(season, 1.0))
		if m == "field_mushrooms" and is_rain(weather):
			w *= RAIN_MUSHROOMS
		out[m] = w
	return out

## Out of season: everything on it together is less than half what it usually gives, so one pick at most.
static func lean(variant: String, season: String, weather: String) -> bool:
	var now := 0.0
	var usual := 0.0
	var w := weights(variant, season, weather)
	var base: Dictionary = VARIANTS.get(variant, {}).get("yield", {})
	for m in base:
		now += float(w[m])
		usual += float(base[m])
	return now < usual * 0.5

## One weighted choice: `u` in 0..1 walks the cumulative weights (in the variant's own order).
static func choose(w: Dictionary, u: float) -> String:
	var total := 0.0
	for m in w:
		total += float(w[m])
	if total <= 0.0:
		return ""
	var r := clampf(u, 0.0, 0.9999) * total
	for m in w:
		r -= float(w[m])
		if r < 0.0:
			return str(m)
	return str(w.keys().back())

## What one pick turns up: {"items": {id: n}, "bonus": id or "", "bonus_kind": "rare" | "charm" | "", "startled": bool}.
static func roll(variant: String, season: String, weather: String, rng: Rng) -> Dictionary:
	var w := weights(variant, season, weather)
	var got := {}
	var n := rng.roll_int(MIN_PICK, MAX_PICK)
	if lean(variant, season, weather):
		n = MIN_PICK  # out of season: slim pickings
	for i in n:
		var m := choose(w, rng.roll())
		if m != "":
			got[m] = int(got.get(m, 0)) + 1
	var v: Dictionary = VARIANTS.get(variant, {})
	var out := {"items": got, "bonus": "", "bonus_kind": "", "startled": false}
	var b := rng.roll()
	if b < CHARM_CHANCE:
		out.bonus = str(v.get("charm", ""))
		out.bonus_kind = "charm"
	elif b < CHARM_CHANCE + RARE_CHANCE:
		out.bonus = str(v.get("rare", ""))
		out.bonus_kind = "rare"
	out.startled = rng.roll() < STARTLE_CHANCE
	return out

## Picks prop `pr` in zone `z`: rolls, bags it, remembers the day. {"ok", "lines", "startled", "got"}.
## Picked clean already today: ok false and the bare line.
static func pick(data: GameStateData, z: ZoneData, pr: Dictionary, season: String, weather: String, rng: Rng, items: ItemDB) -> Dictionary:
	var p := Vector2i(int(pr.x), int(pr.y))
	var variant := str(pr.get("variant", "bramble"))
	if not is_ready(data, z.id, p):
		return {"ok": false, "lines": [BARE.get(variant, "Nothing more to pick today.")], "startled": false, "got": {}}
	var r := roll(variant, season, weather, rng)
	mark_picked(data, z.id, p)
	var bag := Bag.new(data.bag)
	var got := {}
	for m in r.items:
		var n := bag.add(str(m), int(r.items[m]))
		if n > 0:
			got[m] = n
	var lines := [haul_line(got, items)]
	if str(r.bonus) != "" and items.has(str(r.bonus)) and bag.add(str(r.bonus), 1) > 0:
		got[r.bonus] = int(got.get(r.bonus, 0)) + 1
		lines.append("Oh! Tucked underneath: %s. %s" % [_one(str(r.bonus), items),
			"How lucky is that?" if r.bonus_kind == "charm" else "You don't see one of those every day."])
	return {"ok": true, "lines": lines, "startled": bool(r.startled), "got": got}

## "You picked 2 Blackberries. Your fingers are purple now." (or "a Blackberry", or "2 Sloes and a Hawthorn Berry").
static func haul_line(got: Dictionary, items: ItemDB) -> String:
	if got.is_empty():
		return "Your bag is stuffed with that already. You leave it for the birds."
	var parts := []
	var main := ""
	var most := 0
	for m in got:
		var n := int(got[m])
		parts.append(_one(str(m), items) if n == 1 else "%d %s" % [n, items.get_item(str(m)).get("name", m)])
		if n > most:
			most = n
			main = str(m)
	var list: String = parts[0] if parts.size() == 1 else ", ".join(parts.slice(0, parts.size() - 1)) + " and " + str(parts.back())
	return ("You picked %s. %s" % [list, QUIPS.get(main, "")]).strip_edges()

static func _one(id: String, items: ItemDB) -> String:
	var it := items.get_item(id)
	return str(it.get("one", "a " + str(it.get("name", id))))

## A startled creature from the zone's grass table, or {}.
static func startled_encounter(z: ZoneData, phase: String, weather: String, rng: Rng) -> Dictionary:
	var list := Encounters.candidates(z, "grass", phase, weather)
	if list.is_empty():
		return {}
	var e := Encounters.pick_entry(list, rng.roll())
	var lo := int(e.get("min", 2))
	return {"species": str(e.species), "level": rng.roll_int(lo, maxi(lo, int(e.get("max", lo))))}

# --- in the overworld ---------------------------------------------------------

## Builds the forage props and benches into the zone's scenery (called once the zone node is built).
static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	var root: Node3D = null
	for pr in z.props:
		var t := str(pr.get("type", ""))
		if t != TYPE and t != BENCH:
			continue
		if root == null:
			root = Node3D.new()
			root.name = "Forage"
			zone_node.add_child(root)
		var p := Vector2i(int(pr.x), int(pr.y))
		var y := ZoneBuilder.ground_y(z, p) + (0.9 if z.tile_at(p) == "counter" else 0.0)
		var n := bench_node(str(pr.get("bench", "kitchen"))) if t == BENCH else prop_node(str(pr.get("variant", "bramble")))
		n.name = "F_%d_%d" % [p.x, p.y]
		n.position = Vector3(p.x + 0.5, y, p.y + 0.5)
		if t == TYPE:
			n.rotation.y = float(hash(p) % 628) / 100.0
			n.scale = Vector3.ONE * 1.2  # a touch bigger than the scenery, so it reads as something to pick
		root.add_child(n)
		if t == TYPE:
			show_ready(n, is_ready(data, z.id, p))

static func show_ready(n: Node, ready: bool) -> void:
	for k in ["Ready", "Sparkle"]:
		var c := n.get_node_or_null(k)
		if c:
			c.visible = ready
	var bare := n.get_node_or_null("Bare")
	if bare:
		bare.visible = not ready

## Facing a forage prop or a bench and pressing confirm. True when it was one of ours.
static func interact(ow: Node, p: Vector2i) -> bool:
	var pr := prop_at(ow.zone, p)
	if pr.is_empty():
		return false
	if str(pr.type) == BENCH:
		await ScriptRunner.start(ow, [{"do": "craft", "bench": str(pr.get("bench", "kitchen"))}])
		return true
	var res := pick(Game.data, ow.zone, pr, Calendar.season_today(), str(ow.weather), Game.rng, Game.items)
	var node: Node = ow._zone_node.get_node_or_null("Forage/F_%d_%d" % [p.x, p.y]) if ow._zone_node else null
	if node:
		show_ready(node, false)
	if res.ok:
		Bus.foraged.emit(ow.zone.id)
		Audio.sfx("step_grass")
		Audio.sfx("item")
	await ow.say(res.lines)
	if res.startled and Game.data.first_able() != null:
		var enc := startled_encounter(ow.zone, Game.phase(), str(ow.weather), Game.rng)
		if not enc.is_empty() and Game.dex.has(str(enc.species)):
			var foe := Creature.create(Game.dex.get_species(str(enc.species)), int(enc.level), Game.rng, Game.moves)
			Forms.assign_wild(foe, ow.zone.region, str(ow.zone.id), Game.moves)
			await ow.say(["Something bursts out of the %s!" % NAMES.get(str(pr.get("variant", "")), "undergrowth")])
			Game.data.mark_seen(str(enc.species))
			var result: Dictionary = await Router.battle([foe], {"kind": "wild", "weather": ow.weather, "time": Game.phase(), "stage": ow._stage()})
			await ow._after_battle(result)
	return true

# --- meshes -------------------------------------------------------------------

static var _mesh_cache := {}
static var _sparkle_mat: StandardMaterial3D

## A forage prop: "Base" (always), "Ready" (the fruit or flowers) and "Bare" (picked clean), plus a "Sparkle".
static func prop_node(variant: String) -> Node3D:
	Meshes.materials()
	var n := Node3D.new()
	for part in ["Base", "Ready", "Bare"]:
		var m := part_mesh(variant, part)
		if m == null:
			continue
		var mi := MeshInstance3D.new()
		mi.name = part
		mi.mesh = m
		mi.material_override = Meshes.solid
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if part != "Base" else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		n.add_child(mi)
	var sp := MeshInstance3D.new()
	sp.name = "Sparkle"
	sp.mesh = _cached("sparkle", func(): return _sparkle())
	sp.material_override = _sparkle_material()
	sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sp.position.y = _top(variant) + 0.12
	n.add_child(sp)
	return n

## A bench's tools on the counter top: a mixing bowl and rolling pin, or a vice and a coil of twine.
static func bench_node(bench: String) -> Node3D:
	Meshes.materials()
	var mi := MeshInstance3D.new()
	mi.mesh = _cached("bench_" + bench, func(): return _bench_mesh(bench))
	mi.material_override = Meshes.solid
	return mi

static func _cached(key: String, make: Callable) -> ArrayMesh:
	if not _mesh_cache.has(key):
		_mesh_cache[key] = make.call()
	return _mesh_cache[key]

static func part_mesh(variant: String, part: String) -> ArrayMesh:
	var key := variant + ":" + part
	if not _mesh_cache.has(key):
		_mesh_cache[key] = _build(variant, part)
	return _mesh_cache[key]

static func _top(variant: String) -> float:
	return {"bramble": 0.7, "mushroom_ring": 0.15, "seaweed": 0.25, "hazel": 1.1, "elder": 1.0, "heather": 0.3,
		"slate_heap": 0.5, "nettle_patch": 0.55, "blackthorn": 0.8, "wild_garlic": 0.2}.get(variant, 0.6)

static func _sparkle_material() -> StandardMaterial3D:
	if _sparkle_mat == null:
		_sparkle_mat = StandardMaterial3D.new()
		_sparkle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_sparkle_mat.vertex_color_use_as_albedo = true
		_sparkle_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	return _sparkle_mat

## Three little four-point stars (billboarded), cream and gold.
static func _sparkle() -> ArrayMesh:
	var st := Meshes._st()
	for s in [[Vector3(0, 0, 0), 0.09, Color("fff6d0")], [Vector3(0.16, 0.1, 0), 0.055, Color("ffe08a")], [Vector3(-0.14, 0.06, 0), 0.045, Color("ffffff")]]:
		var c: Vector3 = s[0]
		var r: float = s[1]
		var col: Color = s[2]
		var w := r * 0.28
		Meshes._quad(st, c + Vector3(-w, 0, 0), c + Vector3(0, r, 0), c + Vector3(w, 0, 0), c + Vector3(0, -r, 0), col)
		Meshes._quad(st, c + Vector3(-r, 0, 0), c + Vector3(0, w, 0), c + Vector3(r, 0, 0), c + Vector3(0, -w, 0), col)
	return Meshes._finish(st)

static func _dots(st: SurfaceTool, rng: RandomNumberGenerator, n: int, centre: Vector3, spread: Vector3, size: float, cols: Array) -> void:
	for i in n:
		var p := centre + Vector3(rng.randf_range(-spread.x, spread.x), rng.randf_range(-spread.y, spread.y), rng.randf_range(-spread.z, spread.z))
		Meshes.box(st, p - Vector3.ONE * size * 0.5, Vector3.ONE * size, cols[i % cols.size()])

static func _build(variant: String, part: String) -> ArrayMesh:
	var rng := Meshes._rng(hash(variant + part))
	var st := Meshes._st()
	var empty := true
	match [variant, part]:
		["bramble", "Base"]:
			Meshes.blob(st, Vector3(0, 0.3, 0), Vector3(0.42, 0.32, 0.38), Color("3d5e2c"), rng, 0.3)
			Meshes.blob(st, Vector3(0.15, 0.5, 0.05), Vector3(0.24, 0.2, 0.24), Color("4a6b30"), rng, 0.3)
			empty = false
		["bramble", "Ready"]:
			_dots(st, rng, 16, Vector3(0, 0.42, 0), Vector3(0.38, 0.22, 0.36), 0.09, [Color("2b1d33"), Color("3b1f47"), Color("2b1d33"), Color("8a2440")])
			empty = false
		["bramble", "Bare"]:
			_dots(st, rng, 5, Vector3(0, 0.42, 0), Vector3(0.34, 0.2, 0.32), 0.05, [Color("b8344a"), Color("6f8a3a")])
			empty = false
		["mushroom_ring", "Base"]:
			for i in 9:
				var a := TAU * i / 9.0
				Meshes.box(st, Vector3(cos(a) * 0.36 - 0.07, 0, sin(a) * 0.36 - 0.07), Vector3(0.14, 0.02, 0.14), Color("3f6a2e"))
			empty = false
		["mushroom_ring", "Ready"]:
			for i in 7:
				var a := TAU * i / 7.0 + 0.3
				var p := Vector3(cos(a) * 0.34, 0, sin(a) * 0.34)
				var h := rng.randf_range(0.08, 0.14)
				Meshes.cylinder(st, p, 0.03, h, 5, Color("eee6d2"))
				Meshes.blob(st, p + Vector3(0, h, 0), Vector3(0.08, 0.045, 0.08), Color("f2ead8") if i % 3 else Color("c8a27a"), rng, 0.1)
			empty = false
		["mushroom_ring", "Bare"]:
			for i in 4:
				var a := TAU * i / 4.0 + 0.6
				Meshes.cylinder(st, Vector3(cos(a) * 0.34, 0, sin(a) * 0.34), 0.025, 0.03, 5, Color("d8cfbb"))
			empty = false
		["seaweed", "Base"]:
			Meshes.blob(st, Vector3(0, 0.08, 0), Vector3(0.36, 0.12, 0.3), Color("7b766a"), rng, 0.25)
			empty = false
		["seaweed", "Ready"]:
			for i in 9:
				var a := rng.randf() * TAU
				var p := Vector3(cos(a), 0, sin(a)) * rng.randf_range(0.05, 0.32) + Vector3(0, 0.12, 0)
				Meshes.box(st, p, Vector3(rng.randf_range(0.18, 0.3), 0.04, 0.07), [Color("5b5a2a"), Color("6f6a2c"), Color("3f4f2a")][i % 3])
			_dots(st, rng, 5, Vector3(0, 0.2, 0), Vector3(0.25, 0.03, 0.22), 0.05, [Color("8a7a2e")])
			empty = false
		["seaweed", "Bare"]:
			Meshes.box(st, Vector3(-0.1, 0.16, -0.03), Vector3(0.16, 0.03, 0.05), Color("4a4a2a"))
			empty = false
		["hazel", "Base"]:
			for i in 5:
				var a := TAU * i / 5.0
				Meshes.cylinder(st, Vector3(cos(a) * 0.1, 0, sin(a) * 0.1), 0.035, 0.75 + 0.08 * (i % 3), 5, Color("7a5a3e"))
			Meshes.blob(st, Vector3(0, 0.85, 0), Vector3(0.45, 0.3, 0.42), Color("5c7f3a"), rng, 0.25)
			empty = false
		["hazel", "Ready"]:
			for i in 7:
				var p := Vector3(rng.randf_range(-0.36, 0.36), rng.randf_range(0.62, 0.9), rng.randf_range(-0.34, 0.34))
				Meshes.box(st, p - Vector3(0.05, 0.05, 0.05), Vector3(0.1, 0.1, 0.1), Color("9a6a3a"))
				Meshes.box(st, p - Vector3(0.06, -0.03, 0.06), Vector3(0.12, 0.04, 0.12), Color("9ab84a"))
			empty = false
		["elder", "Base"]:
			Meshes.cylinder(st, Vector3.ZERO, 0.06, 0.55, 6, Color("8a7a62"))
			Meshes.blob(st, Vector3(0, 0.75, 0), Vector3(0.48, 0.3, 0.44), Color("4f7a3a"), rng, 0.25)
			empty = false
		["elder", "Ready"]:
			for i in 7:
				var p := Vector3(rng.randf_range(-0.38, 0.38), rng.randf_range(0.8, 1.0), rng.randf_range(-0.36, 0.36))
				Meshes.box(st, p - Vector3(0.09, 0, 0.09), Vector3(0.18, 0.04, 0.18), Color("f4eccc"), Color("fbf6e2"))
			empty = false
		["heather", "Base"]:
			for i in 7:
				var p := Vector3(rng.randf_range(-0.36, 0.36), 0, rng.randf_range(-0.36, 0.36))
				Meshes.blob(st, p + Vector3(0, 0.1, 0), Vector3(0.14, 0.12, 0.14), Color("6a4a66").lightened(rng.randf_range(-0.05, 0.1)), rng, 0.3)
			empty = false
		["heather", "Ready"]:
			# a straw skep on a flat stone: the honey's in there
			Meshes.box(st, Vector3(0.05, 0, -0.2), Vector3(0.32, 0.06, 0.3), Color("8c8270"))
			Meshes.blob(st, Vector3(0.21, 0.2, -0.05), Vector3(0.15, 0.16, 0.15), Color("c8a35a"), rng, 0.05)
			_dots(st, rng, 4, Vector3(0.21, 0.42, -0.05), Vector3(0.15, 0.06, 0.15), 0.035, [Color("2a2418"), Color("e8b83a")])
			empty = false
		["slate_heap", "Base"]:
			for i in 5:
				var s := 0.7 - i * 0.12
				Meshes.box(st, Vector3(-s * 0.5 + rng.randf_range(-0.04, 0.04), i * 0.08, -s * 0.45), Vector3(s, 0.07, s * 0.9), Color("5b6470").lightened(rng.randf_range(-0.06, 0.1)))
			empty = false
		["slate_heap", "Ready"]:
			for i in 4:
				Meshes.box(st, Vector3(rng.randf_range(-0.25, 0.1), 0.41 + i * 0.012, rng.randf_range(-0.2, 0.08)), Vector3(0.14, 0.015, 0.1), Color("7c8a9c"), Color("a8b8cc"))
			empty = false
		["nettle_patch", "Base"]:
			for i in 12:
				var p := Vector3(rng.randf_range(-0.38, 0.38), 0, rng.randf_range(-0.38, 0.38))
				var a := rng.randf() * TAU
				var side := Vector3(cos(a), 0, sin(a)) * 0.07
				var h := rng.randf_range(0.35, 0.5)
				Meshes._tri(st, p - side, p + side, p + Vector3(0, h, 0), Color("3f6a30"))
				Meshes._tri(st, p + side, p - side, p + Vector3(0, h, 0), Color("365c2a"))
			empty = false
		["nettle_patch", "Ready"]:
			_dots(st, rng, 10, Vector3(0, 0.45, 0), Vector3(0.36, 0.06, 0.36), 0.08, [Color("8cc04a"), Color("a2d05a")])
			empty = false
		["blackthorn", "Base"]:
			Meshes.cylinder(st, Vector3.ZERO, 0.05, 0.3, 5, Color("2e2420"))
			Meshes.blob(st, Vector3(0, 0.5, 0), Vector3(0.44, 0.3, 0.4), Color("34482a"), rng, 0.35)
			empty = false
		["blackthorn", "Ready"]:
			_dots(st, rng, 14, Vector3(0, 0.55, 0), Vector3(0.4, 0.22, 0.36), 0.1, [Color("4f5f9a"), Color("6474ae"), Color("3e4a80")])
			empty = false
		["blackthorn", "Bare"]:
			for i in 6:
				var p := Vector3(rng.randf_range(-0.35, 0.35), rng.randf_range(0.4, 0.75), rng.randf_range(-0.3, 0.3))
				Meshes.box(st, p, Vector3(0.02, 0.12, 0.02), Color("2e2420"))
			empty = false
		["wild_garlic", "Base"]:
			for i in 14:
				var p := Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4))
				var a := rng.randf() * TAU
				var d := Vector3(cos(a), 0, sin(a))
				var s := Vector3(-d.z, 0, d.x) * 0.05
				Meshes._quad(st, p - s, p + s, p + d * 0.2 + s * 0.6 + Vector3(0, 0.12, 0), p + d * 0.2 - s * 0.6 + Vector3(0, 0.12, 0), Color("3f7a34").lightened(rng.randf_range(-0.05, 0.1)))
			empty = false
		["wild_garlic", "Ready"]:
			for i in 6:
				var p := Vector3(rng.randf_range(-0.32, 0.32), 0, rng.randf_range(-0.32, 0.32))
				Meshes.box(st, p, Vector3(0.015, 0.18, 0.015), Color("4f8a3a"))
				_dots(st, rng, 3, p + Vector3(0, 0.2, 0), Vector3(0.03, 0.01, 0.03), 0.035, [Color("ffffff"), Color("f2f0e6")])
			empty = false
	if empty:
		return null
	return Meshes._finish(st)

static func _bench_mesh(bench: String) -> ArrayMesh:
	var rng := Meshes._rng(hash(bench))
	var st := Meshes._st()
	if bench == "kitchen" or bench == "hob":
		# a mixing bowl, a rolling pin and a jar of something purple
		Meshes.cylinder(st, Vector3(-0.15, 0, 0), 0.16, 0.12, 8, Color("e8e0cc"))
		Meshes.blob(st, Vector3(-0.15, 0.1, 0), Vector3(0.12, 0.03, 0.12), Color("c8a070"), rng, 0.1)
		Meshes.box(st, Vector3(0.05, 0, 0.12), Vector3(0.32, 0.05, 0.05), Color("c8a070"))
		Meshes.cylinder(st, Vector3(0.24, 0, -0.14), 0.06, 0.14, 6, Color("4a2a4a"))
	else:
		# a little vice, a coil of twine and a hazel wand
		Meshes.box(st, Vector3(-0.3, 0, -0.1), Vector3(0.16, 0.14, 0.18), Color("5a6068"))
		Meshes.box(st, Vector3(-0.32, 0.14, -0.04), Vector3(0.2, 0.04, 0.06), Color("6a7078"))
		Meshes.cylinder(st, Vector3(0.1, 0, 0.05), 0.09, 0.07, 8, Color("b89a62"))
		Meshes.box(st, Vector3(-0.05, 0, -0.22), Vector3(0.38, 0.03, 0.03), Color("8a6a4a"))
	return Meshes._finish(st)
