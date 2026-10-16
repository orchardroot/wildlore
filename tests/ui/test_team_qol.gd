extends TestCase
## Nicknames, move reordering in the Summary and the move relearner's candidate list.

const NameEntry = preload("res://ui/name_entry.gd")
const Summary = preload("res://ui/summary_screen.gd")

func test_nickname_shows_in_display_name() -> void:
	var c := Fixtures.creature("kindlet", 5)
	assert_eq(c.display_name(), "Kindlet")
	NameEntry.apply_nickname(c, "  Sparky  ")
	assert_eq(c.nickname, "Sparky")
	assert_eq(c.display_name(), "Sparky")
	assert_eq(Creature.from_dict(c.to_dict(), Fixtures.dex()).display_name(), "Sparky", "the nickname survives a save")

func test_blank_or_species_nickname_clears_it() -> void:
	var c := Fixtures.creature("kindlet", 5)
	NameEntry.apply_nickname(c, "Sparky")
	NameEntry.apply_nickname(c, "   ")
	assert_eq(c.nickname, "")
	assert_eq(c.display_name(), "Kindlet")
	NameEntry.apply_nickname(c, "Kindlet")
	assert_eq(c.nickname, "", "naming it after its own species is the same as no nickname")

func test_nickname_target_parsing() -> void:
	var d := GameStateData.new()
	d.party = [Fixtures.creature("kindlet", 5), Fixtures.creature("spikkin", 5)]
	d.ark = [Fixtures.creature("binfox", 5)]
	assert_eq(NameEntry.nickname_target(d, "nickname:1"), d.party[1])
	assert_eq(NameEntry.nickname_target(d, "nickname:ark:0"), d.ark[0])
	assert_eq(NameEntry.nickname_target(d, "nickname:7"), null)
	assert_eq(NameEntry.nickname_target(d, ""), null)

func test_reorder_swaps_two_moves() -> void:
	var c := Fixtures.creature("kindlet", 9)  # scrap, glare, kindle, quick_nip
	c.moves[0].pp = 3
	Summary.swap_moves(c, 0, 2)
	assert_eq(c.moves.map(func(m): return m.id), ["kindle", "glare", "scrap", "quick_nip"])
	assert_eq(int(c.moves[2].pp), 3, "PP travels with the move")
	Summary.swap_moves(c, 1, 1)
	assert_eq(c.moves.map(func(m): return m.id), ["kindle", "glare", "scrap", "quick_nip"])
	Summary.swap_moves(c, 0, 9)
	assert_eq(c.moves.map(func(m): return m.id), ["kindle", "glare", "scrap", "quick_nip"], "out of range does nothing")

func test_relearn_candidates() -> void:
	var c := Fixtures.creature("kindlet", 20)
	c.moves = [c.make_move_slot("scrap", Fixtures.moves()), c.make_move_slot("smoulder", Fixtures.moves())]
	assert_eq(Progression.relearnable(c), ["glare", "kindle", "quick_nip", "blaze_dash"],
		"learnset moves at or below its level it doesn't know, in learn order")
	c.level = 12
	assert_eq(Progression.relearnable(c), ["glare", "kindle", "quick_nip"])

func test_relearn_skips_duplicates_in_learnset() -> void:
	var sp := Fixtures.species("echo", ["kin"], 50, {"learnset": [[1, "scrap"], [3, "glare"], [7, "glare"]]})
	var c := Creature.create(sp, 10, FixedRng.new(), Fixtures.moves())
	c.moves = [c.make_move_slot("scrap", Fixtures.moves())]
	assert_eq(Progression.relearnable(c), ["glare"])

func test_screens_compile() -> void:
	for p in ["res://ui/bag_screen.gd", "res://ui/party_screen.gd", "res://ui/summary_screen.gd", "res://ui/name_entry.gd", "res://ui/relearn_screen.gd"]:
		var s: GDScript = load(p)
		assert_true(s != null and s.can_instantiate(), "%s compiles" % p)
