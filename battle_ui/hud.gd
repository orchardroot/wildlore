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
			var band := "green" if v > 0.5 else ("amber" if v > 0.2 else "red")
			c = TypeColours.HP_SAFE[band] if TypeColours.is_colour_blind() else {"green": BattleHUD.GREEN, "amber": BattleHUD.AMBER, "red": BattleHUD.RED}[band]
		if v > 0.0:
			var w := maxf(2.0, (size.x - 4.0) * v)
			draw_rect(Rect2(2, 2, w, size.y - 4), c)
			draw_rect(Rect2(2, 2, w, (size.y - 4) * 0.4), c.lightened(0.25))
		draw_rect(r, BattleHUD.CREAM, false, 2.0)

## A tiny woven snare: shown on a wild foe's plate when that species is already in the collection.
class CaughtMark extends Control:
	func _init(px := 20.0) -> void:
		custom_minimum_size = Vector2(px, px)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tooltip_text = "Already caught"
	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.5 - 1.5
		draw_circle(c, r, Color("e8c46a"))
		draw_circle(c, r * 0.62, Color("8a5a2b"))
		draw_line(c - Vector2(r, 0), c + Vector2(r, 0), Color("14161c"), 2.0)
		draw_circle(c, r * 0.28, BattleHUD.CREAM)
		draw_arc(c, r, 0.0, TAU, 20, Color("14161c"), 1.5, true)

## The weather glyph on the weather plate, drawn in code: sun, rain cloud, fog bands, frost star, gale streaks.
class WeatherIcon extends Control:
	var kind := "clear"
	func _init() -> void:
		custom_minimum_size = Vector2(40, 40)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
	func _draw() -> void:
		var c := size * 0.5
		match kind:
			"sunshine":
				var sun := Color("ffd257")
				draw_circle(c, 9.0, sun)
				for i in 8:
					var d := Vector2.from_angle(TAU * i / 8.0)
					draw_line(c + d * 12.5, c + d * 17.0, sun, 3.0, true)
			"drizzle", "downpour":
				_cloud(c + Vector2(0, -5), Color("d5dde7"))
				var n := 3 if kind == "drizzle" else 5
				var drop := 5.0 if kind == "drizzle" else 10.0
				for i in n:
					var x := c.x - 10.0 + i * 20.0 / (n - 1)
					draw_line(Vector2(x + 1.5, c.y + 6), Vector2(x - 1.5, c.y + 6 + drop), Color("86bff2"), 2.5, true)
			"fog":
				for i in 4:
					var y := c.y - 10.0 + i * 6.5
					var inset := 5.0 if i % 2 == 0 else 10.0
					draw_line(Vector2(inset, y), Vector2(size.x - inset, y), Color("cdd4da"), 3.5, true)
			"frost":
				var ice := Color("c4eef8")
				for i in 3:
					var d := Vector2.from_angle(PI * i / 3.0 + PI / 2.0) * 15.0
					draw_line(c - d, c + d, ice, 3.0, true)
					for s in [-1.0, 1.0]:  # little barbs near each tip
						var tip: Vector2 = c + d * 0.62 * s
						draw_line(tip, tip + d.rotated(2.4 * s).normalized() * 5.0 * s, ice, 2.0, true)
				draw_circle(c, 3.0, ice)
			"gale":
				var wind := Color("e2eaf0")
				var widths := [24.0, 30.0, 18.0]
				for i in 3:
					var y := c.y - 9.0 + i * 9.0
					var x0 := c.x - 16.0 + (4.0 if i == 1 else 0.0)
					var x1: float = x0 + widths[i]
					draw_line(Vector2(x0, y), Vector2(x1, y), wind, 3.0, true)
					draw_arc(Vector2(x1, y - 3.5), 3.5, PI / 2.0, -PI / 2.0 - 0.3, 8, wind, 3.0, true)
	func _cloud(c: Vector2, col: Color) -> void:
		draw_circle(c + Vector2(-8, 3), 6.5, col)
		draw_circle(c + Vector2(0, -2), 9.0, col)
		draw_circle(c + Vector2(9, 3), 6.5, col)
		draw_rect(Rect2(c.x - 14, c.y + 2, 28, 7.5), col)

