extends MenuBase
## A Deed counter (see Deeds): the books on the left (till, store, tier, manager, rates, the last few events), the
## counter on the right (buy, collect, stock the store, upgrade, sell back). Opened as "deed:<deed id>" from the
## counter in the interior by the `deed` story command.

var _id := ""
var _cur := Wallet.GBP
var _stmt: VBoxContainer
var _box: VBoxContainer
var _say: Label
var _buttons: Array = []
var _sell_armed := false

func _build() -> void:
	set_title("The Business")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 18)
	lp.custom_minimum_size = Vector2(600, 0)
	row.add_child(lp)
	_stmt = VBoxContainer.new()
	_stmt.add_theme_constant_override("separation", 8)
	lp.add_child(_stmt)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	row.add_child(right)
	var bp := UIKit.panel(Color("1d2230f0"), 10)
	right.add_child(bp)
	_box = VBoxContainer.new()
	bp.add_child(_box)
	right.add_child(UIKit.fill())
	_say = UIKit.label("", 24, UIKit.GOLD)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_say)

## "deed:<deed id>"
func setup(arg: String) -> void:
	_id = arg
	var d := Deeds.get_deed(_id)
	_cur = Deeds.cur_of(_id)
	set_title(str(d.get("name", "The Business")))
	Deeds.tick(Game.data, Game.data.day_count)
	_say.text = _hello()
	_refresh()
	_set_hint()

func _hello() -> String:
	if Deeds.is_owned(Game.data, _id):
		return "Your place, your books. Collect the till, keep the store full, and watch the rates."
	return "It could be yours. Everything in it, the fryer included. The fryer comes with opinions."

func _local(gbp: int) -> String:
	return Wallet.fmt(Wallet.localise(gbp, _cur), _cur)

func _line(text: String, size := 22, colour := UIKit.CREAM) -> void:
	var l := UIKit.label(text, size, colour)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stmt.add_child(l)

func _refresh() -> void:
	var d: GameStateData = Game.data
	var deed := Deeds.get_deed(_id)
	UIKit.clear(_stmt)
	UIKit.clear(_box)
	_buttons = []
	header_right.text = UIKit.money_text(Wallet.balance(d, _cur), _cur)
	_stmt.add_child(UIKit.label("The books", 30, UIKit.GOLD))
	if Deeds.is_owned(d, _id):
		for t in Deeds.summary(d, _id):
			_line(str(t))
		_line("A good day, fully stocked, takes about %s." % _local(Deeds.daily_estimate(d, _id)), 20, UIKit.MUTED)
		var rec := Deeds.recent(d, _id)
		if not rec.is_empty():
			_stmt.add_child(UIKit.spacer(6))
			_line("Lately", 22, UIKit.MUTED)
			for t in rec:
				_line(str(t), 18, UIKit.MUTED)
		_button("Collect the till (%s)" % _local(Deeds.till(d, _id)), _collect)
		for inp in deed.get("inputs", []):
			var it := str(inp.item)
			var nm := str(Trade.items().get_item(it).get("name", it))
			_button("Stock %s (store %d, bag %d)" % [nm, Deeds.store_of(d, _id, it), int(d.bag.get(it, 0))], _stock.bind(it))
		var up := Deeds.upgrade_cost(d, _id)
		if up > 0:
			var nxt: Dictionary = deed.tiers[Deeds.tier_of(d, _id) + 1]
			_button("Upgrade: %s (%s)" % [str(nxt.name), _local(up)], _upgrade)
		_button("Sell the business", _sell)
	else:
		_line(str(deed.get("kind", "")).capitalize() + " in " + str(deed.get("zone", "")).capitalize(), 22, UIKit.MUTED)
		_line("Price today: %s" % _local(Deeds.price(d, _id)))
		_line("Takes about %s a day when stocked. Business rates are %d%% of takings." % [_local(Deeds.daily_estimate(d, _id)), roundi(float(deed.get("rates", 0.0)) * 100.0)])
		_line(Deeds.talk("manager"), 18, UIKit.MUTED)
		_button("Buy it", _buy)
	_button("Leave", func(): close(null))
	UIKit.wrap_focus(_buttons)
	UIKit.focus_later(_buttons[0])

func _button(text: String, fn: Callable) -> void:
	var b := make_button(text, fn)
	b.add_theme_font_size_override("font_size", 26)
	_box.add_child(b)
	_buttons.append(b)

func _set_hint() -> void:
	set_hints([["confirm", "Choose"], ["cancel", "Leave"]])

func _done_sfx(ok: bool) -> void:
	Audio.sfx("item" if ok else "bump")

func _buy() -> void:
	var why := Deeds.buy(Game.data, _id)
	_done_sfx(why == "")
	_say.text = Deeds.talk("buy") if why == "" else why
	econ_tip()
	_refresh()

func _collect() -> void:
	var got := Deeds.collect(Game.data, _id)
	_done_sfx(got > 0)
	_say.text = ("Collected %s, after the council took its share." % Wallet.fmt(got, _cur)) if got > 0 else "Nothing in the till yet after rates. Give it a day or two."
	_refresh()

func _stock(item_id: String) -> void:
	var n := Deeds.supply(Game.data, _id, item_id, 99)
	_done_sfx(n > 0)
	_say.text = ("In goes %d." % n) if n > 0 else "Nothing to put in: either the store holds a fortnight already or the bag has none."
	_refresh()

func _upgrade() -> void:
	var why := Deeds.upgrade(Game.data, _id)
	_done_sfx(why == "")
	_say.text = "Done. The takings will notice." if why == "" else why
	_refresh()

func _sell() -> void:
	var d: GameStateData = Game.data
	if not _sell_armed:
		_sell_armed = true
		_say.text = "Sure? You'd get %s for the place (60%% of what you've put in), plus the till. Press again to sell." % _local(roundi(float(_paid()) * Deeds.SELL_BACK))
		Audio.sfx("cursor")
		return
	var got := Deeds.sell_back(d, _id)
	_sell_armed = false
	Audio.sfx("item")
	_say.text = Deeds.talk("sell") + "  (%s)" % Wallet.fmt(got, _cur)
	_refresh()

func _paid() -> int:
	return int(Deeds.state(Game.data, _id).get("paid", 0))
