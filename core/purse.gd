class_name Purse
extends RefCounted
## The one door every casino and bookies' pound goes in and out of. The Palace, Aintree and the betting shops
## never touch GameStateData.money directly: they ask the Purse, so a currency-aware wallet (euros in the
## Republic) can take over here without the games noticing. All the venues are in sterling areas.
## Pure logic.

const CURRENCY := "GBP"

## What the player has to spend, in pounds.
static func balance(data: GameStateData) -> int:
	return data.money

static func can_afford(data: GameStateData, amount: int) -> bool:
	return amount >= 0 and data.money >= amount

## Takes `amount` if it's there. False (and nothing taken) if not.
static func take(data: GameStateData, amount: int) -> bool:
	if amount < 0 or not can_afford(data, amount):
		return false
	data.money -= amount
	return true

## Pays `amount` in (winnings, cashed chips, prize money).
static func pay(data: GameStateData, amount: int) -> void:
	if amount > 0:
		data.money += amount

## "£1,250": how the venues write money.
static func text(amount: int) -> String:
	var s := str(absi(amount))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if amount < 0 else "") + "£" + s + out
