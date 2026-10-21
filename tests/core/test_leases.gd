extends TestCase
## The Enclosure's leases (core/leases.gd): the auction and its guild-sensitive rivals, upkeep through the post,
## arrears and forfeit, commissioning rewilding, the gap in the anchor's border (fenced until won), the lease zones
## as cul-de-sacs, and that none of it can make money from nothing.

const MOOR := "pennine_grouse_moor"
const WOOD := "welsh_conifer_plantation"

func _data(cash := 400000) -> GameStateData:
	var d := GameStateData.new()
	d.money = cash
	d.euros = cash
	d.day_count = 400
	d.rng_seed = 99
	d.set_flag("game_complete", true)
	return d

## Sits through a whole auction bidding the minimum every time.
func _win(d: GameStateData, id: String) -> Dictionary:
	var a := Leases.auction_open(d, id)
	var guard := 0
	while not bool(a.over) and guard < 200:
		Leases.bid(a, d)
		guard += 1
	return a

func _owned(id := MOOR, cash := 400000) -> GameStateData:
	var d := _data(cash)
	var tries := 0
	while not Leases.is_owned(d, id) and tries < 12:  # a sitting can be lost to a keen rival; the next one has new bidders
		_win(d, id)
		tries += 1
	assert_true(Leases.is_owned(d, id), "won it in the end")
	return d

func test_data_is_sound() -> void:
	assert_true(Leases.all().size() >= 2, "the two reference leases")
	for l in Leases.all():
		assert_true(["england", "wales", "scotland", "ireland", "northern_ireland"].has(str(l.nation)), str(l.id) + " nation")
		assert_eq(str(l.unlock_flag), "game_complete")
		assert_true(int(l.reserve) >= 30000 and int(l.reserve) <= 150000, str(l.id) + " priced from 30k to 150k")

func test_old_save_has_no_leases() -> void:
	var d := GameStateData.new()
	assert_eq(Leases.owned(d).size(), 0)
	assert_false(Leases.is_owned(d, MOOR))
	assert_eq(Leases.letters_waiting(d).size(), 0)
	assert_eq(Leases.collect_letters(d).size(), 0)
	assert_eq(Leases.stage(d, MOOR), 0)

func test_not_on_the_market_before_the_credits() -> void:
	var d := GameStateData.new()
	d.money = 1000000
	assert_true(Leases.unavailable(d, MOOR) != "")
	assert_eq(Leases.auction_open(d, MOOR).size(), 0, "no sitting")
	d.set_flag("game_complete", true)
	assert_eq(Leases.unavailable(d, MOOR), "")

func test_the_reserve_is_the_opening_bid_and_it_costs_real_money() -> void:
	var d := _data()
	var a := Leases.auction_open(d, MOOR)
	assert_eq(int(a.reserve), 40000)
	assert_eq(Leases.min_bid(a), 40000)
	var broke := _data(500)
	assert_true(Leases.bid(a, broke) != "")
	assert_eq(int(a.bid), 0, "nothing bid")

func test_winning_takes_exactly_the_price_and_opens_the_flag() -> void:
	var d := _data()
	var before := d.money
	var a := _win(d, MOOR)
	if bool(a.won):
		assert_eq(before - d.money, int(a.price))
		assert_true(int(a.price) >= 40000)
		assert_true(Leases.is_owned(d, MOOR))
		assert_true(d.flag("lease_" + MOOR) != null, "state lives in the lease_<id> flag")
		assert_true(Leases.letters_waiting(d).size() >= 1, "the solicitor writes")
	else:
		assert_eq(d.money, before, "a lost sitting costs nothing")
		assert_false(Leases.is_owned(d, MOOR))

func test_passing_costs_nothing() -> void:
	var d := _data()
	var a := Leases.auction_open(d, MOOR)
	Leases.bid(a, d)
	Leases.pass_lot(a, d)
	assert_true(bool(a.over))
	assert_false(bool(a.won))
	assert_eq(d.money, 400000)
	assert_false(Leases.is_owned(d, MOOR))

func test_rivals_depend_on_the_guild_side() -> void:
	var plain := _data()
	var ram := _data()
	var tru := _data()
	Guilds.join(ram, "ramblers")
	Guilds.join(tru, "trust")
	var a_plain := Leases.rivals_for(plain, MOOR, 0)
	var a_ram := Leases.rivals_for(ram, MOOR, 0)
	var a_tru := Leases.rivals_for(tru, MOOR, 0)
	var trust_of := func(rs: Array) -> Dictionary:
		for r in rs:
			if str(r.name) == "The Heritage Trust":
				return r
		return {}
	assert_true(trust_of.call(a_plain).size() > 0, "the Trust bids against a stranger")
	assert_true(int(trust_of.call(a_ram).ceiling) > int(trust_of.call(a_plain).ceiling), "and harder against a Rambler")
	assert_eq(trust_of.call(a_tru).size(), 0, "a Trustee has the Trust on side")
	var o_plain := Leases.auction_open(plain, MOOR)
	var o_tru := Leases.auction_open(tru, MOOR)
	assert_true(int(o_tru.reserve) < int(o_plain.reserve), "with a friendly valuation")

