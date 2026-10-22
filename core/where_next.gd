class_name WhereNext
extends RefCounted
## "Where next?" (4.0): up to three worthwhile things, most pressing first. The story always leads; then a quest under
## way nearby, what is happening around here, a festival on today, a Deed's till worth collecting and a basket about
## to hatch. Each appears only when it applies, so a new save sees one line and a busy one sees three.
## `opts` is for tests: story (false to skip), o / sides / quests (as MenuLogic takes them), show, fest (lines).

const LIMIT := 3
const TILL_WORTH := 50          # pounds in a till before it is worth a mention
const BASKET_SOON := 500        # steps: a basket this close to hatching is worth a mention

static func suggest(d: GameStateData, total := 0, town := "", opts := {}) -> Array:
	var out := []
	if opts.get("story", true):
		var o := MenuLogic.next_objective(d, total, opts.get("o", {}), opts.get("sides", []), opts.get("quests", []))
		if not o.is_empty():
			out.append({"kind": "story", "text": str(o.get("text", "")), "town": str(o.get("town", ""))})
	var q := MenuLogic.quest_nearby(d, town, opts.get("quests", []))
	if q != "":
		out.append({"kind": "quest", "text": q})
	var here := MenuLogic.around_here(d, town, opts.get("show", {}), opts.get("sides", []))
	if here != "":
		out.append({"kind": "here", "text": here})
	var fest: Array = opts.get("fest", []) if opts.has("fest") else Festivals.whats_on(Vector2i(-1, -1), 3)
	for f in fest:
		if str(f).begins_with("On now"):
			out.append({"kind": "festival", "text": str(f)})
			break
	var deed := _best_till(d)
	if not deed.is_empty():
		out.append({"kind": "deed", "text": "%s has %s waiting in the till." % [deed.name, deed.sum]})
	var basket := _basket(d)
	if basket != "":
		out.append({"kind": "basket", "text": basket})
	var seen := {}
	var unique := []
	for s in out:
		if not seen.has(s.text) and s.text != "":
			seen[s.text] = true
			unique.append(s)
	return unique.slice(0, LIMIT)

static func _best_till(d: GameStateData) -> Dictionary:
	var best := {}
	var most := 0
	for dd in Deeds.owned(d):
		var id := str(dd.id)
		var t := Deeds.till(d, id)
		if t >= TILL_WORTH and t > most:
			most = t
			best = {"name": str(dd.get("name", id)), "sum": Wallet.fmt(t, Deeds.cur_of(id))}
	return best

static func _basket(d: GameStateData) -> String:
	var nearest := -1
	for b in Breeding.baskets(d):
		var left := maxi(0, int(b.get("steps_due", 0)) - Breeding.steps_now(d))
		nearest = left if nearest < 0 else mini(nearest, left)
	if nearest < 0 or nearest > BASKET_SOON:
		return ""
	return "A basket is ready to hatch." if nearest == 0 else "A basket hatches in about %d steps." % nearest
