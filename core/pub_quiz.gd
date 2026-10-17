class_name PubQuiz
extends RefCounted
## The pub quiz: the question bank (data/quiz/questions.json), picking a round weighted towards the pub's region,
## the prize ladder and the once-a-day-per-pub prize lock. Pure logic; ui/quiz_screen.gd shows it.
##
## A bank entry: {cat, region, q, a (the right answer), wrong (three others), fact (one line shown afterwards)}.

const BANK_PATH := "res://data/quiz/questions.json"
const ROUND_SIZE := 5
const REGIONS := ["all", "england_north", "england_south", "london", "scotland", "wales", "ireland", "ni"]
const HOME_WEIGHT := 4.0
const NEAR_WEIGHT := 2.0
const NORMAL_WEIGHT := 1.0
const AWAY_WEIGHT := 0.5
## Regions that count as next door for the weighting.
const NEAR := {"london": ["england_south"], "england_south": ["london"], "ni": ["ireland"], "ireland": ["ni"]}
const FLAG_PREFIX := "quiz_day_"

static var _bank: Array = []

static func load_bank() -> Array:
	if _bank.is_empty():
		var raw: Variant = JsonUtil.read(BANK_PATH)
		if raw is Array:
			_bank = raw
	return _bank

## How likely a question is to be drawn at a pub in `region`. A pub with no region ("" or "all") has no bias.
static func weight(q: Dictionary, region: String) -> float:
	var r := str(q.get("region", "all"))
	if region == "" or region == "all" or r == "all":
		return NORMAL_WEIGHT
	if r == region:
		return HOME_WEIGHT
	if r in NEAR.get(region, []):
		return NEAR_WEIGHT
	return AWAY_WEIGHT

## `n` different questions, drawn without replacement, favouring `region`.
static func pick_round(bank: Array, region: String, rng: Rng, n := ROUND_SIZE) -> Array:
	var pool: Array = bank.duplicate()
	var out: Array = []
	while out.size() < n and not pool.is_empty():
		var total := 0.0
		for q in pool:
			total += weight(q, region)
		var roll := rng.roll() * total
		var chosen := pool.size() - 1
		for i in pool.size():
			roll -= weight(pool[i], region)
			if roll < 0.0:
				chosen = i
				break
		out.append(pool[chosen])
		pool.remove_at(chosen)
	return out

## A question ready to show: {q, options (shuffled), answer (index into options), fact, cat}.
static func build(q: Dictionary, rng: Rng) -> Dictionary:
	var options: Array = [str(q.a)]
	for w in q.wrong:
		options.append(str(w))
	for i in range(options.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = options[i]
		options[i] = options[j]
		options[j] = t
	return {"q": str(q.q), "options": options, "answer": options.find(str(q.a)), "fact": str(q.fact), "cat": str(q.cat)}

# ---- prizes

## What a score earns: {item, n, money, text}. Nothing here is a balance breaker: one Whitby Jet, a cream tea
## and some pocket money, at most once a day per pub.
static func prize(score: int) -> Dictionary:
	match score:
		5:
			return {"item": "whitby_jet", "n": 1, "money": 0, "text": "the Whitby Jet from the top shelf"}
		4:
			return {"item": "cream_tea", "n": 1, "money": 0, "text": "a slap-up cream tea"}
		3:
			return {"item": "", "n": 0, "money": 300, "text": "a fistful of notes from the kitty"}
		2:
			return {"item": "", "n": 0, "money": 150, "text": "a handful of change from the swear jar"}
		1:
			return {"item": "cup_of_tea", "n": 1, "money": 0, "text": "a consolation cup of tea"}
	return {"item": "", "n": 0, "money": 0, "text": ""}

## Once per real day per pub (DailyKey: the real date, so the in-game day can't be farmed).
static func claimed_today(data: GameStateData, pub: String) -> bool:
	return DailyKey.done_today(data, FLAG_PREFIX + pub)

static func claim(data: GameStateData, pub: String) -> void:
	data.set_flag(FLAG_PREFIX + pub, DailyKey.stamp(data))

## Pays out `score` at `pub` unless the pub's prize was already won today. Returns {paid, item, n, money, text}
## (what was actually handed over; item/n are 0 if the bag was full and cash was given instead).
## `double` (Today's Walk bonus pub): twice the items and twice the money.
static func award(data: GameStateData, items: ItemDB, pub: String, score: int, double := false) -> Dictionary:
	var none := {"paid": false, "item": "", "n": 0, "money": 0, "text": ""}
	if claimed_today(data, pub):
		return none
	claim(data, pub)
	var p := prize(score)
	if double:
		p.n = int(p.n) * 2
		p.money = int(p.money) * 2
	var out := {"paid": false, "item": "", "n": 0, "money": int(p.money), "text": p.text}
	if p.item != "" and not items.get_item(p.item).is_empty():
		var got := Bag.new(data.bag).add(p.item, int(p.n))
		if got > 0:
			out.item = p.item
			out.n = got
		else:
			out.money += 100  # a full bag: the landlord pays you in cash instead
	data.money += int(out.money)
	out.paid = out.item != "" or out.money > 0
	return out

## The quizmaster's reaction to a finished round (warm, pub-quiz-night humour).
static func reaction(score: int, total: int) -> String:
	if score >= total:
		return "Full marks! I'm checking your pockets for a phone, and I'm not even joking."
	if score == total - 1:
		return "So close! One more and we'd have had to call the brewery."
	if score >= 3:
		return "Respectable. You'd hold your own on any team, even Dave's."
	if score >= 1:
		return "Not your night, but the effort was lovely. Have a biscuit."
	return "Nought. Impressive, in its way. I've seen the table football team do better."
