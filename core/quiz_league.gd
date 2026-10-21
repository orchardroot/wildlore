class_name QuizLeague
extends RefCounted
## The pub quiz league: a table per nation (data/quiz_league.json). Every round you finish in a pub of that nation
## (once per real day per pub, like the prize) adds your score to your points; the rival teams' points are worked
## out from a fixed seed, so the table is the same every time it's opened and nothing needs saving but your own
## total. After `season` fixtures the season closes: top of the table is the nation's title, paid once. Two titles
## qualify you for the cup final in Dublin. Pure logic; the quiz command (story/commands.gd) calls it.
##
## Flags: qleague_<nation>_played, qleague_<nation>_pts, qleague_title_<nation>, qleague_cup, qleague_day_<pub>.

const PATH := "res://data/quiz_league.json"
const DAY_PREFIX := "qleague_day_"
const CUP_FLAG := "qleague_cup"

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var raw: Variant = JsonUtil.read(PATH)
		_cfg = raw if raw is Dictionary else {"leagues": {}}
	return _cfg

static func nations() -> Array:
	return cfg().leagues.keys()

static func league(nation: String) -> Dictionary:
	return cfg().leagues.get(nation, {})

static func season() -> int:
	return int(cfg().get("season", 6))

static func played(data: GameStateData, nation: String) -> int:
	return int(data.flag("qleague_%s_played" % nation) if data.flag("qleague_%s_played" % nation) != null else 0)

static func points(data: GameStateData, nation: String) -> int:
	return int(data.flag("qleague_%s_pts" % nation) if data.flag("qleague_%s_pts" % nation) != null else 0)

static func over(data: GameStateData, nation: String) -> bool:
	return played(data, nation) >= season()

static func has_title(data: GameStateData, nation: String) -> bool:
	return data.flag("qleague_title_" + nation) == true

static func titles(data: GameStateData) -> int:
	var n := 0
	for nation in nations():
		if has_title(data, nation):
			n += 1
	return n

## A rival's score (0 to 5) in fixture `fixture`: its strength, a fixed nudge either way, rounded.
static func rival_score(nation: String, team: Dictionary, fixture: int) -> int:
	var h := 7
	for ch in "%s|%s|%d" % [nation, team.name, fixture]:
		h = (h * 31 + ch.unicode_at(0)) % 2147483629
	var nudge := (Rng.new(h).roll() - 0.5) * 3.0
	return clampi(roundi(float(team.strength) + nudge), 0, 5)

static func rival_points(nation: String, team: Dictionary, fixtures: int) -> int:
	var total := 0
	for f in fixtures:
		total += rival_score(nation, team, f)
	return total

## The table after your fixtures so far: [{name, pts, me}], best first. A tie puts the rivals ahead of you.
static func table(data: GameStateData, nation: String) -> Array:
	var n := played(data, nation)
	var rows: Array = [{"name": "You", "pts": points(data, nation), "me": true}]
	for t in league(nation).get("teams", []):
		rows.append({"name": str(t.name), "pts": rival_points(nation, t, n), "me": false})
	rows.sort_custom(func(a, b): return a.pts > b.pts if a.pts != b.pts else (not a.me and b.me))
	return rows

static func rank(data: GameStateData, nation: String) -> int:
	var rows := table(data, nation)
	for i in rows.size():
		if rows[i].me:
			return i + 1
	return rows.size()

static func ordinal(n: int) -> String:
	return ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh"][clampi(n, 0, 7)]

## One-line state of the table, for the quizmaster to read out.
static func summary(data: GameStateData, nation: String) -> String:
	var lg := league(nation)
	if lg.is_empty():
		return ""
	var rows := table(data, nation)
	var top: Dictionary = rows[0] if not rows[0].me else rows[1]
	var line := "%s: you are %s of %d on %d points after %d of %d fixtures." % [lg.name, ordinal(rank(data, nation)), rows.size(), points(data, nation), mini(played(data, nation), season()), season()]
	if rank(data, nation) > 1:
		line += " %s lead on %d." % [top.name, top.pts]
	return line

## Counts a finished round at `pub` in `nation`, unless that pub already counted today or the season is over.
## Returns {counted, closed, title, money, cur, line}.
static func record(data: GameStateData, nation: String, pub: String, score: int, zone_for_money := "") -> Dictionary:
	var out := {"counted": false, "closed": false, "title": false, "money": 0, "cur": Wallet.GBP, "line": ""}
	if league(nation).is_empty() or over(data, nation) or DailyKey.done_today(data, DAY_PREFIX + pub):
		return out
	data.set_flag(DAY_PREFIX + pub, DailyKey.stamp(data))
	data.set_flag("qleague_%s_played" % nation, played(data, nation) + 1)
	data.set_flag("qleague_%s_pts" % nation, points(data, nation) + clampi(score, 0, 5))
	out.counted = true
	out.line = summary(data, nation)
	if over(data, nation):
		out.closed = true
		if rank(data, nation) == 1:
			out.title = true
			data.set_flag("qleague_title_" + nation, true)
			var paid := Wallet.earn_here(data, int(cfg().get("title_prize", 600)), zone_for_money if zone_for_money != "" else nation)
			out.money = paid.amount
			out.cur = paid.cur
			out.line += " Champions! The trophy is yours for the year."
		else:
			out.line += " The season is done, and %s take the trophy. There is always next year." % table(data, nation)[0].name
	return out

# ---- the cup final

static func final_pub() -> String:
	return str(cfg().get("final_pub", "dublin"))

static func final_size() -> int:
	return int(cfg().get("final_size", 7))

static func cup_won(data: GameStateData) -> bool:
	return data.flag(CUP_FLAG) == true

static func cup_open(data: GameStateData) -> bool:
	return not cup_won(data) and titles(data) >= int(cfg().get("titles_needed", 2))

## The result of a final round: {won, money, cur, line}. The prize is paid once; losing costs nothing but pride.
static func cup_result(data: GameStateData, score: int, total: int) -> Dictionary:
	var out := {"won": false, "money": 0, "cur": Wallet.GBP, "line": ""}
	if not cup_open(data):
		return out
	if score < int(cfg().get("final_pass", 5)):
		out.line = "Not this time. The cup stays in its case until you come back and win it."
		return out
	out.won = true
	data.set_flag(CUP_FLAG, true)
	var paid := Wallet.earn_here(data, int(cfg().get("cup_prize", 1500)), final_pub())
	out.money = paid.amount
	out.cur = paid.cur
	out.line = "%d out of %d. The Pub Quiz Cup is yours: champion of the isles." % [score, total]
	return out

## The most the league can ever pay out, once: the money check.
static func total_prizes() -> int:
	return nations().size() * int(cfg().get("title_prize", 600)) + int(cfg().get("cup_prize", 1500))
