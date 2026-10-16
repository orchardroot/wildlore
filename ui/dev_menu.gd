class_name DevMenu
extends RefCounted
## Dev switch `--menu=<name>[:arg]`: boots a new game with a sample party and bag, then opens that menu.
## Used for screenshots (see docs/screens/t9-*.png). Called from Game._dev_boot.

static func arg(cmdline: PackedStringArray) -> String:
	for a in cmdline:
		if a.begins_with("--menu="):
			return a.substr(7)
	return ""

static func boot(game: Node, menu: String) -> void:
	game.new_game()
	var d: GameStateData = game.data
	var mk := func(id: String, lvl: int) -> Creature:
		return Creature.create(game.dex.get_species(id), lvl, game.rng, game.moves)
	var a: Creature = mk.call("spikkin", 12)
	a.take_damage(a.max_hp() / 3)
	var b: Creature = mk.call("kindlet", 10)
	var c: Creature = mk.call("holtling", 9)
	c.take_damage(c.max_hp() * 4 / 5)
	var e: Creature = mk.call("binfox", 8)
	e.hp = 0
	e.status = "stung"
	var f: Creature = mk.call("hootlet", 7)
	f.status = "asleep"
	d.party = [a, b, c, e, f]
	d.ark = [mk.call("croakle", 6), mk.call("pipkin", 4), mk.call("dipling", 9)]
	if menu.begins_with("ark"):  # a fuller Ark, so sorting shows
		for sp in ["bramblehog", "emberdrey", "redbreast", "snowhare", "gritling", "wispet", "cooplet", "raidtail", "bran"]:
			d.ark.append(mk.call(sp, 3 + d.ark.size() * 4 % 23))
	for sp in ["spikkin", "kindlet", "holtling", "binfox", "hootlet", "pipkin", "scuttlet", "croakle"]:
		d.mark_caught(sp)
	for sp in ["dipling", "wispet", "snowhare"]:
		d.mark_seen(sp)
	d.bag = {"cup_of_tea": 5, "flask_of_tea": 2, "smelling_salts": 3, "bakewell_tart": 1, "kendal_mint_cake": 1,
		"wicker_snare": 8, "iron_snare": 2, "lavender_sachet": 3, "map": 1, "fieldbook": 1}
	d.money = 1840
	d.badges = ["a", "b"]
	d.play_seconds = 4980.0
	for t in ["macclesfield", "buxton"]:
		d.set_flag("visited_" + t)
		d.set_flag("station_" + t)
	d.set_flag("last_town", "buxton")
	d.bag["rail_pass"] = 1
	if menu == "map:post":  # `--menu=map:post`: the whole map visited, Champion, every Stone
		for t in Travel.world_map().get("towns", {}):
			d.set_flag("visited_" + t)
			d.set_flag("station_" + t)
		for k in ["brook", "urban", "stone", "storm", "fae", "kin", "tide", "iron", "frost", "spirit"]:
			d.set_flag("badge_" + k)
		d.set_flag("champion")
		d.set_flag("game_complete")
		d.set_flag("last_town", "york")
	if menu.begins_with("relearn"):
		a.level = 20  # past a couple of its moves, so the relearner has something to offer
	if menu.begins_with("shop") and not menu.contains(":"):
		menu = "shop:macc_corner_shop"
	await game.get_tree().process_frame
	var cur := game.get_tree().current_scene
	if cur:
		cur.visible = false  # hide the title so screenshots show the menu alone
	var router := game.get_node("/root/Router")
	var parts := menu.split(":", true, 1)
	if parts[0] in ["summary", "pedia_popup"]:
		var scene: Node = load("res://ui/%s.tscn" % ("summary_screen" if parts[0] == "summary" else "pedia_popup")).instantiate()
		router._menu_layer.add_child(scene)
		scene.setup(parts[1] if parts.size() > 1 else "")
	else:
		router.open_menu(menu)
