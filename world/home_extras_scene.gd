class_name HomeExtrasScene
extends RefCounted
## The overworld side of the 3.1 home and garden extras (logic in core/home_extras.gd, look in home_extras_meshes.gd).
## Zone props: `souvenir_shelf` ({"first": 1|7, "face": "east"}) and `plaque_board` in Mum's house, and the garden's
## `bird_table`, `bug_hotel` and `pond` in Macclesfield. Hooks: dress() after building a zone, interact() on confirm.

const SHELF := "souvenir_shelf"
const BOARD := "plaque_board"
const KINDS := ["bird_table", "bug_hotel", "pond"]
const PER_SHELF := 6
const ROT := {"east": 90.0, "west": -90.0, "south": 180.0}

static func _mine(z: ZoneData) -> Array:
	return z.props.filter(func(pr): return str(pr.get("type", "")) in [SHELF, BOARD] or str(pr.get("type", "")) in KINDS)

static func prop_at(z: ZoneData, p: Vector2i) -> Dictionary:
	for pr in _mine(z):
		if int(pr.get("x", -1)) == p.x and int(pr.get("y", -1)) == p.y:
			return pr
	return {}

static func _shelf_ids(d: GameStateData, first: int) -> Array:
	var ids := []
	for i in PER_SHELF:
		ids.append(HomeExtras.slot(d, first + i))
	return ids

static func _place(z: ZoneData, node: Node3D, pr: Dictionary) -> void:
	var p := Vector2i(int(pr.x), int(pr.y))
	node.position = Vector3(p.x + 0.5 + float(pr.get("dx", 0.0)), ZoneBuilder.ground_y(z, p), p.y + 0.5 + float(pr.get("dz", 0.0)))
	node.rotation_degrees.y = float(ROT.get(str(pr.get("face", "")), 0.0))

static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	var mine := _mine(z)
	if mine.is_empty():
		return
	var root := Node3D.new()
	root.name = "HomeExtras"
	zone_node.add_child(root)
	var season := Calendar.season_today()
	for pr in mine:
		var t := str(pr.type)
		var node: Node3D
		if t == SHELF:
			node = HomeExtrasMeshes.shelf_node(_shelf_ids(data, int(pr.get("first", 1))))
			node.name = "Shelf%d" % int(pr.get("first", 1))
		elif t == BOARD:
			node = HomeExtrasMeshes.boards_node(HomeExtras.boards(data))
		else:
			node = HomeExtrasMeshes.feature_node(t)
			node.name = t
			if HomeExtras.visitor_here(data, t):
				node.add_child(_visitor_sprite(t, season))
		_place(z, node, pr)
		root.add_child(node)

static func _visitor_sprite(kind: String, season: String) -> Node3D:
	var species := HomeExtras.visitor(kind, season)
	var spr := CharSprite.new()
	spr.name = "Visitor"
	spr.setup("creature:" + species)
	spr.scale = Vector3.ONE * Follower.scale_for(Cries.size_of(Game.dex.get_species(species))) * 0.8
	spr.position = {"bird_table": Vector3(0, 0.8, 0), "bug_hotel": Vector3(0, 1.1, 0.1), "pond": Vector3(0.1, 0.06, 0.12)}[kind]
	return spr

static func interact(ow: Node, p: Vector2i) -> bool:
	var pr := prop_at(ow.zone, p)
	if pr.is_empty():
		return false
	var t := str(pr.type)
	if t == BOARD:
		await ow.say(HomeExtras.board_lines(Game.data))
	elif t == SHELF:
		await _souvenirs(ow)
		_refresh(ow)
	else:
		await _garden(ow, t)
	return true

static func _refresh(ow: Node) -> void:
	var root: Node = ow._zone_node.get_node_or_null("HomeExtras") if ow._zone_node else null
	if root == null:
		return
	for pr in _mine(ow.zone):
		if str(pr.type) != SHELF:
			continue
		var old := root.get_node_or_null("Shelf%d" % int(pr.get("first", 1)))
		if old:
			old.free()
		var node := HomeExtrasMeshes.shelf_node(_shelf_ids(Game.data, int(pr.get("first", 1))))
		node.name = "Shelf%d" % int(pr.get("first", 1))
		_place(ow.zone, node, pr)
		root.add_child(node)

# --- souvenirs -----------------------------------------------------------------------------------

