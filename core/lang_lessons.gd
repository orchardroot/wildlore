class_name LangLessons
extends RefCounted
## Language lessons (4.5 "Learn as you go"), on top of 4.1's Words of the Isles (see Langs). Each data/lang/<code>.json
## may carry "name", "endonym", "about" and "lessons" (the contract in docs/briefs/wave45.md): a teacher stands in a
## real town, teaches 6 to 10 words with a pronunciation guide, then gives a quick check. Pass it and the words are
## yours: they join the Words of the Isles, come back for review on a spaced-repetition (Leitner) timetable, turn up
## after a won battle ("Say it"), in greetings and on signs. Finish every lesson of a level for its certificate.
##
## State, all in flags with safe defaults (an old save simply has none):
##   lang_lesson_<lesson id> = true             the lesson's check passed
##   lang_cert_<code>_<level> = true            a level's certificate (session C's evolutions read these)
##   word_<code>_lesson_<word id> = true        a word learnt (Langs' "words met" flag, so it counts in the Almanac)
##   lang_srs = {"<code>:<word id>": [box, due day]}   the review timetable, in in-game days (GameStateData.day_count)
##   lang_say_it = [day, n]                     "Say it" questions asked today (a few a day at most)
## Pure logic, no autoload names. The language list is Langs.CODES, never one of its own.

const LESSON_FLAG := "lang_lesson_"
const CERT_FLAG := "lang_cert_"
const SRS_FLAG := "lang_srs"
const SAY_IT_FLAG := "lang_say_it"
const KIND := "lesson"                       # Langs.flag_key(code, KIND, word id)
const LEVELS := [1, 2, 3, 4]
const LEVEL_NAMES := {1: "Survival", 2: "Out and about", 3: "A little grammar", 4: "Idioms and place-names"}
const MAX_BOX := 5
const INTERVALS := [0, 1, 2, 4, 8, 16]       # days until the next review, by box (box 0 is unused)
const PASS_TENTHS := 6                       # pass a lesson's check with 6 in 10 or better
const REVIEW_SIZE := 6
const SAY_IT_PER_DAY := 3
const SAY_IT_CHANCE := 0.3
const SAY_IT_MIN_WORDS := 4
const SAY_IT_PRIZE := 3                      # pounds sterling, paid in the local currency (Wallet.earn_here)
const TEACHER_PREFIX := "lang_teacher_"      # NPC id: lang_teacher_<first lesson id of that teacher>
const SCRIPT_FILE := "lang_lessons"          # data/dialogue/lang_lessons.json
const SCRIPT_ID := "lang_teacher"
const WORD_KEYS := ["id", "local", "english", "say", "note"]
const LESSON_KEYS := ["id", "title", "level", "teacher", "intro", "words", "tip"]
const TEACHER_KEYS := ["zone", "x", "y", "name", "sprite", "facing"]
## Characters that would mean IPA crept into a "say" guide (it is meant to be plain English spelling).
const IPA := ["ə", "ʃ", "ʒ", "θ", "ð", "ŋ", "ɪ", "ʊ", "ɛ", "ɔ", "æ", "ʌ", "ɑ", "ɬ", "χ", "ˈ", "ː", "/", "["]

# --- the data ------------------------------------------------------------------------------

## Language codes that have lessons, in Langs.CODES order.
static func codes() -> Array:
	return Langs.CODES.filter(func(c): return not lessons(c).is_empty())

static func lang_name(code: String) -> String:
	return str(Langs.data(code).get("name", Langs.NAMES.get(code, code)))

static func endonym(code: String) -> String:
	return str(Langs.data(code).get("endonym", ""))

static func about(code: String) -> Array:
	var a: Variant = Langs.data(code).get("about", [])
	return a if a is Array else []

const EXTRA_DIR := "res://data/lang/lessons"  # data/lang/lessons/<code>.json: a plain array of more lessons, appended

static var _extra := {}

## More lessons for a language from data/lang/lessons/<code>.json (a plain array), or [].
static func extra(code: String) -> Array:
	if code == "":
		return []
	if not _extra.has(code):
		var path := "%s/%s.json" % [EXTRA_DIR, code]
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		_extra[code] = d if d is Array else []
	return _extra[code]

static func reset() -> void:
	_extra = {}

## Every lesson entry a language has, in file order: its own file's "lessons", then data/lang/lessons/<code>.json.
static func raw_lessons(code: String) -> Array:
	var own: Variant = Langs.data(code).get("lessons", [])
	return (own if own is Array else []) + extra(code)

