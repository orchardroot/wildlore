extends MenuBase
## The Economist's notebook (an Almanac page): every idea down the left, ideas first and then the history, each
## one blank until you have met it in play; the right shows what the page says, how you met it, and sums worked
## from the game's own numbers. See Economist.

const ROW_H := 30

var _detail: VBoxContainer
var _buttons: Array = []
var _ids: Array = []

func _build() -> void:
	set_title("Economist's notebook")
	header_right.text = "%d of %d ideas met" % [Economist.count(Game.data), Economist.total()]
	set_hints([["updown", "Choose"], ["cancel", "Back"]])
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 18)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 12)
	lp.custom_minimum_size = Vector2(400, 0)
	row.add_child(lp)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 1)
	lp.add_child(list)
	var kind := ""
	for i in Economist.ideas():
		if str(i.get("kind", "idea")) != kind:
			kind = str(i.get("kind", "idea"))
			list.add_child(UIKit.label("Ideas" if kind == "idea" else "History", 18, UIKit.MUTED))
		var id := str(i.id)
		var known := Economist.met(Game.data, id)
		var b := make_button(str(i.title) if known else "? " + str(i.title), func(): pass)
		b.custom_minimum_size = Vector2(370, ROW_H)
		b.add_theme_font_size_override("font_size", 19)
		if not known:
			b.add_theme_color_override("font_color", UIKit.MUTED)
		UIKit.compact(b, 1)
		b.focus_entered.connect(_show.bind(id))
		list.add_child(b)
		_buttons.append(b)
		_ids.append(id)
	var rp := UIKit.panel(Color("1d2230f0"), 18)
	rp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rp)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 10)
	rp.add_child(_detail)
	UIKit.wrap_focus(_buttons)
	if not _buttons.is_empty():
		var first := 0
		for k in _ids.size():
			if Economist.met(Game.data, str(_ids[k])):
				first = k
				break
		UIKit.focus_later(_buttons[first])
		_show(str(_ids[first]))

## "economist:<idea id>" opens on that idea (for screenshots).
func setup(arg: String) -> void:
	var k := _ids.find(arg)
	if k >= 0:
		UIKit.focus_later(_buttons[k])
		_show(arg)

func _show(id: String) -> void:
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	var i := Economist.idea(id)
	_detail.add_child(UIKit.label(str(i.get("title", "")), 30, UIKit.GOLD))
	if not Economist.met(Game.data, id):
		var how := UIKit.label("Not met yet. " + str(i.get("how", "")), 21, UIKit.MUTED)
		how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_detail.add_child(how)
		return
	var lines := Economist.lines(Game.data, id)
	var fs := 20 if lines.size() <= 5 else 18
	for line in lines:
		var l := UIKit.label(str(line), fs, UIKit.CREAM)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 640
		_detail.add_child(l)

func _on_cancel() -> void:
	close(null)
