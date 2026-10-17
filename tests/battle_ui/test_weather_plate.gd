extends TestCase
## The battle HUD's weather plate: hidden under clear skies, shows the weather, and counts a called-up weather down.

func test_plate_shows_weather_and_turns() -> void:
	var hud := BattleHUD.new()
	hud._ready()
	hud.set_weather("clear", 0)
	assert_false(hud.weather_plate.visible)
	hud.set_weather("drizzle", 0)
	assert_true(hud.weather_plate.visible)
	assert_eq(hud.weather_plate.name_l.text, "Drizzle")
	assert_eq(hud.weather_plate.sub_l.text, "Today's weather")
	assert_false(hud.weather_plate.pips.visible)
	hud.set_weather("downpour", 5)
	assert_eq(hud.weather_plate.sub_l.text, "5 turns left")
	assert_eq(hud.weather_plate.pips.total, 5)
	hud.set_weather("downpour", 1)
	assert_eq(hud.weather_plate.sub_l.text, "1 turn left")
	assert_eq(hud.weather_plate.pips.left, 1)
	hud.set_weather("fog", 8)
	assert_eq(hud.weather_plate.pips.total, 8)
	hud.free()
