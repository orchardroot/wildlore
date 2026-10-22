extends RefCounted
## Builds one fully-played save (every system that writes into a save, through its real API) and writes it as JSON to
## the path after "--". tools/gen_save_fixtures.py then trims it to each released version's shape.
## godot --headless --path . -s res://tools/gen_save_fixtures.gd -- /tmp/full_save.json

func run(out_path: String) -> void:
	var dex := Dex.load_default()
	var mdb := MoveDB.load_default()
	var d := GameStateData.new()
	d.player_name = "Jo"
	d.rival_name = "Kit"
	d.zone_id = "whitby"
	d.pos = Vector2i(14, 9)
	d.facing = "left"
	d.play_seconds = 41000.0
	d.clock_minutes = 755
	d.day_count = 31
	d.rng_seed = 8675309
	d.weather = "drizzle"
	d.weather_region = "peak"
	d.weather_until = 52000
	d.money = 12840
	d.euros = 310
	d.purses = {"BMD": 80, "KYD": 25}
	var party := [["pipkin", 24, "brash", "Pip", "horseshoe", ""], ["kindlet", 21, "calm", "", "", "frost"],
		["barnling", 18, "steady", "Barney", "", ""], ["baskling", 16, "brash", "", "", ""]]
	var uid := 1
	for p in party:
		d.party.append(_mon(dex, mdb, p, uid))
		uid += 1
	for sid in ["afanc", "azurana", "bathlet", "beaconet", "binfox", "barkdeer"]:
		d.ark.append(_mon(dex, mdb, [sid, 9 + uid, "steady", "", "", ""], uid))
		uid += 1
	d.bag = {"cup_of_tea": 5, "sloes": 4, "show_rosette": 2, "haddock": 3}
	d.badges = ["peak", "mersey", "potteries", "brook", "stone", "tide"]
	for b in d.badges:
		d.set_flag("badge_" + b, true)
	for t in ["macclesfield", "buxton", "whitby", "hull", "lancaster", "york"]:
		d.set_flag("visited_" + t, true)
	d.set_flag("met_kit", true)
	d.set_flag("last_town", "whitby")
	d.set_flag("quiz_score", 4)
	d.set_flag("ch2_started", true)
	for sp in ["pipkin", "kindlet", "barnling", "baskling", "afanc"]:
		d.mark_seen(sp)
		d.mark_caught(sp)
	d.last_sanctuary = {"zone": "whitby", "pos": [3, 4]}
	for k in ["steps", "wins_wild", "wins_trainer", "caught", "train_trips", "money_earned", "teas", "rained_on",
			"fish_caught", "goods_sold", "dishes_cooked", "darts_won", "crabs_caught", "show_rosettes", "sheepdog_trials",
			"rows_rung", "walls_built", "games_won", "pulls_sung", "conkers_won"]:
		d.stats[k] = 3 + k.length()
	d.stats["steps"] = 24000
	d.stats["money_earned"] = 31000

	# 2.0 systems
	d.party[1].variant = "frost"
	Coats.record_caught(d, d.party[1])
	Standing.add(d, "wales", 12)
	Standing.add(d, "scotland", 40)
	var job := str(Jobs.offers(d, "macclesfield")[0].id)
	Jobs.accept(d, job, "macclesfield")
	var site := str(Rewild.sites()[0].id)
	Rewild.contribute(d, site)
	Rewild.contribute(d, site)
	HomeBase.plant(d, 2, "sloes")
	Tournament.note_moot_fight(d, true)
	d.set_flag("keeper_side_maud", true)
	d.set_flag(Postcards.flag_key("first"), "2026-10-18")
	# 3.0 systems: markets, bank, Regulars' goodwill
	d.set_flag("punt_biggest", 40)
	d.set_flag(Wallet.WELCOME_FLAG, "")
	d.set_flag(Wallet.HAD_EUROS_FLAG, true)
	d.markets.h = {str(Markets.companies()[0].id): {"n": 12, "cost": 600, "since": 20}}
	d.markets.trades = 3
	d.set_flag(BuildingSociety.FLAG, {"loan": {}, "save": {"GBP": {"bal": 500, "since": 25}}, "mum": {}, "mail": [], "log": []})
	# 3.3 systems
	d.set_flag("festivals_done_whitby_regatta", 2)
	d.set_flag("home_souv_1", "postcard")
	d.set_flag("home_visit_1", 28)
	# 3.5 systems
	d.set_flag(Deeds.FLAG_PREFIX + "allotment_lancaster", {"owned": true, "tier": 1, "store": {"sloes": 4}, "till": 120,
		"rates_due": 0, "manager": "", "last_day": 30, "coll": 30, "paid": 900, "accrue": 0, "bill": 35, "stmt": 55, "log": []})
	d.set_flag(Deeds.POST_FLAG, {"bills": [], "log": [], "tax": 0})
	d.set_flag(Trade.GLUT_FLAG, {"haddock": 2})
	d.set_flag(Trade.FRESH_FLAG, {"haddock": 30})
	d.set_flag(Trades.SKY_FLAG, 0.15)
	d.set_flag(Regulars.flag_key("ned"), {"favour": 2, "pts": 5, "gift_day": 29, "met": true, "letter": false, "manager": false})
	d.set_flag("fish_day", 30)
	d.set_flag("fish_casts", 2)
	d.set_flag(ShowClasses.FLAG_PREFIX + "best_in_show", true)
	d.set_flag(ShowClasses.WINS_PREFIX + "best_in_show", 2)
	d.set_flag("ring_done_whitby", true)
	# 3.7 systems
	d.set_flag("guild_ramblers", true)
	d.set_flag(Stud.FLAG_PAID + "30", 120)
	d.set_flag(Stud.FLAG_UID, 3)
	d.set_flag("book_ideas", {"dominance": true})
	d.set_flag("book_loci", {"coat": true, "mark": true})
	d.set_flag("book_log", ["Pip x Kindlet: Pipkin"])
	d.set_flag(Breeding.LOG_COUNT, 1)
	d.set_flag(Breeding.LOG + "1", {"day": 29, "kind": "same_line", "species": "pipkin", "child_uid": 3, "sire_uid": 1,
		"dam_uid": 2, "sire_species": "pipkin", "dam_species": "pipkin", "sport": false, "sport_locus": "",
		"sire": {}, "dam": {}, "child": {}})
	d.set_flag(Breeding.UID_COUNTER, 6)
	# a pairing in two baskets (one already walked off) and a Roslin reading, through the real Breeding/Stud code
	d.stats["steps"] = 24000
	var sire := _mon(dex, mdb, ["pipkin", 20, "brash", "Rex", "", ""], 90)
	var dam := _mon(dex, mdb, ["pipkin", 20, "calm", "Dot", "", ""], 91)
	sire.sex = "m"
	dam.sex = "f"
	sire.friendship = 255
	dam.friendship = 255
	for slot in 2:
		d.day_count += 1
		var r := Breeding.start(d, sire, dam, "whitby", dex, mdb, Rng.new(5 + slot), "spring")
		print("breeding start: ", r)
	var b0: Dictionary = d.flag(Breeding._basket_key(0))
	if not b0.is_empty():
		b0["steps_due"] = 23000
	d.set_flag(Stud.FLAG_TESTED, [d.party[0].uid])
	d.set_flag(Stud.FLAG_OUT, DailyKey.stamp(d))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(d.to_dict(), "\t", true))
	f.close()
	print("wrote ", out_path)

func _mon(dex: Dex, mdb: MoveDB, p: Array, uid: int) -> Creature:
	var c := Creature.create(dex.get_species(p[0]), p[1], Rng.new(uid * 7), mdb)
	c.nature = p[2]
	c.nickname = p[3]
	c.held = p[4]
	c.variant = p[5]
	c.xp = c.level * c.level * c.level
	c.friendship = 100
	c.uid = uid
	var made := Genetics.derive(c)
	c.genome = made.genome
	c.sex = made.sex
	return c
