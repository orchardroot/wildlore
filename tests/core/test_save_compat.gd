extends TestCase
## Saves across versions: a mid-game save in the shape of each released version (tests/fixtures/saves, built by
## tools/gen_save_fixtures.py from that tag's own code) loads in this build, keeps everything it held, works with the
## newer systems, survives a scripted month of play and a save and reload with nothing lost.

const TAGS := ["v2.0.0", "v2.2.1", "v3.0.0", "v3.3.0", "v3.5.0", "v3.7.0"]
var dir := "user://test_saves_compat_%d" % Time.get_ticks_usec()

func _fixture(tag: String) -> Dictionary:
	var text := FileAccess.get_file_as_string("res://tests/fixtures/saves/save_%s.json" % tag)
	var raw = JSON.parse_string(text)
	assert_true(raw is Dictionary, "fixture %s parses" % tag)
	return raw if raw is Dictionary else {}

## Through the real file path: write the fixture as a slot, read it back with the loader the game uses.
func _load(tag: String) -> GameStateData:
	var raw := _fixture(tag)
	DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(SaveSystem.slot_path(tag, dir), FileAccess.WRITE)
	f.store_string(JSON.stringify(raw))
	f.close()
	var loaded := SaveSystem.load_slot(tag, dir)
	assert_false(loaded.is_empty(), "%s loads from its slot file" % tag)
	return GameStateData.from_dict(loaded, Fixtures.dex())

func _wipe() -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(dir)

func _canon(data: GameStateData) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(data.to_dict())), "", true)

func _reload(data: GameStateData) -> GameStateData:
	assert_eq(SaveSystem.save("rt", data.to_dict(), dir), OK)
	return GameStateData.from_dict(SaveSystem.load_slot("rt", dir), Fixtures.dex())

func test_every_fixture_exists_and_is_in_its_versions_shape() -> void:
	for tag in TAGS:
		var raw := _fixture(tag)
		assert_eq(raw.has("euros"), tag >= "v3.0.0", "%s: euros arrived in 3.0" % tag)
		assert_eq(raw.has("markets"), tag >= "v3.0.0", "%s: markets arrived in 3.0" % tag)
		assert_eq(raw.party[0].has("genome"), tag >= "v3.5.0", "%s: genomes arrived in 3.5" % tag)
		assert_true(raw.party.size() >= 2 and raw.bag.size() >= 3 and raw.badges.size() >= 3, tag)

func test_each_version_loads_with_party_bag_money_flags_and_badges_intact() -> void:
	for tag in TAGS:
		var raw := _fixture(tag)
		var d := _load(tag)
		assert_eq(d.player_name, "Jo", tag)
		assert_eq(d.party.size(), raw.party.size(), tag)
		for i in raw.party.size():
			var m: Dictionary = raw.party[i]
			assert_eq(d.party[i].species.id, m.species, tag)
			assert_eq(d.party[i].level, int(m.level), tag)
			assert_eq(d.party[i].nickname, m.nickname, tag)
			assert_eq(d.party[i].held, m.held, tag)
			assert_eq(d.party[i].moves.size(), m.moves.size(), tag)
			assert_true(d.party[i].hp <= d.party[i].max_hp(), tag)
			assert_false(d.party[i].genome.is_empty(), "%s: every creature has genes (derived if the save predates them)" % tag)
		assert_eq(d.ark.size(), raw.ark.size(), tag)
		for k in raw.bag:
			assert_eq(int(d.bag[k]), int(raw.bag[k]), "%s bag %s" % [tag, k])
		assert_eq(d.money, int(raw.money), tag)
		assert_eq(d.badges, raw.badges, tag)
		for k in raw.flags:
			assert_true(d.flags.has(k), "%s keeps flag %s" % [tag, k])
			assert_eq(typeof(d.flags[k]) == TYPE_DICTIONARY, typeof(raw.flags[k]) == TYPE_DICTIONARY, "%s flag %s keeps its kind" % [tag, k])
		for k in raw.seen:
			assert_true(d.seen.has(k), tag)
		assert_eq(d.zone_id, raw.zone_id, tag)
		assert_eq(d.day_count, int(raw.day_count), tag)
		assert_eq(d.stats.get("steps"), int(raw.stats.steps), tag)
	_wipe()

