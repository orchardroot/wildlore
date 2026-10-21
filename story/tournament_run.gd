class_name TournamentRun
extends RefCounted
## The `tournament` story command: {"do": "tournament", "id": "show" | "moot" | "trade"}.
##   show   the steward at today's County Show: the class, the entry, three knockout rounds, the rosettes
##   moot   the Moot Herald at Stonehenge (after the Champion): the Open Moot, five back to back
##   trade  the rosette stall at the show ring
## Your creatures fight as exhibition copies (Tournament): capped to the class, no XP, healed between show rounds,
## and the real team is put back however it ends. Losing is never a whiteout. Rules and prizes live in Tournament.

const STEWARD := "Steward"
const HERALD := "Moot Herald"
const STALL := "Rosette Stall"
const SHOW_ROUND_NAMES := ["Round one", "The semi-final", "The final"]
const MOOT_ROUND_NAMES := ["The first stone", "The second stone", "The third stone", "The fourth stone", "The heel stone"]

var cmd: Commands
var host

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func run(c: Dictionary) -> void:
	match str(c.get("id", "")):
		"show":
			await _show()
		"show_menu":
			await _show_menu()
		"moot":
			await _moot()
		"trade":
			await _trade()
		_:
			push_warning("TournamentRun: unknown tournament '%s'" % c.get("id", ""))

func _say(who: String, text: String) -> void:
	await host.say(who, text)

static func _names(list: Array) -> String:
	if list.size() <= 1:
		return "".join(list)
	return ", ".join(list.slice(0, list.size() - 1)) + " and " + str(list.back())

# ---------------------------------------------------------------- County Shows

func _show() -> void:
	var data: GameStateData = host.data
	var s := Tournament.today(data)
	if s.is_empty():
		await _say(STEWARD, "No show today, I'm afraid. The marquee's in the wash.")
		return
	if str(s.town) != str(host.zone_id()):
		await _say(STEWARD, "You're keen! The County Show today is %s, %s." % [str(s.name), str(s.where)])
		return
	if not Tournament.open_to(data):
		await _say(STEWARD, "Welcome to %s! The battling classes are for trainers with two Keeper's Stones or more, I'm afraid. Have a look at the cheeses, and come back once you've a couple." % str(s.name))
		return
	var key := Calendar.today_key()
	var rule := Tournament.ruleset("%s/%s" % [key, s.id], data.party)
	var cap := Tournament.cap_for(data)
	for line in welcome_lines(s):
		await _say(STEWARD, line)
	await _say(STEWARD, "Today's class is %s, level %d cap. %s" % [Tournament.rule_name(rule), cap, Tournament.rule_text(rule)])
	var el := Tournament.eligible(data.party, rule, Tournament.SHOW_SIZE)
	if el.picks.is_empty():
		await _say(STEWARD, str(el.why))
		return
	await _say(STEWARD, "Three rounds, knockout, three a side. We patch everyone up between rounds, and nobody's creature comes home any worse, or any wiser. It's for the rosettes, not the experience.")
	var who: Array = el.picks.map(func(i): return data.party[i].display_name())
	var cur := Wallet.local(data)  # an Irish show takes its fee in euros
	var fee := Wallet.localise(Tournament.FEE, cur)
	var pick: int = await host.choice("Enter %s for %s?" % [_names(who), Wallet.fmt(fee, cur)], ["Enter", "Not today"])
	if pick != 0:
		await _say(STEWARD, "Right you are. The cake tent's that way if you change your mind.")
		return
	if not Wallet.spend(data, fee, cur):
		await _say(STEWARD, "Entry's %s, and your purse says otherwise. Come back when you're flush." % Wallet.fmt(fee, cur))
		return
	var top := 1
	for i in el.picks:
		top = maxi(top, mini(data.party[i].level, cap))
	var levels := []
	for r in Tournament.SHOW_ROUNDS:
		levels.append(Tournament.show_level(r, top, cap))
	var bracket := Tournament.draw("%s/%s/%s" % [key, s.id, rule.id], Tournament.trainer_pool(false), Tournament.SHOW_ROUNDS, rule, host.dex, levels)
	await cmd.host.sfx("confirm")
	await _say(STEWARD, "Paid and pinned. Here's your number. Into the ring when your name's called!")
	var wins := await _rounds(bracket, el.picks, rule, cap, true, "trainer", SHOW_ROUND_NAMES, false)
	var paid := Tournament.pay_show(data, Tournament.rosettes_for(wins))
	match wins:
		3:
			Tournament.note_show_win(data)
			await host.sfx("badge")
			await _say(STEWARD, "And the winner of the %s, %s: %s! A red rosette, and a round of applause from the sheep pens." % [Tournament.rule_name(rule), str(s.name).trim_prefix("the "), data.player_name])
		2:
			await _say(STEWARD, "Runner-up, and a blue rosette. Proper close, that. The judges were torn.")
		1:
			await _say(STEWARD, "Out in the semi-final, but that's a yellow rosette for a good go. Nothing to be ashamed of.")
		_:
			await _say(STEWARD, "Out in the first round. Happens to the best. Have a cup of tea and come back fighting.")
	if paid > 0:
		await host.sfx("item")
		await _say("", "%s received %s." % [data.player_name, "a Show Rosette" if paid == 1 else "%d Show Rosettes" % paid])
	elif wins > 0:
		await _say(STEWARD, "You've had today's rosettes already, mind. The glory's free.")

