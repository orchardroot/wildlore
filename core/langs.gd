class_name Langs
extends RefCounted
## The local languages (4.1 "Voices of the Isles"): Welsh, Irish, Scottish Gaelic, Manx, Cornish, Jerriais and
## Guernesiais shown beside English where the place really uses them. Data lives in data/lang/<code>.json:
##   {"places": {"<zone id>": "Caerdydd"}, "greetings": ["Shwmae!"], "phrases": {"thanks": "Diolch"}}
## and a zone sign may carry "local": {"cy": "Croeso"}. A language only ever shows what its file holds, so a form
## nobody was sure of is simply left out. Words met are flags (word_<code>_<kind>_<key>), listed in the Fieldbook's
## "Words of the Isles" page. Pure logic, no autoload names: callers pass `on` (Settings.local_languages != "off").

const CODES := ["cy", "ga", "gd", "gv", "kw", "jer", "nrf_gg", "sco", "sco_ulster"]
const NAMES := {"cy": "Welsh", "ga": "Irish", "gd": "Scottish Gaelic", "gv": "Manx", "kw": "Cornish", "jer": "Jerriais", "nrf_gg": "Guernesiais",
	"sco": "Scots", "sco_ulster": "Ulster Scots"}
const CODES := ["cy", "ga", "gd", "gv", "kw", "jer", "nrf_gg", "br"]
const NAMES := {"cy": "Welsh", "ga": "Irish", "gd": "Scottish Gaelic", "gv": "Manx", "kw": "Cornish", "jer": "Jerriais", "nrf_gg": "Guernesiais", "br": "Breton"}
## Region -> language (Wales: cy; Ireland and the Gaeltacht: ga; Highlands and Islands: gd; Mann; Cornwall).
const REGION_LANG := {"north_wales": "cy", "mid_wales": "cy", "south_wales": "cy", "ireland": "ga", "ireland_west": "ga",
	"ireland_east": "ga", "scotland": "gd", "man": "gv", "cornwall": "kw"}
## The Channel Islands share one region, so their zones are told apart by id (an interior borrows its town's).
const ZONE_LANG := {"st_helier": "jer", "jersey_country": "jer", "st_peter_port": "nrf_gg", "guernsey_country": "nrf_gg"}
## Scots and Ulster Scots (4.5): zones (and every zone or room under them, "edinburgh" covers "edinburgh_castle")
## where they are the local tongue. Checked before the region, so the Lowlands, the North East's Doric, Orkney and
## Shetland get Scots, and Antrim's Ulster-Scots heartland (Belfast, the Route, the Causeway coast) gets Ulster Scots.
const PREFIX_LANG := {"sco": ["edinburgh", "glasgow", "aberdeen", "dundee", "st_andrews", "cairnryan", "scottish_borders",
		"forth_bridges", "galloway", "central_belt", "kirkwall", "lerwick", "shetland_mainland"],
	"sco_ulster": ["belfast", "bushmills", "antrim_coast", "antrim_ropehut", "causeway"]}
const ZONE_LANG := {"st_helier": "jer", "jersey_country": "jer", "st_peter_port": "nrf_gg", "guernsey_country": "nrf_gg",
	"gaiman": "cy", "baddeck": "gd", "roscoff": "br"}  # these isles abroad: Y Wladfa, Cape Breton, Brittany
## Places in a language's region where it isn't the everyday local tongue, so no greeting or banner in it: Northern
## Ireland (its towns share the "ireland" region; Irish there is used sparingly, by choice, not by default) and the
## Scottish Lowlands and east coast (Gaelic is a Highlands and Islands language).
const NOT_LOCAL := {"ga": ["belfast", "bushmills", "derry", "enniskillen", "lough_neagh", "mourne", "giants_causeway", "mournes",
		"causeway", "antrim_coast", "antrim_ropehut", "marblearch"],
	"gd": ["edinburgh", "glasgow", "aberdeen", "dundee", "st_andrews", "cairnryan", "scottish_borders", "forth_bridges",
		"galloway", "kirkwall", "lerwick", "shetland_mainland"]}
