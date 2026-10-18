extends TestCase
## 2.0 save safety: a 1.5.0 save (no 2.0 flags or fields at all) loads, plays into every 2.0 system, and round-trips
## through the real save file with all of their state intact.

var dir := "user://test_saves_2_0_%d" % Time.get_ticks_usec()

func _wipe() -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(dir)

## What 1.5.0's GameStateData.to_dict wrote (git show v1.5.0:core/game_state_data.gd), as it comes back from the
## JSON file: every number a float, creatures without "variant".
static func old_save() -> Dictionary:
	var mon := {"species": "pipkin", "nickname": "Pip", "level": 24.0, "xp": 13824.0, "nature": "brash",
		"ivs": {"hp": 12.0, "atk": 6.0, "def": 11.0, "lore": 9.0, "ward": 15.0, "spd": 1.0},
		"training": {"hp": 4.0, "atk": 0.0, "def": 0.0, "lore": 0.0, "ward": 0.0, "spd": 0.0}, "hp": 50.0,
		"moves": [{"id": "talk_about_the_weather", "pp": 15.0, "max_pp": 15.0}], "status": "", "status_turns": 0.0,
		"friendship": 120.0, "held": "horseshoe"}
	var ark := mon.duplicate(true)
	ark.species = "kindlet"
	ark.nickname = ""
	return {"version": 2.0, "saved_at": 1760000000.0, "player_name": "Jo", "rival_name": "Kit",
		"party": [mon], "ark": [ark], "bag": {"cup_of_tea": 3.0, "sloes": 4.0, "show_rosette": 0.0}, "money": 4321.0,
		"flags": {"visited_macclesfield": true, "visited_buxton": true, "met_kit": true, "quiz_score": 4.0,
			"badge_count_seen": 3.0, "last_town": "macclesfield"},
		"zone_id": "macclesfield", "pos": [10.0, 12.0], "facing": "up", "seen": {"pipkin": true}, "caught": {"pipkin": true},
		"badges": ["peak", "mersey", "potteries"], "play_seconds": 36000.0, "clock_minutes": 600.0, "day_count": 12.0,
		"last_sanctuary": {"zone": "macclesfield", "pos": [-1.0, -1.0]}, "rng_seed": 99.0, "weather": "drizzle",
		"weather_region": "peak", "weather_until": 9000.0, "stats": {"steps": 5000.0, "wins_wild": 40.0}}

func _reload(data: GameStateData) -> GameStateData:
	assert_eq(SaveSystem.save("slot1", data.to_dict(), dir), OK)
	return GameStateData.from_dict(SaveSystem.load_slot("slot1", dir), Fixtures.dex())

func test_a_1_5_save_loads_with_every_2_0_system_at_rest() -> void:
	var d := GameStateData.from_dict(SaveSystem.migrate(old_save()), Fixtures.dex())
	assert_eq(d.party.size(), 1)
	assert_eq(d.party[0].variant, "", "no coat")
	assert_eq(d.party[0].held, "horseshoe")
	assert_eq(d.ark[0].variant, "")
	for n in Standing.NATIONS:
		assert_eq(Standing.points(d, n), 0)
		assert_eq(Standing.tier(d, n), Standing.STRANGER)
	assert_eq(Jobs.active(d), [])
	for s in Rewild.sites():
		assert_eq(Rewild.stage(d, str(s.id)), 0)
		assert_false(Rewild.pending(d, str(s.id)))
	for n in range(1, 7):
		assert_eq(HomeBase.plot_state(d, n).stage, "empty")
	assert_eq(Tournament.streak(d), 0)
	assert_eq(Tournament.shows_won(d), 0)
	assert_false(Tournament.moot_champion(d))
	assert_eq(Postcards.collected(d), [])
	assert_true(d.real_party.is_empty())

func test_a_1_5_save_round_trips_with_all_2_0_state() -> void:
	var d := GameStateData.from_dict(SaveSystem.migrate(old_save()), Fixtures.dex())
	# play into every 2.0 system
	d.party[0].variant = "frost"
	Coats.record_caught(d, d.party[0])
	Standing.add(d, "wales", 12)
	var job := str(Jobs.offers(d, "macclesfield")[0].id)
	assert_eq(Jobs.accept(d, job, "macclesfield"), "")
	var site := str(Rewild.sites()[0].id)
	Rewild.contribute(d, site)
	Rewild.contribute(d, site)  # stage 1 at once, then a day's wait
	assert_true(HomeBase.plant(d, 2, "sloes"))
	Tournament.pay_show(d, 2)
	Tournament.note_moot_fight(d, true)
	Tournament.note_moot_fight(d, true)
	Tournament.today(d)
	d.set_flag("keeper_side_maud", true)
	d.set_flag(Postcards.flag_key("first"), "2026-10-18")
	var epoch := Jobs.epoch(d)
	var before := d.to_dict()

	var back := _reload(d)
	assert_eq(back.party[0].variant, "frost")
	assert_eq(Coats.status(back, "pipkin", "frost"), "caught")
	assert_eq(Standing.points(back, "wales"), 12)
	assert_eq(Standing.tier(back, "wales"), Standing.KNOWN_FACE)
	assert_eq(Jobs.active(back).size(), 1)
	assert_true(Jobs.has_active(back, job))
	assert_eq(Jobs.epoch(back), epoch, "the board day survives a reload (no fresh board from loading)")
	assert_eq(Rewild.stage(back, site), 1)
	assert_true(Rewild.pending(back, site))
	back.day_count += 1
	assert_eq(Rewild.settle(back), [site], "a JSON day stamp still settles")
	assert_eq(HomeBase.plot_state(back, 2).material, "sloes")
	assert_eq(Bag.new(back.bag).count(Tournament.ROSETTE), 2)
	assert_eq(Tournament.pay_show(back, 2), 0, "the day's rosettes stay paid after a reload")
	assert_eq(Tournament.streak(back), 2)
	assert_eq(back.flag("keeper_side_maud"), true)
	assert_true(Postcards.is_collected(back, "first"))
	# and a second trip through the file changes nothing
	var again := _reload(back)
	back.day_count -= 1
	again.day_count -= 1
	assert_eq(JSON.stringify(again.to_dict(), "", true), JSON.stringify(_reload(again).to_dict(), "", true))
	assert_eq(int(before.money), int(again.money))
	_wipe()