## The Steward's class list: the battling class (_show) and the gentler ones (ShowClasses), open to everyone.
func _show_menu() -> void:
	var data: GameStateData = host.data
	var s := Tournament.today(data)
	if s.is_empty() or str(s.town) != str(host.zone_id()):
		await _show()
		return
	var pick: int = await host.choice("Which class, then?", ["Battling class", "Produce class", "Sheepdog trials", "Breed class", "Just looking"])
	match pick:
		0:
			await _show()
		1:
			await _produce(s)
		2:
			await _sheepdog(s)
		3:
			await _breed(s)
		_:
			await _say(STEWARD, "Look all you like. The cake tent's that way.")

func _plaque(cls: String) -> void:
	var text := str(Tournament.config().get("plaques", {}).get(cls, ""))
	if text != "":
		await _say("", text)

## The produce class: one item of kind "produce" a day, marked for size and condition against four growers.
func _produce(s: Dictionary) -> void:
	var data: GameStateData = host.data
	if ShowClasses.entered_today(data, ShowClasses.PRODUCE):
		await _say(STEWARD, "You've entered the produce class today already. The judges have gone for a lie-down.")
		return
	var ents := ShowClasses.entrants(data, host.items)
	if ents.is_empty():
		await _say(STEWARD, "The produce tent wants something from the soil: vegetables, fruit, anything you've grown. Bring it back and we'll see.")
		await _plaque(ShowClasses.PRODUCE)
		return
	var options: Array = ents.map(func(e): return "%s (%d)" % [e.name, e.n])
	options.append("Not today")
	var pick: int = await host.choice("What are you entering? It goes to the tea tent afterwards, win or lose.", options)
	if pick < 0 or pick >= ents.size():
		await _say(STEWARD, "Righto. The marrows will keep.")
		return
	var item: Dictionary = host.items.get_item(str(ents[pick].id))
	Bag.new(data.bag).remove(str(ents[pick].id), 1)
	ShowClasses.mark_entered(data, ShowClasses.PRODUCE)
	var seed := "%s/%s" % [Calendar.today_key(), s.id]
	var j := ShowClasses.judge(item, seed)
	await _say("Judge", "Size %d out of a hundred, condition %d. Let's see how that stacks up." % [int(j.size), int(j.condition)])
	var p := ShowClasses.place(int(j.score), ShowClasses.rivals(seed))
	await _placed(ShowClasses.PRODUCE, p, "produce")
	await _plaque(ShowClasses.PRODUCE)

## The sheepdog trials: your lead creature herds four sheep through two gates; the Settings easy option widens them.
func _sheepdog(s: Dictionary) -> void:
	var data: GameStateData = host.data
	if ShowClasses.entered_today(data, ShowClasses.DOG):
		await _say(STEWARD, "One run each, I'm afraid. The sheep have had enough of you for one day.")
		return
	var lead := data.first_able()
	if lead == null:
		await _say(STEWARD, "You'll need a creature on its feet to be your dog. This lot are all poorly.")
		return
	await _say(STEWARD, "Four sheep, two gates, one pen, and the clock. %s will do the running; you do the pointing." % lead.display_name())
	if await host.choice("Take your run?", ["Start", "Not today"]) != 0:
		await _say(STEWARD, "Righto. The sheep will be grateful.")
		return
	ShowClasses.mark_entered(data, ShowClasses.DOG)
	TrainerStats.add(data, "sheepdog_trials")
	var easy: bool = host.easy_trial()
	var st: Dictionary = await host.sheepdog(lead.calc_stat("spd"), easy, "%s/%s" % [Calendar.today_key(), s.id], str(s.name).capitalize())
	var n := Sheepdog.penned(st)
	await _say(STEWARD, "%d of %d in the pen." % [n, Sheepdog.SHEEP])
	await _placed(ShowClasses.DOG, Sheepdog.place_for(st), "dog")
	await _plaque(ShowClasses.DOG)

