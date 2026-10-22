extends MenuBase
## Language lessons (4.5, see LangLessons): menu "lang:lesson:<id>" shows the lesson card (each word, how to say it,
## a note, the tip), then a quick check, and closes with {"score", "total"} (the teacher's command marks the lesson
## learnt on a pass). "lang:review:<code>" is a spaced-repetition review round: each answer is booked straight away.
## Closes with null if the player backs out. Dev/screenshot args: "lesson:<id>:check" opens at the first question,
## "lesson:<id>:answered" with it answered (wrongly), "review:<code>:answered" likewise.

const CORRECT_BG := Color("2f5d3a")
const CORRECT_EDGE := Color("8fd19e")
const WRONG_BG := Color("6b2c2c")
const WRONG_EDGE := Color("e08a8a")
const LETTERS := ["A", "B", "C", "D"]
const SAY_INK := Color("b9c7e6")

var _mode := ""            # "lesson" or "review"
var _code := ""
var _lesson: Dictionary = {}
var _rng: Rng
var _questions: Array = []
var _index := 0
var _score := 0
var _picked := -1
var _root: VBoxContainer
var _buttons: Array = []

func _build() -> void:
	set_title("Words of the Isles")
	_root = VBoxContainer.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_theme_constant_override("separation", 10)
	content.add_child(_root)

func setup(arg: String) -> void:
	var parts := arg.split(":")
	_mode = parts[0]
	var dev := parts[2] if parts.size() > 2 else ""
	_rng = Rng.new(7) if dev != "" else Rng.new(int(Time.get_ticks_usec()))
	if _mode == "lesson":
		_lesson = LangLessons.lesson(parts[1] if parts.size() > 1 else "")
		_code = LangLessons.code_of(str(_lesson.get("id", "")))
		if _lesson.is_empty():
			close.call_deferred(null)
			return
		set_title(LangLessons.lang_name(_code) + ": " + str(_lesson.title))
		if dev == "":
			_show_card()
		else:
			_start_check()
	else:
		_code = parts[1] if parts.size() > 1 else ""
		set_title("Revision: " + LangLessons.lang_name(_code))
		_questions = LangLessons.review_round(Game.data, _code, _rng)
		if _questions.is_empty():
			_show_empty()
			return
		_index = 0
		_ask()
	if dev == "answered":
		_answer(0 if int(_questions[0].answer) != 0 else 1)

# ---- the lesson card

func _show_card() -> void:
	_reset()
	var lv := int(_lesson.get("level", 1))
	header_right.text = "Level %d · %s" % [lv, str(LangLessons.LEVEL_NAMES.get(lv, ""))]
	var who := str(_lesson.get("teacher", {}).get("name", ""))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(UIKit.chip(_code.to_upper(), UIKit.HEATHER.darkened(0.25), UIKit.CREAM, 16))
	var e := LangLessons.endonym(_code)
	top.add_child(UIKit.label(LangLessons.lang_name(_code) + ((" (" + e + ")") if e != "" else ""), 24, UIKit.GOLD))
	top.add_child(UIKit.fill())
	if who != "":
		top.add_child(UIKit.label("with " + who, 22, UIKit.MUTED))
	_root.add_child(top)
	var ws: Array = _lesson.get("words", [])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var small := ws.size() > 8
	for w in ws:
		grid.add_child(_word_cell(w, small))
	_root.add_child(grid)
	var tip := str(_lesson.get("tip", ""))
	if tip != "":
		var tp := UIKit.panel(Color("2a2338f0"), 10)
		var tl := UIKit.label(tip, 20, Color("d8cfb4"))
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tp.add_child(tl)
		_root.add_child(tp)
	var go := make_button("Ready for a quick check", _start_check, 360)
	go.add_theme_font_size_override("font_size", 24)
	var row := HBoxContainer.new()
	row.add_child(UIKit.fill())
	row.add_child(go)
	_root.add_child(row)
	set_hints([["confirm", "Start the check"], ["cancel", "Leave"]])
	UIKit.focus_later(go)

func _word_cell(w: Dictionary, small: bool) -> Control:
	var p := UIKit.panel(Color("1d2230f0"), 8)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	p.add_child(v)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.add_child(UIKit.label(str(w.get("local", "")), 24 if small else 26, Langs.LOCAL_INK))
	h.add_child(UIKit.label(str(w.get("english", "")), 20 if small else 22, UIKit.CREAM))
	v.add_child(h)
	var say := "say " + str(w.get("say", ""))
	var note := str(w.get("note", ""))
	var l := UIKit.label(say + (("  ·  " + note) if note != "" else ""), 15 if small else 16, SAY_INK)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(560, 0)
	v.add_child(l)
	return p

func _start_check() -> void:
	set_title(LangLessons.lang_name(_code))  # the lesson's title moves into the question card, so the header fits
	_questions = LangLessons.check_round(str(_lesson.id), _rng)
	_index = 0
	_score = 0
	_ask()

# ---- asking (the same shape as the pub quiz)

