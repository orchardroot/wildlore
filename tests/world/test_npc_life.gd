extends TestCase
## Idle life in the world: NPC schedules (`times`), NPCs noticing the player, and wild creatures roaming the tall grass.

# --- schedules ----------------------------------------------------------------

func test_npc_without_times_is_always_out() -> void:
	for ph in ["dawn", "day", "dusk", "night"]:
		assert_true(Npc.shown_at({"id": "a"}, ph), ph)

func test_npc_with_times_is_only_out_then() -> void:
	var home_at_night := {"id": "a", "times": ["day", "dusk"]}
	assert_true(Npc.shown_at(home_at_night, "day"))
	assert_true(Npc.shown_at(home_at_night, "dusk"))
	assert_false(Npc.shown_at(home_at_night, "night"))
	assert_false(Npc.shown_at(home_at_night, "dawn"))
	var owl := {"id": "b", "times": ["night"]}
	assert_true(Npc.shown_at(owl, "night"))
	assert_false(Npc.shown_at(owl, "day"))

func test_shipped_night_npcs_only_come_out_at_night() -> void:
	var night_only := 0
	for z in ZoneData.load_all().values():
		for n in z.npcs:
			if n.get("times", []) == ["night"]:
				night_only += 1
				assert_false(Npc.shown_at(n, "day"), str(n.id))
	assert_true(night_only >= 20, "a night-only NPC or two in every city (got %d)" % night_only)

# --- the validator rule for `times` ----------------------------------------------

const CHAT := [{"do": "say", "who": "Lamplighter", "text": "Evening."}]

func test_times_on_a_chatty_npc_is_fine() -> void:
	assert_eq(StoryValidator.times_errors({"id": "lamp", "sprite": "lamplighter", "times": ["night"]}, CHAT, {}), [])
	var with_when := [{"do": "when", "cond": "rain", "then": CHAT}, {"do": "say", "text": "Hi."}]
	assert_eq(StoryValidator.times_errors({"id": "a", "times": ["day", "dusk"]}, with_when, {}), [])

func test_times_must_be_known_phases() -> void:
	assert_eq(StoryValidator.times_errors({"id": "a", "times": ["teatime"]}, CHAT, {}).size(), 1)
	assert_eq(StoryValidator.times_errors({"id": "a", "times": []}, CHAT, {}).size(), 1)

func test_times_never_on_a_trainer() -> void:
	assert_true(StoryValidator.times_errors({"id": "a", "trainer": "x", "times": ["day"]}, [], {}).size() > 0)

func test_times_never_on_a_story_npc() -> void:
	var story := [{"do": "say", "text": "Take this."}, {"do": "give_item", "item": "potion"}]
	assert_true(StoryValidator.times_errors({"id": "a", "times": ["day"]}, story, {}).size() > 0, "a script that does more than talk")
	var sets := [{"do": "if", "flag": "f", "then": [{"do": "set", "flag": "g"}]}]
	assert_true(StoryValidator.times_errors({"id": "a", "times": ["day"]}, sets, {}).size() > 0, "even nested")
	assert_true(StoryValidator.times_errors({"id": "a", "times": ["day"]}, CHAT, {"a": true}).size() > 0, "moved by a story beat")

func test_times_never_on_shopkeepers_nurses_guards_or_sailors() -> void:
	for s in ["shopkeeper", "sanctuary_nurse", "rail_guard", "sailor"]:
		assert_true(StoryValidator.times_errors({"id": "a", "sprite": s, "times": ["day"]}, CHAT, {}).size() > 0, s)

# --- noticing the player ------------------------------------------------------------

func test_npc_notices_the_player_within_two_tiles() -> void:
	var at := Vector2i(10, 10)
	assert_true(Npc.notices(at, Vector2i(12, 10)))
	assert_true(Npc.notices(at, Vector2i(9, 8)))
	assert_false(Npc.notices(at, Vector2i(13, 10)))
	assert_false(Npc.notices(at, at))

# --- roaming creatures --------------------------------------------------------------

func _zone(rows: Array, extra := {}) -> ZoneData:
	var d := {"id": "t", "kind": "route", "rows": rows, "props": [], "warps": [], "npcs": [], "signs": [], "spawn": [0, 0],
		"encounters": {"grass": [
			{"species": "pipkin", "weight": 10},
			{"species": "hootlet", "weight": 10, "time": ["night"]},
			{"species": "croakle", "weight": 10, "weather": ["drizzle", "downpour"]},
		]}}
	d.merge(extra, true)
	return ZoneData.from_dict(d)

const ROWS := [
	"..........",
	".,,,,,,,,.",
	".,,,,,,,,.",
	".,,,R,,,,.",
	".,,,,,,,,.",
	"..........",
]

