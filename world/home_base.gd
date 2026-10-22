class_name HomeBase
extends RefCounted
## Mum's house as a home base. Three things, all built from the save so they fill in as you play:
##  - the trophy shelf in macc_home (a `trophy_shelf` prop): every Wardstone won, Garside's diploma, the Fieldbook
##    awards, County Show rosettes, the Moot Champion title, Pillar of the Community trophies and a brass plaque
##    for each legend caught. Facing it reads them out.
##  - the garden in Macclesfield (six `garden_plot` props with "plot": 1..6): plant a hedgerow material and it
##    grows through seed, sprout and leaf to ready the next in-game day, for 2 to 4 back (one more in season) and
##    now and then a charm or a rare find. A plot is the flag garden_<n> = "<material>@<world minute>@<day>".
##  - visitors: each legend you've caught rests in the garden or the market square, and a couple of Ark residents
##    come round too. They block their tile and have a line when you talk to them.
## Mum notices: the flag home_mum_note is refreshed whenever you walk in (see mum_note), and her script reads it.
## Overworld hooks: dress() once the zone is built, interact() when facing something.

const PLOT := "garden_plot"
const SHELF := "trophy_shelf"
const SEEDS := ["sloes", "hazelnuts", "blackberries", "elderflower", "wild_garlic", "rowan_berry", "hawthorn_berry"]
## When each one is in season (a harvest then gives one more).
const IN_SEASON := {
	"sloes": ["autumn", "winter"], "hazelnuts": ["autumn"], "blackberries": ["summer", "autumn"],
	"elderflower": ["spring", "summer"], "wild_garlic": ["spring"], "rowan_berry": ["autumn"],
	"hawthorn_berry": ["autumn", "winter"],
}
const SPROUT_MINUTES := 120   # in-game minutes (real seconds) from seed to sprout
const GROW_MINUTES := 360     # ...and from sprout to leafy; ready at the next in-game midnight
const MIN_YIELD := 2
const MAX_YIELD := 4
const CHARM_CHANCE := 0.02
const RARE_CHANCE := 0.06
const CHARMS := ["four_leaf_clover", "rowan_sprig", "oak_acorn"]
const RARES := ["honeycomb", "truffle"]
const ARK_VISITORS := 2
const NOTE_FLAG := "home_mum_note"