## Languages whose signs lead with the local language (Welsh and Irish signs show it first).
const LOCAL_FIRST := ["cy", "ga"]
## The languages a creature's real-life basis is named in (its `names`, see docs/design/fieldbook_teaching.md),
## in the order the Fieldbook shows them.
const CREATURE_NAME_CODES := ["cy", "ga", "gd"]
const LOCAL_INK := Color("e8c872")  # a touch warmer than the English text, on a sign or the town banner
const FLAG_PREFIX := "word_"
const SEP := " / "

static var _cache := {}
## Kept in step with Settings.local_languages, for scripts that mustn't name autoloads.
static var enabled := true

static func setting_on(value: String) -> bool:
	return value != "off"

## The language code for a zone ("" if none): its id, its town's id (an interior) or its region. `index` is
## ZoneIndex.get_index() (or a fixture with zones and room_town).
static func code_for(zone_id: String, index: Dictionary) -> String:
	var id := zone_id
	var town := str(index.get("room_town", {}).get(id, ""))
	if town != "":
		id = town
	if ZONE_LANG.has(id):
		return ZONE_LANG[id]
	for alt in PREFIX_LANG:
		for prefix in PREFIX_LANG[alt]:
			if id == prefix or id.begins_with(prefix + "_"):
				return alt
	var region := str(index.get("zones", {}).get(id, {}).get("region", ""))
	var code := str(REGION_LANG.get(region, ""))
	for prefix in NOT_LOCAL.get(code, []):
		if id == prefix or id.begins_with(prefix + "_"):
			return ""
	return code

static func data(code: String) -> Dictionary:
	if code == "":
		return {}
	if not _cache.has(code):
		var path := "res://data/lang/%s.json" % code
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		_cache[code] = d if d is Dictionary else {}
	return _cache[code]

static func reset() -> void:
	_cache = {}
	LangLessons.reset()  # and the extra lesson files (data/lang/lessons)

## The local name of a zone's town or route ("" when the language has none, or it is the same as English).
static func place(code: String, zone_id: String, english: String, index: Dictionary) -> String:
	var id := zone_id
	var town := str(index.get("room_town", {}).get(id, ""))
	var places: Dictionary = data(code).get("places", {})
	var n := str(places.get(id, places.get(town, "")))
	return "" if n == english else n

## Both names, in the local order, or just the English one: "Caerdydd / Cardiff".
static func both(code: String, local: String, english: String) -> String:
	if local == "" or local == english:
		return english
	return (local + SEP + english) if code in LOCAL_FIRST else (english + SEP + local)

## The town banner's two lines: [title, local name]. The local name is "" when there is nothing to add.
static func banner(zone_id: String, english: String, on: bool, index: Dictionary) -> Array:
	if not on:
		return [english, ""]
	var code := code_for(zone_id, index)
	var local := place(code, zone_id, english, index)
	return [english, local]

## What a sign says: [lines, local_line]. A plain sign gains the local words as their own line (first where that
## is local practice); a plaque (title) gets both names in its title instead, see sign_title.
static func sign_lines(sign: Dictionary, zone_id: String, on: bool, index: Dictionary) -> Array:
	var text := str(sign.get("text", ""))
	var local := local_for(sign, zone_id, on, index)
	if local == "" or str(sign.get("plaque", "")) != "":
		return [[text], ""]
	var code := code_for(zone_id, index)
	return [[local, text] if code in LOCAL_FIRST else [text, local], local]

static func sign_title(sign: Dictionary, zone_id: String, on: bool, index: Dictionary) -> String:
	var title := str(sign.get("title", ""))
	var local := local_for(sign, zone_id, on, index)
	if local == "" or title == "":
		return title
	return both(code_for(zone_id, index), local, title)

static func local_for(sign: Dictionary, zone_id: String, on: bool, index: Dictionary) -> String:
	if not on:
		return ""
	var loc: Variant = sign.get("local", {})
	if not (loc is Dictionary):
		return ""
	return str(loc.get(code_for(zone_id, index), ""))

## A local hello for a zone, or "" (callers keep their English one). `salt` varies it (the clock, an NPC).
static func greeting(zone_id: String, salt: int, on: bool, index: Dictionary) -> String:
	if not on:
		return ""
	var g: Array = data(code_for(zone_id, index)).get("greetings", [])
	if g.is_empty():
		return ""
	return str(g[absi(hash(zone_id) + salt) % g.size()])

