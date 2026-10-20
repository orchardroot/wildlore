extends TestCase
## The follower in motion: a real Player and Follower on a FakeOverworld, driven a frame at a time with a held
## direction. It should stay locked one step behind, with no stalls, catch-up jumps or rubber-banding.

const DT := 1.0 / 60.0
const EPS := 0.002

var _saved_party: Array
var _saved_setting: bool
var _saved_quality: String

func _open(w := 24, h := 12) -> Array:
	var rows := []
	for y in h:
		rows.append(".".repeat(w))
	return rows

## Party lead in place and the setting on, so the follower has a sprite and shows.
func _ow(rows: Array, at: Vector2i, facing := "right", edges := {}) -> FakeOverworld:
	_saved_party = Game.data.party
	_saved_setting = Settings.follower
	Game.data.party = [Fixtures.creature("kindlet", 10)]
	Settings.follower = true
	_saved_quality = Settings.quality
	Settings.quality = "low"  # no dust puffs: the particles want to be in a running tree
	var ow := FakeOverworld.make(rows, at, facing, edges)
	return ow

func _done(ow: FakeOverworld) -> void:
	ow.free()
	Game.data.party = _saved_party
	Settings.follower = _saved_setting
	Settings.quality = _saved_quality

static func _xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

## Holds `dir` for `frames` frames (dt each, `ticks` physics ticks a frame) and records both positions.
func _hold(ow: FakeOverworld, dir: String, frames: int, log: Array, dt := DT, ticks := 1) -> void:
	ow.player.forced_dir = dir
	for i in frames:
		ow.frame(dt, ticks)
		log.append([_xz(ow.player.position), _xz(ow.follower.position), dt])

## The checks every held walk must pass: the follower never jumps further in a frame than the player could
## (`hop_slack` allows a ledge hop), never stands still while the player walks on, and stays a step behind.
func _check_smooth(log: Array, what: String, max_speed: float, hop_slack := 1.0, max_gap := 1.0) -> void:
	var stalls := 0
	var worst_jump := 0.0
	var worst_gap := 0.0
	var closest := 9.0
	for i in range(1, log.size()):
		var p0: Vector2 = log[i - 1][0]
		var p1: Vector2 = log[i][0]
		var f0: Vector2 = log[i - 1][1]
		var f1: Vector2 = log[i][1]
		var dt: float = log[i][2]
		worst_jump = maxf(worst_jump, f0.distance_to(f1) / (max_speed * dt * hop_slack))
		if p0.distance_to(p1) > EPS and f0.distance_to(f1) <= EPS:
			stalls += 1
		worst_gap = maxf(worst_gap, p1.distance_to(f1))
		closest = minf(closest, p1.distance_to(f1))
	assert_true(worst_jump <= 1.0 + EPS, "%s: the follower jumped %.2fx further in a frame than it can walk" % [what, worst_jump])
	assert_eq(stalls, 0, "%s: frames where the follower stood still while the player walked" % what)
	assert_true(worst_gap <= max_gap + EPS, "%s: fell %.2f tiles behind (rubber-banding)" % [what, worst_gap])
	assert_true(closest >= 0.7 - EPS, "%s: crowded the player (%.2f tiles)" % [what, closest])

func _ends_behind(ow: FakeOverworld, behind: Vector2i, what: String) -> void:
	assert_eq(ow.follower.tile, behind, "%s: on the tile the player just left" % what)
	assert_true(_xz(ow.follower.position).distance_to(Vector2(behind.x + 0.5, behind.y + 0.5)) <= EPS,
		"%s: and standing in the middle of it, got %s" % [what, ow.follower.position])

## Lets every step in flight finish, without holding a direction.
func _settle(ow: FakeOverworld, log: Array) -> void:
	_hold(ow, "", 40, log)

func test_walking_held_stays_locked_one_tile_behind() -> void:
	var ow := _ow(_open(), Vector2i(2, 5))
	var log := []
	_hold(ow, "right", 120, log)  # 2 seconds: 8 steps
	_check_smooth(log, "walking", Player.WALK_SPEED)
	assert_true(ow.steps.size() >= 7, "the player walked (%d steps)" % ow.steps.size())
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(1, 0), "walking")
	_done(ow)

func test_mid_step_it_is_exactly_one_tile_behind_in_a_straight_line() -> void:
	var ow := _ow(_open(), Vector2i(2, 5))
	var log := []
	_hold(ow, "right", 90, log)
	for i in range(20, log.size()):  # once the follower has lined up behind
		assert_near((log[i][0] as Vector2).x - (log[i][1] as Vector2).x, 1.0, EPS, "frame %d" % i)
	_done(ow)

