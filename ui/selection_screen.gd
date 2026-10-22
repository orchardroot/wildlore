extends MenuBase
## The moor model (SelectionSim): a population on its backdrop, a kestrel's share taken each step, and the dark share
## drawn over time underneath. Step, Run, switch scenario, change the winters. Opened from Dr Keir's bench and the
## Almanac's Biology page. Watching for a while opens Biology pages (flags bio_sim_watched, bio_sim_manchester).
## setup("manchester") starts on Manchester; "manchester:1900" or "moor:12" runs that far first (screenshots).

const PALE_MOOR := Color("e9eef2")     # snow
const DARK_MOOR := Color("5a3f4f")     # heather and peat
const PALE_TOWN := Color("c9cfae")     # lichen on bark
const DARK_TOWN := Color("2e2b29")     # soot
const DARK_ONE := Color("2a211d")
const PALE_ONE := Color("efe6d2")
const WATCHED_AFTER := 8

var sim: SelectionSim
var _field: Control
var _chart: Control
var _head: Label
var _sub: Label
var _note: Label
var _run_btn: Button
var _scen_btn: Button
var _clim_btn: Button
var _running := false
var _acc := 0.0
var _steps_seen := 0
var _backs: Array = []     # backdrop darkness per step, for the chart's strip
var _spots: Array = []     # where each shown creature sits, 0..1 in the field

func _build() -> void:
	set_title("The moor model")
	set_hints([["confirm", "Choose"], ["cancel", "Back"]])
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 6)
	content.add_child(col)
	_head = UIKit.label("", 24, UIKit.GOLD)
	col.add_child(_head)
	_sub = UIKit.label("", 19, UIKit.CREAM)
	col.add_child(_sub)
	_field = Control.new()
	_field.custom_minimum_size = Vector2(0, 190)
	_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_field.draw.connect(_draw_field)
	col.add_child(_field)
	col.add_child(UIKit.label("The gold line is the dark share over time; the strip beneath it is the backdrop.", 17, UIKit.MUTED))
	_chart = Control.new()
	_chart.custom_minimum_size = Vector2(0, 90)
	_chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chart.draw.connect(_draw_chart)
	col.add_child(_chart)
	_note = UIKit.label("", 18, UIKit.MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_note)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	col.add_child(bar)
	var step := make_button("Step", _step_once, 120)
	_run_btn = make_button("Run", _toggle_run, 120)
	_scen_btn = make_button("", _switch, 230)
	_clim_btn = make_button("", _climate, 230)
	var reset := make_button("Reset", func(): _reset(sim.scenario, sim.climate), 120)
	var back := make_button("Back", func(): close(null), 120)
	for b in [step, _run_btn, _scen_btn, _clim_btn, reset, back]:
		b.add_theme_font_size_override("font_size", 22)
		UIKit.compact(b, 2)
		bar.add_child(b)
	var rng := Rng.new(45)
	for i in SelectionSim.SHOWN:
		var cx := (i % 15 + 0.5) / 15.0 + rng.roll_range(-0.022, 0.022)
		var cy := (int(i / 15.0) + 0.5) / 4.0 + rng.roll_range(-0.06, 0.06)
		_spots.append(Vector2(cx, cy))
	_reset("moor", "snowy")
	UIKit.focus_later(step)

func setup(arg: String) -> void:
	var parts := arg.split(":")
	if parts.size() > 0 and SelectionSim.SCENARIOS.has(parts[0]):
		_reset(parts[0], "snowy")
		if parts.size() > 1:
			var target := int(parts[1])
			for i in 400:
				if (sim.scenario == "manchester" and sim.year() >= target) or (sim.scenario == "moor" and sim.t >= target) or sim.finished():
					break
				_advance()
			_refresh()

func _reset(scenario: String, climate: String) -> void:
	sim = SelectionSim.new(scenario, int(Time.get_ticks_usec() % 100000) if not Engine.has_meta("autopilot") else 1, climate)
	_backs = [float(sim.backdrop().dark)]
	_running = false
	_refresh()

func _advance() -> void:
	sim.step()
	_backs.append(float(sim.backdrop().dark))
	_steps_seen += 1
	if _steps_seen >= WATCHED_AFTER:
		Game.data.set_flag("bio_sim_watched", true)
	if sim.scenario == "manchester" and sim.year() >= 1960:
		Game.data.set_flag("bio_sim_manchester", true)

func _step_once() -> void:
	if sim.finished():
		return
	_advance()
	_refresh()

func _toggle_run() -> void:
	_running = not _running and not sim.finished()
	_refresh()

