extends MenuBase
## A bureau de change: today's pound to euro rate, the last fortnight on a chart, and a counter to change money
## either way at the bureau's spread (see Forex). Opened as "bureau" from the counters at Holyhead, Dublin port,
## Belfast and every Irish Sanctuary.

const DAYS := 14
const UP := Color("8fd18a")
const DOWN := Color("e9998c")

var _mode := "root"     # root | qty
var _from := "gbp"      # the purse being changed
var _amount := 0
var _mid := 1.175
var _buttons: Array = []
var _rate_big: Label
var _rate_move: Label
var _buy_line: Label
var _sell_line: Label
var _tourist_line: Label
var _news: Label
var _chart: PriceChart
var _qty_panel: PanelContainer
var _qty_label: Label
var _get_label: Label
var _say: Label

func _build() -> void:
	set_title("Bureau de Change")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 18)
	lp.custom_minimum_size = Vector2(600, 0)
	row.add_child(lp)
	var lc := VBoxContainer.new()
	lc.add_theme_constant_override("separation", 6)
	lp.add_child(lc)
	lc.add_child(UIKit.label("One pound buys", 22, UIKit.MUTED))
	var big := HBoxContainer.new()
	big.add_theme_constant_override("separation", 16)
	_rate_big = UIKit.label("", 46, UIKit.CREAM)
	big.add_child(_rate_big)
	_rate_move = UIKit.label("", 24, UP)
	_rate_move.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	big.add_child(_rate_move)
	lc.add_child(big)
	_buy_line = UIKit.label("", 22)
	lc.add_child(_buy_line)
	_sell_line = UIKit.label("", 22)
	lc.add_child(_sell_line)
	_tourist_line = UIKit.label("", 20, UIKit.MUTED)
	lc.add_child(_tourist_line)
	lc.add_child(UIKit.spacer(4))
	_chart = PriceChart.new()
	_chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chart.line_colour = UIKit.GOLD
	lc.add_child(_chart)
	_news = UIKit.label("", 20, UIKit.GOLD)
	_news.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lc.add_child(_news)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	row.add_child(right)
	var bp := UIKit.panel(Color("1d2230f0"), 10)
	right.add_child(bp)
	var bc := VBoxContainer.new()
	bp.add_child(bc)
	for e in [["Pounds into euros", func(): _open_qty("gbp")], ["Euros into pounds", func(): _open_qty("eur")], ["Leave", func(): close(null)]]:
		var b := make_button(e[0], e[1])
		b.add_theme_font_size_override("font_size", 30)
		bc.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	_qty_panel = UIKit.panel(Color("2c3446f8"), 14)
	_qty_panel.visible = false
	var qv := VBoxContainer.new()
	_qty_panel.add_child(qv)
	_qty_label = UIKit.label("", 34)
	qv.add_child(_qty_label)
	_get_label = UIKit.label("", 26, UIKit.GOLD)
	qv.add_child(_get_label)
	qv.add_child(UIKit.label("Up / Down  10      Left / Right  100", 20, UIKit.MUTED))
	right.add_child(_qty_panel)
	right.add_child(UIKit.fill())
	_say = UIKit.label("", 24, UIKit.GOLD)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_say)
	_refresh()
	_say.text = "Rates change daily. Commission? Built into the rate, love. Like everyone else."
	UIKit.focus_later(_buttons[0])
	_set_hint()

func _refresh() -> void:
	var d: GameStateData = Game.data
	Markets.sync(d)
	var ev := Markets.events_of(d)
	_mid = Forex.mid_for(d)
	_rate_big.text = "€%.4f" % _mid
	var y := Forex.mid(d.rng_seed, maxi(0, d.day_count - 1), ev)
	var mv := (_mid / y - 1.0) * 100.0 if d.day_count > 0 else 0.0
	_rate_move.text = "%s%.2f%% today" % ["+" if mv >= 0.0 else "", mv]
	_rate_move.add_theme_color_override("font_color", UP if mv >= 0.0 else DOWN)
	_buy_line.text = "We buy your pounds at €%.3f each" % Forex.bureau_buy_eur(_mid)
	_sell_line.text = "We sell you pounds at €%.3f each" % Forex.bureau_sell_eur(_mid)
	_tourist_line.text = "A shop taking the wrong money gives the tourist rate: €%.3f" % Forex.tourist_eur_per_gbp(_mid, true)
	_chart.set_values(Forex.history(d.rng_seed, d.day_count, DAYS, ev), func(v: float) -> String: return "€%.3f" % v)
	_news.text = Forex.news(d.rng_seed, d.day_count, Markets.news_templates())
	header_right.text = "%s   %s" % [UIKit.money_text(d.money), UIKit.money_text(d.euros, Wallet.EUR)]

func _set_hint() -> void:
	if _mode == "qty":
		set_hints([["updown", "Amount"], ["confirm", "Change it"], ["cancel", "Back"]])
	else:
		set_hints([["confirm", "Choose"], ["cancel", "Leave"]])

func _open_qty(from: String) -> void:
	var have := Wallet.balance(Game.data, from)
	if Forex.quote(have, from, _mid) <= 0:
		_say.text = "You've no %s to change. Lovely to see you all the same." % Wallet.NAMES[from]
		Audio.sfx("bump")
		return
	_from = from
	_amount = mini(have, 100)
	_mode = "qty"
	_qty_panel.visible = true
	_say.text = ""
	_refresh_qty()
	_set_hint()

func _refresh_qty() -> void:
	_amount = clampi(_amount, 1, maxi(1, Wallet.balance(Game.data, _from)))
	_qty_label.text = "Change %s" % UIKit.money_text(_amount, _from)
	_get_label.text = "You get %s" % UIKit.money_text(Forex.quote(_amount, _from, _mid), Wallet.other(_from))

func _commit() -> void:
	var r := Forex.exchange(Game.data, _amount, _from)
	if not r.ok:
		_say.text = "That won't buy so much as a cent. Try a bit more."
		Audio.sfx("bump")
		return
	Audio.sfx("item")
	_say.text = "There you go: %s for your %s. Count it, go on." % [UIKit.money_text(int(r.got), str(r.cur)), UIKit.money_text(int(r.paid), _from)]
	_close_qty()
	_refresh()

func _close_qty() -> void:
	_mode = "root"
	_qty_panel.visible = false
	_set_hint()
	UIKit.focus_later(_buttons[0 if _from == "gbp" else 1])

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	if _mode == "qty":
		var dlt := 0
		if event.is_action_pressed("move_up"):
			dlt = 10
		elif event.is_action_pressed("move_down"):
			dlt = -10
		elif event.is_action_pressed("move_right"):
			dlt = 100
		elif event.is_action_pressed("move_left"):
			dlt = -100
		if dlt != 0:
			get_viewport().set_input_as_handled()
			var old := _amount
			_amount += dlt
			_refresh_qty()
			if _amount != old:
				Audio.sfx("cursor")
			return
		if event.is_action_pressed("confirm"):
			get_viewport().set_input_as_handled()
			_commit()
			return
	super._input(event)

func _on_cancel() -> void:
	if _mode == "qty":
		Audio.sfx("cancel")
		_close_qty()
	else:
		close(null)
