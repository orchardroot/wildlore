class_name Blackjack
extends RefCounted
## Blackjack at the Palace: a fresh six-deck shoe every hand, the dealer stands on all 17s, blackjack pays 3:2,
## double down on any first two cards, no splitting and no insurance (house rules, on the card by the table).
## The dealer checks for blackjack straight after the deal. The whole shoe is shuffled when the hand is dealt,
## so the cards are fixed at the moment the bet goes down. Pure logic.
##
## Cards are {rank: 1..13 (ace..king), suit: 0..3}.

const DECKS := 6
const SUITS := ["spades", "hearts", "diamonds", "clubs"]

var stake := 0
var player: Array = []
var dealer: Array = []
var done := false
var doubled := false
var result := ""     # blackjack | win | push | lose | bust | dealer_blackjack
var _shoe: Array = []

## Deals a hand for `stake` from a shoe shuffled by `rng`.
func _init(rng: Rng = null, stake_in := 0) -> void:
	stake = stake_in
	if rng == null:
		return
	_shoe = shoe(rng)
	player = [_draw(), _draw()]
	dealer = [_draw(), _draw()]
	_check_naturals()

## A hand with known cards (tests): the shoe then deals `rest` in order.
static func rigged(stake_in: int, p: Array, d: Array, rest: Array) -> Blackjack:
	var g := Blackjack.new(null, stake_in)
	g.player = p.duplicate()
	g.dealer = d.duplicate()
	g._shoe = rest.duplicate()
	g._shoe.reverse()  # _draw pops from the back
	g._check_naturals()
	return g

static func shoe(rng: Rng) -> Array:
	var out := []
	for d in DECKS:
		for s in 4:
			for r in range(1, 14):
				out.append({"rank": r, "suit": s})
	for i in range(out.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = out[i]
		out[i] = out[j]
		out[j] = t
	return out

func _draw() -> Dictionary:
	if _shoe.is_empty():
		return {"rank": 10, "suit": 0}
	return _shoe.pop_back()

static func card_points(c: Dictionary) -> int:
	return mini(10, int(c.rank))

## {total, soft}: soft when an ace is counting 11.
static func value(cards: Array) -> Dictionary:
	var total := 0
	var aces := 0
	for c in cards:
		total += card_points(c)
		if int(c.rank) == 1:
			aces += 1
	var soft := false
	if aces > 0 and total + 10 <= 21:
		total += 10
		soft = true
	return {"total": total, "soft": soft}

static func is_blackjack(cards: Array) -> bool:
	return cards.size() == 2 and int(value(cards).total) == 21

## The dealer draws to 16 and stands on every 17, soft ones included.
static func dealer_hits(cards: Array) -> bool:
	return int(value(cards).total) < 17

func _check_naturals() -> void:
	var p := is_blackjack(player)
	var d := is_blackjack(dealer)
	if p or d:
		done = true
		result = "push" if p and d else ("blackjack" if p else "dealer_blackjack")

func can_double() -> bool:
	return not done and player.size() == 2 and not doubled

func hit() -> void:
	if done:
		return
	player.append(_draw())
	var t := int(value(player).total)
	if t > 21:
		done = true
		result = "bust"
	elif t == 21:
		stand()  # nobody sensible hits 21; save them the button press

## Doubles the stake (the caller has already taken the second stake), one card, then the dealer plays.
func double_down() -> void:
	if not can_double():
		return
	doubled = true
	stake *= 2
	player.append(_draw())
	if int(value(player).total) > 21:
		done = true
		result = "bust"
	else:
		stand()

func stand() -> void:
	if done:
		return
	while dealer_hits(dealer):
		dealer.append(_draw())
	var p := int(value(player).total)
	var d := int(value(dealer).total)
	done = true
	if d > 21 or p > d:
		result = "win"
	elif p == d:
		result = "push"
	else:
		result = "lose"

## What goes back across the felt: stake plus winnings (3:2 for a blackjack, rounded down).
func returns() -> int:
	match result:
		"blackjack":
			return stake + stake * 3 / 2
		"win":
			return stake * 2
		"push":
			return stake
	return 0

## The dealer's face-up card (the first).
func upcard() -> Dictionary:
	return dealer[0] if not dealer.is_empty() else {}

## Basic strategy for these rules (no splits): what the house assumes a sharp player does. "hit", "stand" or
## "double". Used by the simulations and the dealer's tip.
static func basic_strategy(g: Blackjack) -> String:
	var v := value(g.player)
	var t := int(v.total)
	var up := card_points(g.upcard())
	if up == 1:
		up = 11
	var two := g.player.size() == 2
	if v.soft:
		if t >= 19:
			return "stand"
		if t == 18:
			if two and up >= 3 and up <= 6:
				return "double"
			return "stand" if up <= 8 else "hit"
		if two and ((t == 17 and up >= 3 and up <= 6) or (t >= 15 and up >= 4 and up <= 6) or (t >= 13 and up >= 5 and up <= 6)):
			return "double"
		return "hit"
	if t >= 17:
		return "stand"
	if t >= 13:
		return "stand" if up <= 6 else "hit"
	if t == 12:
		return "stand" if up >= 4 and up <= 6 else "hit"
	if t == 11:
		return "double" if two else "hit"
	if t == 10:
		return "double" if two and up <= 9 else "hit"
	if t == 9:
		return "double" if two and up >= 3 and up <= 6 else "hit"
	return "hit"
