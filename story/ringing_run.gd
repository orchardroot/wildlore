class_name RingingRun
extends RefCounted
## The `ring` and `wall` story commands.
##   {"do": "ring", "who": "Tower Captain"}                                  pick a piece and ring it
##   {"do": "wall", "who": "Waller", "level": "normal", "site": "goyt_moss"}   mend a gap (site optional: a rewilding site)
## Rules live in Ringing and Walling; the screens are ui/ringing_screen.gd and ui/walling_screen.gd.

var cmd: Commands
var host

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func ring(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var who := str(c.get("who", "Tower Captain"))
	var ps: Array = Ringing.pieces()
	var opts: Array = []
	for p in ps:
		opts.append(str(p.name) + (" (rung)" if data.flags.has(Ringing.FLAG_FIRST + str(p.id)) else ""))
	opts.append("Not today")
	var i: int = await host.choice("Six bells, six ringers, and a bell rope with your name on it. What shall we ring?", opts)
	if i >= ps.size():
		await host.say(who, "No bother. The ropes aren't going anywhere. Mind, the bats are.")
		return
	var p: Dictionary = ps[i]
	var res = await host.open_menu("ringing:" + str(p.id))
	if not (res is Dictionary) or bool(res.get("quit", false)):
		await host.say(who, "Left the rope mid-touch? It's all right, the others carried on. Nobody noticed. Much.")
		return
	var hits := int(res.hits)
	var rows := int(res.rows)
	var out := Ringing.finish(data, p, hits, rows)
	if not Ringing.clean(hits, rows):
		await host.say(who, "%d of %d rows in time. Ringing is mostly listening. Have another go." % [hits, rows])
		return
	await host.say(who, "%d of %d rows in time. A clean touch of %s." % [hits, rows, str(p.name)])
	await host.say(who, str(p.fact))
	if bool(out.first):
		var pl: Dictionary = Ringing.cfg().get("plaque", {})
		if not pl.is_empty():
			await host.say(str(pl.title), str(pl.text))
	if int(out.tip) > 0:
		var paid := Wallet.earn_here(data, int(out.tip), host.zone_id())
		await host.sfx("item")
		await host.say(who, "The ringers pass the bag round: %s for the tower fund, and a share for you." % Wallet.fmt(int(paid.amount), str(paid.cur)))

func wall(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var who := str(c.get("who", "Waller"))
	var level := str(c.get("level", "normal"))
	var site := str(c.get("site", ""))
	var key: String = site if site != "" else str(host.zone_id())
	var i: int = await host.choice("There's a gap in the wall. No mortar: stones by size and shape, and gravity does the rest.", ["Mend it", "Not today"])
	if i != 0:
		await host.say(who, "It's not going to mend itself. Though the sheep do keep trying to.")
		return
	var res = await host.open_menu("walling:" + level)
	if not (res is Dictionary) or not bool(res.get("built", false)):
		await host.say(who, "Left it half done? A wall in progress is a gap with ambitions.")
		return
	var out := Walling.finish(data, key, level, site)
	await host.say(who, "That'll stand a hundred years. Big stones low, joints covered, and a throughstone to tie it. You've the knack.")
	if int(out.fee) > 0:
		var paid := Wallet.earn_here(data, int(out.fee), host.zone_id())
		await host.sfx("item")
		await host.say(who, "The farmer left a few coins in a flask for whoever mended it: %s." % Wallet.fmt(int(paid.amount), str(paid.cur)))
	if str(out.thanks) != "":
		await host.say("", str(out.thanks) + ".")
