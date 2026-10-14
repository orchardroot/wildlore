extends Control
## Title screen: Continue, New Game, Settings, Quit. Also checks the game data made it into the build.

var _menu: VBoxContainer

func _ready() -> void:
	theme = load("res://ui/theme.tres")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var sky := TextureRect.new()
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.texture = _sky_gradient()
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(sky)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centre)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 24)
	centre.add_child(col)
	var logo := Label.new()
	logo.text = "WILDLORE"
	logo.add_theme_font_size_override("font_size", 120)
	logo.add_theme_constant_override("shadow_offset_x", 6)
	logo.add_theme_constant_override("shadow_offset_y", 6)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(logo)
	var sub := Label.new()
	sub.text = _subtitle()
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = Color(1, 1, 1, 0.8)
	col.add_child(sub)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(panel)
	_menu = VBoxContainer.new()
	panel.add_child(_menu)
	if Game.has_save("auto"):
		_add("Continue", _on_continue)
	_add("New Game", _on_new)
	_add("Settings", _on_settings)
	_add("Quit", func(): get_tree().quit())
	_menu.get_child(0).grab_focus()
	Audio.play_music("title")

func _add(text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 0)
	b.pressed.connect(cb)
	b.focus_entered.connect(func(): Audio.sfx("cursor"))
	_menu.add_child(b)

func _subtitle() -> String:
	if Game.chart.types.is_empty() or Game.dex.ids().is_empty() or Game.moves.ids().is_empty():
		return "Game data missing from this build"
	return "v%s  ·  %d creatures so far" % [ProjectSettings.get_setting("application/config/version"), Game.dex.ids().size()]

func _on_continue() -> void:
	Audio.sfx("confirm")
	if Game.load_slot("auto"):
		Router.goto_zone(Game.data.zone_id, Game.data.pos, Game.data.facing)

func _on_new() -> void:
	Audio.sfx("confirm")
	Game.new_game()
	Router.goto_zone(Game.data.zone_id, Vector2i(-1, -1), "down")

func _on_settings() -> void:
	Audio.sfx("confirm")
	await Router.open_menu("settings")
	_menu.get_child(0).grab_focus()

func _sky_gradient() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color("3b4f7a"))
	g.set_color(1, Color("e8b77c"))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	return tex
