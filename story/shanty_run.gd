class_name ShantyRun
extends RefCounted
## The `sing` and `conkers` story commands.
##   {"do": "sing", "who": "Old Shantyman"}        pick a shanty and sing it with the pub
##   {"do": "conkers", "who": "Conker Kid"}         pick up, season and play conkers (autumn)
## Rules live in Shanties and Conkers; the screens are ui/shanty_screen.gd and ui/conker_screen.gd.

var cmd: Commands
var host

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func sing(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var who := str(c.get("who", "Shantyman"))
	var ss: Array = Shanties.shanties()
	var opts: Array = []
	for s in ss:
		opts.append("%s (%s)%s" % [str(s.name), str(s.kind).to_lower(), " *" if data.flags.has(Shanties.FLAG_FIRST + str(s.id)) else ""])
	opts.append("Not tonight")
	var i: int = await host.choice("Pull on the beat when the line lights up. A shantyman sings the verse and the crew heaves together.", opts)
	if i >= ss.size():
		await host.say(who, "Fair enough. Mind, the room's not going to haul itself.")
		return
	var s: Dictionary = ss[i]
	var res = await host.open_menu("shanty:" + str(s.id))
	if not (res is Dictionary) or bool(res.get("quit", false)):
		await host.say(who, "Gone quiet on us? We'll finish the chorus without you. We always do.")
		return
	var hits := int(res.hits)
	var pulls := int(res.pulls)
	var out := Shanties.finish(data, s, hits, pulls)
	if not Shanties.clean(hits, pulls):
		await host.say(who, "%d of %d pulls together. A crew only hauls when it hauls as one. Have another go." % [hits, pulls])
		return
	await host.say(who, "%d of %d pulls together. That's a good heave." % [hits, pulls])
	await host.say(who, str(s.fact))
	if bool(out.first):
		var pl: Dictionary = Shanties.cfg().get("plaque", {})
		if not pl.is_empty():
			await host.say(str(pl.title), str(pl.text))
	if int(out.tip) > 0:
		var paid := Wallet.earn_here(data, int(out.tip), host.zone_id())
		await host.sfx("item")
		await host.say(who, "The hat goes round for the singers: %s, and your share." % Wallet.fmt(int(paid.amount), str(paid.cur)))

func conkers(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var who := str(c.get("who", "Conker Kid"))
	var autumn := Conkers.in_season(Calendar.season_today())
	var opts: Array = []
	var acts: Array = []
	if autumn and not Conkers.picked_today(data):
		opts.append("Pick up a conker")
		acts.append("pick")
	if Conkers.bag_count(data, Conkers.ITEM_FRESH) > 0 and not Conkers.curing(data):
		opts.append("Put a conker in the drawer")
		acts.append("cure")
	if Conkers.curing(data) and Conkers.days_left(data) <= 0:
		opts.append("Take your seasoned conker")
		acts.append("collect")
	if autumn and (Conkers.bag_count(data, Conkers.ITEM_SEASONED) + Conkers.bag_count(data, Conkers.ITEM_FRESH)) > 0:
		opts.append("Play a match")
		acts.append("play")
	if not autumn:
		await host.say(who, "Conkers? Not now. The trees are bare and the chestnuts are all gone. Come back in autumn, when they drop.")
	elif acts.is_empty():
		await host.say(who, "You've had your conker for the day. Season it a few days in the drawer and bring it back.")
	if acts.is_empty():
		if Conkers.curing(data):
			await host.say(who, "Your conker needs %d more days in the drawer. No vinegar, no oven. That's cheating." % Conkers.days_left(data))
		return
	opts.append("Not today")
	var i: int = await host.choice("Horse chestnuts, a string and a rival. What'll it be?", opts)
	if i >= acts.size():
		await host.say(who, "Right. They'll still be on the ground tomorrow.")
		return
	match acts[i]:
		"pick":
			if Conkers.pick_up(data):
				await host.sfx("item")
				await host.say("", "You find a shiny conker in its split green case and put it in your bag.")
			else:
				await host.say(who, "Your bag's too full for a conker. Even a small one.")
		"cure":
			Conkers.start_cure(data)
			await host.say(who, "In the drawer it goes. About %d days, and not a drop of vinegar." % Conkers.season_days())
		"collect":
			if Conkers.collect(data):
				await host.sfx("item")
				await host.say(who, "Hard as a pebble. That's a proper seasoned conker. Drill it, thread it, and go and find someone to challenge.")
			else:
				await host.say(who, "Your bag's full. Make room and ask again.")
		"play":
			await _match(who)

func _match(who: String) -> void:
	var data: GameStateData = host.data
	var rs: Array = Conkers.rivals()
	var ropts: Array = []
	for r in rs:
		ropts.append(str(r.who))
	ropts.append("Not just now")
	var i: int = await host.choice("Who will you challenge?", ropts)
	if i >= rs.size():
		return
	var r: Dictionary = rs[i]
	var seasoned := Conkers.bag_count(data, Conkers.ITEM_SEASONED) > 0
	var id: String = Conkers.ITEM_SEASONED if seasoned else Conkers.ITEM_FRESH
	var wins := int(data.flags.get(Conkers.FLAG_ONER, 0))
	var ner := Conkers.ner_name(wins)
	Bag.new(data.bag).remove(id, 1)
	await host.say(who, "%s'll take you on. %s Strings out, one swing each, no stamping on them." % [str(r.who), ("Your conker's a %s." % ner) if ner != "" else "Your first match, then."])
	var res = await host.open_menu("conkers:%s:%d" % [str(r.id), Conkers.toughness(seasoned, wins)])
	var won: bool = res is Dictionary and bool(res.get("won", false))
	var out := Conkers.finish(data, r, won)
	if not won:
		await host.say(who, "Smashed to bits. That's conkers for you. Every one has its day.")
		return
	Bag.new(data.bag).add(id, 1)
	await host.say("", "%s's conker flies apart. Yours is a %s now." % [str(r.who).split(",")[0], Conkers.ner_name(int(out.wins))])
	if bool(out.first):
		var pl: Dictionary = Conkers.cfg().get("plaque", {})
		if not pl.is_empty():
			await host.say(str(pl.title), str(pl.text))
	if int(out.prize) > 0:
		var paid := Wallet.earn_here(data, int(out.prize), host.zone_id())
		await host.sfx("item")
		await host.say(who, "The losing side pays up: %s." % Wallet.fmt(int(paid.amount), str(paid.cur)))