## The Breed Class: one creature a day, judged on coat, frame, markings and pedigree against four breeders. No battle.
func _breed(s: Dictionary) -> void:
	var data: GameStateData = host.data
	if ShowClasses.entered_today(data, ShowClasses.BREED):
		await _say(STEWARD, "You've shown in the breed ring today already. The judge has gone to look at some sheep and refuses to be moved.")
		return
	var ents := Stud.entrants(data)
	if ents.is_empty():
		await _say(STEWARD, "The breed ring wants stock with a sex and a pedigree to show: a ewe, a bull, a hen. Bring one of those and we'll see.")
		await _plaque(ShowClasses.BREED)
		return
	var options: Array = ents.map(func(e): return str(e.name))
	options.append("Not today")
	var pick: int = await host.choice("Who's going in the ring?", options)
	if pick < 0 or pick >= ents.size():
		await _say(STEWARD, "Righto. They'll keep.")
		return
	var c: Creature = data.party[int(ents[pick].index)]
	ShowClasses.mark_entered(data, ShowClasses.BREED)
	var seed := "%s/%s" % [Calendar.today_key(), s.id]
	var j := Stud.judge(c, seed)
	await _say("Judge", "Coat %d, frame %d, markings %d, pedigree %d, and manners %d. Let's see how that stacks up." % [int(j.coat), int(j.frame), int(j.markings), int(j.pedigree), int(j.manners)])
	var p := ShowClasses.place(int(j.score), ShowClasses.rivals(seed + "/breed"))
	await _placed(ShowClasses.BREED, p, "breed")
	await _plaque(ShowClasses.BREED)

func _placed(cls: String, p: int, what: String) -> void:
	var data: GameStateData = host.data
	var cur := Wallet.local(data)
	var pr := ShowClasses.award(data, cls, p, cur)
	if pr.is_empty():
		await _say(STEWARD, "Not placed this time. Nothing to be ashamed of; there's always next year, and the year after.")
		return
	await host.sfx("badge" if p == 1 else "item")
	var place_name: String = ["", "first", "second", "third"][p]
	await _say(STEWARD, "That's %s place in the %s class, and a %s rosette." % [place_name, what, str(pr.colour)])
	await _say("", "%s received a %s rosette and %s." % [data.player_name, str(pr.colour), Wallet.fmt(Wallet.localise(int(pr.money), cur), cur)])

## The Steward's welcome: the show, then its blurb (one line would overrun the dialogue box).
static func welcome_lines(s: Dictionary) -> Array:
	return ["Welcome to %s!" % str(s.name), str(s.blurb)]

# ---------------------------------------------------------------- the Open Moot

func _moot() -> void:
	var data: GameStateData = host.data
	if data.flag("champion") != true:
		await _say(HERALD, "The Open Moot is for Champions. Beat the Moot itself first, and then we'll talk.")
		return
	var streak := Tournament.streak(data)
	await _say(HERALD, "The Open Moot: five challengers, back to back, from every corner of the islands, and a Keeper on the heel stone. No Sanctuary between them, so heal from your bag mid-fight. A new rule every time.")
	if streak > 0:
		await _say(HERALD, "Your streak stands at %d. The stones remember." % streak)
	if await host.choice("Step into the Open Moot?", ["Begin", "Not yet"]) != 0:
		await _say(HERALD, "The stones have waited five thousand years. They'll manage.")
		return
	var runs := Tournament.moot_runs(data) + 1
	data.set_flag(Tournament.MOOT_RUNS, runs)
	var seed := "%s/moot/%d" % [Calendar.today_key(), runs]
	var rule := Tournament.ruleset(seed, data.party)
	var el := Tournament.eligible(data.party, rule, Tournament.MOOT_SIZE)
	await _say(HERALD, "The rule this time: %s. %s" % [Tournament.rule_name(rule), Tournament.rule_text(rule)])
	if el.picks.is_empty():
		await _say(HERALD, str(el.why))
		return
	var total := 0
	for i in el.picks:
		total += int(data.party[i].level)
	var team := ceili(float(total) / el.picks.size())
	var levels := []
	for r in Tournament.MOOT_ROUNDS:
		levels.append(Tournament.moot_level(r, team))
	var bracket := Tournament.moot_bracket(seed, rule, host.dex, levels)
	var wins := await _rounds(bracket, el.picks, rule, Tournament.OPEN_CAP, false, "keeper", MOOT_ROUND_NAMES, true)
	if wins < bracket.size():
		await _say(HERALD, "The stones go quiet. %s" % ("That's the end of a streak of %d. A fine one." % (wins + streak) if wins + streak > 0 else "Not today, then. The Moot will wait."))
		return
	Tournament.note_moot_win(data)
	await host.music("legend")
	await host.sfx("badge")
	await _say(HERALD, "Five challengers, five falls. The Open Moot is yours, %s, and the streak runs to %d." % [data.player_name, Tournament.streak(data)])
	var got := Bag.new(data.bag).add(Tournament.ROSETTE, Tournament.MOOT_ROSETTES)
	var prize := Tournament.moot_prize(data)
	var prize_got := Bag.new(data.bag).add(prize, 1) if prize != "" and host.items.has(prize) else 0
	await host.sfx("item")
	if got > 0:
		await _say("", "%s received %d Show Rosettes." % [data.player_name, got])
	if prize_got > 0:
		await _say("", "%s received the %s." % [data.player_name, str(host.items.get_item(prize).get("name", prize))])
	if Tournament.moot_wins(data) == Tournament.TITLE_WINS:
		await _say(HERALD, "Three Open Moots. The chalk has a word for you now, and the word is Moot Champion. It'll be on your Stats page, where you can look at it as often as you like.")