func test_a_sitting_is_fair_and_repeatable() -> void:
	var a := Leases.rivals_for(_data(), MOOR, 3)
	var b := Leases.rivals_for(_data(), MOOR, 3)
	assert_eq(a, b, "same lot, same attempt, same room")
	var c := Leases.rivals_for(_data(), MOOR, 4)
	assert_true(a != c, "a new attempt faces fresh bidders")
	var d := _data()
	Leases.auction_open(d, MOOR)
	assert_eq(Leases.tries(d, MOOR), 1, "the attempt is counted and saved at once")

func test_no_sitting_can_print_money() -> void:
	for attempt in 40:
		var d := _data(200000)
		d.set_flag(Leases.TRIES_PREFIX + MOOR, attempt)
		var start := d.money
		var a := _win(d, WOOD)
		d.set_flag(Leases.TRIES_PREFIX + WOOD, attempt)
		assert_true(d.money <= start, "never richer after bidding")
		if bool(a.won):
			assert_true(start - d.money >= Leases.reserve_of(WOOD) / 2, "paid at least a real price")

func test_upkeep_is_taken_weekly_and_the_post_comes() -> void:
	var d := _owned()
	d.flags.erase(Leases.POST_FLAG)
	var m0 := d.money
	Leases.tick(d, d.day_count + 7)
	assert_eq(m0 - d.money, 300, "a week's upkeep")
	Leases.tick(d, d.day_count + 7)
	assert_eq(m0 - d.money, 300, "not twice for the same week")
	var letters := Leases.letters_waiting(d)
	assert_true(letters.size() >= 1)
	var lines := Leases.collect_letters(d)
	assert_true(lines.size() >= 2 and str(lines[0]).begins_with("A letter from"))
	assert_eq(Leases.letters_waiting(d).size(), 0)
	for ln in lines:
		assert_false(str(ln).contains("—"), "no em-dashes")
		assert_false(str(ln).contains("{"), "every blank filled")

func test_arrears_warn_then_forfeit_but_the_land_remembers() -> void:
	var d := _owned()
	d.flags.erase(Leases.POST_FLAG)
	d.set_flag("rewild_lease_" + MOOR, 2)
	d.money = 0
	d.euros = 0
	var day := d.day_count
	var lost: Array = []
	for w in range(1, Leases.FORFEIT_WEEKS + 1):
		lost = Leases.tick(d, day + 7 * w)
		if w < Leases.FORFEIT_WEEKS:
			assert_true(Leases.is_owned(d, MOOR), "still yours at week %d" % w)
			assert_eq(Leases.arrears(d, MOOR), w)
	assert_true(lost.has(MOOR))
	assert_false(Leases.is_owned(d, MOOR), "taken back")
	assert_eq(Leases.stage(d, MOOR), 2, "the land keeps its stage")
	assert_true(Leases.letters_waiting(d).size() >= 1)
	var kinds := []
	for m in Leases.letters_waiting(d):
		kinds.append(str(m.k))
	assert_has(kinds, "forfeit")

func test_commissioning_a_stage_takes_a_season() -> void:
	var d := _owned()
	var m0 := d.money
	assert_eq(Leases.stage(d, MOOR), 0)
	assert_eq(Leases.commission_blocked(d, MOOR), "")
	assert_eq(Leases.commission(d, MOOR), "")
	assert_eq(m0 - d.money, Leases.stage_cost(_data(), MOOR), "the first stage costs 8% of the reserve")
	assert_true(Leases.commission_blocked(d, MOOR) != "", "one at a time")
	var day := d.day_count
	d.day_count = day + Leases.SEASON - 1
	Leases.tick(d, d.day_count)
	assert_eq(Leases.stage(d, MOOR), 0, "not yet")
	d.day_count = day + Leases.SEASON
	Leases.tick(d, d.day_count)
	assert_eq(Leases.stage(d, MOOR), 1, "a season later it has moved on")
	assert_true(Leases.stage_cost(d, MOOR) > roundi(Leases.reserve_of(MOOR) * Leases.STAGE_PCT), "the next costs more")

func test_a_trustee_cannot_rewild_past_the_shoot() -> void:
	var d := _owned()
	d.set_flag("rewild_lease_" + MOOR, 1)
	Guilds.join(d, "trust")
	assert_eq(Leases.stage_cap(d), 1)
	assert_true(Leases.commission_blocked(d, MOOR).contains("Trust"))
	Guilds.resign(d, "trust")
	assert_eq(Leases.stage_cap(d), Rewild.WILD)

