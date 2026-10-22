class_name BiologyCheck
extends RefCounted
## Validator for data/biology.json (core/biology.gd). Reads the file itself and names no other class, so the validator
## can load it without pulling in UI code. That a page's "idea:<id>" names a real Stud Book idea is a unit test.

const GOALS := ["mark_medium", "female", "coat", "tortie", "frame_mean"]
const MAX_REWARD := 100

static func check(path := "res://data/biology.json") -> Array:
	var errors := []
	var d = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if not d is Dictionary:
		return ["biology.json: missing or unreadable"]
	var ids := {}
	for p in d.get("pages", []):
		var id := str(p.get("id", ""))
		if id == "" or ids.has(id):
			errors.append("biology.json: page id '%s' empty or repeated" % id)
		ids[id] = true
		if p.get("text", []).size() != 4:
			errors.append("biology.json: page '%s' needs four lines" % id)
		for cond in str(p.get("when", "")).split("|"):
			if not (cond == "always" or cond.begins_with("flag:bio_") or (cond.begins_with("idea:") and cond.length() > 5)):
				errors.append("biology.json: page '%s' has a bad 'when' '%s'" % [id, cond])
		if str(p.get("when", "")) != "always" and str(p.get("hint", "")) == "":
			errors.append("biology.json: page '%s' is locked at first and needs a hint" % id)
		for t in p.get("text", []) + [p.get("title", ""), p.get("story", "")]:
			if str(t) == "" or "—" in str(t):
				errors.append("biology.json: page '%s' has empty text or an em-dash" % id)
		if "—" in str(p.get("hint", "")):
			errors.append("biology.json: page '%s' hint has an em-dash" % id)
	var cids := {}
	for c in d.get("challenges", []):
		var id := str(c.get("id", ""))
		if id == "" or cids.has(id):
			errors.append("biology.json: challenge id '%s' empty or repeated" % id)
		cids[id] = true
		if not str(c.get("goal", "")) in GOALS:
			errors.append("biology.json: challenge '%s' has an unknown goal" % id)
		if int(c.get("reward", 0)) > MAX_REWARD:
			errors.append("biology.json: challenge '%s' pays more than £%d" % [id, MAX_REWARD])
		for t in [c.get("title", ""), c.get("ask", ""), c.get("brief", "")]:
			if str(t) == "" or "—" in str(t):
				errors.append("biology.json: challenge '%s' has empty text or an em-dash" % id)
	return errors
