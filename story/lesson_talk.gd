class_name LessonTalk
extends RefCounted
## Talking to a language teacher ({"do": "lesson"}, the teacher's NPC id names the lesson, see LangLessons.npcs_for)
## and the "Say it" moment after a won battle ({"do": "say_it"}). Runs inside Commands through its host: the lesson
## card and its check are the "lang:lesson:<id>" menu, a review round is "lang:review:<code>".

const YES_NO := ["Yes, go on", "Not now"]

static func run(cmd: Commands, c: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	var first := str(c.get("lesson", cmd.npc_id.trim_prefix(LangLessons.TEACHER_PREFIX)))
	var l0 := LangLessons.lesson(first)
	if l0.is_empty():
		push_warning("LessonTalk: no lesson '%s'" % first)
		return
	var code := LangLessons.code_of(first)
	var who := str(l0.get("teacher", {}).get("name", ""))
	var lang := LangLessons.lang_name(code)
	var next := LangLessons.next_lesson(data, first)
	if not next.is_empty():
		for line in next.get("intro", []):
			await host.say(who, cmd._sub(str(line)))
		var ask := "Lesson: %s (level %d, %d words)" % [str(next.title), int(next.get("level", 1)), next.get("words", []).size()]
		if await host.choice(ask, YES_NO) != 0:
			await host.say(who, "No bother. I'm here when you fancy it.")
			return
		var res = await host.open_menu("lang:lesson:" + str(next.id))
		if not (res is Dictionary):
			await host.say(who, "Off already? The words will keep.")
			return
		if not LangLessons.passed(int(res.get("score", 0)), int(res.get("total", 0))):
			await host.say(who, "%d out of %d. Nearly there. Have another go whenever you like." % [int(res.get("score", 0)), int(res.get("total", 0))])
			return
		var new_certs := LangLessons.learn(data, str(next.id))
		await host.sfx("item")
		await host.say(who, "%d out of %d. Lovely. Those words are yours now: they're in your Fieldbook, under Words of the Isles." \
			% [int(res.get("score", 0)), int(res.get("total", 0))])
		for lv in new_certs:
			await host.sfx("badge")
			await host.say("", "%s receives a certificate: %s." % [data.player_name, LangLessons.cert_title(code, int(lv))])
		await _point_on(cmd, code, who)
		return
	# nothing new from this teacher: a level still shut, or all done here
	var later := LangLessons.teacher_lessons(first).filter(func(l): return not LangLessons.done(data, str(l.id)))
	if not later.is_empty():
		var lv := int(later[0].get("level", 1))
		await host.say(who, "Next from me is level %d %s. Get your level %d certificate first." % [lv, lang, lv - 1])
		await _point_on(cmd, code, who)
	else:
		await host.say(who, "You've had all my lessons. Want to go over a few words?")
	if LangLessons.learnt_words(data, code).is_empty():
		return
	var due := LangLessons.due_count(data, code)
	var ask2 := "Revise %s (%s)" % [lang, ("%d due" % due) if due > 0 else "nothing due, just practice"]
	if await host.choice(ask2, YES_NO) != 0:
		return
	var r = await host.open_menu("lang:review:" + code)
	if r is Dictionary and int(r.get("total", 0)) > 0:
		await host.say(who, "%d out of %d. Little and often: that's the trick." % [int(r.get("score", 0)), int(r.get("total", 0))])

## Where the next open lesson of this language is, if it's with someone else.
static func _point_on(cmd: Commands, code: String, who: String) -> void:
	var nxt := LangLessons.next_anywhere(cmd.host.data, code)
	if nxt.is_empty():
		return
	var t: Dictionary = nxt.get("teacher", {})
	if str(t.get("name", "")) == who:
		return
	var town := _town_name(str(t.get("zone", "")))
	await cmd.host.say(who, "For your next lesson, see %s%s." % [str(t.get("name", "")), (" in " + town) if town != "" else ""])

static func _town_name(zone_id: String) -> String:
	var idx := ZoneIndex.get_index()
	var town := str(idx.get("room_town", {}).get(zone_id, zone_id))
	return str(idx.get("zones", {}).get(town, {}).get("name", ""))

## After a won battle in a language's area: one quick question, a small prize for the right answer, never required.
static func say_it(cmd: Commands, _c: Dictionary) -> void:
	var host = cmd.host
	var data: GameStateData = host.data
	var code := Langs.code_for(host.zone_id(), ZoneIndex.get_index())
	var q := LangLessons.say_it_question(data, code, host.rng)
	if q.is_empty():
		return
	LangLessons.say_it_used(data)
	var opts: Array = q.options.duplicate()
	opts.append("Pass")
	var pick: int = await host.choice("Someone who watched the battle calls over: \"%s\"" % str(q.q), opts)
	if pick < 0 or pick >= q.options.size():
		return  # passed: no harm done
	var right: bool = pick == int(q.answer)
	LangLessons.review(data, code, str(q.word), right)
	if right:
		TrainerStats.add(data, "say_it_right")
		var paid := Wallet.earn_here(data, LangLessons.SAY_IT_PRIZE, host.zone_id())
		TrainerStats.earned(data, LangLessons.SAY_IT_PRIZE)
		await host.sfx("item")
		await host.say("", "Spot on. They toss you %s for your trouble." % Wallet.fmt(int(paid.amount), str(paid.cur)))
	else:
		await host.say("", "Not quite. %s" % str(q.fact))
