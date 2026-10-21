class_name CasebookTab
extends RefCounted
## The Fieldbook's Casebook tab (after Rumours, once a case is open): one row per case, then in the detail panel the
## leads followed so far, the next one, the evidence held (red herrings look like everything else until the case
## is closed) and the suspects still in the frame. The pedia screen owns the list and the focus; same shape as StudBookTab.

static func ids() -> Array:
	return Casebook.open_cases(Game.data).map(func(c): return str(c.id))

static func visible(data: GameStateData) -> bool:
	return Casebook.visible(data)

static func row(id: String, h: HBoxContainer) -> void:
	var c := Casebook.get_case(id)
	var done := Casebook.solved(Game.data, c)
	h.add_child(UIKit.chip("SOLVED" if done else "OPEN", (UIKit.GOLD if done else UIKit.HEATHER).darkened(0.25), UIKit.CREAM if not done else UIKit.SLATE, 16))
	h.add_child(UIKit.label(str(c.title), 26, UIKit.CREAM))

static func _words(detail: VBoxContainer, text: String, size := 21, colour := UIKit.CREAM) -> Label:
	var l := UIKit.label(text, size, colour)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(l)
	return l

static func show(id: String, detail: VBoxContainer) -> void:
	UIKit.clear(detail)
	var d: GameStateData = Game.data
	var c := Casebook.get_case(id)
	if c.is_empty():
		return
	var done := Casebook.solved(d, c)
	detail.add_child(UIKit.label(str(c.title), 34, UIKit.GOLD))
	_words(detail, "%s. %d of %d leads followed." % [Standing.name_of(str(c.nation)), Casebook.steps_done(d, c), c.steps.size()], 20, UIKit.MUTED)
	var nxt := Casebook.next_step(d, c)
	if done:
		_words(detail, str(c.get("closed", "Case closed.")), 22, UIKit.GOLD)
	elif nxt.is_empty():
		_words(detail, "Every lead followed. Time to name someone: %s" % str(c.get("accuse_hint", "go back to whoever gave you the case.")), 22, UIKit.GOLD)
	else:
		_words(detail, "Next: %s" % str(nxt.text), 22)
	detail.add_child(UIKit.spacer(4))
	detail.add_child(UIKit.label("Evidence", 24, UIKit.MUTED))
	var held := Casebook.held(d, c)
	if held.is_empty():
		_words(detail, "Nothing yet. Look at things. Ask people.", 20, UIKit.MUTED)
	for e in held:
		var herring: bool = done and e.get("red_herring", false)
		_words(detail, "%s%s" % [str(e.name), " (a red herring)" if herring else ""], 22, UIKit.MUTED if herring else UIKit.CREAM)
		_words(detail, str(e.text), 19, UIKit.MUTED)
	detail.add_child(UIKit.spacer(4))
	detail.add_child(UIKit.label("Suspects", 24, UIKit.MUTED))
	for s in c.suspects:
		var out := not Casebook.open_suspects(d, c).any(func(o): return str(o.id) == str(s.id))
		_words(detail, "%s%s" % [str(s.name), " (ruled out)" if out else ""], 21, UIKit.MUTED if out else UIKit.CREAM)
