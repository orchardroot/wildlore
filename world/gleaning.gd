class_name Gleaning
extends RefCounted
## The countryside gives back: about one wild win in six, the beaten creature leaves a material behind (wool off a
## kin, peat off a bog creature, blackberries off a hedgerow one in autumn), which goes in the bag for Mum's bench.
## Pure logic: the battle flow says the lines.

const CHANCE := 16.0  # percent

## Type -> material id. Hedgerow is seasonal (see material_for).
const BY_TYPE := {
	"kin": "sheep_wool", "hedgerow": "hawthorn_berry", "brook": "wild_garlic", "tide": "seaweed", "hearth": "hazelnuts",
	"gale": "heather_honey", "storm": "nettles", "frost": "rowan_berry", "stone": "slate_chip", "bog": "peat",
	"iron": "slate_chip", "urban": "sea_glass", "fae": "elderflower", "spirit": "field_mushrooms", "brawn": "nettles",
	"night": "field_mushrooms",
}

static func material_for(type: String, season: String) -> String:
	if type == "hedgerow" and season == "autumn":
		return "blackberries"
	return str(BY_TYPE.get(type, "nettles"))

## Rolls for a gleaning off the first foe; adds it to `bag` and returns the line to say ([] for nothing).
## `season` "" means today's.
static func after_wild_win(bag: Bag, foes: Array, rng: Rng, items: ItemDB, season := "") -> Array:
	if foes.is_empty() or not rng.chance(CHANCE):
		return []
	var foe: Creature = foes[0]
	var types: Array = foe.types()
	var id := material_for(str(types[0]) if not types.is_empty() else "", season if season != "" else Calendar.season_today())
	if bag.add(id) < 1:
		return []
	var it := items.get_item(id)
	return ["The wild %s left behind %s. Into the bag it goes." % [foe.display_name(), str(it.get("one", "a " + str(it.get("name", id))))]]
