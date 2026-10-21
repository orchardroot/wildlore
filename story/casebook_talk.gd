class_name CasebookTalk
extends RefCounted
## The Casebook in conversation. {"do": "evidence", "id": ev} pockets a piece of evidence with a line ("Casebook: ...").
## {"do": "casebook", "id": case} is the accusation prompt: it says what's missing if the case isn't ready, otherwise
## lists the suspects still in the frame, asks twice (a wrong name costs standing) and plays the verdict.
## Runs inside Commands through its host.

const NOT_YET := "Not yet"

static func evidence(cmd: Commands, c: Dictionary) -> void:
	for e in Casebook.collect(cmd.host.data, str(c.get("id", ""))):
		await cmd.host.sfx("item")
		await cmd.host.say("", "Casebook: %s." % str(e.name))

static func run(cmd: Commands, c: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	var cs := Casebook.get_case(str(c.get("id", "")))
	if cs.is_empty():
		push_warning("CasebookTalk: no case '%s'" % c.get("id", ""))
		return
	if Casebook.solved(data, cs):
		await host.say("", "Case closed. %s" % str(cs.get("closed", "")))
		return
	if not Casebook.ready(data, cs):
		var nxt := Casebook.next_step(data, cs)
		await host.say("", "You can't name anyone yet. Check the Casebook in your Fieldbook: %s" % str(nxt.get("text", "")))
		return
	while true:
		var open := Casebook.open_suspects(data, cs)
		var names: Array = open.map(func(s): return str(s.name))
		names.append(NOT_YET)
		var pick: int = await host.choice("Who do you accuse? (A wrong name costs you standing.)", names)
		if pick >= open.size():
			return
		var sus: Dictionary = open[pick]
		var sure: int = await host.choice("Name %s?" % str(sus.name), ["Yes", NOT_YET])
		if sure != 0:
			continue
		var r := Casebook.accuse(data, str(cs.id), str(sus.id))
		if not r.ok:
			return
		if r.line != "":
			await host.say(str(sus.name), cmd._sub(str(r.line)))
		if r.correct:
			await host.sfx("badge")
			await host.say("", "Case solved: %s." % str(cs.title))
			if r.money > 0:
				await host.say("", "Reward: %s." % Purse.text(r.money))
			return
		await host.say("", "Wrong. %s is out of the frame, and %s thinks a little less of you." % [str(sus.name), Standing.name_of(str(cs.nation))])
		if Casebook.open_suspects(data, cs).size() < 2:
			return
