extends MenuBase
## Crafting: the recipes you know, with what you have against what each needs. Confirm makes one batch.
## Opened as "craft:<bench>" (kitchen, workbench, borrowed) from the {"do": "craft"} story command.

const SHORT := Color("e9998c")
const OK := Color("a8d08d")

var _bench := "kitchen"
var _recipes: Array = []
var _list_col: VBoxContainer
var _desc: VBoxContainer
var _say: Label
var _buttons: Array = []
var _last := 0

func _build() -> void:
	set_title(Crafting.BENCHES.kitchen)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 10)
	lp.custom_minimum_size = Vector2(600, 0)
	row.add_child(lp)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	lp.add_child(sc)
	_list_col = VBoxContainer.new()
	_list_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(_list_col)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	row.add_child(right)
	var dp := UIKit.panel(Color("1d2230f0"), 18)
	dp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(dp)
	_desc = VBoxContainer.new()
	_desc.add_theme_constant_override("separation", 8)
	dp.add_child(_desc)
	_say = UIKit.label("", 26, UIKit.GOLD)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_say)
	_money()
	_refresh()
	set_hints([["confirm", "Make one"], ["cancel", "Done"]])

func setup(arg: String) -> void:
	_bench = arg if Crafting.BENCHES.has(arg) else "kitchen"
	set_title(Crafting.BENCHES[_bench])
	_say.text = "" if _recipes.is_empty() else ("Pinny on. What are we making?" if _bench != "workbench" else "Sleeves up. What are we making?")

func _money() -> void:
	header_right.text = Wallet.purse_text(Game.data, Wallet.local(Game.data))

func _refresh() -> void:
	_recipes = Crafting.known(Game.data)
	UIKit.clear(_list_col)
	_buttons.clear()
	if _recipes.is_empty():
		_list_col.add_child(UIKit.label("You don't know any recipes yet. Mum knows a few, if you ask nicely.", 26, UIKit.MUTED))
		_list_col.get_child(0).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UIKit.clear(_desc)
		return
	for i in _recipes.size():
		var r: Dictionary = _recipes[i]
		var it: Dictionary = Game.items.get_item(str(r.out))
		var can := Crafting.can_make(Game.data, r)
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 56)
		b.focus_entered.connect(func():
			Audio.sfx("cursor")
			_last = i
			_describe(r))
		b.pressed.connect(func(): _make(i))
		b.focus_neighbor_left = NodePath(".")
		b.focus_neighbor_right = NodePath(".")
		var h := HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.offset_left = 14
		h.offset_right = -14
		h.add_theme_constant_override("separation", 10)
		var n := int(r.get("n", 1))
		h.add_child(UIKit.label(str(it.get("name", str(r.out).capitalize())) + (" x%d" % n if n > 1 else ""), 28, UIKit.CREAM if can else UIKit.MUTED))
		h.add_child(UIKit.fill())
		h.add_child(UIKit.label("have %d" % Bag.new(Game.data.bag).count(str(r.out)), 22, UIKit.MUTED))
		for c in h.get_children():
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(h)
		if not can:
			b.modulate = Color(1, 1, 1, 0.55)  # greyed out: something's missing
		_list_col.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	_last = clampi(_last, 0, _buttons.size() - 1)
	UIKit.focus_later(_buttons[_last])

func _describe(r: Dictionary) -> void:
	UIKit.clear(_desc)
	var it: Dictionary = Game.items.get_item(str(r.out))
	_desc.add_child(UIKit.label(str(it.get("name", str(r.out).capitalize())), 34))
	var kind := str(it.get("kind", "charm"))
	_desc.add_child(UIKit.chip(UIKit.kind_name(kind), Color("4a4f5e"), UIKit.CREAM, 18))
	var d := UIKit.label(str(r.get("note", it.get("desc", ""))), 22, UIKit.MUTED)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.add_child(d)
	_desc.add_child(UIKit.label("Needs", 24, UIKit.GOLD))
	var bag := Bag.new(Game.data.bag)
	var ins: Dictionary = r.get("in", {})
	for id in ins:
		var have := bag.count(str(id))
		var need := int(ins[id])
		var line := HBoxContainer.new()
		line.add_child(UIKit.label(str(Game.items.get_item(str(id)).get("name", id)), 24))
		line.add_child(UIKit.fill())
		line.add_child(UIKit.label("%d / %d" % [have, need], 24, OK if have >= need else SHORT))
		_desc.add_child(line)
	var cost := Crafting.cost(Game.data, r)
	var cur := Wallet.local(Game.data)
	if cost > 0:
		var line := HBoxContainer.new()
		line.add_child(UIKit.label("Shopping", 24))
		line.add_child(UIKit.fill())
		line.add_child(UIKit.label(UIKit.money_text(cost, cur), 24, OK if Wallet.can_afford(Game.data, cost, cur) else SHORT))
		_desc.add_child(line)

func _make(i: int) -> void:
	if i < 0 or i >= _recipes.size():
		return
	var res := Crafting.craft(Game.data, _recipes[i], Game.items)
	_say.text = str(res.text)
	Audio.sfx("heal" if res.ok else "bump")
	if res.ok:
		_money()
		_refresh()
		_describe(_recipes[i])