## A language's lessons, by level then id.
static func lessons(code: String) -> Array:
	var raw := raw_lessons(code)
	var out: Array = raw.filter(func(l): return l is Dictionary and str(l.get("id", "")) != "")
	out.sort_custom(func(a, b): return [int(a.get("level", 1)), str(a.id)] < [int(b.get("level", 1)), str(b.id)])
	return out

## "cy_01" -> "cy", "sco_ulster_02" -> "sco_ulster".
static func code_of(lesson_id: String) -> String:
	var i := lesson_id.rfind("_")
	return lesson_id.substr(0, i) if i > 0 else ""

static func lesson(lesson_id: String) -> Dictionary:
	for l in lessons(code_of(lesson_id)):
		if str(l.id) == lesson_id:
			return l
	return {}

## Every word a language teaches, each with "lesson" (its lesson id) and "level" added.
static func words(code: String) -> Array:
	var out := []
	for l in lessons(code):
		for w in l.get("words", []):
			if w is Dictionary:
				var c: Dictionary = w.duplicate()
				c["lesson"] = str(l.id)
				c["level"] = int(l.get("level", 1))
				out.append(c)
	return out

static func word(code: String, wid: String) -> Dictionary:
	for w in words(code):
		if str(w.get("id", "")) == wid:
			return w
	return {}

static func levels_of(code: String) -> Array:
	var out := []
	for l in lessons(code):
		var lv := int(l.get("level", 1))
		if lv not in out:
			out.append(lv)
	out.sort()
	return out

static func level_lessons(code: String, level: int) -> Array:
	return lessons(code).filter(func(l): return int(l.get("level", 1)) == level)

# --- progress ------------------------------------------------------------------------------

static func done(d: GameStateData, lesson_id: String) -> bool:
	return d.flag(LESSON_FLAG + lesson_id) == true

static func cert_flag(code: String, level: int) -> String:
	return "%s%s_%d" % [CERT_FLAG, code, level]

static func has_cert(d: GameStateData, code: String, level: int) -> bool:
	return d.flag(cert_flag(code, level)) == true

static func certs(d: GameStateData, code: String) -> Array:
	return levels_of(code).filter(func(lv): return has_cert(d, code, lv))

## A level opens once every lower level that has lessons is certified (level 1 is always open).
static func unlocked(d: GameStateData, code: String, level: int) -> bool:
	for lv in levels_of(code):
		if lv < level and not has_cert(d, code, lv):
			return false
	return true

static func lessons_done(d: GameStateData, code: String) -> int:
	return lessons(code).filter(func(l): return done(d, str(l.id))).size()

static func learnt(d: GameStateData, code: String, wid: String) -> bool:
	return d.flag(Langs.flag_key(code, KIND, wid)) == true

## The words of a language learnt so far, in lesson order.
static func learnt_words(d: GameStateData, code: String) -> Array:
	return words(code).filter(func(w): return learnt(d, code, str(w.get("id", ""))))

## The check is passed: the words are learnt and booked for review. Returns the levels certified just now.
static func learn(d: GameStateData, lesson_id: String) -> Array:
	var code := code_of(lesson_id)
	var l := lesson(lesson_id)
	if l.is_empty():
		return []
	if not done(d, lesson_id):
		d.set_flag(LESSON_FLAG + lesson_id, true)
		TrainerStats.add(d, "lessons_taken")
	var t := srs(d)
	for w in l.get("words", []):
		var wid := str(w.get("id", ""))
		Langs.note(d, code, KIND, wid)
		var key := _srs_key(code, wid)
		if not t.has(key):
			t[key] = [1, d.day_count + INTERVALS[1]]
	d.set_flag(SRS_FLAG, t)
	var out := []
	for lv in levels_of(code):
		if has_cert(d, code, lv):
			continue
		if level_lessons(code, lv).all(func(x): return done(d, str(x.id))):
			d.set_flag(cert_flag(code, lv), true)
			TrainerStats.add(d, "lang_certs")
			out.append(lv)
	return out

static func passed(score: int, total: int) -> bool:
	return total > 0 and score * 10 >= total * PASS_TENTHS

static func cert_title(code: String, level: int) -> String:
	return "Level %d %s: %s" % [level, lang_name(code), str(LEVEL_NAMES.get(level, ""))]

# --- teachers ------------------------------------------------------------------------------