static func _souvenirs(ow: Node) -> void:
	var d := Game.data
	var got := HomeExtras.unlocked(d)
	if got.is_empty():
		await ow.say(["Your souvenir shelf, dusted and ready. Read a heritage plaque on your travels and bring something back for it. Mum has been very clear that tat is welcome."])
		return
	var first := true
	while true:
		var shown := HomeExtras.SOUVENIRS.filter(func(s): return s.id in got)
		var opts := []
		for s in shown:
			var on := false
			for i in range(1, HomeExtras.SLOTS + 1):
				on = on or HomeExtras.slot(d, i) == s.id
			opts.append("%s%s" % [s.name, " (on show)" if on else ""])
		opts.append("Done")
		var q := "Your souvenirs: %d of %d. Pick one to put on the shelf, or to take down." % [shown.size(), HomeExtras.SOUVENIRS.size()] if first else "Anything else?"
		first = false
		var pick := await HomeBase._choose(ow, q, opts)
		if pick < 0 or pick >= shown.size():
			return
		var s: Dictionary = shown[pick]
		var at := 0
		for i in range(1, HomeExtras.SLOTS + 1):
			if HomeExtras.slot(d, i) == s.id:
				at = i
		if at > 0:
			HomeExtras.clear(d, at)
			Audio.sfx("step_soft")
			await ow.say(["You take the %s down and give it a quick dust." % str(s.name).to_lower()])
			_refresh(ow)
			continue
		var free := 0
		for i in range(1, HomeExtras.SLOTS + 1):
			if HomeExtras.slot(d, i) == "":
				free = i
				break
		if free == 0:
			await ow.say(["Every shelf is full. Mum says: 'Rotate them, love. Like a museum.'"])
			continue
		HomeExtras.place(d, free, str(s.id))
		Audio.sfx("item")
		await ow.say([str(s.line)])
		_refresh(ow)

# --- garden visitors -----------------------------------------------------------------------------

const QUIET := {
	"bird_table": "The bird table, scattered with seed. Nobody's in at the moment. Something will be along.",
	"bug_hotel": "A bug hotel: canes, bark and straw, full of tiny lodgers. Nobody at reception right now.",
	"pond": "The garden pond, still and dark. A lily pad twitches. It might be the wind.",
}
const FIRST := {
	"bird_table": "%s has landed on the bird table and is eating like it's paying by the seed.",
	"bug_hotel": "%s has checked into the bug hotel. It looks very pleased with the room.",
	"pond": "%s is at the edge of the pond, with the air of someone who owns it.",
}

static func _garden(ow: Node, kind: String) -> void:
	var d := Game.data
	if not HomeExtras.visitor_here(d, kind):
		await ow.say([QUIET[kind]])
		return
	var season := Calendar.season_today()
	var species := HomeExtras.visitor(kind, season)
	var sp: Dictionary = Game.dex.get_species(species)
	var nm := str(sp.get("name", species))
	var pals := HomeExtras.friends(d, species)
	Audio.cry(sp)
	d.mark_seen(species)
	var intro: String = FIRST[kind] % nm
	if pals > 0:
		intro += " It knows you by now."
	var pick := await HomeBase._choose(ow, intro, ["Befriend it", "Try to catch it", "Leave it be"])
	if pick == 0:
		var r := HomeExtras.befriend(d, kind, season)
		_remove_visitor(ow, kind)
		var lines := ["You sit very still and say nothing. %s edges closer, then closer still." % nm]
		if str(r.gift) != "":
			lines.append("It leaves you %s, with great ceremony, and goes." % _with_article(str(Game.items.get_item(str(r.gift)).get("name", r.gift))))
			Audio.sfx("item")
		else:
			lines.append("It offers you something, but your bag is full. It goes off, offended and delighted.")
		if str(r.reward) != "":
			lines.append("And it has brought something special: %s! You must have made a friend for life." % _with_article(str(Game.items.get_item(str(r.reward)).get("name", r.reward))))
		await ow.say(lines)
	elif pick == 1:
		if Game.data.first_able() == null:
			await ow.say(["You've nobody fit to help. Maybe after a rest."])
			return
		HomeExtras.mark_visited(d, kind)
		_remove_visitor(ow, kind)
		var top := 0
		for c in d.party:
			top = maxi(top, int(c.level))
		var foe := Creature.create(sp, HomeExtras.visit_level(top), Game.rng, Game.moves)
		var result: Dictionary = await Router.battle([foe], {"kind": "wild", "weather": ow.weather, "time": Game.phase(), "stage": ow._stage()})
		await ow._after_battle(result)

static func _with_article(item_name: String) -> String:
	var low := item_name.to_lower()
	if low.ends_with("s") and not low.ends_with("ss"):
		return "some " + low
	return ("an " if low[0] in "aeiou" else "a ") + low

static func _remove_visitor(ow: Node, kind: String) -> void:
	var root: Node = ow._zone_node.get_node_or_null("HomeExtras") if ow._zone_node else null
	var f: Node = root.get_node_or_null(kind) if root else null
	var v: Node = f.get_node_or_null("Visitor") if f else null
	if v:
		v.queue_free()
