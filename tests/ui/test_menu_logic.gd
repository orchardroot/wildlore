extends TestCase

func test_wrap_index() -> void:
	assert_eq(MenuLogic.wrap_index(0, -1, 4), 3, "up from top wraps to bottom")
	assert_eq(MenuLogic.wrap_index(3, 1, 4), 0, "down from bottom wraps to top")
	assert_eq(MenuLogic.wrap_index(1, 1, 4), 2)
	assert_eq(MenuLogic.wrap_index(0, 1, 0), 0, "empty list stays at zero")

func test_affordability() -> void:
	assert_true(MenuLogic.can_afford(300, 100, 3))
	assert_false(MenuLogic.can_afford(299, 100, 3))
	assert_false(MenuLogic.can_afford(1000, 100, 0), "zero quantity is not a purchase")

func test_max_buy() -> void:
	assert_eq(MenuLogic.max_buy(550, 100), 5)
	assert_eq(MenuLogic.max_buy(99999, 100), 99, "capped at 99")
	assert_eq(MenuLogic.max_buy(50, 100), 0)
	assert_eq(MenuLogic.max_buy(500, 0), 99, "free items are only capped")
	assert_eq(MenuLogic.max_buy(550, 100, 97), 2, "owned stacks count towards the cap")
	assert_eq(MenuLogic.max_buy(99999, 100, 99), 0)

func test_sell_price() -> void:
	assert_eq(MenuLogic.sell_price(100), 50)
	assert_eq(MenuLogic.sell_price(1200), 600)
	assert_eq(MenuLogic.sell_price(0), 0, "key items are worth nothing")
	assert_eq(MenuLogic.sell_price(5), 2, "rounds down")

func test_reorder_swaps() -> void:
	assert_eq(MenuLogic.reorder(["a", "b", "c"], 0, 2), ["c", "b", "a"])
	assert_eq(MenuLogic.reorder(["a", "b", "c"], 1, 1), ["a", "b", "c"])
	assert_eq(MenuLogic.reorder(["a", "b"], 0, 5), ["a", "b"], "out of range changes nothing")
	var src := ["a", "b"]
	MenuLogic.reorder(src, 0, 1)
	assert_eq(src, ["a", "b"], "input is not mutated")

func test_habitats() -> void:
	var zones := [
		{"id": "z1", "name": "Forest", "encounters": {"grass": [{"species": "pipkin"}, {"species": "binfox"}]}},
		{"id": "z2", "name": "Moor", "encounters": {"grass": [{"species": "pipkin"}], "water": [{"species": "croakle"}]}},
		{"id": "z3", "name": "Town"},
	]
	var idx := MenuLogic.habitat_index(zones)
	assert_eq(MenuLogic.habitats(idx, "pipkin"), ["Forest", "Moor"])
	assert_eq(MenuLogic.habitats(idx, "croakle"), ["Moor"])
	assert_eq(MenuLogic.habitats(idx, "wispet"), [])

func test_hp_band_and_time() -> void:
	assert_eq(MenuLogic.hp_band(50, 100), "green")
	assert_eq(MenuLogic.hp_band(26, 100), "green")
	assert_eq(MenuLogic.hp_band(25, 100), "amber")
	assert_eq(MenuLogic.hp_band(10, 100), "red")
	assert_eq(MenuLogic.hp_band(0, 100), "red")
	assert_eq(MenuLogic.play_time(3725.0), "1:02")
	assert_eq(MenuLogic.play_time(59.0), "0:00")

func test_credits_ignore_an_early_confirm() -> void:
	const Credits = preload("res://ui/credits_screen.gd")
	assert_false(Credits.can_skip(0.3))
	assert_true(Credits.can_skip(2.5))

func test_fly_action_is_registered_on_keyboard_and_pad() -> void:
	InputSetup.register()
	assert_true(InputMap.has_action("fly"))
	var kinds := InputMap.action_get_events("fly").map(func(e): return e.get_class())
	assert_has(kinds, "InputEventKey")
	assert_has(kinds, "InputEventJoypadButton")