static func _teacher_key(t: Dictionary) -> String:
	return "%s@%d,%d" % [str(t.get("zone", "")), int(t.get("x", 0)), int(t.get("y", 0))]

## Every lesson this teacher gives (the teacher of `lesson_id`: same zone and spot), in order.
static func teacher_lessons(lesson_id: String) -> Array:
	var l := lesson(lesson_id)
	if l.is_empty():
		return []
	var key := _teacher_key(l.get("teacher", {}))
	return lessons(code_of(lesson_id)).filter(func(x): return _teacher_key(x.get("teacher", {})) == key)

## NPC definitions for the teachers standing in this zone (the overworld nudges each onto a free tile).
static func npcs_for(zone_id: String) -> Array:
	var out := []
	var seen := {}
	for code in Langs.CODES:
		for l in lessons(code):
			var t: Variant = l.get("teacher", {})
			if not (t is Dictionary) or str(t.get("zone", "")) != zone_id:
				continue
			var key := _teacher_key(t)
			if seen.has(key):
				continue
			seen[key] = true
			out.append({"id": TEACHER_PREFIX + str(l.id), "sprite": str(t.get("sprite", "villager_1")), "name": str(t.get("name", "")),
				"x": int(t.get("x", 0)), "y": int(t.get("y", 0)), "facing": str(t.get("facing", "down")), "move": "still",
				"script": SCRIPT_ID, "script_file": SCRIPT_FILE})
	return out

## The lesson this teacher would give next: the first not done that is open. {} when none is open.
static func next_lesson(d: GameStateData, lesson_id: String) -> Dictionary:
	var code := code_of(lesson_id)
	for l in teacher_lessons(lesson_id):
		if not done(d, str(l.id)) and unlocked(d, code, int(l.get("level", 1))):
			return l
	return {}

## The first lesson of a language not yet done and open, anywhere (for a "try the teacher in ..." hint).
static func next_anywhere(d: GameStateData, code: String) -> Dictionary:
	for l in lessons(code):
		if not done(d, str(l.id)) and unlocked(d, code, int(l.get("level", 1))):
			return l
	return {}

# --- review (Leitner boxes) ----------------------------------------------------------------

static func _srs_key(code: String, wid: String) -> String:
	return code + ":" + wid

static func srs(d: GameStateData) -> Dictionary:
	var t: Variant = d.flag(SRS_FLAG)
	return t if t is Dictionary else {}

## [box, due day] for a learnt word, or [0, 0].
static func card(d: GameStateData, code: String, wid: String) -> Array:
	var c: Variant = srs(d).get(_srs_key(code, wid))
	if c is Array and c.size() >= 2:
		return [int(c[0]), int(c[1])]
	return [0, 0]

static func is_due(d: GameStateData, code: String, wid: String) -> bool:
	var c := card(d, code, wid)
	return c[0] > 0 and c[1] <= d.day_count

## Learnt words due for review, the most overdue (then the shakiest) first.
static func due_words(d: GameStateData, code: String) -> Array:
	var out := learnt_words(d, code).filter(func(w): return is_due(d, code, str(w.id)))
	out.sort_custom(func(a, b):
		var ca := card(d, code, str(a.id))
		var cb := card(d, code, str(b.id))
		return [ca[1], ca[0]] < [cb[1], cb[0]])
	return out

static func due_count(d: GameStateData, code: String) -> int:
	return due_words(d, code).size()

## One review answer. Right on a due word moves it up a box (seen again later); wrong puts it back in box 1, due now.
## Right on a word not yet due is just practice and changes nothing.
static func review(d: GameStateData, code: String, wid: String, right: bool) -> void:
	var c := card(d, code, wid)
	if c[0] <= 0:
		return
	TrainerStats.add(d, "words_reviewed")
	var t := srs(d)
	if not right:
		t[_srs_key(code, wid)] = [1, d.day_count]
	elif c[1] <= d.day_count:
		var box := mini(MAX_BOX, c[0] + 1)
		t[_srs_key(code, wid)] = [box, d.day_count + INTERVALS[box]]
	d.set_flag(SRS_FLAG, t)

## "in 4 days", "tomorrow", "today": when a word comes round again.
static func due_text(d: GameStateData, code: String, wid: String) -> String:
	var n := card(d, code, wid)[1] - d.day_count
	return "due now" if n <= 0 else ("tomorrow" if n == 1 else "in %d days" % n)

# --- questions -----------------------------------------------------------------------------

