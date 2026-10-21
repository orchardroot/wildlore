class_name Guilds
extends RefCounted
## Six guilds, the measure of calling (Standing is the measure of belonging). Each has three ranks, earned by doing and
## read off counters that already exist (Gazetteer, TrainerStats, the Fieldbook, Deeds), and a small perk per rank while
## you are a member. Joining is free the first time. One real choice: the Ramblers and the Heritage Trust want opposite
## things of the moor, so while you belong to one the other's top rank is closed to you. Resigning costs a fee and the
## guild remembers (rejoining costs more). State is plain flags, so old saves simply have no guilds. Pure logic.

const IDS := ["ramblers", "anglers", "naturalists", "folk", "traders", "trust"]
const NAMES := {"ramblers": "The Ramblers", "anglers": "The Anglers", "naturalists": "The Naturalists",
	"folk": "The Folk Club", "traders": "The Traders' Guild", "trust": "The Heritage Trust"}
## What each guild counts, in a sentence, and the amounts that earn ranks 1 to 3.
const SOURCE := {
	"ramblers": {"unit": "plaques read", "at": [10, 30, 60]},
	"anglers": {"unit": "fish landed", "at": [8, 35, 100]},
	"naturalists": {"unit": "Fieldbook entries", "at": [15, 50, 110]},
	"folk": {"unit": "darts wins, crabs, rosettes and trials", "at": [3, 15, 40]},
	"traders": {"unit": "pounds of goods sold", "at": [300, 2500, 10000]},
	"trust": {"unit": "Deeds owned", "at": [1, 2, 3]},
}
const RANKS := {
	"ramblers": ["Day Tripper", "Footpath Warden", "Keeper of the Right of Way"],
	"anglers": ["Tackle Carrier", "Regular on the Bank", "Keeper of the Water"],
	"naturalists": ["Hedge Peerer", "Recorder", "Fellow of the Fieldbook"],
	"folk": ["Floor Singer", "Session Regular", "Resident Fiddler"],
	"traders": ["Stallholder", "Liveryman", "Master of the Exchange"],
	"trust": ["Friend of the Trust", "Trustee", "Chair of the Estate"],
}
const PERKS := {
	"ramblers": ["Lavender Sachets last a tenth longer.", "Sachets last a fifth longer.", "Sachets last three tenths longer."],
	"anglers": ["Two extra casts a day.", "Four extra casts a day.", "Six extra casts a day."],
	"naturalists": ["The weather brings out its favourites a little more.", "...a bit more again.", "...rather more."],
	"folk": ["A good turn in a nation earns an extra point of standing.", "...two extra points.", "...three extra points."],
	"traders": ["Carry ten more of each trade good without the pannier.", "Twenty more, and shopkeepers pay 2% extra.",
		"Thirty more, and shopkeepers pay 4% extra."],
	"trust": ["Rates on your Deeds are a tenth lower.", "A fifth lower.", "Three tenths lower."],
}
## The guilds that cannot both hold their top rank for you.
const RIVALS := {"ramblers": "trust", "trust": "ramblers"}
const RESIGN_FEE := 100
const REJOIN_FEE := 50
const MAX_RANK := 3
const HALLS := {"ramblers": "keswick_guesthouse", "anglers": "whitby_boat_hut", "naturalists": "aber_lab",
	"folk": "whitby_smugglers", "traders": "edinburgh_exchange", "trust": "bath_crescent"}

static func _member_key(id: String) -> String:
	return "guild_" + id

static func _left_key(id: String) -> String:
	return "guild_left_" + id

static func is_member(data: GameStateData, id: String) -> bool:
	return IDS.has(id) and data.flag(_member_key(id)) == true

## What the guild counts for you right now.
static func measure(data: GameStateData, id: String) -> int:
	match id:
		"ramblers":
			return Gazetteer.count(data)
		"naturalists":
			return FieldbookGoals.caught_count(data)
		"trust":
			return Deeds.owned(data).size()
		"folk":
			var n := 0
			for k in ["darts_won", "crabs_caught", "show_rosettes", "sheepdog_trials"]:
				n += TrainerStats.get_count(data, k)
			return n
		"anglers":
			return TrainerStats.get_count(data, "fish_caught")
		"traders":
			return TrainerStats.get_count(data, "goods_sold")
	return 0

## Rank earned by doing, 0 to 3, whether or not you belong.
static func earned(data: GameStateData, id: String) -> int:
	if not SOURCE.has(id):
		return 0
	var m := measure(data, id)
	var r := 0
	for need in SOURCE[id].at:
		if m >= int(need):
			r += 1
	return r

## The rival you currently belong to, or "".
static func blocked_by(data: GameStateData, id: String) -> String:
	var rival: String = RIVALS.get(id, "")
	return rival if rival != "" and is_member(data, rival) else ""

## The rank that counts: 0 if you have not joined, and a rival's membership holds the top rank back.
static func rank(data: GameStateData, id: String) -> int:
	if not is_member(data, id):
		return 0
	var r := earned(data, id)
	return mini(r, MAX_RANK - 1) if blocked_by(data, id) != "" else r

static func rank_title(data: GameStateData, id: String) -> String:
	var r := rank(data, id)
	return str(RANKS[id][r - 1]) if r > 0 else ""

static func to_next(data: GameStateData, id: String) -> int:
	var e := earned(data, id)
	return 0 if e >= MAX_RANK else maxi(0, int(SOURCE[id].at[e]) - measure(data, id))

static func perk_lines(data: GameStateData, id: String) -> Array:
	var out := []
	for i in rank(data, id):
		out.append(str(PERKS[id][i]))
	return out

## What it costs to join: nothing the first time, then more each time you have walked out.
static func join_fee(data: GameStateData, id: String) -> int:
	return REJOIN_FEE * mini(4, int(data.flag(_left_key(id)) if data.flag(_left_key(id)) != null else 0))

## Joins; returns "" on success or the reason you can't.
static func join(data: GameStateData, id: String) -> String:
	if not IDS.has(id):
		return "No such guild."
	if is_member(data, id):
		return "You already belong."
	var fee := join_fee(data, id)
	if data.money < fee:
		return "They remember you, and the fee is £%d." % fee
	data.money -= fee
	data.set_flag(_member_key(id), true)
	return ""

## Resigns for a fee; returns "" on success or the reason you can't. The guild remembers.
static func resign(data: GameStateData, id: String) -> String:
	if not is_member(data, id):
		return "You don't belong."
	if data.money < RESIGN_FEE:
		return "Resigning costs £%d, and you haven't got it." % RESIGN_FEE
	data.money -= RESIGN_FEE
	data.set_flag(_member_key(id), false)
	var n := int(data.flag(_left_key(id)) if data.flag(_left_key(id)) != null else 0)
	data.set_flag(_left_key(id), n + 1)
	return ""

# --- perks, each a one-line hook in the system it touches ---

static func cast_bonus(data: GameStateData) -> int:
	return 2 * rank(data, "anglers")

static func repel_bonus(data: GameStateData, base: int) -> int:
	return base * rank(data, "ramblers") / 10

static func sky_bonus(data: GameStateData) -> float:
	return 0.05 * rank(data, "naturalists")

static func standing_bonus(data: GameStateData, n: int) -> int:
	return rank(data, "folk") if n >= 2 else 0

static func carry_bonus(data: GameStateData) -> int:
	return 10 * rank(data, "traders")

static func sell_bonus(data: GameStateData) -> float:
	return 0.02 * maxi(0, rank(data, "traders") - 1)

static func rates_mult(data: GameStateData) -> float:
	return 1.0 - 0.1 * rank(data, "trust")
