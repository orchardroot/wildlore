class_name ForecastRun
extends RefCounted
## The `forecast` story command: {"do": "forecast", "who": "Forecaster", "set": "<flag set on a pass>"}.
## The forecaster explains a chart the first time, then the round itself is ui/forecasting_screen.gd (three
## practice charts and today's, two questions each; see Forecasting). A pass sets `set`, counts in
## forecast_passes and pays the day's prize once (Forecasting.prize); calling today's weather right earns a nod.

var cmd: Commands
var host

const FLAG_EXPLAINED := "forecast_explained"

func _init(c: Commands) -> void:
	cmd = c
	host = c.host

func _weather() -> String:
	var w := str(host.current_weather()) if host.has_method("current_weather") else str(host.data.weather)
	return w if w != "" else "clear"

func run(c: Dictionary) -> void:
	var data: GameStateData = host.data
	var who := str(c.get("who", "Forecaster"))
	if data.flag(FLAG_EXPLAINED) != true:
		await host.say(who, "A weather chart is mostly isobars: lines joining places with the same air pressure. Close together means strong wind. L is a low, H is a high.")
		await host.say(who, "Air flows anticlockwise round a low and clockwise round a high, up here in the northern hemisphere. Stand with your back to the wind and the low is on your left. That's Buys Ballot's law, and it's most of the job.")
		await host.say(who, "Lows bring rising air, cloud and rain, and their fronts: a warm front for steady drizzle, a cold front for heavy showers. Highs bring sinking air and settled weather: sun in summer, frost or fog in winter.")
		data.set_flag(FLAG_EXPLAINED, true)
	var opts := ["Read the charts", "Not now"]
	if await host.choice("Three charts from the archive, then today's. Two questions each: the wind, then the sky. Pass mark %d of %d." % [Forecasting.pass_mark(), Forecasting.total()], opts) != 0:
		await host.say(who, "Fair enough. The charts will keep. The weather won't, but the charts will.")
		return
	var res = await host.open_menu("forecasting:" + _weather())
	if not (res is Dictionary):
		await host.say(who, "Walked out mid-chart? There's a front coming through, I expect.")
		return
	var score := int(res.get("score", 0))
	var total := int(res.get("total", Forecasting.total()))
	var r := Forecasting.record(data, score)
	await host.say(who, "%d out of %d. %s" % [score, total, Forecasting.reaction(score, total)])
	if bool(res.get("today", false)):
		await host.say(who, "And you called today's chart right. Step outside and check my work.")
	if bool(r.passed) and c.has("set"):
		cmd._set_flag(str(c.set), true)
	var prize := Forecasting.prize(data, score, total)
	if prize > 0:
		var paid := Wallet.earn_here(data, prize, host.zone_id())
		await host.sfx("item")
		await host.say("", "%s takes %s from the forecasters' sweepstake%s." % [data.player_name, Wallet.fmt(int(paid.amount), str(paid.cur)), ", the lot, for full marks" if score >= total else ""])
	elif bool(r.passed):
		await host.say(who, "The sweepstake's paid out for today. Come back tomorrow and I'll find you a worse chart.")