## A multiple-choice question about `w`: dir "meaning" ("What does X mean?") or "say" ("How do you say Y?").
## {q, options, answer, word, dir, fact}. Distractors come from `pool` (other words of the language), 3 at most.
static func question(code: String, w: Dictionary, dir: String, pool: Array, rng: Rng) -> Dictionary:
	var field := "english" if dir == "meaning" else "local"
	var right := str(w.get(field, ""))
	var others := []
	var same_lesson := []
	for o in pool:
		var t := str(o.get(field, ""))
		if str(o.get("id", "")) == str(w.get("id", "")) or _plain(t) == _plain(right) or t in others or t in same_lesson:
			continue
		if str(o.get("lesson", "")) == str(w.get("lesson", "")):
			same_lesson.append(t)
		else:
			others.append(t)
	_shuffle(same_lesson, rng)
	_shuffle(others, rng)
	var wrong: Array = (same_lesson + others).slice(0, 3)
	var opts := [right] + wrong
	_shuffle(opts, rng)
	var q := ("What does \"%s\" mean?" % str(w.get("local", ""))) if dir == "meaning" \
		else ("How do you say \"%s\" in %s?" % [str(w.get("english", "")), lang_name(code)])
	var fact := "%s (say %s): %s." % [str(w.get("local", "")), str(w.get("say", "")), str(w.get("english", ""))]
	if str(w.get("note", "")) != "":
		fact += " " + str(w.note)
	return {"q": q, "options": opts, "answer": opts.find(right), "word": str(w.get("id", "")), "dir": dir, "fact": fact,
		"cat": lang_name(code)}

## The check at the end of a lesson: every word once, the directions taking turns, in a shuffled order.
static func check_round(lesson_id: String, rng: Rng) -> Array:
	var code := code_of(lesson_id)
	var pool := words(code)
	var ws: Array = pool.filter(func(w): return str(w.lesson) == lesson_id)
	_shuffle(ws, rng)
	var out := []
	for i in ws.size():
		out.append(question(code, ws[i], "meaning" if i % 2 == 0 else "say", pool, rng))
	return out

## A review round: the due words first, then the shakiest of the rest for practice. [] when nothing is learnt.
static func review_round(d: GameStateData, code: String, rng: Rng, size := REVIEW_SIZE) -> Array:
	var pool := words(code)
	var picks := due_words(d, code)
	if picks.size() < size:
		var rest := learnt_words(d, code).filter(func(w): return not is_due(d, code, str(w.id)))
		_shuffle(rest, rng)
		rest.sort_custom(func(a, b): return card(d, code, str(a.id))[0] < card(d, code, str(b.id))[0])
		picks.append_array(rest)
	picks = picks.slice(0, size)
	var out := []
	for i in picks.size():
		out.append(question(code, picks[i], "meaning" if (i + d.day_count) % 2 == 0 else "say", pool, rng))
	return out

# --- word of the day, greetings, signs -----------------------------------------------------

## {code, word} for the pause screen: from what you've learnt (here first), else a first lesson's word of the
## local language, else {}. `day` picks it (the same all day).
static func word_of_day(d: GameStateData, code_here: String, day: int) -> Dictionary:
	var order := ([code_here] if code_here != "" else []) + Langs.CODES.filter(func(c): return c != code_here)
	for code in order:
		var ws := learnt_words(d, code)
		if not ws.is_empty():
			return {"code": code, "word": ws[posmod(day * 7 + 3, ws.size())]}
	if code_here != "":
		var first := level_lessons(code_here, 1)
		if not first.is_empty():
			var ws: Array = first[posmod(day, first.size())].get("words", [])
			if not ws.is_empty():
				return {"code": code_here, "word": ws[posmod(day, ws.size())]}
	return {}

const TIME_GREETINGS := [[0, 720, "good morning"], [720, 1080, "good afternoon"], [1080, 1440, "good evening"]]

## A learnt "good morning" / "good afternoon" / "good evening" for the time of day (minutes past midnight), or "".
static func time_greeting(d: GameStateData, code: String, minutes: int) -> String:
	var m := posmod(minutes, 1440)
	for g in TIME_GREETINGS:
		if m >= int(g[0]) and m < int(g[1]):
			for w in learnt_words(d, code):
				if _plain(str(w.get("english", ""))) == str(g[2]):
					return str(w.local) + "!"
	return ""

