class_name BreedTalk
extends RefCounted
## The farm gate and the lab bench: {"do": "breed", "act": ...} (core/breeding.gd). Runs inside Commands through its host.
##   pair     the pairing screen for this farm (menu "pairing:<zone>"; the UI session owns the screen)
##   collect  hatches every walked-off basket, tells each, and sends the young to the party or the Ark
##   status   how far each basket still has to walk
##   goal     {id, set}: pays a conservation goal once if it is met; `set` gets 1 for paid now, 0 for not yet
## "who" names the speaker for the lines this tells.

static func run(cmd: Commands, c: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	var who := str(c.get("who", "Dot"))
	match str(c.get("act", "")):
		"pair":
			await host.open_menu("pairing:" + str(host.zone_id()))
		"collect":
			var got := Breeding.collect(data, host.dex, host.moves)
			if got.is_empty():
				await host.say(who, _nothing_yet(data))
				return
			for g in got:
				await host.sfx("catch")
				await _tell(host, who, g)
		"status":
			var bs := Breeding.baskets(data)
			if bs.is_empty():
				await host.say(who, "Nothing in the baskets just now. Pick a pair and we'll see.")
			for b in bs:
				var left := Breeding.steps_left(data, int(b.slot))
				var line := "%s and %s: " % [b.sire_name, b.dam_name]
				line += "ready to collect." if left == 0 else "about %d more steps to walk." % (int(ceil(left / 100.0)) * 100)
				await host.say(who, line)
		"goal":
			var id := str(c.get("id", ""))
			var r := Breeding.claim_goal(data, id)
			if c.has("set"):
				cmd._set_flag(str(c.set), 1 if r.ok else 0)
			if r.ok:
				await host.sfx("item")
				await host.say("", "The grant comes to £%d." % int(r.money))
			elif data.flag(Breeding.GOAL + id) != true:
				var st := Breeding.goal_status(data, id)
				await host.say(who, "%d of %d so far. Keep going." % [st.have, st.need])
		_:
			push_warning("BreedTalk: unknown act '%s'" % c.get("act", ""))

static func _nothing_yet(data: GameStateData) -> String:
	var bs := Breeding.baskets(data)
	if bs.is_empty():
		return "Nothing of yours in the baskets, love."
	return "Not yet. Walk it off, they'll come when they're ready."

static func _tell(host, who: String, g: Dictionary) -> void:
	var cr: Creature = g.creature
	var name_: String = cr.species.name
	var where := "joined your team" if g.where == "party" else "went to the Ark, as your team is full"
	await host.say("", "A %s hatched, out of %s and %s!" % [name_, g.sire_name, g.dam_name])
	if g.sport:
		await host.say(who, "Well, that's a sport. Not from either side. That's the old word for it, and you'll hear Dr Keir use a longer one.")
	await host.say("", "%s %s." % [cr.display_name(), where])