func test_each_version_round_trips_with_nothing_lost() -> void:
	for tag in TAGS:
		var d := _load(tag)
		var once := _canon(d)
		var back := _reload(d)
		assert_eq(_canon(back), once, "%s: save then load changes nothing" % tag)
		assert_eq(_canon(_reload(back)), once, "%s: and again" % tag)
		# every flag, number for number
		for k in d.flags:
			assert_eq(str(back.flags.get(k)), str(d.flags[k]), "%s flag %s" % [tag, k])
		assert_eq(back.money, d.money, tag)
		assert_eq(back.euros, d.euros, tag)
		assert_eq(back.purses, d.purses, tag)
		assert_eq(back.party.size(), d.party.size(), tag)
		for i in d.party.size():
			assert_eq(JSON.stringify(back.party[i].to_dict()), JSON.stringify(d.party[i].to_dict()), tag)
	_wipe()

func test_pre_3_0_saves_get_their_defaults_for_the_newer_fields() -> void:
	for tag in ["v2.0.0", "v2.2.1"]:
		var d := _load(tag)
		assert_eq(d.euros, 0, tag)
		assert_eq(d.purses, {}, tag)
		assert_eq(d.markets.trades, 0, tag)
		assert_eq(Wallet.balance(d, Wallet.GBP), d.money, tag)
		assert_true(d.stats.has("fish_caught") or TrainerStats.get_count(d, "fish_caught") == 0, tag)
	_wipe()

func test_the_newer_systems_work_on_every_loaded_save() -> void:
	for tag in TAGS:
		var d := _load(tag)
		# money, purses and the Building Society
		for cur in [Wallet.GBP, Wallet.EUR]:
			assert_true(Wallet.balance(d, cur) >= 0, tag)
		assert_true(Wallet.foreign_lines(d) is Array, tag)
		assert_true(BuildingSociety.saved(d, Wallet.GBP) >= 0, tag)
		assert_true(BuildingSociety.loan(d) is Dictionary, tag)
		# Trades, Regulars, Guilds, Deeds, Standing, Leases
		for t in Trades.IDS:
			assert_true(Trades.level(d, t) >= 1, "%s trade %s" % [tag, t])
		Trades.refresh(d)
		assert_true(Trades.sell_mult(d) >= 1.0, tag)
		for r in Regulars.ids():
			assert_true(Regulars.favour(d, str(r)) >= 0, tag)
		for g in Guilds.IDS:
			assert_true(Guilds.is_member(d, g) is bool, tag)
		assert_true(Guilds.sell_bonus(d) >= 0.0, tag)
		for dd in Deeds.all():
			assert_true(Deeds.price(d, str(dd.id)) > 0, tag)
		for n in Standing.NATIONS:
			assert_true(Standing.points(d, n) >= 0, tag)
		assert_true(Leases.tick(d, d.day_count) is Array, tag)
		# genes, sex and showing for everyone, including saves that predate Genetics
		for c in d.party + d.ark:
			assert_false(c.genome.is_empty(), tag)
			assert_true(Genetics.showing(c) is Dictionary, tag)
			assert_true(Genetics.derive(c).genome.has("coat"), tag)
		# the Stud Book and Casebook read their pages
		assert_false(StudBook.unlocked(d, "nonsense"), tag)
		for c in Casebook.all():
			assert_true(Casebook.started(d, c) is bool, tag)
			assert_true(Casebook.solved(d, c) is bool, tag)
		assert_true(TrainerStats.lines(d).size() > 0, "%s: the Stats page builds" % tag)
		assert_true(Rewild.wild_count(d) >= 0, tag)
		assert_true(Postcards.collected(d) is Array, tag)
		assert_true(Jobs.active(d) is Array, tag)
		assert_true(Tournament.streak(d) >= 0, tag)
	_wipe()

## A month of in-game midnights as Game._process runs them, with the things a player does between them.
func _play_a_month(d: GameStateData) -> void:
	for day in 30:
		d.day_count += 1
		d.clock_minutes = 480
		BuildingSociety.settle(d)
		Deeds.tick(d, d.day_count)
		Leases.tick(d, d.day_count)
		Rewild.settle(d)
		Markets.settle(d)
		Trades.refresh(d)
		Jobs.offers(d, "macclesfield")
		d.money += 25
		TrainerStats.add(d, "steps", 300)
		for c in d.party:
			c.xp += 40
			c.friendship = mini(255, c.friendship + 1)
		if day % 7 == 0:
			d.heal_party()
	d.set_flag("compat_played", d.day_count)

