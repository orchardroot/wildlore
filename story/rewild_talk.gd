class_name RewildTalk
extends RefCounted
## The warden at a rewilding site: {"do": "rewild", "site": id}. Says how the site is doing, pays out each stage
## reached (once), then asks for this stage's task and takes it if you have it (see Rewild and data/rewild.json).
## Runs inside Commands, through its host, so it works the same in tests.

const YES_NO := ["Yes", "Not yet"]

static func run(cmd: Commands, c: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	var id := str(c.get("site", ""))
	var s := Rewild.site(id)
	if s.is_empty():
		push_warning("RewildTalk: no site '%s'" % id)
		return
	var who := str(s.warden)
	var lines: Dictionary = s.get("lines", {})
	Rewild.settle(data)  # an in-game day has gone by since the last contribution: it has taken
	if data.flag(Rewild.flag_key(id) + "_met") != true:
		for l in lines.get("intro", []):
			await host.say(who, cmd._sub(str(l)))
		cmd._set_flag(Rewild.flag_key(id) + "_met", true)
	if await _celebrate(cmd, s):
		await _refresh(cmd, s)
	var st := Rewild.stage(data, id)
	if st >= Rewild.WILD:
		await host.say(who, str(lines.get("wild", "")))
		await _complete(cmd, s)
		return
	if Rewild.pending(data, id):
		await host.say(who, str(lines.get("settling", "Give it a day.")))
		return
	await host.say(who, str(lines.get("stages", [""])[st]))
	var t := Rewild.task(s, st)
	var done := false
	match str(t.get("kind", "")):
		"plant", "litter":
			if Rewild.task_done(data, id):
				await host.say(who, "That's the lot. Lovely work.")
				done = true
			else:
				await host.say(who, str(t.get("ask", "")))
		"items", "money":
			await host.say(who, str(t.get("ask", "")))
			if not Rewild.can_pay(data, t):
				await host.say(who, "No rush. Come back when you've got it.")
			elif await host.choice(_offer(t, host.items, Wallet.local(host.data)), YES_NO) == 0:
				Rewild.pay(data, t)
				await host.sfx("item")
				await host.say(who, "Champion. That'll go straight in.")
				done = true
		"show":
			await host.say(who, str(t.get("ask", "")))
			var cr := Rewild.shown(data, str(t.get("type", "")))
			if cr != null:
				await host.say("", "%s has a good look round, sniffs everything twice and comes back looking pleased with itself." % cr.display_name())
				await host.say(who, "There. If it likes it, the rest will follow.")
				done = true
		"battle":
			await host.say(who, str(t.get("ask", "")))
			if await host.choice("Go and deal with them now?", YES_NO) == 0:
				var tid := str(t.get("trainer", ""))
				await cmd._exec({"do": "battle", "trainer": tid, "intro": true})
				if cmd._ended:
					return  # lost: back to the Sanctuary, the job's still there
				if data.flag("trainer_" + tid) == true:
					await host.say(who, "Did you see his face! That's him gone for good.")
					done = true
	if not done:
		return
	Rewild.contribute(data, id)
	if Rewild.pending(data, id):
		await host.say(who, str(lines.get("settling", "Give it a day.")))
	elif await _celebrate(cmd, s):
		await _refresh(cmd, s)

## "Hand over 3 Sheep Wool?" / "Chip in £800?"
static func _offer(t: Dictionary, items: ItemDB, cur := Wallet.GBP) -> String:
	if str(t.kind) == "money":
		return "Chip in %s?" % Wallet.fmt(Wallet.localise(int(t.amount), cur), cur)
	var parts := []
	for id in t.items:
		parts.append("%d %s" % [int(t.items[id]), str(items.get_item(str(id)).get("name", id))])
	return "Hand over %s?" % " and ".join(parts)

## Each stage reached and not yet paid out: how it looks now, its reward (once) and the news that something's back.
static func _celebrate(cmd: Commands, s: Dictionary) -> bool:
	var host = cmd.host
	var data: GameStateData = host.data
	var id := str(s.id)
	var due := Rewild.unrewarded(data, id)
	if due.is_empty():
		return false
	var who := str(s.warden)
	var lines: Dictionary = s.get("lines", {})
	var done: Array = lines.get("done", [])
	await host.sfx("item")
	if not done.is_empty():
		await host.say(who, str(done[0]))
	for st in due:
		cmd._set_flag(Rewild.flag_key(id) + "_rewarded", st)  # first, so nothing can pay twice
		var rewards: Array = s.get("rewards", [])
		if st - 1 < rewards.size():
			await cmd._run_list(rewards[st - 1])
	var now := Rewild.stage(data, id)
	await host.say("", "%s is now %s." % [s.name, Rewild.stage_name(now)])
	if done.size() > 1:
		await host.say(who, str(done[1]))
	return true

## Talking at the site itself: reload the zone so the change shows (and the returning creatures move in).
static func _refresh(cmd: Commands, s: Dictionary) -> void:
	var host = cmd.host
	if host.zone_id() != str(s.zone):
		return
	var pos: Vector2i = host.data.pos
	await host.warp(str(s.zone), pos.x, pos.y, str(host.data.facing))

## All six Wild: the Rewilder's Crook, once.
static func _complete(cmd: Commands, s: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	if not Rewild.all_wild(data) or data.flag(Rewild.COMPLETE_FLAG) == true:
		return
	cmd._set_flag(Rewild.COMPLETE_FLAG, true)
	await host.say(str(s.warden), "All six? Every one of them Wild? Oh, come here. We had a whip-round, the six of us. Here.")
	await cmd._run_list(Rewild._all().get("complete", []))
	await host.say("", "Six wardens, six marks on a hazel crook. The land remembers who helped it.")
