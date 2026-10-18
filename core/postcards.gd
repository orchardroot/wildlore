class_name Postcards
extends RefCounted
## Kit's postcards (data/postcards.json): after each Stone and a few story beats Kit sends a card. Once its beat
## is done a card waits in the post, any `post_box` prop shows a little envelope, and facing one collects
## everything waiting. The flag postcard_<id> holds the real date it was collected (for the postmark).
## The first card brings the Postcard Album, a key item that opens the collection. Pure logic, no autoloads.
## Card: {id, after (flag), place, zone and view (the picture: a focus tile, see ui/postcard_screen.gd),
## stamp (a species), text (paragraphs), ps (optional), hint (optional: what it points you at)}.

const PATH := "res://data/postcards.json"
const ALBUM := "postcard_album"
const PREFIX := "postcard_"
const BOX := "post_box"
const MONTHS := ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

static var _cards: Array = []

static func cards() -> Array:
	if _cards.is_empty():
		var d = JsonUtil.read(PATH)
		_cards = d.get("cards", []) if d is Dictionary else []
	return _cards

static func card(id: String, list: Array = []) -> Dictionary:
	for c in (list if not list.is_empty() else cards()):
		if str(c.get("id", "")) == id:
			return c
	return {}

## Where a card comes in the whole set (0-based), or -1.
static func card_index(id: String, list: Array = []) -> int:
	var l := list if not list.is_empty() else cards()
	for i in l.size():
		if str(l[i].get("id", "")) == id:
			return i
	return -1

static func flag_key(id: String) -> String:
	return PREFIX + id

static func is_collected(data: GameStateData, id: String) -> bool:
	return data.flag(flag_key(id)) != null

## Ids of the cards in the post: their beat done, not yet collected. Story order.
static func waiting(data: GameStateData, list: Array = []) -> Array:
	var out := []
	for c in (list if not list.is_empty() else cards()):
		if _truthy(data.flag(str(c.get("after", "")))) and not is_collected(data, str(c.id)):
			out.append(str(c.id))
	return out

## Takes everything waiting out of the post, stamped with `date` ("YYYY-MM-DD", Calendar.today_key()).
## The first card ever brings the album. Returns the ids collected, story order.
static func collect(data: GameStateData, list: Array = [], date := "") -> Array:
	var got := waiting(data, list)
	for id in got:
		data.set_flag(flag_key(id), date if date != "" else "-")
	if not got.is_empty() and int(data.bag.get(ALBUM, 0)) <= 0:
		data.bag[ALBUM] = 1
	return got

## Ids of the cards in the album, story order.
static func collected(data: GameStateData, list: Array = []) -> Array:
	var out := []
	for c in (list if not list.is_empty() else cards()):
		if is_collected(data, str(c.id)):
			out.append(str(c.id))
	return out

static func post_boxes(z: ZoneData) -> Array:
	var out := []
	for pr in z.props:
		if str(pr.get("type", "")) == BOX:
			out.append(Vector2i(int(pr.get("x", 0)), int(pr.get("y", 0))))
	return out

static func is_post_box(z: ZoneData, p: Vector2i) -> bool:
	return p in post_boxes(z)

## "2026-10-18" -> "18 OCT 2026", for the postmark ring.
static func postmark_date(key: String) -> String:
	var parts := key.split("-")
	if parts.size() != 3 or not parts[1].is_valid_int():
		return ""
	var m := clampi(int(parts[1]), 1, 12)
	return "%d %s %s" % [int(parts[2]), MONTHS[m - 1], parts[0]]

static func _truthy(v: Variant) -> bool:
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return true
