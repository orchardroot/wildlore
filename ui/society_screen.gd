extends MenuBase
## A Building Society counter (see BuildingSociety): the statement on the left (loan, savings, Mum's sub, the last few
## entries), the counter on the right. Borrowing shows what the loan costs over six, twelve and twenty-four months
## before you sign, which is the whole lesson. Opened as "society:<zone id>" from Pat's counters in Manchester, Cardiff,
## Edinburgh, Belfast and Dublin.

const UP := Color("8fd18a")
const DOWN := Color("e9998c")

var _zone := ""
var _cur := Wallet.GBP
var _mode := "root"     # root | qty
var _kind := ""         # borrow | repay | payin | payout | mum
var _amount := 0
var _term := 1          # index into BuildingSociety.TERMS
var _buttons: Array = []
var _stmt: VBoxContainer
var _qty_panel: PanelContainer
var _qty_title: Label
var _qty_lines: Array = []
var _qty_note: Label
var _say: Label
var _btn := {}

func _build() -> void:
	set_title("Building Society")
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
	var bc := VBoxContainer.new()
	bp.add_child(bc)
	for e in [["borrow", "Borrow", func(): _open_qty("borrow")], ["repay", "Pay off the loan", func(): _open_qty("repay")],
			["payin", "Pay into savings", func(): _open_qty("payin")], ["payout", "Take out savings", func(): _open_qty("payout")],
			["mum", "Pay Mum back", func(): _open_qty("mum")], ["apr", "What is APR?", func(): _explain("apr")],
			["leave", "Leave", func(): close(null)]]:
		var b := make_button(e[1], e[2])
		b.add_theme_font_size_override("font_size", 28)
		bc.add_child(b)
		_btn[e[0]] = b
	_qty_panel = UIKit.panel(Color("2c3446f8"), 14)
	_qty_panel.visible = false
	var qv := VBoxContainer.new()
	qv.add_theme_constant_override("separation", 4)
	_qty_panel.add_child(qv)
	_qty_title = UIKit.label("", 32)
	qv.add_child(_qty_title)
	for i in 3:
		var l := UIKit.label("", 22, UIKit.GOLD)
		qv.add_child(l)
		_qty_lines.append(l)
	_qty_note = UIKit.label("", 20, UIKit.MUTED)
	_qty_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qv.add_child(_qty_note)
	right.add_child(_qty_panel)
	right.add_child(UIKit.fill())
	_say = UIKit.label("", 24, UIKit.GOLD)
	_say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_say)

## "society:<zone id>"
func setup(arg: String) -> void:
	_zone = arg
	var b := BuildingSociety.branch(arg)
	_cur = str(b.get("cur", Wallet.GBP))
	set_title(str(b.get("place", "Building Society")))
	BuildingSociety.settle(Game.data)
	_refresh()
	_say.text = _hello()
	UIKit.focus_later(_buttons[0])
	_set_hint()

func _hello() -> String:
	var d: GameStateData = Game.data
	if BuildingSociety.missed(d) > 0:
		return "Ah, there you are, love. No fuss. Let's get you straightened out."
	if BuildingSociety.limit(d, _cur) <= 0 and not BuildingSociety.has_loan(d):
		return "Morning, love. I lend to folk who've been somewhere, so come back after a couple of Stones. Savings are open to anyone, mind."
	return "Morning, love. Savings, a loan, or just in out of the rain? I've seen it all, so you can't shock me."