## The ten Wardstones in the order they're won: [name, keeper, town, the shelf's line].
const STONES := {
	"brook": ["Brook Stone", "Maud", "Buxton", "Still faintly damp. Mum has put a coaster under it."],
	"urban": ["Urban Stone", "Ray", "Liverpool", "It hums a bit like a bus idling. You can't unhear it now."],
	"stone": ["Stone Stone", "Eluned", "Llanberis", "Yes, a Stone Stone. Eluned didn't name it. Slate grey and very heavy for its size."],
	"storm": ["Storm Stone", "Rhys", "Cardiff", "It crackles when the weather's turning. Better than the barometer."],
	"fae": ["Fae Stone", "Morwen", "Glastonbury", "Mum swears it's moved along the shelf on its own. Twice."],
	"kin": ["Kin Stone", "Declan", "Dublin", "Warm to the touch, like someone's just been holding it."],
	"tide": ["Tide Stone", "Nuala", "Galway", "Hold it to your ear and there's the sea. Or the boiler."],
	"iron": ["Iron Stone", "Ruairi", "Belfast", "Riveted, solid, honest. Leaves a little rust ring on the shelf."],
	"frost": ["Frost Stone", "Isla", "Inverness", "Cold enough to keep the milk. Mum has thought about it."],
	"spirit": ["Spirit Stone", "Hester", "York", "It glows a little at night. Mum says it's company."],
}
## Fieldbook milestone awards from Professor Garside (flags fieldbook_<n>; 200 is the diploma).
const AWARDS := {
	25: ["Fieldbook Rosette", "A green rosette: 25 caught. Garside wrote 'Promising' on the back in pencil."],
	50: ["Fieldbook Ribbon", "A blue ribbon: 50 caught. Slightly chewed. Nobody's owning up."],
	100: ["Fieldbook Medal", "A bronze medal on a tartan ribbon: 100 caught. Mum polishes it on Sundays."],
	150: ["Fieldbook Shield", "A little oak shield: 150 caught. Engraved, if a bit wonkily."],
}
## Pillar of the Community trophies (Standing.TROPHY), by nation, as they sit on the shelf: [name, line].
const PILLAR_TROPHIES := {
	"england": ["Freedom of the Shires", "The Freedom of the Shires, tied with its red and white rose. Mum has read every signature. Twice."],
	"wales": ["Carved Lovespoon", "A cherrywood lovespoon from Wales. Mum finds a reason to mention it to the neighbours most days."],
	"scotland": ["Silver Quaich", "A silver quaich from Scotland. Mum has polished it and, just the once, had a sherry out of it."],
	"northern_ireland": ["Ulster Linen Sash", "An Ulster linen sash, folded just so. Mum ironed it, though it didn't need it."],
	"ireland": ["Claddagh Brooch", "A Claddagh brooch from Galway, on a little velvet cushion Mum made specially."],
	"mann": ["Three Legs Badge", "The Manx Three Legs badge. Mum knocked it over and it landed standing up. She hasn't touched it since."],
	"channel_islands": ["Gache Loaf", "A Guernsey gache, wrapped in a tea towel. Mum says it is a fruit loaf and Dad says it is a way of life, and they have not spoken since."],
	"overseas": ["Airbridge Wings", "A pair of enamel RAF wings. Mum asked if you were safe. You said the Airbridge has a very good record. She put them next to the barometer anyway."],
	"abroad": ["Well-Stamped Passport", "Your passport, stamped in Trelew, Halifax, Boston, Bristol (the one in Tennessee) and Roscoff. Mum keeps it in the biscuit tin, which is where the important things go."],
}
const PLAQUE_LINES := [
	"A brass plaque: %s. Mum's put a doily under it.",
	"A brass plaque: %s. Underneath, in Mum's writing: 'Visits. Wipe feet.'",
	"A brass plaque: %s. Polished so bright you can see your nose in it.",
]
const VISITOR_LINES := [
	"%s is dozing on the lawn. It opens one ancient eye, decides you're family, and shuts it again.",
	"%s has flattened Mum's lavender and looks extremely pleased about it.",
	"%s is watching the garden grow. Very, very patiently.",
	"%s nods at you, as one old friend to another.",
	"%s is sunning itself. Somewhere a neighbour is pretending not to stare.",
]
const ARK_LINES := [
	"%s has popped over from the Ark for the afternoon. It's found the good patch of sun.",
	"%s is helping in the garden. Mostly by digging where it shouldn't.",
	"%s came round for a visit and is in no hurry to go back.",
]
## Where visitors rest: the garden lawn first, then round the market square. Kept off paths and doors.
const VISITOR_TILES := [Vector2i(5, 17), Vector2i(7, 16), Vector2i(4, 18), Vector2i(6, 12), Vector2i(19, 13),
	Vector2i(33, 13), Vector2i(19, 17), Vector2i(33, 17), Vector2i(24, 13), Vector2i(28, 13), Vector2i(25, 17), Vector2i(29, 17)]
const GARDEN_ZONE := "macclesfield"
const HOME_ZONE := "macc_home"

# --- the trophy shelf ---------------------------------------------------------------

static func stone_won(data: GameStateData, id: String) -> bool:
	return id in data.badges or data.flag("badge_" + id) == true

## [{kind: stone|diploma|award|rosette|title|pillar|legend, id, name, line}] in shelf order.
static func trophies(data: GameStateData, dex: Dex) -> Array:
	var out := []
	for id in STONES:
		if stone_won(data, id):
			var s: Array = STONES[id]
			out.append({"kind": "stone", "id": id, "name": s[0], "line": "The %s, from Keeper %s in %s. %s" % [s[0], s[1], s[2], s[3]]})
	if data.flag("fieldbook_diploma_given") == true:
		out.append({"kind": "diploma", "id": "diploma", "name": "Fieldbook Diploma",
			"line": "Professor Garside's diploma, framed. Every creature, one Fieldbook. The stamp is a potato. Mum has hung it in excellent light."})
	for n in AWARDS:
		if data.flag("fieldbook_%d" % n) == true:
			out.append({"kind": "award", "id": str(n), "name": AWARDS[n][0], "line": AWARDS[n][1]})
	var shows := Tournament.shows_won(data)
	if shows > 0:
		out.append({"kind": "rosette", "id": "shows", "name": "County Show Rosettes", "n": shows,
			"line": "%d red rosette%s from the County Shows, pinned along the edge of the shelf. Mum irons them." % [shows, "" if shows == 1 else "s"]})
	if Tournament.moot_champion(data):
		out.append({"kind": "title", "id": "moot", "name": "Moot Champion",
			"line": "A framed certificate: Open Moot Champion. Mum has hung it where the vicar can't miss it."})
	for nation in PILLAR_TROPHIES:
		if Standing.tier(data, nation) >= Standing.PILLAR:
			var p: Array = PILLAR_TROPHIES[nation]
			out.append({"kind": "pillar", "id": nation, "name": p[0], "line": p[1]})
	if Punt.has_trophy(data):
		out.append({"kind": "cheque", "id": "cheque", "name": "Giant Novelty Cheque",
			"line": "A giant novelty cheque from the Palace in Douglas, propped beside the cabinet. Mum tells visitors it's from the Premium Bonds."})
	var i := 0
	for id in legends_caught(data, dex):
		var nm := str(dex.get_species(id).get("name", id))
		out.append({"kind": "legend", "id": id, "name": nm, "line": PLAQUE_LINES[i % PLAQUE_LINES.size()] % nm})
		i += 1
	return out