## A gloss for the local line of a sign, from the words you've learnt: "castell: castle". "" when none show.
static func sign_gloss(d: GameStateData, code: String, local_text: String) -> String:
	var hay := " " + _words_only(local_text) + " "
	if hay.strip_edges() == "":
		return ""
	var bits := []
	for w in learnt_words(d, code):
		var needle := _words_only(str(w.get("local", "")))
		if needle != "" and (" " + needle + " ") in hay:
			bits.append("%s: %s" % [str(w.local), str(w.english)])
	return ("You know: " + ", ".join(bits.slice(0, 3)) + ".") if not bits.is_empty() else ""

# --- Say it (after a won battle) -----------------------------------------------------------

static func say_it_today(d: GameStateData) -> int:
	var s: Variant = d.flag(SAY_IT_FLAG)
	return int(s[1]) if s is Array and s.size() >= 2 and int(s[0]) == d.day_count else 0

## Should a won battle here bring a "Say it" question? `roll` is 0..1.
static func say_it_offer(d: GameStateData, code: String, on: bool, roll: float) -> bool:
	return on and code != "" and learnt_words(d, code).size() >= SAY_IT_MIN_WORDS and say_it_today(d) < SAY_IT_PER_DAY \
		and roll < SAY_IT_CHANCE

static func say_it_used(d: GameStateData) -> void:
	d.set_flag(SAY_IT_FLAG, [d.day_count, say_it_today(d) + 1])

## The question: a due word if there is one, else any learnt one; always "how do you say".
static func say_it_question(d: GameStateData, code: String, rng: Rng) -> Dictionary:
	var ws := due_words(d, code)
	if ws.is_empty():
		ws = learnt_words(d, code)
	if ws.is_empty():
		return {}
	return question(code, ws[rng.roll_int(0, ws.size() - 1)], "say", words(code), rng)

# --- the glossary --------------------------------------------------------------------------

## Rows for the Words of the Isles: [{word, meaning, say, note}] for each learnt word.
static func glossary_rows(d: GameStateData, code: String) -> Array:
	return learnt_words(d, code).map(func(w): return {"word": str(w.local), "meaning": str(w.english), "say": str(w.get("say", "")),
		"note": str(w.get("note", ""))})

# --- helpers -------------------------------------------------------------------------------

static func _plain(s: String) -> String:
	return s.strip_edges().to_lower().rstrip("!?.,")

## Lower case, punctuation turned to spaces, single-spaced: for whole-word matching.
static func _words_only(s: String) -> String:
	var out := ""
	for ch in s.to_lower():
		out += ch if (ch == "'" or ch == "’" or ch.to_upper() != ch.to_lower() or ch.is_valid_int()) else " "
	while "  " in out:
		out = out.replace("  ", " ")
	return out.strip_edges()

static func _shuffle(a: Array, rng: Rng) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = a[i]
		a[i] = a[j]
		a[j] = t

# --- the validator -------------------------------------------------------------------------

## Problems with the lesson data. `zone_of` maps a zone id to its ZoneData (or null); `index` is ZoneIndex's.
static func check(zone_of: Callable, index: Dictionary) -> Array:
	var errs := []
	var tiles := {}
	for code in Langs.CODES:
		var path := "res://data/lang/%s.json" % code
		if not FileAccess.file_exists(path):
			continue
		var dd: Variant = JsonUtil.read(path)
		if not (dd is Dictionary):
			continue
		for k in ["name", "endonym"]:
			if dd.has(k) and str(dd[k]).strip_edges() == "":
				errs.append("lang %s: empty %s" % [code, k])
		if dd.has("about"):
			if not (dd.about is Array) or dd.about.size() < 2 or dd.about.size() > 4:
				errs.append("lang %s: 'about' should be 2 to 4 lines" % code)
		var raw: Variant = dd.get("lessons", [])
		if not (raw is Array):
			errs.append("lang %s: 'lessons' is not a list" % code)
			continue
		var xpath := "%s/%s.json" % [EXTRA_DIR, code]
		if FileAccess.file_exists(xpath):
			var x: Variant = JsonUtil.read(xpath)
			if not (x is Array):
				errs.append("lang %s: %s should be a plain list of lessons" % [code, xpath])
			else:
				if "—" in JSON.stringify(x):
					errs.append("lang %s: em-dash in %s" % [code, xpath])
				raw = raw + x
		errs.append_array(check_list(code, raw, zone_of, index, tiles))
	return errs

