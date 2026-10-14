class_name StoryValidator
extends RefCounted
## Checks dialogue scripts, trainers and the NPCs that use them against the rest of the data.

const COMMANDS := ["say", "choice", "if", "set", "give_item", "give_creature", "heal", "battle", "move", "face",
	"face_player", "wait", "warp", "shop", "starter", "fade_out", "fade_in", "music", "sfx", "badge", "end", "whiteout", "ark", "rail", "ferry", "legend"]
const MOVE_MODES := ["still", "wander", "pace"]
const DIRS := ["up", "down", "left", "right"]

static func validate(dex: Dex, moves: MoveDB, items: ItemDB, zones: Dictionary) -> Array:
	var errors := []
	var dialogue := StoryData.all_dialogue()
	for file in dialogue:
		for sid in dialogue[file]:
			var cmds = dialogue[file][sid]
			if not cmds is Array:
				errors.append("dialogue %s/%s: script is not a list" % [file, sid])
				continue
			errors.append_array(validate_commands(cmds, "dialogue %s/%s" % [file, sid], dex, items, zones))
	for tid in StoryData.trainer_ids():
		errors.append_array(_validate_trainer(tid, dex, moves, items, zones))
	for zid in zones:
		var z: ZoneData = zones[zid]
		var seen_ids := {}
		for n in z.npcs:
			var tag := "zone %s npc '%s': " % [zid, n.get("id", "?")]
			var nid := str(n.get("id", ""))
			if nid == "" or seen_ids.has(nid):
				errors.append(tag + "id is missing or duplicated")
			seen_ids[nid] = true
			if str(n.get("move", "still")) not in MOVE_MODES:
				errors.append(tag + "unknown move mode '%s'" % n.get("move"))
			if str(n.get("facing", "down")) not in DIRS:
				errors.append(tag + "unknown facing")
			var sc := str(n.get("script", ""))
			if sc != "" and StoryData.script(zid, sc).is_empty():
				errors.append(tag + "script '%s' does not exist for this zone" % sc)
			var tr := str(n.get("trainer", ""))
			if tr != "" and not StoryData.trainer_exists(tr):
				errors.append(tag + "trainer '%s' does not exist" % tr)
	return errors

static func validate_commands(cmds: Array, tag: String, dex: Dex, items: ItemDB, zones: Dictionary) -> Array:
	var errors := []
	for c in cmds:
		if not c is Dictionary:
			errors.append("%s: command is not an object" % tag)
			continue
		var op := str(c.get("do", ""))
		if op not in COMMANDS:
			errors.append("%s: unknown command '%s'" % [tag, op])
			continue
		match op:
			"say":
				if str(c.get("text", "")) == "":
					errors.append("%s: say with no text" % tag)
			"choice":
				if c.get("options", []).size() < 2:
					errors.append("%s: choice needs at least two options" % tag)
			"if":
				if str(c.get("flag", "")) == "":
					errors.append("%s: if with no flag" % tag)
				errors.append_array(validate_commands(c.get("then", []), tag, dex, items, zones))
				errors.append_array(validate_commands(c.get("else", []), tag, dex, items, zones))
			"set":
				if str(c.get("flag", "")) == "":
					errors.append("%s: set with no flag" % tag)
			"give_item":
				if not items.has(str(c.get("item", ""))):
					errors.append("%s: give_item '%s' does not exist" % [tag, c.get("item", "")])
			"give_creature":
				if not dex.has(str(c.get("species", ""))):
					errors.append("%s: give_creature '%s' does not exist" % [tag, c.get("species", "")])
			"battle":
				if not StoryData.trainer_exists(str(c.get("trainer", ""))):
					errors.append("%s: battle trainer '%s' does not exist" % [tag, c.get("trainer", "")])
			"warp":
				if not zones.has(str(c.get("zone", ""))):
					errors.append("%s: warp to unknown zone '%s'" % [tag, c.get("zone", "")])
			"shop":
				if not items.shops.has(str(c.get("id", ""))):
					errors.append("%s: shop '%s' does not exist" % [tag, c.get("id", "")])
			"move":
				for d in c.get("path", []):
					if str(d) not in DIRS:
						errors.append("%s: move path has bad direction '%s'" % [tag, d])
			"face":
				if str(c.get("dir", "")) not in DIRS:
					errors.append("%s: face with bad direction" % tag)
	return errors

static func _validate_trainer(tid: String, dex: Dex, moves: MoveDB, items: ItemDB, zones: Dictionary) -> Array:
	var errors := []
	var tag := "trainer %s" % tid
	var raw = JsonUtil.read(StoryData.TRAINER_DIR.path_join(tid + ".json"))
	if not raw is Dictionary:
		return ["%s: not a JSON object" % tag]
	if str(raw.get("id", "")) != tid:
		errors.append("%s: id does not match file name" % tag)
	if str(raw.get("name", "")) == "":
		errors.append("%s: no name" % tag)
	if str(raw.get("ai", "trainer")) not in ["trainer", "keeper"]:
		errors.append("%s: unknown ai '%s'" % [tag, raw.get("ai")])
	if raw.get("party", []).is_empty():
		errors.append("%s: empty party" % tag)
	if bool(raw.get("double", false)) and raw.get("party", []).size() < 2:
		errors.append("%s: a double battle needs a party of at least 2" % tag)
	if int(raw.get("money", 0)) < 0:
		errors.append("%s: negative money" % tag)
	for m in raw.get("party", []):
		var sp := str(m.get("species", ""))
		if not dex.has(sp):
			errors.append("%s: species '%s' does not exist" % [tag, sp])
		var lv := int(m.get("level", 0))
		if lv < 1 or lv > Rules.MAX_LEVEL:
			errors.append("%s: level %d out of range" % [tag, lv])
		var mv: Array = m.get("moves", [])
		if mv.size() > Rules.MAX_MOVES:
			errors.append("%s: too many fixed moves for %s" % [tag, sp])
		for id in mv:
			if not moves.has(str(id)):
				errors.append("%s: move '%s' does not exist" % [tag, id])
	errors.append_array(validate_commands(raw.get("intro", []), tag + " intro", dex, items, zones))
	return errors