func _switch() -> void:
	_reset("manchester" if sim.scenario == "moor" else "moor", sim.climate)

func _climate() -> void:
	if sim.scenario != "moor":
		return
	_reset("moor", "mild" if sim.climate == "snowy" else "snowy")

func _process(delta: float) -> void:
	if not _running:
		return
	_acc += delta
	var every := 0.12 if sim.scenario == "manchester" else 0.45
	if _acc < every:
		return
	_acc = 0.0
	_advance()
	if sim.finished():
		_running = false
	_refresh()

func _when() -> String:
	if sim.scenario == "manchester":
		return str(sim.year())
	return "Year %d, %s" % [sim.year() + 1, str(sim.backdrop().season)]

func _refresh() -> void:
	var b := sim.backdrop()
	var dark := roundi(sim.dark_fraction() * 100.0)
	_head.text = "%s   %s   Dark: %d%%   Pale: %d%%" % [SelectionSim.SCENARIOS[sim.scenario].name, _when(), dark, 100 - dark]
	var eaten := ""
	if sim.t > 0:
		eaten = "   Last %s the kestrels took %d dark and %d pale." % ["year" if sim.scenario == "manchester" else "season", sim.last_eaten.dark, sim.last_eaten.pale]
	_sub.text = str(b.text) + "." + eaten
	_run_btn.text = "Pause" if _running else "Run"
	_scen_btn.text = "Try Manchester" if sim.scenario == "moor" else "Back to the moor"
	_clim_btn.text = ("Snowy winters" if sim.climate == "snowy" else "Mild winters") if sim.scenario == "moor" else "(fixed history)"
	_clim_btn.disabled = sim.scenario != "moor"
	if sim.scenario == "moor":
		_note.text = "A toy model, not a real study. Dark is dominant, so pale young can come from two dark parents. Change the winters and watch the balance tip."
	else:
		_note.text = "The shape is history's, the numbers are the model's. A few moths fly in from the cleaner countryside each year, which is why the pale form never quite vanishes."
	if sim.finished():
		_note.text = "2000. The pale form is back. " + _note.text
	_field.queue_redraw()
	_chart.queue_redraw()

func _back_colour(darkness: float) -> Color:
	if sim.scenario == "manchester":
		return PALE_TOWN.lerp(DARK_TOWN, clampf(darkness / 0.9, 0.0, 1.0))
	return PALE_MOOR.lerp(DARK_MOOR, darkness)

func _draw_field() -> void:
	var sz := _field.size
	_field.draw_rect(Rect2(Vector2.ZERO, sz), _back_colour(float(sim.backdrop().dark)))
	var shown := sim.sample()
	var moth := sim.scenario == "manchester"
	for i in shown.size():
		var p: Vector2 = _spots[i] * sz
		var c := DARK_ONE if shown[i] else PALE_ONE
		if moth:
			_field.draw_colored_polygon(PackedVector2Array([p, p + Vector2(-16, -9), p + Vector2(-13, 9)]), c)
			_field.draw_colored_polygon(PackedVector2Array([p, p + Vector2(16, -9), p + Vector2(13, 9)]), c)
			_field.draw_line(p + Vector2(0, -6), p + Vector2(0, 7), c.darkened(0.3), 2.0)
		else:
			_field.draw_circle(p, 9.0, c)
			_field.draw_circle(p + Vector2(8, -6), 5.5, c)
			_field.draw_line(p + Vector2(8, -10), p + Vector2(6, -20), c, 3.0)
			_field.draw_line(p + Vector2(11, -10), p + Vector2(12, -20), c, 3.0)

func _draw_chart() -> void:
	var sz := _chart.size
	_chart.draw_rect(Rect2(Vector2.ZERO, sz), Color("161a26"))
	var n := maxi(sim.history.size(), 2)
	var span := 160.0 if sim.scenario == "manchester" else maxf(40.0, n)
	var w := sz.x / span
	for i in _backs.size():
		_chart.draw_rect(Rect2(i * w, sz.y - 8, ceilf(w), 8), _back_colour(float(_backs[i])))
	var pts := PackedVector2Array()
	for i in sim.history.size():
		pts.append(Vector2(i * w, (sz.y - 12) * (1.0 - float(sim.history[i])) + 2))
	_chart.draw_line(Vector2(0, (sz.y - 12) * 0.5 + 2), Vector2(sz.x, (sz.y - 12) * 0.5 + 2), Color(1, 1, 1, 0.12), 1.0)
	if pts.size() >= 2:
		_chart.draw_polyline(pts, UIKit.GOLD, 2.5)