## Problems with one language's lessons (both files together); `tiles` collects the teachers' spots across languages.
static func check_list(code: String, raw: Array, zone_of: Callable, index: Dictionary, tiles := {}) -> Array:
	var errs := []
	var lids := {}
	var wids := {}
	for l in raw:
		if not (l is Dictionary):
			errs.append("lang %s: a lesson is not an object" % code)
			continue
		var lid := str(l.get("id", ""))
		var tag := "lang %s lesson %s" % [code, lid]
		if lids.has(lid):
			errs.append("%s: duplicate lesson id" % tag)
		lids[lid] = true
		var suffix := lid.trim_prefix(code + "_")
		if not lid.begins_with(code + "_") or suffix.length() != 2 or not suffix.is_valid_int():
			errs.append("%s: id should be %s_NN" % [tag, code])
		for k in l:
			if k not in LESSON_KEYS:
				errs.append("%s: unknown key '%s'" % [tag, k])
		if str(l.get("title", "")).strip_edges() == "":
			errs.append("%s: no title" % tag)
		if int(l.get("level", 0)) not in LEVELS:
			errs.append("%s: level should be 1 to 4" % tag)
		var intro: Variant = l.get("intro", [])
		if not (intro is Array) or intro.size() < 1 or intro.size() > 3:
			errs.append("%s: intro should be 1 to 3 lines" % tag)
		var ws: Variant = l.get("words", [])
		if not (ws is Array) or ws.size() < 6 or ws.size() > 10:
			errs.append("%s: should teach 6 to 10 words" % tag)
			ws = ws if ws is Array else []
		for w in ws:
			if not (w is Dictionary):
				errs.append("%s: a word is not an object" % tag)
				continue
			var wid := str(w.get("id", ""))
			if wid == "":
				errs.append("%s: a word has no id" % tag)
			elif wids.has(wid):
				errs.append("%s: word id '%s' already used in %s" % [tag, wid, wids[wid]])
			wids[wid] = lid
			for k in w:
				if k not in WORD_KEYS:
					errs.append("%s word %s: unknown key '%s'" % [tag, wid, k])
			for k in ["local", "english", "say"]:
				if str(w.get(k, "")).strip_edges() == "":
					errs.append("%s word %s: no '%s'" % [tag, wid, k])
			var say := str(w.get("say", ""))
			for ch in IPA:
				if ch in say:
					errs.append("%s word %s: 'say' should be plain English spelling, not IPA ('%s')" % [tag, wid, ch])
					break
			if say != "" and say == say.to_lower():
				errs.append("%s word %s: 'say' should show the stressed syllable in capitals" % [tag, wid])
		errs.append_array(_check_teacher(code, tag, l.get("teacher", {}), zone_of, index, tiles))
	return errs

static func _check_teacher(code: String, tag: String, t: Variant, zone_of: Callable, index: Dictionary, tiles: Dictionary) -> Array:
	var errs := []
	if not (t is Dictionary):
		return ["%s: no teacher" % tag]
	for k in t:
		if k not in TEACHER_KEYS:
			errs.append("%s: teacher has unknown key '%s'" % [tag, k])
	if str(t.get("name", "")).strip_edges() == "":
		errs.append("%s: teacher has no name" % tag)
	var sid := str(t.get("sprite", ""))
	if not FileAccess.file_exists("res://art/sprites/chars/%s.png" % sid):
		errs.append("%s: teacher sprite '%s' has no art" % [tag, sid])
	var zid := str(t.get("zone", ""))
	var z = zone_of.call(zid)
	if z == null:
		return errs + ["%s: teacher zone '%s' is not a zone" % [tag, zid]]
	var p := Vector2i(int(t.get("x", -1)), int(t.get("y", -1)))
	var key := _teacher_key(t)
	var who := "%s/%s" % [code, str(t.get("name", ""))]
	if not tiles.has(key):
		if not z.in_bounds(p) or not SideStories.free_tile(z, p, {}):
			errs.append("%s: teacher at %s (%d, %d) is not on a free floor tile" % [tag, zid, p.x, p.y])
		tiles[key] = who
	elif str(tiles[key]) != who:
		errs.append("%s: another teacher (%s) stands on that tile" % [tag, tiles[key]])
	var here := Langs.code_for(zid, index)
	if here != code:  # lessons stay in their own country: a Welsh teacher only stands where Welsh is local
		errs.append("%s: teacher stands in %s, not a %s-speaking place" % [tag, ("a " + str(Langs.NAMES.get(here, here)) + "-speaking place") if here != "" else "a place with no local language", Langs.NAMES.get(code, code)])
	return errs
