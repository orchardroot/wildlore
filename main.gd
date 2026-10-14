extends Control
## Boot screen placeholder until the title screen lands in plan 2.
## Also proves the JSON data made it into this build.

func _ready() -> void:
	var label := Label.new()
	var chart := TypeChart.load_default()
	var dex := Dex.load_default()
	if chart.types.is_empty() or dex.ids().is_empty():
		label.text = "Wildlore: game data missing from this build"
	else:
		label.text = "Wildlore  v%s\n%d types, %d creatures" % [ProjectSettings.get_setting("application/config/version"), chart.types.size(), dex.ids().size()]
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
	print(label.text.replace("\n", " | "))
