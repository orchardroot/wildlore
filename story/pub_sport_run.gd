class_name PubSportRun
extends RefCounted
## The `darts` and `crab_comp` story commands.
##   {"do": "darts", "nation": "england", "pub": "blackpool_pub", "who": "Captain"}   the pub league captain
##   {"do": "crab_comp", "harbour": "whitby", "who": "Harbour Warden"}                  the summer crabbing competition
## Darts: the next rung of the nation's league (Darts.league), or a friendly leg once you've beaten some. Crabbing:
## eight hauls with the harbour's own bait, scored against three locals, once a real day per harbour. Rules and
## prizes live in Darts and Crabbing; the screens are ui/darts_screen.gd and ui/crabbing_screen.gd.

var cmd: Commands
var host

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func darts(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var nation := str(c.get("nation", ""))
	var pub := str(c.get("pub", host.zone_id()))
	var who := str(c.get("who", "Darts Captain"))
	var lg := Darts.league(nation)
	if lg.is_empty():
		push_warning("PubSportRun: no darts league '%s'" % nation)
		return
	var rungs: Array = lg.rungs
	var next := Darts.next_rung(data, nation)
	var beaten := Darts.rungs_beaten(data, nation)
	var opts: Array = []
	var picks: Array = []
	if not next.is_empty():
		await host.say(who, "%s. You're on %d of %d. %s" % [lg.name, beaten, rungs.size(), str(next.intro)])
		opts.append("Play %s" % str(next.who))
		picks.append(beaten)
	else:
		await host.say(who, "Champion of %s! The sash is yours. Fancy a friendly leg?" % lg.name)
	if beaten > 0:
		opts.append("A friendly leg")
		picks.append(-1)
	opts.append("Not tonight")
	var i: int = await host.choice("Oche's free. 501, double to finish.", opts)
	if i >= picks.size():
		await host.say(who, "Fair enough. The board will be here. Mostly.")
		return
	var idx: int = picks[i]
	if idx < 0:
		idx = host.rng.roll_int(0, maxi(0, beaten - 1)) if beaten < rungs.size() else host.rng.roll_int(0, rungs.size() - 1)
	var res = await host.open_menu("darts:%s:%s:%d" % [nation, pub, idx])
	if not (res is Dictionary) or not bool(res.get("won", false)):
		await host.say(who, "Not this time. %s" % ("No shame in it." if res is Dictionary and not res.get("quit", false) else "Walked off mid-leg, did we?"))
		return
	var won := Darts.win(data, nation, pub, idx)
	await host.say("", "%s wins the leg against %s." % [data.player_name, str(rungs[idx].who)])
	if str(won.line) != "":
		await host.say(str(rungs[idx].who).split(",")[0], str(won.line))
	if int(won.money) > 0:
		var paid := Wallet.earn_here(data, int(won.money), host.zone_id())
		await host.sfx("item")
		await host.say("", "%s for the winner%s." % [Wallet.fmt(int(paid.amount), str(paid.cur)), " (the league prize)" if bool(won.first) else " (the pub's kitty)"])
	if bool(won.first):
		var line := Standing.add(data, Standing.nation_for_zone(host.zone_id()), 3 if Darts.champion(data, nation) else 1)
		if line != "":
			await host.say("", line + ".")

func crab_comp(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var harbour := str(c.get("harbour", host.zone_id()))
	var who := str(c.get("who", "Harbour Warden"))
	var cp := Crabbing.comp()
	if not Crabbing.comp_open():
		await host.say(who, "The crabbing competition is a summer thing. June to August, bucket and bacon, as tradition demands. Come back then.")
		return
	if Crabbing.comp_done_today(data, harbour):
		await host.say(who, "You've had your go today. The crabs need the afternoon off, and so do I.")
		return
	var cur := Wallet.currency_for_zone(harbour)
	var fee := Wallet.localise(int(cp.fee), cur)
	var i: int = await host.choice("Eight hauls, and every crab goes back. Entry is %s for the bait and the charity tin." % Wallet.fmt(fee, cur), ["Enter", "Not today"])
	if i != 0:
		await host.say(who, "Spectating is a noble art. Mind the bucket.")
		return
	if not Wallet.spend(data, fee, cur):
		await host.say(who, "Short of the fee? Never mind, pop back when you've found a few coins down the sofa.")
		return
	Crabbing.comp_enter(data, harbour)
	var res = await host.open_menu("crabbing:comp:%d:%s" % [int(cp.hauls), harbour])
	var bucket: Array = res.get("bucket", []) if res is Dictionary else []
	var mine := Crabbing.score(bucket)
	var rivals := Crabbing.rival_scores(host.rng)
	var place := Crabbing.place(mine, rivals)
	var rows: Array = ["You: %d" % mine]
	for r in rivals:
		rows.append("%s: %d" % [r.who, r.score])
	await host.say(who, "Scores in (a point a crab, and a point more for every 20 mm of your biggest). %s." % "; ".join(PackedStringArray(rows)))
	var big := Crabbing.biggest(bucket)
	var out := Crabbing.release(data, harbour, bucket)
	if not bucket.is_empty():
		await host.say("", "All %d crabs go back over the wall. The biggest, a %s at %d mm, gets a round of applause." % [bucket.size(), str(big.name).to_lower(), int(big.mm)])
	if str(out.line) != "":
		await host.say("", str(out.line))
	var gbp := Crabbing.prize(place)
	if gbp > 0:
		var paid := Wallet.earn_here(data, gbp, harbour)
		await host.sfx("item")
		await host.say(who, "%s place! %s and a rosette." % [["First", "Second", "Third"][place], Wallet.fmt(int(paid.amount), str(paid.cur))])
	else:
		await host.say(who, "Fourth, but the crabs rated you highly. Well, one of them did.")
