class_name Commands
extends RefCounted
## The story command interpreter. Pure logic: everything that touches the screen goes through an injected host.
##
## Host interface (duck typed; coroutines may suspend):
##   data: GameStateData, dex: Dex, moves: MoveDB, items: ItemDB, rng: Rng
##   zone_id() -> String                      heal_anchor(npc_id) -> Vector2i
##   say(who, text)      choice(text, options) -> int      battle(foe_party, opts) -> Dictionary
##   move_npc(npc, path) face_npc(npc, dir)    face_player(npc)
##   warp(zone, x, y, facing)   open_menu(name) -> Variant   fade(out: bool)
##   music(id)  sfx(id)  wait(seconds)
##   optional: on_flag(key, value)
##   optional: journey_out(kind, info) -> bool, journey_in(kind, info)   travel scenes round a rail or ferry warp

const WHITEOUT_LINE := "You hurry back to the Sanctuary, a little dazed."
const WHITEOUT_LINE_2 := "Your team is patched up and ready to go again."

var host
var npc_id: String
var _ended := false
var _badge_won := false
var _legend_caught := false

## npc_id is the NPC that owns the script (the default target of move, face and heal).
func _init(h, owner_npc := "") -> void:
	host = h
	npc_id = owner_npc

func run(commands: Array) -> void:
	_ended = false
	_badge_won = false
	_legend_caught = false
	await _run_list(_nurse_visit(commands))
	if is_nurse_script(commands) and not _ended:
		await _nurse_bounty()
	# autosave once the whole scene has played, so the save has everything the Keeper's script did after the badge
	# (or after a legend was caught, never mid-script)
	if (_badge_won or _legend_caught) and host.has_method("autosave"):
		host.autosave()

const NURSE_HEALED := ["All set.", "Good as new.", "Right as rain."]
const NURSE_BYE := "Mind how you go."

## Every Sanctuary nurse script has the same shape: greeting, choice, then heal / Ark / just looking.
static func is_nurse_script(c: Array) -> bool:
	if c.size() != 3 or c[0].get("do") != "say" or c[1].get("do") != "choice" or c[2].get("do") != "if":
		return false
	var heal: Array = c[2].get("then", [])
	var rest: Array = c[2].get("else", [])
	if heal.size() != 3 or heal[0].get("do") != "say" or heal[1].get("do") != "heal" or heal[2].get("do") != "say":
		return false
	if rest.size() != 1 or rest[0].get("do") != "if":
		return false
	var ark: Array = rest[0].get("then", [])
	return ark.size() == 2 and ark[0].get("do") == "say" and ark[1].get("do") == "ark" and rest[0].get("else", []).size() == 1

## The quick version for a Sanctuary you have been to before: no greeting, no wind-up, one short line after.
static func nurse_repeat(c: Array, variant: int) -> Array:
	var out: Array = c.duplicate(true)
	out.remove_at(0)
	var branch: Dictionary = out[1]
	branch["then"] = [branch.then[1], {"do": "say", "who": "Nurse", "text": NURSE_HEALED[posmod(variant, NURSE_HEALED.size())]}]
	var rest: Dictionary = branch["else"][0]
	rest["then"] = [rest.then[1]]
	rest["else"] = [{"do": "say", "who": "Nurse", "text": NURSE_BYE}]
	return out

## First visit to a Sanctuary: the full script (and a note of it). Afterwards, the short one.
func _nurse_visit(commands: Array) -> Array:
	if not is_nurse_script(commands):
		return commands
	var key := "nurse_seen_" + str(host.zone_id())
	if host.data.flag(key) == true:
		return nurse_repeat(commands, int(host.data.day_count))
	_set_flag(key, true)
	return commands

## Today's Walk: a Sanctuary nurse pays a waiting weather bounty.
func _nurse_bounty() -> void:
	var line := TodaysWalk.nurse_pays(host.data, host.items)
	if line != "":
		await host.sfx("item")
		await host.say("Nurse", line)

