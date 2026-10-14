class_name BattleHUD
extends Control
## The two name plates: name, level, status chip, animated HP bar (green, amber, red), and the player's XP bar.
## Double battles get four compact plates (set_double); the per-plate calls then take a field position.

const CREAM := Color("f2e8cf")
const GREEN := Color("5fcf6a")
const AMBER := Color("f0b840")
const RED := Color("e0524a")
const STATUS_COLOURS := {
	"soaked": Color("3f86c4"), "chilled": Color("6fb8cc"), "muddled": Color("c46fa0"),
	"hexed": Color("7e56b8"), "stung": Color("a3b52f"), "asleep": Color("6f84ad"),
}

## Flat bar drawn in code so the colour can follow the value as it drains.
class Bar extends Control:
	var value := 1.0
	var colour_by_value := true
	var fill := Color("7aa7ff")
	func _init(h := 14.0) -> void:
		custom_minimum_size = Vector2(0, h)
	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("0d0f15"))
		var v := clampf(value, 0.0, 1.0)
		var c := fill
		if colour_by_value:
			c = BattleHUD.GREEN if v > 0.5 else (BattleHUD.AMBER if v > 0.2 else BattleHUD.RED)
		if v > 0.0:
			var w := maxf(2.0, (size.x - 4.0) * v)
			draw_rect(Rect2(2, 2, w, size.y - 4), c)
			draw_rect(Rect2(2, 2, w, (size.y - 4) * 0.4), c.lightened(0.25))
		draw_rect(r, BattleHUD.CREAM, false, 2.0)

class Plate extends PanelContainer:
	var creature: Creature
	var is_player := false
	var name_l: Label
	var level_l: Label
	var chip: Label
	var hp_bar: Bar
	var hp_text: Label
	var xp_bar: Bar
	var hp_shown := 1.0
	var hp_max := 1.0
	var xp_shown := 0.0
	var _hp_tween: Tween
	var _xp_tween: Tween
	var _sb: StyleBoxFlat
	var _border: Color
	var _border_w := 2

	func build(player: bool, compact := false) -> void:
		is_player = player
		var k := 0.72 if compact else 1.0  # compact plates for doubles: smaller type, tighter padding
		var sb: StyleBoxFlat = (load("res://ui/theme.tres") as Theme).get_stylebox("panel", "PanelContainer").duplicate()
		_sb = sb
		_border = sb.border_color
		_border_w = sb.border_width_top
		sb.set_content_margin_all(8 if compact else 12)
		sb.shadow_color = Color(0, 0, 0, 0.35)
		sb.shadow_size = 6
		sb.shadow_offset = Vector2(0, 3)
		add_theme_stylebox_override("panel", sb)
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2 if compact else 5)
		add_child(col)
		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 10)
		col.add_child(top)
		name_l = Label.new()
		name_l.add_theme_font_size_override("font_size", int(28 * k))
		name_l.clip_text = compact
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(name_l)
		chip = Label.new()
		chip.add_theme_font_size_override("font_size", int(16 * k))
		chip.visible = false
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		top.add_child(chip)
		level_l = Label.new()
		level_l.add_theme_font_size_override("font_size", int(24 * k))
		top.add_child(level_l)
		var hp_row := HBoxContainer.new()
		hp_row.add_theme_constant_override("separation", 8)
		col.add_child(hp_row)
		var tag := Label.new()
		tag.text = "HP"
		tag.add_theme_font_size_override("font_size", int(18 * k))
		tag.modulate = Color("e8c46a")
		hp_row.add_child(tag)
		hp_bar = Bar.new(12 if compact else 16)
		hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hp_row.add_child(hp_bar)
		if player:
			hp_text = Label.new()
			hp_text.add_theme_font_size_override("font_size", int(22 * k))
			hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			col.add_child(hp_text)
			var xp_row := HBoxContainer.new()
			col.add_child(xp_row)
			var xt := Label.new()
			xt.text = "XP"
			xt.add_theme_font_size_override("font_size", int(16 * k))
			xt.modulate = Color("9ab6ff")
			xp_row.add_child(xt)
			xp_bar = Bar.new(6 if compact else 8)
			xp_bar.colour_by_value = false
			xp_bar.fill = Color("7aa7ff")
			xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			xp_row.add_child(xp_bar)

	## Picked as a target: a bright border.
	func set_marked(on: bool) -> void:
		_sb.border_color = Color("ffc52e") if on else _border
		_sb.set_border_width_all(4 if on else _border_w)
		queue_redraw()

	func set_creature(c: Creature) -> void:
		creature = c
		name_l.text = c.display_name()
		level_l.text = "Lv %d" % c.level
		hp_max = float(c.max_hp())
		hp_shown = float(c.hp)
		_sync_hp()
		set_status(c.status)
		if is_player:
			xp_shown = xp_fraction(c)
			xp_bar.value = xp_shown

	func refresh_names() -> void:
		if creature != null:
			name_l.text = creature.display_name()
			level_l.text = "Lv %d" % creature.level

	func refresh_stats() -> void:
		if creature == null:
			return
		level_l.text = "Lv %d" % creature.level
		hp_max = float(creature.max_hp())
		_sync_hp()

	func _sync_hp() -> void:
		hp_bar.value = hp_shown / maxf(1.0, hp_max)
		hp_bar.queue_redraw()
		if hp_text:
			hp_text.text = "%d / %d" % [int(ceil(hp_shown)), int(hp_max)]

	func tween_hp(to: float, dur: float) -> void:
		if _hp_tween and _hp_tween.is_valid():
			_hp_tween.kill()
		_hp_tween = create_tween()
		_hp_tween.tween_method(func(v: float):
			hp_shown = v
			_sync_hp(), hp_shown, to, dur)

	func set_status(s: String) -> void:
		chip.visible = s != ""
		if s == "":
			return
		chip.text = " %s " % s.to_upper()
		var sb := StyleBoxFlat.new()
		sb.bg_color = BattleHUD.STATUS_COLOURS.get(s, Color("777777"))
		sb.set_corner_radius_all(4)
		sb.set_content_margin_all(2)
		chip.add_theme_stylebox_override("normal", sb)
		chip.add_theme_color_override("font_color", Color("14161c"))
		chip.add_theme_constant_override("shadow_offset_x", 0)
		chip.add_theme_constant_override("shadow_offset_y", 0)

	static func xp_fraction(c: Creature) -> float:
		var lo := Rules.xp_for_level(c.species.growth, c.level)
		var hi := Rules.xp_for_level(c.species.growth, c.level + 1)
		return clampf(float(c.xp - lo) / maxf(1.0, float(hi - lo)), 0.0, 1.0) if c.level < Rules.MAX_LEVEL else 1.0

	func tween_xp(to: float, dur: float) -> void:
		if _xp_tween and _xp_tween.is_valid():
			_xp_tween.kill()
		_xp_tween = create_tween()
		_xp_tween.tween_method(func(v: float):
			xp_shown = v
			xp_bar.value = v
			xp_bar.queue_redraw(), xp_shown, to, dur)
		await _xp_tween.finished

