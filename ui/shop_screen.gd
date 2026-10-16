extends MenuBase
## Shop: buy with a quantity, sell at half price. Opened as "shop:<shop_id>"; stock comes from ItemDB.shops.

var _shop: Dictionary = {}
var _bag: Bag
var _mode := "root"      # root | list | qty
var _side := "buy"       # buy | sell
var _ids: Array = []
var _cur := ""           # item id in the quantity chooser
var _qty := 1
var _root_col: VBoxContainer
var _list_col: VBoxContainer
var _list_scroll: ScrollContainer
var _desc: VBoxContainer
var _qty_panel: PanelContainer
var _qty_label: Label
var _total_label: Label
var _say: Label
var _root_buttons: Array = []
var _item_buttons: Array = []
var _last_item := 0

func _build() -> void:
	set_title("Shop")
	_bag = Bag.new(Game.data.bag)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(560, 0)
	left.add_theme_constant_override("separation", 12)
	row.add_child(left)
	var rp := UIKit.panel(Color("1d2230f0"), 10)
	left.add_child(rp)
	_root_col = VBoxContainer.new()
	rp.add_child(_root_col)
	for e in [["Buy", func(): _open_list("buy")], ["Sell", func(): _open_list("sell")], ["Leave", func(): close(null)]]:
		var b := make_button(e[0], e[1])
		b.add_theme_font_size_override("font_size", 32)
		_root_col.add_child(b)
		_root_buttons.append(b)
	UIKit.wrap_focus(_root_buttons)
	_list_scroll = ScrollContainer.new()
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list_scroll.follow_focus = true
	_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lp := UIKit.panel(Color("1d2230f0"), 10)
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp.add_child(_list_scroll)
	_list_col = VBoxContainer.new()
	_list_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_scroll.add_child(_list_col)
	left.add_child(lp)
	lp.visible = false
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	row.add_child(right)
	var dp := UIKit.panel(Color("1d2230f0"), 18)
	dp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(dp)
	_desc = VBoxContainer.new()
	_desc.add_theme_constant_override("separation", 10)
	dp.add_child(_desc)
	_qty_panel = UIKit.panel(Color("2c3446f8"), 14)
	_qty_panel.visible = false
	var qv := VBoxContainer.new()
	_qty_panel.add_child(qv)
	_qty_label = UIKit.label("", 34)
	qv.add_child(_qty_label)
	_total_label = UIKit.label("", 26, UIKit.GOLD)
	qv.add_child(_total_label)
	qv.add_child(UIKit.label("Up / Down  1      Left / Right  10", 20, UIKit.MUTED))
	right.add_child(_qty_panel)
	_say = UIKit.label("", 26, UIKit.GOLD)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_say)
	_money()
	UIKit.focus_later(_root_buttons[0])
	_set_hint()

func setup(arg: String) -> void:
	var parts := arg.split(":")  # "<shop_id>" or "<shop_id>:buy|sell" (jump straight to a list, handy for screenshots)
	arg = parts[0]
	_shop = Game.items.shops.get(arg, {}) if Game.items != null else {}
	if _shop.is_empty():
		_say.text = "Shut for stocktaking. Back soon."
		set_title("Shop")
		return
	set_title(str(_shop.get("name", "Shop")))
	_say.text = "Welcome in. Mind the cat."
	if parts.size() > 1 and parts[1] in ["buy", "sell"]:
		_open_list(parts[1])
		_say.text = "Welcome in. Mind the cat."

func _money() -> void:
	header_right.text = UIKit.money_text(Game.data.money)

func _set_hint() -> void:
	match _mode:
		"root": set_hints([["confirm", "Choose"], ["cancel", "Leave"]])
		"list": set_hints([["confirm", "Pick"], ["cancel", "Back"]])
		"qty": set_hints([["confirm", "Confirm"], ["cancel", "Back"]])

func _open_list(side: String) -> void:
	_side = side
	_mode = "list"
	_last_item = 0
	_say.text = ""
	_ids = []
	if side == "buy":
		for id in _shop.get("stock", []):
			if Game.items.has(id):
				_ids.append(id)
	else:
		for id in _bag.store.keys():
			var it: Dictionary = Game.items.get_item(id)
			if not it.is_empty() and int(it.get("price", 0)) > 0 and str(it.get("kind", "")) != "key" and _bag.count(id) > 0:
				_ids.append(id)
	_draw_list()
	_list_scroll.get_parent().visible = true
	_root_col.get_parent().visible = false
	_set_hint()

