class_name VisitorsBook
extends RefCounted
## The Visitor's Book: the first time you walk into any room (an interior zone), flag seen_<zone id>.
## The map counts a town's rooms ("Rooms visited 12 of 18"), and the first time you've seen every room in a
## town, the local tourist board pays out once (flag tourist_board_<town>): some money and a cream tea.
## No autoload names here (the save data's tools load this); announce() reaches the UI through the overworld.

const SEEN_PREFIX := "seen_"
const BOARD_PREFIX := "tourist_board_"
const MONEY := 500
const FOOD := "cream_tea"

static func seen_flag(zone_id: String) -> String:
	return SEEN_PREFIX + zone_id

## Call on entering any zone. Marks a room seen; returns the tourist board's payout ({town, money, item})
## if that was the last room in its town, otherwise {}. The payout is already in the bag when it returns.
static func note(data: GameStateData, zone_id: String, kind: String, idx: Dictionary) -> Dictionary:
	if kind != "interior" or data.flag(seen_flag(zone_id)) == true:
		return {}
	data.set_flag(seen_flag(zone_id))
	var town := str(idx.get("room_town", {}).get(zone_id, ""))
	if town == "" or data.flag(BOARD_PREFIX + town) == true:
		return {}
	var c := count(data, town, idx)
	if c.x < c.y:
		return {}
	data.set_flag(BOARD_PREFIX + town)
	var paid := Wallet.earn_here(data, MONEY, town)  # an Irish tourist board pays in euros
	Bag.new(data.bag).add(FOOD, 1)
	return {"town": town, "money": int(paid.amount), "cur": str(paid.cur), "item": FOOD}

## Rooms seen and rooms in all, for a town: Vector2i(seen, total).
static func count(data: GameStateData, town: String, idx: Dictionary) -> Vector2i:
	var rooms: Array = idx.get("town_rooms", {}).get(town, [])
	var got := 0
	for r in rooms:
		if data.flag(seen_flag(str(r))) == true:
			got += 1
	return Vector2i(got, rooms.size())

## Every room you've ever walked into, anywhere.
static func rooms_seen(data: GameStateData) -> int:
	var n := 0
	for k in data.flags:
		if str(k).begins_with(SEEN_PREFIX) and data.flags[k] == true:
			n += 1
	return n

static func towns_complete(data: GameStateData) -> int:
	var n := 0
	for k in data.flags:
		if str(k).begins_with(BOARD_PREFIX) and data.flags[k] == true:
			n += 1
	return n

static func payout_lines(town_name: String, item_name: String, money: int, cur := Wallet.GBP) -> Array:
	return ["You've seen every room in %s. The tourist board would like a word, and a scone." % town_name,
		"The tourist board sends %s and a %s, with their compliments. Do tell your friends." % [Wallet.fmt(money, cur), item_name]]

## Shows the payout once the door's fade has finished (the overworld's say() is the dialogue box).
static func announce(ow: Node, tour: Dictionary, town_name: String, item_name: String) -> void:
	var router := ow.get_node_or_null("/root/Router")
	for _i in 600:  # up to ten seconds for the fade
		if router == null or not router.busy:
			break
		await ow.get_tree().process_frame
	if is_instance_valid(ow) and ow.is_inside_tree():
		await ow.say(payout_lines(town_name, item_name, int(tour.money), str(tour.get("cur", Wallet.GBP))))