func test_arrears_hold_up_the_contractors() -> void:
	var d := _owned()
	var st := Leases.state(d, MOOR)
	st["arrears"] = 2
	d.set_flag("lease_" + MOOR, st)
	assert_true(Leases.commission_blocked(d, MOOR).contains("upkeep"))

func test_the_gap_is_cut_and_fenced_until_won() -> void:
	for pair in [[MOOR, "saddleworth_moor", "north"], [WOOD, "dee_valley", "south"]]:
		var l := Leases.get_lease(pair[0])
		var z := ZoneData.load_id(pair[1])
		assert_true(z.edges.has(pair[2]), "%s edge registered" % pair[1])
		assert_eq(str(z.edges[pair[2]].to), str(l.zone))
		var lane := Leases.border_tiles(z, l)
		var seen := z.reachable(z.spawn)
		for t in lane:
			assert_true(z.walkable(t), "gap open as parsed")
			assert_true(seen.has(t), "and reachable from the spawn")
		var closed := ZoneData.load_id(pair[1])
		Leases.apply(GameStateData.new(), closed)
		for t in lane:
			assert_false(closed.walkable(t), "fenced while unowned")
		var sign_found := false
		for s in closed.signs:
			if str(s.get("title", "")) == "Private land":
				sign_found = true
		assert_true(sign_found, "sign-posted")
		var open := ZoneData.load_id(pair[1])
		var d := GameStateData.new()
		d.set_flag("lease_" + pair[0], {"since": 1, "next": 99999})
		Leases.apply(d, open)
		for t in lane:
			assert_true(open.walkable(t), "open once won")

func test_the_lease_zone_is_a_cul_de_sac_that_lines_up() -> void:
	for id in [MOOR, WOOD]:
		var l := Leases.get_lease(id)
		var z := ZoneData.load_id(str(l.zone))
		var anchor := ZoneData.load_id(str(l.anchor))
		assert_eq(z.edges.size(), 1)
		var back_side: String = Leases.OPPOSITE[str(l.side)]
		assert_true(z.edges.has(back_side))
		var lane := Leases.border_tiles(anchor, l)
		for t in lane:
			var arr := anchor.edge_arrival(str(l.side), t, z)
			assert_true(z.walkable(arr), "arriving at %d,%d" % [arr.x, arr.y])
			var home := z.edge_arrival(back_side, arr, anchor)
			assert_eq(home, t, "and the way back lands where you left")
		assert_true(z.reachable(z.spawn).size() > 100, "plenty of land to walk")

func test_the_land_changes_with_its_stage() -> void:
	for id in [MOOR, WOOD]:
		var l := Leases.get_lease(id)
		var d := GameStateData.new()
		var z0 := ZoneData.load_id(str(l.zone))
		Rewild.apply(d, z0)
		assert_true(z0.has_meta("rewild"), "a lease zone is a rewild site")
		d.set_flag("rewild_lease_" + id, 3)
		var z3 := ZoneData.load_id(str(l.zone))
		Rewild.apply(d, z3)
		var diffs := 0
		for y in z0.height:
			for x in z0.width:
				if z0.chars[y][x] != z3.chars[y][x]:
					diffs += 1
		assert_true(diffs > 50, "stage 3 looks different from stage 0 (%d tiles in %s)" % [diffs, id])
		var species0 := []
		for e in z0.encounters.get("grass", []):
			if e.has("requires_flag"):
				species0.append(e.species)
		assert_eq(species0.size(), (l.rewild.encounters[0] as Array).size() + (l.rewild.encounters[1] as Array).size() + (l.rewild.encounters[2] as Array).size(), "all the returning creatures are gated on the stage")

func test_returning_creatures_only_appear_as_it_heals() -> void:
	var names := func(d: GameStateData, stage: int) -> Array:
		d.set_flag("rewild_lease_" + MOOR, stage)
		var z := ZoneData.load_id(MOOR)
		Rewild.apply(d, z)
		return Encounters.candidates(z, "grass", "day", "clear", d.flags, "summer").map(func(e): return str(e.species))
	var d := GameStateData.new()
	var s0: Array = names.call(d, 0)
	assert_false(s0.has("peregrin") or s0.has("ptarmlet") or s0.has("kitelet"), "nothing has come back to a drained moor")
	var s2: Array = names.call(d, 2)
	assert_true(s2.has("peregrin"), "raptors by stage two")
	assert_false(s2.has("ptarmlet"), "the rare one waits for Wild")
	var s3: Array = names.call(d, 3)
	assert_true(s3.has("ptarmlet"), "and comes at last")

func test_rewilding_sites_are_still_six() -> void:
	assert_eq(Rewild.sites().size(), 6, "leases are not part of the six")
	assert_eq(Rewild.sites_in(MOOR).size(), 0)