static func legends_caught(data: GameStateData, dex: Dex) -> Array:
	return dex.ids().filter(func(id): return data.caught.has(id) and bool(dex.get_species(id).get("legend", false)))

static func shelf_lines(data: GameStateData, dex: Dex) -> Array:
	var t := trophies(data, dex)
	if t.is_empty():
		return ["Your trophy shelf. Empty, and dusted every Sunday regardless. Mum says she's keeping it for something."]
	var lines := ["Your trophy shelf. Mum has arranged it, rearranged it, and dusted it twice since breakfast."]
	for x in t:
		lines.append(str(x.line))
	return lines

# --- the garden ------------------------------------------------------------------------

static func plot_flag(n: int) -> String:
	return "garden_%d" % n

## {"material", "stage": empty|seed|sprout|growing|ready, "ready": bool}
static func plot_state(data: GameStateData, n: int) -> Dictionary:
	var v: Variant = data.flag(plot_flag(n))
	if not (v is String) or str(v) == "":
		return {"material": "", "stage": "empty", "ready": false}
	var parts := str(v).split("@")
	var mat := parts[0]
	var at := int(parts[1]) if parts.size() > 1 else 0
	var day := int(parts[2]) if parts.size() > 2 else 0
	var stage := "growing"
	if data.day_count > day:
		stage = "ready"
	elif data.world_minutes() - at < SPROUT_MINUTES:
		stage = "seed"
	elif data.world_minutes() - at < SPROUT_MINUTES + GROW_MINUTES:
		stage = "sprout"
	return {"material": mat, "stage": stage, "ready": stage == "ready"}

## The seeds you could plant right now (in the bag).
static func plantable(data: GameStateData) -> Array:
	return SEEDS.filter(func(m): return int(data.bag.get(m, 0)) > 0)

## Plants one of `material` from the bag in plot n. False if the plot's taken, it won't grow or you've none.
static func plant(data: GameStateData, n: int, material: String) -> bool:
	if material not in SEEDS or plot_state(data, n).stage != "empty":
		return false
	if not Bag.new(data.bag).remove(material, 1):
		return false
	data.set_flag(plot_flag(n), "%s@%d@%d" % [material, data.world_minutes(), data.day_count])
	return true

static func in_season(material: String, season: String) -> bool:
	return season in IN_SEASON.get(material, [])

## Picks a ready plot into the bag and clears it: {"items": {id: n}, "bonus": id, "bonus_kind": ""|"charm"|"rare"}.
## Not ready: nothing happens and items is empty.
static func harvest(data: GameStateData, n: int, season: String, rng: Rng) -> Dictionary:
	var st := plot_state(data, n)
	var out := {"items": {}, "bonus": "", "bonus_kind": ""}
	if not st.ready:
		return out
	var mat: String = st.material
	var count := rng.roll_int(MIN_YIELD, MAX_YIELD) + (1 if in_season(mat, season) else 0)
	var bag := Bag.new(data.bag)
	var got := bag.add(mat, count)
	if got > 0:
		out.items[mat] = got
	var b := rng.roll()
	if b < CHARM_CHANCE:
		out.bonus = CHARMS[rng.roll_int(0, CHARMS.size() - 1)]
		out.bonus_kind = "charm"
	elif b < CHARM_CHANCE + RARE_CHANCE:
		out.bonus = RARES[rng.roll_int(0, RARES.size() - 1)]
		out.bonus_kind = "rare"
	if out.bonus != "" and bag.add(str(out.bonus), 1) <= 0:
		out.bonus = ""
		out.bonus_kind = ""
	data.flags.erase(plot_flag(n))
	return out

# --- visitors and Mum ----------------------------------------------------------------------

## Caught legends who come to the garden (as many as there are resting places).
static func legend_visitors(data: GameStateData, dex: Dex) -> Array:
	return legends_caught(data, dex).slice(0, VISITOR_TILES.size())

