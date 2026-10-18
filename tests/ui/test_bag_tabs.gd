extends TestCase
## The bag only shows tabs with something in them: a first-hour bag is Healing, Snares and Key Items, not eight
## tabs of nothing. A tab turns up as soon as something lands in it.

const BagScreen = preload("res://ui/bag_screen.gd")

var items := ItemDB.load_default()

func test_first_hour_bag_shows_only_the_tabs_in_use() -> void:
	var bag := Bag.new({"cup_of_tea": 3, "wicker_snare": 5, "fieldbook": 1, "map": 1, "smelling_salts": 0})
	assert_eq(BagScreen.tab_kinds(bag, items), ["heal", "snare", "key"], "used up, so no Remedies tab")
	bag.add("smelling_salts", 1)
	assert_eq(BagScreen.tab_kinds(bag, items), ["heal", "cure", "snare", "key"], "it turns up when something lands in it")

func test_hold_and_use_on_narrow_the_tabs() -> void:
	var bag := Bag.new({"cup_of_tea": 3, "wicker_snare": 5, "rowan_sprig": 1})
	assert_eq(BagScreen.tab_kinds(bag, items, true), ["charm"], "holding: charms only")
	assert_eq(BagScreen.tab_kinds(bag, items, false, true), ["heal"], "using on one: usable kinds only")