func _run_list(commands: Array) -> void:
	for c in commands:
		if _ended:
			return
		if c is Dictionary:
			await _exec(c)

func _exec(c: Dictionary) -> void:
	var data: GameStateData = host.data
	match str(c.get("do", "")):
		"say":
			await host.say(_sub(str(c.get("who", ""))), _sub(str(c.get("text", ""))))
		"choice":
			var idx: int = await host.choice(_sub(str(c.get("text", ""))), c.get("options", []).map(func(o): return _sub(str(o))))
			if c.has("set"):
				_set_flag(str(c.set), idx)
		"if":
			var branch: Array = c.get("then", []) if _test(c) else c.get("else", [])
			await _run_list(branch)
		"set":
			_set_flag(str(c.get("flag", "")), c.get("value", true))
		"give_item":
			var id := str(c.get("item", ""))
			var n := int(c.get("n", 1))
			var got := Bag.new(data.bag).add(id, n)
			var nm: String = host.items.get_item(id).get("name", id)
			if got <= 0:
				await host.say("", "Your bag's full of %s already. You leave them for someone else." % nm)
			else:
				await host.sfx("item")
				await host.say("", "%s received %s%s." % [data.player_name, nm, " x%d" % got if got > 1 else ""])
		"give_creature":
			var sp: Dictionary = host.dex.get_species(str(c.get("species", "")))
			var cr := Creature.create(sp, int(c.get("level", 5)), host.rng, host.moves)
			var where := data.add_creature(cr)
			await host.sfx("catch")
			if where == "party":
				await host.say("", "%s joined your team!" % cr.display_name())
			else:
				await host.say("", "%s was sent to the Ark, as your team is full." % cr.display_name())
		"heal":
			data.heal_party()
			var t: Vector2i = host.heal_anchor(str(c.get("npc", npc_id)))
			data.last_sanctuary = {"zone": host.zone_id(), "pos": [t.x, t.y]}
			await host.sfx("heal")
		"battle":
			if bool(c.get("intro", false)):
				for line in StoryData.trainer(str(c.get("trainer", ""))).get("intro", []):
					await _exec(line)
			await _battle(str(c.get("trainer", "")))
		"daily":
			# once per real day (see DailyKey): `key` remembers the date it last ran on
			if not DailyKey.done_today(data, str(c.get("key", ""))):
				_set_flag(str(c.get("key", "")), DailyKey.stamp(data))
				await _run_list(c.get("then", []))
			else:
				await _run_list(c.get("else", []))
		"when":
			await _run_list(c.get("then", []) if _when(str(c.get("cond", ""))) else c.get("else", []))
		"move":
			await host.move_npc(str(c.get("npc", npc_id)), c.get("path", []))
		"face":
			await host.face_npc(str(c.get("npc", npc_id)), str(c.get("dir", "down")))
		"face_player":
			await host.face_player(str(c.get("npc", npc_id)))
		"wait":
			await host.wait(float(c.get("seconds", 0.5)))
		"warp":
			await host.warp(str(c.get("zone", "")), int(c.get("x", 0)), int(c.get("y", 0)), str(c.get("facing", "down")))
		"shop":
			await host.open_menu("shop:" + str(c.get("id", "")))
		"starter":
			var picked = await host.open_menu("starter")
			if picked is String and picked != "" and host.dex.has(picked):
				_set_flag("starter", picked)
				host.data.add_creature(Creature.create(host.dex.get_species(picked), STARTER_LEVEL, host.rng, host.moves))
		"fade_out":
			await host.fade(true)
		"fade_in":
			await host.fade(false)
		"music":
			await host.music(str(c.get("id", "")))
		"sfx":
			await host.sfx(str(c.get("id", "")))
		"badge":
			var b := str(c.get("id", ""))
			if b != "" and b not in data.badges:
				data.badges.append(b)
			if b != "":
				_set_flag("badge_" + b, true)
				_badge_won = true
			await host.sfx("badge")
		"end":
			_ended = true
		"ark":
			await host.open_menu("ark")
		"relearn":
			# the move relearner; `set` (optional) gets 1 if a move was learned, 0 if they backed out
			var learned = await host.open_menu("relearn")
			if c.has("set"):
				_set_flag(str(c.set), 1 if learned is Dictionary else 0)
		"sachet_worn":
			await _sachet_worn()
		"craft":
			await host.open_menu("craft:" + str(c.get("bench", "kitchen")))
		"recipe":
			await _recipe(c.get("id", []))
		"quiz":
			await _quiz(c)
		"legend":
			await _legend(c)
		"rail":
			await _rail()
		"gauntlet":
			await _gauntlet(c)
		"tournament":
			await TournamentRun.new(self).run(c)  # County Shows, the Open Moot and the rosette stall
		"credits":
			await host.open_menu("credits")
			# the credits swapped the music and the ending set game_complete: put the zone's tune back and save
			if host.has_method("zone_music"):
				host.zone_music()
			if host.has_method("autosave"):
				host.autosave()
		"ferry":
			await _ferry(str(c.get("route", "")))
		"whiteout":
			await whiteout()
			_ended = true
		"fieldbook_news":
			await _fieldbook_news(str(c.get("who", "")))
		"standing":
			# {"do": "standing", "nation": id, "amount": n}: standing with a nation (see Standing), with a line on a new tier
			var line := Standing.add(data, str(c.get("nation", "")), int(c.get("amount", 1)))
			if line != "":
				await host.sfx("badge")
				await host.say("", line + ".")
		"rewild":
			await RewildTalk.run(self, c)  # a rewilding site's warden (story/rewild_talk.gd)
		_:
			push_warning("Commands: unknown command '%s'" % c.get("do", ""))

