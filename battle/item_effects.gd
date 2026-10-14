class_name ItemEffects
extends RefCounted
## What an item does to one creature. Shared by Bag (overworld) and Battle (item action).
## Pure effect: it never touches a bag. Returns {"ok": bool, "text": String}; on failure the creature is unchanged.

static func apply(item: Dictionary, c: Creature) -> Dictionary:
	var name := c.display_name()
	match str(item.get("kind", "")):
		"heal":
			if c.is_fainted():
				return _no("%s is in no state for tea." % name)
			if c.hp >= c.max_hp():
				return _no("%s is already in tip-top shape." % name)
			var n := c.heal(int(item.get("amount", 0)))
			return _yes("%s recovered %d HP." % [name, n])
		"cure":
			if c.is_fainted() or c.status == "" or c.status not in item.get("cures", []):
				return _no("It would have no effect on %s." % name)
			var old := c.status
			c.status = ""
			c.status_turns = 0
			return _yes("%s is no longer %s." % [name, old])
		"revive":
			if not c.is_fainted():
				return _no("%s is perfectly conscious, thanks." % name)
			c.status = ""
			c.status_turns = 0
			c.hp = maxi(1, c.max_hp() * int(item.get("amount", 50)) / 100)
			return _yes("%s is back on their feet." % name)
		"pp":
			if c.is_fainted():
				return _no("%s is in no state for pudding." % name)
			var changed := false
			for m in c.moves:
				var restored := mini(int(item.get("amount", 0)), int(m.max_pp) - int(m.pp))
				if restored > 0:
					m.pp = int(m.pp) + restored
					changed = true
			if not changed:
				return _no("%s's moves are already full." % name)
			return _yes("%s's moves got their pep back." % name)
	return _no("You can't use that now.")

static func _yes(text: String) -> Dictionary:
	return {"ok": true, "text": text}

static func _no(text: String) -> Dictionary:
	return {"ok": false, "text": text}