func test_each_version_plays_a_month_then_saves_and_reloads_with_nothing_lost() -> void:
	for tag in TAGS:
		var d := _load(tag)
		var start_day := d.day_count
		var start_money := d.money
		var start_steps := TrainerStats.get_count(d, "steps")
		_play_a_month(d)
		assert_eq(d.day_count, start_day + 30, tag)
		assert_true(d.money >= start_money, "%s: nothing took money from a month of idling" % tag)
		var before := _canon(d)
		var back := _reload(d)
		assert_eq(_canon(back), before, "%s: the played save reloads exactly" % tag)
		assert_eq(back.day_count, start_day + 30, tag)
		assert_eq(TrainerStats.get_count(back, "steps"), start_steps + 9000, tag)
		assert_eq(back.flag("compat_played"), start_day + 30, tag)
		# and a second month on the reloaded copy still works
		_play_a_month(back)
		assert_eq(_canon(_reload(back)), _canon(back), tag)
	_wipe()

func test_the_slot_screens_can_read_every_fixture() -> void:
	for tag in TAGS:
		_load(tag)
		var info := SaveSystem.slot_info(tag, dir)
		assert_true(info.ok, tag)
		assert_eq(info.player_name, "Jo", tag)
		assert_true(info.badges >= 3, tag)
	_wipe()

## Baskets, Roslin's readings and the stud engagement are written by 3.7 and read back from JSON (every number a float).
func test_a_3_7_basket_hatches_from_the_file_into_a_clean_creature() -> void:
	var d := _load("v3.7.0")
	assert_eq(Breeding.baskets(d).size(), 2)
	assert_eq(Breeding.ready(d), [0], "the walked-off basket is ready, the other is not")
	var got := Breeding.collect(d, Fixtures.dex(), Fixtures.moves())
	assert_eq(got.size(), 1)
	var c: Creature = got[0].creature
	for s in Rules.STATS:
		assert_eq(typeof(c.ivs[s]), TYPE_INT, "iv %s is a whole number" % s)
		assert_eq(typeof(c.training[s]), TYPE_INT, "training %s" % s)
	assert_eq(typeof(c.level), TYPE_INT)
	assert_eq(typeof(c.uid), TYPE_INT)
	assert_eq(typeof(c.max_hp()), TYPE_INT)
	assert_eq(c.hp, c.max_hp())
	assert_eq(Breeding.logs(d).size(), 2, "the old hatch and the new one")
	assert_eq(Breeding.baskets(d).size(), 1)
	var back := _reload(d)
	assert_eq(_canon(back), _canon(d))
	assert_true(Stud.tested(back, back.party[0]))
	_wipe()

## What the player does with the newer systems on an old save, straight after loading it.
func test_actions_on_a_loaded_save_work_for_every_version() -> void:
	for tag in TAGS:
		var d := _load(tag)
		d.money = 200000
		d.euros = 50000
		d.flags["badge_brook"] = true
		d.flags["badge_stone"] = true
		d.flags["badge_tide"] = true
		var deed := str(Deeds.all()[0].id)
		var err := Deeds.buy(d, deed)
		assert_true(err == "" or Deeds.is_owned(d, deed), "%s: buy a Deed (%s)" % [tag, err])
		assert_eq(Deeds.supply(d, deed, "sloes", 1) >= 0, true, tag)
		Deeds.tick(d, d.day_count + 8)
		assert_true(Deeds.collect(d, deed) >= 0, tag)
		assert_true(Deeds.summary(d, deed) is Array, tag)
		assert_true(BuildingSociety.deposit(d, Wallet.GBP, 1000), tag)
		assert_true(BuildingSociety.withdraw(d, Wallet.GBP, 200), tag)
		assert_true(BuildingSociety.borrow(d, "macclesfield", 500, 6) is Dictionary, tag)
		assert_true(BuildingSociety.statement(d) is Array, tag)
		assert_eq(Guilds.join(d, "anglers") is String, true, tag)
		var held := Markets.buy(d, str(Markets.companies()[0].id), 2)
		assert_true(held is Dictionary, tag)
		if d.party.size() > 0:
			assert_true(Stud.genotype_test(d, d.party[1], Wallet.GBP) is String, tag)
		var back := _reload(d)
		assert_eq(_canon(back), _canon(d), "%s: after the actions, a reload loses nothing" % tag)
	_wipe()