## A row of pips: how many turns a called-up weather has left.
class TurnPips extends Control:
	var total := 5
	var left := 0
	func _init() -> void:
		custom_minimum_size = Vector2(8 * 13, 12)
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
	func _draw() -> void:
		for i in total:
			var p := Vector2(6 + i * 13, size.y * 0.5)
			if i < left:
				draw_circle(p, 4.5, Color("ffc52e"))
			else:
				draw_arc(p, 4.0, 0, TAU, 14, Color(BattleHUD.CREAM, 0.45), 1.5, true)

## The weather plate, top right: what the sky is doing and, for a weather a move called up, how long it lasts.
class WeatherPlate extends PanelContainer:
	var icon: WeatherIcon
	var name_l: Label
	var sub_l: Label
	var pips: TurnPips
	var _shown := ""
	func build() -> void:
		var sb: StyleBoxFlat = (load("res://ui/theme.tres") as Theme).get_stylebox("panel", "PanelContainer").duplicate()
		sb.set_content_margin_all(10)
		sb.content_margin_left = 12
		sb.content_margin_right = 16
		sb.shadow_color = Color(0, 0, 0, 0.35)
		sb.shadow_size = 6
		sb.shadow_offset = Vector2(0, 3)
		add_theme_stylebox_override("panel", sb)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		add_child(row)
		icon = WeatherIcon.new()
		row.add_child(icon)
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(col)
		name_l = Label.new()
		name_l.add_theme_font_size_override("font_size", 22)
		col.add_child(name_l)
		var sub := HBoxContainer.new()
		sub.add_theme_constant_override("separation", 6)
		col.add_child(sub)
		pips = TurnPips.new()
		sub.add_child(pips)
		sub_l = Label.new()
		sub_l.add_theme_font_size_override("font_size", 16)
		sub_l.modulate = Color("e8c46a")
		sub.add_child(sub_l)
	func show_weather(w: String, turns: int) -> void:
		var key := "%s/%d" % [w, turns]
		if key == _shown:
			return
		if w != icon.kind or turns > pips.left:  # a fresh weather: the row is as long as it will last
			pips.total = maxi(5, turns)
		_shown = key
		visible = w != "clear"
		icon.kind = w
		icon.queue_redraw()
		name_l.text = MoveFX.weather_label(w)
		pips.visible = turns > 0
		pips.left = turns
		pips.custom_minimum_size.x = pips.total * 13
		pips.queue_redraw()
		sub_l.text = ("%d turn left" if turns == 1 else "%d turns left") % turns if turns > 0 else "Today's weather"
		reset_size()

class Plate extends PanelContainer:
	var creature: Creature
	var is_player := false
	var name_l: Label
	var level_l: Label
	var chip: Label
	var caught: CaughtMark
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
		caught = CaughtMark.new(20.0 * k)
		caught.visible = false
		top.add_child(caught)
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
	weather_plate = WeatherPlate.new()
	weather_plate.build()
	weather_plate.visible = false
	add_child(weather_plate)
	resized.connect(_place_weather)

var weather_plate: WeatherPlate

## The weather plate: hidden under clear skies; a called-up weather shows its turns left.
func set_weather(w: String, turns: int) -> void:
	weather_plate.show_weather(w, turns)
	_place_weather()

## Top right, 24px in from the edge of the screen (wider screens included).
func _place_weather() -> void:
	weather_plate.reset_size()
	var w := size.x if size.x > 0.0 else 1280.0
	weather_plate.position = Vector2(w - weather_plate.size.x - 24.0, 20.0)

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

func set_caught(side: int, on: bool, pos := 0) -> void:
	plate(side, pos).caught.visible = on

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
