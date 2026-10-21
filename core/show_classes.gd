class_name ShowClasses
extends RefCounted
## The County Show's gentler classes (the battling class is Tournament): the produce class, where you enter any
## item of kind "produce" and the judges mark it for size and condition against four local growers, and the
## sheepdog trials (see Sheepdog) and the Breed Class (see Stud). Each class can be entered once per show day; a rosette (red, blue or yellow)
## and a small purse go with a top-three place. Pure logic: the Steward's menu is in story/tournament_run.gd.
## Money can't be printed here: one entry a class a day, a produce entry costs you the item, and the biggest
## day's purse (PRODUCE_PRIZE + DOG_PRIZE firsts) is a few pounds.

const PRODUCE := "produce"
const DOG := "sheepdog"
const BREED := "breed"
const PRODUCE_PRIZE := [30, 20, 10]   # sterling, first to third
const DOG_PRIZE := [40, 25, 10]
const BREED_PRIZE := [40, 25, 10]
const SHOW_EVERY := 7             # the shows come round about weekly (the balance sims assume it)
const COLOURS := ["red", "blue", "yellow"]
const RIVALS := 4
const FLAG_PREFIX := "show_class_"   # + class id: DailyKey stamp of the day it was last entered
const WINS_PREFIX := "show_class_wins_"

## What the player can enter: [{id, name, n}] for every bag item of kind "produce".
static func entrants(data: GameStateData, items: ItemDB) -> Array:
	var out := []
	for id in data.bag:
		if int(data.bag[id]) > 0 and items.has(str(id)) and str(items.get_item(str(id)).get("kind", "")) == PRODUCE:
			out.append({"id": str(id), "name": str(items.get_item(str(id)).get("name", id)), "n": int(data.bag[id])})
	out.sort_custom(func(a, b): return str(a.id) < str(b.id))
	return out

static func _rng(seed_text: String) -> Rng:
	return Rng.new(absi(hash(seed_text)))

## The judges' marks for one entry, 0 to 100: {size, condition, score}. Seeded by the show, the day and the item, so
## a retry can't re-roll it. A dearer item (a rarer vegetable) runs a touch bigger.
static func judge(item: Dictionary, seed_text: String) -> Dictionary:
	var rng := _rng("judge/%s/%s" % [seed_text, item.get("id", "")])
	var bonus := mini(10, int(item.get("price", 0)) / 20)
	var size := clampi(rng.roll_int(35, 90) + bonus, 0, 100)
	var cond := clampi(rng.roll_int(30, 95), 0, 100)
	return {"size": size, "condition": cond, "score": int(round(size * 0.5 + cond * 0.5))}

## The four local growers' scores for a show and day.
static func rivals(seed_text: String) -> Array:
	var rng := _rng("rivals/" + seed_text)
	var out := []
	for i in RIVALS:
		out.append(rng.roll_int(40, 82))
	return out

## 1 for best. A tie with a grower goes to the grower (the judges know them).
static func place(score: int, rival_scores: Array) -> int:
	var p := 1
	for r in rival_scores:
		if int(r) >= score:
			p += 1
	return p

## {colour, money} for a place, or {} past third.
static func prize(cls: String, p: int) -> Dictionary:
	var table: Array = PRODUCE_PRIZE if cls == PRODUCE else (BREED_PRIZE if cls == BREED else DOG_PRIZE)
	if p < 1 or p > table.size():
		return {}
	return {"colour": COLOURS[p - 1], "money": int(table[p - 1])}

static func entered_today(data: GameStateData, cls: String) -> bool:
	return DailyKey.done_today(data, FLAG_PREFIX + cls)

static func mark_entered(data: GameStateData, cls: String) -> void:
	data.set_flag(FLAG_PREFIX + cls, DailyKey.stamp(data))

static func wins(data: GameStateData, cls: String) -> int:
	return int(data.flag(WINS_PREFIX + cls)) if data.flag(WINS_PREFIX + cls) != null else 0

## Pays the purse for a place and tallies a first. Returns the prize dictionary ({} if unplaced).
static func award(data: GameStateData, cls: String, p: int, cur: String) -> Dictionary:
	var pr := prize(cls, p)
	if pr.is_empty():
		return pr
	Wallet.earn(data, Wallet.localise(int(pr.money), cur), cur)
	TrainerStats.earned(data, int(pr.money))
	TrainerStats.add(data, "show_rosettes")
	if p == 1:
		data.set_flag(WINS_PREFIX + cls, wins(data, cls) + 1)
	return pr