func _refresh() -> void:
	var d: GameStateData = Game.data
	UIKit.clear(_stmt)
	_stmt.add_child(UIKit.label("Statement", 30, UIKit.GOLD))
	var lines := BuildingSociety.statement(d)
	for t in lines:
		var l := UIKit.label(str(t), 22)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_stmt.add_child(l)
	var lim := BuildingSociety.limit(d, _cur)
	if not BuildingSociety.has_loan(d):
		_stmt.add_child(UIKit.label("You can borrow up to %s." % Wallet.fmt(lim, _cur) if lim > 0 else "Not lending to you yet: two Stones first.", 20, UIKit.MUTED))
	var rec := BuildingSociety.recent(d)
	if not rec.is_empty():
		_stmt.add_child(UIKit.spacer(6))
		_stmt.add_child(UIKit.label("Recently", 22, UIKit.MUTED))
		for t in rec:
			var l := UIKit.label(str(t), 18, UIKit.MUTED)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_stmt.add_child(l)
	header_right.text = UIKit.money_text(Wallet.balance(d, _cur), _cur)
	var have_loan := BuildingSociety.has_loan(d)
	_btn.borrow.visible = not have_loan
	_btn.repay.visible = have_loan
	_btn.mum.visible = BuildingSociety.mum_owed(d) > 0
	_btn.payout.visible = BuildingSociety.saved(d, _cur) > 0
	_buttons = []
	for k in ["borrow", "repay", "payin", "payout", "mum", "apr", "leave"]:
		if _btn[k].visible:
			_buttons.append(_btn[k])
	UIKit.wrap_focus(_buttons)

func _set_hint() -> void:
	if _mode == "qty":
		if _kind == "borrow":
			set_hints([["updown", "Amount"], ["leftright", "Months"], ["confirm", "Sign"], ["cancel", "Back"]])
		else:
			set_hints([["updown", "Amount"], ["confirm", "Do it"], ["cancel", "Back"]])
	else:
		set_hints([["confirm", "Choose"], ["cancel", "Leave"]])

func _explain(key: String) -> void:
	_say.text = BuildingSociety.talk(key) + ("  " + BuildingSociety.talk("early") if key == "apr" else "")

func _open_qty(kind: String) -> void:
	var d: GameStateData = Game.data
	var max_n := _max_for(kind)
	if max_n <= 0:
		_say.text = _cannot(kind)
		Audio.sfx("bump")
		return
	_kind = kind
	_mode = "qty"
	_amount = mini(max_n, 100 if kind != "borrow" else mini(max_n, Wallet.localise(500, _cur)))
	_amount = maxi(_amount, _min_for(kind))
	_qty_panel.visible = true
	_say.text = BuildingSociety.talk("savings") if kind == "payin" else ""
	_refresh_qty()
	_set_hint()

func _min_for(kind: String) -> int:
	return Wallet.localise(BuildingSociety.MIN_LOAN, _cur) if kind == "borrow" else 1

func _max_for(kind: String) -> int:
	var d: GameStateData = Game.data
	match kind:
		"borrow":
			return BuildingSociety.limit(d, _cur)
		"repay":
			return mini(Wallet.balance(d, BuildingSociety.loan_cur(d)), BuildingSociety.payoff(d))
		"payin":
			return Wallet.balance(d, _cur)
		"payout":
			return BuildingSociety.saved(d, _cur)
		"mum":
			return mini(d.money, BuildingSociety.mum_owed(d))
	return 0

func _cannot(kind: String) -> String:
	match kind:
		"borrow":
			return "Not yet, love. Come back after your second Stone and we'll talk." if Game.data.badges.size() < BuildingSociety.MIN_BADGES else "Not today, love."
		"repay":
			return "You've nothing in the purse to pay with, love. No shame in it."
		"payin":
			return "The purse is empty, love. Hard to save nothing."
		"payout":
			return "There's nothing in the account yet."
		"mum":
			return "Mum would sooner you ate. Pay her when there's something spare."
	return ""

