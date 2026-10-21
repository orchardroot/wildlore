class_name Games
extends RefCounted
## Highland games, hurling and shinty (data/games.json): four short, fair minigames. The caber is hold-and-release, the
## tug of war is a rhythm tap powered by your lead creature's Attack, and hurling and shinty are five shots at a goal
## with a keeper who leans before he dives. Pure rules; ui/games_screen.gd plays them and story/games_run.gd (the
## `games` command) starts them.

const PATH := "res://data/games.json"
const FLAG_DONE := "games_done_"     # games_done_<event> = the DailyKey stamp of today's paid win
const FLAG_FIRST := "games_first_"   # games_first_<event> = won at least once
const EVENTS := ["caber", "tug", "hurling", "shinty"]

# caber
const CABER_FULL := 1.7              # seconds of run-up to a full hold
const CABER_SWEET := 0.8             # the power that lands it at twelve o'clock
# tug
const TUG_BEAT := 0.7                # seconds between beats
const TUG_SECONDS := 30.0
const NO_LEAD_ATK := 40
# goal: x is -1..1 between the posts, y is 0 (grass) to 1 (the crossbar) and up to 1.6 (over it)
const KEEPER_REACH := 1.0

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"events": {}}
	return _cfg

static func event(id: String) -> Dictionary:
	return cfg().events.get(id, {})

# ---- the caber

## Run-up power after `held` seconds (0..1, capped).
static func caber_power(held: float, easy: bool) -> float:
	return clampf(held / (CABER_FULL * (1.4 if easy else 1.0)), 0.0, 1.0)

## Where the caber lands as hours away from twelve o'clock (0 perfect .. 6 straight back): too soft it flops short,
## too hard it drops behind you. A cap of 1.0 (holding to the end) is a drop.
static func caber_offset(power: float, easy: bool) -> int:
	var width := 0.1 if easy else 0.06
	var d := absf(power - CABER_SWEET)
	if power >= 1.0:
		return 6
	return clampi(int(floorf(d / width)), 0, 6)

## Points for a toss: 12 for twelve o'clock, two fewer for each hour off.
static func caber_points(offset: int) -> int:
	return maxi(0, 12 - 2 * clampi(offset, 0, 6))

static func clock_name(offset: int) -> String:
	return ["twelve o'clock", "one o'clock", "two o'clock", "three o'clock", "four o'clock", "five o'clock", "six o'clock"][clampi(offset, 0, 6)]

# ---- the tug of war

## How hard one good tap pulls, from the creature's Attack stat (about 50 to 150 for a creature in play).
static func tug_pull(atk: int) -> float:
	return 0.06 + float(clampi(atk, 1, 300)) / 1600.0

## How the other side drags, per second. Easier games drag less.
static func tug_drag(easy: bool) -> float:
	return 0.085 if easy else 0.11

## How close a tap was to the beat: 1.0 dead on, 0.5 inside the window, 0 a miss. `offset` in seconds from the beat.
static func tug_judge(offset: float, easy: bool) -> float:
	var w := 0.26 if easy else 0.17
	var a := absf(offset)
	if a <= w * 0.4:
		return 1.0
	return 0.5 if a <= w else 0.0

## The rope after `dt` seconds: -1 is your end gone, +1 is the other side's marker over the line.
static func tug_step(pos: float, dt: float, easy: bool) -> float:
	return clampf(pos - tug_drag(easy) * dt, -1.0, 1.0)

static func tug_tap(pos: float, atk: int, quality: float) -> float:
	return clampf(pos + tug_pull(atk) * quality, -1.0, 1.0)

# ---- shots at goal (hurling and shinty)

## What a strike at `aim` is worth against a keeper covering `zone` (0 left, 1 centre, 2 right): {kind: goal | point |
## saved | wide | over, pts}. Hurling scores 3 for a goal and 1 for a point over the bar; shinty scores only goals.
static func shot(aim: Vector2, zone: int, event_id: String) -> Dictionary:
	var e := event(event_id)
	var goal := int(e.get("goal", 1))
	var point := int(e.get("point", 0))
	if absf(aim.x) > 1.0 or aim.y < 0.0 or aim.y > 1.6:
		return {"kind": "wide", "pts": 0}
	if aim.y > 1.0:
		return {"kind": "point" if point > 0 else "over", "pts": point}
	if zone_of(aim.x) == zone and aim.y <= KEEPER_REACH:
		return {"kind": "saved", "pts": 0}
	return {"kind": "goal", "pts": goal}

static func zone_of(x: float) -> int:
	if x < -1.0 / 3.0:
		return 0
	return 2 if x > 1.0 / 3.0 else 1

## The keeper's dive and the way he leans first. He leans the right way most of the time.
static func keeper(rng: Rng, easy: bool) -> Dictionary:
	var zone := rng.roll_int(0, 2)
	var honest := rng.roll() < (0.85 if easy else 0.6)
	var lean := zone
	if not honest:
		lean = (zone + rng.roll_int(1, 2)) % 3
	return {"zone": zone, "lean": lean}

# ---- results

static func won_today(data: GameStateData, id: String) -> bool:
	return DailyKey.done_today(data, FLAG_DONE + id)

## Books a win: the counter, the first-win flag and the day's prize. Returns {first, prize (whole pounds), line}.
static func win(data: GameStateData, id: String, zone_id: String) -> Dictionary:
	var e := event(id)
	TrainerStats.add(data, "games_won")
	var out := {"first": false, "prize": 0, "line": ""}
	if not data.flags.has(FLAG_FIRST + id):
		data.set_flag(FLAG_FIRST + id, 1)
		out.first = true
		out.prize = int(e.get("first_prize", 0))
		out.line = Standing.add(data, str(e.get("nation", "")), 2)
	elif not won_today(data, id):
		out.prize = int(e.get("prize", 0))
	if int(out.prize) > 0 or bool(out.first):
		data.set_flag(FLAG_DONE + id, DailyKey.stamp(data))
	return out

## The lead's Attack for the tug, or a modest default with no creature fit to pull.
static func lead_atk(data: GameStateData) -> int:
	for c in data.party:
		if c is Creature and not c.is_fainted():
			return c.calc_stat("atk")
	return NO_LEAD_ATK