func _ask() -> void:
	_picked = -1
	var q: Dictionary = _questions[_index]
	_reset()
	_update_header()
	set_hints([["updown", "Choose"], ["confirm", "Answer"], ["cancel", "Leave"]])
	var p := UIKit.panel(Color("1d2230f0"), 14)
	p.custom_minimum_size = Vector2(0, 104)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	v.add_child(UIKit.label(("CHECK: " + str(_lesson.title) if _mode == "lesson" else "REVISION").to_upper(), 18, UIKit.HEATHER.lightened(0.3)))
	var l := UIKit.label(str(q.q), 32)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(l)
	_root.add_child(p)
	var opts := VBoxContainer.new()
	opts.add_theme_constant_override("separation", 8)
	_root.add_child(opts)
	for i in q.options.size():
		var b := Button.new()
		b.text = "%s    %s" % [LETTERS[i], q.options[i]]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 52)
		b.add_theme_font_size_override("font_size", 28)
		b.focus_entered.connect(func(): Audio.sfx("cursor"))
		b.pressed.connect(_answer.bind(i))
		opts.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	UIKit.focus_later(_buttons[0])

func _answer(i: int) -> void:
	if _picked >= 0:
		return
	_picked = i
	var q: Dictionary = _questions[_index]
	var right: bool = i == int(q.answer)
	if right:
		_score += 1
	if _mode == "review":
		LangLessons.review(Game.data, _code, str(q.word), right)
	Audio.sfx("heal" if right else "bump")
	_update_header()
	for k in _buttons.size():
		var b: Button = _buttons[k]
		b.focus_mode = Control.FOCUS_NONE
		if k == int(q.answer):
			_tint(b, CORRECT_BG, CORRECT_EDGE)
		elif k == i:
			_tint(b, WRONG_BG, WRONG_EDGE)
	var fb := UIKit.panel(Color("1d2230f0"), 12)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	fb.add_child(v)
	v.add_child(UIKit.label("Da iawn!" if right and _code == "cy" else ("Correct!" if right else "Not quite."), 26, CORRECT_EDGE if right else WRONG_EDGE))
	var f := UIKit.label(str(q.fact), 22, Color("d8cfb4"))
	f.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(f)
	if _mode == "review":
		v.add_child(UIKit.label("Next time: " + LangLessons.due_text(Game.data, _code, str(q.word)), 18, UIKit.MUTED))
	_root.add_child(fb)
	var last := _index + 1 >= _questions.size()
	var next := make_button("See how you did" if last else "Next", _next, 280)
	next.add_theme_font_size_override("font_size", 26)
	var row := HBoxContainer.new()
	row.add_child(UIKit.fill())
	row.add_child(next)
	_root.add_child(row)
	set_hints([["confirm", "Carry on"], ["cancel", "Leave"]])
	UIKit.focus_later(next)

func _tint(b: Button, bg: Color, edge: Color) -> void:
	var s := UIKit.box(bg, edge, 2, 6, 10)
	for state in ["normal", "hover", "focus", "pressed", "hover_pressed", "disabled"]:
		b.add_theme_stylebox_override(state, s)
	b.add_theme_color_override("font_color", Color("ffffff"))

func _next() -> void:
	_index += 1
	if _index >= _questions.size():
		_show_result()
	else:
		_ask()

# ---- the result

func _show_result() -> void:
	_reset()
	header_right.text = ""
	var total := _questions.size()
	var p := UIKit.panel(Color("1d2230f0"), 28)
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(p)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 14)
	p.add_child(v)
	var big := UIKit.label("%d / %d" % [_score, total], 96, UIKit.GOLD)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(big)
	var line := ""
	if _mode == "lesson":
		line = "That's a pass. Your teacher will want a word." if LangLessons.passed(_score, total) \
			else "Not a pass this time (%d needed). Have another look at the card and try again." % ceili(total * LangLessons.PASS_TENTHS / 10.0)
	else:
		var due := LangLessons.due_count(Game.data, _code)
		line = "All caught up. The words you knew come back later, the ones you missed come back sooner." if due == 0 \
			else "%d still due. Little and often." % due
	var l := UIKit.label(line, 26)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(l)
	var done := make_button("Done", _finish, 240)
	done.add_theme_font_size_override("font_size", 28)
	var row := CenterContainer.new()
	row.add_child(done)
	v.add_child(row)
	set_hints([["confirm", "Done"]])
	UIKit.focus_later(done)

func _show_empty() -> void:
	_reset()
	var l := UIKit.label("No words learnt in %s yet. Find a teacher: they stand in libraries, cafes and chapel halls." % LangLessons.lang_name(_code), 26)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_root.add_child(l)
	var done := make_button("Back", func(): close(null), 200)
	_root.add_child(done)
	set_hints([["confirm", "Back"]])
	UIKit.focus_later(done)

func _finish() -> void:
	if _done:
		return
	_done = true  # not close(): that plays the back-out sound
	closed.emit({"score": _score, "total": _questions.size()})

func _reset() -> void:
	UIKit.clear(_root)
	_buttons.clear()

func _update_header() -> void:
	header_right.text = "Question %d of %d  ·  Score %d" % [_index + 1, _questions.size(), _score]

func _on_cancel() -> void:
	close(null)
