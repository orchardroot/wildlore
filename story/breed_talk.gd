class_name BreedTalk
extends RefCounted
## The farm gate and the lab bench: {"do": "breed", "act": ...} (core/breeding.gd). Runs inside Commands through its host.
##   pair     the pairing screen for this farm (menu "pairing:<zone>"; the UI session owns the screen)
##   collect  hatches every walked-off basket, tells each, and sends the young to the party or the Ark
##   status   how far each basket still has to walk
##   goal     {id, set}: pays a conservation goal once if it is met; `set` gets 1 for paid now, 0 for not yet
##   challenge  Dr Keir sets her prediction challenges (Biology) the first time, then says how you are getting on
##   sim      the moor model (menu "selection"), natural selection you can watch
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
				StudBook.observe_hatch(data, g.basket, g.creature, host.dex)
				await _tell(host, who, g)
				var sc := Biology.score(data, g.creature)
				for line in sc.get("lines", []):
					await host.say("", str(line))
				if int(sc.get("money", 0)) > 0:
					await host.sfx("item")
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
		"challenge":
			await _challenge(host, data)
		"sim":
			await host.open_menu("selection")
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
		var what := sport_words(str(g.get("sport_locus", "")))
		if what != "":
			await host.say("", "A new mutation: %s that neither parent had. It's marked NEW on its makings page." % what)
	await host.say("", "%s %s." % [cr.display_name(), where])

## What a sport changed, in words: "a Tint allele" ("" if not known).
static func sport_words(locus: String) -> String:
	if locus.begins_with("frame"):
		return "a Frame allele"
	if Genetics.LOCI.has(locus):
		return "a %s allele" % locus.capitalize()
	return ""

static func _challenge(host, data: GameStateData) -> void:
	var who := "Dr Keir"
	if not Biology.lab_on(data):
		data.set_flag("bio_lab_on", true)
		await host.say(who, "Here's my game, then. Every time you pair at a farm, tell me the odds of one thing before it hatches.")
		await host.say(who, "I'll score your reasoning, not your luck. Luck is what the hatchling does. Odds are what you can know.")
	var n := Biology.done_count(data)
	var total := Biology.challenges().size()
	var cur := Biology.current(data)
	if n >= total:
		await host.say(who, "All %d met. You think like a geneticist now, which I mean kindly. Keep predicting if you like; it keeps you honest." % total)
	else:
		await host.say(who, "%d of %d so far. Next: %s." % [n, total, str(cur.title)])
		await host.say(who, str(cur.brief))
	var rec := Biology.record_lines(data)
	if not rec.is_empty():
		await host.say(who, " ".join(rec.slice(0, 2)) + " That's what odds look like from the inside.")
