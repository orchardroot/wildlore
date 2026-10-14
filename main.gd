extends Control
## Boot screen placeholder until the title screen lands in plan 2.

func _ready() -> void:
	var label := Label.new()
	label.text = "Wildlore  v%s" % ProjectSettings.get_setting("application/config/version")
	label.add_theme_font_size_override("font_size", 64)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
