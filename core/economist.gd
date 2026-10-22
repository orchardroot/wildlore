class_name Economist
extends RefCounted
## The Economist's notebook (4.5): a page of the Almanac that fills as you meet each idea in play. An idea is met
## once, in the flag econ_<id> (true, or a little detail of how you met it: {"text": ..., and numbers}); a history
## entry is met by reading its Gazetteer plaque. Ideas come from data/economist.json; the worked examples are worked
## here from the game's own numbers (the Trade Ledger's glut, Pat's rates, the casino's prices), so they are never
## out of date. The systems that teach an idea call note(); a screen shows take_fresh() in its hint bar.
## Pure logic, no autoload names: the Trade Ledger, the Deeds and the validator all load it.

const PATH := "res://data/economist.json"
const PREFIX := "econ_"
## Measured, not assumed: basic strategy at the Palace's blackjack over many hands (pinned by test_economist.gd).
const BLACKJACK_RTP := 0.99
## FruitMachine.exact_rtp_with_nudges(), which takes most of a second to work out; pinned by test_economist.gd.
const FRUIT_RTP := 0.847

static var _cache: Dictionary = {}
static var _fresh: Array = []

static func db() -> Dictionary:
	if _cache.is_empty():
		var d = JsonUtil.read(PATH)
		_cache = d if d is Dictionary else {"ideas": []}
	return _cache

static func ideas() -> Array:
	return db().get("ideas", [])

static func idea(id: String) -> Dictionary:
	for i in ideas():
		if str(i.id) == id:
			return i
	return {}

static func total() -> int:
	return ideas().size()

static func flag_key(id: String) -> String:
	return PREFIX + id

static func met(d: GameStateData, id: String) -> bool:
	var i := idea(id)
	if i.is_empty():
		return false
	if str(i.get("plaque", "")) != "":
		return Gazetteer.is_read(d, str(i.plaque))
	var v: Variant = d.flag(flag_key(id))
	return v != null and not (v is bool and not v)

static func count(d: GameStateData) -> int:
	return ideas().filter(func(i): return met(d, str(i.id))).size()

## Notes an idea as met. `detail` is kept (a String, or a Dictionary with "text") for the "yours" line. True if new.
static func note(d: GameStateData, id: String, detail: Variant = true) -> bool:
	var i := idea(id)
	if i.is_empty() or met(d, id):
		return false
	d.set_flag(flag_key(id), detail if detail != null else true)
	_fresh.append(str(i.title))
	if _fresh.size() > 3:
		_fresh.pop_front()
	return true

## The hint-bar line for anything noted since the last call ("" if nothing), then forgets it.
static func take_fresh() -> String:
	if _fresh.is_empty():
		return ""
	var t := "New in your Economist's notebook: %s." % ", ".join(_fresh)
	_fresh.clear()
	return t

## Everything the page says about an idea: its lines, how you met it, and the worked examples.
static func lines(d: GameStateData, id: String) -> Array:
	var i := idea(id)
	if i.is_empty():
		return []
	var out: Array = i.get("lines", []).duplicate()
	var v: Variant = d.flag(flag_key(id))
	var text := str(v.get("text", "")) if v is Dictionary else (str(v) if v is String else "")
	if text != "" and str(i.get("yours", "")) != "":
		out.append(str(i.yours) % text)
	out.append_array(examples(d, id))
	return out

static func _money(v: float) -> String:
	return Wallet.fmt(roundi(v))

