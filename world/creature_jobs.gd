class_name CreatureJobs
extends RefCounted
## Jobs for your lead creature out on the routes: face a `creature_job` prop and press Confirm, and if the creature
## at the head of your party is the right type it does the job (fords the stream, fetches from the ledge...) and
## you get a small find, once. Never needed for the story: every spot sits on open ground with room to walk round.
##
## Zone JSON: {"type": "creature_job", "job": "ford", "x": 12, "y": 7, "item": "seaweed", "n": 1 (optional)}
## A job done is remembered in the flag cjob_<zone>_<x>_<y>.

const TYPE := "creature_job"

## job -> what it is, which creature types can do it, and what is said. `spot` is how the prop is named to you.
const KINDS := {
	"ford": {"types": ["brook", "tide"], "spot": "stream with a stepping stone just out of reach", "anim": "hop",
		"do": "%s wades out, finds the stones and brings back what the water was hiding.", "hint": "Looks like a job for a brook or tide type."},
	"fetch": {"types": ["gale", "storm"], "spot": "ledge with something caught on it", "anim": "rise",
		"do": "%s whips up the rock face on the wind and comes back with it.", "hint": "Out of reach. A gale or storm type could manage it."},
	"nudge": {"types": ["kin", "brawn", "stone", "iron"], "spot": "boulder with something under it", "anim": "shove",
		"do": "%s puts a shoulder to the boulder and rolls it over. Something was underneath.", "hint": "Far too heavy for you. A kin, brawn, stone or iron type might shift it."},
	"sniff": {"types": ["hedgerow", "fae", "bog"], "spot": "tangle of undergrowth that smells promising", "anim": "wiggle",
		"do": "%s noses into the undergrowth and comes out with a mouthful of something good.", "hint": "A hedgerow, fae or bog type would know where to look."},
	"cross": {"types": ["frost"], "spot": "frozen puddle with a glint under the ice", "anim": "slide",
		"do": "%s breathes on the water and skates over the new ice to fetch it.", "hint": "A frost type could freeze a path over that."},
	"reveal": {"types": ["spirit", "night", "hearth", "urban"], "spot": "odd stone that feels like it is listening", "anim": "glow",
		"do": "%s stares at the stone until a small hidden path shows, and something was left along it.", "hint": "A spirit, night, hearth or urban type might see more than you can."},
}
const DONE := "You've done this one already. The lead looks pleased with itself."
const NO_LEAD := "You'd want a creature that's up to it with you first."

static func flag_key(zone_id: String, p: Vector2i) -> String:
	return "cjob_%s_%d_%d" % [zone_id, p.x, p.y]

static func is_done(data: GameStateData, zone_id: String, p: Vector2i) -> bool:
	return data.flag(flag_key(zone_id, p)) == true

static func prop_at(z: ZoneData, p: Vector2i) -> Dictionary:
	for pr in z.props:
		if str(pr.get("type", "")) == TYPE and int(pr.get("x", -1)) == p.x and int(pr.get("y", -1)) == p.y:
			return pr
	return {}

## Can a creature with these types do job `kind`?
static func can_do(kind: String, types: Array) -> bool:
	for t in types:
		if t in KINDS.get(kind, {}).get("types", []):
			return true
	return false

## Tries the job with the party's lead. {"ok": did it, "lines": what to say, "kind": job, "got": {item: n}}.
static func attempt(data: GameStateData, z: ZoneData, pr: Dictionary, items: ItemDB) -> Dictionary:
	var p := Vector2i(int(pr.x), int(pr.y))
	var kind := str(pr.get("job", ""))
	var k: Dictionary = KINDS.get(kind, {})
	if k.is_empty():
		return {"ok": false, "lines": [], "kind": kind, "got": {}}
	var spot := "A %s." % k.spot
	if is_done(data, z.id, p):
		return {"ok": false, "lines": [DONE], "kind": kind, "got": {}}
	var lead := data.first_able()
	if lead == null:
		return {"ok": false, "lines": [spot, NO_LEAD], "kind": kind, "got": {}}
	if not can_do(kind, lead.types()):
		return {"ok": false, "lines": [spot, k.hint], "kind": kind, "got": {}}
	var item := str(pr.get("item", ""))
	var got := {}
	var lines := [str(k["do"]) % lead.display_name()]
	if item != "" and items.has(item):
		var n := Bag.new(data.bag).add(item, int(pr.get("n", 1)))
		if n > 0:
			got[item] = n
			lines.append("You find %s." % (str(items.get_item(item).get("one", item)) if n == 1 else "%d %s" % [n, items.get_item(item).get("name", item)]))
		else:
			lines.append("Your bag is too full to take what it found. Next time.")
			return {"ok": false, "lines": lines, "kind": kind, "got": {}}
	data.set_flag(flag_key(z.id, p), true)
	return {"ok": true, "lines": lines, "kind": kind, "got": got}

## Problems with a zone's job props (for the validator).
static func errors(z: ZoneData, items: ItemDB) -> Array:
	var e := []
	var seen := {}
	for pr in z.props:
		if str(pr.get("type", "")) != TYPE:
			continue
		var p := Vector2i(int(pr.get("x", -1)), int(pr.get("y", -1)))
		var tag := "zone %s: creature_job at %d,%d " % [z.id, p.x, p.y]
		if not KINDS.has(str(pr.get("job", ""))):
			e.append(tag + "has unknown job '%s'" % str(pr.get("job", "")))
		if not z.in_bounds(p):
			e.append(tag + "is out of bounds")
			continue
		if seen.has(p):
			e.append(tag + "is doubled up")
		seen[p] = true
		if z.tile_at(p) not in ["grass", "tall_grass", "flowers", "sand", "path", "cobbles"]:
			e.append(tag + "is not on open ground")
		if str(pr.get("item", "")) != "" and not items.has(str(pr.get("item", ""))):
			e.append(tag + "gives unknown item '%s'" % str(pr.item))
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
			if z.in_bounds(p + d) and (z.tile_at(p + d) in ["door", "rail"] or not z.warp_at(p + d).is_empty()):
				e.append(tag + "is next to a door, rail or warp, so it could block the way")
				break
	return e