var plates: Array = []  # position 0 plate per side (the only ones in singles)
var extra_plates: Array = []  # doubles: position 1 plate per side
var double := false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in 2:
		var p := Plate.new()
		p.build(side == Battle.PLAYER)
		add_child(p)
		plates.append(p)
		p.visible = false
	plates[Battle.FOE].position = Vector2(40, 40)
	plates[Battle.FOE].custom_minimum_size = Vector2(430, 0)
	plates[Battle.PLAYER].position = Vector2(790, 372)
	plates[Battle.PLAYER].custom_minimum_size = Vector2(450, 0)

## Four compact plates: the foes' pair along the top left, the player's pair above the message box on the right,
## each pair in field order (position 0 on the left, as on the diorama).
func set_double(on: bool) -> void:
	if not on or double:
		return
	double = true
	for p in plates:
		p.queue_free()
	plates = []
	for row in [plates, extra_plates]:
		for side in 2:
			var p := Plate.new()
			p.build(side == Battle.PLAYER, true)
			add_child(p)
			row.append(p)
			p.visible = false
	plates[Battle.FOE].position = Vector2(24, 20)
	extra_plates[Battle.FOE].position = Vector2(366, 20)
	plates[Battle.PLAYER].position = Vector2(568, 424)
	extra_plates[Battle.PLAYER].position = Vector2(918, 424)
	for side in 2:
		for p in [plates[side], extra_plates[side]]:
			p.custom_minimum_size = Vector2(338 if side == Battle.PLAYER else 330, 0)

func plate(side: int, pos := 0) -> Plate:
	return extra_plates[side] if pos == 1 and double else plates[side]

## Every player plate in use.
func player_plates() -> Array:
	return [plates[Battle.PLAYER]] + ([extra_plates[Battle.PLAYER]] if double else [])

func refresh_names() -> void:
	for p in player_plates():
		p.refresh_names()

func set_creature(side: int, c: Creature, pos := 0) -> void:
	var p := plate(side, pos)
	p.set_creature(c)
	if not p.visible:
		p.visible = true
		var from := Vector2(-480, 0) if side == Battle.FOE else Vector2(520, 0)
		var home := p.position
		p.position = home + from
		create_tween().tween_property(p, "position", home, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func tween_hp(side: int, hp: int, dur: float, pos := 0) -> void:
	plate(side, pos).tween_hp(float(hp), dur)

func shown_hp(side: int, pos := 0) -> float:
	return plate(side, pos).hp_shown

func max_hp(side: int, pos := 0) -> float:
	return plate(side, pos).hp_max

func set_status(side: int, s: String, pos := 0) -> void:
	plate(side, pos).set_status(s)

func set_marked(side: int, pos: int, on: bool) -> void:
	plate(side, pos).set_marked(on)

func _player_plate_of(c: Creature) -> Plate:
	for p in player_plates():
		if p.creature == c:
			return p
	return null

func set_xp_instant(c: Creature) -> void:
	var p := _player_plate_of(c)
	if p == null:
		p = plates[Battle.PLAYER]
	p.xp_shown = Plate.xp_fraction(c)
	p.xp_bar.value = p.xp_shown

## Fill towards the new XP, wrapping once per level gained.
func animate_xp(c: Creature, level_events: Array) -> void:
	var p := _player_plate_of(c)
	if p == null:
		return
	var gained := level_events.filter(func(e): return e.type == "level_up").size()
	for i in gained:
		await p.tween_xp(1.0, 0.45)
		p.level_l.text = "Lv %d" % (c.level - gained + i + 1)
		p.xp_shown = 0.0
		p.xp_bar.value = 0.0
	p.refresh_stats()
	p.tween_hp(float(c.hp), 0.4)
	await p.tween_xp(Plate.xp_fraction(c), 0.6)
