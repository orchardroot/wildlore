class_name PairingLogic
extends RefCounted
## The pairing screen's decisions, pure (data in, no autoloads): who can be offered, what the farmer says, how close
## kin they are. Genetics.can_pair has the rules of species and sex; this adds fondness and the one-a-day limit.

const FOND_HEARTS := 2  # "Fond", the second bond tier

static func is_fond(c: Creature) -> bool:
	return Bond.hearts(c.friendship) >= FOND_HEARTS

## Team then Ark, as [{c, where, index}], keeping only creatures of a kindred that breeds.
static func candidates(data: GameStateData) -> Array:
	var out := []
	var i := 0
	for c in data.party:
		if Genetics.breeds(Genetics.kindred_of(c)):
			out.append({"c": c, "where": "team", "index": i})
		i += 1
	i = 0
	for c in data.ark:
		if Genetics.breeds(Genetics.kindred_of(c)):
			out.append({"c": c, "where": "ark", "index": i})
		i += 1
	return out

## Kinship in words; "Too close" is where the farmer refuses.
static func kinship_words(k: float) -> String:
	if k >= float(Genetics.genes().get("inbreeding", {}).get("refuse_at", 0.25)):
		return "Too close"
	if k >= 0.125:
		return "Close kin"
	if k >= 0.0625:
		return "Cousins"
	if k > 0.0:
		return "Distant cousins"
	return "Unrelated"

## The verdict on a chosen pair: {ok, why, kind, kin, kin_words}. `sire` and `dam` may be either way round (the
## screen lets the player pick two and sorts them); null means that slot is still empty.
static func verdict(data: GameStateData, zone_id: String, a: Creature, b: Creature) -> Dictionary:
	if a == null or b == null:
		return {"ok": false, "why": "Pick two.", "kind": "", "kin": 0.0, "kin_words": ""}
	var sire := a
	var dam := b
	if a.sex == "f" and b.sex == "m":
		sire = b
		dam = a
	var v := Genetics.can_pair(sire, dam)
	var kin := Genetics.kinship(sire, dam)
	v["kin"] = kin
	v["kin_words"] = kinship_words(kin)
	v["sire"] = sire
	v["dam"] = dam
	if v.ok:
		for p in [sire, dam]:
			if not is_fond(p):
				v.ok = false
				v.why = "%s doesn't know you well enough yet. They'd want to be fond of each other and of you." % _name(p)
				return v
		if Breeding.paired_today(data, zone_id):
			v.ok = false
			v.why = "One pairing a day. Come back tomorrow."
		elif Breeding.baskets(data).size() >= Breeding.MAX_BASKETS:
			v.ok = false
			v.why = "Three baskets on the go is plenty. Walk some off first."
	return v

## Dot's line for a verdict that is fine.
static func fine_line(v: Dictionary) -> String:
	var line := "Fine pair." if v.kin <= 0.0 else "Fine pair, though they're %s." % str(v.kin_words).to_lower()
	if str(v.get("kind", "")) == "crossbreed":  # a generated cross: how likely it is to take
		line += " " + Crossbreeds.odds_line(str(v.get("tier", "")))
	return line

static func _name(c: Creature) -> String:
	return c.nickname if c.nickname != "" else str(c.species.get("name", "They"))

## What the Stud Book should learn from a verdict the player has just been shown.
static func notes_for(v: Dictionary) -> Array:
	var out := []
	if v.get("sire") == null:
		return out
	for p in [v.sire, v.dam]:
		if (p.hybrid != "" and Genetics.hybrids().get(p.hybrid, {}).get("fertile", true) == false) or Crossbreeds.sterile(p):
			out.append("sterile")
	if v.kin >= 0.125:
		out.append("close_kin")
	elif v.ok and v.kin <= 0.0:
		out.append("unrelated")
	return out

## 1240 -> "1,240".
static func commas(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out

## The pause card's basket line, or "" with nothing in a basket: "Basket: 1,240 steps to go".
static func basket_line(data: GameStateData) -> String:
	var bs := Breeding.baskets(data)
	if bs.is_empty():
		return ""
	var nearest := -1
	for b in bs:
		var left := maxi(0, int(b.get("steps_due", 0)) - Breeding.steps_now(data))
		nearest = left if nearest < 0 else mini(nearest, left)
	if bs.size() == 1:
		return "Basket: ready to hatch" if nearest == 0 else "Basket: %s steps to go" % commas(nearest)
	return "Baskets: %d, one ready to hatch" % bs.size() if nearest == 0 else "Baskets: %d, next in %s steps" % [bs.size(), commas(nearest)]