func _refresh_qty() -> void:
	var d: GameStateData = Game.data
	_amount = clampi(_amount, _min_for(_kind), maxi(_min_for(_kind), _max_for(_kind)))
	for l in _qty_lines:
		l.text = ""
	_qty_note.text = ""
	match _kind:
		"borrow":
			_qty_title.text = "Borrow %s" % Wallet.fmt(_amount, _cur)
			var rate := BuildingSociety.loan_rate(_cur)
			for i in BuildingSociety.TERMS.size():
				var q := BuildingSociety.quote(_amount, rate, BuildingSociety.TERMS[i])
				_qty_lines[i].text = "%s%d months: %s a month, %s in all" % [">  " if i == _term else "    ", BuildingSociety.TERMS[i], Wallet.fmt(q.payment, _cur), Wallet.fmt(q.total, _cur)]
				_qty_lines[i].add_theme_color_override("font_color", UIKit.CREAM if i == _term else UIKit.GOLD)
			_qty_note.text = "%.2f%% a month on what you still owe: %.1f%% APR. Left alone, a year of it costs that much." % [rate * 100.0, BuildingSociety.apr(rate) * 100.0]
		"repay":
			_qty_title.text = "Pay %s off" % Wallet.fmt(_amount, BuildingSociety.loan_cur(d))
			_qty_lines[0].text = "Clearing it all today costs %s." % Wallet.fmt(BuildingSociety.payoff(d), BuildingSociety.loan_cur(d))
			_qty_note.text = "Early is fine: you only pay for the days you had it."
		"payin":
			_qty_title.text = "Pay in %s" % Wallet.fmt(_amount, _cur)
		"payout":
			_qty_title.text = "Take out %s" % Wallet.fmt(_amount, _cur)
		"mum":
			_qty_title.text = "Post Mum %s" % Wallet.fmt(_amount)
			_qty_lines[0].text = "You owe her %s." % Wallet.fmt(BuildingSociety.mum_owed(d))
			_qty_note.text = "No interest. She did say."

func _commit() -> void:
	var d: GameStateData = Game.data
	var ok := false
	var msg := ""
	match _kind:
		"borrow":
			var r := BuildingSociety.borrow(d, _zone, _amount, BuildingSociety.TERMS[_term])
			ok = r.ok
			msg = "There you are: %s in your purse. %s a month comes out by itself on the same day each month, so keep a little in the purse." % [Wallet.fmt(_amount, _cur), Wallet.fmt(BuildingSociety.loan(d).get("pay", 0), _cur)] if ok else str(r.why)
		"repay":
			var r := BuildingSociety.repay(d, _amount)
			ok = r.ok
			msg = ("All clear. Not a penny owing. Lovely." if not BuildingSociety.has_loan(d) else "Done. That helps, love. %s to go." % Wallet.fmt(BuildingSociety.owed(d), _cur)) if ok else "That didn't go through."
		"payin":
			ok = BuildingSociety.deposit(d, _cur, _amount)
			msg = "Paid in. Don't spend it all at once." if ok else "That didn't go through."
		"payout":
			ok = BuildingSociety.withdraw(d, _cur, _amount)
			msg = "Here you go. Count it, go on." if ok else "That didn't go through."
		"mum":
			var r := BuildingSociety.repay_mum(d, _amount)
			ok = r.ok
			msg = ("Postal order sent. She'll mention it for years, but kindly." if BuildingSociety.mum_owed(d) <= 0 else "Posted. She'll say she wasn't counting.") if ok else "That didn't go through."
	Audio.sfx("item" if ok else "bump")
	_say.text = msg
	if ok:
		_close_qty()
		_refresh()
		UIKit.focus_later(_buttons[0])
	else:
		_refresh_qty()

func _close_qty() -> void:
	_mode = "root"
	_qty_panel.visible = false
	_set_hint()

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	if _mode == "qty":
		var step := 100 if _kind == "borrow" else 10
		var dlt := 0
		if event.is_action_pressed("move_up", true):
			dlt = step
		elif event.is_action_pressed("move_down", true):
			dlt = -step
		elif _kind != "borrow" and event.is_action_pressed("move_right", true):
			dlt = 100
		elif _kind != "borrow" and event.is_action_pressed("move_left", true):
			dlt = -100
		if dlt != 0:
			get_viewport().set_input_as_handled()
			var old := _amount
			_amount += dlt
			_refresh_qty()
			if _amount != old:
				Audio.sfx("cursor")
			return
		if _kind == "borrow" and (event.is_action_pressed("move_right") or event.is_action_pressed("move_left")):
			get_viewport().set_input_as_handled()
			_term = clampi(_term + (1 if event.is_action_pressed("move_right") else -1), 0, BuildingSociety.TERMS.size() - 1)
			_refresh_qty()
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
		UIKit.focus_later(_buttons[0])
	else:
		close(null)
