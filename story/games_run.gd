class_name GamesRun
extends RefCounted
## The `games` story command: offers the events a steward or player runs, explains the rules, plays one and pays out.
##   {"do": "games", "who": "Games Steward", "events": ["caber", "tug"]}
## Rules live in Games; the screen is ui/games_screen.gd.

var cmd: Commands
var host

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func play(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var evs: Array = c.get("events", Games.EVENTS)
	var who := str(c.get("who", "Games Steward"))
	var opts: Array = []
	for id in evs:
		opts.append(str(Games.event(str(id)).name))
	opts.append("Not today")
	var i: int = await host.choice("Which event?", opts)
	if i >= evs.size():
		await host.say(who, "Another time. The field isn't going anywhere, though the caber might be.")
		return
	var id := str(evs[i])
	var e := Games.event(id)
	await host.say(who, str(e.rules))
	var j: int = await host.choice("Have a go at %s?" % str(e.name).to_lower(), ["Yes", "Not now"])
	if j != 0:
		await host.say(who, "Take your time. Nobody has ever lost by stretching first.")
		return
	var arg := id
	if id == "tug":
		arg += ":%d" % Games.lead_atk(data)
	var res = await host.open_menu("games:" + arg)
	if not (res is Dictionary) or bool(res.get("quit", false)):
		await host.say(who, "Walked off mid-event? We'll say you were called away.")
		return
	if not bool(res.get("won", false)):
		await host.say(who, "Not this time. You scored %d. Have another go." % int(res.get("score", 0)) if id != "tug" else "The rope wins this one. Heels down next time.")
		return
	var out := Games.win(data, id, host.zone_id())
	await host.say(who, str(e.won))
	if bool(out.first):
		var pl: Dictionary = e.get("plaque", {})
		if not pl.is_empty():
			await host.say(str(pl.title), str(pl.text))
	if int(out.prize) > 0:
		var paid := Wallet.earn_here(data, int(out.prize), host.zone_id())
		await host.sfx("item")
		await host.say("", "The prize: %s." % Wallet.fmt(int(paid.amount), str(paid.cur)))
	if str(out.line) != "":
		await host.say("", str(out.line) + ".")