## Worked examples from the game's real numbers.
static func examples(d: GameStateData, id: String) -> Array:
	var out := []
	var v: Variant = d.flag(flag_key(id))
	match id:
		"supply_demand":
			var step := float(Trade.config().get("glut_step", 0.92))
			out.append("Here each one you sell in a town knocks about %d%% off the next, and the glut fades over %d days." % [roundi((1.0 - step) * 100.0), int(Trade.config().get("glut_days", 3))])
			out.append("Sell ten at once and the tenth fetches %d%% of what the first did." % roundi(pow(step, 9) * 100.0))
		"opportunity_cost":
			if v is Dictionary and int(v.get("gbp", 0)) > 0:
				var put := mini(int(v.gbp), BuildingSociety.save_cap(d, Wallet.GBP))
				var yearly := put * (pow(1.0 + BuildingSociety.save_rate(Wallet.GBP), 12.0) - 1.0)
				out.append("Left in savings instead, %s of it would earn about %s a year at Pat's rate." % [_money(put), _money(yearly)])
		"compound":
			var r := BuildingSociety.loan_rate(Wallet.GBP)
			out.append("A £1,000 debt at Pat's %.0f%% a month, never paid: simple interest makes it %s after a year, compound %s." % [r * 100.0, _money(1000.0 * (1.0 + 12.0 * r)), _money(1000.0 * pow(1.0 + r, 12.0))])
			out.append("After ten years: %s simple, %s compound." % [_money(1000.0 * (1.0 + 120.0 * r)), _money(1000.0 * pow(1.0 + r, 120.0))])
			var s := BuildingSociety.save_rate(Wallet.GBP)
			out.append("Pat's savings pay %.1f%% a month, so £1,000 left alone for ten years grows to %s." % [s * 100.0, _money(1000.0 * pow(1.0 + s, 120.0))])
		"apr":
			var r := BuildingSociety.loan_rate(Wallet.GBP)
			out.append("Pat lends at %.2f%% a month. Twelve times that is %.0f%%, but with interest on interest it is %.1f%% APR." % [r * 100.0, r * 1200.0, BuildingSociety.apr(r) * 100.0])
			var e := BuildingSociety.loan_rate(Wallet.EUR)
			out.append("The Dublin credit union: %.2f%% a month, %.1f%% APR." % [e * 100.0, BuildingSociety.apr(e) * 100.0])
		"inflation":
			out.append("At 2%% a year, a £5.00 pint costs %s in ten years. Prices double in about %d years." % [Wallet.fmt_price(5.0 * pow(1.02, 10.0)), roundi(log(2.0) / log(1.02))])
			out.append("At 10%% a year, they double in about %d." % roundi(log(2.0) / log(1.10)))
		"winners_curse":
			if v is Dictionary and v.has("over"):
				out.append("You paid %d%% over the reserve." % int(v.over))
		"house_edge":
			var pockets := Roulette.WHEEL.size()
			out.append("Roulette: %d pockets, but a single number pays %d to 1. On average %.1fp comes back per £1." % [pockets, pockets - 2, 100.0 * (pockets - 1) / pockets])
			out.append("Blackjack, played by the book: about %dp back per £1." % roundi(BLACKJACK_RTP * 100.0))
			var keep := 1.0 - HigherLower.EDGE
			out.append("Higher or Lower: each call pays %dp in the pound of a fair price, so three calls in a row keep at most %.1fp." % [roundi(keep * 100.0), pow(keep, 3.0) * 100.0])
			out.append("The fruit machine, every nudge played perfectly: about %dp back per £1." % roundi(FRUIT_RTP * 100.0))
			out.append("The races: add up the chances a card's prices imply and they come to more than 100%. The extra is the bookie's.")
	return out

## The hint-bar line each casino screen opens with: the real odds, plainly.
static func odds_line(screen: String) -> String:
	match screen:
		"roulette_screen":
			return "Real odds: a number pays %d to 1, but there are %d pockets. On average %.1fp back per £1." % [Roulette.WHEEL.size() - 2, Roulette.WHEEL.size(), 100.0 * (Roulette.WHEEL.size() - 1) / Roulette.WHEEL.size()]
		"blackjack_screen":
			return "Real odds: played perfectly by the book, about %dp back per £1 staked." % roundi(BLACKJACK_RTP * 100.0)
		"hilo_screen":
			return "Real odds: every call pays %d%% under the fair price, and it compounds. Three calls keep %.1fp in the pound." % [roundi(HigherLower.EDGE * 100.0), pow(1.0 - HigherLower.EDGE, 3.0) * 100.0]
		"fruit_screen":
			return "Real odds: about %dp back per £1, and that is with every nudge played perfectly." % roundi(FRUIT_RTP * 100.0)
		"race_screen":
			return "Real odds: the chances on a card add up to more than 100%. The extra is the bookie's."
	return ""

## Data problems: unique ids, a title and lines each, history plaques that exist, no em-dashes.
static func check(plaques: Array) -> Array:
	var errs := []
	var seen := {}
	var have := {}
	for p in plaques:
		have[str(p.id)] = true
	for i in ideas():
		var id := str(i.get("id", ""))
		if id == "" or seen.has(id):
			errs.append("economist: idea id '%s' missing or repeated" % id)
		seen[id] = true
		if str(i.get("title", "")) == "" or i.get("lines", []).is_empty():
			errs.append("economist: idea '%s' needs a title and lines" % id)
		if str(i.get("kind", "")) == "history" and not have.has(str(i.get("plaque", ""))):
			errs.append("economist: idea '%s' names plaque '%s', which no zone has" % [id, i.get("plaque", "")])
		if JSON.stringify(i).contains("—"):
			errs.append("economist: idea '%s' has an em-dash" % id)
	return errs