## A couple of Ark residents, a different pair each in-game day. Returns Creatures.
static func ark_visitors(data: GameStateData) -> Array:
	var out := []
	var n := data.ark.size()
	for i in mini(ARK_VISITORS, n):
		var c: Creature = data.ark[posmod(data.day_count * 7 + i * 3, n)]
		if c not in out:
			out.append(c)
	return out

## What Mum has on her mind: one of the things she could mention, a different one each in-game day.
## "" when there's nothing. Her script compares the flag home_mum_note with these.
static func mum_note(data: GameStateData, dex: Dex) -> String:
	var notes := []
	for n in range(1, 7):
		if plot_state(data, n).ready:
			notes.append("garden_ready")
			break
	if not legends_caught(data, dex).is_empty():
		notes.append("legends")
	if data.flag("fieldbook_diploma_given") == true:
		notes.append("diploma")
	var stones := STONES.keys().filter(func(id): return stone_won(data, id)).size()
	if stones >= STONES.size():
		notes.append("all_stones")
	elif stones > 0:
		notes.append("stones")
	if notes.is_empty():
		return ""
	return notes[posmod(data.day_count, notes.size())]

# --- in the overworld ----------------------------------------------------------------------

static func props_of(z: ZoneData, kind: String) -> Array:
	return z.props.filter(func(pr): return str(pr.get("type", "")) == kind)

static func prop_at(z: ZoneData, p: Vector2i) -> Dictionary:
	for pr in z.props:
		var t := str(pr.get("type", ""))
		if (t == PLOT or t == SHELF) and int(pr.get("x", -1)) == p.x and int(pr.get("y", -1)) == p.y:
			return pr
	return {}

## Builds the shelf, the plots and the visitors into the zone (the overworld's one hook after building a zone).
static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	if z.id == HOME_ZONE:
		data.set_flag(NOTE_FLAG, mum_note(data, Game.dex))
	var shelves := props_of(z, SHELF).filter(func(pr): return not pr.has("part"))
	var plots := props_of(z, PLOT)
	if shelves.is_empty() and plots.is_empty():
		return
	var root := HomeGarden.new()
	root.name = "HomeBase"
	zone_node.add_child(root)
	for pr in shelves:
		var p := Vector2i(int(pr.x), int(pr.y))
		var shelf := HomeMeshes.shelf_node(trophies(data, Game.dex))
		shelf.position = Vector3(p.x + 0.5 + float(pr.get("dx", 0.0)), ZoneBuilder.ground_y(z, p), p.y + 0.5)
		root.add_child(shelf)
	if plots.is_empty():
		return
	root.setup(z, plots)
	_visitors(z, root, data)

static func _visitors(z: ZoneData, root: Node3D, data: GameStateData) -> void:
	var tiles := VISITOR_TILES.filter(func(t): return z.in_bounds(t) and z.walkable(t) and z.warp_at(t).is_empty())
	var who := []
	for id in legend_visitors(data, Game.dex):
		who.append({"species": id, "variant": "", "line": VISITOR_LINES[who.size() % VISITOR_LINES.size()] % str(Game.dex.get_species(id).name)})
	for c in ark_visitors(data):
		who.append({"species": str(c.species.id), "variant": c.variant, "line": ARK_LINES[who.size() % ARK_LINES.size()] % c.display_name()})
	for i in mini(who.size(), tiles.size()):
		var t: Vector2i = tiles[i]
		var w: Dictionary = who[i]
		z.blocked[t] = true  # so you face them rather than walk through them (this zone load only)
		var spr := CharSprite.new()
		root.add_child(spr)
		spr.setup("creature:" + str(w.species))
		spr.set_coat(str(w.variant))
		spr.scale = Vector3.ONE * Follower.scale_for(Cries.size_of(Game.dex.get_species(str(w.species))))
		spr.position = Vector3(t.x + 0.5, ZoneBuilder.ground_y(z, t), t.y + 0.5)
		spr.flip_h = (i % 2) == 1
		root.visitors[t] = w

## Facing a plot, the shelf or a visitor and pressing confirm. True when it was one of ours.
static func interact(ow: Node, p: Vector2i) -> bool:
	var root: Node = ow._zone_node.get_node_or_null("HomeBase") if ow._zone_node else null
	if root and root.visitors.has(p):
		Audio.cry(Game.dex.get_species(str(root.visitors[p].species)))
		await ow.say([str(root.visitors[p].line)])
		return true
	var pr := prop_at(ow.zone, p)
	if pr.is_empty():
		return false
	if str(pr.type) == SHELF:
		await ow.say(shelf_lines(Game.data, Game.dex))
		return true
	await _tend(ow, int(pr.get("plot", 1)))
	if root:
		root.refresh()
	return true

