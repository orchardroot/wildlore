class_name Bag
extends RefCounted
## The player's items. Wraps an item_id -> count dictionary (the one saved in game state) so changes stick.

var store: Dictionary

func _init(items: Dictionary) -> void:
	store = items

func count(id: String) -> int:
	return int(store.get(id, 0))

const MAX_STACK := 99

## Adds up to n, never past MAX_STACK. Returns how many were actually added.
func add(id: String, n := 1) -> int:
	var room := maxi(0, MAX_STACK - count(id))
	var added := clampi(n, 0, room)
	if added > 0:
		store[id] = count(id) + added
	return added

func remove(id: String, n := 1) -> bool:
	if n < 1 or count(id) < n:
		return false
	var left := count(id) - n
	if left > 0:
		store[id] = left
	else:
		store.erase(id)
	return true

func items_of_kind(kind: String, item_db: ItemDB) -> Array:
	var out := []
	for id in store:
		if count(id) > 0 and item_db.get_item(id).get("kind", "") == kind:
			out.append(id)
	return out

func use_on(id: String, c: Creature, item_db: ItemDB) -> Dictionary:
	var item := item_db.get_item(id)
	if item.is_empty() or count(id) < 1:
		return {"ok": false, "text": "You don't have any."}
	var r := ItemEffects.apply(item, c)
	if r.ok:
		remove(id)
	return r