# ---------------------------------------------------------------- the rounds

## The player's entrants as exhibition copies: capped to `cap`, XP to match, healed, charms off when items are
## barred. The real creatures are never in the battle.
func _exhibition(real: Array, picks: Array, rule: Dictionary, cap: int) -> Array:
	var out := []
	for i in picks:
		var c := Creature.from_dict(real[i].to_dict(), host.dex)
		if c.level > cap:
			c.level = cap
			c.xp = Rules.xp_for_level(c.species.growth, cap)
		if str(rule.get("id", "")) == "no_items":
			c.held = ""
		out.append(c)
	return out

## Fights the bracket in order with the exhibition team; returns how many rounds were won. The real team is put
## back whatever happens.
func _rounds(bracket: Array, picks: Array, rule: Dictionary, cap: int, heal: bool, ai: String, names: Array, moot: bool) -> int:
	var data: GameStateData = host.data
	var real: Array = data.party
	data.real_party = real  # a save made mid-show writes these, never the stand-ins
	data.party = _exhibition(real, picks, rule, cap)
	data.heal_party()
	var wins := 0
	for i in bracket.size():
		var t: Dictionary = bracket[i]
		var title := ("%s %s" % [str(t.get("class", "")), str(t.name)]) if str(t.get("class", "")) != "" and not str(t.name).begins_with(str(t.get("class", ""))) else str(t.name)
		await _say("", "%s: %s!" % [str(names[mini(i, names.size() - 1)]), title])
		var foes := []
		for m in t.party:
			foes.append(Creature.create(host.dex.get_species(str(m.species)), int(m.level), host.rng, host.moves))
		var opts := {"kind": "trainer", "ai": ai, "trainer": t, "exhibition": true, "no_items": str(rule.get("id", "")) == "no_items"}
		if bool(t.get("double", false)) and foes.size() >= 2:
			opts["double"] = true
		var result: Dictionary = await host.battle(foes, opts)
		var won := str(result.get("result", "")) == "win"
		if moot:
			Tournament.note_moot_fight(data, won)
		if not won:
			# the Router stays dark after a loss, waiting for a whiteout warp: there isn't one here
			await host.fade(false)
			break
		wins += 1
		if str(t.get("win", "")) != "":
			await _say(str(t.name), str(t.win))
		# shows patch you up between rounds; the Moot doesn't (use the bag in the fights: the field bag stays
		# shut, as it would only work on the stand-ins)
		if heal and i < bracket.size() - 1:
			data.heal_party()
			await host.sfx("heal")
	data.party = real
	data.real_party = []
	return wins

# ---------------------------------------------------------------- the rosette stall

func _trade() -> void:
	var data: GameStateData = host.data
	var first := true
	while true:
		var wares := Tournament.wares(Calendar.today_key(), data)
		var n := Bag.new(data.bag).count(Tournament.ROSETTE)
		var options: Array = wares.map(func(w): return Tournament.ware_label(w, host.items))
		options.append("Nothing, ta")
		var ask := "You've %d rosette%s. What'll it be?" % [n, "" if n == 1 else "s"]
		if first:  # the patter, once
			ask = "Rosettes for prizes! Charms, snares and the odd family recipe. " + ask
			first = false
		var pick: int = await host.choice(ask, options)
		if pick < 0 or pick >= wares.size():
			await _say(STALL, "Righto. We're here till the cows come home. Literally: they're in the next field.")
			return
		var r := Tournament.buy(data, wares[pick], host.items)
		if bool(r.ok):
			await host.sfx("item")
			await _say("", str(r.text))
		else:
			await host.sfx("bump")
			await _say(STALL, str(r.text))
			return
