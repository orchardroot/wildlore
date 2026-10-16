extends MenuBase
## Save or load: the autosave plus three manual slots. setup("save") or setup("load").
## Closes with the slot id that was saved or loaded, or null.

var mode := "save"
var _list: VBoxContainer
var _note: Label
var _confirm_slot := ""

func _build() -> void:
	set_hints([["confirm", "Choose"], ["cancel", "Back"]])
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 14)
	content.add_child(col)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	col.add_child(_list)
	_note = UIKit.label("", 26, UIKit.GOLD)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_note)

func setup(arg: String) -> void:
	mode = "load" if arg == "load" else "save"
	set_title("Load a journey" if mode == "load" else "Save your journey")
	_refresh()

func _refresh() -> void:
	UIKit.clear(_list)
	var buttons := []
	for info in SaveSystem.slot_infos(Game.save_dir):
		if mode == "save" and info.slot == "auto":
			continue  # the autosave slot is the game's, not the player's
		var b := make_button(_slot_text(info), _choose.bind(info))
		b.custom_minimum_size = Vector2(0, 96)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 28)
		b.disabled = mode == "load" and not info.ok
		_list.add_child(b)
		buttons.append(b)
	UIKit.wrap_focus(buttons)
	for b in buttons:
		if not b.disabled:
			UIKit.focus_later(b)
			break

static func slot_title(slot: String) -> String:
	return "Autosave" if slot == "auto" else "Slot " + slot

## One line per slot: "Slot 2   Buxton   1 Stone   2:14" or "Empty" or "Damaged".
static func _slot_text(info: Dictionary) -> String:
	var head := slot_title(str(info.slot))
	if not info.exists:
		return "  %s      Empty" % head
	if not info.ok:
		return "  %s      Damaged (can't be read)" % head
	var zname := str(info.zone_id)
	if Game.zone_exists(zname):
		zname = ZoneData.load_id(zname).name
	var stones := "%d Stone%s" % [info.badges, "" if info.badges == 1 else "s"]
	return "  %s      %s      %s      %s      %s" % [head, info.player_name, zname, stones, MenuLogic.play_time(info.play_seconds)]

func _choose(info: Dictionary) -> void:
	if mode == "load":
		if Game.load_slot(str(info.slot)):
			close(str(info.slot))
		else:
			_note.text = "That save couldn't be read."
		return
	if info.ok and _confirm_slot != str(info.slot):
		_confirm_slot = str(info.slot)
		_note.text = "%s already holds a journey. Press again to save over it." % slot_title(_confirm_slot)
		return
	var err := Game.save(str(info.slot))
	_confirm_slot = ""
	_note.text = "Saved to %s. Safe as houses." % slot_title(str(info.slot)) if err == OK else "That didn't save. Check the disk has room."
	Audio.sfx("heal" if err == OK else "bump")
	_refresh()
