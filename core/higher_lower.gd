class_name HigherLower
extends RefCounted
## Higher or Lower, the Palace's quick game. A card is turned; call the next one higher or lower and your pot is
## multiplied by the price on that call; keep going or cash out. A tie loses. Aces are high (ranks 2..14).
## Cards come from an eight-deck shoe, near enough each rank equally likely every time, so the prices are honest:
## each one is the fair price less EDGE, rounded down to the penny. Every card of the run is dealt when the
## stake goes down. Pure logic.

const EDGE := 0.04
const MAX_STEPS := 10
const NAMES := {11: "Jack", 12: "Queen", 13: "King", 14: "Ace"}

var stake := 0
var pot := 0.0      # kept in fractions of a pound; paid out rounded down
var steps := 0       # right calls so far
var done := false
var lost := false
var _cards: Array = []   # ranks (and suits) dealt in advance
var _i := 0

func _init(rng: Rng = null, stake_in := 0) -> void:
	stake = stake_in
	pot = float(stake_in)
	if rng == null:
		return
	for k in MAX_STEPS + 1:
		_cards.append({"rank": rng.roll_int(2, 14), "suit": rng.roll_int(0, 3)})

static func rigged(stake_in: int, ranks: Array) -> HigherLower:
	var g := HigherLower.new(null, stake_in)
	for r in ranks:
		g._cards.append({"rank": int(r), "suit": 0})
	return g

static func rank_name(r: int) -> String:
	return NAMES.get(r, str(r))

## The chance the next card is strictly higher (or lower) than `rank`.
static func chance(guess: String, rank: int) -> float:
	var n := (14 - rank) if guess == "higher" else (rank - 2)
	return maxf(0.0, float(n) / 13.0)

## The price on a call: fair less the edge, rounded down to 0.05. 0 when the call can't win.
static func multiplier(guess: String, rank: int) -> float:
	var p := chance(guess, rank)
	if p <= 0.0:
		return 0.0
	return floor((1.0 - EDGE) / p * 100.0 + 0.0001) / 100.0

func card() -> Dictionary:
	return _cards[_i] if _i < _cards.size() else {}

## The card after the current one (shown once a call is made).
func next_card() -> Dictionary:
	return _cards[_i + 1] if _i + 1 < _cards.size() else {}

## Makes a call. True if it was right; the pot grows and the next card is up.
func guess(g: String) -> bool:
	if done or _i + 1 >= _cards.size():
		return false
	var now := int(card().rank)
	var nxt := int(next_card().rank)
	var right := (nxt > now) if g == "higher" else (nxt < now)
	var mult := multiplier(g, now)
	_i += 1
	if not right or mult <= 0.0:
		done = true
		lost = true
		pot = 0.0
		return false
	pot = pot * mult
	steps += 1
	if steps >= MAX_STEPS or _i + 1 >= _cards.size():
		done = true  # the run's end: the pot is banked
	return true

## Takes the pot (or the stake back if no call was made yet). Returns what's paid.
func cash_out() -> int:
	if not lost:
		done = true
	return returns()

func returns() -> int:
	if lost:
		return 0
	return int(floor(pot + 0.0001)) if steps > 0 else stake
