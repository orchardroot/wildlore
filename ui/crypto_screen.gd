extends "res://ui/exchange_screen.gd"
## The Doggerel kiosk: one coin, absurd swings, a crowd who have never once sold, and the occasional rug pull
## (see Markets). In-game sterling only. Opened as "crypto".

const NEON := Color("7dffb0")
const CROWD := [
	"\"To the moon!\"  (a man in a hoodie, in the rain)",
	"\"Have fun staying poor.\"  (a student who owes his mum forty quid)",
	"\"It's not a loss until you sell.\"  (a lad who has never sold)",
	"\"Diamond paws!\"  (a woman holding a framed picture of a dog)",
	"\"The poem is the utility.\"  (nobody has read the poem)",
]

func _init() -> void:
	_panel_bg = Color("21143af0")
	_accent = NEON

func _is_coin() -> bool:
	return true

func _id() -> String:
	return str(Markets.coin().get("id", "DGRL"))

func _listing_ids() -> Array:
	return [_id()]

func _state() -> Dictionary:
	return Markets.coin_state(Game.data.rng_seed, Game.data.day_count)

func _name(_id_unused: String) -> String:
	return str(_state().name)

func _price(_id_unused: String) -> float:
	return Markets.coin_price_for(Game.data)

func _history(_id_unused: String) -> Array:
	return Markets.coin_history(Game.data.rng_seed, Game.data.day_count, DAYS)

func _move(_id_unused: String) -> float:
	var d: GameStateData = Game.data
	if d.day_count <= 0:
		return 0.0
	var y := float(Markets.coin_state(d.rng_seed, d.day_count - 1).price)
	if int(_state().start) == d.day_count or y <= 0.0:
		return 0.0  # a fresh edition: nothing to compare with
	return _price("") / y - 1.0

func _held(_id_unused: String) -> int:
	return Markets.coin_held(Game.data)

func _basis(_id_unused: String) -> int:
	return int(Game.data.markets.get("coin", {}).get("cost", 0))

func _max_buy(_id_unused: String) -> int:
	return Markets.coin_max_buy(Game.data)

func _cost(_id_unused: String, n: int) -> int:
	return Markets.coin_buy_cost(n, _price(""))

func _proceeds(_id_unused: String, n: int) -> int:
	return Markets.coin_sell_proceeds(n, _price(""))

func _limit() -> int:
	return Markets.coin_cap(Game.data.badges.size())

func _deal(_id_unused: String, side: String, n: int) -> Dictionary:
	return Markets.coin_buy(Game.data, n) if side == "buy" else Markets.coin_sell(Game.data, n)

func _price_text(v: float) -> String:
	if v >= 10.0:
		return Wallet.fmt_price(v, Wallet.GBP)
	return "£%.4f" % v

func _sector(_id_unused: String) -> String:
	return "Meme coin"

func _about(_id_unused: String) -> String:
	var s := _state()
	var age := Game.data.day_count - int(s.start)
	return "%s Edition %d, %d days old. Prices swing wildly and the developers come and go. Only ever spend what you'd happily lose." \
		% [str(Markets.coin().get("about", "")), int(s.gen) + 1, age]

func _fee_text(_id_unused: String, _n: int) -> String:
	return "incl. a %d%% spread and a %s network fee" % [roundi(Markets.COIN_SPREAD * 100.0), UIKit.money_text(Markets.COIN_FEE)]

func _headlines() -> Array:
	var h := Markets.headlines(Game.data, true).filter(func(l): return str(l).contains("Doggerel") or str(l).contains("DOGGEREL"))
	h.append_array(CROWD.slice(posmod(Game.data.day_count, CROWD.size())) + CROWD.slice(0, posmod(Game.data.day_count, CROWD.size())))
	return h

func _greeting() -> String:
	if int(_state().flag) == 2:
		return "The kiosk screen just says 'brb'. The crowd is very quiet."
	return "Welcome, fellow early adopter. Not financial advice. Nothing here is advice of any kind."

func _portfolio_value() -> int:
	return floori(_held("") * _price(""))

func _style_chart(c: PriceChart) -> void:
	c.floor_mark = 0.0

func _build() -> void:
	super._build()
	set_title("Doggerel Kiosk")

func setup(arg: String) -> void:
	super.setup("london" + (":" + arg if arg != "" else ""))
	set_title("Doggerel Kiosk")
	_cur = Wallet.GBP
	_money()

func _draw_list() -> void:
	super._draw_list()
	_list_col.add_child(UIKit.spacer(10))
	_list_col.add_child(_row_label("The crowd", 20, UIKit.MUTED))
	for i in 3:
		var l := UIKit.label(CROWD[posmod(Game.data.day_count + i, CROWD.size())], 18, Color(NEON, 0.75))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list_col.add_child(l)