const STARTER_LEVEL := 5

## Garside hears about each region you've finished (every species found there caught), once each.
func _fieldbook_news(who: String) -> void:
	for r in FieldbookGoals.untold_regions(host.data, ZoneIndex.get_index()):
		_set_flag(FieldbookGoals.NEWS_PREFIX + r, true)
		await host.say(_sub(who), "Every creature in %s, caught? Then that's a stamp in the Fieldbook, {player}. Region complete. I'll fetch the potato." \
			.replace("{player}", host.data.player_name) % FieldbookGoals.region_name(r))

## The pub quiz: {"do": "quiz", "pub": id, "region": region, "who": quizmaster name, "set": flag (the score, or -1)}.
## The round itself is the quiz screen; the prize is once per real day per pub (see PubQuiz).
func _quiz(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var pub := str(c.get("pub", host.zone_id()))
	var who := str(c.get("who", "Quizmaster"))
	var bonus := TodaysWalk.bonus_pub(data) == pub
	if PubQuiz.claimed_today(data, pub):
		await host.say(who, "You've had tonight's prize already. Play for glory if you like, but the kitty's shut until tomorrow.")
	elif bonus:
		await host.say(who, "You'll have heard it on the wireless: double prizes here tonight. No pressure.")
	var res = await host.open_menu("quiz:%s:%s" % [pub, str(c.get("region", "all"))])
	if c.has("set"):
		_set_flag(str(c.set), int(res.score) if res is Dictionary else -1)
	if not (res is Dictionary):
		await host.say(who, "Off already? Fair enough. The quiz will be here, so will the crisps.")
		return
	var score := int(res.get("score", 0))
	var total := int(res.get("total", PubQuiz.ROUND_SIZE))
	await host.say(who, "%d out of %d. %s" % [score, total, PubQuiz.reaction(score, total)])
	var paid := PubQuiz.award(data, host.items, pub, score, bonus)
	if bool(paid.paid) and score >= 3:  # a quiz win: the pub's nation thinks a bit better of you
		var line := Standing.add(data, Standing.nation_for_zone(pub if FileAccess.file_exists("res://data/zones/%s.json" % pub) else host.zone_id()), Standing.FOR_QUIZ_WIN)
		if line != "":
			await host.say("", line + ".")
	if bool(paid.paid):
		await host.sfx("item")
		if str(paid.item) != "":
			var nm: String = host.items.get_item(str(paid.item)).get("name", str(paid.item))
			await host.say("", "%s wins %s%s." % [data.player_name, nm, (" and " + UIKit.money_text(int(paid.money))) if int(paid.money) > 0 else ""])
		else:
			await host.say("", "%s wins %s." % [data.player_name, UIKit.money_text(int(paid.money))])

func _battle(trainer_id: String) -> void:
	var def := StoryData.trainer(trainer_id)
	if def.is_empty():
		push_error("Commands: no trainer '%s'" % trainer_id)
		return
	var result := await _fight(def)
	match str(result.get("result", "")):
		"win":
			# prize money is paid by the battle scene, which also announces it
			_set_flag("trainer_" + trainer_id, true)
			if def.win != "":
				await host.say(def.name, _sub(def.win))
		"lose":
			await whiteout()
			_ended = true

## Builds a trainer's party and runs the battle; returns the battle result.
func _fight(def: Dictionary) -> Dictionary:
	var foes := TrainerParty.build(def, host.dex, host.rng, host.moves, 0, host.data.flags)  # fixed moves, a held charm, a keeper's tea
	var opts := {"kind": "trainer", "ai": def.ai, "trainer": def}
	if str(def.get("music", "")) != "":
		opts["music"] = str(def.music)
	if bool(def.get("double", false)) and foes.size() >= 2:
		opts["double"] = true  # a 2v2: the trainer sends out two at once
	return await host.battle(foes, opts)

## The Moot: several trainers back to back with no Sanctuary in between. Winning them all sets `flag`.
## Losing any one sends you back to the entrance (`exit`), healed and poorer, with nothing half-won.
## Other gauntlets (a round on the Old Course) may reword it: optional `lose_line`, `next_line`, `prize_from`.
func _gauntlet(c: Dictionary) -> void:
	var ids: Array = c.get("trainers", [])
	var prize := 0  # paid only once the whole gauntlet is won, so retries can't farm it
	for i in ids.size():
		var def := StoryData.trainer(str(ids[i]))
		if def.is_empty():
			push_error("Commands: no trainer '%s'" % ids[i])
			return
		for line in def.get("intro", []):
			await _exec(line)
		prize += int(def.get("money", def.get("reward", 0)))
		var fight_def := def.duplicate()
		fight_def["money"] = 0
		fight_def.erase("reward")
		var result := await _fight(fight_def)
		if str(result.get("result", "")) != "win":
			var ex: Dictionary = c.get("exit", {})
			host.data.money = host.data.money / 2
			host.data.heal_party()
			await host.warp(str(ex.get("zone", host.zone_id())), int(ex.get("x", -1)), int(ex.get("y", -1)), "down")
			await host.say("", str(c.get("lose_line", "You come round at the edge of the stones, patched up and a little humbled. The Moot will wait.")))
			_ended = true
			return
		if def.win != "":
			await host.say(def.name, _sub(def.win))
		if i < ids.size() - 1:
			await host.say("", str(c.get("next_line", "No rest at the Moot. The next challenger steps forward.")))
			while await host.choice("Anything to sort out before the next challenger?", ["Open your bag", "Carry on"]) == 0:
				await host.open_menu("bag")
	if prize > 0:
		host.data.money += prize
		TrainerStats.earned(host.data, prize)
		await host.say("", "%s collects £%d in prize money from %s." % [host.data.player_name, prize, str(c.get("prize_from", "the Moot"))])
	_set_flag(str(c.get("flag", "gauntlet_won")), true)

## A legendary encounter: a wild battle you can't run from, with its own music. Catching it sets `flag`;
## knocking it out doesn't, so it can be met again. Losing whites out as usual.
func _legend(c: Dictionary) -> void:
	var sp: Dictionary = host.dex.get_species(str(c.get("species", "")))
	if sp.is_empty():
		push_error("Commands: no legend species '%s'" % c.get("species", ""))
		return
	host.data.mark_seen(str(sp.id))
	var foe := Creature.create(sp, int(c.get("level", 40)), host.rng, host.moves)
	var result: Dictionary = await host.battle([foe], {"kind": "wild", "no_run": true, "legend": true, "music": str(c.get("music", "legend"))})
	match str(result.get("result", "")):
		"caught":
			_set_flag(str(c.get("flag", "caught_" + str(sp.id))), true)
			_legend_caught = true
		"lose":
			await whiteout()
			_ended = true

## {"do": "recipe", "id": "parkin"} or a list of ids: learn recipes (flags recipe_<id>), and one line naming the new ones.
func _recipe(ids: Variant) -> void:
	var names := []
	for id in (ids if ids is Array else [ids]):
		var r := Crafting.get_recipe(str(id))
		if r.is_empty() or not Crafting.learn(host.data, str(id)):
			continue
		if host.has_method("on_flag"):
			host.on_flag(Crafting.flag_for(str(id)), true)
		names.append(str(host.items.get_item(str(r.out)).get("name", str(r.out).capitalize())))
	if names.is_empty():
		return
	var list: String = names[0] if names.size() == 1 else ", ".join(names.slice(0, names.size() - 1)) + " and " + str(names.back())
	await host.sfx("item")
	await host.say("", "%s learnt how to make %s." % [host.data.player_name, list])

## A Lavender Sachet ran out on the overworld: say so, and offer another if there's one in the bag.
func _sachet_worn() -> void:
	await host.say("", Repel.WORN_LINE)
	if Bag.new(host.data.bag).count(Repel.ITEM) < 1:
		return
	if await host.choice("Use another Lavender Sachet?", ["Yes", "No"]) == 0:
		var r := Repel.use(host.data, Repel.ITEM, host.items)
		await host.sfx("confirm" if r.ok else "bump")
		await host.say("", str(r.text))

func _rail() -> void:
	if int(host.data.bag.get("rail_pass", 0)) <= 0:
		await host.say("", "The ticket barrier beeps sadly. You'll need a Rail Pass.")
		return
	var dest = await host.open_menu("travel:rail")
	if dest == null or str(dest) == "":
		return
	var a := Travel.rail_arrival(str(dest))
	var info := {"from": host.zone_id(), "to": str(dest)}
	TrainerStats.note_train(host.data, host.zone_id(), str(dest))
	var scene := await _journey_out("train", info)
	if not scene:
		await host.sfx("train")
	await host.warp(str(a.zone), a.pos.x, a.pos.y, "down")
	if scene:
		await host.journey_in("train", info)
	_ended = true

func _ferry(route: String) -> void:
	var a := Travel.ferry_arrival(route, host.zone_id())
	if a.is_empty():
		push_error("Commands: no ferry route '%s'" % route)
		return
	var pick: int = await host.choice("Sail to %s?" % Travel.town_name(str(a.zone)), ["All aboard", "Not today"])
	if pick != 0:
		return
	await host.music(str(Travel.ferries()[route].get("music", "ferry")))
	var card := str(Travel.ferries()[route].get("card", "The ferry crosses the sea."))
	var info := {"from": host.zone_id(), "to": str(a.zone), "route": route, "card": card}
	TrainerStats.add(host.data, "ferry_trips")
	var scene := await _journey_out("ferry", info)
	if not scene:
		await host.say("", card)
	await host.warp(str(a.zone), a.pos.x, a.pos.y, "down")
	if scene:
		await host.journey_in("ferry", info)
	_ended = true

## A travel scene on the way out (see Journey), if the host plays them: true when one played. The warp to the
## usual arrival tile is still ours to do either way.
func _journey_out(kind: String, info: Dictionary) -> bool:
	if not host.has_method("journey_out"):
		return false
	return bool(await host.journey_out(kind, info))

## Lost a battle: lose half the money, heal up, back to the last Sanctuary.
func whiteout() -> void:
	var data: GameStateData = host.data
	data.money = data.money / 2
	data.heal_party()
	var ls: Dictionary = data.last_sanctuary
	await host.warp(str(ls.zone), int(ls.pos[0]), int(ls.pos[1]), "down")
	await host.say("", WHITEOUT_LINE)
	await host.say("", WHITEOUT_LINE_2)

const PHASE_CONDS := ["dawn", "day", "dusk", "night"]
const WEATHER_CONDS := {"rain": ["drizzle", "downpour"], "fog": ["fog"], "gale": ["gale"], "frost": ["frost"], "sunshine": ["sunshine"]}

## Conditions that aren't flags: the time of day ("dawn", "day", "dusk", "night", from the in-game clock), the
## weather ("rain" is drizzle or a downpour; "fog", "gale", "frost", "sunshine"), "caught_all" (every species
## in the Fieldbook proper caught; the appendix is a bonus), "caught_<n>" (at least n caught), and from the real date the season ("spring".."winter") or a festival (Calendar.FESTIVALS).
func _when(cond: String) -> bool:
	if cond in PHASE_CONDS:
		return GameClock.phase(host.data.clock_minutes) == cond
	if WEATHER_CONDS.has(cond):
		return _weather() in WEATHER_CONDS[cond]
	if cond == "caught_all":
		return FieldbookGoals.caught_count(host.data) >= host.dex.core_ids().size()
	if cond.begins_with("caught_") and cond.substr(7).is_valid_int():  # a Fieldbook milestone: caught_25 and so on
		return FieldbookGoals.caught_count(host.data) >= int(cond.substr(7))
	if cond in Calendar.SEASONS:
		return Calendar.season_today() == cond
	if cond in Calendar.FESTIVALS:
		return Calendar.festival_today() == cond
	push_warning("Commands: unknown condition '%s'" % cond)
	return false

## The outdoor weather: the overworld's sky when the host has one, otherwise the saved outdoor weather
## (which interiors inherit). Nothing rolled yet is "clear".
func _weather() -> String:
	var w := str(host.current_weather()) if host.has_method("current_weather") else str(host.data.weather)
	return w if w != "" else "clear"

func _test(c: Dictionary) -> bool:
	var v: Variant = host.data.flag(str(c.get("flag", "")))
	if c.has("eq"):
		return _loose_eq(v, c.eq)
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return true

static func _loose_eq(a: Variant, b: Variant) -> bool:
	if typeof(a) in [TYPE_INT, TYPE_FLOAT] and typeof(b) in [TYPE_INT, TYPE_FLOAT]:
		return is_equal_approx(float(a), float(b))
	return a == b

func _set_flag(key: String, value: Variant) -> void:
	if typeof(value) == TYPE_FLOAT and value == floorf(value):
		value = int(value)
	host.data.set_flag(key, value)
	if host.has_method("on_flag"):
		host.on_flag(key, value)

func _sub(s: String) -> String:
	var total: int = host.dex.core_ids().size()  # the Fieldbook proper: the appendix is a bonus
	var got: int = FieldbookGoals.caught_count(host.data)
	return s.replace("{player}", host.data.player_name).replace("{rival}", host.data.rival_name) \
		.replace("{caught}", str(got)).replace("{left}", str(maxi(0, total - got))).replace("{total}", str(total)) \
		.replace("{greeting}", _greeting() if "{greeting}" in s else "")

## {greeting}: the local hello, and once you're a Pillar of the Community here, a word about what you sorted out.
func _greeting() -> String:
	var g := StoryData.greeting(host.data.zone_id, host.data.clock_minutes)
	var extra := Standing.greeting_extra(host.data, host.data.zone_id)
	return g + (" " + extra if extra != "" else "")