func _draw_list() -> void:
	UIKit.clear(_list_col)
	_item_buttons.clear()
	if _ids.is_empty():
		_list_col.add_child(UIKit.label("Nothing to sell. Not even a biscuit." if _side == "sell" else "Sold out of everything.", 26, UIKit.MUTED))
		UIKit.clear(_desc)
		return
	for id in _ids:
		var it: Dictionary = Game.items.get_item(id)
		var price := int(it.get("price", 0))
		var shown := price if _side == "buy" else MenuLogic.sell_price(price)
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 56)
		b.focus_entered.connect(func():
			Audio.sfx("cursor")
			_last_item = _item_buttons.find(b)
			_describe(id))
		b.pressed.connect(func():
			Audio.sfx("confirm")
			_pick(id))
		b.focus_neighbor_left = NodePath(".")
		b.focus_neighbor_right = NodePath(".")
		var h := HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.offset_left = 14
		h.offset_right = -14
		h.add_theme_constant_override("separation", 10)
		h.add_child(UIKit.label(str(it.get("name", id)), 28))
		h.add_child(UIKit.fill())
		var afford: bool = _side == "sell" or Game.data.money >= price
		h.add_child(UIKit.label(UIKit.money_text(shown), 26, UIKit.GOLD if afford else Color("e9998c")))
		for c in h.get_children():
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(h)
		_list_col.add_child(b)
		_item_buttons.append(b)
	UIKit.wrap_focus(_item_buttons)
	_last_item = clampi(_last_item, 0, _item_buttons.size() - 1)
	UIKit.focus_later(_item_buttons[_last_item])

func _describe(id: String) -> void:
	UIKit.clear(_desc)
	var it: Dictionary = Game.items.get_item(id)
	_desc.add_child(UIKit.label(str(it.get("name", id)), 36))
	_desc.add_child(UIKit.chip(UIKit.kind_name(str(it.get("kind", ""))), Color("4a4f5e"), UIKit.CREAM, 18))
	var d := UIKit.label(str(it.get("desc", "")), 26)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_child(d)
	_desc.add_child(UIKit.fill())
	_desc.add_child(UIKit.label("You have %d" % _bag.count(id), 24, UIKit.MUTED))

func _pick(id: String) -> void:
	_cur = id
	var price := int(Game.items.get_item(id).get("price", 0))
	var most := MenuLogic.max_buy(Game.data.money, price, _bag.count(id)) if _side == "buy" else _bag.count(id)
	if most < 1:
		_say.text = "You'd need a bit more cash for that one." if _side == "buy" and Game.data.money < price else "You can't carry any more of those."
		Audio.sfx("bump")
		return
	_say.text = ""
	_qty = 1
	_mode = "qty"
	_qty_panel.visible = true
	_refresh_qty()
	_set_hint()

func _max_qty() -> int:
	var price := int(Game.items.get_item(_cur).get("price", 0))
	if _side == "buy":
		return MenuLogic.max_buy(Game.data.money, price, _bag.count(_cur))
	return _bag.count(_cur)

func _unit() -> int:
	var price := int(Game.items.get_item(_cur).get("price", 0))
	return price if _side == "buy" else MenuLogic.sell_price(price)

func _refresh_qty() -> void:
	_qty = clampi(_qty, 1, maxi(1, _max_qty()))
	_qty_label.text = "%s  x %d" % [Game.items.get_item(_cur).get("name", _cur), _qty]
	_total_label.text = "%s %s" % ["Total" if _side == "buy" else "You get", UIKit.money_text(_unit() * _qty)]

func _commit() -> void:
	var total := _unit() * _qty
	if _side == "buy":
		if not MenuLogic.can_afford(Game.data.money, _unit(), _qty):
			_say.text = "Not enough cash for that many."
			Audio.sfx("bump")
			return
		Game.data.money -= total
		_bag.add(_cur, _qty)
		_say.text = "Lovely. %d x %s, that's %s." % [_qty, Game.items.get_item(_cur).name, UIKit.money_text(total)]
	else:
		if not _bag.remove(_cur, _qty):
			return
		Game.data.money += total
		_say.text = "Cheers. %s for the %s." % [UIKit.money_text(total), Game.items.get_item(_cur).name]
	Audio.sfx("confirm")
	_money()
	_mode = "list"
	_qty_panel.visible = false
	_set_hint()
	if _side == "sell":
		_ids = _ids.filter(func(id): return _bag.count(id) > 0)
	_draw_list()

func _close_qty() -> void:
	_mode = "list"
	_qty_panel.visible = false
	_set_hint()
	if not _item_buttons.is_empty():
		UIKit.focus_later(_item_buttons[clampi(_last_item, 0, _item_buttons.size() - 1)])

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	if _mode == "qty":
		var d := 0
		if event.is_action_pressed("move_up"):
			d = 1
		elif event.is_action_pressed("move_down"):
			d = -1
		elif event.is_action_pressed("move_right"):
			d = 10
		elif event.is_action_pressed("move_left"):
			d = -10
		if d != 0:
			get_viewport().set_input_as_handled()
			var old := _qty
			_qty = clampi(_qty + d, 1, maxi(1, _max_qty()))
			if _qty != old:
				Audio.sfx("cursor")
			_refresh_qty()
			return
		if event.is_action_pressed("confirm"):
			get_viewport().set_input_as_handled()
			_commit()
			return
	super._input(event)

func _on_cancel() -> void:
	match _mode:
		"qty":
			Audio.sfx("cancel")
			_close_qty()
		"list":
			Audio.sfx("cancel")
			_mode = "root"
			_list_scroll.get_parent().visible = false
			_root_col.get_parent().visible = true
			UIKit.clear(_desc)
			_set_hint()
			_root_buttons[0 if _side == "buy" else 1].grab_focus()
		_:
			close(null)