func test_creatures_roam_only_tall_grass() -> void:
	var z := _zone(ROWS, {"props": [{"type": "bench", "x": 2, "y": 2}], "warps": [{"x": 3, "y": 1, "to": "x", "tx": 0, "ty": 0}]})
	assert_true(RoamingCreatures.can_roam(z, Vector2i(1, 1)))
	assert_false(RoamingCreatures.can_roam(z, Vector2i(0, 0)), "short grass")
	assert_false(RoamingCreatures.can_roam(z, Vector2i(4, 3)), "rock")
	assert_false(RoamingCreatures.can_roam(z, Vector2i(2, 2)), "a bench stands in the grass")
	assert_false(RoamingCreatures.can_roam(z, Vector2i(3, 1)), "a warp")
	assert_false(RoamingCreatures.can_roam(z, Vector2i(-1, 1)), "off the map")
	var tiles := RoamingCreatures.roam_tiles(z)
	assert_eq(tiles.size(), 31 - 2)
	for p in tiles:
		assert_eq(z.tile_at(p), "tall_grass")

func test_how_many_roam() -> void:
	assert_eq(RoamingCreatures.count_for("low", 200), 0, "off on Low")
	assert_eq(RoamingCreatures.count_for("high", 3), 0, "a scrap of grass is too small")
	assert_eq(RoamingCreatures.count_for("medium", 20), 2)
	assert_eq(RoamingCreatures.count_for("high", 400), 3)
	assert_true(RoamingCreatures.count_for("high", 99999) <= RoamingCreatures.MAX_CREATURES, "capped")

func test_species_come_from_the_current_encounter_table() -> void:
	var z := _zone(ROWS)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 20:
		for sp in RoamingCreatures.pick_species(z, "day", "clear", 3, rng):
			assert_eq(sp, "pipkin", "only what you could meet now")
	var night := {}
	for i in 30:
		for sp in RoamingCreatures.pick_species(z, "night", "drizzle", 3, rng):
			night[sp] = true
	assert_eq(night.keys().size(), 3, "night and rain bring their own")
	assert_eq(RoamingCreatures.pick_species(_zone(ROWS, {"encounters": {}}), "day", "clear", 3, rng), [])

func test_creature_darts_away_from_the_player() -> void:
	var z := _zone(ROWS)
	assert_true(RoamingCreatures.spooked(Vector2i(5, 2), Vector2i(5, 4)))
	assert_true(RoamingCreatures.spooked(Vector2i(5, 2), Vector2i(7, 3)))
	assert_false(RoamingCreatures.spooked(Vector2i(5, 2), Vector2i(8, 2)))
	var to := RoamingCreatures.flee_step(z, Vector2i(5, 2), Vector2i(5, 4), {})
	assert_eq(to, Vector2i(5, 1), "straight away from the player")
	assert_eq(z.tile_at(to), "tall_grass")
	# cornered against the edge of the grass: it slips sideways rather than out of the grass
	var side := RoamingCreatures.flee_step(z, Vector2i(5, 1), Vector2i(5, 3), {})
	assert_true(side in [Vector2i(4, 1), Vector2i(6, 1)], "sideways, got %s" % side)
	# boxed in by other creatures: stays put
	var boxed := RoamingCreatures.flee_step(z, Vector2i(1, 1), Vector2i(1, 3), {Vector2i(2, 1): true})
	assert_eq(boxed, Vector2i(1, 1))

func test_wandering_stays_in_the_grass() -> void:
	var z := _zone(ROWS)
	for pick in 4:
		var to := RoamingCreatures.wander_step(z, Vector2i(1, 1), {}, pick)
		assert_eq(z.tile_at(to), "tall_grass", "pick %d" % pick)
	assert_eq(RoamingCreatures.wander_step(z, Vector2i(5, 2), {Vector2i(5, 1): true, Vector2i(5, 3): true, Vector2i(4, 2): true, Vector2i(6, 2): true}, 0), Vector2i(5, 2), "boxed in")

# --- breathing and running ------------------------------------------------------------

func test_breathing_starts_after_standing_a_while() -> void:
	assert_eq(CharSprite.breath(0.0), 0.0)
	assert_eq(CharSprite.breath(CharSprite.BREATHE_AFTER - 0.1), 0.0, "not straight away")
	var ups := 0
	for i in 100:
		ups += int(CharSprite.breath(CharSprite.BREATHE_AFTER + i * CharSprite.BREATHE_PERIOD / 100.0))
	assert_true(ups > 20 and ups < 80, "rises and falls over a breath (%d/100 up)" % ups)

func test_running_has_a_faster_walk_cycle() -> void:
	assert_true(CharSprite.RUN_RATE > CharSprite.WALK_RATE)