# --- words met -------------------------------------------------------------------------

static func flag_key(code: String, kind: String, key: String) -> String:
	return "%s%s_%s_%s" % [FLAG_PREFIX, code, kind, key]

static func note(d: GameStateData, code: String, kind: String, key: String) -> void:
	if code != "" and key != "" and d.flag(flag_key(code, kind, key)) != true:
		d.set_flag(flag_key(code, kind, key), true)

## Records the words a banner, a sign or a greeting just showed: the place, and any phrase or greeting in the text.
static func note_place(d: GameStateData, zone_id: String, english: String, index: Dictionary) -> void:
	var code := code_for(zone_id, index)
	if place(code, zone_id, english, index) != "":
		note(d, code, "place", zone_id)

static func note_text(d: GameStateData, code: String, text: String) -> void:
	var dd := data(code)
	var low := _plain(text)
	if low == "":
		return
	for k in dd.get("phrases", {}):
		if _plain(str(dd.phrases[k])) == low:
			note(d, code, "phrase", str(k))
	var g: Array = dd.get("greetings", [])
	for i in g.size():
		if _plain(str(g[i])) == low:
			note(d, code, "hello", str(i))

static func _plain(s: String) -> String:
	return s.strip_edges().to_lower().rstrip("!?.,")

## The glossary: [{code, language, rows: [{word, meaning}]}] for every language with something met, in CODES order.
## `zone_names` maps zone id -> English name (the meaning of a place).
static func glossary(d: GameStateData, zone_names: Dictionary) -> Array:
	var out := []
	for code in CODES:
		var dd := data(code)
		if dd.is_empty():
			continue
		var rows := []
		var places: Dictionary = dd.get("places", {})
		var zids := places.keys()
		zids.sort()
		for zid in zids:
			if d.flag(flag_key(code, "place", str(zid))) == true:
				rows.append({"word": str(places[zid]), "meaning": str(zone_names.get(zid, zid))})
		var phrases: Dictionary = dd.get("phrases", {})
		var keys := phrases.keys()
		keys.sort()
		for k in keys:
			if d.flag(flag_key(code, "phrase", str(k))) == true:
				rows.append({"word": str(phrases[k]), "meaning": str(k).replace("_", " ")})
		var g: Array = dd.get("greetings", [])
		for i in g.size():
			if d.flag(flag_key(code, "hello", str(i))) == true:
				var meaning := "a local greeting"
				for k in phrases:
					if _plain(str(phrases[k])) == _plain(str(g[i])):
						meaning = str(k).replace("_", " ")
				rows.append({"word": str(g[i]), "meaning": meaning})
		var have := rows.map(func(r): return _plain(str(r.word)))
		for r in LangLessons.glossary_rows(d, code):  # words learnt from a teacher (4.5), unless already listed
			if _plain(str(r.word)) not in have:
				rows.append(r)
		if not rows.is_empty():
			out.append({"code": code, "language": str(NAMES.get(code, dd.get("name", code))), "rows": rows})
	return out

## Problems with data/lang files for the validator: shape, no em-dashes, known zones.
static func check(zone_exists: Callable) -> Array:
	var errs := []
	for code in CODES:
		var path := "res://data/lang/%s.json" % code
		if not FileAccess.file_exists(path):
			continue
		var d: Variant = JsonUtil.read(path)
		if not (d is Dictionary):
			errs.append("lang %s: not a JSON object" % code)
			continue
		for k in d:
			if k not in ["places", "greetings", "phrases", "name", "endonym", "about", "lessons"]:  # 4.5 lessons: see LangLessons
				errs.append("lang %s: unknown key '%s'" % [code, k])
		for zid in d.get("places", {}):
			if not zone_exists.call(str(zid)):
				errs.append("lang %s: place '%s' is not a zone" % [code, zid])
		var all_text := JSON.stringify(d)
		if "—" in all_text:
			errs.append("lang %s: em-dash in text" % code)
		for g in d.get("greetings", []):
			if str(g).strip_edges() == "":
				errs.append("lang %s: empty greeting" % code)
	return errs
