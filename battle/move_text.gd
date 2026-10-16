class_name MoveText
extends RefCounted
## Plain-English words for the battle menus: what a move does (built from its effect data, so it always matches
## what Battle and StatusFX really do), how well it lands on a foe, and how likely a snare is to hold.

const STAT_NAMES := {"atk": "Attack", "def": "Defence", "lore": "Lore", "ward": "Ward", "spd": "Speed", "acc": "Accuracy"}

## status -> [doing it, as a chance ("20% chance to ..."), what it means, the same in brackets after a chance]
const STATUS_TEXT := {
	"asleep": ["Puts the foe to sleep", "put the foe to sleep", "it can't move for 1 to 3 turns", "can't move for 1 to 3 turns"],
	"soaked": ["Soaks the foe", "soak the foe", "it slows down and storm moves hit it harder", "slower, and hurt more by storm moves"],
	"chilled": ["Chills the foe", "chill the foe", "now and then it is too cold to move", "now and then too cold to move"],
	"muddled": ["Muddles the foe", "muddle the foe", "for a few turns it may hurt itself instead", "may hurt itself for a few turns"],
	"hexed": ["Hexes the foe", "hex the foe", "it loses 1/16 of its HP each turn", "loses 1/16 of its HP each turn"],
	"stung": ["Stings the foe", "sting the foe", "it loses 1/8 of its HP each turn", "loses 1/8 of its HP each turn"],
}

## One or two short sentences. A "desc" in the move data wins, for moves that need a hand-written line.
static func describe(mv: Dictionary) -> String:
	if str(mv.get("desc", "")) != "":
		return str(mv.desc)
	var parts: Array[String] = []
	var cat := str(mv.get("category", "status"))
	var fx: Dictionary = mv.get("effect", {"id": "none"})
	if cat != "status":
		parts.append("A %s hit." % cat)
	var chance := int(fx.get("chance", 100))
	match str(fx.get("id", "none")):
		"status":
			var st: Array = STATUS_TEXT.get(str(fx.status), ["Inflicts %s" % fx.status, "inflict %s" % fx.status, "", ""])
			if chance < 100:
				parts.append("%d%% chance to %s (%s)." % [chance, st[1], st[3]])
			else:
				parts.append("%s%s: %s." % ["Also " if cat != "status" else "", st[0] if cat == "status" else str(st[0]).to_lower(), st[2]])
		"stat":
			var stages := int(fx.get("stages", 0))
			var who := "the user's" if str(fx.get("target", "foe")) == "self" else "the foe's"
			var what := "%s %s by %s" % [who, STAT_NAMES.get(str(fx.stat), str(fx.stat)), "one stage" if absi(stages) == 1 else "%d stages" % absi(stages)]
			if chance < 100:
				parts.append("%d%% chance to %s %s." % [chance, "raise" if stages > 0 else "lower", what])
			else:
				parts.append("%s%s %s." % ["Also " if cat != "status" else "", ("Raises" if stages > 0 else "Lowers") if cat == "status" else ("raises" if stages > 0 else "lowers"), what])
	if int(mv.get("priority", 0)) > 0:
		parts.append("Usually strikes first.")
	if str(mv.get("target", "")) == "all_foes":
		parts.append("Hits both foes in a double battle, a bit weaker.")
	if parts.is_empty():
		parts.append("Does nothing much.")
	return " ".join(parts)

static func effectiveness_label(mult: float) -> String:
	if mult == 0.0:
		return "No effect"
	if mult > 1.0:
		return "Super effective"
	if mult < 1.0:
		return "Not very effective"
	return ""

## How a damaging move will land. foes: the standing foes, each {"name", "types", "known"}; only species the
## player has met before ("known") are judged. One foe (or the same answer for every known foe): just the label.
## Otherwise each known foe that isn't a plain hit is named. "" when there is nothing useful to say.
static func versus(mv: Dictionary, foes: Array, chart: TypeChart) -> String:
	if str(mv.get("category", "status")) == "status" or int(mv.get("power", 0)) <= 0:
		return ""
	var labels := []
	for f in foes:
		if bool(f.get("known", false)):
			labels.append([str(f.name), effectiveness_label(chart.effectiveness(str(mv.get("type", "")), f.types))])
	if labels.is_empty():
		return ""
	var same := labels.size() == foes.size() and labels.all(func(l): return l[1] == labels[0][1])
	if foes.size() == 1 or same:
		return labels[0][1]
	var bits := []
	for l in labels:
		if l[1] != "":
			bits.append("%s on %s" % [l[1] if bits.is_empty() else str(l[1]).to_lower(), l[0]])
	return ", ".join(bits)

## The odds of one snare holding, in words rather than numbers.
static func catch_band(chance: float) -> String:
	if chance < 0.2:
		return "Long shot"
	if chance < 0.5:
		return "Worth a try"
	return "Good odds"