func test_running_held() -> void:
	var ow := _ow(_open(40), Vector2i(2, 5))
	var log := []
	ow.player._run_latched = true
	var mode := Settings.run_mode
	Settings.run_mode = "toggle"
	_hold(ow, "right", 120, log)
	Settings.run_mode = mode
	_check_smooth(log, "running", Player.RUN_SPEED)
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(1, 0), "running")
	_done(ow)

func test_cycling_held() -> void:
	var ow := _ow(_open(40), Vector2i(2, 5))
	ow.player.set_bike(true)
	var log := []
	_hold(ow, "right", 120, log)
	_check_smooth(log, "cycling", Player.BIKE_SPEED)
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(1, 0), "cycling")
	_done(ow)

func test_turning_while_walking() -> void:
	var ow := _ow(_open(), Vector2i(2, 2))
	var log := []
	_hold(ow, "right", 47, log)
	_hold(ow, "down", 47, log)
	_hold(ow, "left", 47, log)
	_hold(ow, "up", 30, log)
	_check_smooth(log, "turning", Player.WALK_SPEED)
	_settle(ow, log)
	var last: Vector2i = ow.steps[ow.steps.size() - 1]
	var before: Vector2i = ow.steps[ow.steps.size() - 2]
	_ends_behind(ow, before, "turning")
	assert_eq(last, ow.player.grid_pos)
	_done(ow)

func test_uneven_frame_times() -> void:
	var ow := _ow(_open(40), Vector2i(2, 5))
	var log := []
	for i in 30:  # an old iMac now and then drops a frame: two physics ticks, then a short frame with none
		_hold(ow, "right", 3, log)
		_hold(ow, "right", 1, log, DT * 2.0, 2)
		_hold(ow, "right", 1, log, DT * 0.5, 0)
	_check_smooth(log, "uneven frames", Player.WALK_SPEED)
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(1, 0), "uneven frames")
	_done(ow)

func test_walking_into_a_wall_does_not_jitter() -> void:
	var rows := _open(8)
	rows[5] = "......H."
	var ow := _ow(rows, Vector2i(1, 5))
	var log := []
	_hold(ow, "right", 150, log)  # reaches x=5 against the hedge, then keeps pushing
	assert_eq(ow.player.grid_pos, Vector2i(5, 5))
	_check_smooth(log, "into a wall", Player.WALK_SPEED)
	var still := log.slice(log.size() - 40)
	for e in still:
		assert_true((e[1] as Vector2).distance_to(still[0][1]) <= EPS, "stays put while the player pushes the wall")
	_ends_behind(ow, Vector2i(4, 5), "into a wall")
	_done(ow)

func test_ledge_hop_then_carry_on() -> void:
	var rows := _open(6, 14)
	rows[5] = "LLLLLL"
	var ow := _ow(rows, Vector2i(2, 1), "down")
	var log := []
	_hold(ow, "down", 150, log)
	# the follower hops down a step later, two tiles in one step's time, so it is twice as quick and two behind
	_check_smooth(log, "ledge", Player.WALK_SPEED, 2.0, 2.0)
	assert_has(ow.steps, Vector2i(2, 6), "the player hopped the ledge")
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(0, 1), "ledge")
	_done(ow)

func test_crossing_an_edge_lands_behind_in_the_next_zone() -> void:
	var ow := _ow(_open(6), Vector2i(1, 5), "right", {"east": {"to": "fake"}})
	var log := []
	_hold(ow, "right", 120, log)
	assert_eq(ow.edge_crossed, Vector2i(6, 5), "walked off the east edge")
	# what load_zone does after the fade: the player is placed in the new zone and the follower reattached
	ow.player.forced_dir = ""
	_settle(ow, log)
	ow.player.place(Vector2i(0, 5), "right", 0.0)
	Follower.attach(ow)
	var t := ow.follower.tile  # behind is off the map, so it stands beside the player until the first step
	assert_eq(absi(t.x - 0) + absi(t.y - 5), 1, "next to the player on arrival, got %s" % t)
	log.clear()
	_hold(ow, "right", 60, log)
	_settle(ow, log)
	_ends_behind(ow, ow.player.grid_pos - Vector2i(1, 0), "after the edge")
	_done(ow)

func test_follower_frame_cost_is_negligible() -> void:
	var ow := _ow(_open(400), Vector2i(2, 5))
	ow.player.forced_dir = "right"
	var t := 0
	for i in 600:
		ow.player._physics_process(DT)
		var t0 := Time.get_ticks_usec()
		ow.player._process(DT)
		ow.follower._process(DT)
		t += Time.get_ticks_usec() - t0
	assert_true(t / 600.0 < 60.0, "player and follower _process cost %.1f us a frame" % (t / 600.0))
	_done(ow)
