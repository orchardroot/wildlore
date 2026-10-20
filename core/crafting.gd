class_name Crafting
extends RefCounted
## Recipes (data/recipes.json): materials, plus sometimes a basic item or a bit of money, made into regional food,
## snares and charms at a bench. A recipe is known once its flag `recipe_<id>` is set: Mum teaches the first few,
## folk around the isles teach the rest. Pure logic (no autoloads), so the story validator can check recipes too.

const PATH := "res://data/recipes.json"
const FLAG_PREFIX := "recipe_"
## Charm ids from the 1.5 contract. Charms live in data/items/charms.json (the bond-charms work); until that lands
## a recipe may still name one, and the validator lets it through.
const CONTRACT_CHARMS := ["hag_stone", "horseshoe", "four_leaf_clover", "brigid_cross", "leek", "rowan_sprig",
	"selkie_pearl", "miners_lamp", "thistle_brooch", "shamrock_pin", "oak_acorn"]
## Mum's kitchen and the Field Station bench (any bench can make any recipe; the name is for the title).
const BENCHES := {"kitchen": "Mum's Kitchen", "workbench": "Field Station Bench", "borrowed": "A Borrowed Kitchen", "hob": "The Pub Hob"}

static var _cache: Array = []

static func all() -> Array:
	if _cache.is_empty():
		var d = JsonUtil.read(PATH)
		_cache = d if d is Array else []
	return _cache

static func has(id: String) -> bool:
	return not get_recipe(id).is_empty()

static func get_recipe(id: String) -> Dictionary:
	for r in all():
		if str(r.get("id", "")) == id:
			return r
	return {}

static func flag_for(id: String) -> String:
	return FLAG_PREFIX + id

static func is_known(data: GameStateData, id: String) -> bool:
	return data.flag(flag_for(id)) == true

static func learn(data: GameStateData, id: String) -> bool:
	var fresh := not is_known(data, id)
	data.set_flag(flag_for(id), true)
	return fresh

## Known recipes, in file order.
static func known(data: GameStateData) -> Array:
	return all().filter(func(r): return is_known(data, str(r.id)))

## Recipes a teacher ("from") hands out.
static func taught_by(who: String) -> Array:
	return all().filter(func(r): return str(r.get("from", "")) == who).map(func(r): return str(r.id))

## What stops `r` being made right now, or "" when it can be.
static func blocker(data: GameStateData, r: Dictionary) -> String:
	var bag := Bag.new(data.bag)
	var ins: Dictionary = r.get("in", {})
	for id in ins:
		if bag.count(str(id)) < int(ins[id]):
			return "short"
	if not Wallet.can_afford(data, cost(data, r), Wallet.local(data)):
		return "money"
	if bag.count(str(r.out)) + int(r.get("n", 1)) > Bag.MAX_STACK:
		return "full"
	return ""

static func can_make(data: GameStateData, r: Dictionary) -> bool:
	return blocker(data, r) == ""

## Makes one batch: takes the inputs and money, adds the output. {"ok", "text"}.
static func craft(data: GameStateData, r: Dictionary, items: ItemDB) -> Dictionary:
	var out_name := str(items.get_item(str(r.out)).get("name", str(r.out).capitalize()))
	if not items.has(str(r.out)):  # a contract charm before charms.json has landed: nothing to make yet
		return {"ok": false, "text": "Nobody's quite sure how the %s goes yet." % out_name}
	match blocker(data, r):
		"short":
			return {"ok": false, "text": "You're short of something for the %s." % out_name}
		"money":
			return {"ok": false, "text": "You'll need %s for the rest of the ingredients." % Wallet.fmt(cost(data, r), Wallet.local(data))}
		"full":
			return {"ok": false, "text": "Your bag can't fit any more %s." % out_name}
	var bag := Bag.new(data.bag)
	var ins: Dictionary = r.get("in", {})
	for id in ins:
		bag.remove(str(id), int(ins[id]))
	Wallet.spend(data, cost(data, r), Wallet.local(data))
	var n := int(r.get("n", 1))
	bag.add(str(r.out), n)
	return {"ok": true, "text": "You made %s%s." % [out_name, " x%d" % n if n > 1 else ""]}

## What the rest of the ingredients cost where you stand (euros in the Republic).
static func cost(data: GameStateData, r: Dictionary) -> int:
	return Wallet.localise(int(r.get("money", 0)), Wallet.local(data))

## Everything wrong with the recipe file: duplicate ids, unknown inputs or outputs, silly counts.
static func validate(items: ItemDB, recipes: Array = all()) -> Array:
	var e := []
	var seen := {}
	for r in recipes:
		var id := str(r.get("id", ""))
		var tag := "recipe '%s': " % id
		if id == "" or seen.has(id):
			e.append(tag + "id is missing or duplicated")
		seen[id] = true
		var out := str(r.get("out", ""))
		if not items.has(out) and out not in CONTRACT_CHARMS:
			e.append(tag + "makes unknown item '%s'" % out)
		if int(r.get("n", 1)) < 1:
			e.append(tag + "makes nothing (n < 1)")
		if int(r.get("money", 0)) < 0:
			e.append(tag + "negative money")
		var ins = r.get("in", {})
		if not ins is Dictionary or ins.is_empty():
			e.append(tag + "needs at least one input")
			continue
		for k in ins:
			if not items.has(str(k)):
				e.append(tag + "needs unknown item '%s'" % k)
			if int(ins[k]) < 1:
				e.append(tag + "needs %d of '%s'" % [int(ins[k]), k])
	return e