static func _tend(ow: Node, n: int) -> void:
	var st := plot_state(Game.data, n)
	match str(st.stage):
		"ready":
			var r := harvest(Game.data, n, Calendar.season_today(), Game.rng)
			Audio.sfx("step_grass")
			Audio.sfx("item")
			var lines := [Forage.haul_line(r.items, Game.items).replace("You picked", "You harvested")]
			if in_season(str(st.material), Calendar.season_today()):
				lines[0] += " In season, too: a cracking crop."
			if str(r.bonus) != "":
				lines.append("And what's this in the soil? A %s! %s" % [str(Game.items.get_item(str(r.bonus)).get("name", r.bonus)),
					"How lucky is that?" if r.bonus_kind == "charm" else "Mum will want to hear about this."])
			await ow.say(lines)
		"empty":
			var seeds := plantable(Game.data)
			if seeds.is_empty():
				await ow.say(["A neat little bed of dark soil, raked and waiting. Bring back something from the hedgerows to plant: sloes, hazelnuts, blackberries, elderflower, wild garlic, rowan or hawthorn."])
				return
			var opts: Array = seeds.map(func(m): return "%s (%d)" % [Game.items.get_item(m).get("name", m), int(Game.data.bag.get(m, 0))])
			opts.append("Leave it")
			var pick := await _choose(ow, "A bed of good dark soil, raked and waiting. Plant something?", opts)
			if pick < 0 or pick >= seeds.size():
				return
			var mat: String = seeds[pick]
			if plant(Game.data, n, mat):
				Audio.sfx("step_soft")
				var nm := str(Game.items.get_item(mat).get("name", mat))
				await ow.say(["You plant the %s and pat the soil down. It should be ready by tomorrow.%s" % [nm.to_lower(),
					" It's the right time of year for it." if in_season(mat, Calendar.season_today()) else ""]])
		_:
			var nm := str(Game.items.get_item(str(st.material)).get("name", st.material)).to_lower()
			var what: String = {"seed": "Freshly planted %s. Nothing to see yet but hope and soil.",
				"sprout": "The %s has come up: a few brave green shoots.",
				"growing": "The %s is coming on nicely, all leaf. Ready tomorrow."}.get(str(st.stage), "%s") % nm
			await ow.say([what])

static func _choose(ow: Node, text: String, options: Array) -> int:
	var was := Router.busy
	Router.busy = true
	var box: Node = load("res://ui/dialogue_box.tscn").instantiate()
	ow.add_child(box)
	var idx: int = await box.show_choice(text, options)
	box.queue_free()
	Router.busy = was
	return idx

# --- dev: --home=<seed|growing|ready|full> for screenshots ------------------------------------

static func dev_setup(data: GameStateData, mode: String, dex: Dex) -> void:
	if mode == "":
		return
	var stage_back := {"seed": 10, "sprout": SPROUT_MINUTES + 30, "growing": SPROUT_MINUTES + GROW_MINUTES + 30}
	for i in SEEDS.size() - 1:
		var mat: String = SEEDS[i]
		var n := i + 1
		if mode == "ready":
			data.set_flag(plot_flag(n), "%s@%d@%d" % [mat, data.world_minutes() - 600, data.day_count - 1])
		elif mode == "mixed":
			var st: String = ["seed", "sprout", "growing", "ready", "growing", "ready"][i]
			var back: int = 2000 if st == "ready" else int(stage_back[st])
			data.set_flag(plot_flag(n), "%s@%d@%d" % [mat, data.world_minutes() - back, data.day_count - (1 if st == "ready" else 0)])
		elif stage_back.has(mode):
			data.set_flag(plot_flag(n), "%s@%d@%d" % [mat, data.world_minutes() - int(stage_back[mode]), data.day_count])
	if mode == "full" or mode == "ready" or mode == "mixed":
		data.badges = STONES.keys()
		data.set_flag("fieldbook_diploma_given")
		for n in AWARDS:
			data.set_flag("fieldbook_%d" % n)
		for id in ["herne", "nessie", "ddraig", "cusith", "shuck"]:
			data.mark_caught(id)
		data.set_flag(Tournament.SHOW_WINS, 4)
		data.set_flag(Tournament.MOOT_WINS, Tournament.TITLE_WINS)
		for nation in ["england", "wales", "scotland", "ireland"]:
			Standing.add(data, nation, Standing.TIER_POINTS[Standing.PILLAR])
		HomeExtras.dev_setup(data)
