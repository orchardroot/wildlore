class_name Punt
extends RefCounted
## House rules shared by the Palace casino and the bookies: chips, the daily stake limit, the stream of luck, the
## tallies and the big-win rewards. Everything lives in save flags (punt_*), so old saves start with no chips, a
## fresh limit and a clean slate. Money only moves through Purse. Pure logic: the screens call Game.autosave()
## once a bet is settled.
##
## Save safety: every result (a spin, a hand, a race) is rolled from rng(), which is seeded from the save itself
## (punt_seed) plus a counter (punt_n) that moves on with every bet. The stake comes off and the result is fixed
## the moment a bet goes down; the screen saves as soon as it's settled. Reload a save from before the bet and the
## same bet gets the very same result, so there is nothing to gain from it.

const SEED_FLAG := "punt_seed"
const COUNT_FLAG := "punt_n"
const CHIPS_FLAG := "punt_chips"
const DAY_FLAG := "punt_day"
const STAKED_FLAG := "punt_staked"
const CHARM_FLAG := "punt_charm"
const TROPHY_FLAG := "punt_trophy"

## The daily stake limit: a modest float for a beginner, more as the Stones (badges) come in.
const LIMIT_BASE := 300
const LIMIT_PER_BADGE := 450
## A single win this big (profit) earns the charm, once; this big earns the novelty cheque for Mum's shelf.
const BIG_WIN := 500
const TROPHY_WIN := 2500
const CHARM := "lucky_chip"

# ---------------------------------------------------------------- the stream of luck

## A fresh Rng for one bet at `game`, dealt from the save's stream. Moves the stream on.
static func rng(data: GameStateData, game: String) -> Rng:
	var s: Variant = data.flag(SEED_FLAG)
	if not (s is int):
		s = posmod(hash("%d:%s" % [data.rng_seed, data.player_name]), 2147483647)
		data.set_flag(SEED_FLAG, s)
	var n := int(data.flag(COUNT_FLAG)) if data.flag(COUNT_FLAG) is int else 0
	data.set_flag(COUNT_FLAG, n + 1)
	return Rng.new(posmod(hash("%d/%d/%s" % [int(s), n, game]), 2147483647))

# ---------------------------------------------------------------- chips

static func chips(data: GameStateData) -> int:
	var c: Variant = data.flag(CHIPS_FLAG)
	return int(c) if (c is int or c is float) else 0

static func _set_chips(data: GameStateData, n: int) -> void:
	data.set_flag(CHIPS_FLAG, maxi(0, n))

## Buys `amount` of chips at the cage. False if the purse can't stand it.
static func buy_chips(data: GameStateData, amount: int) -> bool:
	if amount <= 0 or not Purse.take(data, amount):
		return false
	_set_chips(data, chips(data) + amount)
	return true

## Cashes every chip back into the purse. Returns how much.
static func cash_chips(data: GameStateData) -> int:
	var n := chips(data)
	_set_chips(data, 0)
	Purse.pay(data, n)
	return n

# ---------------------------------------------------------------- the daily limit

static func limit(data: GameStateData) -> int:
	return LIMIT_BASE + LIMIT_PER_BADGE * data.badges.size()

## Staked so far today (the real date, like the pub quiz, so the 24-minute game day can't be farmed).
static func staked_today(data: GameStateData) -> int:
	if str(data.flag(DAY_FLAG)) != Calendar.today_key():
		return 0
	var v: Variant = data.flag(STAKED_FLAG)
	return int(v) if (v is int or v is float) else 0

static func left_today(data: GameStateData) -> int:
	return maxi(0, limit(data) - staked_today(data))

## Whether `amount` could go down now: inside today's limit and covered by chips (or the purse).
static func can_stake(data: GameStateData, amount: int, with_chips: bool) -> bool:
	if amount <= 0 or amount > left_today(data):
		return false
	return amount <= chips(data) if with_chips else Purse.can_afford(data, amount)

## Puts a stake down: takes it from the chips or the purse and counts it against today's limit and the tallies.
## False (and nothing taken) if it isn't allowed.
static func stake(data: GameStateData, amount: int, with_chips: bool) -> bool:
	if not can_stake(data, amount, with_chips):
		return false
	if with_chips:
		_set_chips(data, chips(data) - amount)
	elif not Purse.take(data, amount):
		return false
	var today := staked_today(data) + amount
	data.set_flag(DAY_FLAG, Calendar.today_key())
	data.set_flag(STAKED_FLAG, today)
	_add(data, "wagered", amount)
	_add(data, "bets", 1)
	return true

# ---------------------------------------------------------------- settling

## Pays out a settled bet (`staked` was already taken by stake()). Returns {net, lines}: `lines` are any rewards
## to announce (the charm, the cheque).
static func settle(data: GameStateData, staked: int, returned: int, with_chips: bool) -> Dictionary:
	if returned > 0:
		if with_chips:
			_set_chips(data, chips(data) + returned)
		else:
			Purse.pay(data, returned)
		_add(data, "returned", returned)
	var net := returned - staked
	var lines := []
	if net > count(data, "biggest"):
		data.set_flag("punt_biggest", net)
	if net >= BIG_WIN and data.flag(CHARM_FLAG) != true:
		data.set_flag(CHARM_FLAG, true)
		Bag.new(data.bag).add(CHARM, 1)
		lines.append("The pit boss presses something into your hand: a Lucky Chip, for luck that's clearly working.")
	if net >= TROPHY_WIN and not has_trophy(data):
		data.set_flag(TROPHY_FLAG, true)
		lines.append("And a giant novelty cheque, for the photo. It won't fit on the ferry, so they'll post it to your mum's.")
	return {"net": net, "lines": lines}

static func has_trophy(data: GameStateData) -> bool:
	return data.flag(TROPHY_FLAG) == true

# ---------------------------------------------------------------- tallies

## punt_wagered, punt_returned, punt_biggest, punt_bets, punt_novice_wins.
static func count(data: GameStateData, key: String) -> int:
	var v: Variant = data.flag("punt_" + key)
	return int(v) if (v is int or v is float) else 0

static func _add(data: GameStateData, key: String, n: int) -> void:
	data.set_flag("punt_" + key, count(data, key) + n)

static func note_novice_win(data: GameStateData) -> void:
	_add(data, "novice_wins", 1)

## Rows for the Stats page (none until the first bet).
static func stat_lines(data: GameStateData) -> Array:
	if count(data, "bets") <= 0 and count(data, "novice_wins") <= 0:
		return []
	var out := [
		["Total wagered", Purse.text(count(data, "wagered"))],
		["Biggest win", Purse.text(count(data, "biggest")) if count(data, "biggest") > 0 else "Still waiting"],
		["Up or down on the night", _up_down(count(data, "returned") - count(data, "wagered"))],
	]
	if count(data, "novice_wins") > 0:
		out.append(["Novice races won", str(count(data, "novice_wins"))])
	return out

static func _up_down(n: int) -> String:
	if n == 0:
		return "Level, somehow"
	return ("Up " if n > 0 else "Down ") + Purse.text(absi(n))
